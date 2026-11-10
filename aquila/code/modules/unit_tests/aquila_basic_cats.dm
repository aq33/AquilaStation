// AQUILA - basic mob cats (port of BeeStation/BeeStation-Hornet basic cats): Runtime's family save written by the old simple animal Runtime
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define RUNTIME_SAVE_PATH "data/npc_saves/Runtime.json"

/// The family in a save of the simple animal Runtime (old type paths as text) comes back as basic cats and is saved with the new paths
/datum/unit_test/aquila_runtime_save_migration
	/// Whatever save was there before the test, put back in Destroy()
	var/old_save

/datum/unit_test/aquila_runtime_save_migration/Run()
	if(fexists(RUNTIME_SAVE_PATH))
		old_save = rustg_file_read(RUNTIME_SAVE_PATH)
	TEST_ASSERT(!fexists("data/npc_saves/Runtime.sav"), "A legacy Runtime.sav exists, the test would delete it")
	// What the old Write_Memory() wrote: json_encode() turns the type keys into text
	var/old_json = "{\"family\":{\"/mob/living/simple_animal/pet/cat/kitten\":2,\"/mob/living/simple_animal/pet/cat/space\":1,\"/mob/living/simple_animal/pet/cat/removed_since\":4}}"
	fdel(RUNTIME_SAVE_PATH)
	text2file(old_json, RUNTIME_SAVE_PATH)

	var/mob/living/basic/pet/cat/runtime/runtime = allocate(/mob/living/basic/pet/cat/runtime, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(runtime.family[/mob/living/basic/pet/cat/kitten], 2, "The kittens from the old save were not read")
	TEST_ASSERT_EQUAL(runtime.family[/mob/living/basic/pet/cat/space], 1, "The space cat from the old save was not read")
	TEST_ASSERT_EQUAL(length(runtime.family), 2, "A cat type that no longer exists was kept")

	runtime.deploy_the_cats()
	var/kittens = 0
	var/space_cats = 0
	for(var/mob/living/basic/pet/cat/cat in run_loc_floor_bottom_left)
		if(istype(cat, /mob/living/basic/pet/cat/kitten))
			kittens++
		else if(istype(cat, /mob/living/basic/pet/cat/space))
			space_cats++
	TEST_ASSERT_EQUAL(kittens, 2, "Runtime did not bring her kittens")
	TEST_ASSERT_EQUAL(space_cats, 1, "Runtime did not bring her space cat")
	for(var/mob/living/basic/pet/cat/cat in run_loc_floor_bottom_left)
		if(cat != runtime)
			allocated += cat

	// A kitten born this round is counted through the breeding callback and saved with the new path
	var/mob/living/basic/pet/cat/kitten/newborn = allocate(/mob/living/basic/pet/cat/kitten, run_loc_floor_bottom_left)
	runtime.post_birth_callback.Invoke(newborn)
	runtime.write_memory(FALSE)
	var/list/saved = json_decode(rustg_file_read(RUNTIME_SAVE_PATH))
	TEST_ASSERT_EQUAL(saved["family"]["/mob/living/basic/pet/cat/kitten"], 1, "The kitten born this round was not saved under the basic mob path")

/datum/unit_test/aquila_runtime_save_migration/Destroy()
	fdel(RUNTIME_SAVE_PATH)
	if(old_save)
		text2file(old_save, RUNTIME_SAVE_PATH)
	return ..()

/// A cat picks up a dead mouse it attacks and forgets it when it drops it
/datum/unit_test/aquila_cat_held_food

/datum/unit_test/aquila_cat_held_food/Run()
	var/mob/living/basic/pet/cat/cat = allocate(/mob/living/basic/pet/cat, run_loc_floor_bottom_left)
	var/obj/item/food/deadmouse/snack = allocate(/obj/item/food/deadmouse, run_loc_floor_bottom_left)
	TEST_ASSERT(cat.ai_controller.blackboard[BB_HUNTABLE_PREY], "The cat has no prey list")
	SEND_SIGNAL(cat, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, snack)
	TEST_ASSERT_EQUAL(snack.loc, cat, "The cat did not pick up the dead mouse")
	TEST_ASSERT_EQUAL(cat.held_food, snack, "The cat does not know it holds the dead mouse")
	snack.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(isnull(cat.held_food), "The cat still holds the dead mouse it dropped")

#undef RUNTIME_SAVE_PATH
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
