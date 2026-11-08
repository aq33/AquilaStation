// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - BeeStation/BeeStation-Hornet#14340: what is swallowed waits in the stomach and reaches the blood later,
/// a human without a stomach throws it up, a xenomorph eats like before, vomiting empties the stomach and not the blood
/datum/unit_test/aquila_stomach_ingest

/datum/unit_test/aquila_stomach_ingest/Run()
	SSmobs.pause()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human)
	eater.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	var/obj/item/organ/stomach/belly = eater.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT(belly?.reagents, "A human has no stomach that holds reagents")

	// A drink waits in the stomach, then digestion passes it on to the blood
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass)
	glass.reagents.add_reagent(/datum/reagent/consumable/orangejuice, 10)
	glass.attack(eater, eater)
	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/orangejuice), "A drink did not reach the stomach")
	TEST_ASSERT(!eater.reagents.has_reagent(/datum/reagent/consumable/orangejuice), "A drink went straight into the blood")
	var/drink_in_stomach = belly.reagents.get_reagent_amount(/datum/reagent/consumable/orangejuice)
	eater.handle_stomach_digestion()
	TEST_ASSERT(eater.reagents.has_reagent(/datum/reagent/consumable/orangejuice), "Digestion did not pass the drink on to the blood")
	TEST_ASSERT(belly.reagents.get_reagent_amount(/datum/reagent/consumable/orangejuice) < drink_in_stomach, "Digestion did not take the drink out of the stomach")

	// A bite of food and a pill go to the stomach too
	var/obj/item/food/breadslice/plain/bread = allocate(/obj/item/food/breadslice/plain)
	bread.reagents.add_reagent(/datum/reagent/consumable/ketchup, 5)
	var/datum/component/edible/edible = bread.GetComponent(/datum/component/edible)
	edible.TakeBite(eater, eater)
	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/ketchup), "A bite of food did not reach the stomach")
	TEST_ASSERT(!eater.reagents.has_reagent(/datum/reagent/consumable/ketchup), "A bite of food went straight into the blood")
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	pill.reagents.add_reagent(/datum/reagent/iron, 5)
	pill.attack(eater, eater)
	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/iron), "A swallowed pill did not reach the stomach")
	TEST_ASSERT(!eater.reagents.has_reagent(/datum/reagent/iron), "A swallowed pill went straight into the blood")

	// A pill hidden in food is swallowed into the stomach
	var/obj/item/reagent_containers/pill/hidden = allocate(/obj/item/reagent_containers/pill)
	hidden.reagents.add_reagent(/datum/reagent/copper, 5)
	hidden.on_accidental_consumption(eater, eater, null)
	TEST_ASSERT(QDELETED(hidden), "A pill hidden in food was not swallowed")
	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/copper), "A pill hidden in food did not reach the stomach")
	var/brute_before = eater.getBruteLoss()
	var/datum/material/iron/iron = getmaterialref(/datum/material/iron)
	TEST_ASSERT(iron.on_accidental_mat_consumption(eater, null), "Biting into hidden iron has no effect")
	TEST_ASSERT(eater.getBruteLoss() > brute_before, "Biting into hidden iron did not hurt")

	// The health analyzer shows the stomach
	var/list/data = get_health_analyzer_data(eater, eater, FALSE)
	var/list/stomach_entries = data["stomach"]
	TEST_ASSERT(length(stomach_entries), "The health analyzer window does not list the stomach contents")
	TEST_ASSERT(findtext(chemscan(eater, eater, FALSE), "Zawartość żołądka"), "The chemical scan does not list the stomach contents")

	// Vomiting takes from the stomach and leaves the blood alone
	belly.reagents.add_reagent(/datum/reagent/consumable/sugar, 30)
	eater.reagents.add_reagent(/datum/reagent/water, 20)
	eater.vomit(10, stun = FALSE)
	TEST_ASSERT(belly.reagents.get_reagent_amount(/datum/reagent/consumable/sugar) < 30, "Vomiting did not empty the stomach")
	TEST_ASSERT_EQUAL(eater.reagents.get_reagent_amount(/datum/reagent/water), 20, "Vomiting took reagents out of the blood")
	for(var/obj/effect/decal/cleanable/vomit/spew in range(2, eater))
		qdel(spew)

	// A full heal empties the stomach as well as the blood
	TEST_ASSERT(belly.get_contents_volume() > 0, "Nothing left in the stomach to check the full heal with")
	eater.fully_heal()
	TEST_ASSERT_EQUAL(belly.get_contents_volume(), 0, "A full heal left reagents in the stomach")

	// A human without a stomach can't keep a drink down
	var/mob/living/carbon/human/gutless = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/obj/item/organ/stomach/removed = gutless.getorganslot(ORGAN_SLOT_STOMACH)
	removed.Remove(gutless)
	qdel(removed)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass_two = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass, run_loc_floor_top_right)
	glass_two.reagents.add_reagent(/datum/reagent/consumable/orangejuice, 10)
	glass_two.attack(gutless, gutless)
	TEST_ASSERT(!gutless.reagents.has_reagent(/datum/reagent/consumable/orangejuice), "A human without a stomach kept a drink in the blood")
	var/obj/effect/decal/cleanable/vomit/thrown_up = locate() in get_turf(gutless)
	TEST_ASSERT(thrown_up?.reagents?.has_reagent(/datum/reagent/consumable/orangejuice), "A human without a stomach did not throw the drink up")
	qdel(thrown_up)

	// A xenomorph has no stomach by nature and eats into the blood like before
	var/mob/living/carbon/alien/humanoid/hunter/xeno = allocate(/mob/living/carbon/alien/humanoid/hunter, run_loc_floor_top_right)
	var/datum/reagents/meal = new(50)
	meal.add_reagent(/datum/reagent/consumable/orangejuice, 10)
	meal.trans_to(xeno, 5, method = INGEST)
	TEST_ASSERT(xeno.reagents.has_reagent(/datum/reagent/consumable/orangejuice), "A xenomorph no longer gets what it eats")
	qdel(meal)
	TEST_ASSERT(!(locate(/obj/effect/decal/cleanable/vomit) in get_turf(xeno)), "A xenomorph threw up what it ate")

/datum/unit_test/aquila_stomach_ingest/Destroy()
	SSmobs.ignite()
	return ..()

/// AQUILA - BeeStation/BeeStation-Hornet#14340: a small dose of toxin stays without effect, a large one hurts the liver
/// on the old scale (amount * toxLethality per tick for an ordinary toxin), a failing liver goes through Bee's stages
/datum/unit_test/aquila_liver_toxins

/datum/unit_test/aquila_liver_toxins/Run()
	SSmobs.pause()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/liver/liver = patient.getorganslot(ORGAN_SLOT_LIVER)
	TEST_ASSERT(liver, "A human has no liver")

	// Under the tolerance: no effect, no liver damage, gone at the normal metabolic rate instead of 1 u per tick
	patient.reagents.add_reagent(/datum/reagent/toxin, 2)
	var/tox_before = patient.getToxLoss()
	liver.process_reagents(patient)
	TEST_ASSERT(patient.reagents.get_reagent_amount(/datum/reagent/toxin) >= 1.5, "A small dose of toxin vanished at once")
	TEST_ASSERT_EQUAL(patient.getToxLoss(), tox_before, "A dose under the liver tolerance still poisoned")
	TEST_ASSERT_EQUAL(liver.damage, 0, "A dose under the liver tolerance hurt the liver")

	// Toxin still waiting in the stomach counts towards the tolerance
	var/obj/item/organ/stomach/belly = patient.getorganslot(ORGAN_SLOT_STOMACH)
	belly.reagents.add_reagent(/datum/reagent/toxin, 10)
	liver.process_reagents(patient)
	TEST_ASSERT(patient.getToxLoss() > tox_before, "Toxin in the stomach did not count towards the liver tolerance")
	belly.reagents.clear_reagents()
	patient.reagents.clear_reagents()
	liver.setOrganDamage(0)

	// Over the tolerance: 30 u of an ordinary toxin = 30 * 0.01 = 0.3 liver damage per tick, the same as before the port
	patient.reagents.add_reagent(/datum/reagent/toxin, 30)
	liver.process_reagents(patient)
	TEST_ASSERT(abs(liver.damage - 0.3) < 0.01, "30 u of toxin should do 0.3 liver damage per tick, did [liver.damage]")
	patient.reagents.clear_reagents()
	liver.setOrganDamage(0)

	// A harsher toxin hurts more (plasma, toxpwr 3), a harmless one not at all
	patient.reagents.add_reagent(/datum/reagent/toxin/plasma, 30)
	liver.process_reagents(patient)
	TEST_ASSERT(abs(liver.damage - 0.6) < 0.01, "30 u of plasma should do 0.6 liver damage per tick, did [liver.damage]")
	patient.reagents.clear_reagents()
	liver.setOrganDamage(0)
	patient.reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 30)
	liver.process_reagents(patient)
	TEST_ASSERT_EQUAL(liver.damage, 0, "A toxin without toxpwr hurt the liver")
	patient.reagents.clear_reagents()

	// Plasmamen don't wear out their crystal on plasma
	var/obj/item/organ/liver/plasmaman/crystal = new
	TEST_ASSERT(!crystal.toxin_harms_liver(GLOB.chemical_reagents_list[/datum/reagent/toxin/plasma]), "Plasma hurts the plasmaman liver")
	TEST_ASSERT(crystal.toxin_harms_liver(GLOB.chemical_reagents_list[/datum/reagent/toxin]), "Other toxins no longer hurt the plasmaman liver")
	qdel(crystal)

	// Hard liquor that still waits in the stomach counts for cirrhosis like it did in the blood
	belly.reagents.add_reagent(/datum/reagent/consumable/ethanol/vodka, 50)
	liver.handle_alcohol_abuse(patient)
	TEST_ASSERT(liver.damage > 0, "Heavy drinking that waits in the stomach did not count for cirrhosis")
	belly.reagents.clear_reagents()

	// Failure: the first stage comes after a minute
	liver.setOrganDamage(liver.maxHealth)
	TEST_ASSERT(liver.organ_flags & ORGAN_FAILING, "A destroyed liver is not failing")
	liver.failure_time = 56
	var/tox_failing = patient.getToxLoss()
	liver.process_reagents(patient)
	TEST_ASSERT_EQUAL(patient.getToxLoss(), tox_failing, "Liver failure poisoned before its first stage")
	liver.process_reagents(patient)
	TEST_ASSERT_EQUAL(liver.failure_time, 60, "Liver failure time did not count up")
	TEST_ASSERT(patient.getToxLoss() > tox_failing, "The first stage of liver failure did not poison")

/datum/unit_test/aquila_liver_toxins/Destroy()
	SSmobs.ignite()
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
