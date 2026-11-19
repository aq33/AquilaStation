// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Tika drzewo bota, aż warunek zajdzie albo minie limit (praca jest asynchroniczna, więc z krótkim snem)
#define TICK_BOT_UNTIL(bot, condition, ticks) for(var/_i in 1 to ticks) { if(condition) { break }; bot.ai_controller.SelectBehaviors(0.5); sleep(1) }

/// Kontroler testowy: drzewo z opisu w kodzie, bez pliku .bt.json
/datum/ai_controller/basic_controller/bt_test
	behavior_nodes = list(
		"type" = "/datum/bt_node/composite/sequence",
		"children" = list(
			list("type" = "/datum/bt_node/ai_behavior/set_bb_key", "target_key" = "bt_test_key", "value" = 7),
			list("type" = "/datum/bt_node/decorator/bb_key_set", "key" = "bt_test_key", "children" = list(
				list("type" = "/datum/bt_node/ai_behavior/set_bb_key", "target_key" = "bt_test_second", "value" = TRUE),
			)),
			list("type" = "/datum/bt_node/ai_behavior/wait", "duration" = 0),
		),
	)

/// AQUILA - BOTY: silnik drzew zachowań (hybryda): drzewo z opisu tika i podejmuje decyzje, planning subtrees zostają
/datum/unit_test/aquila_behavior_tree_engine

/datum/unit_test/aquila_behavior_tree_engine/Run()
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse)
	var/datum/ai_controller/old_controller = mouse.ai_controller
	TEST_ASSERT(old_controller && !old_controller.uses_behavior_tree(), "Mysz (planning subtrees) dostała drzewo zachowań")
	TEST_ASSERT(length(old_controller.planning_subtrees), "Mysz straciła planning subtrees")

	var/datum/ai_controller/basic_controller/bt_test/controller = new(mouse)
	TEST_ASSERT(controller.uses_behavior_tree(), "Kontroler z behavior_nodes nie zbudował drzewa")
	controller.SelectBehaviors(0.5)
	TEST_ASSERT_EQUAL(controller.blackboard["bt_test_key"], 7, "Pierwszy liść sekwencji nie ustawił klucza")
	TEST_ASSERT(controller.blackboard["bt_test_second"], "Dekorator bb_key_set nie przepuścił dziecka po ustawieniu klucza")
	var/datum/bt_node/composite/sequence/root = controller.behavior_nodes[1]
	TEST_ASSERT_EQUAL(root.running_child_index, 3, "Sekwencja nie czeka na działający liść wait")
	controller.cancel_current_plan()
	TEST_ASSERT_EQUAL(root.running_child_index, 0, "cancel_current_plan() nie zresetował drzewa")
	// brak bieżących /datum/ai_behavior nie wpycha drzewa w przerwę po nieudanym planowaniu
	controller.planning_failed()
	TEST_ASSERT(!controller.on_failed_planning_timeout, "Kontroler drzewa dostał przerwę jak nieudane planowanie")

	// każde skompilowane drzewo z indeksu .rsc wczytuje się i buduje bez błędów
	for(var/json_path in GLOB.bt_compiled_trees)
		var/list/desc = load_bt_descriptor(json_path)
		TEST_ASSERT(islist(desc), "Nie da się wczytać skompilowanego drzewa [json_path] (uruchom python tools/build_bt.py)")
		var/datum/bt_node/built = controller.build_node_from_descriptor(desc)
		TEST_ASSERT(built, "Nie da się zbudować drzewa [json_path]")
		qdel(built)
	// każde poddrzewo z behavior_tree_json ma plik w indeksie
	for(var/datum/bt_node/subtree/subtree_type as anything in subtypesof(/datum/bt_node/subtree))
		var/json_path = initial(subtree_type.behavior_tree_json)
		if(json_path)
			TEST_ASSERT(GLOB.bt_compiled_trees[json_path], "Poddrzewo [subtree_type] wskazuje plik [json_path], którego nie ma w indeksie")
	qdel(controller)

/// AQUILA - BOTY: każdy basic bot powstaje bez runtime'ów, z drzewem zachowań i grafiką
/datum/unit_test/aquila_basic_bots_spawn

/datum/unit_test/aquila_basic_bots_spawn/Run()
	var/runtimes_before = GLOB.total_runtimes
	for(var/bot_type in subtypesof(/mob/living/basic/bot))
		var/mob/living/basic/bot/bot = allocate(bot_type)
		TEST_ASSERT(bot.ai_controller?.uses_behavior_tree(), "[bot_type] nie ma drzewa zachowań")
		TEST_ASSERT(bot.icon_state in icon_states(bot.icon), "[bot_type] ma stan ikony bez grafiki: [bot.icon_state] w [bot.icon]")
		TEST_ASSERT(bot in GLOB.basic_bots_list, "[bot_type] nie trafił na listę basic botów")
		bot.ai_controller.SelectBehaviors(0.5)
		bot.ui_data(bot)
		bot.get_custom_controls(bot)
		qdel(bot)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Tworzenie basic botów wywołało runtime'y")

/// AQUILA - BOTY: drzewo bota znajduje pracę i ją wykonuje (cleanbot sprząta plamę na swoim kafelku)
/datum/unit_test/aquila_basic_bot_tree_work

/datum/unit_test/aquila_basic_bot_tree_work/Run()
	var/mob/living/basic/bot/cleanbot/bot = allocate(/mob/living/basic/bot/cleanbot, run_loc_floor_bottom_left)
	bot.clean_time = 1
	var/obj/effect/decal/cleanable/blood/stain = allocate(/obj/effect/decal/cleanable/blood, run_loc_floor_bottom_left)
	TICK_BOT_UNTIL(bot, QDELETED(stain), 40)
	TEST_ASSERT(QDELETED(stain), "Cleanbot na drzewie nie posprzątał plamy na swoim kafelku: [jointext(bot.ai_controller.get_behavior_tree_lines(), " | ")]")
	TEST_ASSERT(!bot.ai_controller.blackboard[BB_BOT_WORK_TARGET], "Po pracy cel został w tablicy")

/// AQUILA - BOTY: kluczowe zachowania botów (leczenie, łatanie, resuscytacja, areszt, pobranie krwi)
/datum/unit_test/aquila_basic_bot_behaviors

/datum/unit_test/aquila_basic_bot_behaviors/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next = get_step(start, EAST)

	// Medibot leczy rannego obok
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, next)
	patient.adjustBruteLoss(40)
	var/mob/living/basic/bot/medbot/medbot = allocate(/mob/living/basic/bot/medbot, start)
	medbot.heal_time = 1
	TEST_ASSERT(medbot.is_valid_work_target(patient), "Medibot nie uznaje rannego za pacjenta")
	var/brute_before = patient.getBruteLoss()
	medbot.work_on_target(patient)
	TEST_ASSERT(patient.getBruteLoss() < brute_before, "Medibot nie wyleczył obrażeń")
	qdel(medbot)

	// Zhakowany securitron ogłusza każdego obok
	var/mob/living/basic/bot/secbot/secbot = allocate(/mob/living/basic/bot/secbot, start)
	secbot.cuff_time = 1
	secbot.bot_access_flags |= BOT_COVER_EMAGGED
	TEST_ASSERT(secbot.is_valid_work_target(patient), "Zhakowany securitron nie uznaje człowieka za cel")
	secbot.work_on_target(patient)
	TEST_ASSERT(patient.IsParalyzed(), "Securitron nie ogłuszył celu")
	secbot.work_on_target(patient)
	TEST_ASSERT(patient.handcuffed, "Securitron nie skuł ogłuszonego celu")
	qdel(secbot)
	QDEL_NULL(patient.handcuffed)
	patient.SetParalyzed(0)

	// CPRbot robi resuscytację osobie w stanie krytycznym na swoim kafelku
	patient.forceMove(start)
	patient.fully_heal()
	patient.adjustOxyLoss(150)
	var/mob/living/basic/bot/cprbot/cprbot = allocate(/mob/living/basic/bot/cprbot, start)
	TEST_ASSERT(cprbot.needs_cpr(patient), "CPRbot nie widzi potrzeby resuscytacji")
	var/oxy_before = patient.getOxyLoss()
	cprbot.work_on_target(patient)
	TEST_ASSERT(patient.getOxyLoss() < oxy_before, "CPRbot nie zmniejszył niedotlenienia")
	qdel(cprbot)
	patient.fully_heal()

	// Doctor Acula pobiera krew od zdrowego dawcy do worka
	patient.forceMove(next)
	patient.blood_volume = BLOOD_VOLUME_NORMAL
	var/mob/living/basic/bot/bloodbot/acula = allocate(/mob/living/basic/bot/bloodbot, start)
	TEST_ASSERT(acula.is_valid_work_target(patient), "Doctor Acula nie uznaje dawcy")
	acula.work_on_target(patient)
	TEST_ASSERT(patient.blood_volume < BLOOD_VOLUME_NORMAL, "Doctor Acula nie pobrał krwi")
	var/collected = 0
	for(var/obj/item/reagent_containers/blood/bag as anything in acula.contained_bags)
		collected += bag.reagents.total_volume
	TEST_ASSERT(collected > 0, "Pobrana krew nie trafiła do worka")
	qdel(acula)

	// Repairbot naprawia uszkodzoną podłogę obok
	var/turf/open/floor/broken_floor = next
	if(istype(broken_floor))
		broken_floor.broken = TRUE
		var/mob/living/basic/bot/repairbot/repairbot = allocate(/mob/living/basic/bot/repairbot, start)
		repairbot.repair_time = 1
		TEST_ASSERT(repairbot.task_for(broken_floor), "Repairbot nie widzi uszkodzonej podłogi")
		repairbot.work_on_target(broken_floor)
		TEST_ASSERT(!broken_floor.broken, "Repairbot nie naprawił podłogi")
		qdel(repairbot)

	// Żółwik podlewa tacę
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, next)
	var/mob/living/basic/bot/turtle/turtle = allocate(/mob/living/basic/bot/turtle, start)
	TEST_ASSERT(turtle.is_valid_work_target(tray), "Żółwik nie widzi pustej tacy")
	turtle.work_on_target(tray)
	TEST_ASSERT(tray.reagents.get_reagent_amount(/datum/reagent/water) > 0, "Żółwik nie podlał tacy")

/// AQUILA - BOTY: panel i osobowość (duch może przejąć bota tylko po włączeniu przełącznika)
/datum/unit_test/aquila_basic_bot_personality

/datum/unit_test/aquila_basic_bot_personality/Run()
	var/mob/living/basic/bot/medbot/bot = allocate(/mob/living/basic/bot/medbot)
	TEST_ASSERT(!bot.can_be_possessed, "Bot jest do przejęcia bez włączenia osobowości")
	bot.enable_possession()
	TEST_ASSERT(bot.can_be_possessed, "Przełącznik osobowości nie pozwala duchom przejąć bota")
	var/list/data = bot.ui_data(bot)
	TEST_ASSERT(data["settings"]["possession_enabled"], "Okno bota nie pokazuje włączonej osobowości")
	bot.disable_possession()
	TEST_ASSERT(!bot.can_be_possessed, "Wyłączenie osobowości nie zadziałało")
	bot.emag_act(null)
	TEST_ASSERT(!bot.is_emagged(), "Pierwszy emag od razu zhakował bota (powinien tylko odblokować)")
	bot.bot_access_flags |= BOT_COVER_MAINTS_OPEN
	bot.emag_act(null)
	TEST_ASSERT(bot.is_emagged(), "Emag przy otwartym panelu nie zhakował bota")

#undef TICK_BOT_UNTIL
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
