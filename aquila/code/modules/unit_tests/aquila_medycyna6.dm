// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - AquilaMed 6 pancreas: burns sugar, a missing one brings hyperglycemia, too much sugar wears it out,
/// an emagged cybernetic one pumps stimulants
/datum/unit_test/aquila_pancreas

/datum/unit_test/aquila_pancreas/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/pancreas/pancreas = patient.getorganslot(ORGAN_SLOT_PANCREAS)
	TEST_ASSERT(istype(pancreas), "A human has no pancreas")
	TEST_ASSERT(patient.aq_sugar_clearance() == 1, "A healthy pancreas does not burn sugar at full speed")

	// Too much sugar wears a living pancreas out
	patient.reagents.add_reagent(/datum/reagent/consumable/sugar, 200)
	pancreas.on_life()
	TEST_ASSERT(pancreas.damage > 0, "A sugar overload did not hurt the pancreas")
	patient.reagents.clear_reagents()
	pancreas.setOrganDamage(0)

	// Without it sugar burns slowly and brings hyperglycemia
	pancreas.Remove(patient)
	TEST_ASSERT(patient.aq_sugar_clearance() == 0.25, "Sugar burns at full speed without a pancreas")
	patient.reagents.add_reagent(/datum/reagent/consumable/sugar, 60)
	var/datum/reagent/consumable/sugar/sugar = patient.reagents.has_reagent(/datum/reagent/consumable/sugar)
	sugar.on_mob_life(patient)
	TEST_ASSERT(sugar.metabolization_rate < initial(sugar.metabolization_rate), "Sugar burns at full speed without a pancreas")
	TEST_ASSERT(patient.drowsyness > 0, "High blood sugar without a pancreas brings no drowsiness")
	qdel(pancreas)

	// An emagged cybernetic pancreas stops burning sugar and pumps stimulants
	var/obj/item/organ/pancreas/cybernetic/cyber = new()
	cyber.Insert(patient)
	TEST_ASSERT(patient.aq_sugar_clearance() == 1, "A cybernetic pancreas does not work like a healthy one")
	cyber.emag_act(patient)
	cyber.on_life()
	TEST_ASSERT(patient.aq_sugar_clearance() == 0.25 && patient.reagents.has_reagent(/datum/reagent/medicine/ephedrine), "An emagged pancreas still burns sugar or gives no stimulants")

/// AQUILA - AquilaMed 6 esophagus: no swallowing without it, choking blocks breath and speech, acid burns it
/datum/unit_test/aquila_esophagus

/datum/unit_test/aquila_esophagus/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/esophagus/esophagus = patient.getorganslot(ORGAN_SLOT_ESOPHAGUS)
	TEST_ASSERT(istype(esophagus), "A human has no esophagus")
	TEST_ASSERT(patient.aq_can_swallow(), "A healthy esophagus cannot swallow")
	var/standing = patient.aq_choke_chance()
	patient.Knockdown(5 SECONDS)
	patient.update_mobility()
	TEST_ASSERT(patient.aq_choke_chance() > standing, "Eating lying down is not riskier")
	patient.SetKnockdown(0)

	// Choking: mute, no swallowing, coughing the bite out clears it
	var/datum/status_effect/aq_choking/choking = patient.apply_status_effect(/datum/status_effect/aq_choking)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_MUTE) && !patient.aq_can_swallow(), "A choking body can speak or swallow")
	choking.tick()
	TEST_ASSERT(patient.losebreath > 0, "A choking body still breathes")
	choking.cough_out()
	TEST_ASSERT(!patient.has_status_effect(/datum/status_effect/aq_choking) && !HAS_TRAIT(patient, TRAIT_MUTE), "Coughing the bite out did not clear the choking")

	// Swallowed acid burns it; without it nothing goes down
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass)
	TEST_ASSERT(glass.canconsume(patient, patient), "A healthy body cannot drink")
	var/datum/reagent/toxin/acid/acid = new()
	acid.reaction_mob(patient, INGEST, 10)
	qdel(acid)
	TEST_ASSERT(esophagus.damage > 0, "Swallowed acid did not burn the esophagus")
	esophagus.Remove(patient)
	TEST_ASSERT(!patient.aq_can_swallow() && !glass.canconsume(patient, patient), "A body without an esophagus can drink")
	qdel(esophagus)

#undef TEST_ASSERT
