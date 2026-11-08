// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - port tgstation/tgstation#88418: pchnięcie nożem na prawym przycisku zadaje mniej obrażeń, rany kłute, potem nóż wraca do cięcia
/datum/unit_test/aquila_knife_stab

/datum/unit_test/aquila_knife_stab/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/slashed = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/stabbed = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/kitchen/knife/combat/knife = allocate(/obj/item/kitchen/knife/combat)
	attacker.put_in_active_hand(knife, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	var/base_force = knife.force
	knife.wound_bonus = CANT_WOUND // rana mogłaby dodać obrażenia i zafałszować porównanie

	TEST_ASSERT_EQUAL(knife.get_attack_animation(), ATTACK_ANIMATION_SLASH, "A knife does not slash")
	knife.melee_attack_chain(attacker, slashed, "")
	TEST_ASSERT(slashed.getBruteLoss() > 0, "A left click with a knife did no damage")
	TEST_ASSERT_EQUAL(knife.get_wound_kind(), WOUND_SLASH, "A left click switched the knife to piercing")

	knife.melee_attack_chain(attacker, stabbed, "right=1")
	TEST_ASSERT(stabbed.getBruteLoss() > 0, "A right click with a knife did no damage")
	TEST_ASSERT_EQUAL(slashed.getBruteLoss() - stabbed.getBruteLoss(), -knife.alt_attack_force_mod, "The stab did not change the damage by alt_attack_force_mod")
	TEST_ASSERT_EQUAL(knife.get_wound_kind(), WOUND_PIERCE, "The stab does not pierce")
	TEST_ASSERT_EQUAL(knife.get_attack_animation(), ATTACK_ANIMATION_PIERCE, "The stab does not thrust")

	var/datum/component/alternative_sharpness/stab = knife.GetComponent(/datum/component/alternative_sharpness)
	stab.disable_alt_attack()
	stab.disable_alt_attack() // drugi raz (timer) nie może zabrać siły jeszcze raz
	TEST_ASSERT_EQUAL(knife.force, base_force, "The knife force did not come back after the stab")
	TEST_ASSERT_EQUAL(knife.get_wound_kind(), WOUND_SLASH, "The knife did not go back to slashing")

	// Siła zmieniona w trakcie pchnięcia (np. wyłączony miecz energetyczny) zostaje, a nie dostaje force_mod z powrotem
	knife.melee_attack_chain(attacker, stabbed, "right=1")
	knife.force = 7
	stab.disable_alt_attack()
	TEST_ASSERT_EQUAL(knife.force, 7, "Restoring after a stab overwrote a force set during the stab")

/// AQUILA - port tgstation/tgstation#88418: tasak nie ma pchnięcia, wyłączony miecz energetyczny nie pchnie
/datum/unit_test/aquila_stab_exceptions

/datum/unit_test/aquila_stab_exceptions/Run()
	var/obj/item/kitchen/knife/butcher/cleaver = allocate(/obj/item/kitchen/knife/butcher)
	TEST_ASSERT(!cleaver.GetComponent(/datum/component/alternative_sharpness), "A butcher's cleaver got the stab attack")

	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/melee/transforming/energy/sword/esword = allocate(/obj/item/melee/transforming/energy/sword)
	TEST_ASSERT(!esword.active, "A new energy sword is on")
	var/off_force = esword.force
	SEND_SIGNAL(esword, COMSIG_ITEM_PRE_ATTACK_SECONDARY, attacker, attacker, "right=1")
	TEST_ASSERT_EQUAL(esword.force, off_force, "A switched off energy sword changed its force for a stab")

	var/obj/item/spear/spear = allocate(/obj/item/spear)
	TEST_ASSERT_EQUAL(spear.get_attack_animation(), ATTACK_ANIMATION_PIERCE, "A spear does not thrust")
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	TEST_ASSERT_EQUAL(toolbox.get_attack_animation(), ATTACK_ANIMATION_BLUNT, "A toolbox is not blunt")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
