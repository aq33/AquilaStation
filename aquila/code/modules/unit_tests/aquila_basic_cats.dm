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

/// A male cat breeding with Runtime (only males start breeding) still adds the kitten to Runtime's children (her save)
/datum/unit_test/aquila_runtime_counts_kittens

/datum/unit_test/aquila_runtime_counts_kittens/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/basic/pet/cat/runtime/runtime = allocate(/mob/living/basic/pet/cat/runtime, get_step(left, EAST))
	runtime.cats_deployed = TRUE // no family from a real save on the test floor
	var/mob/living/basic/pet/cat/male = allocate(/mob/living/basic/pet/cat, left)
	male.gender = MALE
	male.combat_mode = FALSE
	var/list/before = left.contents.Copy()
	SEND_SIGNAL(male, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, runtime)
	var/mob/living/basic/pet/cat/kitten/kitten = locate() in (left.contents - before)
	TEST_ASSERT(kitten, "The cats made no kitten")
	allocated += kitten
	TEST_ASSERT_EQUAL(length(runtime.children), 1, "Runtime did not count the kitten the male started")
	TEST_ASSERT_EQUAL(runtime.children[1], kitten, "Runtime counted something else")

/// A cat with no kitten to feed eats its prey after a while and can hunt again; a cat fed from the hand gets tamed
/datum/unit_test/aquila_cat_prey_and_taming

/datum/unit_test/aquila_cat_prey_and_taming/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/basic/pet/cat/cat = allocate(/mob/living/basic/pet/cat, left)
	var/datum/ai_controller/controller = cat.ai_controller
	var/obj/item/food/deadmouse/snack = allocate(/obj/item/food/deadmouse, left)
	// The cat clicking its prey (the AI interacts the same way) picks it up instead of eating it
	cat.UnarmedAttack(snack, TRUE)
	TEST_ASSERT_EQUAL(snack.loc, cat, "The cat did not pick up its prey")

	cat.held_food_since = world.time - CAT_KEEP_PREY_TIME
	var/datum/ai_behavior/eat_held_prey/eat = GET_AI_BEHAVIOR(/datum/ai_behavior/eat_held_prey)
	for(var/i in 1 to 20)
		controller.SelectBehaviors(1)
		if(controller.current_behaviors[eat])
			break
	TEST_ASSERT(controller.current_behaviors[eat], "The cat never planned to eat the prey it could not deliver")
	controller.ProcessBehavior(1, eat)
	TEST_ASSERT(QDELETED(snack), "The cat did not eat its prey")
	TEST_ASSERT(isnull(cat.held_food), "The cat still thinks it holds its prey")

	// Feeding from the hand: dead mouse, fish, fish meat
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/component/tameable/tameable = cat.GetComponent(/datum/component/tameable)
	TEST_ASSERT(tameable, "Cats cannot be tamed")
	tameable.current_tame_chance = 100
	var/obj/item/food/deadmouse/treat = allocate(/obj/item/food/deadmouse, left)
	cat.attackby(treat, feeder)
	TEST_ASSERT(QDELETED(treat), "The cat did not eat the dead mouse from the hand")
	TEST_ASSERT(feeder in controller.blackboard[BB_FRIENDS_LIST], "The cat fed from the hand did not become a friend")

/// Two tomcats fighting over territory wait between threats
/datum/unit_test/aquila_cat_territorial_delay

/datum/unit_test/aquila_cat_territorial_delay/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/basic/pet/cat/cat = allocate(/mob/living/basic/pet/cat, left)
	var/mob/living/basic/pet/cat/rival = allocate(/mob/living/basic/pet/cat, get_step(left, EAST))
	cat.ai_controller.set_blackboard_key(BB_TRESSPASSER_TARGET, rival)
	rival.ai_controller.set_blackboard_key(BB_TRESSPASSER_TARGET, cat)
	var/datum/ai_behavior/territorial_struggle/struggle = GET_AI_BEHAVIOR(/datum/ai_behavior/territorial_struggle)
	var/old_chance = struggle.end_battle_chance
	struggle.end_battle_chance = 0
	var/result = struggle.perform(1, cat.ai_controller, BB_TRESSPASSER_TARGET, BB_HOSTILE_MEOWS)
	struggle.end_battle_chance = old_chance
	TEST_ASSERT(result & AI_BEHAVIOR_DELAY, "The territorial struggle runs again on the next tick")

#undef RUNTIME_SAVE_PATH
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
