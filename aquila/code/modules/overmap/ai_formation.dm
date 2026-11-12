/// AQUILA - jak okręt AI zachowuje się na dystansie i kiedy w ogóle wchodzi do walki.
///
/// Dwie rzeczy widoczne na nagraniach z piaskownicy (raport/sensory_05_sensory_ai.md):
///
/// 1. Okręty trzymające dystans (lotniskowce, torpedowce, każdy kto czeka) stały w miejscu.
///    Stary kod z #569 w tym pasie wołał circle_around() i enable_dampeners(), a tłumiki wyhamowywały
///    okręt do zera: 22-41% klatek okręty ani się nie ruszały, ani nie obracały, lotniskowce nawet 68%.
///    Teraz zamiast wisieć krążą po łuku wokół celu, przesuwając się na nową pozycję co kilka sekund.
///
/// 2. Pojedynczy okręt wchodził w sam środek kilku wrogów. Teraz, zanim zejdzie na zasięg dział,
///    sprawdza, czy ma przy sobie dość floty; jeśli nie, trzyma się dalej i czeka na resztę.
///    Brawurowy dowódca się tym nie przejmuje, ostrożny czeka dłużej.

/// Admin i piaskownica: całość osobno (Debug > Toggle AI formation)
GLOBAL_VAR_INIT(ai_formation_enabled, TRUE)

/// Jak długo okręt trzyma się raz wybranego punktu na okręgu dystansu
#define AI_REPOSITION_MIN (6 SECONDS)
#define AI_REPOSITION_MAX (13 SECONDS)
/// Uznajemy punkt za osiągnięty z tej odległości.
/// Musi być większe niż 12, bo bazowe move_toward() (ai-skynet.dm) odpala silniki tylko wtedy,
/// gdy cel jest dalej niż 12 pól - bliżej okręt sam z siebie hamuje tłumikami i staje.
#define AI_REPOSITION_REACHED 16
/// Najbliższy punkt, jaki w ogóle wybieramy; poniżej tego okręt by do niego dopłynął bez ciągu
#define AI_REPOSITION_MIN_HOP 22
/// Co ile okręt może zmienić stronę okrążania, żeby nie zygzakował
#define AI_SIDE_SWITCH_CHANCE 15

/// W jakim promieniu liczymy wrogów, przed którymi warto poczekać na swoich
#define AI_ENGAGE_THREAT_RANGE 35
/// Przewaga wroga, przy której zwykły dowódca czeka na resztę floty
#define AI_ENGAGE_MARGIN 2
#define AI_ENGAGE_MARGIN_CAUTIOUS 1
#define AI_ENGAGE_MARGIN_RECKLESS 5

#define AI_TEMPERAMENT_CAUTIOUS "ostrożny"
#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/obj/structure/overmap
	/// AQUILA - dokąd okręt leci, trzymając dystans od celu
	var/turf/ai_standoff_point
	/// AQUILA - world.time, do którego trzyma ten punkt
	var/ai_standoff_until = 0
	/// AQUILA - 1 albo -1: w którą stronę okrąża cel
	var/ai_standoff_side = 0
	/// AQUILA - czeka na resztę floty, zamiast wchodzić na zasięg dział
	var/ai_waiting_for_support = FALSE

/// Bazowe move_toward() (ai-skynet.dm) odpala silniki tylko wtedy, gdy cel jest dalej niż 12 pól.
/// Bliżej okręt sam ustawia kurs, włącza tłumiki i staje. Każdy punkt, który mu podajemy,
/// przechodzi więc przez to: zbyt bliski jest przesuwany dalej po tym samym namiarze.
#define AI_ENGINE_DEAD_ZONE 14

/obj/structure/overmap/proc/ai_far_enough_point(turf/point, minimum = AI_ENGINE_DEAD_ZONE)
	if(!point || point.z != z)
		return point
	var/dist = overmap_dist(src, point)
	if(dist >= minimum)
		return point
	// Ten sam kierunek, tylko dalej; przy punkcie dokładnie pod nami bierzemy własny kurs
	var/bearing = dist ? overmap_angle(src, point) : angle
	return locate(clamp(round(x + sin(bearing) * minimum), 1, world.maxx),
		clamp(round(y + cos(bearing) * minimum), 1, world.maxy), z)

// ---------------------------------------------------------------- krążenie zamiast stania

/// Ilu wrogów jest w promieniu, w którym mogliby nas wspólnie ostrzelać
/obj/structure/overmap/proc/count_ai_threats(range = AI_ENGAGE_THREAT_RANGE)
	. = 0
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!istype(other) || other == src || other.z != z || other.mass <= MASS_TINY)
			continue
		if(!is_ai_hostile(other) || istype(other, /obj/structure/overmap/asteroid))
			continue
		// Liczymy tylko wrogów, których widzimy: o niewykrytych dowódca nie wie
		if(overmap_dist(src, other) <= range && other.is_sensor_visible(src) >= SENSOR_VISIBILITY_FAINT)
			.++

/// Najbliższy sojusznik godny tej nazwy (nie myśliwiec, nie asteroida), albo null
/obj/structure/overmap/proc/get_ai_nearest_ally()
	var/obj/structure/overmap/best
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!istype(other) || other == src || other.z != z || other.faction != faction)
			continue
		if(other.mass <= MASS_TINY || istype(other, /obj/structure/overmap/asteroid) || other.ai_fleeing)
			continue
		var/dist = overmap_dist(src, other)
		if(dist < best_dist)
			best_dist = dist
			best = other
	return best

/// Dokąd lecieć, gdy wrogów jest więcej niż swoich: do najbliższego swojego, nie na wroga.
/// Null, gdy nie ma do kogo dołączyć albo i tak jesteśmy już przy nim.
/obj/structure/overmap/proc/get_ai_regroup_point()
	if(!ai_waiting_for_support)
		return null
	var/obj/structure/overmap/ally = get_ai_nearest_ally()
	if(QDELETED(ally) || overmap_dist(src, ally) < 12)
		return null
	return ai_far_enough_point(get_turf(ally))

/// Ilu swoich jest w tym samym promieniu, w którym liczymy wrogów
/obj/structure/overmap/proc/count_ai_threats_allies(range = AI_ENGAGE_THREAT_RANGE)
	. = 0
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!istype(other) || other == src || other.z != z || other.faction != faction)
			continue
		if(other.mass <= MASS_TINY || istype(other, /obj/structure/overmap/asteroid))
			continue
		if(overmap_dist(src, other) <= range)
			.++

/// Namiar na najbliższego sojusznika, albo null
/obj/structure/overmap/proc/get_ai_ally_bearing()
	var/obj/structure/overmap/best
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!istype(other) || other == src || other.z != z || other.faction != faction)
			continue
		if(other.mass <= MASS_TINY || istype(other, /obj/structure/overmap/asteroid))
			continue
		var/dist = overmap_dist(src, other)
		if(dist < best_dist)
			best_dist = dist
			best = other
	return best ? overmap_angle(src, best) : null

/// Punkt na okręgu dystansu wokół celu, do którego teraz lecimy. Null, gdy moduł jest wyłączony.
/obj/structure/overmap/proc/get_ai_standoff_point(atom/target, standoff)
	if(!GLOB.ai_formation_enabled || !target || standoff <= 0)
		return null
	// Trzymamy raz wybrany punkt, póki do niego nie dolecimy i póki nie minie jego czas
	if(ai_standoff_point && world.time < ai_standoff_until && ai_standoff_point.z == z \
		&& overmap_dist(src, ai_standoff_point) > AI_REPOSITION_REACHED \
		&& abs(overmap_dist(target, ai_standoff_point) - standoff) < standoff * 0.5)
		return ai_standoff_point
	var/bearing = overmap_angle(target, src) // gdzie jesteśmy względem celu
	if(!ai_standoff_side || prob(AI_SIDE_SWITCH_CHANCE))
		// Krążymy w stronę swoich, żeby flota się schodziła, a nie rozchodziła
		var/ally_bearing = get_ai_ally_bearing()
		if(isnull(ally_bearing))
			ai_standoff_side = pick(1, -1)
		else
			ai_standoff_side = closer_angle_difference(bearing, ally_bearing) >= 0 ? 1 : -1
	// Bierzemy pierwszy punkt na okręgu, do którego jest dość daleko, żeby silniki w ogóle ruszyły
	// Coraz szersze łuki: bierzemy pierwszy, który wypada dość daleko
	var/static/list/arcs = list(60, 90, 120, 150)
	var/turf/chosen
	for(var/arc in arcs)
		var/new_bearing = (bearing + ai_standoff_side * arc + 360) % 360
		var/turf/candidate_turf = locate(
			clamp(round(target.x + sin(new_bearing) * standoff), 1, world.maxx),
			clamp(round(target.y + cos(new_bearing) * standoff), 1, world.maxy), z)
		chosen = candidate_turf
		if(overmap_dist(src, candidate_turf) >= AI_REPOSITION_MIN_HOP)
			break
	ai_standoff_point = chosen
	ai_standoff_until = world.time + rand(AI_REPOSITION_MIN, AI_REPOSITION_MAX)
	return ai_standoff_point

// ---------------------------------------------------------------- osłona lotniskowca

/// AQUILA - nadpisanie `/datum/ai_goal/proc/guard()` z ai-skynet.dm (częściowe, LEGACY_OVERRIDES.md).
/// Bazowa wersja po dolocie na AI_PDC_RANGE wciskała hamulce i zerowała ciąg, więc eskorta parkowała
/// przy lotniskowcu do końca bitwy. Z pomiaru nagrań: cel "Protect supply lines" stał 42,3% klatek,
/// co dawało 25% całego stania we flocie. Teraz w promieniu osłony eskorta krąży wokół osłanianego okrętu;
/// dalej, z wyłączonym przełącznikiem i przy okręcie osłaniającym sam siebie idzie bazowe ..().
/datum/ai_goal/guard(obj/structure/overmap/OM, obj/structure/overmap/to_guard)
	if(QDELETED(OM) || QDELETED(to_guard))
		return
	if(!GLOB.ai_formation_enabled || to_guard == OM || overmap_dist(OM, to_guard) > AI_PDC_RANGE)
		return ..()
	OM.circle_around(to_guard) // ustawia brakes = FALSE i move_mode = NORTH

// ---------------------------------------------------------------- czekanie na resztę floty

/// Czy warto poczekać ze zbliżeniem, aż będzie nas dość
/obj/structure/overmap/proc/ai_waits_for_support(obj/structure/overmap/enemy)
	if(!GLOB.ai_formation_enabled || !ai_controlled || QDELETED(enemy))
		return FALSE
	// Myśliwce i okręty bez floty walczą jak dotąd, tak samo uciekinier i ten, kto już dostaje
	if(mass <= MASS_TINY || !fleet || ai_fleeing)
		return FALSE
	var/margin = AI_ENGAGE_MARGIN
	switch(ai_temperament)
		if(AI_TEMPERAMENT_RECKLESS)
			margin = AI_ENGAGE_MARGIN_RECKLESS
		if(AI_TEMPERAMENT_CAUTIOUS)
			margin = AI_ENGAGE_MARGIN_CAUTIOUS
	var/threats = count_ai_threats()
	if(threats <= 1)
		return FALSE // Jeden na jednego to nie szarża
	// Swoich liczymy w tym samym promieniu co wrogów, inaczej porównujemy różne rzeczy.
	// Z rozkładu w nagraniach: "wrogów >= swoich + 2" to około 19% sytuacji, + 3 to 13%.
	return threats >= count_ai_threats_allies() + margin

/// Stan do nagrania i do etykiety taktyki
/obj/structure/overmap/proc/update_ai_formation()
	if(!ai_controlled)
		return
	ai_waiting_for_support = ai_waits_for_support(last_target)

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_formation

/client/proc/toggle_ai_formation()
	set category = "Debug"
	set name = "Toggle AI formation"
	set desc = "Włącza lub wyłącza krążenie zamiast stania i czekanie na resztę floty."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_formation_enabled = !GLOB.ai_formation_enabled
	var/state = GLOB.ai_formation_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] manewrowanie i czekanie na flotę u AI.")
	log_admin("[key_name(usr)] toggled AI formation to [GLOB.ai_formation_enabled].")

#undef AI_REPOSITION_MIN
#undef AI_REPOSITION_MAX
#undef AI_REPOSITION_REACHED
#undef AI_ENGINE_DEAD_ZONE
#undef AI_REPOSITION_MIN_HOP
#undef AI_SIDE_SWITCH_CHANCE
#undef AI_ENGAGE_THREAT_RANGE
#undef AI_ENGAGE_MARGIN
#undef AI_ENGAGE_MARGIN_CAUTIOUS
#undef AI_ENGAGE_MARGIN_RECKLESS
#undef AI_TEMPERAMENT_CAUTIOUS
#undef AI_TEMPERAMENT_RECKLESS
