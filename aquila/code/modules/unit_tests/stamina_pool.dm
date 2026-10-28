// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation#14750: one stamina pool per mob, the old API and limb stamina feed it, stamcrit and disorient follow it
/datum/unit_test/stamina_pool

/datum/unit_test/stamina_pool/Run()
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	TEST_ASSERT(target.stamina && target.stamina.current == STAMINA_MAX, "Humans do not start with a full stamina pool")

	// Old API goes to the pool
	target.adjustStaminaLoss(40)
	TEST_ASSERT(target.stamina.loss == 40, "adjustStaminaLoss did not take from the pool (loss [target.stamina.loss])")
	TEST_ASSERT(target.getStaminaLoss() == 40, "getStaminaLoss does not read the pool")
	target.setStaminaLoss(0)
	TEST_ASSERT(target.stamina.current == STAMINA_MAX, "setStaminaLoss(0) did not refill the pool")

	// Stamina damage on a limb and through heal/take ends up in the pool, once
	target.apply_damage(30, STAMINA, BODY_ZONE_L_ARM)
	TEST_ASSERT(target.stamina.loss == 30, "Limb stamina damage did not reach the pool (loss [target.stamina.loss])")
	var/obj/item/bodypart/arm = target.get_bodypart(BODY_ZONE_L_ARM)
	TEST_ASSERT(!arm.stamina_dam, "Stamina damage was still stored on the limb")
	target.take_overall_damage(0, 0, 20)
	TEST_ASSERT(target.stamina.loss == 50, "take_overall_damage stamina did not reach the pool exactly once (loss [target.stamina.loss])")
	target.heal_overall_damage(0, 0, 30)
	TEST_ASSERT(target.stamina.loss == 20, "heal_overall_damage stamina did not heal the pool exactly once (loss [target.stamina.loss])")
	target.setStaminaLoss(0)

	// Swinging only costs while it leaves more than STAMINA_MAXIMUM_TO_SWING
	target.stamina_swing(25)
	TEST_ASSERT(target.stamina.current == STAMINA_MAX - 25, "A swing at full stamina was free")
	target.stamina.adjust(-(target.stamina.current - STAMINA_MAXIMUM_TO_SWING))
	var/before = target.stamina.current
	target.stamina_swing(25)
	TEST_ASSERT(target.stamina.current == before, "A swing below the free threshold still cost stamina")
	target.setStaminaLoss(0)

	// Exhaustion: whisper only, no sprint
	target.stamina.adjust(-STAMINA_MAX * 0.7)
	TEST_ASSERT(HAS_TRAIT(target, TRAIT_EXHAUSTED) && HAS_TRAIT(target, TRAIT_WHISPER_ONLY), "Low stamina did not exhaust into whisper only")
	target.setStaminaLoss(0)
	TEST_ASSERT(!HAS_TRAIT(target, TRAIT_EXHAUSTED) && !HAS_TRAIT(target, TRAIT_WHISPER_ONLY), "Exhaustion stayed after a refill")

	// Disorient: never pushes into the stun threshold by itself, paralyzes only the exhausted
	target.Disorient(2 SECONDS, 500, paralyze = 4 SECONDS)
	TEST_ASSERT(target.stamina.current >= target.stamina.maximum * STAMINA_STUN_THRESHOLD_MODIFIER, "Disorient pushed stamina below the stun threshold without overstam")
	TEST_ASSERT(target.IsDisoriented(), "Disorient did not apply the disoriented status")
	TEST_ASSERT(HAS_TRAIT(target, TRAIT_EXHAUSTED), "Heavy disorient did not exhaust")
	target.SetParalyzed(0)
	target.Disorient(2 SECONDS, 10, paralyze = 4 SECONDS)
	TEST_ASSERT(target.IsParalyzed(include_stamcrit = FALSE), "Disorient did not paralyze an exhausted target")
	target.fully_heal()

	var/mob/living/carbon/human/fresh = allocate(/mob/living/carbon/human)
	fresh.Disorient(2 SECONDS, 10, paralyze = 4 SECONDS)
	TEST_ASSERT(!fresh.IsParalyzed(include_stamcrit = FALSE), "Disorient paralyzed a rested target")

	// Stamcrit is a status that sets stam_paralyzed and blocks further loss
	fresh.apply_status_effect(STATUS_EFFECT_STAMCRIT)
	TEST_ASSERT(fresh.is_stamcrit() && fresh.IsParalyzed(), "Stamcrit did not floor the mob")
	var/stamcrit_current = fresh.stamina.current
	fresh.stamina.adjust(-50)
	TEST_ASSERT(fresh.stamina.current == stamcrit_current, "Stamina loss went through during stamcrit")
	fresh.remove_status_effect(STATUS_EFFECT_STAMCRIT)
	TEST_ASSERT(!fresh.is_stamcrit(), "Stamcrit did not clear")

	// Items carry stamina damage, the hit applies it
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	fresh.setStaminaLoss(0)
	fresh.apply_item_stamina_damage(toolbox)
	TEST_ASSERT(fresh.stamina.loss >= toolbox.stamina_damage, "A toolbox hit did not take stamina")

	// Silicons and aliens are immune
	var/mob/living/carbon/alien/humanoid/alien = allocate(/mob/living/carbon/alien/humanoid)
	alien.stamina.adjust(-50)
	TEST_ASSERT(alien.stamina.current == alien.stamina.maximum, "Aliens took stamina damage")

#undef TEST_ASSERT

