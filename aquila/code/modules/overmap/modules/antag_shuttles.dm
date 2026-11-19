/// AQUILA - promy antagonistów na overmapie (plan walki na overmapie, etap „statki antagów”).
/// Gdy prom piratów, złomiarzy albo łowców jest w grze, przy okręcie gracza pojawia się jego okręt: widać go na DRADIS, da się
/// go namierzyć i ostrzelać, a trafienia przechodzą na pokład promu (wybuchy w jego obszarach). Okręt trzyma się w pobliżu
/// okrętu gracza i idzie za nim po skoku FTL; znika razem z promem.
/// Sprite'y z Aurora.3 (CC-BY-SA 3.0): tools/overmap_scale/import_aurora_ships.py -> aquila/icons/overmap/antag/.

#define ANTAG_SHUTTLE_FOLLOW_TICK (5 SECONDS)
#define ANTAG_SHUTTLE_MAX_DIST 30
#define ANTAG_SHUTTLE_RELAY_COOLDOWN (2 SECONDS)

/// id promu -> typ jego okrętu na overmapie
GLOBAL_LIST_INIT(antag_shuttle_overmaps, list(
	"pirateship" = /obj/structure/overmap/antag_shuttle/pirate,
	"salvagership" = /obj/structure/overmap/antag_shuttle/salvager,
	"huntership" = /obj/structure/overmap/antag_shuttle/hunter,
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

/// Trzyma się okrętu gracza: ten sam system, najwyżej ANTAG_SHUTTLE_MAX_DIST pól od niego
/obj/structure/overmap/antag_shuttle/proc/follow_main_ship()
	if(!get_port())
		qdel(src)
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

/// Trafienie w okręt promu: wybuch w losowym miejscu promu na mapie
/obj/structure/overmap/antag_shuttle/relay_damage(proj_type, original_proj_angle)
	if(world.time < next_relay)
		return
	next_relay = world.time + ANTAG_SHUTTLE_RELAY_COOLDOWN
	var/obj/docking_port/mobile/port = get_port()
	if(!port || !length(port.shuttle_areas))
		return
	var/list/turfs = list()
	for(var/area/A as anything in port.shuttle_areas)
		for(var/turf/open/T in A)
			turfs += T
	if(length(turfs))
		explosion(pick(turfs), 0, 0, 2, 3, adminlog = FALSE)

/obj/docking_port/mobile/register()
	. = ..()
	var/marker_type = GLOB.antag_shuttle_overmaps[id]
	if(marker_type)
		addtimer(CALLBACK(src, PROC_REF(spawn_antag_shuttle_overmap), marker_type), 1 SECONDS)

/// Tworzy okręt promu antagonisty przy okręcie gracza
/obj/docking_port/mobile/proc/spawn_antag_shuttle_overmap(marker_type)
	if(QDELETED(src))
		return
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		return
	var/obj/structure/overmap/antag_shuttle/marker = new marker_type(get_turf(main))
	marker.port_ref = WEAKREF(src)
	marker.place_near(main)
	if(!marker.current_system)
		main.current_system.add_ship(marker, get_turf(marker))

#undef ANTAG_SHUTTLE_FOLLOW_TICK
#undef ANTAG_SHUTTLE_MAX_DIST
#undef ANTAG_SHUTTLE_RELAY_COOLDOWN
