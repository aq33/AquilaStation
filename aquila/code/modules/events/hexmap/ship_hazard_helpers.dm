// AQUILA - wspólne procedury eventów z zagrożeniami dla statku z mapy hex (losowe miejsce na statku, załoga na pokładzie, burta kadłuba)

/// Losowy otwarty kafel (bez kosmosu) w losowym obszarze statku. Obszary z excluded_area_types (typecache) są pomijane.
/proc/aquila_hex_random_ship_turf(list/excluded_area_types)
	var/list/area_types = GLOB.the_station_areas.Copy()
	while(length(area_types))
		var/area_type = pick_n_take(area_types)
		if(excluded_area_types && excluded_area_types[area_type])
			continue
		var/list/turfs = list()
		for(var/turf/open/T as anything in get_area_turfs(area_type))
			if(!istype(T) || isspaceturf(T) || !is_station_level(T.z))
				continue
			turfs += T
		if(length(turfs))
			return pick(turfs)

/// Żywe moby graczy na poziomach statku
/proc/aquila_hex_ship_crew()
	. = list()
	for(var/mob/living/crew in GLOB.player_list)
		var/turf/T = get_turf(crew)
		if(T && is_station_level(T.z))
			. += crew

/**
 * Kafel kosmosu tuż przy burcie statku od strony direction: idzie od krawędzi mapy w stronę losowego miejsca na statku
 * i zatrzymuje się na ostatnim kaflu kosmosu przed kadłubem.
 */
/proc/aquila_hex_ship_hull_turf(direction)
	var/turf/anchor = aquila_hex_random_ship_turf()
	if(!anchor)
		return null
	var/turf/current
	switch(direction)
		if(NORTH)
			current = locate(anchor.x, world.maxy, anchor.z)
		if(SOUTH)
			current = locate(anchor.x, 1, anchor.z)
		if(EAST)
			current = locate(world.maxx, anchor.y, anchor.z)
		else
			current = locate(1, anchor.y, anchor.z)
	var/inward = turn(direction, 180)
	var/turf/last_space
	while(current && current != anchor)
		if(!isspaceturf(current))
			break
		last_space = current
		current = get_step(current, inward)
	return last_space || anchor
