// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety: Odczynnik kryształowy (łup kryształowego goliata) cofa zwęglenie martwego ciała, leczy żywych,
/// a przedawkowany rozrywa serce
/datum/unit_test/crystal_reagent

/datum/unit_test/crystal_reagent/Run()
	// Polany na martwe zwęglone ciało (co najmniej 5 jednostek): koniec zwęglenia i 10 obrażeń genetycznych
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	corpse.adjustFireLoss(150)
	corpse.become_husk("burn")
	corpse.death()
	TEST_ASSERT(HAS_TRAIT_FROM(corpse, TRAIT_HUSK, "burn"), "The test corpse isn't husked")
	var/datum/reagent/crystal_reagent/splash = new
	splash.reaction_mob(corpse, TOUCH, 4)
	TEST_ASSERT(HAS_TRAIT_FROM(corpse, TRAIT_HUSK, "burn"), "Less than 5 units cured the husk")
	splash.reaction_mob(corpse, TOUCH, 5)
	TEST_ASSERT(!HAS_TRAIT(corpse, TRAIT_HUSK), "The crystal reagent didn't cure the husk")
	TEST_ASSERT_EQUAL(corpse.getCloneLoss(), 10, "The crystal reagent didn't leave 10 clone damage")
	qdel(splash)

	// W organizmie leczy po trochu obrażenia (toksyny: obrażenia fizyczne zostawiłyby krew na podłodze testowej)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	patient.adjustToxLoss(20)
	patient.reagents.add_reagent(/datum/reagent/crystal_reagent, 10)
	var/datum/reagent/crystal_reagent/dose = patient.reagents.has_reagent(/datum/reagent/crystal_reagent)
	TEST_ASSERT(dose, "The patient has no crystal reagent")
	dose.on_mob_life(patient)
	TEST_ASSERT(patient.getToxLoss() < 20, "The crystal reagent didn't heal toxin damage")

	// Przedawkowanie: wyczerpanie, rozerwane serce i zawał
	dose.overdose_process(patient)
	TEST_ASSERT(patient.getStaminaLoss() > 0, "The overdose didn't drain stamina")
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_HEART) >= 100 || !patient.getorganslot(ORGAN_SLOT_HEART), "The overdose didn't break the heart")
	TEST_ASSERT(patient.undergoing_cardiac_arrest(), "The overdose didn't cause a heart attack")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
