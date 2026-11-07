// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every ship map in rotation has the mechanics Atlas and Trawnik have (Atlantis and Von Neumann were missing most of them).
/// Unit tests run on runtimestation, so the ship maps are read from disk.
/datum/unit_test/aquila_map_standard
	/// Maps checked (json name in _maps/)
	var/list/map_jsons = list("aquila_atlas", "aquila_serendipity", "aquila_snake", "atlantis", "vonneumann")
	/// Types every one of these maps must place (subtypes count)
	var/list/required_types = list(
		/obj/effect/landmark/observer_start,
		/obj/effect/landmark/patrol_node,
		/obj/machinery/quantum_server,
		/obj/machinery/netpod,
		/obj/machinery/computer/quantum_console,
		/obj/machinery/byteforge,
		/obj/machinery/exodrone_launcher,
		/obj/machinery/exoscanner,
		/obj/machinery/computer/exodrone_control_console,
		/obj/machinery/ai/data_core,
		/obj/machinery/ai/server_cabinet,
		/obj/machinery/computer/ai_resource_distribution,
		/obj/structure/ethernet_cable,
		/obj/machinery/computer/xenoarchaeology_console,
		/obj/machinery/xenoarchaeology_machine,
		/obj/machinery/munitions_forge/arc_forge,
		/obj/machinery/munitions_forge/anvil,
		/obj/machinery/shipbreaker,
		/obj/machinery/computer/ship/mineral_magnet,
		/obj/effect/landmark/asteroid_spawn,
		/obj/machinery/computer/slime_market,
		/obj/machinery/piratepad/civilian,
		/obj/machinery/materials_market,
		/obj/machinery/restaurant_portal,
		/obj/machinery/restaurant_terminal,
		/obj/machinery/griddle,
		/obj/machinery/oven,
		/obj/machinery/modular_fabricator/component_printer,
		/obj/machinery/computer/telecomms/traffic,
		/obj/machinery/vitals_reader,
		/obj/structure/desk_bell,
		/obj/machinery/conquest_beacon,
		/mob/living/simple_animal/hostile/retaliate/wojtek,
	)

/// TRUE if the TGM text places the type or one of its subtypes (atom lines start the line and end with "," "{" or a subtype "/")
/datum/unit_test/aquila_map_standard/proc/map_has_type(map_text, typepath)
	var/needle = "\n[typepath]"
	var/position = findtext(map_text, needle)
	while(position)
		var/next_char = copytext(map_text, position + length(needle), position + length(needle) + 1)
		if(next_char == "," || next_char == "{" || next_char == "/")
			return TRUE
		position = findtext(map_text, needle, position + 1)
	return FALSE

/// Every MAP_REMOVE_JOB(x) in the map's job_changes.dm must really disable job x under that map's name.
/// It does not when map_changes.dm forgets to include the file (Atlantis and Von Neumann had that bug).
/datum/unit_test/aquila_map_standard/proc/check_job_changes(map_json, map_path, map_name)
	if(!fexists("_maps/[map_path]/job_changes.dm"))
		return
	var/job_changes = file2text("_maps/[map_path]/job_changes.dm")
	var/regex/removal = regex(@"^MAP_REMOVE_JOB\((\w+)\)", "gm")
	var/old_name = SSmapping.config.map_name
	SSmapping.config.map_name = map_name
	var/list/still_enabled = list()
	while(removal.Find(job_changes))
		var/job_path = text2path("/datum/job/[removal.group[1]]")
		if(!job_path)
			continue
		var/datum/job/job = new job_path
		if(job.map_check())
			still_enabled += removal.group[1]
		qdel(job)
	SSmapping.config.map_name = old_name
	TEST_ASSERT(!length(still_enabled), "[map_json]: job_changes.dm removes [still_enabled.Join(", ")], but the job stays enabled under \"[map_name]\" (is the file included in map_changes.dm?)")

/datum/unit_test/aquila_map_standard/Run()
	var/basemap = file2text("_maps/_basemap.dm")
	for(var/map_json in map_jsons)
		var/list/config = json_decode(file2text("_maps/[map_json].json"))
		var/list/map_files = islist(config["map_file"]) ? config["map_file"] : list(config["map_file"])
		var/map_path = config["map_path"]
		var/map_text = ""
		for(var/map_file in map_files)
			var/one_map = file2text("_maps/[map_path]/[map_file]")
			TEST_ASSERT(length(one_map), "[map_json]: cannot read _maps/[map_path]/[map_file]")
			map_text += one_map
			// CI compiles the map only if it is in the ALL_MAPS block
			var/include_path = replacetext("[map_path]/[map_file]", "/", "\\")
			TEST_ASSERT(findtext(basemap, include_path), "[map_json]: [include_path] is not included in _maps/_basemap.dm, so CI never compiles it")
		check_job_changes(map_json, map_path, config["map_name"])
		if(!succeeded)
			return
		var/list/missing = list()
		for(var/typepath in required_types)
			if(!map_has_type(map_text, typepath))
				missing += "[typepath]"
		TEST_ASSERT(!length(missing), "[map_json] is missing: [missing.Join(", ")]")

#undef TEST_ASSERT
