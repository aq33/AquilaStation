// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - ksenoflora od gazów (ksenoflora_gazowe.dm i trzy rośliny przeniesione z tacki): w zwykłej tacce nie wschodzi,
/// w kapsule ze spełnionymi wymaganiami rośnie i owocuje, a bez wymaganego gazu stoi
/datum/unit_test/aquila_botany_kseno_gazowe
	var/list/seed_types = list(
		/obj/item/plant_seeds/preset/alien/xenoflora/vaporsac,
		/obj/item/plant_seeds/preset/alien/xenoflora/plasma,
		/obj/item/plant_seeds/preset/alien/xenoflora/crystal,
		/obj/item/plant_seeds/preset/alien/xenoflora/breather,
		/obj/item/plant_seeds/preset/alien/xenoflora/resin,
		/obj/item/plant_seeds/preset/alien/xenoflora/plasma_cabbage,
		/obj/item/plant_seeds/preset/alien/xenoflora/livewire_orange,
		/obj/item/plant_seeds/preset/alien/xenoflora/nuclear_orange,
	)

/datum/unit_test/aquila_botany_kseno_gazowe/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/pod_turf = locate(origin.x + 1, origin.y + 1, origin.z)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/list/failures = list()
	for(var/seed_type in seed_types)
		var/failure = check_plant(seed_type, pod_turf, user)
		if(failure)
			failures += "[seed_type]: [failure]"
	TEST_ASSERT(!length(failures), "Ksenoflora z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// Zwraca opis błędu albo null
/datum/unit_test/aquila_botany_kseno_gazowe/proc/check_plant(seed_type, turf/pod_turf, mob/living/carbon/human/user)
//Zwykła tacka z podłożem wróżkowym: nasiona nie wschodzą
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, pod_turf)
	var/datum/component/planter/tray_planter = tray.GetComponent(/datum/component/planter)
	tray_planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, pod_turf)
	if(seeds.plant(tray, null, TRUE, null, TRUE) || length(tray_planter.plants))
		return "dała się posadzić w zwykłej tacce"
	qdel(tray)

//Kapsuła ze spełnionymi wymaganiami: rośnie, owocuje, zużywa gaz, plon ma ikonę
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	var/datum/component/plant/plant = plant_in(seed_type, pod)
	if(!istype(plant))
		return "nie da się posadzić w kapsule"
	var/datum/plant_need/xenoflora/need = get_need(plant)
	if(!need || !length(need.required_gases))
		return "brak potrzeby ksenoflory z wymaganym gazem"
	setup_pod(pod, need, TRUE)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	grow(body, fruit)
	if(body.current_stage < body.growth_stages)
		return "nie urosła w kapsule ze spełnionymi wymaganiami (etap [body.current_stage]/[body.growth_stages])"
	if(!length(fruit.fruits))
		return "nie zawiązała owoców w kapsule ze spełnionymi wymaganiami"
	for(var/gas_id in need.required_gases)
		if(pod.internal_gases.get_moles(gas_id) >= 50)
			return "nie zużyła gazu [gas_id]"
	var/expected = fruit.fruit_product
	fruit.catch_attack_hand(null, user)
	var/obj/item/product = locate(expected) in get_turf(user)
	if(!product)
		return "zbiór nie dał [expected]"
	if(!icon_exists(product.icon, product.icon_state))
		return "brak ikony plonu [product.icon_state] w [product.icon]"
	for(var/obj/item/leftover in get_turf(user))
		qdel(leftover)
	qdel(pod)

//Kapsuła bez wymaganego gazu (odczynniki i temperatura w porządku): ani wzrostu, ani owoców
	pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	plant = plant_in(seed_type, pod)
	if(!istype(plant))
		return "nie da się posadzić w drugiej kapsule"
	setup_pod(pod, get_need(plant), FALSE)
	body = locate() in plant.plant_features
	fruit = locate() in plant.plant_features
	grow(body, fruit)
	if(body.current_stage >= body.growth_stages)
		return "urosła w kapsule bez wymaganego gazu"
	if(length(fruit.fruits))
		return "zawiązała owoce w kapsule bez wymaganego gazu"
	qdel(pod)

/datum/unit_test/aquila_botany_kseno_gazowe/proc/plant_in(seed_type, atom/target)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(target))
	return seeds.plant(target, null, TRUE, null, TRUE)

/datum/unit_test/aquila_botany_kseno_gazowe/proc/get_need(datum/component/plant/plant)
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		var/datum/plant_need/xenoflora/need = locate() in feature.plant_needs
		if(need)
			return need

/// Woda, odczynniki i temperatura z wymagań rośliny; gazy tylko gdy with_gases
/datum/unit_test/aquila_botany_kseno_gazowe/proc/setup_pod(obj/machinery/atmospherics/components/binary/xenoflora_pod/pod, datum/plant_need/xenoflora/need, with_gases)
	pod.reagents.add_reagent(/datum/reagent/water, 200)
	for(var/reagent in need.required_reagents)
		pod.reagents.add_reagent(reagent, 50)
	var/temperature = (need.min_temperature + need.max_temperature) / 2
	pod.target_temperature = temperature
	pod.chamber_temperature = temperature
	if(with_gases)
		for(var/gas_id in need.required_gases)
			pod.internal_gases.set_moles(gas_id, 50)
	pod.internal_gases.set_temperature(temperature)

/// Kilka cykli wzrostu z czasami skróconymi do jednego cyklu
/datum/unit_test/aquila_botany_kseno_gazowe/proc/grow(datum/plant_feature/body/body, datum/plant_feature/fruit/fruit)
	body.growth_time = 1
	fruit.growth_time = 1
	for(var/i in 1 to 4)
		body.process(2)
		fruit.process(2)

#undef TEST_ASSERT
