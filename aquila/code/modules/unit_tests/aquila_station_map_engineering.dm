// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message || "No message"] (expected [b], got [a])") }

/// AQUILA - inżynieryjna holomapa: dorysowuje znaczniki aktywnych alarmów pożarowych i atmosferycznych,
/// a bez alarmów ich nie pokazuje. Każdy poziom statku ma wygenerowany plan (inaczej mapa byłaby „bogus”).
/datum/unit_test/aquila_station_map_engineering
	/// Obszar, któremu test włącza alarmy (przywracane w Destroy)
	var/area/alarm_area

/datum/unit_test/aquila_station_map_engineering/Run()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		TEST_ASSERT("[HOLOMAP_EXTRA_STATIONMAP]_[z]" in SSholomaps.extra_holomaps, "poziom statku [z] nie ma planu holomapy")

	var/obj/machinery/station_map/engineering/holomap = allocate(/obj/machinery/station_map/engineering/directional/north)
	// Plan poziomu testów nie musi istnieć: liczymy znaczniki tak, jak na poziomie statku
	holomap.bogus = FALSE
	holomap.current_z_level = holomap.z

	var/turf/alarm_turf = get_step(run_loc_floor_bottom_left, EAST)
	allocate(/obj/machinery/firealarm, alarm_turf)
	allocate(/obj/machinery/airalarm, alarm_turf)
	alarm_area = get_area(alarm_turf)

	// Inne obszary poziomu mogą mieć własne alarmy (np. dziura do kosmosu), więc liczy się znacznik w miejscu testowego alarmu
	var/list/legend = holomap.handle_overlays()
	TEST_ASSERT(!station_map_marker_at(legend, "Alarmy pożarowe", alarm_turf), "bez pożaru nie powinno być znacznika alarmu pożarowego")
	TEST_ASSERT(!station_map_marker_at(legend, "Alarmy powietrza", alarm_turf), "bez alarmu atmosfery nie powinno być znacznika alarmu powietrza")

	alarm_area.fire = TRUE
	alarm_area.atmosalm = TRUE
	legend = holomap.handle_overlays()
	TEST_ASSERT(station_map_marker_at(legend, "Alarmy pożarowe", alarm_turf), "aktywny alarm pożarowy nie trafił na holomapę")
	TEST_ASSERT(station_map_marker_at(legend, "Alarmy powietrza", alarm_turf), "aktywny alarm atmosfery nie trafił na holomapę")

	// Projekt płytki w badaniach inżynierii
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("engineering")
	TEST_ASSERT("station_map_engineering" in node.design_ids, "węzeł engineering nie ma projektu holomapy")
	var/datum/design/design = SSresearch.techweb_designs["station_map_engineering"]
	TEST_ASSERT_EQUAL(design?.build_path, /obj/item/circuitboard/machine/station_map/engineering, "projekt holomapy buduje złą płytkę")

/// Czy legenda holomapy ma w danej grupie znacznik w miejscu pola (tak jak liczy go handle_overlays)
/datum/unit_test/aquila_station_map_engineering/proc/station_map_marker_at(list/legend, group, turf/where)
	var/list/entry = legend[group]
	if(!entry)
		return FALSE
	for(var/image/marker as anything in entry["markers"])
		if(marker.pixel_x == where.x + HOLOMAP_CENTER_X - 1 && marker.pixel_y == where.y + HOLOMAP_CENTER_Y)
			return TRUE
	return FALSE

/datum/unit_test/aquila_station_map_engineering/Destroy()
	if(alarm_area)
		alarm_area.fire = initial(alarm_area.fire)
		alarm_area.atmosalm = initial(alarm_area.atmosalm)
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
