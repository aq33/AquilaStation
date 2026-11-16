// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, message) if (isnull(a)) { return Fail("Expected non-null value: [message || "No message"]") }

/// AQUILA - sadzi preset w tacy na podanym kafelku i doprowadza roślinę do dojrzałości (z owocami), zwraca komponent rośliny
/proc/aquila_obce_grow_plant(datum/unit_test/test, seed_type, turf/where)
	var/obj/item/plant_tray/tray = test.allocate(/obj/item/plant_tray, where)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = test.allocate(seed_type, where)
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!istype(plant))
		return
	plant.skip_growth = TRUE
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(tray)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	for(var/i in 1 to 3)
		body?.process(2)
		fruit?.process(2)
	return plant

/// Zwraca cechę danego typu z ciała rośliny
/proc/aquila_obce_body_trait(datum/component/plant/plant, trait_type)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	return locate(trait_type) in body?.plant_traits

/// AQUILA - artefakt z cechą Seeding wyrzuca nasiono obcej rośliny, które da się posadzić; w czasie przerwy nie wyrzuca kolejnego
/datum/unit_test/aquila_xenoa_seeding

/datum/unit_test/aquila_xenoa_seeding/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/item/xenoartifact/no_traits/artifact = allocate(/obj/item/xenoartifact/no_traits, origin)
	var/datum/component/xenoartifact/artifact_component = artifact.AddComponent(/datum/component/xenoartifact, XENOA_BLUESPACE, list(/datum/xenoartifact_trait/major/seeding), TRUE, FALSE, FALSE)
	TEST_ASSERT_NOTNULL(artifact_component, "Artefakt nie dostał komponentu")
	artifact_component.trigger(TRUE)
	var/list/found = list()
	for(var/obj/item/plant_seeds/preset/alien/seeds in origin)
		found += seeds
	TEST_ASSERT(length(found) == 1, "Aktywacja dała [length(found)] nasion obcych roślin zamiast jednego")
	var/obj/item/plant_seeds/preset/alien/seeds = found[1]
	TEST_ASSERT(seeds.type != seeds.abstract_type, "Artefakt wyrzucił abstrakcyjny typ nasion")
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/fairy)
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	TEST_ASSERT(istype(plant), "Nasiona [seeds.type] z artefaktu nie dają się posadzić")
	artifact_component.trigger(TRUE)
	var/count = 0
	//Paczka z pierwszej aktywacji może zostać na kafelku (ma kilka nasion), liczą się tylko nowe
	for(var/obj/item/plant_seeds/preset/alien/more_seeds in origin)
		if(more_seeds != seeds)
			count++
	TEST_ASSERT(count == 0, "Artefakt wyrzucił kolejne nasiono w czasie przerwy")
	for(var/obj/item/leftover in origin)
		if(leftover != artifact)
			qdel(leftover)

/// AQUILA - pełzacz zasiewa się w sąsiedniej pustej tacy
/datum/unit_test/aquila_botany_obce_creeper

/datum/unit_test/aquila_botany_obce_creeper/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/old_spreads = GLOB.aquila_creeper_spreads
	GLOB.aquila_creeper_spreads = 0
	var/datum/component/plant/creeper = aquila_obce_grow_plant(src, /obj/item/plant_seeds/preset/alien/creeper, origin)
	TEST_ASSERT(istype(creeper), "Pełzacza nie da się posadzić")
	var/obj/item/plant_tray/empty_tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/planter/empty_planter = empty_tray.GetComponent(/datum/component/planter)
	empty_planter.set_substrate(/datum/plant_subtrate/fairy)
	var/datum/plant_trait/body/alien_periodic/creeper/trait = aquila_obce_body_trait(creeper, /datum/plant_trait/body/alien_periodic/creeper)
	TEST_ASSERT_NOTNULL(trait, "Pełzacz nie ma cechy Rozrastanie")
	TEST_ASSERT(trait.can_act(), "Dojrzały pełzacz w tacy nie może działać")
	trait.periodic_effect()
	GLOB.aquila_creeper_spreads = old_spreads
	TEST_ASSERT(length(empty_planter.plants) == 1, "Pełzacz nie zasiał się w sąsiedniej pustej tacy")
	var/datum/component/plant/child = empty_planter.plants[1]
	TEST_ASSERT(aquila_obce_body_trait(child, /datum/plant_trait/body/alien_periodic/creeper), "W sąsiedniej tacy wyrósł nie pełzacz")
	TEST_ASSERT(trait.spreads_left == 1, "Pełzaczowi nie ubyło rozsiewów")

/// AQUILA - ludożerca gryzie dotykającego
/datum/unit_test/aquila_botany_obce_maneater

/datum/unit_test/aquila_botany_obce_maneater/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/datum/component/plant/maneater = aquila_obce_grow_plant(src, /obj/item/plant_seeds/preset/alien/maneater, get_step(origin, EAST))
	TEST_ASSERT(istype(maneater), "Ludożercy nie da się posadzić")
	SEND_SIGNAL(maneater.plant_item, COMSIG_ATOM_ATTACK_HAND, user)
	TEST_ASSERT(user.getBruteLoss() > 0, "Ludożerca nie ugryzł dotykającego")

/// AQUILA - rzygacz wymiotuje na podłogę, ciekacz kapie odczynnikiem z owocu, lotos świeci
/datum/unit_test/aquila_botany_obce_periodic

/datum/unit_test/aquila_botany_obce_periodic/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/puker_turf = get_step(origin, NORTH)
	var/datum/component/plant/puker = aquila_obce_grow_plant(src, /obj/item/plant_seeds/preset/alien/puker, puker_turf)
	TEST_ASSERT(istype(puker), "Rzygacza nie da się posadzić")
	var/datum/plant_trait/body/alien_periodic/puker/puke = aquila_obce_body_trait(puker, /datum/plant_trait/body/alien_periodic/puker)
	TEST_ASSERT(puke?.can_act(), "Dojrzały rzygacz w tacy nie może działać")
	puke.periodic_effect()
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/vomit) in puker_turf, "Rzygacz nie zwymiotował na podłogę")

	var/datum/component/plant/dripper = aquila_obce_grow_plant(src, /obj/item/plant_seeds/preset/alien/dripper, get_step(origin, EAST))
	TEST_ASSERT(istype(dripper), "Ciekacza nie da się posadzić")
	var/datum/plant_feature/fruit/fruit = locate() in dripper.plant_features
	TEST_ASSERT(length(fruit?.fruits), "Ciekacz nie zawiązał owoców")
	var/obj/item/first_fruit = fruit.fruits[1]
	var/before = first_fruit.reagents.total_volume
	var/datum/plant_trait/body/alien_periodic/dripper/drip = aquila_obce_body_trait(dripper, /datum/plant_trait/body/alien_periodic/dripper)
	drip.periodic_effect()
	TEST_ASSERT(first_fruit.reagents.total_volume < before, "Z owocu ciekacza nic nie skapnęło")

	var/datum/component/plant/lotus = aquila_obce_grow_plant(src, /obj/item/plant_seeds/preset/alien/lotus, get_step(get_step(origin, EAST), NORTH))
	TEST_ASSERT(istype(lotus), "Lotosu nie da się posadzić")
	var/datum/plant_trait/body/alien_periodic/glow/glow = aquila_obce_body_trait(lotus, /datum/plant_trait/body/alien_periodic/glow)
	glow.process(2)
	TEST_ASSERT(lotus.plant_item.light_range > 0, "Dojrzały lotos świetlny nie świeci")

/// AQUILA - podglądacz obraca się w stronę przechodzącego
/datum/unit_test/aquila_botany_obce_peeker

/datum/unit_test/aquila_botany_obce_peeker/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/peeker_turf = locate(origin.x + 3, origin.y + 1, origin.z)
	var/datum/component/plant/peeker = aquila_obce_grow_plant(src, /obj/item/plant_seeds/preset/alien/peeker, peeker_turf)
	TEST_ASSERT(istype(peeker), "Podglądacza nie da się posadzić")
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, origin)
	walker.forceMove(locate(origin.x + 1, origin.y + 1, origin.z))
	var/matrix/facing = peeker.plant_item.transform
	TEST_ASSERT(facing.a < 0, "Podglądacz nie obrócił się w stronę przechodzącego z lewej")

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
