// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - rośliny z tg dostępne tylko z mutacji: każda jest na liście mutacji rodzica, pasuje do jego części, rośnie i daje swój plon
/datum/unit_test/aquila_botany_ported_tg
	/// list(preset rodzica = list(kolejne mutacje owocu))
	var/list/chains = list(
		/obj/item/plant_seeds/preset/peas = list(/datum/plant_feature/fruit/peas/laugh, /datum/plant_feature/fruit/peas/peace),
		/obj/item/plant_seeds/preset/greenbean = list(/datum/plant_feature/fruit/greenbean/jump),
		/obj/item/plant_seeds/preset/soybean = list(/datum/plant_feature/fruit/soybean/butter),
		/obj/item/plant_seeds/preset/rose = list(/datum/plant_feature/fruit/flower/rose/carbon),
		/obj/item/plant_seeds/preset/plum = list(/datum/plant_feature/fruit/plum/plumb),
		/obj/item/plant_seeds/preset/corn = list(/datum/plant_feature/fruit/corn/pepper),
		/obj/item/plant_seeds/preset/geranium = list(/datum/plant_feature/fruit/flower/fraxinella),
		/obj/item/plant_seeds/preset/korta_nut = list(/datum/plant_feature/fruit/korta_nut/sweet),
		/obj/item/plant_seeds/preset/sugarcane = list(/datum/plant_feature/fruit/sugarcane/salt),
		/obj/item/plant_seeds/preset/watermelon = list(/datum/plant_feature/fruit/watermelon/barrel),
		/obj/item/plant_seeds/preset/whitebeet = list(/datum/plant_feature/fruit/whitebeet/red),
		/obj/item/plant_seeds/preset/cannabis = list(/datum/plant_feature/fruit/cannabis/anti),
	)

/datum/unit_test/aquila_botany_ported_tg/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/list/failures = list()
	for(var/seed_type in chains)
		var/failure = check_chain(seed_type, chains[seed_type], origin, user)
		if(failure)
			failures += "[seed_type]: [failure]"
	TEST_ASSERT(!length(failures), "Mutacje z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// Zwraca opis błędu albo null
/datum/unit_test/aquila_botany_ported_tg/proc/check_chain(seed_type, list/chain, turf/origin, mob/living/carbon/human/user)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(tray))
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!istype(plant))
		return "nie da się posadzić rodzica"
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	for(var/new_type in chain)
		if(!(new_type in fruit.mutations))
			return "[fruit.type] nie ma na liście mutacji [new_type]"
		fruit = plant.mutate_feature(fruit, new_type)
		if(!istype(fruit, new_type))
			return "[new_type] nie pasuje do pozostałych części rośliny"
	if(!icon_exists(fruit.icon, fruit.icon_state))
		return "brak ikony owocu [fruit.icon_state] w [fruit.icon]"
	if(!icon_exists(fruit.seed_icon, fruit.seed_icon_state))
		return "brak ikony nasion [fruit.seed_icon_state] w [fruit.seed_icon]"
	plant.skip_growth = TRUE
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(tray)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	//Usunięcie starego owocu przy mutacji startuje przerwę między plonami; test nie czeka prawdziwego czasu
	if(body)
		COOLDOWN_RESET(body, yield_cooldown)
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
