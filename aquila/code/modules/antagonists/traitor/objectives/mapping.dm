// AQUILA - traitor objective "station mapping": anchor a mapping scanner in a picked room of a department
// and keep it there until the room scan is done. Pays a lot of aquilos once the scan finishes.

/// How long the scanner has to stay anchored in the room
#define MAPPING_SCAN_TIME (3 MINUTES)
/// Aquilos paid to every owner when the scan finishes
#define MAPPING_REWARD 1000
/// How often a scanning device pings, so the crew can find it
#define MAPPING_PING_INTERVAL (20 SECONDS)

/datum/objective/plant_device/mapping
	name = "mapowanie stacji"
	device_type = /obj/item/traitor_device/mapper
	/// Department name = room area types the target room is picked from
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
	/// Department the room belongs to
	var/department_name
	/// Ckeys that already got the reward
	var/list/paid_ckeys = list()

/datum/objective/plant_device/mapping/pick_target_areas()
	var/list/shuffled = shuffle(departments.Copy())
	for(var/name in shuffled)
		var/list/rooms = get_station_areas_of_types(departments[name])
		if(length(rooms))
			department_name = name
			target_areas = list(pick(rooms))
			return TRUE
	return FALSE

/datum/objective/plant_device/mapping/target_area_names()
	return "[..()] (dział: [department_name])"

/datum/objective/plant_device/mapping/update_explanation_text()
	explanation_text = "Wywiad Syndykatu potrzebuje dokładnych planów statku. Zamocuj skaner kartograficzny w pomieszczeniu [target_area_names()] \
		i nie pozwól go ruszyć, dopóki nie skończy skanu ([DisplayTimeText(MAPPING_SCAN_TIME)]). Skaner co jakiś czas cicho piszczy. \
		Nagroda: [MAPPING_REWARD] [CONFIG_GET(string/metacurrency_name)]."

/datum/objective/plant_device/mapping/check_completion()
	if(completed)
		pay_owners() // owners that were offline when the scan finished
	return completed

/// The planted scanner finished: the objective is done for good, even if the scanner is gone later
/datum/objective/plant_device/mapping/proc/scan_finished(obj/item/traitor_device/mapper/scanner)
	completed = TRUE
	for(var/datum/mind/owner_mind as anything in get_owners())
		to_chat(owner_mind.current, "<span class='greentext'>Skaner kartograficzny ukończył skan [target_area_names()]. Plany są już u Syndykatu.</span>")
	pay_owners()

/datum/objective/plant_device/mapping/proc/pay_owners()
	for(var/datum/mind/owner_mind as anything in get_owners())
		var/owner_ckey = ckey(owner_mind.key)
		if(!owner_ckey || (owner_ckey in paid_ckeys))
			continue
		var/client/owner_client = GLOB.directory[owner_ckey]
		if(!owner_client)
			continue
		paid_ckeys += owner_ckey
		owner_client.inc_metabalance(MAPPING_REWARD, reason = "Ukończono mapowanie stacji dla Syndykatu!")

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
	/// TRUE once the scan finished
	var/scan_done = FALSE

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
	if(!planted || scan_done)
		return
	scan_started = world.time
	next_ping = world.time + MAPPING_PING_INTERVAL
	icon_state = "motion3"
	START_PROCESSING(SSobj, src)

/obj/item/traitor_device/mapper/process(delta_time)
	if(!anchored || !objective?.is_target_area(get_area(src)))
		stop_scan()
		return
	if(world.time >= next_ping)
		next_ping = world.time + MAPPING_PING_INTERVAL
		playsound(src, 'sound/machines/ping.ogg', 10, FALSE, -4)
	if(world.time - scan_started < MAPPING_SCAN_TIME)
		return
	scan_done = TRUE
	STOP_PROCESSING(SSobj, src)
	var/datum/objective/plant_device/mapping/mapping = objective
	log_game("[src] finished scanning [AREACOORD(src)].")
	do_sparks(2, FALSE, src)
	visible_message("<span class='warning'>[src] krótko piszczy i rozpada się na kawałki!</span>")
	if(istype(mapping))
		mapping.scan_finished(src)
	qdel(src)

/// Taken off or moved out of the room: the scan starts over after planting again
/obj/item/traitor_device/mapper/proc/stop_scan()
	STOP_PROCESSING(SSobj, src)
	scan_started = 0
	icon_state = initial(icon_state)
	visible_message("<span class='warning'>Czujnik [src] przestaje się obracać.</span>")

#undef MAPPING_SCAN_TIME
#undef MAPPING_REWARD
#undef MAPPING_PING_INTERVAL
