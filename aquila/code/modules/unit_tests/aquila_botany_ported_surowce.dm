// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - rośliny-surowce (surowce.dm) nie mają gotowych nasion: każda ma ścieżkę mutacji z istniejącej rośliny,
/// po mutacji rośnie na ciele rodzica, daje swój plon i najwyżej harvest_cap sztuk z jednego zbioru
/datum/unit_test/aquila_botany_ported_surowce
	/// Nasiona rośliny, od której zaczyna się dana gałąź (cecha owocu = gotowe nasiona rodzica w łańcuchu)
	var/list/start_seeds = list(
		/datum/plant_feature/fruit/wheat/meat = /obj/item/plant_seeds/preset/meat,
		/datum/plant_feature/fruit/apple = /obj/item/plant_seeds/preset/apple,
		/datum/plant_feature/fruit/cactus = /obj/item/plant_seeds/preset/cactus,
	)

/datum/unit_test/aquila_botany_ported_surowce/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	// Kto z czego mutuje: piec albo odczynnik
	var/list/parents = list()
	var/list/to_visit = list()
	for(var/start_type in start_seeds)
		to_visit += start_type
	while(length(to_visit))
		var/parent_type = to_visit[1]
		to_visit.Cut(1, 2)
		var/datum/plant_feature/fruit/parent_fruit = new parent_type()
		var/list/children = list()
		for(var/child in parent_fruit.mutations)
			children += child
		for(var/child in parent_fruit.reagent_mutations)
			children += child
		qdel(parent_fruit)
		for(var/child in children)
			if(!ispath(child, /datum/plant_feature/fruit/surowce) || parents[child])
				continue
			parents[child] = parent_type
			to_visit += child
	var/list/failures = list()
	for(var/fruit_type in subtypesof(/datum/plant_feature/fruit/surowce))
		var/datum/plant_feature/fruit/surowce/fruit_path = fruit_type
		if(fruit_type == initial(fruit_path.abstract_type))
			continue
		if(!parents[fruit_type])
			failures += "[fruit_type]: żadna roślina nie mutuje w tę odmianę"
			continue
		var/failure = check_fruit(fruit_type, parents, origin, user)
		if(failure)
			failures += "[fruit_type]: [failure]"
	TEST_ASSERT(!length(failures), "Rośliny-surowce z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// Sadzi początek gałęzi, podmienia owoc na badaną odmianę, zbiera. Zwraca opis błędu albo null
/datum/unit_test/aquila_botany_ported_surowce/proc/check_fruit(fruit_type, list/parents, turf/origin, mob/living/carbon/human/user)
	var/start_type = fruit_type
	while(parents[start_type])
		start_type = parents[start_type]
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = allocate(start_seeds[start_type], get_turf(tray))
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!istype(plant))
		return "nie da się posadzić [start_seeds[start_type]]"
	plant.skip_growth = TRUE
	var/datum/plant_feature/fruit/old_fruit = locate() in plant.plant_features
	var/datum/plant_feature/fruit/surowce/fruit = plant.mutate_feature(old_fruit, fruit_type)
	if(!istype(fruit))
		return "nie pasuje do pozostałych części rośliny [start_seeds[start_type]]"
	if(!icon_exists(fruit.icon, fruit.icon_state))
		return "brak ikony owocu [fruit.icon_state] w [fruit.icon]"
	if(!icon_exists(fruit.seed_icon, fruit.seed_icon_state))
		return "brak ikony nasion [fruit.seed_icon_state] w [fruit.seed_icon]"
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(tray)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	// Usunięcie starego owocu liczy się jak zbiór i włącza przerwę między plonami; test nie czeka na nią
	COOLDOWN_RESET(body, yield_cooldown)
	for(var/i in 1 to 3)
		body?.process(2)
		fruit.process(2)
	if(!length(fruit.fruits))
		return "nie zawiązała owoców"
	var/expected = istype(fruit, /datum/plant_feature/fruit/surowce/synth_organ/limb) ? /obj/item/bodypart : fruit.fruit_product
	fruit.catch_attack_hand(null, user)
	var/turf/harvest_turf = get_turf(user)
	var/atom/movable/product = locate(expected) in harvest_turf
	. = null
	if(!product)
		. = "zbiór nie dał [expected]"
	else if(!icon_exists(product.icon, product.icon_state))
		. = "brak ikony plonu [product.icon_state] w [product.icon]"
	else
		var/count = 0
		for(var/atom/movable/harvested in harvest_turf)
			if(istype(harvested, expected))
				var/obj/item/stack/stack = harvested
				count += istype(stack) ? stack.amount : 1
		if(count > fruit.harvest_cap)
			. = "zbiór dał [count] sztuk, a limit to [fruit.harvest_cap]"
		else if(body.max_harvest > 1 && count != min(body.max_harvest, fruit.harvest_cap))
			. = "zbiór z [body.max_harvest] owoców dał [count] sztuk zamiast [min(body.max_harvest, fruit.harvest_cap)]"
	for(var/atom/movable/leftover in harvest_turf)
		if(leftover != user && !(leftover in user) && (isitem(leftover) || isanimal(leftover)))
			qdel(leftover)
	qdel(tray)

#undef TEST_ASSERT
