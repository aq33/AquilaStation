// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - losowe uzbrojenie: każdy slot ma pasujące warianty, każdy wariant ma swój slot
/datum/unit_test/aquila_random_ship_weapons

/datum/unit_test/aquila_random_ship_weapons/Run()
	var/list/templates = list()
	for(var/datum/map_template/random_room/template_type as anything in subtypesof(/datum/map_template/random_room))
		if(initial(template_type.room_group))
			templates += template_type

	var/list/slot_groups = list()
	for(var/obj/effect/spawner/room/spawner_type as anything in subtypesof(/obj/effect/spawner/room))
		var/group = initial(spawner_type.room_group)
		if(!group)
			continue
		slot_groups |= group
		var/variants = 0
		for(var/datum/map_template/random_room/template_type as anything in templates)
			if(initial(template_type.room_group) != group)
				continue
			TEST_ASSERT(initial(template_type.template_width) == initial(spawner_type.room_width) && initial(template_type.template_height) == initial(spawner_type.room_height), \
				"[template_type] ma inny rozmiar niż slot [spawner_type]")
			variants++
		TEST_ASSERT(variants, "Slot [spawner_type] nie ma żadnego wariantu z room_group \"[group]\"")

	for(var/datum/map_template/random_room/template_type as anything in templates)
		TEST_ASSERT(initial(template_type.room_group) in slot_groups, "[template_type] ma room_group \"[initial(template_type.room_group)]\", którego nie używa żaden spawner")
		// Plik .dmm musi się wczytać i mieć dokładnie zadeklarowany rozmiar
		var/datum/map_template/random_room/loaded = SSmapping.random_room_templates[initial(template_type.room_id)]
		TEST_ASSERT(loaded, "[template_type] nie trafił do SSmapping.random_room_templates")
		TEST_ASSERT(loaded.width == loaded.template_width && loaded.height == loaded.template_height, \
			"[loaded.mappath] ma [loaded.width]x[loaded.height], a [template_type] deklaruje [loaded.template_width]x[loaded.template_height]")

	// Stanowisko na kilku pokładach: każdy pokład (grupa) musi mieć szablon każdego wariantu, inaczej drugi spawner nie miałby czego wkleić
	var/list/link_variants = list()
	var/list/link_group_variants = list()
	for(var/datum/map_template/random_room/template_type as anything in templates)
		var/link = initial(template_type.room_link)
		if(!link)
			continue
		var/variant = initial(template_type.room_variant)
		var/group = initial(template_type.room_group)
		TEST_ASSERT(variant, "[template_type] ma room_link bez room_variant")
		LAZYOR(link_variants[link], variant)
		LAZYOR(link_group_variants["[link]|[group]"], variant)
	for(var/key in link_group_variants)
		var/link = splittext(key, "|")[1]
		TEST_ASSERT(length(link_group_variants[key]) == length(link_variants[link]), \
			"[key] ma warianty [english_list(link_group_variants[key])], a całe stanowisko [english_list(link_variants[link])]")

	// Na Atlasie oba pokłady stanowiska NAC dostały ten sam wariant i broń jest podłączona
	if(SSmapping.config.map_name != "NSV Aquilas")
		return
	var/variant = GLOB.random_room_link_choices["atlas_nac"]
	TEST_ASSERT(variant, "Na Atlasie nie wylosowano wariantu stanowiska NAC")
	var/rails = 0
	var/turrets = 0
	for(var/obj/machinery/ship_weapon/hybrid_rail/rail in GLOB.machines)
		if(!is_station_level(rail.z))
			continue
		rails++
		var/turf/rail_turf = get_turf(rail)
		TEST_ASSERT(rail_turf.get_cable_node(), "Railgun hybrydowy w [rail.x],[rail.y] nie stoi na kablu")
	for(var/obj/machinery/ship_weapon/deck_turret/turret in GLOB.machines)
		if(!is_station_level(turret.z))
			continue
		turrets++
		TEST_ASSERT(turret.core, "Wieża NAC w [turret.x],[turret.y],[turret.z] nie ma rdzenia pod spodem")
	TEST_ASSERT(rails == (variant == "railgun" ? 2 : 0) && turrets == (variant == "nac" ? 2 : 0), \
		"Wariant [variant], a na statku jest [rails] railgunów hybrydowych i [turrets] wież NAC")

#undef TEST_ASSERT
