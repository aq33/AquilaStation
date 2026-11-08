// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every ship map in rotation has the mechanics Atlas and Trawnik have (Atlantis and Von Neumann were missing most of them).
/// Unit tests do not load these maps (CI runs on the default map only), so they are read from disk.
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
		/obj/item/fuel_pellet,
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
		/obj/machinery/slime_extract_requestor,
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
		/obj/machinery/gulag_teleporter,
		/obj/machinery/computer/prisoner/gulag_teleporter_computer,
		/obj/machinery/gulag_item_reclaimer,
	)
	/// Mechanics a map does without on purpose (json name = types it may skip)
	var/list/map_exceptions = list(
		// Trawnik and Von Neumann have no asteroid cage (removed by the mapper), so no magnet and no shipbreaking
		"aquila_serendipity" = list(/obj/machinery/computer/ship/mineral_magnet, /obj/effect/landmark/asteroid_spawn, /obj/machinery/shipbreaker),
		"vonneumann" = list(/obj/machinery/computer/ship/mineral_magnet, /obj/effect/landmark/asteroid_spawn, /obj/machinery/shipbreaker),
	)

/// The TGM dictionary entries that are actually placed on the map grid, as one text (keys left over in the dictionary do not count)
/datum/unit_test/aquila_map_standard/proc/placed_entries(map_text)
	map_text = replacetextEx(map_text, ascii2text(13), "")
	var/grid_start = findtextEx(map_text, "\n(1,1,1) = {\"")
	if(!grid_start)
		return ""
	var/list/placed = list()
	for(var/line in splittext(copytext(map_text, grid_start + 1), "\n"))
		placed[line] = TRUE
	var/list/entries = list()
	// Every entry starts on a new line with "key" = (
	for(var/entry in splittext(copytext(map_text, 1, grid_start), "\n\""))
		var/key_end = findtextEx(entry, "\" = (")
		if(key_end && placed[copytext(entry, 1, key_end)])
			entries += entry
	return "\n\"[jointext(entries, "\n\n\"")]\n"

/// TRUE if the placed TGM entries contain the type or one of its subtypes (atom lines start the line and end with "," "{" ")" or a subtype "/")
/datum/unit_test/aquila_map_standard/proc/map_has_type(placed_text, typepath)
	var/needle = "\n[typepath]"
	var/position = findtextEx(placed_text, needle)
	while(position)
		var/next_char = copytext(placed_text, position + length(needle), position + length(needle) + 1)
		if(next_char == "," || next_char == "{" || next_char == "/" || next_char == ")")
			return TRUE
		position = findtextEx(placed_text, needle, position + 1)
	return FALSE

/// TRUE if one placed entry has a laborcamp_home dock that spawns the labour shuttle at round start
/datum/unit_test/aquila_map_standard/proc/has_gulag_dock(placed_text)
	for(var/entry in splittext(placed_text, "\n\""))
		if(findtextEx(entry, "id = \"laborcamp_home\"") && findtextEx(entry, "roundstart_template = /datum/map_template/shuttle/labour"))
			return TRUE
	return FALSE

/// Every MAP_REMOVE_JOB(x) in the map's job_changes.dm must name a real station job and really disable it under that map's name.
/// It does not when map_changes.dm forgets to include the file (Atlantis and Von Neumann had that bug).
/// The macro itself declares /datum/job/x, so a misspelled job compiles fine and has to be caught here (brig_phys was one).
/datum/unit_test/aquila_map_standard/proc/check_job_changes(map_json, map_path, map_name)
	if(!fexists("_maps/[map_path]/job_changes.dm"))
		return
	var/job_changes = file2text("_maps/[map_path]/job_changes.dm")
	var/regex/removal = regex(@"^MAP_REMOVE_JOB\((\w+)\)", "gm")
	var/list/not_jobs = list()
	var/list/job_paths = list()
	while(removal.Find(job_changes))
		var/datum/job/job_path = text2path("/datum/job/[removal.group[1]]")
		if(!job_path || initial(job_path.faction) != "Station")
			not_jobs += removal.group[1]
		else
			job_paths[job_path] = removal.group[1]
	TEST_ASSERT(!length(not_jobs), "[map_json]: job_changes.dm removes [not_jobs.Join(", ")], which is not a station job (misspelled type?)")
	var/list/still_enabled = list()
	var/old_name = SSmapping.config.map_name
	SSmapping.config.map_name = map_name
	for(var/job_path in job_paths)
		var/datum/job/job = new job_path
		if(job.map_check())
			still_enabled += job_paths[job_path]
		qdel(job)
	SSmapping.config.map_name = old_name
	TEST_ASSERT(!length(still_enabled), "[map_json]: job_changes.dm removes [still_enabled.Join(", ")], but the job stays enabled under \"[map_name]\" (is the file included in map_changes.dm?)")

/datum/unit_test/aquila_map_standard/Run()
	var/basemap = file2text("_maps/_basemap.dm")
	for(var/map_json in map_jsons)
		var/list/config = json_decode(file2text("_maps/[map_json].json"))
		var/list/map_files = islist(config["map_file"]) ? config["map_file"] : list(config["map_file"])
		var/map_path = config["map_path"]
		var/placed_text = ""
		for(var/map_file in map_files)
			var/one_map = file2text("_maps/[map_path]/[map_file]")
			TEST_ASSERT(length(one_map), "[map_json]: cannot read _maps/[map_path]/[map_file]")
			placed_text += placed_entries(one_map)
			// CI compiles the map only if it is in the ALL_MAPS block
			var/include_path = replacetext("[map_path]/[map_file]", "/", "\\")
			// The tab before #include rejects a commented-out //#include
			TEST_ASSERT(findtextEx(basemap, "\t#include \"[include_path]\""), "[map_json]: [include_path] is not included in _maps/_basemap.dm, so CI never compiles it")
		// The labour camp z-level loads only with has_gulag, and its shuttle needs a dock on the ship
		TEST_ASSERT(config["has_gulag"], "[map_json]: has_gulag is not set, so the labour camp is never loaded")
		TEST_ASSERT(has_gulag_dock(placed_text), "[map_json]: no placed laborcamp_home docking port with the labour shuttle as roundstart_template")
		check_job_changes(map_json, map_path, config["map_name"])
		if(!succeeded)
			return
		var/list/missing = list()
		var/list/skipped = map_exceptions[map_json] || list()
		for(var/typepath in required_types)
			if(!(typepath in skipped) && !map_has_type(placed_text, typepath))
				missing += "[typepath]"
		TEST_ASSERT(!length(missing), "[map_json] is missing: [missing.Join(", ")]")

#undef TEST_ASSERT
