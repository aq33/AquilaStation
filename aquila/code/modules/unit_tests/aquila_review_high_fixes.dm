// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA: regression tests for the high-effort review of aq33/AquilaStation#613 (target search backoff, idling, voice
/// commands, lazarus, gutlunch overlay)
/datum/unit_test/aquila_review_high_fixes

/datum/unit_test/aquila_review_high_fixes/Run()
	// Target search backoff stays short and a waking controller searches at the normal rate again
	var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, run_loc_floor_bottom_left)
	var/datum/ai_controller/controller = bear.ai_controller
	var/datum/ai_behavior/find_potential_targets/finder = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	controller.set_blackboard_key(BB_FIND_TARGETS_EMPTY_SCANS, 10)
	TEST_ASSERT(finder.get_cooldown(controller) <= 8 SECONDS, "after many empty scans a mob waits [finder.get_cooldown(controller) / 10] s before looking for targets")
	controller.set_ai_status(AI_STATUS_OFF)
	controller.set_ai_status(AI_STATUS_ON)
	TEST_ASSERT(!controller.blackboard[BB_FIND_TARGETS_EMPTY_SCANS], "a controller waking up kept its target search backoff")

	// A busy controller (pet command, queued behaviour) does not go idle away from players
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/dog_controller = corgi.ai_controller
	TEST_ASSERT(dog_controller.should_idle(), "a corgi with no player around and nothing to do does not idle")
	var/datum/pet_command/follow/active_command = new(corgi)
	dog_controller.set_blackboard_key(BB_ACTIVE_PET_COMMAND, active_command)
	TEST_ASSERT(!dog_controller.should_idle(), "a corgi with an active pet command goes idle")
	dog_controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	qdel(active_command)

	// Voice commands: common imperative forms and Polish capitals
	var/datum/pet_command/idle/sit = new(corgi)
	var/datum/pet_command/follow/heel = new(corgi)
	TEST_ASSERT(sit.find_command_in_text("Siadaj!"), "\"Siadaj!\" is not the sit command")
	TEST_ASSERT(sit.find_command_in_text("ZOSTAŃ"), "\"ZOSTAŃ\" is not the stay command")
	TEST_ASSERT(heel.find_command_in_text("Do mnie, piesku"), "\"Do mnie\" is not the follow command")
	TEST_ASSERT(!sit.find_command_in_text("To mój sąsiad."), "\"sąsiad\" triggered the sit command again")
	qdel(sit)
	qdel(heel)

	// A malfunctioning lazarus injector leaves the revived mob loyal to the reviver only
	var/mob/living/carbon/human/old_owner = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/reviver = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTHEAST))
	var/mob/living/basic/pet/dog/corgi/pet = allocate(/mob/living/basic/pet/dog/corgi, get_step(run_loc_floor_bottom_left, NORTH))
	pet.befriend(old_owner)
	pet.death()
	var/obj/item/lazarus_injector/injector = allocate(/obj/item/lazarus_injector, get_turf(reviver))
	injector.malfunctioning = TRUE
	reviver.put_in_active_hand(injector)
	injector.afterattack(pet, reviver, TRUE)
	TEST_ASSERT(pet.stat != DEAD, "the lazarus injector did not revive the corgi")
	TEST_ASSERT(reviver in pet.ai_controller.blackboard[BB_FRIENDS_LIST], "the reviver is not the revived corgi's friend")
	TEST_ASSERT(!(old_owner in pet.ai_controller.blackboard[BB_FRIENDS_LIST]), "a malfunctioning injector gave the corgi back its old friends")

	// The gutlunch keeps its full udder overlay through an ordinary redraw
	var/mob/living/basic/mining/gutlunch/guthen/guthen = allocate(/mob/living/basic/mining/gutlunch/guthen, get_step(run_loc_floor_bottom_left, SOUTHEAST))
	var/datum/component/udder/udder = guthen.GetComponent(/datum/component/udder)
	TEST_ASSERT(udder?.udder, "the guthen has no udder")
	STOP_PROCESSING(SSobj, udder.udder) // no breeding during the test
	udder.udder.reagents.clear_reagents()
	guthen.udder_changed()
	udder.udder.reagents.add_reagent(/datum/reagent/consumable/cream, udder.udder.reagents.maximum_volume)
	guthen.udder_changed()
	guthen.update_appearance() // an ordinary redraw
	var/full_overlay_shown = islist(guthen.managed_overlays) ? ("gl_full" in guthen.managed_overlays) : (guthen.managed_overlays == "gl_full")
	TEST_ASSERT(guthen.udder_full && full_overlay_shown, "a full guthen lost its udder overlay on a redraw")

#undef TEST_ASSERT
