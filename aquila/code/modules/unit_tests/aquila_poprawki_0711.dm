// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message ? message : "No reason"] (expected [b], got [a])") }

/// Wybuch implantu karnego CE zostawia mózg: wcześniej gib(1) kasował mózg i gracz wypadał z rundy.
/// Sonda zapisuje argument gib() zamiast rozrywać ciało: prawdziwe gibs rozrzucają części i krew asynchronicznie,
/// a krew lądowała na podłodze testowej po sprzątaniu i psuła późniejsze testy (aquila_review_bloody_floors)
/datum/unit_test/aquila_engineering_implant_keeps_brain

/mob/living/carbon/human/aquila_gib_probe
	/// Argument no_brain ostatniego gib(), null = gib() nie było
	var/gib_no_brain

/mob/living/carbon/human/aquila_gib_probe/gib(no_brain, no_organs, no_bodyparts)
	gib_no_brain = !!no_brain

/datum/unit_test/aquila_engineering_implant_keeps_brain/Run()
	var/mob/living/carbon/human/aquila_gib_probe/engineer = allocate(/mob/living/carbon/human/aquila_gib_probe)
	var/obj/item/implant/explosive/engineering/chip = new
	TEST_ASSERT(chip.implant(engineer, null, TRUE), "Engineering implant did not implant")
	// Bez fali wybuchu w teście
	chip.heavy = 0
	chip.medium = 0
	chip.weak = 0
	chip.activate("stormdrive")
	TEST_ASSERT(!isnull(engineer.gib_no_brain), "The implant did not gib its host")
	TEST_ASSERT(!engineer.gib_no_brain, "The engineering implant destroys the brain, the player leaves the round")
	// Zwykła mikrobomba dalej kasuje mózg
	var/mob/living/carbon/human/aquila_gib_probe/agent = allocate(/mob/living/carbon/human/aquila_gib_probe)
	var/obj/item/implant/explosive/bomb = new
	TEST_ASSERT(bomb.implant(agent, null, TRUE), "Microbomb did not implant")
	bomb.heavy = 0
	bomb.medium = 0
	bomb.weak = 0
	bomb.activate("death")
	TEST_ASSERT(agent.gib_no_brain, "The regular microbomb started keeping the brain")

/// Demon impulsu nie przepycha kanistrów, pod którymi przechodzi po kablu (Bump -> PushAM)
/datum/unit_test/aquila_pulse_demon_does_not_push

/datum/unit_test/aquila_pulse_demon_does_not_push/Run()
	var/mob/living/simple_animal/pulse_demon/demon = allocate(/mob/living/simple_animal/pulse_demon, run_loc_floor_bottom_left)
	var/turf/canister_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/obj/machinery/portable_atmospherics/canister/canister = allocate(/obj/machinery/portable_atmospherics/canister, canister_turf)
	demon.Bump(canister)
	TEST_ASSERT_EQUAL(canister.loc, canister_turf, "Pulse demon pushed a canister")
	TEST_ASSERT(demon.Process_Spacemove(EAST), "Pulse demon cannot move without gravity")
	TEST_ASSERT_EQUAL(canister.loc, canister_turf, "Pulse demon pushed off a canister in zero gravity")

/// Okno roli pokazuje samouczek z greet(), a nie tylko nazwę i cele (demon impulsu nie miał opisu w oknie)
/datum/unit_test/aquila_antag_info_greeting

/datum/unit_test/aquila_antag_info_greeting/Run()
	var/mob/living/carbon/human/player = allocate(/mob/living/carbon/human)
	player.mind_initialize()
	var/datum/antagonist/pulse_demon/demon = player.mind.add_antag_datum(/datum/antagonist/pulse_demon)
	TEST_ASSERT(demon, "Could not give the pulse demon role")
	var/intro = demon.get_antag_intro()
	TEST_ASSERT(findtext(intro, "Przejmuj APC"), "Pulse demon info window has no tutorial: [intro]")
	TEST_ASSERT(!findtext(intro, "Twoje obecne cele"), "Objectives leaked into the greeting, the window shows them separately")
	TEST_ASSERT(isnull(GLOB.antag_greeting_capture), "Greeting capture was left running after greet()")
	player.mind.remove_antag_datum(/datum/antagonist/pulse_demon)

/// Pełny schowek bez siatki: puste pola na czerwono, ale komplet sztuk (pas 7/7) bez czerwieni, bo nie ma pustych pól
/datum/unit_test/aquila_storage_full_slots_red

/datum/unit_test/aquila_storage_full_slots_red/Run()
	var/obj/item/storage/belt/utility/belt = allocate(/obj/item/storage/belt/utility)
	var/datum/component/storage/storage = belt.GetComponent(/datum/component/storage)
	TEST_ASSERT(storage, "Belt has no storage")
	if(istype(storage, /datum/component/storage/concrete/grid))
		var/datum/component/storage/concrete/grid/grid = storage
		TEST_ASSERT(!grid.grid_width, "Utility belt became a grid storage, pick another old-style storage")
	for(var/obj/item/thing in belt)
		qdel(thing)
	// Limit wagi wyczerpany, a pola wolne: wolne pola na czerwono
	storage.max_items = 7
	storage.max_combined_w_class = WEIGHT_CLASS_TINY
	storage.orient2hud()
	TEST_ASSERT(isnull(storage.boxes.color), "Empty belt slots are red")
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver, belt)
	tool.w_class = WEIGHT_CLASS_TINY
	storage.orient2hud()
	TEST_ASSERT_EQUAL(storage.boxes.color, "#ee7b7b", "Belt at its weight limit does not mark free slots red")
	// Komplet sztuk: żadne pole nie jest puste, więc nic nie jest czerwone
	storage.max_items = 1
	storage.orient2hud()
	TEST_ASSERT(isnull(storage.boxes.color), "Belt with every slot taken is red although it has no free slot")
	storage.max_items = 7
	qdel(tool)
	storage.orient2hud()
	TEST_ASSERT(isnull(storage.boxes.color), "Belt slots stay red after taking the item out")

/// Pieróg w mikrofali nie jest czarną sylwetką: kopia wyglądu składnika nie niesie blokera emisji
/datum/unit_test/aquila_microwave_ingredient_not_black

/datum/unit_test/aquila_microwave_ingredient_not_black/Run()
	var/obj/machinery/microwave/microwave = allocate(/obj/machinery/microwave, run_loc_floor_bottom_left)
	var/obj/item/food/donkpocket/pierog = allocate(/obj/item/food/donkpocket, microwave)
	microwave.ingredients += pierog
	var/found_ingredient = FALSE
	for(var/image/ingredient_overlay in microwave.update_overlays())
		if(ingredient_overlay.blend_mode != BLEND_INSET_OVERLAY)
			continue
		found_ingredient = TRUE
		for(var/image/sub_overlay as anything in ingredient_overlay.overlays)
			TEST_ASSERT(sub_overlay.plane != EMISSIVE_PLANE, "Microwave ingredient overlay keeps the black emissive blocker")
	TEST_ASSERT(found_ingredient, "Microwave did not draw the ingredient behind its door")
	microwave.ingredients -= pierog

/// Błąd w greet() nie zostawia globalnego wskaźnika zbierania powitania na roli
/datum/unit_test/aquila_antag_greeting_crash_releases_capture

/datum/antagonist/aquila_greet_crash_probe
	name = "sonda testu powitania"
	show_in_antagpanel = FALSE
	banning_key = UNBANNABLE_ANTAGONIST // antag_datum_sanity sprawdza każdy podtyp /datum/antagonist

/datum/antagonist/aquila_greet_crash_probe/greet()
	CRASH("Celowy błąd w greet() (test aquila_antag_greeting_crash_releases_capture)")

/datum/unit_test/aquila_antag_greeting_crash_releases_capture/Run()
	var/datum/antagonist/aquila_greet_crash_probe/probe = new
	var/crashed = FALSE
	try
		probe.greet_and_capture()
	catch
		crashed = TRUE
	qdel(probe)
	TEST_ASSERT(crashed, "The probe greet() did not throw, the test checks nothing")
	TEST_ASSERT(isnull(GLOB.antag_greeting_capture), "Greeting capture still points at a role whose greet() crashed")

/// Konsola łączności poza poziomem ze znacznikiem stacji: działa na statku załogi (górniczy, główny), nie na obcym
/datum/unit_test/aquila_comms_console_on_crew_ship
	var/datum/turf_reservation/comms_reservation
	/// Statek testu; Destroy() przywraca mu zwykłą rolę, bo usunięcie statku z rolą MAIN_OVERMAP kończy rundę
	/// (overmap.dm: „statek zniszczony”), a wtedy CI nie uruchamia już żadnego z dalszych testów
	var/obj/structure/overmap/probe_ship

/obj/machinery/computer/communications/aquila_probe
	/// Statek, który zwraca get_overmap() w teście
	var/obj/structure/overmap/probe_ship

/obj/machinery/computer/communications/aquila_probe/get_overmap(failsafe = FALSE)
	return probe_ship

/// Bez broni, żeby nic w teście nie strzelało
/obj/structure/overmap/syndicate/ai/gunboat/aquila_comms_probe
	missiles = 0
	shots_left = 0
	torpedoes = 0

/obj/structure/overmap/syndicate/ai/gunboat/aquila_comms_probe/apply_weapons()
	return

/datum/unit_test/aquila_comms_console_on_crew_ship/Run()
	comms_reservation = SSmapping.RequestBlockReservation(3, 3)
	TEST_ASSERT(comms_reservation, "Could not reserve turfs off the station level")
	var/turf/off_station = locate(comms_reservation.bottom_left_coords[1] + 1, comms_reservation.bottom_left_coords[2] + 1, comms_reservation.bottom_left_coords[3])
	TEST_ASSERT(!is_station_level(off_station.z), "The reserved block is on a station level, the test checks nothing")
	var/obj/machinery/computer/communications/aquila_probe/console = allocate(/obj/machinery/computer/communications/aquila_probe, off_station)
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/aquila_comms_probe)
	probe_ship = ship
	console.probe_ship = ship
	ship.role = NORMAL_OVERMAP
	TEST_ASSERT(!console.has_communication(), "A console on a foreign ship off the station level has communication")
	ship.role = MAIN_MINING_SHIP
	TEST_ASSERT(console.has_communication(), "The console on the mining ship shows no connection to the ship")
	ship.role = MAIN_OVERMAP
	var/main_ship_ok = console.has_communication()
	// Rola wraca przed sprzątaniem: usunięty statek z MAIN_OVERMAP to zniszczony okręt gracza i koniec rundy w środku testów
	ship.role = NORMAL_OVERMAP
	TEST_ASSERT(main_ship_ok, "The console on the main ship loaded off the station level shows no connection")
	console.probe_ship = null

/datum/unit_test/aquila_comms_console_on_crew_ship/Destroy()
	// Także gdy asercja przerwała Run() przy roli MAIN_OVERMAP: allocate() usuwa statek w ..()
	if(probe_ship)
		probe_ship.role = NORMAL_OVERMAP
		probe_ship = null
	QDEL_NULL(comms_reservation)
	return ..()

/// Moduł zsypu MOD losuje numer celu, nie nazwę: zsyp porównuje liczby, a okno konfiguracji czyta TAGGERLOCATIONS[disposal_tag]
/datum/unit_test/aquila_mod_disposal_tag_is_number

/datum/unit_test/aquila_mod_disposal_tag_is_number/Run()
	var/obj/item/mod/module/disposal_connector/connector = allocate(/obj/item/mod/module/disposal_connector)
	TEST_ASSERT(isnum(connector.disposal_tag), "MOD disposal connector tag is not a number: [connector.disposal_tag]")
	TEST_ASSERT(connector.disposal_tag >= 1 && connector.disposal_tag <= length(GLOB.TAGGERLOCATIONS), "MOD disposal connector tag [connector.disposal_tag] is outside TAGGERLOCATIONS")

/// Radial SS14: najbliższa szerokość sektora, podświetlenie sektora pod myszą po zmianie strony, przyciski info nie narastają
/datum/unit_test/aquila_radial_ss14

/datum/unit_test/aquila_radial_ss14/Run()
	var/datum/radial_menu/menu = new
	TEST_ASSERT_EQUAL(menu.radial_sector_state(50), "sector_51", "Sector width 50 does not snap to the nearest state")
	TEST_ASSERT_EQUAL(menu.radial_sector_state(360), "sector_360", "Full circle does not use the full disc")
	var/list/choices = list()
	for(var/i in 1 to 10)
		var/datum/radial_menu_choice/choice = new
		choice.image = image('icons/mob/radial.dmi', "radial_next")
		choice.info = "opis [i]"
		choices["opcja [i]"] = choice
	menu.anchor = run_loc_floor_bottom_left
	menu.set_choices(choices)
	TEST_ASSERT(menu.ss14_style, "Menu without radial_icon is not in the SS14 style")
	TEST_ASSERT(menu.pages > 1, "10 choices did not make a second page")
	var/atom/movable/screen/radial/slice/hovered = menu.elements[1]
	// Stan po najechaniu myszą (MouseEntered bez klienta nie działa: screentips czytają usr.client)
	hovered.icon_state = "[hovered.sector_state]_focus"
	menu.show_title(hovered)
	for(var/i in 1 to 3)
		menu.next_page()
	TEST_ASSERT_EQUAL(hovered.icon_state, "[hovered.sector_state]_focus", "Hovered sector lost its highlight after a page change")
	var/info_buttons = 0
	for(var/obj/effect/abstract/info/info_button in hovered.icon_holder)
		info_buttons++
	TEST_ASSERT(info_buttons <= 1, "Info buttons pile up in the choice icon holder: [info_buttons]")
	qdel(menu)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
