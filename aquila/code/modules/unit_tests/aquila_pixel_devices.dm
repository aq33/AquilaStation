// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message ? message : "No reason"] (expected [b], got [a])") }

// Okna w formie urządzeń (aquila/code/modules/pixel_devices/): akcje okien bez klienta

/// Nieudane pieczenie z graczem: loop() dostawał moba jako trzeci argument (wait), addtimer() padał i mikrofalówka stawała.
/// Do tego okno: dane z ikonami zawartości i wyjęcie jednej rzeczy do ręki.
/datum/unit_test/aquila_pixel_microwave

/datum/unit_test/aquila_pixel_microwave/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/mob/living/carbon/human/cook = allocate(/mob/living/carbon/human, spot)
	var/obj/machinery/microwave/microwave = allocate(/obj/machinery/microwave, spot)
	var/obj/item/food/donkpocket/pocket = allocate(/obj/item/food/donkpocket, microwave)
	microwave.ingredients += pocket

	var/list/data = microwave.ui_data(cook)
	TEST_ASSERT_EQUAL(length(data["items"]), 1, "Microwave window lists a wrong number of items")
	var/list/entry = data["items"][1]
	TEST_ASSERT(entry["icon"], "Microwave window has no icon for the donk pocket")
	TEST_ASSERT(entry["food"], "Donk pocket is not marked as food in the microwave window")

	TEST_ASSERT(microwave.aq_take_ingredient(cook, pocket), "Taking one item out of the microwave window failed")
	TEST_ASSERT(cook.is_holding(pocket), "The item taken out of the microwave is not in the cook's hand")
	TEST_ASSERT(!(pocket in microwave.ingredients), "The item taken out stays on the microwave ingredient list")

	// Nieudane pieczenie (brud) z kucharzem jako argumentem: musi zaplanować kolejny cykl
	microwave.muck(cook)
	TEST_ASSERT(microwave.operating, "Microwave is not running after a mucked start")
	TEST_ASSERT(LAZYLEN(microwave.active_timers), "A mucked start with a cook scheduled no cooking cycle (mob passed as the wait argument)")
	TEST_ASSERT(microwave.aq_cook_end > world.time, "Microwave window gets no end time of the cooking")
	TEST_ASSERT(microwave.ui_data(cook)["time_left"] > 0, "Microwave window shows no time left while cooking")
	TEST_ASSERT(isnull(microwave.ui_data(cook)["done_ago"]), "Microwave window shows READY while still cooking")
	// Udane zakończenie: okno dostaje sygnał GOTOWE
	microwave.loop_finish(cook)
	TEST_ASSERT(!isnull(microwave.ui_data(cook)["done_ago"]), "Microwave window gets no READY signal after a successful cooking")
	microwave.soundloop.stop()

/// Młynek: wrzucenie przedmiotu z ręki przez dzbanek, wyjęcie go z powrotem i naczynie w danych okna
/datum/unit_test/aquila_pixel_grinder

/datum/unit_test/aquila_pixel_grinder/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/mob/living/carbon/human/cook = allocate(/mob/living/carbon/human, spot)
	var/obj/machinery/reagentgrinder/grinder = allocate(/obj/machinery/reagentgrinder, spot)
	var/obj/item/food/grown/tomato/tomato = allocate(/obj/item/food/grown/tomato, spot)
	cook.put_in_active_hand(tomato)

	TEST_ASSERT(grinder.aq_insert_held(cook), "Putting the held tomato into the grinder window failed")
	TEST_ASSERT(grinder.holdingitems[tomato], "The tomato from the hand is not in the grinder")

	var/list/data = grinder.ui_data(cook)
	TEST_ASSERT_EQUAL(length(data["items"]), 1, "Grinder window lists a wrong number of items")
	TEST_ASSERT(data["vessel"], "Grinder window shows no vessel although the grinder starts with a beaker")

	TEST_ASSERT(grinder.aq_take_item(cook, tomato), "Taking the tomato out of the grinder window failed")
	TEST_ASSERT(cook.is_holding(tomato), "The tomato taken out of the grinder is not in the hand")
	TEST_ASSERT(!grinder.holdingitems[tomato], "The tomato stays in the grinder")

	// Łom w trybie walki: okno nic nie wkłada i nie atakuje młynka (attackby z combat mode)
	var/obj/item/crowbar/crowbar = allocate(/obj/item/crowbar, spot)
	qdel(tomato)
	cook.put_in_active_hand(crowbar)
	cook.set_combat_mode(TRUE)
	var/integrity = grinder.obj_integrity
	TEST_ASSERT(!grinder.aq_insert_held(cook), "The grinder window took a crowbar")
	TEST_ASSERT_EQUAL(grinder.obj_integrity, integrity, "Clicking the grinder window with a crowbar in combat mode damaged the grinder")
	TEST_ASSERT(cook.is_holding(crowbar), "The crowbar left the hand")

/// Blok utylizacyjny: kliknięcie otworu wkłada przedmiot z ręki, pustą ręką wyjmuje ostatni
/datum/unit_test/aquila_pixel_disposal

/datum/unit_test/aquila_pixel_disposal/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/mob/living/carbon/human/janitor = allocate(/mob/living/carbon/human, spot)
	var/obj/machinery/disposal/bin/bin = allocate(/obj/machinery/disposal/bin, spot)
	var/obj/item/trash/can/can = allocate(/obj/item/trash/can, spot)
	janitor.put_in_active_hand(can)

	TEST_ASSERT(bin.aq_mouth(janitor), "Putting the held can into the disposal window failed")
	TEST_ASSERT_EQUAL(can.loc, bin, "The can from the hand is not in the disposal unit")
	TEST_ASSERT_EQUAL(length(bin.ui_data(janitor)["items"]), 1, "Disposal window lists a wrong number of items")

	TEST_ASSERT(bin.aq_mouth(janitor), "Taking the last item out with an empty hand failed")
	TEST_ASSERT(janitor.is_holding(can), "The can taken out of the disposal unit is not in the hand")

	// Worek na śmieci przez otwór: opróżnia się do środka i zostaje w ręce, jak przy kliknięciu maszyny
	var/obj/item/storage/bag/trash/bag = allocate(/obj/item/storage/bag/trash, spot)
	can.forceMove(bag)
	janitor.put_in_active_hand(bag)
	TEST_ASSERT(bin.aq_mouth(janitor), "Emptying the trash bag through the disposal window failed")
	TEST_ASSERT(janitor.is_holding(bag), "The trash bag went into the disposal unit instead of being emptied")
	TEST_ASSERT_EQUAL(can.loc, bin, "The trash from the bag is not in the disposal unit")

/// Dozownik napojów: WYLEJ opróżnia naczynie, lód ma strumień kostek, STARE OKNO przełącza na stare okno do jego zamknięcia
/datum/unit_test/aquila_pixel_bar_dispenser

/datum/unit_test/aquila_pixel_bar_dispenser/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/mob/living/carbon/human/bartender = allocate(/mob/living/carbon/human, spot)
	var/obj/machinery/chem_dispenser/drinks/dispenser = allocate(/obj/machinery/chem_dispenser/drinks, spot)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass, dispenser)
	glass.reagents.add_reagent(/datum/reagent/consumable/space_cola, 20)
	dispenser.beaker = glass

	var/list/data = dispenser.ui_data(bartender)
	var/datum/reagent/ice = GLOB.chemical_reagents_list[/datum/reagent/consumable/ice]
	TEST_ASSERT_EQUAL(data["kinds"][ckey(ice.name)], "ice", "Ice in the drinks dispenser window does not fall as cubes")
	TEST_ASSERT(!data["bottles"], "The soda dispenser shows a bottle shelf")

	// Strumień w oknie tylko po potwierdzonym dolaniu do tego samego naczynia: prawdziwa akcja "dispense" z okna
	var/datum/reagent/cola = GLOB.chemical_reagents_list[/datum/reagent/consumable/space_cola]
	var/list/pour_params = list("reagent" = ckey(cola.name))
	var/datum/tgui/ui = new(bartender, dispenser, "BarDispenserDevice")
	usr = bartender
	var/serial = dispenser.aq_pour_serial
	var/volume_before = glass.reagents.total_volume
	dispenser.ui_act("dispense", pour_params, ui)
	TEST_ASSERT(glass.reagents.total_volume > volume_before, "The dispense action poured nothing into the glass")
	TEST_ASSERT_EQUAL(dispenser.aq_pour_serial, serial + 1, "The pour counter did not grow after a successful dose")
	TEST_ASSERT_EQUAL(dispenser.ui_data(bartender)["pourReagent"], ckey(cola.name), "The window gets a wrong drink for the stream")
	// Za mało energii: dozownik odmawia, licznik stoi
	var/charge = dispenser.cell.charge
	dispenser.cell.charge = 1
	volume_before = glass.reagents.total_volume
	dispenser.ui_act("dispense", pour_params, ui)
	TEST_ASSERT_EQUAL(glass.reagents.total_volume, volume_before, "The dispenser poured without enough energy")
	TEST_ASSERT_EQUAL(dispenser.aq_pour_serial, serial + 1, "The pour counter grew for a dose rejected for lack of energy")
	dispenser.cell.charge = charge
	// Podmienione pełniejsze naczynie nie jest dolaniem
	var/obj/item/reagent_containers/food/drinks/drinkingglass/other = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass)
	TEST_ASSERT(!dispenser.aq_note_pour(other, 0, ckey(cola.name)), "A swapped, fuller glass counts as a pour")
	usr = null
	qdel(ui)
	TEST_ASSERT(dispenser.aq_drain(), "Draining the glass from the dispenser window failed")
	TEST_ASSERT_EQUAL(glass.reagents.total_volume, 0, "The glass is not empty after WYLEJ")

	TEST_ASSERT(!dispenser.aq_wants_classic_ui(bartender), "A fresh dispenser opens the old window")
	LAZYOR(dispenser.aq_classic_ui_users, REF(bartender))
	TEST_ASSERT(dispenser.aq_wants_classic_ui(bartender), "The old window switch is not remembered")
	dispenser.ui_close(bartender)
	TEST_ASSERT(!dispenser.aq_wants_classic_ui(bartender), "Closing the old window does not bring the device window back")
	dispenser.beaker = null

/// Fabrykatory: pulpit domyślnie, stare okno po przełączeniu, STOP przytrzymany czyści kolejkę, dane wydruku dla plotera
/datum/unit_test/aquila_pixel_fabricator

/datum/unit_test/aquila_pixel_fabricator/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human, spot)
	var/obj/machinery/modular_fabricator/autolathe/lathe = allocate(/obj/machinery/modular_fabricator/autolathe, spot)
	TEST_ASSERT_EQUAL(lathe.aq_fabricator_interface(engineer, "ModularFabricator"), "LathePulpit", "Autolathe does not open the operator console")
	LAZYOR(lathe.aq_classic_ui_users, REF(engineer))
	TEST_ASSERT_EQUAL(lathe.aq_fabricator_interface(engineer, "ModularFabricator"), "ModularFabricator", "Autolathe ignores the old window switch")
	lathe.ui_close(engineer)

	TEST_ASSERT(lathe.ui_static_data(engineer)["queued"], "Autolathe console does not know it has a queue")
	var/datum/design/design = SSresearch.techweb_design_by_id(lathe.stored_research.researched_designs[1])
	TEST_ASSERT(design, "Autolathe has no researched design")
	lathe.queue_stopped = TRUE
	lathe.add_to_queue(lathe.item_queue, design.id, 2)
	TEST_ASSERT(length(lathe.item_queue), "The design did not get into the autolathe queue")
	TEST_ASSERT(lathe.aq_stop_all(), "STOP held on the console failed")
	TEST_ASSERT(!length(lathe.item_queue), "STOP held did not clear the autolathe queue")

	// Ploter: dane bieżącego wydruku
	lathe.being_built = design
	lathe.busy = TRUE
	lathe.total_build_time = 50
	lathe.process_completion_world_tick = world.time + 25
	var/list/printing = lathe.ui_data(engineer)["printing"]
	TEST_ASSERT(printing, "Autolathe console gets no data of the item being printed")
	TEST_ASSERT_EQUAL(printing["id"], design.id, "Autolathe console plots a wrong design")
	// Czekanie na materiały (being_built bez busy) to nie wydruk
	lathe.busy = FALSE
	TEST_ASSERT(!lathe.ui_data(engineer)["printing"], "Autolathe console shows a print while it only waits for materials")
	lathe.being_built = null

	var/obj/machinery/rnd/production/protolathe/protolathe = allocate(/obj/machinery/rnd/production/protolathe, spot)
	TEST_ASSERT(!protolathe.ui_static_data(engineer)["queued"], "Protolathe console shows a queue it does not have")
	TEST_ASSERT_EQUAL(protolathe.aq_fabricator_interface(engineer, "Fabricator"), "LathePulpit", "Protolathe does not open the operator console")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
