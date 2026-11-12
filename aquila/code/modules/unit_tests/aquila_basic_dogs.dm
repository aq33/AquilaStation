// AQUILA - basic mob dogs (port of BeeStation/BeeStation-Hornet basic dogs): Ian's save written by the old simple animal Ian
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define IAN_SAVE_PATH "data/npc_saves/Ian.json"

/// Ian's JSON save from the simple animal Ian (hat as a type path in text) loads into the basic mob Ian and is written back in the same format
/datum/unit_test/aquila_ian_save_migration
	/// Whatever save was there before the test, put back in Destroy()
	var/old_save

/datum/unit_test/aquila_ian_save_migration/Run()
	if(fexists(IAN_SAVE_PATH))
		old_save = rustg_file_read(IAN_SAVE_PATH)
	TEST_ASSERT(!fexists("data/npc_saves/Ian.sav"), "A legacy Ian.sav exists, the test would delete it")
	// Exactly what the old /mob/living/simple_animal/pet/dog/corgi/Ian/proc/Write_Memory() wrote
	var/list/old_format = list("age" = 3, "record_age" = 5, "saved_head" = /obj/item/clothing/head/chefhat)
	fdel(IAN_SAVE_PATH)
	text2file(json_encode(old_format), IAN_SAVE_PATH)

	var/mob/living/basic/pet/dog/corgi/ian/ian = allocate(/mob/living/basic/pet/dog/corgi/ian, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(ian.age, 3, "Ian's age was not read from the old save")
	TEST_ASSERT_EQUAL(ian.record_age, 5, "Ian's record age was not read from the old save")
	TEST_ASSERT(istype(ian.inventory_head, /obj/item/clothing/head/chefhat), "Ian is not wearing the hat from the old save")
	TEST_ASSERT(findtext(ian.name, "Ian"), "Ian lost his name under the hat ([ian.name])")
	TEST_ASSERT(!(locate(/mob/living/basic/pet/dog/corgi/puppy/ian) in run_loc_floor_bottom_left), "An Ian aged 3 spawned a puppy")

	// Surviving the round writes the same format back
	ian.Write_Memory(FALSE)
	var/list/saved = json_decode(rustg_file_read(IAN_SAVE_PATH))
	TEST_ASSERT_EQUAL(saved["age"], 4, "Ian's age did not go up")
	TEST_ASSERT_EQUAL(saved["record_age"], 5, "Ian's record changed although he did not beat it")
	TEST_ASSERT_EQUAL(text2path(saved["saved_head"]), /obj/item/clothing/head/chefhat, "Ian's hat was not saved")

	// Dying starts him over as a puppy
	ian.Write_Memory(TRUE)
	saved = json_decode(rustg_file_read(IAN_SAVE_PATH))
	TEST_ASSERT_EQUAL(saved["age"], 0, "A dead Ian kept his age")
	TEST_ASSERT(isnull(saved["saved_head"]), "A dead Ian kept his hat")

/datum/unit_test/aquila_ian_save_migration/Destroy()
	fdel(IAN_SAVE_PATH)
	if(old_save)
		text2file(old_save, IAN_SAVE_PATH)
	return ..()

/// A tamed lasso target takes pet commands and befriends the cowboy: a basic carp keeps its own AI (decision D11), other mobs get the dog one
/datum/unit_test/aquila_lasso_tames_with_pet_commands

/datum/unit_test/aquila_lasso_tames_with_pet_commands/Run()
	var/mob/living/carbon/human/cowboy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/basic/carp/carp = allocate(/mob/living/basic/carp, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/mob_lasso/lasso = allocate(/obj/item/mob_lasso)
	TEST_ASSERT(lasso.check_allowed(carp), "The space lasso does not accept a space carp")
	TEST_ASSERT(!lasso.check_allowed(cowboy), "The space lasso accepts a human")
	var/datum/ai_controller/carp_controller = carp.ai_controller
	lasso.tame_target(carp, cowboy)
	// A basic carp keeps its own AI (fleeing, rifts) and only takes pet commands (decision D11)
	TEST_ASSERT_EQUAL(carp.ai_controller, carp_controller, "The lasso replaced the AI of the basic carp")
	TEST_ASSERT(istype(carp.ai_controller, /datum/ai_controller/basic_controller/carp), "The tamed carp lost its carp AI")
	TEST_ASSERT(carp.GetComponent(/datum/component/obeys_commands), "The tamed carp does not take pet commands")
	TEST_ASSERT(cowboy in carp.ai_controller.blackboard[BB_FRIENDS_LIST], "The cowboy is not the tamed carp's friend")
	TEST_ASSERT(carp.faction.Find(REF(cowboy)), "The tamed carp lost the befriend() faction")
	TEST_ASSERT(!("carp" in carp.faction), "The tamed carp still sides with wild carp")
	TEST_ASSERT(carp.GetComponent(/datum/component/riding), "The tamed carp cannot be ridden")

	// The follow command through speech, as a player would say it
	cowboy.say("za mną")
	TEST_ASSERT(istype(carp.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/follow), "Saying the follow command did not make it active")
	TEST_ASSERT_EQUAL(carp.ai_controller.blackboard[BB_CURRENT_PET_TARGET], cowboy, "The follow command does not target the cowboy")
	// The carp AI plans the command first and does not go for its owner
	carp.ai_controller.SelectBehaviors(1)
	TEST_ASSERT(!carp.ai_controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)], "The tamed carp went to bite instead of following")

	// Lassoed mobs stop thinking
	var/mob/living/basic/carp/wild = allocate(/mob/living/basic/carp, get_step(run_loc_floor_bottom_left, NORTH))
	lasso.set_target_ai(wild, FALSE)
	TEST_ASSERT(HAS_TRAIT(wild, TRAIT_AI_PAUSED), "A lassoed mob kept its AI running")
	lasso.set_target_ai(wild, TRUE)
	TEST_ASSERT(!HAS_TRAIT(wild, TRAIT_AI_PAUSED), "A freed mob kept its AI paused")

	// Any other basic mob (the dolphin) swaps its AI for the dog one
	var/mob/living/basic/dolphin/dolphin = allocate(/mob/living/basic/dolphin, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(lasso.check_allowed(dolphin), "The space lasso does not accept a dolphin")
	lasso.tame_target(dolphin, cowboy)
	TEST_ASSERT(istype(dolphin.ai_controller, /datum/ai_controller/basic_controller/dog), "The tamed dolphin did not get the dog AI")
	TEST_ASSERT(dolphin.GetComponent(/datum/component/obeys_commands), "The tamed dolphin does not take pet commands")
	TEST_ASSERT(!HAS_TRAIT(dolphin, TRAIT_AI_PAUSED), "The tamed dolphin's AI stayed paused")

	// Taming the same dolphin again (it is already a friend) leaves the cowboy on the new controller's friend list
	lasso.tame_target(dolphin, cowboy)
	TEST_ASSERT(cowboy in dolphin.ai_controller.blackboard[BB_FRIENDS_LIST], "A dolphin tamed again has no friends on its new controller")

	// A lassoed mob deleted while flipped takes its release timer with it
	lasso.mob_target = wild
	var/release_timer = addtimer(CALLBACK(lasso, TYPE_PROC_REF(/obj/item/mob_lasso, fail_ally)), 6 SECONDS, TIMER_STOPPABLE)
	lasso.timer = release_timer
	lasso.handle_hard_del()
	TEST_ASSERT(!SStimer.timer_id_dict[release_timer], "The release timer of a deleted lassoed mob is still running")

	// Only the root types: no magicarp, Cayenne or wisdom cow
	var/mob/living/basic/carp/magic/magicarp = allocate(/mob/living/basic/carp/magic, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(!lasso.check_allowed(magicarp), "The space lasso accepts a magicarp")
	var/mob/living/basic/carp/pet/cayenne/cayenne = allocate(/mob/living/basic/carp/pet/cayenne, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(!lasso.check_allowed(cayenne), "The space lasso accepts Cayenne")
	var/mob/living/basic/carp/mega/mega = allocate(/mob/living/basic/carp/mega, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(lasso.check_allowed(mega), "The space lasso does not accept a megacarp")
	var/mob/living/basic/cow/wisdom/wise_cow = allocate(/mob/living/basic/cow/wisdom, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(!lasso.check_allowed(wise_cow), "The space lasso accepts the wisdom cow")

#undef IAN_SAVE_PATH
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
