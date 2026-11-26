// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// AQUILA - regresja: sok z bluespace'owej limony przerzuca tylko przy oblaniu, nie po wypiciu ani wstrzyknięciu
/datum/unit_test/aquila_limon_juice_methods

/datum/unit_test/aquila_limon_juice_methods/Run()
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/start = get_turf(drinker)
	var/datum/reagent/consumable/limonjuice/juice = new
	for(var/method in list(INGEST, INJECT, PATCH))
		juice.reaction_mob(drinker, method, 25)
		TEST_ASSERT(get_turf(drinker) == start, "Sok z limony przerzucił gracza przy metodzie [method] (tylko oblanie i opary)")
	qdel(juice)

/// AQUILA - regresja: losowe nasiona i Skarbiec DNA nie biorą presetów obcych (artefakty, ruiny, kapsuła) ani dzikich (struktury planet)
/datum/unit_test/aquila_random_seed_pool

/datum/unit_test/aquila_random_seed_pool/Run()
	TEST_ASSERT(length(GLOB.random_plant_seeds), "Pula losowych nasion jest pusta")
	TEST_ASSERT(/obj/item/plant_seeds/preset/tomato in GLOB.random_plant_seeds, "W puli losowych nasion nie ma pomidora")
	for(var/seed_type in GLOB.random_plant_seeds)
		TEST_ASSERT(!ispath(seed_type, /obj/item/plant_seeds/preset/alien), "Obce nasiona [seed_type] trafiają do losowych źródeł")
		TEST_ASSERT(!findtext("[seed_type]", "_wild"), "Dziki preset [seed_type] trafia do losowych źródeł")
	TEST_ASSERT(!(/obj/item/plant_seeds/preset/fjylozyn_wild in GLOB.random_plant_seeds), "Dziki fjylozyn trafia do losowych źródeł")
	TEST_ASSERT(!(/obj/item/plant_seeds/preset/star_cactus in GLOB.random_plant_seeds), "Gwiaździsty kaktus z planet trafia do losowych źródeł")
	TEST_ASSERT(/obj/item/plant_seeds/preset/glowshroom in GLOB.random_plant_seeds, "Glowshroom (rośnie też na stacji) wypadł z puli losowych nasion")
	var/datum/station_goal/dna_vault/vault = new
	TEST_ASSERT_EQUAL(vault.non_standard_plants_count(), length(GLOB.random_plant_seeds), "Skarbiec DNA liczy inne nasiona niż pula do zdobycia na stacji")
	qdel(vault)

/// AQUILA - regresja: wymagany odczynnik ksenoflory nie może być na liście toksyn łodygi (napalm pirytowej brzoskwini ją zabijał)
/datum/unit_test/aquila_xenoflora_reagents_not_toxic

/datum/unit_test/aquila_xenoflora_reagents_not_toxic/Run()
	var/datum/plant_need/reagent/buff/toxin/toxin_need = new()
	var/list/toxins = toxin_need.reagent_needs.Copy()
	qdel(toxin_need)
	TEST_ASSERT(length(toxins), "Lista toksyn łodygi jest pusta")
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large, run_loc_floor_bottom_left)
	var/list/failures = list()
	for(var/need_type in subtypesof(/datum/plant_need/xenoflora))
		var/datum/plant_need/xenoflora/need = new need_type()
		for(var/reagent in need.required_reagents)
			if(reagent in toxins)
				failures += "[need_type] wymaga [reagent], a to jest na liście toksyn łodygi: roślina truje się tym, czego potrzebuje"
			//Zbiornik kapsuły zawsze ma wodę: odczynnik, który z nią reaguje (potas wybucha, amoniak robi płyn czyszczący), nigdy w nim nie zostanie
			beaker.reagents.clear_reagents()
			beaker.reagents.add_reagent(/datum/reagent/water, 50)
			beaker.reagents.add_reagent(reagent, 10)
			if(beaker.reagents.get_reagent_amount(reagent) < 10)
				failures += "[need_type] wymaga [reagent], który reaguje z wodą w zbiorniku kapsuły"
		qdel(need)
	TEST_ASSERT(!length(failures), "Wymagania ksenoflory z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// AQUILA - regresja: w zestawach nasion części pasują do siebie według whitelist i blacklist (thaa'dra i Łza Messy miały owoc na krzewie kwiatowym)
/datum/unit_test/aquila_preset_feature_compatibility

/datum/unit_test/aquila_preset_feature_compatibility/Run()
	var/list/failures = list()
	for(var/obj/item/plant_seeds/preset/seed_type as anything in valid_subtypesof(/obj/item/plant_seeds/preset))
		var/obj/item/plant_seeds/seeds = new seed_type(null)
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			for(var/datum/plant_feature/other as anything in seeds.plant_features - feature)
				if(length(feature.whitelist_features) && !is_type_in_typecache(other, feature.whitelist_features))
					failures += "[seed_type]: [other.type] nie pasuje do whitelisty [feature.type]"
				if(is_type_in_typecache(other, feature.blacklist_features))
					failures += "[seed_type]: [other.type] jest na blackliście [feature.type]"
		QDEL_LIST(seeds.plant_features)
		qdel(seeds)
	TEST_ASSERT(!length(failures), "Niezgodne części w presetach ([length(failures)]):\n[jointext(failures, "\n")]")

/// AQUILA - regresja kapsuły ksenoflory: otwarta kopuła nie przepompowuje rury do pokoju, przesunięcie z kliknięcia nie gubi
/// przesunięcia kapsuły, rośliny nie dostają względnej warstwy, a kapsuła 2×2 nie staje na zablokowanych polach
/datum/unit_test/aquila_xenoflora_pod_fixes

/datum/unit_test/aquila_xenoflora_pod_fixes/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/pod_turf = locate(origin.x + 1, origin.y + 1, origin.z)
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	pod.reagents.add_reagent(/datum/reagent/water, 200)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/alien/xenoflora/broombush, pod_turf)
	var/datum/component/plant/plant = seeds.plant(pod, null, TRUE, "icon-x=50;icon-y=10", TRUE)
	TEST_ASSERT(istype(plant), "Miotlarz nie dał się posadzić w kapsule")
	var/obj/item/plant_item = plant.plant_item

//Przesunięcie z kliknięcia + przesunięcie kapsuły (16 px), a po wyjęciu samo przesunięcie z kliknięcia
	TEST_ASSERT_EQUAL(plant_item.pixel_x, 4 + 16, "Roślina posadzona kliknięciem zgubiła przesunięcie kapsuły")
	var/layer_inside = plant_item.layer
	plant_item.forceMove(origin)
	TEST_ASSERT_EQUAL(plant_item.pixel_x, 4, "Po wyjęciu z kapsuły roślina została przesunięta w bok")
	TEST_ASSERT_EQUAL(plant_item.layer, layer_inside, "Kapsuła zmienia warstwę rośliny względnie, więc po wyjęciu roślina ląduje pod tacą")
	qdel(plant_item)

//Otwarta kopuła: kapsuła nie dobiera gazu z rury wejściowej
	var/obj/item/plant_seeds/more_seeds = allocate(/obj/item/plant_seeds/preset/alien/xenoflora/broombush, pod_turf)
	TEST_ASSERT(istype(more_seeds.plant(pod, null, TRUE, null, TRUE), /datum/component/plant), "Drugi miotlarz nie dał się posadzić w kapsule")
	var/datum/gas_mixture/input = pod.airs[2]
	input.set_moles(GAS_N2, 100)
	input.set_temperature(T20C)
	pod.dome_extended = FALSE
	pod.process_atmos()
	TEST_ASSERT_EQUAL(input.get_moles(GAS_N2), 100, "Kapsuła z otwartą kopułą pobrała azot z rury (i wypuściła go do pomieszczenia)")
	input.set_moles(GAS_N2, 0)
	aquila_test_drop_pod(pod)

//Kapsuła 2×2 mieści się tylko na wolnych polach
	TEST_ASSERT(xenoflora_pod_fits(origin), "Kapsuła nie mieści się na wolnych polach testowych")
	allocate(/obj/structure/closet, locate(origin.x + 1, origin.y, origin.z))
	TEST_ASSERT(!xenoflora_pod_fits(origin), "Kapsuła mieści się na polach, na których stoi coś gęstego")

/// AQUILA - po usunięciu akwakultury surowe krewetki do przepisów kuchni kupuje się w konsoli zamówień
/datum/unit_test/aquila_kitchen_shrimp_source

/datum/unit_test/aquila_kitchen_shrimp_source/Run()
	var/found = FALSE
	for(var/datum/orderable_item/item as anything in subtypesof(/datum/orderable_item/kitchen_meat_dairy))
		if(initial(item.purchase_path) == /obj/item/food/shellfish_meat/shrimp)
			found = TRUE
			break
	TEST_ASSERT(found, "Konsola zamówień kuchni nie sprzedaje surowych krewetek, a przepisy z krewetkami nie mają innego źródła")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
