// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the shift starts at 7:00, night ends at 7:00, and the captain's switch keeps night lighting off
/datum/unit_test/aquila_nightshift_captain

/datum/unit_test/aquila_nightshift_captain/Run()
	var/datum/controller/subsystem/ticker/ticker = SSticker
	TEST_ASSERT_EQUAL(initial(ticker.gametime_offset), 7 HOURS, "The shift does not start at 7:00")
	TEST_ASSERT_EQUAL(SSnightshift.nightshift_end_time, 7 HOURS, "Night lighting does not end at 7:00")

	var/old_disabled = SSnightshift.captain_disabled
	var/old_active = SSnightshift.nightshift_active
	SSnightshift.captain_disabled = TRUE
	SSnightshift.nightshift_active = TRUE
	SSnightshift.check_nightshift()
	TEST_ASSERT(!SSnightshift.nightshift_active, "Night lighting stayed on after the captain disabled it")
	SSnightshift.captain_disabled = old_disabled
	SSnightshift.update_nightshift(old_active, FALSE)

/// AQUILA - every votable map has a size, and the vote label shows it in brackets
/datum/unit_test/aquila_map_vote_size

/datum/unit_test/aquila_map_vote_size/Run()
	var/datum/map_config/test_map = new
	test_map.map_name = "Testowa"
	TEST_ASSERT_EQUAL(test_map.get_vote_label(), "Testowa", "A map without a size got a bracket")
	test_map.map_size = "mała"
	TEST_ASSERT_EQUAL(test_map.get_vote_label(), "Testowa (mała)", "The map size is not in the vote label")
	qdel(test_map)

	for(var/map in config.maplist)
		var/datum/map_config/map_config = config.maplist[map]
		if(map_config.votable)
			TEST_ASSERT(map_config.map_size, "Votable map [map_config.map_name] has no map_size in its JSON")

/// AQUILA - a stack shows its amount while carried and hides it on the floor
/datum/unit_test/aquila_stack_amount_maptext

/datum/unit_test/aquila_stack_amount_maptext/Run()
	var/mob/living/carbon/human/holder = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/stack/sheet/iron/iron = allocate(/obj/item/stack/sheet/iron, run_loc_floor_bottom_left, 5)
	TEST_ASSERT(!iron.maptext, "A stack on the floor shows its amount")
	holder.put_in_active_hand(iron)
	TEST_ASSERT(findtext(iron.maptext, "5"), "A held stack does not show its amount")
	iron.use(2)
	TEST_ASSERT(findtext(iron.maptext, "3"), "The amount did not update after using the stack")
	holder.dropItemToGround(iron)
	TEST_ASSERT(!iron.maptext, "A dropped stack still shows its amount")
	// Opening a bag redraws its contents and used to wipe the amount: both the grid and the plain storage view keep it
	var/obj/item/storage/backpack/bag = allocate(/obj/item/storage/backpack, run_loc_floor_bottom_left)
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, iron, null, TRUE), "The stack did not fit into a backpack")
	var/datum/component/storage/bag_storage = bag.GetComponent(/datum/component/storage)
	bag_storage.orient2hud()
	TEST_ASSERT(findtext(iron.maptext, "3"), "A stack in an open grid backpack does not show its amount")
	// Santa's bag keeps the plain storage view (no grid)
	var/obj/item/storage/backpack/santabag/sack = allocate(/obj/item/storage/backpack/santabag, run_loc_floor_bottom_left)
	var/datum/component/storage/sack_storage = sack.GetComponent(/datum/component/storage)
	TEST_ASSERT(!istype(sack_storage, /datum/component/storage/concrete/grid), "Santa's bag got a grid, pick another plain storage for this test")
	sack_storage.max_w_class = WEIGHT_CLASS_HUGE
	var/obj/item/stack/sheet/iron/sacked = allocate(/obj/item/stack/sheet/iron, run_loc_floor_bottom_left, 4)
	TEST_ASSERT(SEND_SIGNAL(sack, COMSIG_TRY_STORAGE_INSERT, sacked, null, TRUE), "The stack did not fit into a plain bag")
	sack_storage.orient2hud()
	TEST_ASSERT(findtext(sacked.maptext, "4"), "A stack in an open plain bag does not show its amount")
	// A stack created in nullspace (crafting, vendors) has no loc to ask about storage
	var/obj/item/stack/sheet/iron/nowhere = new(null, 3)
	var/nowhere_maptext = nowhere.maptext
	qdel(nowhere)
	TEST_ASSERT(!nowhere_maptext, "A stack in nullspace shows its amount")

/// AQUILA - the tg fire alarm loop plays while the area burns and stops on reset
/datum/unit_test/aquila_firealarm_sound

/datum/unit_test/aquila_firealarm_sound/Run()
	var/obj/machinery/firealarm/alarm = allocate(/obj/machinery/firealarm, run_loc_floor_bottom_left)
	var/area/test_area = get_area(alarm)
	alarm.alarm()
	TEST_ASSERT(test_area.fire, "The fire alarm did not set off the area")
	TEST_ASSERT(alarm.soundloop?.timerid, "The fire alarm loop did not start")
	// Power loss stops the loop at its next tick, power coming back restarts it while the alarm lasts
	alarm.set_is_operational(FALSE)
	alarm.soundloop.sound_loop(world.time)
	TEST_ASSERT(!alarm.soundloop.timerid, "The fire alarm loop kept playing without power")
	alarm.set_is_operational(TRUE)
	TEST_ASSERT(alarm.soundloop.timerid, "The fire alarm loop did not restart after power came back")
	alarm.reset()
	TEST_ASSERT(!alarm.soundloop.timerid, "The fire alarm loop did not stop on reset")
	TEST_ASSERT(!alarm.should_sound_alarm(), "The alarm still wants to sound after reset")
	// An emagged alarm pulled by hand still sounds (as in tg and before the loop)
	alarm.obj_flags |= EMAGGED
	alarm.last_alarm = 0
	alarm.alarm()
	TEST_ASSERT(alarm.soundloop.timerid, "A pulled emagged fire alarm stayed silent")
	alarm.reset()

/// AQUILA - the map vote window gets the map size next to the name, the HUD has the memory button
/datum/unit_test/aquila_map_vote_label_hud

/datum/unit_test/aquila_map_vote_label_hud/Run()
	var/datum/map_config/votable
	for(var/map in config.maplist)
		var/datum/map_config/candidate = config.maplist[map]
		if(candidate.votable && candidate.map_size)
			votable = candidate
			break
	TEST_ASSERT(votable, "No votable map with a size to test the vote label")
	var/mob/living/carbon/human/voter = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/vote/old_vote = SSvote.current_vote
	var/datum/vote/map/test_vote = new
	test_vote.choices = list("[votable.map_name]" = 0)
	SSvote.current_vote = test_vote
	var/list/data = SSvote.ui_data(voter)
	SSvote.current_vote = old_vote
	qdel(test_vote)
	var/list/choices = data["choices"]
	TEST_ASSERT(length(choices) == 1, "The map vote window got no choices")
	var/list/choice = choices[1]
	TEST_ASSERT_EQUAL(choice["label"], votable.get_vote_label(), "The map vote window does not show the map size")
	TEST_ASSERT_EQUAL(choice["name"], votable.map_name, "The map vote key changed, so the vote would not pick the map")

	var/datum/hud/human/hud = new(voter)
	var/found = locate(/atom/movable/screen/memories) in hud.static_inventory
	qdel(hud)
	TEST_ASSERT(found, "The human HUD has no memory button")

/// AQUILA - humans get a blinking eyelid in their skin colour
/datum/unit_test/aquila_eyelids

/datum/unit_test/aquila_eyelids/Run()
	var/mob/living/carbon/human/blinker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	blinker.update_body()
	TEST_ASSERT(blinker.eyelid, "A human has no eyelid")
	TEST_ASSERT(blinker.eyelid in blinker.vis_contents, "The eyelid is not in vis_contents")
	TEST_ASSERT(blinker.get_eyelid_color(blinker.get_bodypart(BODY_ZONE_HEAD), blinker.getorganslot(ORGAN_SLOT_EYES)), "A human head has no eyelid colour")
	// Species colours may already carry a „#” (copper golem fixed_mut_color = "#d95802"); it used to become "##d95802" and runtime
	var/obj/item/bodypart/head/head = blinker.get_bodypart(BODY_ZONE_HEAD)
	var/old_color = head.draw_color
	head.draw_color = "#d95802"
	var/hash_color = blinker.get_eyelid_color(head, blinker.getorganslot(ORGAN_SLOT_EYES))
	head.draw_color = old_color
	TEST_ASSERT(hash_color, "A skin colour with a leading # gives no eyelid colour")

/// AQUILA - scientists start with an anomaly neutralizer, public defecation is in space law
/datum/unit_test/aquila_scientist_space_law

/datum/unit_test/aquila_scientist_space_law/Run()
	var/datum/outfit/job/scientist/outfit = new
	TEST_ASSERT(outfit.backpack_contents?[/obj/item/anomaly_neutralizer], "Scientists do not start with an anomaly neutralizer")
	qdel(outfit)

	var/found = FALSE
	for(var/list/category in get_space_law_catalog())
		if(category["name"] != "Wykroczenia")
			continue
		for(var/list/crime in category["crimes"])
			if(crime["name"] == "Załatwianie potrzeby w miejscu publicznym")
				found = TRUE
	TEST_ASSERT(found, "Public defecation is not a minor crime in space law")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
