/// AQUILA - promy antagonistów na overmapie (plan walki na overmapie, etap „statki antagów”).
/// Gdy prom piratów, złomiarzy albo łowców jest w grze, przy okręcie gracza pojawia się jego okręt: widać go na DRADIS, da się
/// go namierzyć i ostrzelać, a trafienia przechodzą na pokład promu (wybuchy w jego obszarach). Okręt trzyma się w pobliżu
/// okrętu gracza i idzie za nim po skoku FTL; znika razem z promem.
/// Infiltrator Syndykatu (prom nuke ops) pojawia się dopiero, gdy wyleci z bazy, i wraca do ukrycia, gdy do niej zadokuje.
/// Porywacze mają zamaskowany spodek, dopóki żyje ktoś z drużyny (trafienia wybuchają na ich statku-matce), a drużyna ERT
/// przylatuje dużym promem Nanotrasen, który odlatuje po ERT_OVERMAP_STAY.
/// Sprite'y z Aurora.3 (CC-BY-SA 3.0): tools/overmap_scale/import_aurora_ships.py -> aquila/icons/overmap/antag/.
/// Spodek z niescalonego PR-a BeeStation/NSV13#2770 (autor Pockets-byte): sprite i parametry okrętu, bez mapy wnętrza i bez
/// działa jonowego (spodka nikt nie pilotuje, porywacze mają własny statek).

#define ANTAG_SHUTTLE_FOLLOW_TICK (5 SECONDS)
#define ANTAG_SHUTTLE_MAX_DIST 30
#define ANTAG_SHUTTLE_RELAY_COOLDOWN (2 SECONDS)
#define ANTAG_SHUTTLE_SPAWN_RETRY (30 SECONDS)
#define ERT_OVERMAP_STAY (15 MINUTES)

/// id promu -> typ jego okrętu na overmapie
GLOBAL_LIST_INIT(antag_shuttle_overmaps, list(
	"pirateship" = /obj/structure/overmap/antag_shuttle/pirate,
	"salvagership" = /obj/structure/overmap/antag_shuttle/salvager,
	"huntership" = /obj/structure/overmap/antag_shuttle/hunter,
	"syndicate" = /obj/structure/overmap/antag_shuttle/infiltrator,
))

/obj/structure/overmap/antag_shuttle
	name = "prom"
	desc = "Mały prom, który trzyma się blisko okrętu."
	icon = 'aquila/icons/overmap/antag/pirate_raider.dmi'
	icon_state = "pirate_raider"
	faction = "pirate"
	mass = MASS_SMALL
	max_integrity = 400
	obj_integrity = 400
	bound_width = 64
	bound_height = 64
	ai_controlled = FALSE
	/// Prom na mapie, którego okrętem jest ten obiekt
	var/datum/weakref/port_ref
	var/next_relay = 0
	var/follow_timer
	/// Dok, w którym prom stoi w swojej bazie: wtedy okrętu nie ma na overmapie
	var/home_dock_id

/obj/structure/overmap/antag_shuttle/pirate
	name = "prom piracki"
	desc = "Przerobiona korweta piratów. Ostrzał trafia w ich prom."

/obj/structure/overmap/antag_shuttle/salvager
	name = "statek złomiarzy"
	desc = "Poskładany ze złomu statek, który trzyma się śladu FTL okrętu."
	icon = 'aquila/icons/overmap/antag/salvager_ship.dmi'
	icon_state = "salvager_ship"
	faction = "salvager"

/obj/structure/overmap/antag_shuttle/hunter
	name = "statek łowców nagród"
	desc = "Długi okręt pościgowy łowców nagród."
	icon = 'aquila/icons/overmap/antag/hunter_ship.dmi'
	icon_state = "hunter_ship"
	faction = "hunter"
	bound_width = 96
	bound_height = 96
	/// Sprite z Aurory jest większy od Padalca; prom łowców ma być mniejszy
	overmap_display_proportion = 0.6

/obj/structure/overmap/antag_shuttle/infiltrator
	name = "infiltrator Syndykatu"
	desc = "Szybki statek desantowy Syndykatu. Ostrzał trafia w ich prom."
	icon = 'aquila/icons/overmap/ships/syndie-dropship.dmi'
	icon_state = "tkaczka"
	faction = "syndicate"
	overmap_native_sprite = TRUE
	home_dock_id = "syndicate_away"

/// Spodek porywaczy: mocno zamaskowany, prawie niewidoczny dla sensorów
/obj/structure/overmap/antag_shuttle/abductor
	name = "!*!*! Xenophorica"
	desc = "Brak informacji: zaktualizuj NTOS."
	icon = 'aquila/icons/overmap/antag/saucer.dmi'
	icon_state = "saucer"
	faction = "abductor"
	mass = MASS_MEDIUM
	max_integrity = 600
	obj_integrity = 600
	armor = list("overmap_light" = 70, "overmap_medium" = 60, "overmap_heavy" = 60)
	use_armour_quadrants = FALSE
	cloak_factor = 30
	sensor_profile = 0
	overmap_native_sprite = TRUE
	var/datum/weakref/team_ref

/obj/structure/overmap/antag_shuttle/abductor/Initialize(mapload)
	. = ..()
	handle_cloak(TRUE)

/obj/structure/overmap/antag_shuttle/abductor/still_needed()
	var/datum/team/abductor_team/team = team_ref?.resolve()
	if(!team)
		return FALSE
	for(var/datum/mind/member as anything in team.members)
		if(member.current && member.current.stat != DEAD)
			return TRUE
	return FALSE

/obj/structure/overmap/antag_shuttle/abductor/relay_targets()
	var/list/turfs = list()
	for(var/area/abductor_ship/A in GLOB.sortedAreas)
		for(var/turf/open/T in A)
			turfs += T
	return turfs

/// Duży prom Nanotrasen z drużyną ERT: zostaje przy okręcie przez ERT_OVERMAP_STAY i odlatuje
/obj/structure/overmap/antag_shuttle/ert
	name = "prom szybkiego reagowania Nanotrasen"
	desc = "Uniwersalny statek desantowy, którym Centrala przysyła drużynę szybkiego reagowania."
	icon = 'aquila/icons/overmap/ships/nanotrasen-dropship.dmi'
	icon_state = "mewa"
	faction = "nanotrasen"
	overmap_native_sprite = TRUE
	var/leave_time = 0

/obj/structure/overmap/antag_shuttle/ert/Initialize(mapload)
	. = ..()
	leave_time = world.time + ERT_OVERMAP_STAY

/obj/structure/overmap/antag_shuttle/ert/still_needed()
	return world.time < leave_time

/obj/structure/overmap/antag_shuttle/ert/relay_targets()
	return list()

/obj/structure/overmap/antag_shuttle/Initialize(mapload)
	. = ..()
	follow_timer = addtimer(CALLBACK(src, PROC_REF(follow_main_ship)), ANTAG_SHUTTLE_FOLLOW_TICK, TIMER_STOPPABLE | TIMER_LOOP)

/obj/structure/overmap/antag_shuttle/Destroy()
	deltimer(follow_timer)
	follow_timer = null
	return ..()

/obj/structure/overmap/antag_shuttle/proc/get_port()
	var/obj/docking_port/mobile/port = port_ref?.resolve()
	return QDELETED(port) ? null : port

/// Czy okręt ma dalej istnieć (prom, drużyna albo czas pobytu)
/obj/structure/overmap/antag_shuttle/proc/still_needed()
	return get_port()

/// Prom stoi w swojej bazie: okrętu nie ma na overmapie
/obj/structure/overmap/antag_shuttle/proc/at_home()
	if(!home_dock_id)
		return FALSE
	var/obj/docking_port/mobile/port = get_port()
	return port && port.mode == SHUTTLE_IDLE && port.getDockedId() == home_dock_id

/// Trzyma się okrętu gracza: ten sam system, najwyżej ANTAG_SHUTTLE_MAX_DIST pól od niego
/obj/structure/overmap/antag_shuttle/proc/follow_main_ship()
	if(!still_needed())
		if(current_system)
			current_system.remove_ship(src, null, TRUE) // odlot ze skokiem FTL
		qdel(src)
		return
	if(at_home())
		if(current_system)
			current_system.remove_ship(src, null, TRUE)
			current_system = null
		return
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		return
	if(current_system != main.current_system || z != main.z || overmap_dist(src, main) > ANTAG_SHUTTLE_MAX_DIST)
		place_near(main)

/obj/structure/overmap/antag_shuttle/proc/place_near(obj/structure/overmap/main)
	var/turf/spot = locate(clamp(main.x + rand(-20, 20), 20, world.maxx - 20), clamp(main.y + rand(-20, 20), 20, world.maxy - 20), main.z)
	if(!spot)
		return
	if(current_system != main.current_system)
		current_system?.remove_ship(src)
		main.current_system.add_ship(src, spot)
	forceMove(spot)
	if(cloak_factor < 255)
		handle_cloak(TRUE)

/// Trafienie w okręt promu: wybuch w losowym miejscu promu na mapie
/obj/structure/overmap/antag_shuttle/relay_damage(proj_type, original_proj_angle)
	if(world.time < next_relay)
		return
	next_relay = world.time + ANTAG_SHUTTLE_RELAY_COOLDOWN
	var/list/turfs = relay_targets()
	if(length(turfs))
		explosion(pick(turfs), 0, 0, 2, 3, adminlog = FALSE)

/// Pola, na których wybuchają trafienia w ten okręt
/obj/structure/overmap/antag_shuttle/proc/relay_targets()
	var/obj/docking_port/mobile/port = get_port()
	var/list/turfs = list()
	for(var/area/A as anything in port?.shuttle_areas)
		for(var/turf/open/T in A)
			turfs += T
	return turfs

/obj/docking_port/mobile/register()
	. = ..()
	var/marker_type = GLOB.antag_shuttle_overmaps[id]
	if(marker_type)
		addtimer(CALLBACK(src, PROC_REF(spawn_antag_shuttle_overmap), marker_type), 1 SECONDS)

/// Tworzy okręt promu antagonisty przy okręcie gracza
/obj/docking_port/mobile/proc/spawn_antag_shuttle_overmap(marker_type)
	if(QDELETED(src))
		return
	var/obj/structure/overmap/antag_shuttle/marker = spawn_antag_overmap(marker_type)
	if(marker)
		marker.port_ref = WEAKREF(src)
		marker.follow_main_ship()
	else
		addtimer(CALLBACK(src, PROC_REF(spawn_antag_shuttle_overmap), marker_type), ANTAG_SHUTTLE_SPAWN_RETRY)

/// Okręt antagonisty przy okręcie gracza; null, gdy okrętu gracza jeszcze nie ma na overmapie
/proc/spawn_antag_overmap(marker_type)
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		return null
	var/obj/structure/overmap/antag_shuttle/marker = new marker_type(get_turf(main))
	marker.place_near(main)
	if(!marker.current_system)
		main.current_system.add_ship(marker, get_turf(marker))
	return marker

/datum/team/abductor_team/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spawn_saucer)), 1 SECONDS)

/// Zamaskowany spodek drużyny przy okręcie gracza
/datum/team/abductor_team/proc/spawn_saucer()
	if(QDELETED(src))
		return
	var/obj/structure/overmap/antag_shuttle/abductor/saucer = spawn_antag_overmap(/obj/structure/overmap/antag_shuttle/abductor)
	if(saucer)
		saucer.team_ref = WEAKREF(src)
	else
		addtimer(CALLBACK(src, PROC_REF(spawn_saucer)), ANTAG_SHUTTLE_SPAWN_RETRY)

/datum/admins/makeEmergencyresponseteam(datum/ert/ertemplate = null)
	. = ..()
	if(.)
		spawn_antag_overmap(/obj/structure/overmap/antag_shuttle/ert)

#undef ANTAG_SHUTTLE_FOLLOW_TICK
#undef ANTAG_SHUTTLE_MAX_DIST
#undef ANTAG_SHUTTLE_RELAY_COOLDOWN
#undef ANTAG_SHUTTLE_SPAWN_RETRY
#undef ERT_OVERMAP_STAY
