// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }

/// AQUILA - rośliny partii „inne”: mutacje z istniejących roślin (piec i odczynniki) i kolor hortensji zależny od podłoża
/datum/unit_test/aquila_botany_ported_inne

/datum/unit_test/aquila_botany_ported_inne/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)

// Mutacje w piecu dopisane do roślin, które już mamy
	var/list/furnace = list(
		/datum/plant_feature/fruit/berry = /datum/plant_feature/fruit/berry/blueberry,
		/datum/plant_feature/fruit/watermelon = /datum/plant_feature/fruit/watermelon/honeydew,
		/datum/plant_feature/fruit/tea = /datum/plant_feature/fruit/tea/catnip,
		/datum/plant_feature/fruit/tomato/blue = /datum/plant_feature/fruit/tomato/quantum,
	)
	for(var/parent_type in furnace)
		var/datum/plant_feature/fruit/parent_fruit = new parent_type()
		TEST_ASSERT(furnace[parent_type] in parent_fruit.mutations, "[parent_type] nie ma mutacji w piecu do [furnace[parent_type]]")
		qdel(parent_fruit)

// Mutacje od odczynnika: każda zmienia roślinę w tacy i zużywa odczynnik
	var/list/reagent_cases = list(
		list(/obj/item/plant_seeds/preset/tomato, /datum/reagent/phlogiston, 10, /datum/plant_feature/fruit/tomato/seething),
		list(/obj/item/plant_seeds/preset/orange, /datum/reagent/blood, 15, /datum/plant_feature/fruit/orange/blood),
		list(/obj/item/plant_seeds/preset/orange, /datum/reagent/iron, 15, /datum/plant_feature/fruit/orange/clockwork),
		list(/obj/item/plant_seeds/preset/pumpkin, /datum/reagent/consumable/capsaicin, 15, /datum/plant_feature/fruit/pumpkin/spice),
	)
	for(var/list/test_case in reagent_cases)
		var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
		var/datum/component/plant/plant = plant_in(tray, test_case[1], /datum/plant_subtrate/fairy)
		TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić [test_case[1]]")
		//Spełnione potrzeby mogą zapełnić tacę wodą do pełna, a wtedy odczynnik by się nie zmieścił
		tray.reagents.clear_reagents()
		tray.reagents.add_reagent(test_case[2], test_case[3])
		var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
		TEST_ASSERT(length(fruit.reagent_mutations) && fruit.reagent_mutations[test_case[4]], "[fruit.type] nie ma mutacji od odczynnika do [test_case[4]]")
		//Pozostałe mutacje tej rośliny wymagają innych odczynników, więc mutacja musi trafić w oczekiwaną odmianę
		var/datum/plant_feature/new_feature = fruit.try_reagent_mutation(2, TRUE)
		TEST_ASSERT(istype(new_feature, test_case[4]), "[test_case[1]] z [test_case[2]] zmienił się w [new_feature?.type] zamiast w [test_case[4]]")
		TEST_ASSERT(tray.reagents.get_reagent_amount(test_case[2]) < test_case[3], "Mutacja do [test_case[4]] nie zużyła odczynnika")
		qdel(tray)

// Hortensja: kolor kwiatu z podłoża
	var/list/blooms = list(
		/datum/plant_subtrate/clay = "blue",
		/datum/plant_subtrate/sand = "pink",
		/datum/plant_subtrate/dirt = "purple",
		/datum/plant_subtrate/fairy = "white",
	)
	for(var/substrate in blooms)
		var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
		var/datum/component/plant/plant = plant_in(tray, /obj/item/plant_seeds/preset/hydrangea, substrate)
		TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić hortensji w [substrate]")
		var/datum/plant_feature/body/body = locate() in plant.plant_features
		var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
		for(var/i in 1 to 3)
			body.process(2)
			fruit.process(2)
		TEST_ASSERT(length(fruit.fruits), "Hortensja w [substrate] nie zakwitła")
		fruit.catch_attack_hand(null, user)
		var/obj/item/food/grown/inne_flower/hydrangea/flower = locate() in get_turf(user)
		TEST_ASSERT_NOTNULL(flower, "Zbiór hortensji w [substrate] nie dał kwiatu")
		TEST_ASSERT(flower.bloom == blooms[substrate], "Hortensja w [substrate] ma kolor [flower.bloom] zamiast [blooms[substrate]]")
		TEST_ASSERT(icon_exists(flower.icon, flower.icon_state), "Brak ikony [flower.icon_state]")
		for(var/obj/item/leftover in get_turf(user))
			if(leftover != user && !(leftover in user))
				qdel(leftover)
		qdel(tray)

/// Sadzi nasiona w tacy z danym podłożem, z wodą i z pominięciem czasu wzrostu
/datum/unit_test/aquila_botany_ported_inne/proc/plant_in(obj/item/plant_tray/tray, seed_type, substrate)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(substrate)
	tray.reagents.add_reagent(/datum/reagent/water, 100)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(tray))
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!istype(plant))
		return null
	plant.skip_growth = TRUE
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(tray)
	return plant

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
