// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }

/// AQUILA - wstępny rework botaniki: zbiór całej tacy, podłoże w komunikatach, krótki stan w skanerze, piec przyjmujący nasiona
/datum/unit_test/aquila_botany_rework

/datum/unit_test/aquila_botany_rework/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	usr = user

// Złe podłoże: komunikat mówi, jakiego trzeba
	var/obj/item/plant_tray/sand_tray = allocate(/obj/item/plant_tray, get_step(origin, NORTH))
	var/datum/component/planter/sand_planter = sand_tray.GetComponent(/datum/component/planter)
	sand_planter.set_substrate(/datum/plant_subtrate/sand)
	var/obj/item/plant_seeds/preset/apple/apple = allocate(/obj/item/plant_seeds/preset/apple, origin)
	TEST_ASSERT(findtext(apple.name, "ziemia"), "Nazwa paczki nie podaje podłoża: [apple.name]")
	var/info = apple.plant(sand_tray, null, TRUE)
	TEST_ASSERT(istext(info) && findtext(info, "ziemia"), "Komunikat o złym podłożu nie podaje potrzebnego: [info]")

// Klik w tacę zbiera wszystkie gotowe owoce
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	var/obj/item/plant_seeds/tomato_seeds = allocate(/obj/item/plant_seeds/preset/tomato, origin)
	var/datum/component/plant/plant = tomato_seeds.plant(tray, null, TRUE, null, TRUE)
	TEST_ASSERT_NOTNULL(plant, "Nie udało się posadzić pomidora")
	plant.skip_growth = TRUE
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	for(var/i in 1 to 3)
		body.process(2)
		fruit.process(2)
	TEST_ASSERT(length(fruit.fruits), "Dojrzały pomidor nie zawiązał owoców")
	TEST_ASSERT(tray.harvest_all(user), "Taca nie zebrała owoców")
	TEST_ASSERT_NOTNULL(locate(/obj/item/food/grown/tomato) in get_turf(user), "Po zbiorze z tacy pomidor nie trafił pod gracza")

// Skaner: stan tacy i rośliny zamiast katalogu potrzeb
	var/obj/item/plant_scanner/scanner = allocate(/obj/item/plant_scanner, origin)
	scanner.afterattack(tray, user, TRUE)
	var/list/tray_lines = scanner.buffer
	TEST_ASSERT(length(tray_lines) && findtext(tray_lines[1], "Podłoże"), "Skan tacy nie zaczyna się od podłoża")
	var/list/plant_lines = scanner.get_plant_status(plant)
	TEST_ASSERT(length(plant_lines) && findtext(plant_lines[1], "Zdrowie"), "Stan rośliny nie podaje zdrowia")
	scanner.afterattack(plant.plant_item, user, TRUE)
	TEST_ASSERT(length(scanner.status), "Skan rośliny nie wypełnił sekcji Stan")

// Pestycyd nie truje łodygi (był jednocześnie lekiem na szkodniki i toksyną)
	tray.reagents.add_reagent(/datum/reagent/toxin/pestkiller, 20)
	var/health_before = body.health
	body.check_needs(2)
	TEST_ASSERT(body.health >= health_before, "Pestycyd zabrał roślinie zdrowie ([health_before] -> [body.health])")

// Opis tacy bez chwastów nie mówi o chwastach
	planter.weed_level = 0
	var/list/examine_text = list()
	planter.catch_examine(tray, user, examine_text)
	TEST_ASSERT(!findtext(jointext(examine_text, " "), "chwast"), "Opis tacy przy zerze chwastów pisze o chwastach")

// Piec: z większej paczki bierze jedno nasiono i zachowuje własną nazwę
	var/obj/machinery/plant_machine/plant_mutator/name_kiln = allocate(/obj/machinery/plant_machine/plant_mutator, get_step(get_step(get_step(origin, EAST), EAST), NORTH))
	var/obj/item/plant_seeds/named_seeds = allocate(/obj/item/plant_seeds/preset/tomato, origin)
	named_seeds.seeds = 3
	named_seeds.name_override = "pomidor testowy"
	named_seeds.update_plant_name()
	TEST_ASSERT(name_kiln.insert_seeds(named_seeds, null), "Piec nie przyjął paczki z trzema nasionami")
	TEST_ASSERT(named_seeds.seeds == 2 && name_kiln.inserted_seeds != named_seeds, "Piec nie wziął jednego nasiona z paczki (zostało [named_seeds.seeds])")
	var/obj/item/plant_seeds/single_seed = name_kiln.inserted_seeds
	name_kiln.eject_seeds(null)
	TEST_ASSERT(single_seed.name_override == "pomidor testowy", "Nasiono z pieca zgubiło własną nazwę ([single_seed.name_override])")
	qdel(single_seed)

// Piec radiacyjny: nasiona wchodzą bez łopatki i wracają zmutowane
	var/obj/machinery/plant_machine/plant_mutator/mutator = allocate(/obj/machinery/plant_machine/plant_mutator, get_step(origin, NORTHEAST))
	var/obj/item/plant_seeds/kiln_seeds = allocate(/obj/item/plant_seeds/preset/tomato, origin)
	TEST_ASSERT(mutator.insert_seeds(kiln_seeds, null), "Piec nie przyjął nasion")
	TEST_ASSERT(mutator.plant && mutator.inserted_seeds, "Piec nie zrobił rośliny z nasion")
	var/obj/item/plant_seeds/kiln_single = mutator.inserted_seeds
	var/datum/plant_feature/fruit/kiln_fruit = locate() in mutator.plant_component.plant_features
	var/old_type = kiln_fruit.type
	mutator.ui_act("mutate", list("key" = REF(kiln_fruit)))
	mutator.ui_act("mutate", list("key" = REF(kiln_fruit)))
	mutator.reset_working()
	mutator.eject_seeds(null)
	TEST_ASSERT(kiln_single.loc == get_turf(mutator), "Nasiona nie wyszły z pieca")
	TEST_ASSERT(!mutator.plant && !mutator.inserted_seeds, "Piec nie wyczyścił środka po wyjęciu nasion")
	var/datum/plant_feature/fruit/new_fruit = locate() in kiln_single.plant_features
	TEST_ASSERT(new_fruit && new_fruit.type != old_type, "Nasiona z pieca mają stary owoc ([new_fruit?.type])")
	qdel(kiln_single)

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
