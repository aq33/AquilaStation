// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - drinki z tg: każdy sprite szklanki istnieje, bazy są w dyspenserach baru, przykładowe reakcje dają drink
/datum/unit_test/aquila_tg_drinks

/datum/unit_test/aquila_tg_drinks/Run()
	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		var/glass_icon = initial(reagent_type.glass_icon)
		if(!glass_icon)
			continue
		TEST_ASSERT(initial(reagent_type.glass_icon_state) in icon_states(glass_icon), "[reagent_type]: no glass state [initial(reagent_type.glass_icon_state)] in [glass_icon]")

	var/obj/machinery/chem_dispenser/drinks/beer/booze = allocate(/obj/machinery/chem_dispenser/drinks/beer)
	TEST_ASSERT(/datum/reagent/consumable/ethanol/bitters in booze.dispensable_reagents, "The booze dispenser has no bitters")
	var/obj/machinery/chem_dispenser/drinks/soda = allocate(/obj/machinery/chem_dispenser/drinks)
	TEST_ASSERT(/datum/reagent/consumable/sol_dry in soda.dispensable_reagents, "The soda dispenser has no Sol Dry")

	// Bitter z wodą sodową i lodem
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)
	beaker.reagents.add_reagent(/datum/reagent/consumable/sodawater, 10)
	beaker.reagents.add_reagent(/datum/reagent/consumable/ice, 5)
	beaker.reagents.add_reagent(/datum/reagent/consumable/ethanol/bitters, 1)
	TEST_ASSERT(beaker.reagents.has_reagent(/datum/reagent/consumable/ethanol/bitters_soda), "Soda water, ice and bitters did not make Bitters and Soda ([beaker.reagents.log_list()])")

	// Szklanka pokazuje sprite drinka z pliku tg, a po opróżnieniu wraca do zwykłej
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass)
	glass.reagents.add_reagent(/datum/reagent/consumable/ethanol/bitters_soda, 10)
	var/datum/reagent/bitters_soda = /datum/reagent/consumable/ethanol/bitters_soda
	TEST_ASSERT(glass.icon == initial(bitters_soda.glass_icon), "The glass did not switch to the tg drink icon")
	glass.reagents.clear_reagents()
	TEST_ASSERT(glass.icon == initial(glass.icon), "The empty glass kept the tg drink icon")

#undef TEST_ASSERT
