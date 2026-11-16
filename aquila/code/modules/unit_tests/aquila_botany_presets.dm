// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - każdy preset nasion rośnie w tacy, zawiązuje owoce i daje swój plon; ikony nasion, owocu i plonu istnieją
/datum/unit_test/aquila_botany_presets
	/// Presety, które celowo nie dają zwykłego plonu (owoc to mob, poczta, roślina ozdobna itp.)
	var/list/skip = list(
		/obj/item/plant_seeds/preset/kirby,
		/obj/item/plant_seeds/preset/diona_pod,
		/obj/item/plant_seeds/preset/killer_tomato,
		/obj/item/plant_seeds/preset/mail,
		// przekroczony budżet genetyczny: losowe potrzeby (krew, leki, toksyny) i cechy, których test nie odtwarza
		/obj/item/plant_seeds/preset/bs_banana,
		/obj/item/plant_seeds/preset/firelemon,
	)
	/// Abstrakcyjne presety pomijane tylko jako dokładny typ (ich podtypy test sprawdza)
	var/list/skip_exact = list(
		/obj/item/plant_seeds/preset/alien,
	)

/datum/unit_test/aquila_botany_presets/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/list/failures = list()
	for(var/seed_type in subtypesof(/obj/item/plant_seeds/preset))
		if(seed_type in skip_exact)
			continue
		var/skipped = FALSE
		for(var/skip_type in skip)
			if(ispath(seed_type, skip_type))
				skipped = TRUE
				break
		if(skipped)
			continue
		var/failure = check_preset(seed_type, origin, user)
		if(failure)
			failures += "[seed_type]: [failure]"
	TEST_ASSERT(!length(failures), "Presety z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// Zwraca opis błędu albo null
/datum/unit_test/aquila_botany_presets/proc/check_preset(seed_type, turf/origin, mob/living/carbon/human/user)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(tray))
	//Baśniowe podłoże pasuje do wszystkich korzeni lądowych, korzenie wodne rosną tylko w podłożu wodnym
	var/datum/plant_feature/roots/roots = locate() in seeds.plant_features
	planter.set_substrate((roots?.compatible_substrate & PLANT_SUBSTRATE_WATER) ? /datum/plant_subtrate/water : /datum/plant_subtrate/fairy)
	if(!icon_exists(seeds.icon, seeds.icon_state))
		return "brak ikony nasion [seeds.icon_state] w [seeds.icon]"
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!istype(plant))
		return "nie da się posadzić"
	plant.skip_growth = TRUE
	//Rośliny z przekroczonym budżetem genetycznym dostają losowe potrzeby; spełniamy wszystkie, jak w doniczkach na start rundy
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(tray)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	if(!fruit)
		return "brak cechy owocu"
	if(!icon_exists(fruit.icon, fruit.icon_state))
		return "brak ikony owocu [fruit.icon_state] w [fruit.icon]"
	for(var/i in 1 to 3)
		body?.process(2)
		fruit.process(2)
	if(!length(fruit.fruits))
		return "nie zawiązała owoców"
	var/expected = fruit.fruit_product
	fruit.catch_attack_hand(null, user)
	var/obj/item/product = locate(expected) in get_turf(user)
	if(!product)
		return "zbiór nie dał [expected]"
	if(!icon_exists(product.icon, product.icon_state))
		return "brak ikony plonu [product.icon_state] w [product.icon]"
	for(var/obj/item/leftover in get_turf(user))
		if(leftover != user && !(leftover in user))
			qdel(leftover)
	qdel(tray)
	return null

#undef TEST_ASSERT
