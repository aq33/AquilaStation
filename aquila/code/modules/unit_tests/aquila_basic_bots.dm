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

/// AQUILA - BOTY: kluczowe zachowania botów (leczenie, łatanie, areszt, Secbuddy, D.E.D.bot z uplinka, pobranie krwi)
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

	// Zły Secbuddy (event eldritchowych botów) ogłusza każdego przytomnego obok
	var/mob/living/basic/bot/secbuddy/secbuddy = allocate(/mob/living/basic/bot/secbuddy, start)
	TEST_ASSERT(secbuddy.is_valid_work_target(patient), "Secbuddy nie uznaje przytomnego człowieka za cel")
	secbuddy.work_on_target(patient)
	TEST_ASSERT(patient.IsParalyzed(), "Secbuddy nie ogłuszył celu")
	qdel(secbuddy)
	patient.SetParalyzed(0)

	// D.E.D.bot z uplinka oszczędza kupującego, ale tnie innych spoza Syndykatu
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human, next)
	var/datum/uplink_item/dangerous/aq_dedbot/dedbot_item = new
	var/mob/living/basic/bot/dedbot/dedbot = dedbot_item.spawn_item(dedbot_item.item, patient)
	TEST_ASSERT(istype(dedbot), "Uplink nie dał D.E.D.bota")
	TEST_ASSERT(!dedbot.is_valid_work_target(patient), "D.E.D.bot z uplinka chce ciąć kupującego")
	TEST_ASSERT(dedbot.is_valid_work_target(bystander), "D.E.D.bot z uplinka nie tnie obcych")
	qdel(dedbot)
	qdel(dedbot_item)
	qdel(bystander)
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

/// Pierwszy węzeł danego typu w drzewie kontrolera (testy tikają liść bezpośrednio)
/datum/unit_test/proc/find_bot_tree_node(datum/ai_controller/controller, node_type)
	var/list/to_visit = controller.behavior_nodes.Copy()
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		if(istype(node, node_type))
			return node
		node.collect_reset_children(to_visit)

/// AQUILA - BOTY: wezwanie. Dostęp z wezwania wraca po dotarciu, nieudane wezwanie (brak windy, brak ścieżki) czyści się bez rekurencji resetu
/datum/unit_test/aquila_basic_bot_summon

/datum/unit_test/aquila_basic_bot_summon/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/mob/living/basic/bot/cleanbot/bot = allocate(/mob/living/basic/bot/cleanbot, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/summoner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/ai_controller/basic_controller/bot/controller = bot.ai_controller
	var/list/initial_access = bot.initial_access.Copy()

	bot.summon_bot(summoner, get_turf(bot), grant_all_access = TRUE)
	TEST_ASSERT(length(bot.access_card.access) > length(initial_access), "Wezwanie nie dało dostępu na drogę")
	TICK_BOT_UNTIL(bot, !controller.blackboard[BB_BOT_SUMMON_TARGET], 5)
	TEST_ASSERT(!controller.blackboard[BB_BOT_SUMMON_TARGET], "Bot nie zakończył wezwania na swoim kafelku")
	TEST_ASSERT(!length(bot.access_card.access ^ initial_access), "Po dotarciu na miejsce wezwania bot zachował dostęp z wezwania")

	// inny pokład bez windy dla botów: porażka ruchu, a nie wiszące wezwanie
	var/list/saved_elevators = GLOB.bot_elevator
	GLOB.bot_elevator = list()
	bot.summon_bot(summoner, locate(bot.x, bot.y, bot.z == 1 ? 2 : 1), grant_all_access = TRUE)
	bot.calling_ai_ref = WEAKREF(summoner)
	controller.SelectBehaviors(0.5)
	GLOB.bot_elevator = saved_elevators
	TEST_ASSERT(!controller.blackboard[BB_BOT_SUMMON_TARGET], "Wezwanie na pokład bez windy wisi w tablicy")
	TEST_ASSERT(isnull(bot.calling_ai_ref), "Nieudane wezwanie nie zwolniło wzywającego")
	TEST_ASSERT(!length(bot.access_card.access ^ initial_access), "Nieudane wezwanie zostawiło dostęp z wezwania")

	// brak ścieżki na tym samym pokładzie: reset bota w finish_action nie woła go drugi raz
	bot.summon_bot(summoner, run_loc_floor_top_right)
	controller.SelectBehaviors(0.5)
	SEND_SIGNAL(bot, COMSIG_MOB_AI_MOVEMENT_FAILED)
	controller.SelectBehaviors(0.5)
	TEST_ASSERT(!controller.blackboard[BB_BOT_SUMMON_TARGET], "Wezwanie bez ścieżki wisi w tablicy")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Nieudane wezwanie wywołało runtime'y (rekurencja resetu?)")

/// AQUILA - BOTY: stacjonarny bot nie jedzie do celu ani na patrol, a ruchomy porzuca cel, który kilka razy z rzędu uciekł poza zasięg
/datum/unit_test/aquila_basic_bot_reach

/datum/unit_test/aquila_basic_bot_reach/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/basic/bot/medbot/medbot = allocate(/mob/living/basic/bot/medbot, start)
	var/datum/ai_controller/basic_controller/bot/controller = medbot.ai_controller

	medbot.stationary_mode = TRUE
	TEST_ASSERT(medbot.is_stationary(), "is_stationary() nie widzi trybu stacjonarnego medibota")
	medbot.set_mode_flags(medbot.bot_mode_flags | BOT_MODE_AUTOPATROL)
	controller.set_blackboard_key(BB_BEACON_TARGET, run_loc_floor_top_right)
	controller.SelectBehaviors(0.5)
	TEST_ASSERT(!controller.ai_movement.moving_controllers[controller], "Stacjonarny medibot ruszył na patrol")
	medbot.stationary_mode = FALSE
	controller.SelectBehaviors(0.5)
	TEST_ASSERT(controller.ai_movement.moving_controllers[controller], "Ruchomy medibot nie ruszył na patrol (test nic nie sprawdza)")
	medbot.set_mode_flags(medbot.bot_mode_flags & ~BOT_MODE_AUTOPATROL)
	medbot.bot_reset()
	TEST_ASSERT(!controller.ai_movement.moving_controllers[controller], "Reset bota nie zatrzymał patrolu")

	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(get_step(start, EAST), EAST))
	patient.adjustBruteLoss(40)
	medbot.stationary_mode = TRUE
	controller.set_blackboard_key(BB_BOT_WORK_TARGET, patient)
	controller.SelectBehaviors(0.5)
	TEST_ASSERT(!controller.ai_movement.moving_controllers[controller], "Stacjonarny medibot ruszył do pacjenta")
	TEST_ASSERT(!controller.blackboard[BB_BOT_WORK_TARGET], "Stacjonarny medibot trzyma pacjenta poza zasięgiem")
	TEST_ASSERT(!LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], patient), "Stacjonarny medibot wpisał pacjenta poza zasięgiem na czarną listę")

	medbot.stationary_mode = FALSE
	var/datum/bt_node/ai_behavior/bot_perform_work/work_leaf = find_bot_tree_node(controller, /datum/bt_node/ai_behavior/bot_perform_work)
	TEST_ASSERT(work_leaf, "Drzewo medibota nie ma liścia pracy")
	controller.set_blackboard_key(BB_BOT_WORK_TARGET, patient)
	for(var/attempt in 1 to 3)
		work_leaf.tick(controller, 0.5)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BOT_WORK_TARGET], patient, "Medibot porzucił pacjenta po pierwszej ucieczce poza zasięg")
	work_leaf.tick(controller, 0.5)
	TEST_ASSERT(!controller.blackboard[BB_BOT_WORK_TARGET], "Medibot bez końca trzyma cel, który ucieka poza zasięg")
	TEST_ASSERT(LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], patient), "Porzucony cel poza zasięgiem nie trafił na czarną listę")

/// AQUILA - BOTY: czarna lista, części z rozbitego bota, dostęp do panelu i PDA, śmierć bez DEL_ON_DEATH, czar przyzwania ED-209
/datum/unit_test/aquila_basic_bot_base_fixes

/datum/unit_test/aquila_basic_bot_base_fixes/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/mob/living/basic/bot/honkbot/bot = allocate(/mob/living/basic/bot/honkbot, run_loc_floor_bottom_left)
	var/datum/ai_controller/basic_controller/bot/controller = bot.ai_controller

	var/obj/item/crowbar/thing = allocate(/obj/item/crowbar, run_loc_floor_top_right)
	controller.remove_from_blacklist(thing)
	controller.add_to_blacklist(thing, 1)
	controller.add_to_blacklist(thing, 1)
	TEST_ASSERT(LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], thing), "Cel nie trafił na czarną listę")
	sleep(5)
	TEST_ASSERT(!LAZYACCESS(controller.blackboard[BB_TEMPORARY_IGNORE_LIST], thing), "Cel nie zszedł z czarnej listy po czasie")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Podwójne dopisanie albo zdjęcie spoza czarnej listy dało runtime")

	var/obj/item/storage/firstaid/regular/kit = bot.drop_part(/obj/item/storage/firstaid/regular, run_loc_floor_top_right)
	TEST_ASSERT(istype(kit), "drop_part nie dał apteczki")
	TEST_ASSERT(!length(kit.contents), "Apteczka z rozbitego bota ma pełną zawartość")
	qdel(kit)

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_ROBOTICS)
	TEST_ASSERT(bot.check_access(card), "Robotyka nie odblokowuje panelu bota bez własnej listy dostępów")
	card.access = list()
	TEST_ASSERT(!bot.check_access(card), "Karta bez dostępów odblokowuje panel bota")
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	bot.bot_access_flags &= ~BOT_COVER_LOCKED
	TEST_ASSERT(bot.allowed(stranger), "Odblokowany bot nie przepuszcza w panelu")
	TEST_ASSERT(!bot.remote_access_allowed(stranger, null), "PDA bez karty steruje botem z odblokowaną obudową")
	card.access = list(ACCESS_ROBOTICS)
	TEST_ASSERT(bot.remote_access_allowed(stranger, card), "Karta robotyka w PDA nie steruje botem")

	var/obj/effect/proc_holder/spell/aoe_turf/conjure/summonEdSwarm/spell = new
	var/mob/living/basic/bot/secbot/ed209/ed209 = allocate(/mob/living/basic/bot/secbot/ed209, run_loc_floor_top_right)
	for(var/var_name in spell.newVars)
		TEST_ASSERT(var_name in ed209.vars, "Czar przyzwania ED-209 ustawia zmienną [var_name], której basic ED-209 nie ma")
	spell.post_summon(ed209, null)
	TEST_ASSERT(ed209.is_emagged(), "ED-209 z czaru nie jest zhakowany")
	TEST_ASSERT(!(ed209.bot_mode_flags & BOT_MODE_REMOTE_ENABLED), "ED-209 z czaru słucha zdalnego sterowania")
	qdel(spell)

	bot.basic_mob_flags &= ~DEL_ON_DEATH
	bot.death()
	TEST_ASSERT(QDELETED(bot), "Bot bez DEL_ON_DEATH (event świadomości) nie rozpadł się po śmierci")
	TEST_ASSERT(!(bot in GLOB.basic_bots_list), "Zniszczony bot został na liście basic botów")

/// AQUILA - BOTY (przegląd): reset oprogramowania cofa efekty emagu (undo_emag_effects), emag nie celuje od razu w hakera
/datum/unit_test/aquila_basic_bot_emag_undo

/datum/unit_test/aquila_basic_bot_emag_undo/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/hacker = allocate(/mob/living/carbon/human, get_step(start, EAST))

	// ED-209: laser bojowy po emagu, po resecie z powrotem paralizator; laser tag zostaje swój
	var/mob/living/basic/bot/secbot/ed209/ed = allocate(/mob/living/basic/bot/secbot/ed209, start)
	ed.bot_access_flags |= BOT_COVER_EMAGGED
	ed.emag_effects(hacker)
	TEST_ASSERT_EQUAL(ed.projectile, /obj/item/projectile/beam, "Zhakowany ED-209 nie strzela laserem")
	TEST_ASSERT(!ed.declare_arrests, "Zhakowany ED-209 dalej ogłasza aresztowania")
	TEST_ASSERT(!ed.is_valid_work_target(hacker), "Zhakowany ED-209 od razu celuje w hakera")
	ed.bot_access_flags &= ~BOT_COVER_EMAGGED
	ed.undo_emag_effects()
	TEST_ASSERT_EQUAL(ed.projectile, /obj/item/projectile/beam/disabler, "Reset nie przywrócił ED-209 paralizatora")
	TEST_ASSERT(ed.declare_arrests, "Reset nie przywrócił ogłaszania aresztowań")
	qdel(ed)
	var/mob/living/basic/bot/secbot/ed209/redtag/red = allocate(/mob/living/basic/bot/secbot/ed209/redtag, start)
	red.bot_access_flags |= BOT_COVER_EMAGGED
	red.emag_effects(null)
	red.bot_access_flags &= ~BOT_COVER_EMAGGED
	red.undo_emag_effects()
	TEST_ASSERT_EQUAL(red.projectile, /obj/item/projectile/beam/lasertag/redtag, "Reset nie przywrócił czerwonego laser tagu")
	qdel(red)

	// Honkbot po emagu też nie celuje od razu w hakera
	var/mob/living/basic/bot/honkbot/honkbot = allocate(/mob/living/basic/bot/honkbot, start)
	honkbot.bot_access_flags |= BOT_COVER_EMAGGED
	honkbot.emag_effects(hacker)
	TEST_ASSERT(!honkbot.is_valid_work_target(hacker), "Zhakowany honkbot od razu celuje w hakera")
	qdel(honkbot)

	// Firebot: po emagu podjeżdża tak blisko, jak sprawdza work_on_target(); reset przywraca gaszenie wodą
	var/mob/living/basic/bot/firebot/firebot = allocate(/mob/living/basic/bot/firebot, start)
	firebot.bot_access_flags |= BOT_COVER_EMAGGED
	firebot.emag_effects(null)
	TEST_ASSERT_EQUAL(firebot.work_reach, 1, "Zhakowany firebot zatrzymuje się dalej, niż sięga")
	firebot.bot_access_flags &= ~BOT_COVER_EMAGGED
	firebot.undo_emag_effects()
	TEST_ASSERT(firebot.extinguish_fires, "Reset nie przywrócił gaszenia pożarów")
	TEST_ASSERT_EQUAL(firebot.work_reach, initial(firebot.work_reach), "Reset nie przywrócił zasięgu firebota")
	TEST_ASSERT_EQUAL(firebot.internal_ext.chem, /datum/reagent/water, "Reset zostawił firebotowi gaśnicę z CLF3")
	qdel(firebot)

	// Żółwik, screambot, Doctor Acula, medibot, cleanbot
	var/mob/living/basic/bot/turtle/turtle = allocate(/mob/living/basic/bot/turtle, start)
	turtle.emag_effects(null)
	turtle.undo_emag_effects()
	TEST_ASSERT_EQUAL(turtle.dispensed_reagent, /datum/reagent/water, "Reset zostawił żółwikowi Plant-B-Gone")
	qdel(turtle)
	var/mob/living/basic/bot/screambot/screambot = allocate(/mob/living/basic/bot/screambot, start)
	screambot.emag_effects(null)
	screambot.undo_emag_effects()
	TEST_ASSERT(screambot.speedup == initial(screambot.speedup) && screambot.probability == initial(screambot.probability), "Reset nie uspokoił screambota")
	qdel(screambot)
	var/mob/living/basic/bot/bloodbot/acula = allocate(/mob/living/basic/bot/bloodbot, start)
	acula.emag_effects(null)
	acula.undo_emag_effects()
	TEST_ASSERT_EQUAL(acula.speed, initial(acula.speed), "Reset nie przywrócił prędkości Doctora Aculi")
	qdel(acula)
	var/mob/living/basic/bot/medbot/medbot = allocate(/mob/living/basic/bot/medbot, start)
	medbot.emag_effects(null)
	medbot.undo_emag_effects()
	TEST_ASSERT(medbot.declare_crit, "Reset nie przywrócił medibotowi ogłaszania stanów krytycznych")
	qdel(medbot)
	var/mob/living/basic/bot/cleanbot/cleanbot = allocate(/mob/living/basic/bot/cleanbot, start)
	cleanbot.bot_access_flags |= BOT_COVER_EMAGGED
	cleanbot.emag_effects(null)
	cleanbot.bot_access_flags &= ~BOT_COVER_EMAGGED
	cleanbot.undo_emag_effects()
	TEST_ASSERT(!is_type_in_typecache(hacker, cleanbot.work_target_types), "Cleanbot po resecie dalej celuje w ludzi")

/// AQUILA - BOTY (przegląd): kogo boty biorą za cel (małpy, pacjent medibota, przytulobot, wyłom atmosbota, gibtonit)
/datum/unit_test/aquila_basic_bot_targets

/datum/unit_test/aquila_basic_bot_targets/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next = get_step(start, EAST)

	// Małpa: ED-209 i medibot ją pomijają (securitron sprawdzający identyfikatory nie)
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, next)
	monkey.adjustBruteLoss(40)
	var/mob/living/basic/bot/secbot/secbot = allocate(/mob/living/basic/bot/secbot, start)
	secbot.idcheck = TRUE
	TEST_ASSERT(secbot.is_valid_work_target(monkey), "Securitron sprawdzający identyfikatory nie widzi małpy (test nic nie sprawdza)")
	qdel(secbot)
	var/mob/living/basic/bot/secbot/ed209/ed = allocate(/mob/living/basic/bot/secbot/ed209, start)
	TEST_ASSERT(!ed.is_valid_work_target(monkey), "ED-209 ściga małpę")
	qdel(ed)
	var/mob/living/basic/bot/medbot/medbot = allocate(/mob/living/basic/bot/medbot, start)
	medbot.heal_time = 1
	TEST_ASSERT(!medbot.is_valid_work_target(monkey), "Medibot leczy małpę")
	qdel(monkey)

	// Medibot zdejmuje znacznik pacjenta, gdy porzuca cel albo ginie
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, next)
	patient.adjustBruteLoss(40)
	medbot.on_work_target_found(patient)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_MEDIBOTCOMINGTHROUGH), "Medibot nie oznaczył pacjenta")
	medbot.on_work_target_lost(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_MEDIBOTCOMINGTHROUGH), "Znacznik pacjenta został po porzuceniu celu")
	// przerwane opatrywanie (tu: bot wyłączony w trakcie) to nie porażka, więc pacjent nie trafia na czarną listę
	medbot.bot_mode_flags &= ~BOT_MODE_ON
	TEST_ASSERT_EQUAL(medbot.work_on_target(patient), BOT_WORK_DONE, "Przerwane opatrywanie wpisuje pacjenta na czarną listę")
	medbot.bot_mode_flags |= BOT_MODE_ON
	medbot.on_work_target_found(patient)
	qdel(medbot)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_MEDIBOTCOMINGTHROUGH), "Znacznik pacjenta został po zniszczeniu medibota")

	// Przytulobot nie zajmuje pacjenta medibotom i nie przytula zadowolonych
	var/mob/living/basic/bot/medbot/hugbot/hugbot = allocate(/mob/living/basic/bot/medbot/hugbot, start)
	hugbot.on_work_target_found(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_MEDIBOTCOMINGTHROUGH), "Przytulobot oznaczył pacjenta znacznikiem medibota")
	var/datum/component/mood/mood = patient.GetComponent(/datum/component/mood)
	if(mood)
		mood.sanity = SANITY_GREAT
		TEST_ASSERT(!hugbot.assess_patient(patient), "Przytulobot przytula zadowolonego (poczytalność powyżej progu)")
		mood.sanity = SANITY_UNSTABLE
		TEST_ASSERT(hugbot.assess_patient(patient), "Przytulobot nie przytula smutnego (poczytalność poniżej progu)")
	qdel(hugbot)
	qdel(patient)

	// Atmosbot: wyłom do próżni w /area/space jest wykryty
	var/area/space/space_area = GLOB.areas_by_type[/area/space]
	TEST_ASSERT(space_area, "Brak obszaru /area/space")
	var/area/own_area = next.loc
	var/old_type = next.type
	var/list/old_baseturfs = next.baseturfs
	var/turf/breach_turf = next.ChangeTurf(/turf/open/space)
	space_area.contents += breach_turf
	breach_turf.change_area(own_area, space_area)
	var/mob/living/basic/bot/atmosbot/atmosbot = allocate(/mob/living/basic/bot/atmosbot, start)
	var/turf/found_breach = atmosbot.return_nearest_breach()
	own_area.contents += breach_turf
	breach_turf.change_area(space_area, own_area)
	next = breach_turf.ChangeTurf(old_type, old_baseturfs)
	qdel(atmosbot)
	TEST_ASSERT_EQUAL(found_breach, start, "Atmosbot nie wykrył wyłomu do próżni w /area/space")

	// Digbot kopie skałę, ale nie gibtonit
	var/mob/living/basic/bot/digbot/digbot = allocate(/mob/living/basic/bot/digbot, start)
	var/turf/rock = next.ChangeTurf(/turf/closed/mineral)
	var/rock_ok = digbot.is_valid_work_target(rock)
	var/turf/gibtonite = rock.ChangeTurf(/turf/closed/mineral/gibtonite)
	var/gibtonite_ok = digbot.is_valid_work_target(gibtonite)
	next = gibtonite.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT(rock_ok, "Digbot nie kopie zwykłej skały")
	TEST_ASSERT(!gibtonite_ok, "Digbot kopie gibtonit")

/// AQUILA - BOTY (przegląd): repairbot kładzie płytki tylko z place_tiles i na poszyciu okrętu, ściany stawia tylko na zwykłych dźwigarach, przyjmuje podtypy stosów
/datum/unit_test/aquila_repairbot_tasks

/datum/unit_test/aquila_repairbot_tasks/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next = get_step(start, EAST)
	var/old_type = next.type
	var/list/old_baseturfs = next.baseturfs
	var/mob/living/basic/bot/repairbot/repairbot = allocate(/mob/living/basic/bot/repairbot, start)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human, start)

	// arkusze: najpierw zwykły stos, potem podtyp tego samego stosu (iron/fifty)
	var/obj/item/stack/sheet/iron/iron = allocate(/obj/item/stack/sheet/iron, start, 5)
	engineer.put_in_active_hand(iron)
	repairbot.insert_stack(iron, engineer)
	var/obj/item/stack/sheet/iron/fifty/more_iron = allocate(/obj/item/stack/sheet/iron/fifty, start)
	engineer.put_in_active_hand(more_iron)
	repairbot.insert_stack(more_iron, engineer)
	TEST_ASSERT_EQUAL(repairbot.our_iron?.amount, 50, "Repairbot nie przyjął żelaza z podtypu stosu")

	// płytki specjalne bez place_tiles nie lądują na gołym poszyciu, na asteroidzie wcale
	repairbot.special_tiles = new /obj/item/stack/tile/carpet(repairbot, 10)
	var/turf/plating = next.ChangeTurf(/turf/open/floor/plating)
	var/task_without_setting = repairbot.task_for(plating)
	repairbot.place_tiles = TRUE
	var/task_with_setting = repairbot.task_for(plating)
	var/turf/asteroid = plating.ChangeTurf(/turf/open/floor/plating/asteroid)
	var/task_on_asteroid = repairbot.task_for(asteroid)
	next = asteroid.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT(!task_without_setting, "Repairbot kładzie płytki z wyłączonym place_tiles")
	TEST_ASSERT(task_with_setting, "Repairbot nie kładzie płytek z włączonym place_tiles")
	TEST_ASSERT(!task_on_asteroid, "Repairbot kładzie płytki na asteroidzie")

	// ściana tylko na zwykłym dźwigarze
	var/obj/structure/girder/girder = allocate(/obj/structure/girder, next)
	TEST_ASSERT(repairbot.task_for(girder), "Repairbot nie naprawia zwykłego dźwigara")
	qdel(girder)
	for(var/girder_type in list(/obj/structure/girder/reinforced, /obj/structure/girder/displaced, /obj/structure/girder/cult, /obj/structure/girder/bronze))
		var/obj/structure/girder/other = allocate(girder_type, next)
		TEST_ASSERT(!repairbot.task_for(other), "Repairbot robi zwykłą ścianę z [girder_type]")
		qdel(other)

#undef TICK_BOT_UNTIL
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
