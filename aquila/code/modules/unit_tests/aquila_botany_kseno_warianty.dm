// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kapsułowe odmiany roślin obcych i z planet (ksenoflora_warianty.dm): ten sam przebieg co rośliny ras
/// (w tacce nie wschodzą, w kapsule z warunkami owocują, bez gazu stoją)
/datum/unit_test/aquila_botany_kseno_rasy/warianty
	seed_root = /obj/item/plant_seeds/preset/alien/xenoflora/capsule

/// AQUILA - owoc odmiany kapsułowej jest dwa razy większy od zwykłego, więc daje dwa razy więcej odczynników
/datum/unit_test/aquila_botany_kseno_warianty_objetosc

/datum/unit_test/aquila_botany_kseno_warianty_objetosc/Run()
	var/count = 0
	for(var/seed_type in valid_subtypesof(/obj/item/plant_seeds/preset/alien/xenoflora/capsule))
		var/obj/item/plant_seeds/seeds = allocate(seed_type, run_loc_floor_bottom_left)
		var/datum/plant_feature/fruit/variant
		for(var/datum/plant_feature/fruit/fruit in seeds.plant_features)
			variant = fruit.type
		TEST_ASSERT(variant, "[seed_type] nie ma owocu")
		var/datum/plant_feature/fruit/parent = type2parent(variant)
		TEST_ASSERT(ispath(parent, /datum/plant_feature/fruit) && parent != /datum/plant_feature/fruit, "Owoc [variant] nie jest odmianą zwykłej rośliny")
		TEST_ASSERT(initial(variant.total_volume) == initial(parent.total_volume) * 2, "Owoc [variant] ma [initial(variant.total_volume)] j. zamiast [initial(parent.total_volume) * 2] (dwa razy więcej niż [parent])")
		count++
	TEST_ASSERT(count == 7, "Odmian kapsułowych jest [count] zamiast 7")

#undef TEST_ASSERT
