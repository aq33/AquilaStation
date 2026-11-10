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

/// A tamed lasso target takes pet commands: the lasso swaps its AI for the dog one and befriends the cowboy
/datum/unit_test/aquila_lasso_tames_with_pet_commands

/datum/unit_test/aquila_lasso_tames_with_pet_commands/Run()
	var/mob/living/carbon/human/cowboy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/simple_animal/hostile/carp/carp = allocate(/mob/living/simple_animal/hostile/carp, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/mob_lasso/lasso = allocate(/obj/item/mob_lasso)
	TEST_ASSERT(lasso.check_allowed(carp), "The space lasso does not accept a space carp")
	TEST_ASSERT(!lasso.check_allowed(cowboy), "The space lasso accepts a human")
	lasso.tame_target(carp, cowboy)
	TEST_ASSERT(istype(carp.ai_controller, /datum/ai_controller/basic_controller/dog), "The tamed carp did not get the dog AI")
	TEST_ASSERT(carp.GetComponent(/datum/component/obeys_commands), "The tamed carp does not take pet commands")
	TEST_ASSERT(cowboy in carp.ai_controller.blackboard[BB_FRIENDS_LIST], "The cowboy is not the tamed carp's friend")
	TEST_ASSERT(carp.faction.Find(REF(cowboy)), "The tamed carp lost the befriend() faction")
	TEST_ASSERT(!("carp" in carp.faction), "The tamed carp still sides with wild carp")
	TEST_ASSERT(carp.GetComponent(/datum/component/riding), "The tamed carp cannot be ridden")

	// The follow command through speech, as a player would say it
	cowboy.say("za mną")
	TEST_ASSERT(istype(carp.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/follow), "Saying the follow command did not make it active")
	TEST_ASSERT_EQUAL(carp.ai_controller.blackboard[BB_CURRENT_PET_TARGET], cowboy, "The follow command does not target the cowboy")

	// Lassoed mobs stop thinking
	var/mob/living/simple_animal/hostile/carp/wild = allocate(/mob/living/simple_animal/hostile/carp, get_step(run_loc_floor_bottom_left, NORTH))
	lasso.set_target_ai(wild, FALSE)
	TEST_ASSERT(HAS_TRAIT(wild, TRAIT_AI_PAUSED), "A lassoed mob kept its AI running")
	lasso.set_target_ai(wild, TRUE)
	TEST_ASSERT(!HAS_TRAIT(wild, TRAIT_AI_PAUSED), "A freed mob kept its AI paused")

#undef IAN_SAVE_PATH
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
