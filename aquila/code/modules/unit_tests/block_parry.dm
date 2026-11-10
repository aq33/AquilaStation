// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Blok z nowego Bee: przerwa między blokami i ciosy, których zwykła broń nie zablokuje
/datum/unit_test/aquila_block_cooldown_unblockable

/datum/unit_test/aquila_block_cooldown_unblockable/Run()
	var/mob/living/carbon/human/defender = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/melee/sabre/sabre = allocate(/obj/item/melee/sabre)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	var/obj/item/dualsaber/dualsaber = allocate(/obj/item/dualsaber)
	defender.put_in_active_hand(sabre)
	attacker.put_in_active_hand(toolbox)
	defender.set_combat_mode(TRUE)
	defender.setDir(EAST)

	TEST_ASSERT(sabre.hit_reaction(defender, toolbox, "cios", 10, MELEE_ATTACK), "A sabre facing the attacker did not block a toolbox")
	TEST_ASSERT(!sabre.hit_reaction(defender, toolbox, "cios", 10, MELEE_ATTACK), "A second block went through right away, no block cooldown")
	defender.block_cooldown = 0
	TEST_ASSERT(sabre.hit_reaction(defender, toolbox, "cios", 10, MELEE_ATTACK), "The block did not come back after the cooldown")

	defender.block_cooldown = 0
	attacker.dropItemToGround(toolbox)
	attacker.put_in_active_hand(dualsaber)
	TEST_ASSERT(!sabre.hit_reaction(defender, dualsaber, "cios", 10, MELEE_ATTACK), "A sabre blocked an unblockable double-bladed sword")
	TEST_ASSERT(COOLDOWN_FINISHED(defender, block_cooldown), "A failed block started the block cooldown")

/// Parowanie z Paradise: działa tylko w oknie po wciśnięciu klawisza, z każdego kierunku i bez trybu walki
/datum/unit_test/aquila_parry_window

/datum/unit_test/aquila_parry_window/Run()
	var/mob/living/carbon/human/defender = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/katana/katana = allocate(/obj/item/katana)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	defender.put_in_active_hand(katana)
	attacker.put_in_active_hand(toolbox)
	defender.set_combat_mode(FALSE)
	defender.setDir(WEST) // plecami do atakującego: pasywny blok nie działa

	TEST_ASSERT(!defender.check_shields(toolbox, 10, "cios", MELEE_ATTACK), "A hit from behind was stopped without parrying")
	SEND_SIGNAL(defender, COMSIG_HUMAN_PARRY)
	TEST_ASSERT(defender.check_shields(toolbox, 10, "cios", MELEE_ATTACK), "A katana did not parry right after the parry key")

	var/datum/component/parry/parry = katana.GetComponent(/datum/component/parry)
	TEST_ASSERT(parry, "A katana has no parry component")
	parry.time_parried = world.time - PARRY_DEFAULT_TIMEOUT - 1
	TEST_ASSERT(!defender.check_shields(toolbox, 10, "cios", MELEE_ATTACK), "A parry still worked after its window")

	defender.dropItemToGround(katana)
	parry.time_parried = world.time
	TEST_ASSERT(!defender.check_shields(toolbox, 10, "cios", MELEE_ATTACK), "A dropped katana still parried")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
