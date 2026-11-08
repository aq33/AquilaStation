// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - audyt: noktowizja thralla działa, guz thralla zastępuje paciorek, macki rzucają do celu poza zasięgiem ręki
/datum/unit_test/aquila_audyt_antagi_darkspawn
	var/datum/team/darkspawn/old_team

/datum/unit_test/aquila_audyt_antagi_darkspawn/Destroy()
	if(GLOB.darkspawn_team != old_team)
		QDEL_NULL(GLOB.darkspawn_team)
		GLOB.darkspawn_team = old_team
	return ..()

/datum/unit_test/aquila_audyt_antagi_darkspawn/Run()
	old_team = GLOB.darkspawn_team
	GLOB.darkspawn_team = null
	var/turf/left = run_loc_floor_bottom_left

	var/mob/living/carbon/human/fighter = allocate(/mob/living/carbon/human, left)
	fighter.mind_initialize()
	var/datum/antagonist/darkspawn/antag = fighter.mind.add_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT(antag, "No darkspawn datum")

	// Zniewolona ofiara ma paciorek z Pożarcia woli: dostaje guz thralla zamiast niego
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	victim.mind_initialize()
	var/obj/item/organ/shadowtumor/bead = new
	bead.Insert(victim, FALSE, FALSE)
	TEST_ASSERT(victim.add_thrall(), "Could not thrall the victim")
	var/obj/item/organ/shadowtumor/tumor = get_shadow_tumor(victim)
	TEST_ASSERT(istype(tumor, /obj/item/organ/shadowtumor/thrall), "The thrall kept the plain shadow bead instead of a thrall tumor")
	TEST_ASSERT(QDELETED(bead), "The shadow bead was not removed")
	TEST_ASSERT_EQUAL(tumor.antag_team, antag.team, "The thrall tumor has no team")

	// Noktowizja nadaje cechę, którą czyta update_sight()
	var/datum/action/cooldown/spell/toggle/nightvision/nightvision = locate() in victim.actions
	TEST_ASSERT(nightvision, "Thrall has no nightvision")
	nightvision.Trigger()
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_TRUE_NIGHT_VISION), "Nightvision did not give TRAIT_TRUE_NIGHT_VISION")
	nightvision.reset_spell_cooldown()
	nightvision.Trigger()
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_TRUE_NIGHT_VISION), "Nightvision stayed after turning it off")
	victim.remove_thrall()

	// Rzut mackami w cel trzy pola dalej (prawy klik poza zasięgiem ręki)
	var/obj/item/umbral_tendrils/tendrils = allocate(/obj/item/umbral_tendrils)
	fighter.put_in_active_hand(tendrils)
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, locate(left.x + 3, left.y, left.z))
	antag.psi = 100
	TEST_ASSERT_EQUAL(tendrils.afterattack_secondary(runner, fighter, TRUE, null), SECONDARY_ATTACK_CALL_NORMAL, "Adjacent right click did not go the normal way")
	TEST_ASSERT_EQUAL(antag.psi, 100, "Psi spent by the adjacent afterattack")
	TEST_ASSERT_EQUAL(tendrils.afterattack_secondary(runner, fighter, FALSE, null), SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN, "Ranged right click did not throw the tendrils")
	TEST_ASSERT_EQUAL(antag.psi, 70, "Ranged tendril throw did not spend 30 Psi")

	fighter.mind.remove_antag_datum(/datum/antagonist/darkspawn)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
