// AQUILA - traitor objective "station mapping": scan 1 to 3 rooms of one department with a mapping scanner.
// The scanner is anchored in a room and has to stay there until the scan is done, then it comes loose for the next room.

/// How long the scanner has to stay anchored in a room
#define MAPPING_SCAN_TIME (3 MINUTES)
/// How often a scanning device pings, so the crew can find it
#define MAPPING_PING_INTERVAL (20 SECONDS)

/datum/objective/plant_device/mapping
	name = "mapowanie stacji"
	device_type = /obj/item/traitor_device/mapper
	/// Department name = room area types the target rooms are picked from
	var/static/list/departments = list(
		"dowodzenie" = list(/area/bridge, /area/crew_quarters/heads/captain, /area/crew_quarters/heads/xo, /area/crew_quarters/heads/hop),
		"medyczny" = list(/area/medical/medbay, /area/medical/surgery, /area/medical/chemistry, /area/crew_quarters/heads/cmo),
		"naukowy" = list(/area/science/lab, /area/science/server, /area/science/robotics, /area/science/xenobiology, /area/crew_quarters/heads/hor),
		"inżynieria" = list(/area/engine/engineering, /area/engine/atmos, /area/nsv/engine/engine_room, /area/crew_quarters/heads/chief),
		"ochrona" = list(/area/security/brig, /area/security/main, /area/ai_monitored/security/armory, /area/crew_quarters/heads/hos, /area/nsv/crew_quarters/heads/maa),
		"amunicja" = list(/area/nsv/weapons, /area/nsv/magazine),
		"zaopatrzenie" = list(/area/quartermaster/storage, /area/quartermaster/office, /area/quartermaster/qm),
		"telekomunikacja" = list(/area/tcommsat/server, /area/tcommsat/computer),
	)
	/// Department the rooms belong to
	var/department_name
	/// Rooms that are already scanned
	var/list/area/scanned_areas = list()

/datum/objective/plant_device/mapping/pick_target_areas()
	target_area_count = rand(1, 3)
	var/list/shuffled = shuffle(departments.Copy())
	for(var/name in shuffled)
		var/list/rooms = get_station_areas_of_types(departments[name])
		if(!length(rooms))
			continue
		department_name = name
		target_areas = list()
		while(length(rooms) && length(target_areas) < target_area_count)
			target_areas += pick_n_take(rooms)
		return TRUE
	return FALSE

/// Only rooms that still need a scan count
/datum/objective/plant_device/mapping/is_target_area(area/A)
	return (A in target_areas) && !(A in scanned_areas)

/datum/objective/plant_device/mapping/target_area_names()
	var/list/names = list()
	for(var/area/A as anything in target_areas)
		names += (A in scanned_areas) ? "<s>[A.name]</s>" : A.name
	return "[english_list(names)] (dział: [department_name])"

/datum/objective/plant_device/mapping/update_explanation_text()
	var/rooms = length(target_areas)
	explanation_text = "Wywiad Syndykatu potrzebuje dokładnych planów statku. Zeskanuj skanerem kartograficznym [rooms == 1 ? "pomieszczenie" : "pomieszczenia"] \
		[target_area_names()]. Skaner trzeba zamocować w pomieszczeniu i nie pozwolić go ruszyć, dopóki nie skończy skanu ([DisplayTimeText(MAPPING_SCAN_TIME)]); \
		[rooms > 1 ? "potem sam się odczepi i możesz go przenieść do następnego. " : ""]Skaner co jakiś czas cicho piszczy."

/datum/objective/plant_device/mapping/check_completion()
	return completed

/// A room got scanned. The objective is done for good once every room is, even if the scanner is gone later.
/datum/objective/plant_device/mapping/proc/room_scanned(area/scanned)
	scanned_areas |= scanned
	planted = FALSE
	update_explanation_text()
	var/left = length(target_areas - scanned_areas)
	if(!left)
		completed = TRUE
	for(var/datum/mind/owner_mind as anything in get_owners())
		if(left)
			to_chat(owner_mind.current, "<span class='notice'>Skaner kartograficzny ukończył skan: [scanned.name]. Zostało pomieszczeń: [left].</span>")
		else
			to_chat(owner_mind.current, "<span class='greentext'>Skaner kartograficzny ukończył ostatni skan. Plany są już u Syndykatu.</span>")
	return !left

/// Mapping scanner: planted like the other devices, then scans the room as long as it stays anchored there
/obj/item/traitor_device/mapper
	name = "skaner kartograficzny"
	desc = "Płaskie urządzenie z obracającym się czujnikiem. Na spodzie ma przyssawki i zatrzaski do mocowania."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion0"
	w_class = WEIGHT_CLASS_SMALL
	plant_time = 8 SECONDS
	/// world.time the current scan started at, 0 when not scanning
	var/scan_started = 0
	/// world.time of the next ping
	var/next_ping = 0

/obj/item/traitor_device/mapper/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/traitor_device/mapper/examine(mob/user)
	. = ..()
	if(scan_started && objective && user.mind && (user.mind in objective.get_owners()))
		var/progress = round(100 * (world.time - scan_started) / MAPPING_SCAN_TIME)
		. += "<span class='notice'>Skan: [clamp(progress, 0, 100)]%.</span>"

/obj/item/traitor_device/mapper/plant(mob/user)
	..()
	if(!planted)
		return
	scan_started = world.time
	next_ping = world.time + MAPPING_PING_INTERVAL
	icon_state = "motion3"
	START_PROCESSING(SSobj, src)

/obj/item/traitor_device/mapper/process(delta_time)
	var/area/here = get_area(src)
	if(!anchored || !objective?.is_target_area(here))
		stop_scan()
		visible_message("<span class='warning'>Czujnik [src] przestaje się obracać.</span>")
		return
	if(world.time >= next_ping)
		next_ping = world.time + MAPPING_PING_INTERVAL
		playsound(src, 'sound/machines/ping.ogg', 10, FALSE, -4)
	if(world.time - scan_started < MAPPING_SCAN_TIME)
		return
	stop_scan()
	log_game("[src] finished scanning [AREACOORD(src)].")
	var/datum/objective/plant_device/mapping/mapping = objective
	if(!istype(mapping) || mapping.room_scanned(here))
		do_sparks(2, FALSE, src)
		visible_message("<span class='warning'>[src] krótko piszczy i rozpada się na kawałki!</span>")
		qdel(src)
		return
	// more rooms to go: come loose so the traitor can carry it on
	planted = FALSE
	anchored = FALSE
	alpha = initial(alpha)
	layer = initial(layer)
	visible_message("<span class='notice'>[src] piszczy dwa razy i odczepia zatrzaski.</span>")

/// Taken off, moved out of the room or done: the next scan starts from zero
/obj/item/traitor_device/mapper/proc/stop_scan()
	STOP_PROCESSING(SSobj, src)
	scan_started = 0
	icon_state = initial(icon_state)

#undef MAPPING_SCAN_TIME
#undef MAPPING_PING_INTERVAL
