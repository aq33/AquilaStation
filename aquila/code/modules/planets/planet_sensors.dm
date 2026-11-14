// AQUILA - planety w czujnikach. Planeta nie jest kontaktem (nie da się jej namierzyć ani oznaczyć, nie świeci na DRADIS-ie
// jak okręt), ale stanowisko rozpoznania pokazuje ją wśród obiektów i może ją zeskanować: skan odsłania typ,
// atmosferę i zagrożenia w opisie planety.

/// Z jakiej odległości (w polach overmapy) stanowisko rozpoznania skanuje planetę
#define PLANET_SCAN_RANGE 60

/obj/structure/overmap/planet/is_sensor_visible(obj/structure/overmap/observer)
	return SENSOR_VISIBILITY_GHOST

/obj/structure/overmap/get_scope_objects(display_range)
	. = ..()
	if(!current_system)
		return
	for(var/obj/structure/overmap/planet/planet in current_system.system_contents)
		if(QDELETED(planet) || planet.z != z)
			continue
		var/turf/center = planet.center_turf()
		var/dx = overmap_wrap_delta(center.x - x, world.maxx)
		var/dy = overmap_wrap_delta(center.y - y, world.maxy)
		var/detail
		if(!planet.planet_scanned)
			detail = "niezbadana"
		else if(!planet.planet_type.can_land)
			detail = "[planet.planet_type.name], bez lądowania"
		else
			detail = planet.planet_type.name
		. += list(list("id" = "\ref[planet]", "kind" = "planet", "name" = planet.name, "detail" = detail, "dx" = dx, "dy" = dy, "scannable" = !planet.planet_scanned))

/obj/machinery/computer/ship/dradis/sensors/ui_act(action, params)
	. = ..()
	if(. || action != "scan_planet")
		return
	var/obj/structure/overmap/planet/planet = locate(params["id"])
	if(!istype(planet) || !linked || planet.current_system != linked.current_system || planet.z != linked.z)
		return
	if(overmap_dist(linked, planet) > PLANET_SCAN_RANGE)
		say("Planeta jest za daleko na dokładny skan. Podlećcie bliżej.")
		return TRUE
	planet.set_scanned()
	say("Skan zakończony: [planet.planet_type.scan_text()]")
	playsound(src, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav', 50, TRUE)
	return TRUE

#undef PLANET_SCAN_RANGE
