// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Archetypy KNPC: każdy dostaje swoje wyposażenie, każde wnętrze Syndykatu ma jednego dowódcę, szansa na granat rośnie z trudnością
/datum/unit_test/aquila_knpc_archetypes

/datum/unit_test/aquila_knpc_archetypes/Run()
	// typ KNPC => przedmiot, który musi mieć przy sobie
	var/list/expected = list(
		/mob/living/carbon/human/ai_boarder/syndicate/assault = /obj/item/gun/ballistic/automatic/c20r,
		/mob/living/carbon/human/ai_boarder/syndicate/sentry = /obj/item/gun/ballistic/shotgun/automatic/combat,
		/mob/living/carbon/human/ai_boarder/syndicate/sapper = /obj/item/weldingtool/largetank,
		/mob/living/carbon/human/ai_boarder/syndicate/commander = /obj/item/documents/syndicate/red,
		/mob/living/carbon/human/ai_boarder/syndicate/medic = /obj/item/storage/backpack/duffelbag/syndie/med,
	)
	for(var/knpc_type in expected)
		var/mob/living/carbon/human/ai_boarder/knpc = allocate(knpc_type, run_loc_floor_bottom_left)
		var/list/stuff = knpc.GetAllContents()
		TEST_ASSERT(locate(expected[knpc_type]) in stuff, "[knpc_type] nie ma przy sobie [expected[knpc_type]]")
		if(knpc_type == /mob/living/carbon/human/ai_boarder/syndicate/medic)
			var/medipens = 0
			for(var/obj/item/reagent_containers/hypospray/medipen/survival/pen in stuff)
				medipens++
			TEST_ASSERT(medipens >= 5, "Medyk ma [medipens] medipenów zamiast co najmniej 5")
		if(knpc_type == /mob/living/carbon/human/ai_boarder/syndicate/sapper)
			var/frags = 0
			for(var/obj/item/grenade/frag/frag in stuff)
				frags++
			TEST_ASSERT(frags >= 2, "Saper ma [frags] granatów odłamkowych zamiast co najmniej 2")
		TEST_ASSERT(knpc.aq_knpc_main_gun() || knpc_type == /mob/living/carbon/human/ai_boarder/syndicate/sentry, "[knpc_type] nie ma broni z magazynkiem")
		qdel(knpc)

	var/chance = aq_knpc_frag_chance()
	TEST_ASSERT(chance >= 10 && chance <= 30, "Szansa na granat odłamkowy poza zakresem: [chance]")

	for(var/map_name in list("marine_frigate", "carrier", "destroyer", "mako", "mako_carrier", "nukefrigate", "smalloutpost"))
		var/commanders = aquila_count_map_path("_maps/templates/boarding/syndicate/[map_name].dmm", "/mob/living/carbon/human/ai_boarder/syndicate/commander")
		TEST_ASSERT(commanders == 1, "[map_name]: [commanders] dowódców zamiast jednego")

/// Ile razy dana ścieżka typu stoi na mapie (bez ładowania mapy)
/proc/aquila_count_map_path(map_path, type_path)
	var/datum/parsed_map/parsed = new(file(map_path))
	var/list/per_key = list()
	for(var/key in parsed.grid_models)
		var/count = 0
		var/position = 1
		while((position = findtext(parsed.grid_models[key], type_path, position)))
			var/next_char = copytext(parsed.grid_models[key], position + length(type_path), position + length(type_path) + 1)
			if(!next_char || !findtext("abcdefghijklmnopqrstuvwxyz_/0123456789", next_char))
				count++
			position += length(type_path)
		if(count)
			per_key[key] = count
	. = 0
	for(var/datum/grid_set/grid as anything in parsed.gridSets)
		for(var/line in grid.gridLines)
			line = replacetext(line, ascii2text(13), "")
			for(var/position in 1 to length(line) step parsed.key_len)
				. += per_key[copytext(line, position, position + parsed.key_len)] || 0
	qdel(parsed)

#undef TEST_ASSERT
