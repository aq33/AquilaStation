// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - rośliny obcych ras z Baya (ksenoflora_rasy.dm): każda rośnie i owocuje w kapsule ze swoimi warunkami, bez dowolnego z wymaganych gazów lub odczynników stoi, a w zwykłej tacce nie da się jej zasadzić
/datum/unit_test/aquila_botany_kseno_rasy

/datum/unit_test/aquila_botany_kseno_rasy/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/pod_turf = locate(origin.x + 1, origin.y + 1, origin.z)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, locate(origin.x + 4, origin.y, origin.z))
	var/datum/component/planter/tray_planter = tray.GetComponent(/datum/component/planter)
	tray_planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)

	for(var/seed_type in valid_subtypesof(/obj/item/plant_seeds/preset/alien/xenoflora/rasy))
		//Zwykła tacka: nasiona nie wschodzą
		TEST_ASSERT(!plant_seeds(seed_type, tray), "[seed_type] dał się posadzić w zwykłej tacce")
		TEST_ASSERT(!length(tray_planter.plants), "[seed_type]: w zwykłej tacce pojawiła się ksenoflora")

		//Wszystkie warunki spełnione: rośnie, owocuje, zjada swoje, plon ma ikonę
		var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
		var/datum/component/plant/plant = plant_seeds(seed_type, pod)
		TEST_ASSERT(istype(plant), "[seed_type] nie dał się posadzić w kapsule")
		var/datum/plant_need/xenoflora/need = find_need(plant)
		TEST_ASSERT(need, "[seed_type] nie ma wymagań kapsuły")
		var/list/requirements = list()
		for(var/gas_id in need.required_gases)
			requirements += gas_id
		for(var/reagent in need.required_reagents)
			requirements += reagent
		TEST_ASSERT(length(requirements), "[seed_type] nie wymaga żadnego gazu ani odczynnika")
		fill_pod(pod, need)
		var/datum/plant_feature/body/body = locate() in plant.plant_features
		var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
		grow(body, fruit)
		TEST_ASSERT(body.current_stage >= body.growth_stages, "[seed_type] w kapsule z warunkami nie urósł (etap [body.current_stage]/[body.growth_stages])")
		TEST_ASSERT(length(fruit.fruits), "[seed_type] w kapsule z warunkami nie zawiązał owoców")
		for(var/gas_id in need.required_gases)
			TEST_ASSERT(pod.internal_gases.get_moles(gas_id) < 50, "[seed_type] nie zużył gazu [gas_id]")
		var/product_type = fruit.fruit_product
		fruit.catch_attack_hand(null, user)
		var/obj/item/product = locate(product_type) in get_turf(user)
		TEST_ASSERT(product, "Zbiór [seed_type] nie dał plonu [product_type]")
		TEST_ASSERT(icon_exists(product.icon, product.icon_state), "Plon [product_type] nie ma ikony [product.icon_state]")
		for(var/obj/item/leftover in get_turf(user))
			qdel(leftover)
		qdel(pod)

		//Bez każdego z wymagań po kolei: ani wzrostu, ani owoców
		for(var/missing in requirements)
			pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
			plant = plant_seeds(seed_type, pod)
			TEST_ASSERT(istype(plant), "[seed_type] nie dał się posadzić w kolejnej kapsule")
			need = find_need(plant)
			fill_pod(pod, need, missing)
			body = locate() in plant.plant_features
			fruit = locate() in plant.plant_features
			grow(body, fruit)
			//Łodyżka kwiatu ma jeden etap, więc stoi od razu; wtedy liczą się tylko owoce
			TEST_ASSERT(body.growth_stages <= 1 || body.current_stage < body.growth_stages, "[seed_type] urósł w kapsule bez [missing]")
			TEST_ASSERT(!length(fruit.fruits), "[seed_type] zawiązał owoce w kapsule bez [missing]")
			qdel(pod)

/datum/unit_test/aquila_botany_kseno_rasy/proc/plant_seeds(seed_type, atom/target)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(target))
	return seeds.plant(target, null, TRUE, null, TRUE)

/datum/unit_test/aquila_botany_kseno_rasy/proc/find_need(datum/component/plant/plant)
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/xenoflora/need in feature.plant_needs)
			return need

/// Woda, gazy i odczynniki rośliny z zapasem, temperatura w środku jej zakresu; missing pomija jedno wymaganie
/datum/unit_test/aquila_botany_kseno_rasy/proc/fill_pod(obj/machinery/atmospherics/components/binary/xenoflora_pod/pod, datum/plant_need/xenoflora/need, missing)
	if(missing != /datum/reagent/water)
		pod.reagents.add_reagent(/datum/reagent/water, 200)
	for(var/reagent in need.required_reagents)
		if(reagent != missing && reagent != /datum/reagent/water)
			pod.reagents.add_reagent(reagent, 50)
	for(var/gas_id in need.required_gases)
		if(gas_id != missing)
			pod.internal_gases.set_moles(gas_id, 50)
	var/temperature = (need.min_temperature + need.max_temperature) / 2
	pod.target_temperature = temperature
	pod.chamber_temperature = temperature
	pod.internal_gases.set_temperature(temperature)

/// Kilka cykli wzrostu z czasami skróconymi do jednego cyklu
/datum/unit_test/aquila_botany_kseno_rasy/proc/grow(datum/plant_feature/body/body, datum/plant_feature/fruit/fruit)
	body.growth_time = 1
	fruit.growth_time = 1
	for(var/i in 1 to 4)
		body.process(2)
		fruit.process(2)

#undef TEST_ASSERT
