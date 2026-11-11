/// AQUILA - zwiad myśliwców i łącze danych dla okrętów rakietowych AI.
///
/// Rakiety i torpedy sięgają 250 pól, ale AI strzelało nimi tylko do celu, który samo widzi, i nie dalej niż
/// na 50 pól (ai_fire w ai-skynet.dm). W piaskownicy: torpedy średnio z 23 pól, działa 95% strzałów,
/// zero strzałów do celu, którego strzelający nie widział. Tu, jak w prawdziwej flocie:
/// - jeden myśliwiec na lotniskowiec leci na zwiad: krąży na granicy, z której widzi wroga, sam zimny i cichy;
/// - gdy okręt rakietowy z jego floty jest gotowy do salwy, zwiadowca namierza cel radarem frontalnym
///   (cel musi być przed nosem). Namierzanie to emisja: cel dostaje namiar na zwiadowcę;
/// - okręt rakietowy strzela na przekazany namiar. Torpeda trzyma cel, dopóki trwa namierzanie; potem
///   leci prosto, chyba że jest już na tyle blisko, że łapie cel własną głowicą;
/// - zwiad się kończy, gdy każdy okręt rakietowy widzi cel sam, cel zaczyna gonić zwiadowcę, nie ma już komu
///   celować albo minie czas służby. Wtedy myśliwiec wraca do zwykłych zadań, czyli do ataku.
/// - zwiad wysunięty: zanim ktokolwiek zobaczy wroga, zwiadowca leci w stronę namiaru z nasłuchu albo ostatniej
///   znanej pozycji i przechodzi w zwykły zwiad, gdy coś złapie;
/// - tor radaru: gdy okręt floty pulsuje radarem, okręty rakietowe strzelają do tego, co ten radar widzi;
/// - pocisk na namiar trzyma cel, dopóki źródło go trzyma (namierzanie albo impuls radaru); potem leci prosto
///   w punkt przechwycenia i łapie cel własną głowicą z AI_SEEKER_RANGE.
/// Na razie tylko myśliwce mają radar frontalny; duże okręty namierzają dookoła (radar operatora przyjdzie później).

/// Debug > Toggle AI scouting
GLOBAL_VAR_INIT(ai_scouting_enabled, TRUE)

/// Jak długo myśliwiec jest na zwiadzie, zanim zastąpi go inny
#define AI_SCOUT_DUTY (90 SECONDS)
/// Po zakończeniu zwiadu ten sam myśliwiec przez chwilę nie wraca na zwiad
#define AI_SCOUT_COOLDOWN (40 SECONDS)
/// Zasięg namierzania radarem frontalnym myśliwca i połowa jego stożka
#define AI_SCOUT_LOCK_RANGE 35
#define AI_SCOUT_LOCK_CONE 60
/// Przy namierzaniu myśliwiec leci skosem, z celem tuż w stożku, żeby nie pchać się prosto na niego
#define AI_SCOUT_CRANK 50
/// Bliżej celu zwiad nie ma sensu: myśliwiec jest już w walce
#define AI_SCOUT_MIN_RANGE 12
/// Jak daleko okręt rakietowy strzela na namiar ze zwiadu (pocisk sięga 250, ale tyle leci długo)
#define AI_DATALINK_RANGE 120
/// Bez namierzania torpeda trzyma cel tylko z tej odległości (własna głowica)
#define AI_SEEKER_RANGE 15

/obj/structure/overmap
	/// AQUILA - wróg, którego ten myśliwiec śledzi na zwiadzie
	var/obj/structure/overmap/ai_scout_target
	/// AQUILA - zwiad wysunięty: miejsce, w które zwiadowca leci, zanim ktokolwiek zobaczy wroga
	var/turf/ai_scout_lead
	/// AQUILA - world.time, do którego trwa zwiad
	var/ai_scout_until = 0
	/// AQUILA - world.time, od którego myśliwiec może znów pójść na zwiad
	var/ai_scout_ready_at = 0
	/// AQUILA - world.time ostatniego rozpoczęcia namierzania
	var/ai_scout_lock_started = 0
	/// AQUILA - 1 albo -1: w którą stronę zwiadowca leci skosem przy namierzaniu
	var/ai_scout_side = 0
	/// AQUILA - zwiadowca, na którego namiar ten okręt właśnie strzela
	var/obj/structure/overmap/ai_datalink_firing
	/// AQUILA - lazy list: pocisk => list(źródło namiaru, cel)
	var/list/ai_datalink_shots

/datum/fleet
	/// AQUILA - lazy list myśliwców na zwiadzie
	var/list/ai_scouts

/// Zdarzenie do nagrania piaskownicy (ai_sandbox.dm); poza piaskownicą nic nie robi
/proc/ai_scout_event(text)
#ifdef AQ_AI_SANDBOX
	GLOB.ai_sandbox?.event(text)
#endif

// ---------------------------------------------------------------- kto i na kogo

/// Okręt (nie myśliwiec) z bronią kierowaną, której AI może użyć, i z amunicją do niej
/obj/structure/overmap/proc/is_ai_missile_ship()
	if(mass <= MASS_TINY)
		return FALSE
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if((weapon.weapon_control_flags & OSW_CONTROL_AI) && weapon.is_guided_weapon() && weapon.get_ammo())
			return TRUE
	return FALSE

/// Broń kierowana gotowa do strzału w target, albo null
/obj/structure/overmap/proc/get_ai_guided_weapon(obj/structure/overmap/target)
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if((weapon.weapon_control_flags & OSW_CONTROL_AI) && weapon.is_guided_weapon() && weapon.can_fire(target))
			return weapon
	return null

/// Ilu zwiadowców potrzebuje flota: jeden na lotniskowiec, ale tylko gdy ma dla kogo celować
/datum/fleet/proc/ai_scout_slots()
	if(!GLOB.ai_scouting_enabled)
		return 0
	var/strzelcy = FALSE
	for(var/obj/structure/overmap/ship as anything in all_ships)
		if(!QDELETED(ship) && ship.ai_controlled && ship.is_ai_missile_ship())
			strzelcy = TRUE
			break
	if(!strzelcy)
		return 0
	var/lotniskowce = 0
	for(var/obj/structure/overmap/supply as anything in taskforces["supply"])
		if(!QDELETED(supply))
			lotniskowce++
	return max(lotniskowce, 1)

/datum/fleet/proc/prune_ai_scouts()
	for(var/obj/structure/overmap/scout as anything in ai_scouts?.Copy())
		if(QDELETED(scout) || !scout.is_ai_scouting())
			LAZYREMOVE(ai_scouts, scout)

/// Cel dla zwiadowcy: najbliższy mu duży wróg z obrazu sytuacji floty albo z jego własnego celu
/datum/fleet/proc/get_ai_scout_target(obj/structure/overmap/scout)
	var/obj/structure/overmap/best
	var/best_dist = INFINITY
	var/list/kandydaci = list()
	for(var/obj/structure/overmap/contact as anything in ai_contact_picture)
		kandydaci += contact
	if(istype(scout.last_target, /obj/structure/overmap))
		kandydaci += scout.last_target
	for(var/obj/structure/overmap/contact as anything in kandydaci)
		if(QDELETED(contact) || contact.z != scout.z || contact.mass <= MASS_TINY || !scout.is_ai_hostile(contact))
			continue
		var/dist = overmap_dist(scout, contact)
		if(dist < best_dist)
			best_dist = dist
			best = contact
	return best

/// Gdzie zwiadowca może szukać wroga, którego nikt jeszcze nie widzi: namiar z nasłuchu (ze skrzyżowania, jeśli
/// usłyszało go dwóch) albo ostatnia znana pozycja z obrazu floty. Najbliższe zwiadowcy miejsce albo null.
/datum/fleet/proc/get_ai_scout_lead(obj/structure/overmap/scout)
	var/turf/best
	var/best_dist = INFINITY
	var/list/miejsca = list()
	for(var/obj/structure/overmap/member as anything in all_ships)
		if(QDELETED(member) || member.z != scout.z)
			continue
		for(var/obj/structure/overmap/emitter as anything in member.radar_emissions)
			if(QDELETED(emitter) || !member.get_radar_emission(emitter) || !scout.is_ai_hostile(emitter))
				continue
			miejsca += (triangulate_ai_emission(emitter) || member.get_emission_turf(emitter))
	for(var/obj/structure/overmap/contact as anything in ai_contact_picture)
		if(!QDELETED(contact) && contact.mass > MASS_TINY && scout.is_ai_hostile(contact))
			miejsca += scout.get_ai_contact_guess(contact)
	for(var/turf/miejsce as anything in miejsca)
		if(!istype(miejsce) || miejsce.z != scout.z)
			continue
		var/dist = overmap_dist(scout, miejsce)
		if(dist < best_dist)
			best_dist = dist
			best = miejsce
	return best

/// Czy ten okręt jest teraz na zwiadzie (śledzi cel albo leci do namiaru)
/obj/structure/overmap/proc/is_ai_scouting()
	return ai_scout_target || ai_scout_lead

/// Czy okręt właśnie pulsuje radarem i jego radar sięga target
/obj/structure/overmap/proc/ai_radar_sees(obj/structure/overmap/target)
	if(QDELETED(target) || target.z != z || world.time >= last_radar_pulse + RADAR_VISIBILITY_PENALTY)
		return FALSE
	return overmap_dist(src, target) <= get_suite_range(SENSOR_LIDAR, target)

// ---------------------------------------------------------------- zwiadowca

/obj/structure/overmap/proc/start_ai_scout(obj/structure/overmap/target)
	ai_scout_event("[src] idzie na zwiad nad [target]")
	ai_scout_target = target
	ai_scout_until = world.time + AI_SCOUT_DUTY
	ai_scout_side = pick(1, -1)
	LAZYOR(fleet.ai_scouts, src)

/obj/structure/overmap/proc/start_ai_scout_lead(turf/lead)
	ai_scout_event("[src] leci na zwiad wysunięty w stronę [lead.x],[lead.y]")
	ai_scout_lead = lead
	ai_scout_until = world.time + AI_SCOUT_DUTY
	ai_scout_side = pick(1, -1)
	LAZYOR(fleet.ai_scouts, src)

/obj/structure/overmap/proc/stop_ai_scout(reason)
	if(reason)
		ai_scout_event("[src] kończy zwiad: [reason]")
	if(ai_scout_target && (ai_scout_target in target_painted))
		dump_lock(ai_scout_target)
	ai_scout_target = null
	ai_scout_lead = null
	ai_scout_ready_at = world.time + AI_SCOUT_COOLDOWN
	LAZYREMOVE(fleet?.ai_scouts, src)

/// Czy któryś okręt rakietowy floty mógłby teraz strzelić w target na namiar ze zwiadu
/obj/structure/overmap/proc/has_ai_datalink_shooter(obj/structure/overmap/target)
	for(var/obj/structure/overmap/ship as anything in fleet?.all_ships)
		if(QDELETED(ship) || ship == src || !ship.ai_controlled || ship.z != z)
			continue
		if(overmap_dist(ship, target) <= AI_DATALINK_RANGE && ship.get_ai_guided_weapon(target))
			return TRUE
	return FALSE

/// Czy cel jest w stożku i zasięgu radaru frontalnego (sama geometria)
/obj/structure/overmap/proc/ai_lock_geometry_ok(obj/structure/overmap/target)
	if(QDELETED(target) || target.z != z || overmap_dist(src, target) > AI_SCOUT_LOCK_RANGE)
		return FALSE
	var/bearing = overmap_angle(src, target)
	if(isnull(bearing))
		return TRUE
	return abs(closer_angle_difference(angle, bearing)) <= AI_SCOUT_LOCK_CONE

/// Powód, dla którego zwiad ma się skończyć, albo null
/obj/structure/overmap/proc/get_ai_scout_end_reason()
	var/obj/structure/overmap/target = ai_scout_target
	if(QDELETED(target) || target.z != z)
		return "cel zniknął"
	if(world.time >= ai_scout_until)
		return "koniec służby"
	if(ai_fleeing)
		return "ucieka"
	if(overmap_dist(src, target) < AI_SCOUT_MIN_RANGE)
		return "za blisko, walka"
	if(!fleet?.ai_scout_slots())
		return "nie ma dla kogo celować"
	// Okręty rakietowe trzymają się z tyłu, więc zwiadowca jest im potrzebny także wtedy, gdy reszta floty
	// już walczy z bliska. Kończymy dopiero, gdy każdy z nich widzi cel sam. (Pierwsza wersja kończyła zwiad,
	// gdy jakikolwiek okręt floty był w zasięgu dział od celu: w piaskownicy 78% zwiadów trwało ok. 3 s.)
	if(!needs_ai_datalink(target))
		return "okręty rakietowe widzą cel same"
	// Samo wykrycie nie przerywa zwiadu; dopiero gdy cel bierze zwiadowcę na cel
	if(target.last_target == src)
		return "ścigany przez cel"
	return null

/// Czy któryś okręt rakietowy floty w zasięgu łącza nie widzi celu sam i potrzebuje namiaru ze zwiadu
/obj/structure/overmap/proc/needs_ai_datalink(obj/structure/overmap/target)
	for(var/obj/structure/overmap/ship as anything in fleet?.all_ships)
		if(QDELETED(ship) || ship == src || !ship.ai_controlled || ship.z != z || !ship.is_ai_missile_ship())
			continue
		if(overmap_dist(ship, target) <= AI_DATALINK_RANGE && !ship.get_contact_suite(target))
			return TRUE
	return FALSE

/// Co tik AI myśliwca: zacząć, prowadzić albo skończyć zwiad
/obj/structure/overmap/proc/update_ai_scout()
	if(!fleet)
		return
	fleet.prune_ai_scouts()
	if(ai_scout_lead && !ai_scout_target)
		update_ai_scout_lead()
		return
	if(ai_scout_target)
		var/powod = get_ai_scout_end_reason()
		if(powod)
			stop_ai_scout(powod)
			return
		update_ai_scout_lock()
		return
	if(world.time < ai_scout_ready_at || ai_fleeing || LAZYLEN(fleet.ai_scouts) >= fleet.ai_scout_slots())
		return
	var/obj/structure/overmap/target = fleet.get_ai_scout_target(src)
	if(target && overmap_dist(src, target) >= AI_SCOUT_MIN_RANGE)
		start_ai_scout(target)
		return
	var/turf/lead = fleet.get_ai_scout_lead(src)
	if(lead && overmap_dist(src, lead) > AI_SCOUT_MIN_RANGE)
		start_ai_scout_lead(lead)

/// Zwiad wysunięty: leci do namiaru, a gdy jego sensory złapią dużego wroga, przechodzi w zwykły zwiad
/obj/structure/overmap/proc/update_ai_scout_lead()
	for(var/obj/structure/overmap/contact as anything in sensor_contact_suites)
		if(QDELETED(contact) || contact.mass <= MASS_TINY || !is_ai_hostile(contact))
			continue
		ai_scout_event("[src] na zwiadzie wysuniętym złapał [contact]")
		ai_scout_lead = null
		ai_scout_target = contact
		return
	if(world.time >= ai_scout_until)
		stop_ai_scout("koniec służby")
	else if(ai_fleeing)
		stop_ai_scout("ucieka")
	else if(overmap_dist(src, ai_scout_lead) <= AI_SCOUT_MIN_RANGE)
		stop_ai_scout("nic nie znalazł w miejscu namiaru")

/// Namierzanie radarem frontalnym tylko wtedy, gdy ktoś czeka z salwą; namierzanie to emisja, cel ją słyszy
/obj/structure/overmap/proc/update_ai_scout_lock()
	var/obj/structure/overmap/target = ai_scout_target
	var/trzyma = (target in target_painted)
	if(!has_ai_datalink_shooter(target))
		if(trzyma)
			dump_lock(target) // nikt nie strzela: nie świecimy po próżnicy
		return
	var/widzi = target.is_sensor_visible(src) >= SENSOR_VISIBILITY_TARGETABLE
	if(trzyma)
		if(!widzi || !ai_lock_geometry_ok(target))
			dump_lock(target)
			return
		target.hear_radar_emission(src)
		return
	if(widzi && ai_lock_geometry_ok(target) && world.time >= ai_scout_lock_started + lockon_time + 1 SECONDS)
		ai_scout_lock_started = world.time
		ai_scout_event("[src] namierza [target] dla okrętów rakietowych")
		start_lockon(target)
		target.hear_radar_emission(src)

/// Dokąd leci zwiadowca: krąży na granicy, z której widzi cel, a przy namierzaniu leci skosem z celem w stożku
/obj/structure/overmap/proc/get_ai_scout_point()
	var/obj/structure/overmap/target = ai_scout_target
	if(!target && ai_scout_lead)
		return ai_far_enough_point(ai_scout_lead)
	if(QDELETED(target))
		return null
	var/list/best = get_best_suite(target)
	var/promien = clamp(best[2] * 0.8, AI_SCOUT_MIN_RANGE + 2, AI_SCOUT_LOCK_RANGE)
	var/bearing = overmap_angle(src, target)
	if(isnull(bearing))
		return null
	var/namierza = has_ai_datalink_shooter(target)
	if(!namierza)
		var/turf/orbita = get_ai_standoff_point(target, promien)
		if(orbita)
			return orbita
	// Skos: cel w stożku radaru, ale bez lotu prosto na niego
	var/kurs = bearing + ai_scout_side * (overmap_dist(src, target) > promien ? AI_SCOUT_CRANK * 0.5 : AI_SCOUT_CRANK)
	return locate(clamp(round(x + sin(kurs) * 16), 1, world.maxx), clamp(round(y + cos(kurs) * 16), 1, world.maxy), z)

// ---------------------------------------------------------------- strzał przez łącze danych

/// Cel z łącza danych jako list(źródło, cel), albo null. Najpierw namierzanie zwiadowcy (dokładne), potem tor
/// radaru okrętu floty, który właśnie pulsuje: do celów, których ten okręt sam nie widzi, w zasięgu łącza.
/// contents podawane, żeby dało się testować bez systemu gwiezdnego.
/obj/structure/overmap/proc/get_ai_datalink_target(list/contents)
	for(var/obj/structure/overmap/scout as anything in fleet?.ai_scouts)
		var/obj/structure/overmap/target = scout?.ai_scout_target
		if(QDELETED(scout) || QDELETED(target) || !(target in scout.target_painted))
			continue
		if(target.z != z || overmap_dist(src, target) > AI_DATALINK_RANGE)
			continue
		return list(scout, target)
	var/list/radary = list()
	for(var/obj/structure/overmap/member as anything in fleet?.all_ships)
		if(!QDELETED(member) && member != src && member.z == z && world.time < member.last_radar_pulse + RADAR_VISIBILITY_PENALTY)
			radary += member
	if(!length(radary))
		return null
	var/obj/structure/overmap/best
	var/obj/structure/overmap/best_source
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/other as anything in contents)
		if(!istype(other) || QDELETED(other) || other.mass <= MASS_TINY || !is_ai_hostile(other) || get_contact_suite(other))
			continue
		var/dist = overmap_dist(src, other)
		if(dist > AI_DATALINK_RANGE || dist >= best_dist)
			continue
		for(var/obj/structure/overmap/radar as anything in radary)
			if(radar.ai_radar_sees(other))
				best = other
				best_source = radar
				best_dist = dist
				break
	return best ? list(best_source, best) : null

/// Czy pocisk ma teraz trzymać cel: dopóki źródło go trzyma (zwiadowca namierza albo jego radar pulsuje i sięga celu),
/// a bez tego tylko z bliska, własną głowicą
/proc/ai_datalink_keeps_homing(obj/structure/overmap/source, obj/structure/overmap/target, dist_to_target)
	if(QDELETED(target))
		return FALSE
	if(dist_to_target <= AI_SEEKER_RANGE)
		return TRUE
	if(QDELETED(source))
		return FALSE
	return (target in source.target_painted) || source.ai_radar_sees(target)

/obj/structure/overmap/proc/update_ai_datalink_fire()
	for(var/obj/item/projectile/shot as anything in ai_datalink_shots?.Copy())
		var/list/dane = ai_datalink_shots[shot]
		var/obj/structure/overmap/target = dane[2]
		if(QDELETED(shot) || QDELETED(target))
			LAZYREMOVE(ai_datalink_shots, shot)
			continue
		var/trzyma = ai_datalink_keeps_homing(dane[1], target, get_dist(shot, target))
		if(trzyma && !shot.homing)
			shot.set_homing_target(target) // głowica złapała cel albo źródło znów go trzyma
		else if(!trzyma && shot.homing)
			shot.homing_target = null // jak przy tarczy w damage.dm: dalej leci prosto w punkt przechwycenia
			shot.homing = FALSE
	if(mass <= MASS_TINY || ai_fleeing || is_ai_scouting())
		return
	var/list/namiar = get_ai_datalink_target(current_system?.system_contents)
	if(!namiar)
		return
	var/obj/structure/overmap/target = namiar[2]
	var/datum/overmap_ship_weapon/weapon = get_ai_guided_weapon(target)
	if(!weapon)
		return
	ai_datalink_firing = namiar[1]
	add_enemy(target)
	var/obj/structure/overmap/zrodlo = namiar[1]
	ai_scout_event("[src] strzela na [(target in zrodlo.target_painted) ? "namiar od" : "tor radaru od"] [zrodlo] ([overmap_dist(src, target)] pól) w [target]")
	fire_weapon(target, firing_weapon = weapon, ai_aim = TRUE)
	ai_datalink_firing = null

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	. = ..()
	if(ai_datalink_firing && istype(., /obj/item/projectile/guided_munition) && istype(target, /obj/structure/overmap))
		LAZYSET(ai_datalink_shots, ., list(ai_datalink_firing, target))

// ---------------------------------------------------------------- wpięcie

/obj/structure/overmap/update_ai_sensor_use()
	. = ..()
	if(!GLOB.ai_scouting_enabled || !ai_controlled || QDELETED(src))
		return
	if(mass <= MASS_TINY)
		update_ai_scout()
	update_ai_datalink_fire()

/obj/structure/overmap/move_toward(atom/target, ram_target = FALSE, ignore_all_collisions = FALSE)
	if(is_ai_scouting() && !ram_target && GLOB.ai_scouting_enabled)
		var/turf/punkt = get_ai_scout_point()
		if(punkt)
			return ..(punkt, FALSE, ignore_all_collisions)
	return ..()

/// Zwiadowca nie strzela: strzał to ciepło i błysk, a jego robotą jest widzieć, nie walczyć
/obj/structure/overmap/ai_fire(obj/structure/overmap/target)
	if(is_ai_scouting() && GLOB.ai_scouting_enabled)
		return
	return ..()

/obj/structure/overmap/ai_elite_fire(obj/structure/overmap/target)
	if(is_ai_scouting() && GLOB.ai_scouting_enabled)
		return
	return ..()

/obj/structure/overmap/get_ai_tactic()
	if(ai_scout_target && !ai_fleeing)
		return (ai_scout_target in target_painted) ? "naprowadza" : "zwiad"
	if(ai_scout_lead && !ai_fleeing)
		return "zwiad wysunięty"
	return ..()

/obj/structure/overmap/Destroy()
	if(fleet)
		LAZYREMOVE(fleet.ai_scouts, src)
	ai_scout_target = null
	ai_scout_lead = null
	ai_datalink_firing = null
	ai_datalink_shots = null
	return ..()

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_scouting

/client/proc/toggle_ai_scouting()
	set category = "Debug"
	set name = "Toggle AI scouting"
	set desc = "Włącza lub wyłącza zwiad myśliwców AI z namierzaniem radarem i strzał okrętów rakietowych na ich namiar."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_scouting_enabled = !GLOB.ai_scouting_enabled
	var/state = GLOB.ai_scouting_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] zwiad myśliwców i łącze danych u AI.")
	log_admin("[key_name(usr)] toggled AI scouting to [GLOB.ai_scouting_enabled].")

#undef AI_SCOUT_DUTY
#undef AI_SCOUT_COOLDOWN
#undef AI_SCOUT_LOCK_RANGE
#undef AI_SCOUT_LOCK_CONE
#undef AI_SCOUT_CRANK
#undef AI_SCOUT_MIN_RANGE
#undef AI_DATALINK_RANGE
#undef AI_SEEKER_RANGE
