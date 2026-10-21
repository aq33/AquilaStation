// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }

/// AQUILA - botanika z Bee: cały cykl gracza, czyli sadzenie, wzrost, zbiór, skaner, seeder, analizator z dyskiem, edytor nasion i piec
/datum/unit_test/aquila_botany_flow

/// Sadzi nasiona w tacy z ziemią i wodą, przyspiesza wzrost i zbiera owoce na pole tacy
/datum/unit_test/aquila_botany_flow/proc/grow(obj/item/plant_tray/tray, seed_type)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = allocate(seed_type, get_turf(tray))
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!plant)
		return
	plant.skip_growth = TRUE
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	for(var/i in 1 to 3)
		body?.process(2)
		fruit?.process(2)
	return plant

/datum/unit_test/aquila_botany_flow/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	usr = user

// Sadzenie i wzrost
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/plant/plant = grow(tray, /obj/item/plant_seeds/preset/tomato)
	TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić pomidora w tacy z ziemią")
	TEST_ASSERT(plant.plant_item.loc == tray, "Roślina nie leży w tacy")
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	TEST_ASSERT(body.current_stage >= body.growth_stages, "Roślina nie dojrzała (etap [body.current_stage]/[body.growth_stages])")
	var/datum/plant_feature/fruit/fruit_feature = locate() in plant.plant_features
	TEST_ASSERT(length(fruit_feature.fruits), "Dojrzała roślina nie zawiązała owoców")

// Zbiór
	fruit_feature.catch_attack_hand(null, user)
	var/obj/item/food/grown/tomato/tomato = locate() in get_turf(user)
	TEST_ASSERT_NOTNULL(tomato, "Zbiór nie dał pomidora")
	TEST_ASSERT(tomato.reagents?.total_volume > 0, "Pomidor nie ma odczynników")
	TEST_ASSERT(get_fruit_trait_power(tomato) >= 1, "Pomidor nie ma genów (moc cech [get_fruit_trait_power(tomato)])")

// Skaner: owoc, taca, nasiona
	var/obj/item/plant_scanner/scanner = allocate(/obj/item/plant_scanner, origin)
	scanner.afterattack(tomato, user, TRUE)
	TEST_ASSERT(length(scanner.ui_data(user)), "Skaner nie zwrócił danych po zeskanowaniu owocu")
	scanner.afterattack(tray, user, TRUE)
	TEST_ASSERT(length(scanner.ui_data(user)), "Skaner nie zwrócił danych po zeskanowaniu tacy")

// Siewnik: owoc na nasiona
	var/obj/machinery/seeder/seeder = allocate(/obj/machinery/seeder, get_step(origin, NORTH))
	seeder.attackby(tomato, user)
	var/obj/item/plant_seeds/new_seeds = locate() in get_turf(seeder)
	TEST_ASSERT_NOTNULL(new_seeds, "Siewnik nie zrobił nasion z pomidora")
	TEST_ASSERT(length(new_seeds.plant_features) >= 3, "Nasiona z siewnika nie mają części rośliny")

// Terminal i maszyny obok siebie
	var/turf/machines = get_step(get_step(origin, NORTH), NORTH)
	var/obj/machinery/computer/plant_machine_controller/computer = allocate(/obj/machinery/computer/plant_machine_controller, get_step(origin, NORTHEAST))
	var/obj/machinery/plant_machine/plant_analyser/analyser = allocate(/obj/machinery/plant_machine/plant_analyser, machines)
	var/obj/machinery/plant_machine/seed_editor/editor = allocate(/obj/machinery/plant_machine/seed_editor, get_step(machines, EAST))
	var/obj/machinery/plant_machine/plant_mutator/mutator = allocate(/obj/machinery/plant_machine/plant_mutator, get_step(get_step(machines, EAST), EAST))
	computer.locate_machines()
	TEST_ASSERT(analyser.controller == computer && editor.controller == computer && mutator.controller == computer, "Terminal nie połączył się z maszynami obok")
	TEST_ASSERT(length(computer.ui_data(user)), "Terminal (encyklopedia) nie zwrócił danych")

// Analizator: zapis cechy na dysk
	var/obj/item/disk/plant_disk/disk = allocate(/obj/item/disk/plant_disk, origin)
	analyser.attackby(disk, user)
	TEST_ASSERT(analyser.disk == disk, "Dysk nie wszedł do analizatora")
	plant.plant_item.forceMove(analyser)
	analyser.inserted_plant = plant.plant_item
	analyser.plant_component = plant
	TEST_ASSERT(length(analyser.ui_data(user)), "Analizator nie zwrócił danych z rośliną w środku")
	var/datum/plant_trait/trait_to_save
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			if(trait.can_copy)
				trait_to_save = trait
				break
		if(trait_to_save)
			break
	TEST_ASSERT_NOTNULL(trait_to_save, "Pomidor nie ma żadnej cechy do skopiowania")
	analyser.ui_act("save_trait", list("key" = REF(trait_to_save)))
	TEST_ASSERT(istype(disk.saved, /datum/plant_trait), "Analizator nie zapisał cechy na dysk")

// Edytor nasion: dodanie cechy z dysku
	analyser.ui_act("remove_disk", list())
	disk.forceMove(origin)
	editor.attackby(new_seeds, user)
	editor.attackby(disk, user)
	TEST_ASSERT(editor.seeds == new_seeds && editor.disk == disk, "Nasiona albo dysk nie weszły do sekwencera")
	TEST_ASSERT(length(editor.ui_data(user)), "Sekwencer nie zwrócił danych")
	var/datum/plant_trait/saved_trait = disk.saved
	var/datum/plant_feature/target_feature
	for(var/datum/plant_feature/feature as anything in new_seeds.plant_features)
		if(istype(feature, saved_trait.plant_feature_compat))
			target_feature = feature
			break
	TEST_ASSERT_NOTNULL(target_feature, "Nasiona nie mają części zgodnej z zapisaną cechą")
	var/traits_before = length(target_feature.plant_traits)
	editor.ui_act("select_feature", list("key" = REF(target_feature)))
	var/datum/plant_trait/duplicate = locate(saved_trait.type) in target_feature.plant_traits
	if(duplicate && !duplicate.allow_multiple)
		editor.ui_act("remove_trait", list("key" = REF(duplicate)))
		traits_before--
	editor.ui_act("add_trait", list("key" = REF(saved_trait)))
	TEST_ASSERT(length(target_feature.plant_traits) == traits_before + 1, "Sekwencer nie dodał cechy z dysku ([length(target_feature.plant_traits)] cech, było [traits_before])")

// Piec radiacyjny: mutacja części
	var/obj/item/plant_tray/tray2 = allocate(/obj/item/plant_tray, get_step(get_step(origin, EAST), EAST))
	var/datum/component/plant/plant2 = grow(tray2, /obj/item/plant_seeds/preset/tomato)
	TEST_ASSERT_NOTNULL(plant2, "Nie udało się posadzić drugiego pomidora")
	var/obj/item/tank/internals/plasma/full/tank = allocate(/obj/item/tank/internals/plasma/full, origin)
	mutator.attackby(tank, user)
	TEST_ASSERT(mutator.catalyst == tank, "Butla z plazmą nie weszła do pieca")
	plant2.plant_item.forceMove(mutator)
	mutator.plant = plant2.plant_item
	mutator.plant_component = plant2
	var/datum/plant_feature/fruit/tomato_fruit = locate() in plant2.plant_features
	TEST_ASSERT(length(tomato_fruit.mutations), "Owoc pomidora nie ma mutacji")
	var/old_type = tomato_fruit.type
	mutator.ui_act("mutate", list("key" = REF(tomato_fruit)))
	mutator.ui_act("mutate", list("key" = REF(tomato_fruit)))
	var/datum/plant_feature/fruit/new_fruit = locate() in plant2.plant_features
	TEST_ASSERT(new_fruit && new_fruit.type != old_type, "Piec nie zmutował owocu ([new_fruit?.type])")
	mutator.reset_working()

// Losowa doniczka ma roślinę, glowshroom rośnie bez błędów
	var/obj/item/plant_tray/pot/random/pot = allocate(/obj/item/plant_tray/pot/random, get_step(origin, NORTHWEST) || origin)
	sleep(1)
	var/datum/component/planter/pot_planter = pot.GetComponent(/datum/component/planter)
	TEST_ASSERT(length(pot_planter.plants), "Losowa doniczka nie ma rośliny")
	var/obj/structure/glowshroom/shroom = allocate(/obj/structure/glowshroom, get_step(origin, SOUTH) || origin)
	TEST_ASSERT(!QDELETED(shroom), "Glowshroom zniknął od razu po postawieniu")

/// AQUILA - replica pod: krew z umysłem trafia do części owocu i przechodzi do posadzonej rośliny
/datum/unit_test/aquila_botany_replica_pod

/datum/unit_test/aquila_botany_replica_pod/Run()
	var/obj/item/plant_seeds/preset/diona_pod/seeds = allocate(/obj/item/plant_seeds/preset/diona_pod, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	donor.mind_initialize()
	var/list/blood_data = donor.get_blood_data(donor.get_blood_id())
	TEST_ASSERT_NOTNULL(blood_data, "Dawca nie ma danych krwi")
	blood_data["mind"] = donor.mind
	blood_data["cloneable"] = TRUE
	seeds.reagents.add_reagent(/datum/reagent/blood, 5, blood_data)
	var/datum/plant_feature/fruit/cabbage/diona/pod = locate() in seeds.plant_features
	TEST_ASSERT(pod?.clone_data, "Krew nie trafiła do części replica poda")
	var/datum/plant_feature/fruit/cabbage/diona/copied = pod.copy()
	TEST_ASSERT(copied.clone_data, "Kopia części (przy sadzeniu) zgubiła dane klonu")
	qdel(copied)

/// AQUILA - kwiat trupi: dojrzały w tacy wydziela miazmę, poza tacą przestaje
/datum/unit_test/aquila_botany_corpse_flower

/datum/unit_test/aquila_botany_corpse_flower/Run()
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, run_loc_floor_bottom_left)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/corpse_flower, run_loc_floor_bottom_left)
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić kwiatu trupiego")
	var/obj/item/plant/flower = plant.plant_item
	TEST_ASSERT(flower.miasma_emission(1) == 0, "Niedojrzały kwiat trupi już wydziela miazmę")
	plant.skip_growth = TRUE
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	body.process(2)
	TEST_ASSERT(flower.miasma_emission(1) > 0, "Dojrzały kwiat trupi nie wydziela miazmy")
	flower.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(isnull(flower.miasma_emission(1)), "Kwiat trupi poza tacą nie wyrejestrował się z miazmy")

/// AQUILA - żółwik podlewa tacę
/datum/unit_test/aquila_botany_turtle

/datum/unit_test/aquila_botany_turtle/Run()
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/simple_animal/bot/turtle/turtle = allocate(/mob/living/simple_animal/bot/turtle, run_loc_floor_bottom_left)
	turtle.turn_on()
	var/before = tray.reagents.get_reagent_amount(/datum/reagent/water)
	turtle.UnarmedAttack(tray, TRUE)
	TEST_ASSERT(tray.reagents.get_reagent_amount(/datum/reagent/water) > before, "Żółwik nie podlał tacy")
	TEST_ASSERT(length(turtle.get_custom_controls(null)), "Żółwik nie ma ustawień w oknie bota")

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
