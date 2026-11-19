// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }

/// AQUILA - mutacje od odczynnika: pomarańcza z krwią w tacy zmienia się w krwistą pomarańczę i zużywa krew, bez krwi zostaje pomarańczą
/datum/unit_test/aquila_botany_reagent_mutations

/// Testowy zestaw dopisków: pomidor dostaje mutację w piecu, pomarańcza drugą mutację od odczynnika (mleko), obok tych z własnych list
/datum/plant_mutation_set/unit_test
	mutations = list(/datum/plant_feature/fruit/tomato = list(/datum/plant_feature/fruit/tomato/friendly = 5))
	reagent_mutations = list(/datum/plant_feature/fruit/orange = list(/datum/plant_feature/fruit/orange/threedee = list(/datum/reagent/consumable/milk = 10)))

/datum/unit_test/aquila_botany_reagent_mutations/proc/plant_orange(obj/item/plant_tray/tray)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 100)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/orange, get_turf(tray))
	return seeds.plant(tray, null, TRUE, null, TRUE)

/datum/unit_test/aquila_botany_reagent_mutations/Run()
	var/turf/origin = run_loc_floor_bottom_left

// Bez krwi nic się nie dzieje
	var/obj/item/plant_tray/plain_tray = allocate(/obj/item/plant_tray, origin)
	var/datum/component/plant/plain = plant_orange(plain_tray)
	TEST_ASSERT_NOTNULL(plain, "Nie udało się posadzić pomarańczy")
	var/datum/plant_feature/fruit/plain_fruit = locate() in plain.plant_features
	TEST_ASSERT(isnull(plain_fruit.try_reagent_mutation(2, TRUE)), "Pomarańcza zmutowała bez krwi w tacy")

// Zestawy /datum/plant_mutation_set dopisują się do siebie i nie trafiają do odmian
	TEST_ASSERT(plain_fruit.reagent_mutations[/datum/plant_feature/fruit/orange/blood], "Brak mutacji pomarańczy od krwi z zestawu partii „inne”")
	TEST_ASSERT(plain_fruit.reagent_mutations[/datum/plant_feature/fruit/orange/threedee], "Brak mutacji od mleka dopisanej przez zestaw testowy")
	var/datum/plant_feature/fruit/tomato = new /datum/plant_feature/fruit/tomato()
	TEST_ASSERT((/datum/plant_feature/fruit/tomato/blood in tomato.mutations) && (/datum/plant_feature/fruit/tomato/friendly in tomato.mutations), "Mutacje w piecu: zestaw skasował własne albo nie dopisał nowej")
	qdel(tomato)
	var/datum/plant_feature/fruit/blue_tomato = new /datum/plant_feature/fruit/tomato/blue()
	TEST_ASSERT(!(/datum/plant_feature/fruit/tomato/friendly in blue_tomato.mutations), "Dopisek dla pomidora trafił też do jego odmiany")
	qdel(blue_tomato)

// Z krwią zmienia się w krwistą pomarańczę
	var/obj/item/plant_tray/blood_tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/plant/plant = plant_orange(blood_tray)
	TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić drugiej pomarańczy")
	blood_tray.reagents.add_reagent(/datum/reagent/blood, 15)
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	var/datum/plant_feature/new_feature = fruit.try_reagent_mutation(2, TRUE)
	TEST_ASSERT_NOTNULL(new_feature, "Pomarańcza z krwią w tacy nie zmutowała")
	TEST_ASSERT(istype(new_feature, /datum/plant_feature/fruit/orange/blood), "Pomarańcza z krwią zmieniła się w [new_feature.type] zamiast w krwistą pomarańczę")
	TEST_ASSERT(new_feature in plant.plant_features, "Nowa część nie trafiła do rośliny")
	TEST_ASSERT(QDELETED(fruit), "Stara część owocu nie została usunięta")
	TEST_ASSERT(blood_tray.reagents.get_reagent_amount(/datum/reagent/blood) <= 5, "Mutacja nie zużyła krwi (zostało [blood_tray.reagents.get_reagent_amount(/datum/reagent/blood)] j.)")

// Krwista pomarańcza z krwią nie mutuje sama w siebie
	blood_tray.reagents.add_reagent(/datum/reagent/blood, 15)
	var/datum/plant_feature/fruit/blood_fruit = new_feature
	TEST_ASSERT(isnull(blood_fruit.try_reagent_mutation(2, TRUE)), "Krwista pomarańcza zmutowała sama w siebie")

// Zwykły cykl wzrostu (process) też wywołuje mutację; przy delta_time 60 szansa przekracza 100%, więc wynik jest pewny
	var/obj/item/plant_tray/process_tray = allocate(/obj/item/plant_tray, get_step(origin, NORTH))
	var/datum/component/plant/process_plant = plant_orange(process_tray)
	TEST_ASSERT_NOTNULL(process_plant, "Nie udało się posadzić trzeciej pomarańczy")
	process_tray.reagents.add_reagent(/datum/reagent/blood, 15)
	var/datum/plant_feature/fruit/process_fruit = locate() in process_plant.plant_features
	process_fruit.process(60)
	TEST_ASSERT(locate(/datum/plant_feature/fruit/orange/blood) in process_plant.plant_features, "Cykl wzrostu (process) z krwią w tacy nie zmienił pomarańczy w krwistą")

// Stare odmiany (krwisty pomidor, złote jabłko, święty arbuz, trująca jagoda) wychodzą tylko z pieca, nie z odczynnika
	for(var/old_type in list(/datum/plant_feature/fruit/tomato, /datum/plant_feature/fruit/apple, /datum/plant_feature/fruit/watermelon, /datum/plant_feature/fruit/berry, /datum/plant_feature/fruit/berry/death))
		var/datum/plant_feature/fruit/old_fruit = new old_type()
		for(var/new_type in old_fruit.reagent_mutations)
			TEST_ASSERT(!(new_type in list(/datum/plant_feature/fruit/tomato/blood, /datum/plant_feature/fruit/apple/gold, /datum/plant_feature/fruit/watermelon/holy, /datum/plant_feature/fruit/berry/poison)), "[old_type] ma mutację od odczynnika do starej odmiany [new_type]")
		qdel(old_fruit)

// Regresja: uschnięta roślina nie mutuje i nie zużywa odczynnika
	var/obj/item/plant_tray/dead_tray = allocate(/obj/item/plant_tray, get_step(origin, NORTHEAST))
	var/datum/component/plant/dead_plant = plant_orange(dead_tray)
	TEST_ASSERT_NOTNULL(dead_plant, "Nie udało się posadzić czwartej pomarańczy")
	dead_tray.reagents.add_reagent(/datum/reagent/blood, 15)
	var/datum/plant_feature/body/dead_body = locate() in dead_plant.plant_features
	dead_body.health = -1
	var/datum/plant_feature/fruit/dead_fruit = locate() in dead_plant.plant_features
	TEST_ASSERT(isnull(dead_fruit.try_reagent_mutation(2, TRUE)), "Uschnięta pomarańcza zmutowała od krwi")
	TEST_ASSERT(dead_tray.reagents.get_reagent_amount(/datum/reagent/blood) >= 15, "Uschnięta pomarańcza zużyła krew")

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
