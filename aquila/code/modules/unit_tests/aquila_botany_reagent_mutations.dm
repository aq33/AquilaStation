// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }

/// AQUILA - mutacje od odczynnika: pomidor z krwią w tacy zmienia się w krwisty pomidor i zużywa krew, bez krwi zostaje pomidorem
/datum/unit_test/aquila_botany_reagent_mutations

/// Testowy zestaw dopisków: pomidor dostaje drugą mutację od odczynnika (mleko) i mutację w piecu, obok tych z własnej listy
/datum/plant_mutation_set/unit_test
	mutations = list(/datum/plant_feature/fruit/tomato = list(/datum/plant_feature/fruit/tomato/friendly = 5))
	reagent_mutations = list(/datum/plant_feature/fruit/tomato = list(/datum/plant_feature/fruit/tomato/blue = list(/datum/reagent/consumable/milk = 10)))

/datum/unit_test/aquila_botany_reagent_mutations/proc/plant_tomato(obj/item/plant_tray/tray)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.reagents.add_reagent(/datum/reagent/water, 100)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/tomato, get_turf(tray))
	return seeds.plant(tray, null, TRUE, null, TRUE)

/datum/unit_test/aquila_botany_reagent_mutations/Run()
	var/turf/origin = run_loc_floor_bottom_left

// Bez krwi nic się nie dzieje
	var/obj/item/plant_tray/plain_tray = allocate(/obj/item/plant_tray, origin)
	var/datum/component/plant/plain = plant_tomato(plain_tray)
	TEST_ASSERT_NOTNULL(plain, "Nie udało się posadzić pomidora")
	var/datum/plant_feature/fruit/plain_fruit = locate() in plain.plant_features
	TEST_ASSERT(isnull(plain_fruit.try_reagent_mutation(2, TRUE)), "Pomidor zmutował bez krwi w tacy")

// Dopiski z /datum/plant_mutation_set nie kasują własnych list pomidora
	TEST_ASSERT(plain_fruit.reagent_mutations[/datum/plant_feature/fruit/tomato/blood], "Dopisek z zestawu skasował własną mutację pomidora od krwi")
	TEST_ASSERT(plain_fruit.reagent_mutations[/datum/plant_feature/fruit/tomato/blue], "Brak mutacji od mleka dopisanej przez zestaw")
	TEST_ASSERT((/datum/plant_feature/fruit/tomato/blood in plain_fruit.mutations) && (/datum/plant_feature/fruit/tomato/friendly in plain_fruit.mutations), "Mutacje w piecu: zestaw skasował własne albo nie dopisał nowej")
	var/datum/plant_feature/fruit/blue_tomato = new /datum/plant_feature/fruit/tomato/blue()
	TEST_ASSERT(!(/datum/plant_feature/fruit/tomato/friendly in blue_tomato.mutations), "Dopisek dla pomidora trafił też do jego odmiany")
	qdel(blue_tomato)

// Z krwią zmienia się w krwisty pomidor
	var/obj/item/plant_tray/blood_tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/plant/plant = plant_tomato(blood_tray)
	TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić drugiego pomidora")
	blood_tray.reagents.add_reagent(/datum/reagent/blood, 15)
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	var/datum/plant_feature/new_feature = fruit.try_reagent_mutation(2, TRUE)
	TEST_ASSERT_NOTNULL(new_feature, "Pomidor z krwią w tacy nie zmutował")
	TEST_ASSERT(istype(new_feature, /datum/plant_feature/fruit/tomato/blood), "Pomidor z krwią zmienił się w [new_feature.type] zamiast w krwisty pomidor")
	TEST_ASSERT(new_feature in plant.plant_features, "Nowa część nie trafiła do rośliny")
	TEST_ASSERT(QDELETED(fruit), "Stara część owocu nie została usunięta")
	TEST_ASSERT(blood_tray.reagents.get_reagent_amount(/datum/reagent/blood) <= 5, "Mutacja nie zużyła krwi (zostało [blood_tray.reagents.get_reagent_amount(/datum/reagent/blood)] j.)")

// Krwisty pomidor z krwią nie mutuje sam w siebie
	blood_tray.reagents.add_reagent(/datum/reagent/blood, 15)
	var/datum/plant_feature/fruit/blood_fruit = new_feature
	TEST_ASSERT(isnull(blood_fruit.try_reagent_mutation(2, TRUE)), "Krwisty pomidor zmutował sam w siebie")

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
