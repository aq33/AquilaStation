// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define BUTT_CTRL_CLICK_PARAMS "icon-x=16;icon-y=16;left=1;button=left;ctrl=1"

/// AQUILA - zgłoszenie 24.11: Ctrl+klik w krocze postaci bez kombinezonu (bez trybu walki) otwiera schowek w tyłku
/datum/unit_test/aquila_butt_peek_ctrl_click
	var/shown_to

/datum/unit_test/aquila_butt_peek_ctrl_click/proc/on_show(datum/source, mob/viewer)
	SIGNAL_HANDLER
	shown_to = viewer

/datum/unit_test/aquila_butt_peek_ctrl_click/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/organ/butt/butt = victim.getorganslot(ORGAN_SLOT_BUTT)
	TEST_ASSERT(butt?.inv, "Test human has no butt pocket")
	TEST_ASSERT(!victim.w_uniform, "Test human wears a jumpsuit")
	set_test_controls(user, FALSE)
	user.set_combat_mode(FALSE)
	user.zone_selected = BODY_ZONE_PRECISE_GROIN
	RegisterSignal(butt.inv, COMSIG_TRY_STORAGE_SHOW, PROC_REF(on_show))
	user.ClickOn(victim, BUTT_CTRL_CLICK_PARAMS)
	UnregisterSignal(butt.inv, COMSIG_TRY_STORAGE_SHOW)
	QDEL_NULL(user.mock_client)
	TEST_ASSERT(shown_to == user, "Ctrl+click on the groin did not open the butt pocket (user pulling victim: [user.pulling == victim])")

/// AQUILA - zgłoszenie 24.11: zwykła kupa nie przewraca biegnącego, tylko brudzi mu buty
/datum/unit_test/aquila_feces_not_slippery

/datum/unit_test/aquila_feces_not_slippery/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/poop_turf = get_step(start, EAST)
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, start)
	runner.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(runner), ITEM_SLOT_FEET)
	runner.m_intent = MOVE_INTENT_RUN
	allocate(/obj/effect/decal/cleanable/feces, poop_turf)
	// Sala testowa jest bez grawitacji, a poślizg i ślady jej wymagają (TRAIT_NEGATES_GRAVITY chroniłby przed poślizgiem)
	var/area/room = get_area(start)
	var/old_gravity = room.has_gravity
	room.has_gravity = STANDARD_GRAVITY
	var/moved = runner.Move(poop_turf, EAST)
	var/knocked_down = runner.IsKnockdown()
	room.has_gravity = old_gravity
	TEST_ASSERT(moved, "Runner did not step onto the feces")
	TEST_ASSERT(!knocked_down, "Running onto feces knocked the runner down")
	var/obj/item/clothing/shoes/shoes = runner.shoes
	TEST_ASSERT(shoes.bloody_shoes[BLOOD_STATE_POOP] > 0, "Running onto feces did not dirty the shoes")

/// AQUILA - zgłoszenie 24.11: biegunka (rzadka kupa) dalej jest śliska dla biegnącego
/datum/unit_test/aquila_diarrhea_slippery

/datum/unit_test/aquila_diarrhea_slippery/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/poop_turf = get_step(start, EAST)
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, start)
	runner.m_intent = MOVE_INTENT_RUN
	var/obj/effect/decal/cleanable/feces/diarrhea = allocate(/obj/effect/decal/cleanable/feces, poop_turf)
	diarrhea.make_diarrhea()
	var/area/room = get_area(start)
	var/old_gravity = room.has_gravity
	room.has_gravity = STANDARD_GRAVITY
	runner.Move(poop_turf, EAST)
	var/knocked_down = runner.IsKnockdown()
	room.has_gravity = old_gravity
	TEST_ASSERT(knocked_down, "Running onto diarrhea did not knock the runner down")

/datum/unit_test/aquila_feces_not_slippery/Destroy()
	for(var/turf/room_turf as anything in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		for(var/obj/effect/decal/cleanable/leftover in room_turf)
			qdel(leftover)
	return ..()

#undef BUTT_CTRL_CLICK_PARAMS
#undef TEST_ASSERT
