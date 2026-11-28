/// AQUILA - piraci przylatują rajderem na overmapie (rozwój antagonistów, pirate.json).
/// Po odrzuceniu okupu do systemu okrętu wskakuje piracki rajder AI z flagą abordażu (jak piraci-abordażyści NSV):
/// leci do okrętu i strzela. Załoga może go zniszczyć albo uciec skokiem FTL (rajder zostaje w starym systemie i znika).
/// Gdy podleci na odległość abordażu, duchy dostają role piratów dopiero wtedy: prom piracki z eventu wczytuje się
/// z załogą i od razu przybija do wolnego portu przy okręcie (te same porty, do których lata konsola promu), a rajder
/// odskakuje. Piraci-gracze nie istnieją więc, dopóki rajder leci, i nie giną od salwy w niego. Po przybiciu prom ma
/// zwykły okręt na overmapie z antag_shuttles.dm. Bez okrętu gracza w systemie event działa po staremu.

#define PIRATE_RAIDER_CHECK_TICK (5 SECONDS)
#define PIRATE_RAIDER_SPAWN_DIST 25

/// Prom piracki właśnie się wczytuje z rajdera: spawn_pirates() ma go wczytać po staremu
GLOBAL_VAR_INIT(pirate_raider_docking, FALSE)

/// Porty przy okręcie, do których przybija prom z rajdera (kolejność prób)
GLOBAL_LIST_INIT(pirate_raider_docks, list(
	"syndicate_n", "syndicate_ne", "syndicate_nw", "syndicate_s", "syndicate_se", "syndicate_sw",
	"syndicatecutter_n", "syndicatecutter_ne", "syndicatecutter_nw", "syndicatecutter_s", "syndicatecutter_se", "syndicatecutter_sw",
))

/obj/structure/overmap/spacepirate/ai/boarding/raider
	name = "piracki rajder"
	desc = "Uzbrojony frachtowiec piratów z promem abordażowym w ładowni. Gdy podleci blisko, prom przybije do kadłuba."
	max_integrity = 900
	obj_integrity = 900
	/// Prom już wyleciał: rajder nie przybija drugi raz
	var/docked = FALSE
	/// Rajder zgubił okręt po skoku i odlatuje
	var/escaped = FALSE
	var/check_timer

/obj/structure/overmap/spacepirate/ai/boarding/raider/Initialize(mapload)
	. = ..()
	check_timer = addtimer(CALLBACK(src, PROC_REF(check_pursuit)), PIRATE_RAIDER_CHECK_TICK, TIMER_STOPPABLE | TIMER_LOOP)

/obj/structure/overmap/spacepirate/ai/boarding/raider/Destroy()
	deltimer(check_timer)
	check_timer = null
	if(!docked && !escaped && obj_integrity <= 0)
		priority_announce("Piracki rajder został zniszczony, zanim przybił do okrętu.", "Sensory okrętu")
	return ..()

/// Okręt gracza jest poza zasięgiem pościgu: w innym systemie, w skoku albo na innym poziomie
/obj/structure/overmap/spacepirate/ai/boarding/raider/proc/lost_track_of(obj/structure/overmap/main)
	return !main?.current_system || main.current_system != current_system || main.z != z

/obj/structure/overmap/spacepirate/ai/boarding/raider/proc/check_pursuit()
	if(docked || escaped)
		return
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(lost_track_of(main))
		escaped = TRUE
		priority_announce("Piracki rajder zgubił ślad okrętu po skoku FTL.", "Sensory okrętu")
		qdel(src)
		return
	if(QDELETED(last_target))
		add_enemy(main)

/obj/structure/overmap/spacepirate/ai/boarding/raider/try_board(obj/structure/overmap/ship)
	if(docked || escaped || ship?.role != MAIN_OVERMAP || overmap_dist(ship, src) > 8)
		return FALSE
	docked = TRUE
	INVOKE_ASYNC(src, PROC_REF(launch_boarding_shuttle))
	return TRUE

/// Wczytuje prom piratów z załogą z duchów, przybija go do okrętu i odskakuje
/obj/structure/overmap/spacepirate/ai/boarding/raider/proc/launch_boarding_shuttle()
	priority_announce("Piracki rajder wypuścił prom abordażowy! Przygotujcie się na abordaż.", "Sensory okrętu")
	GLOB.pirate_raider_docking = TRUE
	try
		spawn_pirates(null, TRUE)
	catch(var/exception/load_error)
		stack_trace("Pirate raider could not load the pirate shuttle: [load_error]")
	GLOB.pirate_raider_docking = FALSE
	if(!aquila_dock_pirate_shuttle())
		message_admins("Prom piracki z rajdera nie znalazł wolnego portu przy okręcie i został w swojej bazie.")
	if(QDELETED(src))
		return
	current_system?.remove_ship(src, null, TRUE)
	qdel(src)

/// Rajder zamiast promu w pustej przestrzeni; FALSE, gdy event ma wczytać prom po staremu
/proc/aquila_send_pirate_raider()
	if(GLOB.pirate_raider_docking)
		return FALSE
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		return FALSE
	var/angle = rand(0, 359)
	var/turf/spot = locate(clamp(round(main.x + PIRATE_RAIDER_SPAWN_DIST * cos(angle)), 20, world.maxx - 20), clamp(round(main.y + PIRATE_RAIDER_SPAWN_DIST * sin(angle)), 20, world.maxy - 20), main.z)
	if(!spot)
		return FALSE
	var/obj/structure/overmap/spacepirate/ai/boarding/raider/raider = new(spot)
	main.current_system.add_ship(raider, spot)
	raider.add_enemy(main)
	priority_announce("Do systemu wskoczył piracki rajder. Zniszczcie go albo wykonajcie skok FTL, zanim podleci i przybije prom abordażowy do kadłuba.", "Sensory okrętu", 'aquila/sound/ai/events/pirates_armed_vessel.ogg')
	message_admins("Piraci przylatują rajderem na overmapie: [ADMIN_VERBOSEJMP(raider)].")
	return TRUE

/// Przybija prom piratów do pierwszego wolnego portu przy okręcie; bez wolnego portu prom zostaje w swojej bazie
/proc/aquila_dock_pirate_shuttle()
	var/obj/docking_port/mobile/port = SSshuttle.getShuttle("pirateship")
	if(!port)
		return FALSE
	for(var/dock_id in GLOB.pirate_raider_docks)
		var/obj/docking_port/stationary/dock = SSshuttle.getDock(dock_id)
		if(!dock || port.canDock(dock) != SHUTTLE_CAN_DOCK)
			continue
		if(port.initiate_docking(dock) == DOCKING_SUCCESS)
			return TRUE
	return FALSE

#undef PIRATE_RAIDER_CHECK_TICK
#undef PIRATE_RAIDER_SPAWN_DIST
