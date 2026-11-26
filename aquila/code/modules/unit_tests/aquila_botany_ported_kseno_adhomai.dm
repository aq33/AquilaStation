// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - rośliny z Adhomai w kapsule ksenoflory: w zwykłej tacce nie wschodzą, w kapsule na mrozie z gazem i odczynnikiem
/// rosną i owocują (plon ma ikonę), bez gazu/odczynnika albo w cieple stoją
/datum/unit_test/aquila_botany_kseno_adhomai

/datum/unit_test/aquila_botany_kseno_adhomai/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/pod_turf = locate(origin.x + 1, origin.y + 1, origin.z)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/list/failures = list()
	for(var/seed_type in valid_subtypesof(/obj/item/plant_seeds/preset/alien/xenoflora/adhomai))
		var/failure = check_plant(seed_type, pod_turf, user)
		if(failure)
			failures += "[seed_type]: [failure]"
	TEST_ASSERT(!length(failures), "Rośliny z Adhomai z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// Zwraca opis błędu albo null
/datum/unit_test/aquila_botany_kseno_adhomai/proc/check_plant(seed_type, turf/pod_turf, mob/living/carbon/human/user)
//Zwykła tacka: nasiona nie wschodzą
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, pod_turf)
	var/datum/component/planter/tray_planter = tray.GetComponent(/datum/component/planter)
	tray_planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	if(plant_in(seed_type, tray))
		return "dała się posadzić w zwykłej tacce"
	qdel(tray)

//Kapsuła ze spełnionymi wymaganiami: rośnie, owocuje, plon ma ikonę
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	var/datum/component/plant/plant = plant_in(seed_type, pod)
	if(!istype(plant))
		return "nie dała się posadzić w kapsule"
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	var/datum/plant_need/xenoflora/need = locate() in fruit.plant_needs
	if(!need)
		return "owoc nie ma potrzeby kapsuły"
	if(need.max_temperature >= T0C + 20)
		return "nie potrzebuje mrozu (do [need.max_temperature - T0C] °C)"
	if(!length(need.required_gases) && !length(need.required_reagents))
		return "nie potrzebuje gazu ani odczynnika"
	prepare_pod(pod, need, TRUE, TRUE)
	grow(body, fruit)
	if(body.current_stage < body.growth_stages)
		return "w kapsule ze spełnionymi wymaganiami nie urosła (etap [body.current_stage]/[body.growth_stages])"
	if(!length(fruit.fruits))
		return "w kapsule ze spełnionymi wymaganiami nie zawiązała owoców"
	var/expected = fruit.fruit_product
	fruit.catch_attack_hand(null, user)
	var/obj/item/product = locate(expected) in get_turf(user)
	if(!product)
		return "zbiór nie dał [expected]"
	if(!icon_exists(product.icon, product.icon_state))
		return "brak ikony plonu [product.icon_state] w [product.icon]"
	qdel(product)
	aquila_test_drop_pod(pod)

//Kapsuła na mrozie, ale bez gazu i odczynnika: nie rośnie
	pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	plant = plant_in(seed_type, pod)
	body = locate() in plant.plant_features
	fruit = locate() in plant.plant_features
	need = locate() in fruit.plant_needs
	prepare_pod(pod, need, FALSE, TRUE)
	grow(body, fruit)
	if(body.current_stage >= body.growth_stages || length(fruit.fruits))
		return "urosła w kapsule bez wymaganego gazu i odczynnika"
	aquila_test_drop_pod(pod)

//Kapsuła z gazem i odczynnikiem, ale w cieple: nie rośnie
	pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	plant = plant_in(seed_type, pod)
	body = locate() in plant.plant_features
	fruit = locate() in plant.plant_features
	need = locate() in fruit.plant_needs
	prepare_pod(pod, need, TRUE, FALSE)
	grow(body, fruit)
	if(body.current_stage >= body.growth_stages || length(fruit.fruits))
		return "urosła w kapsule w temperaturze pokojowej"
	aquila_test_drop_pod(pod)
	for(var/obj/item/leftover in get_turf(user))
		if(leftover != user && !(leftover in user))
			qdel(leftover)
	return null

/datum/unit_test/aquila_botany_kseno_adhomai/proc/plant_in(seed_type, atom/target)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(target))
	return seeds.plant(target, null, TRUE, null, TRUE)

/// Woda, a do tego (opcjonalnie) wymagane gazy i odczynniki oraz temperatura w środku zakresu albo pokojowa
/datum/unit_test/aquila_botany_kseno_adhomai/proc/prepare_pod(obj/machinery/atmospherics/components/binary/xenoflora_pod/pod, datum/plant_need/xenoflora/need, supplies, cold)
	pod.reagents.add_reagent(/datum/reagent/water, 200)
	var/temperature = cold ? (need.min_temperature + need.max_temperature) / 2 : T20C
	if(supplies)
		for(var/gas_id in need.required_gases)
			pod.internal_gases.set_moles(gas_id, 50)
		for(var/reagent in need.required_reagents)
			pod.reagents.add_reagent(reagent, 50)
	pod.internal_gases.set_temperature(temperature)
	pod.chamber_temperature = temperature
	pod.target_temperature = temperature

/// Kilka cykli wzrostu z czasami skróconymi do jednego cyklu
/datum/unit_test/aquila_botany_kseno_adhomai/proc/grow(datum/plant_feature/body/body, datum/plant_feature/fruit/fruit)
	body.growth_time = 1
	fruit.growth_time = 1
	for(var/i in 1 to 4)
		body.process(2)
		fruit.process(2)

/// AQUILA - plon dzikiej rośliny z Adhomai daje w siewniku nasiona wersji kapsułowej: korzenie ksenoflory i potrzeba kapsuły,
/// więc nie wschodzą w zwykłej tacce
/datum/unit_test/aquila_botany_kseno_adhomai_wild_seeds

/datum/unit_test/aquila_botany_kseno_adhomai_wild_seeds/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/turf/spot = get_step(origin, EAST)
	var/obj/structure/flora/ash/wulumunusha/flora = allocate(/obj/structure/flora/ash/wulumunusha, spot)
	var/datum/component/plant/plant = flora.GetComponent(/datum/component/plant)
	TEST_ASSERT(plant, "Dzikie pnącze wulumunuszy nie jest rośliną")
	plant.skip_growth = TRUE
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		TEST_ASSERT(!length(feature.plant_needs), "[feature.name] dzikiego pnącza wulumunuszy ma potrzeby, więc na planecie nie zaowocuje")
	for(var/i in 1 to 3)
		body?.process(2)
		fruit.process(2)
	TEST_ASSERT(length(fruit.fruits), "Dzikie pnącze wulumunuszy nie zawiązał owoców")
	flora.attack_hand(user)
	var/obj/item/food/grown/xenoflora/adhomai/wulumunusha/product = locate() in range(1, spot)
	TEST_ASSERT(product, "Zbiór dzikiego pnącza wulumunuszy nie dał owocu wulumunuszy")
	var/obj/machinery/seeder/seeder = allocate(/obj/machinery/seeder, get_step(origin, NORTH))
	seeder.attackby(product, user)
	var/obj/item/plant_seeds/seeds = locate() in get_turf(seeder)
	TEST_ASSERT(seeds, "Siewnik nie zrobił nasion z owocu wulumunuszy")
	TEST_ASSERT(locate(/datum/plant_feature/roots/xenoflora) in seeds.plant_features, "Nasiona z dzikiego owocu wulumunuszy nie mają korzeni ksenoflory")
	var/datum/plant_feature/fruit/seed_fruit = locate() in seeds.plant_features
	TEST_ASSERT(locate(/datum/plant_need/xenoflora/wulumunusha) in seed_fruit?.plant_needs, "Nasiona z dzikiego owocu wulumunuszy nie potrzebują kapsuły")
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, NORTHEAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	TEST_ASSERT(!seeds.plant(tray, null, TRUE, null, TRUE), "Nasiona z dzikiego owocu wulumunuszy wzeszły w zwykłej tacce")

#undef TEST_ASSERT
