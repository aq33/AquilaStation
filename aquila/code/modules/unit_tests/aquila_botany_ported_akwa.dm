// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - akwakultura: małże rosną tylko w podłożu wodnym, rośliny lądowe w nim nie rosną, a otwarty nożem małż daje mięso z odczynnikami plonu
/datum/unit_test/aquila_botany_aquaculture

/datum/unit_test/aquila_botany_aquaculture/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, origin)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/clams = allocate(/obj/item/plant_seeds/preset/clam, origin)
	TEST_ASSERT(findtext(clams.name, "larwy: ") == 1 && findtext(clams.name, "(woda)"), "Zła nazwa paczki małży: [clams.name]")

// Ziemia i baśniowe podłoże nie przyjmują małży
	planter.set_substrate(/datum/plant_subtrate/dirt)
	TEST_ASSERT(!clams.plant(tray, null, TRUE, null, TRUE), "Małże dały się zasadzić w ziemi")
	planter.set_substrate(/datum/plant_subtrate/fairy)
	TEST_ASSERT(!clams.plant(tray, null, TRUE, null, TRUE), "Małże dały się zasadzić w baśniowym podłożu")

// Roślina lądowa nie rośnie w wodzie
	planter.set_substrate(/datum/plant_subtrate/water)
	var/obj/item/plant_seeds/potato = allocate(/obj/item/plant_seeds/preset/potato, origin)
	TEST_ASSERT(!potato.plant(tray, null, TRUE, null, TRUE), "Ziemniak dał się zasadzić w podłożu wodnym")

// W wodzie małże rosną i dają plon
	var/datum/component/plant/plant = clams.plant(tray, null, TRUE, null, TRUE)
	TEST_ASSERT(istype(plant), "Małże nie dały się zasadzić w podłożu wodnym")
	plant.skip_growth = TRUE
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	TEST_ASSERT(istype(body, /datum/plant_feature/body/shoal), "Małże nie rosną w ławicy")
	for(var/i in 1 to 3)
		body.process(2)
		fruit.process(2)
	TEST_ASSERT(length(fruit.fruits), "Małże nie dały plonu w podłożu wodnym")
	var/obj/item/food/grown/shellfish/clam/clam = fruit.fruits[1]
	TEST_ASSERT(istype(clam), "Plon małży to nie małż: [clam?.type]")
	var/protein = clam.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment/protein)
	TEST_ASSERT(protein > 0, "Małż z ławicy nie ma białka")

// Otwarcie nożem: mięso dostaje odczynniki małża
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/kitchen/knife/knife = allocate(/obj/item/kitchen/knife, origin)
	fruit.catch_attack_hand(null, user)
	clam.StartProcessingAtom(user, knife, list(TOOL_PROCESSING_RESULT = /obj/item/food/shellfish_meat/clam, TOOL_PROCESSING_AMOUNT = 1, TOOL_PROCESSING_TIME = 0))
	var/obj/item/food/shellfish_meat/clam/meat = locate() in get_turf(user)
	TEST_ASSERT(meat, "Otwarty nożem małż nie dał mięsa")
	TEST_ASSERT(meat.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment/protein) >= protein, "Mięso małża nie przejęło białka z plonu")
	for(var/obj/item/leftover in get_turf(user))
		if(leftover != knife && leftover != user && !(leftover in user))
			qdel(leftover)

#undef TEST_ASSERT
