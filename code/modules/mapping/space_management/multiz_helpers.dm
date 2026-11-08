/proc/get_step_multiz(ref, dir)
	// AQ EDIT START - makra zamiast procek SSmapping (tgstation/tgstation#76248)
	var/turf/ref_turf
	if(dir & UP)
		dir &= ~UP
		ref_turf = get_turf(ref)
		return get_step(GET_TURF_ABOVE(ref_turf), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		ref_turf = get_turf(ref)
		return get_step(GET_TURF_BELOW(ref_turf), dir)
	// AQ EDIT END
	return get_step(ref, dir)

/proc/get_dir_multiz(turf/us, turf/them)
	us = get_turf(us)
	them = get_turf(them)
	if(!us || !them)
		return NONE
	if(us.z == them.z)
		return get_dir(us, them)
	else
		var/turf/T = us.above()
		var/dir = NONE
		if(T && (T.z == them.z))
			dir = UP
		else
			T = us.below()
			if(T && (T.z == them.z))
				dir = DOWN
			else
				return get_dir(us, them)
		return (dir | get_dir(us, them))

/turf/proc/above()
	return GET_TURF_ABOVE(src) // AQ EDIT - makro zamiast get_step_multiz (tgstation/tgstation#76248)

/turf/proc/below()
	return GET_TURF_BELOW(src) // AQ EDIT - makro zamiast get_step_multiz (tgstation/tgstation#76248)

/proc/dir_inverse_multiz(dir)
	var/holder = dir & (UP|DOWN)
	if((holder == NONE) || (holder == (UP|DOWN)))
		return turn(dir, 180)
	dir &= ~(UP|DOWN)
	if(dir != 0)
		dir = turn(dir, 180)
	if(holder == UP)
		holder = DOWN
	else
		holder = UP
	dir |= holder
	return dir

/proc/get_zs_in_range(z_level, max_z_range)
	. = list(z_level)
	if(max_z_range <= 0)
		return
	// AQ EDIT START - stos pięter liczony raz na z-level (aquila/code/modules/mapping/multiz_levels.dm) zamiast chodzenia po kafelkach
	var/list/stack = SSmapping.get_multiz_stack(z_level)
	var/list/above = stack[1]
	var/list/below = stack[2]
	var/count = CEILING(max_z_range, 1)
	. += above.Copy(1, min(count, length(above)) + 1)
	. += below.Copy(1, min(count, length(below)) + 1)
	// AQ EDIT END

/proc/multi_z_dist(turf/T0, turf/T1)
	if(T0.get_virtual_z_level() == T1.get_virtual_z_level())
		return get_dist(T0, T1)
	if(is_station_level(T0.z) && is_station_level(T1.z))
		var/raw_dist = get_dist(T0, T1)
		var/z_dist = abs(T0.z - T1.z) * MULTI_Z_DISTANCE
		var/total_dist = raw_dist + z_dist
		return total_dist
	return INFINITY

//NSV13
/proc/get_level_trait(z)
	if(SSmapping.level_trait(z, ZTRAIT_STATION))
		return ZTRAIT_STATION
	if(SSmapping.level_trait(z, ZTRAIT_SYNDIE_SHIP))
		return ZTRAIT_SYNDIE_SHIP
