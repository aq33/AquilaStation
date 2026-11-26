// AQUILA - wspólne procedury eventów ze stworami z mapy hex (etap E4): bezpieczne pola w tunelach technicznych,
// wolne pola obok siebie i wentylacje statku

/// Obszar tuneli technicznych statku, w którym może się coś pojawić (bez paneli słonecznych, utylizacji i zagród szlamów)
/proc/aquila_hex_maint_area_ok(area/A)
	var/static/list/excluded_areas = typecacheof(list(
		/area/maintenance/solars,
		/area/maintenance/disposal,
		/area/maintenance/department/science/xenobiology,
	))
	return istype(A, /area/maintenance) && (A.type in GLOB.the_station_areas) && !is_type_in_typecache(A, excluded_areas)

/// Wolne pole podłogi z powietrzem do oddychania, bez gęstych obiektów i ludzi
/proc/aquila_hex_free_safe_turf(turf/T)
	if(!isturf(T) || isgroundlessturf(T) || !is_turf_safe(T))
		return FALSE
	return !is_blocked_turf(T)

/**
 * Losowe wolne i bezpieczne pole w tunelach technicznych statku (jeden losowy obszar po drugim).
 * Gdy statek nie ma takich tuneli, losowe wolne pole statku; null, gdy nie ma żadnego.
 */
/proc/aquila_hex_maint_turf()
	var/list/areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(aquila_hex_maint_area_ok(A))
			areas += A
	while(length(areas))
		var/area/A = pick_n_take(areas)
		var/list/turfs = list()
		for(var/turf/T in A)
			if(is_station_level(T.z) && aquila_hex_free_safe_turf(T))
				turfs += T
		if(length(turfs))
			return pick(turfs)
	for(var/attempt in 1 to 10)
		var/turf/T = aquila_hex_random_ship_turf()
		if(aquila_hex_free_safe_turf(T))
			return T

/// Do amount wolnych pól wokół center (najbliższe pierwsze, center też się liczy), widocznych z center
/proc/aquila_hex_free_turfs_near(turf/center, amount, range = 3)
	. = list()
	if(!isturf(center))
		return
	for(var/dist in 0 to range)
		for(var/turf/T as anything in (dist ? (RANGE_TURFS(dist, center) - RANGE_TURFS(dist - 1, center)) : list(center)))
			if(length(.) >= amount)
				return
			if(!isopenturf(T) || isgroundlessturf(T) || T.density || is_blocked_turf(T, TRUE))
				continue
			if(dist && !(T in view(range, center)))
				continue
			. += T

/// Pola pod wentylacjami statku, które nie są zaspawane: najpierw te w tunelach technicznych
/proc/aquila_hex_vent_turfs(maint_first = TRUE)
	var/list/maint_turfs = list()
	var/list/other_turfs = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in GLOB.machines)
		if(QDELETED(vent) || vent.welded)
			continue
		var/turf/vent_turf = get_turf(vent)
		if(!vent_turf || !is_station_level(vent_turf.z) || isspaceturf(vent_turf))
			continue
		if(maint_first && aquila_hex_maint_area_ok(get_area(vent_turf)))
			maint_turfs += vent_turf
		else
			other_turfs += vent_turf
	return length(maint_turfs) ? maint_turfs : other_turfs
