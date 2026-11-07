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

/// Pełny schowek bez siatki: puste pola na czerwono
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
	storage.max_items = 1
	storage.orient2hud()
	TEST_ASSERT(isnull(storage.boxes.color), "Empty belt slots are red")
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver, belt)
	storage.orient2hud()
	TEST_ASSERT_EQUAL(storage.boxes.color, "#ee7b7b", "Full belt does not mark free slots red")
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

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
