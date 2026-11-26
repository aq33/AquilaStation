// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - każda dzika roślina planet (/obj/structure/flora/ash) jest rośliną naszej botaniki: rośnie, daje się zebrać ręką,
/// a z plonu siewnik robi nasiona, które rosną w tacy. Ikony struktury, nasion i plonu istnieją.
/datum/unit_test/aquila_planet_wild_flora

/datum/unit_test/aquila_planet_wild_flora/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/list/failures = list()
	for(var/flora_type in typesof(/obj/structure/flora/ash))
		var/failure = check_flora(flora_type, origin, user)
		if(failure)
			failures += "[flora_type]: [failure]"
	TEST_ASSERT(!length(failures), "Dzikie rośliny z błędami ([length(failures)]):\n[jointext(failures, "\n")]")

/// Zwraca opis błędu albo null
/datum/unit_test/aquila_planet_wild_flora/proc/check_flora(flora_type, turf/origin, mob/living/carbon/human/user)
	var/turf/spot = get_step(origin, EAST)
	var/obj/structure/flora/ash/flora = allocate(flora_type, spot)
	if(!icon_exists(flora.icon, flora.icon_state))
		return "brak ikony struktury [flora.icon_state] w [flora.icon]"
	var/datum/component/plant/plant = flora.GetComponent(/datum/component/plant)
	if(!plant)
		return "struktura nie jest rośliną (brak komponentu plant)"
	plant.skip_growth = TRUE
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	if(!fruit)
		return "brak cechy owocu"
	//Dzika roślina nie ma zbiornika: rośliny z potrzebami (ogródki, lodowe chili z planet) rosną dopiero po wykopaniu łopatką
	//do tacy, więc dla nich sprawdzamy tylko, że są roślinami. Dzikie rośliny do zbioru ręką nie mają potrzeb (jak paproć jaskiniowa).
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		if(length(feature.plant_needs))
			qdel(flora)
			return null
	for(var/i in 1 to 3)
		body?.process(2)
		fruit.process(2)
	if(!length(fruit.fruits))
		return "nie zawiązała owoców"
	var/expected = fruit.fruit_product
	flora.attack_hand(user)
	var/obj/item/product = locate(expected) in range(1, spot)
	if(!product)
		return "zbiór ręką nie dał [expected]"
	if(!icon_exists(product.icon, product.icon_state))
		return "brak ikony plonu [product.icon_state] w [product.icon]"
	// Nasiona z plonu przez siewnik
	var/obj/machinery/seeder/seeder = allocate(/obj/machinery/seeder, get_step(origin, NORTH))
	seeder.attackby(product, user)
	var/obj/item/plant_seeds/seeds = locate() in get_turf(seeder)
	if(!seeds)
		return "siewnik nie zrobił nasion z plonu [expected]"
	if(!icon_exists(seeds.icon, seeds.icon_state))
		return "brak ikony nasion [seeds.icon_state] w [seeds.icon]"
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, NORTHEAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	var/datum/plant_feature/roots/roots = locate() in seeds.plant_features
	//Plon dzikiej ksenoflory (np. rośliny z Adhomai) daje nasiona do kapsuły: jej podłoże przyjmuje każde korzenie
	if(roots && (roots.compatible_substrate & PLANT_SUBSTRATE_XENOFLORA))
		planter.set_substrate(/datum/plant_subtrate/xenoflora)
	if(!istype(seeds.plant(tray, null, TRUE, null, TRUE), /datum/component/plant))
		return "nasion z plonu nie da się posadzić w tacy"
	var/turf/seeder_turf = get_turf(seeder)
	for(var/atom/movable/leftover in range(1, spot) + seeder_turf.contents)
		if(leftover != user && !ismob(leftover) && !QDELETED(leftover))
			qdel(leftover)
	qdel(seeder)
	return null

/// AQUILA - losowa cecha dzikiej rośliny nie przekracza budżetu: paproć jaskiniowa (bez własnych potrzeb) nigdy nie dostaje potrzeby
/datum/unit_test/aquila_planet_wild_flora_budget

/datum/unit_test/aquila_planet_wild_flora_budget/Run()
	var/turf/spot = get_step(run_loc_floor_bottom_left, EAST)
	for(var/i in 1 to 20)
		var/obj/structure/flora/ash/fern/fern = allocate(/obj/structure/flora/ash/fern, spot)
		var/datum/component/plant/plant = fern.GetComponent(/datum/component/plant)
		for(var/datum/plant_feature/feature as anything in plant.plant_features)
			TEST_ASSERT(feature.remaining_genetic_budget >= 0, "[feature.name] dzikiej paproci przekroczyła budżet ([feature.remaining_genetic_budget])")
			TEST_ASSERT(!length(feature.plant_needs), "[feature.name] dzikiej paproci dostała potrzebę z losowej cechy, więc na planecie nie zaowocuje")
		qdel(fern)

#undef TEST_ASSERT
