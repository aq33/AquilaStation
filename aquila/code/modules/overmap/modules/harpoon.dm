/// AQUILA - harpun abordażowy (plan walki na overmapie, etap „abordaż”). Mają go okręty gracza i wrogie fregaty
/// abordażowe. Harpun trafia cel z bliska (bliżej niż zakłócacz EWAR, który działa do 20 pól), także przez tarcze, i łączy okręty liną: lina ciągnie je do siebie jak sprężyna, a żaden
/// z nich nie skoczy FTL (silna interdykcja). Wciągarka skraca linę; z bliska wnętrze celu się wczytuje i przy harpunie
/// na pokładzie gracza pojawia się rękaw abordażowy do celu, a fregata AI wysadza abordażystów na okręcie gracza.
/// Linę da się odciąć z konsoli taktycznej, wróg próbuje ją przestrzelić, a zbyt mocno napięta pęka.

#define HARPOON_RANGE 8
#define HARPOON_BOARD_RANGE 3
#define HARPOON_REEL_RATE 0.5
#define HARPOON_SPRING 0.04
#define HARPOON_ROPE_HP 100
#define HARPOON_COOLDOWN (30 SECONDS)
#define HARPOON_FLIGHT_TIME (1 SECONDS)

/obj/structure/overmap
	/// AQUILA - okręt ma wyrzutnię harpuna
	var/has_harpoon = FALSE
	var/next_harpoon = 0
	/// AQUILA - lina wystrzelona z tego okrętu
	var/datum/overmap_tether/harpoon_tether
	/// AQUILA - lina, którą ten okręt jest trzymany
	var/datum/overmap_tether/tethered_by

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	if(role == MAIN_OVERMAP)
		has_harpoon = TRUE

/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate
	has_harpoon = TRUE

/obj/structure/overmap/Destroy()
	QDEL_NULL(harpoon_tether)
	QDEL_NULL(tethered_by)
	return ..()

/// Tarcze celu są podniesione (generator na okręcie gracza albo komponent okrętu AI); harpun ich nie sprawdza, kapsuła abordażowa tak
/obj/structure/overmap/proc/harpoon_shields_up()
	if(istype(shields, /datum/component/overmap_shields))
		var/datum/component/overmap_shields/component = shields
		return component.active && component.shield["integrity"] > 0
	if(istype(shields, /obj/machinery/shield_generator))
		var/obj/machinery/shield_generator/generator = shields
		return generator.active && generator.shield["integrity"] > 0
	return FALSE

/// Powód, dla którego harpun nie może strzelić, albo null
/obj/structure/overmap/proc/harpoon_blocked(obj/structure/overmap/target)
	if(!has_harpoon)
		return "Okręt nie ma wyrzutni harpuna."
	if(harpoon_tether)
		return "Harpun już trzyma cel."
	if(world.time < next_harpoon)
		return "Wyrzutnia harpuna się przeładowuje."
	if(!istype(target) || QDELETED(target) || target == src || target.z != z || target.faction == faction)
		return "Nieprawidłowy cel."
	if(overmap_dist(src, target) > HARPOON_RANGE)
		return "Cel za daleko na harpun (do [HARPOON_RANGE] pól)."
	return null

/obj/structure/overmap/proc/fire_harpoon(obj/structure/overmap/target)
	if(harpoon_blocked(target))
		return FALSE
	next_harpoon = world.time + HARPOON_COOLDOWN
	relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='notice'>Harpun wystrzelony.</span>")
	addtimer(CALLBACK(src, PROC_REF(attach_harpoon), target), HARPOON_FLIGHT_TIME)
	return TRUE

/obj/structure/overmap/proc/attach_harpoon(obj/structure/overmap/target)
	if(QDELETED(src) || QDELETED(target) || harpoon_tether || target.tethered_by || overmap_dist(src, target) > HARPOON_RANGE + 2)
		relay(null, "<span class='warning'>Harpun chybił.</span>")
		return
	harpoon_tether = new /datum/overmap_tether(src, target)
	target.relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='userdanger'>Okręt trafiony harpunem! Lina nie pozwala skoczyć FTL.</span>")

/datum/overmap_tether
	var/obj/structure/overmap/source
	var/obj/structure/overmap/target
	/// Długość liny (pola overmapy)
	var/length
	var/rope_hp = HARPOON_ROPE_HP
	var/reeling = FALSE
	var/boarded = FALSE
	var/datum/beam/beam
	var/list/sleeves = list()

/datum/overmap_tether/New(obj/structure/overmap/source, obj/structure/overmap/target)
	src.source = source
	src.target = target
	target.tethered_by = src
	length = max(HARPOON_BOARD_RANGE, overmap_dist(source, target))
	reeling = source.ai_controlled
	beam = source.Beam(target, icon_state = "chain", time = INFINITY, maxdistance = HARPOON_RANGE * 4)
	RegisterSignal(SSdcs, COMSIG_GLOB_CHECK_INTERDICT, PROC_REF(check_interdict))
	START_PROCESSING(SSprocessing, src)

/datum/overmap_tether/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_CHECK_INTERDICT)
	QDEL_NULL(beam)
	QDEL_LIST(sleeves)
	if(source?.harpoon_tether == src)
		source.harpoon_tether = null
	if(target?.tethered_by == src)
		target.tethered_by = null
	source = null
	target = null
	return ..()

/// Okręty na linie nie skoczą FTL
/datum/overmap_tether/proc/check_interdict(datum/signal_source, obj/structure/overmap/interdicted)
	SIGNAL_HANDLER
	if(interdicted == source || interdicted == target)
		return STRONG_INTERDICT

/datum/overmap_tether/proc/snap(message = "Lina harpuna pękła.")
	source?.relay(null, "<span class='warning'>[message]</span>")
	target?.relay(null, "<span class='notice'>[message]</span>")
	qdel(src)

/datum/overmap_tether/proc/damage_rope(amount)
	rope_hp -= amount
	if(rope_hp <= 0)
		snap()

/datum/overmap_tether/process(delta_time)
	if(QDELETED(source) || QDELETED(target) || source.z != target.z)
		qdel(src)
		return PROCESS_KILL
	var/dist = overmap_dist(source, target)
	if(dist > length * 2 + 6)
		snap("Lina harpuna pękła z napięcia.")
		return PROCESS_KILL
	if(reeling && length > HARPOON_BOARD_RANGE)
		length = max(HARPOON_BOARD_RANGE, length - HARPOON_REEL_RATE * delta_time)
	if(dist > length)
		pull(dist)
	if(!boarded && dist <= HARPOON_BOARD_RANGE + 1)
		start_boarding()
	// wróg przestrzeliwuje linę
	if(target.ai_controlled && prob(4))
		damage_rope(25)

/// Sprężyna: ciągnie oba okręty ku sobie, lżejszy dostaje więcej
/datum/overmap_tether/proc/pull(dist)
	// najkrótsza droga, także przez zawinięcie krawędzi overmapy (jak namiary w decoys.dm)
	var/dx = overmap_wrap_delta(source.x - target.x, world.maxx)
	var/dy = overmap_wrap_delta(source.y - target.y, world.maxy)
	var/norm = sqrt(dx * dx + dy * dy)
	if(!norm)
		return
	dx /= norm
	dy /= norm
	var/impulse = (dist - length) * HARPOON_SPRING
	var/total = max(1, source.mass + target.mass)
	target.velocity.a += dx * impulse * source.mass / total
	target.velocity.e += dy * impulse * source.mass / total
	source.velocity.a -= dx * impulse * target.mass / total
	source.velocity.e -= dy * impulse * target.mass / total

/// Z bliska: gracz dostaje rękaw do wnętrza celu, fregata AI wysadza abordażystów na okręcie gracza
/datum/overmap_tether/proc/start_boarding()
	boarded = TRUE
	if(source.ai_controlled)
		if(length(target.occupying_levels))
			target.spawn_boarders(null, source.faction)
		return
	if(!target.ai_load_interior(source))
		source.relay(null, "<span class='warning'>Nie da się wejść do celu: brak dostępnego wnętrza.</span>")
		return
	target.ai_controlled = FALSE
	open_sleeve()

/// Rękaw: wejście przy harpunie na pokładzie gracza, wyjście na pokładzie celu
/datum/overmap_tether/proc/open_sleeve()
	var/obj/machinery/boarding_harpoon/launcher
	for(var/obj/machinery/boarding_harpoon/harpoon in GLOB.machines)
		if(harpoon.get_overmap() == source)
			launcher = harpoon
			break
	var/turf/entry = launcher ? get_step(launcher, launcher.dir) : null
	var/turf/exit = harpoon_exit_turf()
	if(!entry || !exit)
		source.relay(null, "<span class='warning'>Lina trzyma cel, ale okręt nie ma harpuna na pokładzie, przez który dałoby się przejść.</span>")
		return
	var/obj/structure/harpoon_sleeve/here = new(entry)
	var/obj/structure/harpoon_sleeve/there = new(exit)
	here.other_end = there
	there.other_end = here
	sleeves += here
	sleeves += there
	source.relay(null, "<span class='notice'>Rękaw abordażowy otwarty przy harpunie.</span>")

/// Pole wyjścia na pokładzie celu: otwarta podłoga w jego wnętrzu
/datum/overmap_tether/proc/harpoon_exit_turf()
	for(var/area/A as anything in target.linked_areas)
		var/list/floors = list()
		for(var/turf/open/floor/F in A)
			if(!is_blocked_turf(F, TRUE))
				floors += F
		if(length(floors))
			return pick(floors)
	return null

/obj/structure/harpoon_sleeve
	name = "rękaw abordażowy"
	desc = "Elastyczny tunel wzdłuż liny harpuna. Przejście na drugi okręt zajmuje chwilę."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = TRUE
	density = FALSE
	var/obj/structure/harpoon_sleeve/other_end

/obj/structure/harpoon_sleeve/Destroy()
	if(other_end?.other_end == src)
		other_end.other_end = null
	other_end = null
	return ..()

/obj/structure/harpoon_sleeve/attack_hand(mob/living/user)
	. = ..()
	if(. || !other_end)
		return
	to_chat(user, "<span class='notice'>Przeciskasz się przez rękaw abordażowy...</span>")
	if(!do_after(user, 3 SECONDS, target = src) || QDELETED(other_end))
		return
	user.forceMove(get_turf(other_end))

// Fregata abordażowa AI strzela harpunem w bliski cel
/obj/structure/overmap/ai_process()
	. = ..()
	if(!has_harpoon || !ai_controlled || harpoon_tether || !istype(last_target, /obj/structure/overmap) || !prob(20))
		return
	if(!harpoon_blocked(last_target))
		fire_harpoon(last_target)

/obj/machinery/boarding_harpoon
	desc = "Wyrzutnia harpuna abordażowego. Strzela się z konsoli taktycznej, a gdy lina przyciągnie cel, obok otwiera się rękaw abordażowy."
	anchored = TRUE
	density = TRUE

#undef HARPOON_RANGE
#undef HARPOON_BOARD_RANGE
#undef HARPOON_REEL_RATE
#undef HARPOON_SPRING
#undef HARPOON_ROPE_HP
#undef HARPOON_COOLDOWN
#undef HARPOON_FLIGHT_TIME
