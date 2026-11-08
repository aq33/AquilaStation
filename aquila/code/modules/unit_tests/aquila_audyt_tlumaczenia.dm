// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the "promotion" crew objective compares get_assignment() with its own fallback texts, so the Polish defaults do not complete it
/datum/unit_test/aquila_promotion_objective_unknown

/datum/unit_test/aquila_promotion_objective_unknown/Run()
	var/mob/living/carbon/human/assistant = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	assistant.mind_initialize()
	var/obj/item/card/id/card = allocate(/obj/item/card/id, run_loc_floor_bottom_left)
	card.assignment = JOB_NAME_ASSISTANT
	card.hud_state = JOB_HUD_ASSISTANT
	TEST_ASSERT(assistant.put_in_active_hand(card), "The assistant could not hold the ID card")
	var/datum/objective/crew/promotion/promotion = new
	promotion.owner = assistant.mind
	TEST_ASSERT(!promotion.check_completion(), "An assistant ID card completes the promotion objective")
	// cloaked assistant (MOD infiltrator, heretic shadow cloak): get_assignment() falls back to "Brak ID"
	ADD_TRAIT(assistant, TRAIT_UNKNOWN, "aquila_test")
	TEST_ASSERT(!promotion.check_completion(), "An assistant with TRAIT_UNKNOWN completes the promotion objective without a promotion")
	REMOVE_TRAIT(assistant, TRAIT_UNKNOWN, "aquila_test")
	card.assignment = JOB_NAME_SCIENTIST
	TEST_ASSERT(promotion.check_completion(), "A promoted assistant does not complete the promotion objective")
	qdel(promotion)

/// AQUILA - wrong English pairs from the history: the renamed security job, English keys mapped to other words, mismatched window labels
/datum/unit_test/aquila_audyt_en_pairs

/datum/unit_test/aquila_audyt_en_pairs/Run()
	TEST_ASSERT_EQUAL(i18n_en_exact(JOB_NAME_SECURITYOFFICER), "Military Police", "The security job is not translated")
	for(var/english in list("name", "Name", "left", "Left", "good", "center", ROLE_ERT, "Space Dragon", "Agent", "Mansus Grasp"))
		var/translated = i18n_en_exact(english)
		TEST_ASSERT(isnull(translated) || translated == english, "English text \"[english]\" is replaced with \"[translated]\"")
	var/list/expected = list(
		"Szczegóły" = "Details",
		"Karta ID" = "ID Card",
		"Twoje sojusze:" = "Your allies:",
		"Rytuały" = "Rituals",
		"Runy" = "Runes",
		"Placówka Żandarmerii" = "Security"
	)
	for(var/polish in expected)
		TEST_ASSERT_EQUAL(i18n_en_exact(polish), expected[polish], "Wrong English pair for \"[polish]\"")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
