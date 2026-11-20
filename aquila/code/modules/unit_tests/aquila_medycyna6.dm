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
	// The scanner names the missing organ and the hyperglycemia (playtest: the line hung on the organ that was gone)
	var/scan = jointext(patient.aq_organ_scan_lines(), " ")
	TEST_ASSERT(findtext(scan, "Brak trzustki") && findtext(scan, "Hiperglikemia"), "The scanner does not show a missing pancreas and the hyperglycemia: [scan]")
	qdel(pancreas)

	// An emagged cybernetic pancreas stops burning sugar and pumps stimulants
	var/obj/item/organ/pancreas/cybernetic/cyber = new()
	cyber.Insert(patient)
	TEST_ASSERT(patient.aq_sugar_clearance() == 1, "A cybernetic pancreas does not work like a healthy one")
	cyber.emag_act(patient)
	patient.drowsyness = 0
	patient.reagents.add_reagent(/datum/reagent/consumable/sugar, 60)
	var/datum/reagent/consumable/sugar/emag_sugar = patient.reagents.has_reagent(/datum/reagent/consumable/sugar)
	emag_sugar.on_mob_life(patient)
	TEST_ASSERT(!patient.drowsyness, "An emagged pancreas makes the host drowsy on top of its stimulants")
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

	// A body that dies choking does not keep choking after revival, an admin heal clears it too
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/datum/status_effect/aq_choking/dead_choke = victim.apply_status_effect(/datum/status_effect/aq_choking)
	victim.death()
	dead_choke.tick()
	TEST_ASSERT(!victim.has_status_effect(/datum/status_effect/aq_choking), "Choking stayed on a dead body")
	victim.revive(full_heal = TRUE, admin_revive = TRUE)
	victim.apply_status_effect(/datum/status_effect/aq_choking)
	victim.fully_heal(TRUE)
	TEST_ASSERT(!victim.has_status_effect(/datum/status_effect/aq_choking), "A full heal left the choking on")

	// Heimlich by a medic with a mind (default martial art) on the chest
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	medic.mind_initialize()
	medic.zone_selected = BODY_ZONE_CHEST
	patient.apply_status_effect(/datum/status_effect/aq_choking)
	for(var/i in 1 to 10)
		if(!patient.has_status_effect(/datum/status_effect/aq_choking))
			break
		medic.dna.species.help(medic, patient, medic.mind.martial_art)
	TEST_ASSERT(!patient.has_status_effect(/datum/status_effect/aq_choking), "Ten Heimlich manoeuvres by a medic with a mind never cleared the choking")

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

/// AQUILA - AquilaMed 6 spine organ: fractures stay wounds, a dead one paralyses the legs, none paralyses everything,
/// a titanium one does not break
/datum/unit_test/aquila_spine_organ

/datum/unit_test/aquila_spine_organ/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/aq_spine/spine = patient.getorganslot(ORGAN_SLOT_AQ_SPINE)
	TEST_ASSERT(istype(spine), "A human has no spine")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_PARALYSIS_L_LEG), "A healthy spine paralyses the legs")

	// An organ regeneration swaps the spine without dropping what the hands hold (review: special removal paralysed for a moment)
	var/obj/item/held = allocate(/obj/item/toy/crayon/red)
	patient.put_in_active_hand(held)
	patient.dna.species.regenerate_organs(patient, null, TRUE) // organ swap as in a species change, without new limbs
	spine = patient.getorganslot(ORGAN_SLOT_AQ_SPINE)
	TEST_ASSERT(istype(spine) && patient.is_holding(held), "A species change dropped the held item through the spine swap")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM), "A species change left the spine paralysis on")

	// A broken spine is only the wound: the organ is not hurt twice for it
	patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	TEST_ASSERT(!spine.damage, "A spine fracture also damaged the spine organ")
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	qdel(chest.get_wound(WOUND_SPINE))

	spine.setOrganDamage(spine.maxHealth)
	spine.on_life()
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_PARALYSIS_L_LEG) && !HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM), "A dead spine does not paralyse only the legs")
	spine.Remove(patient)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM) && HAS_TRAIT(patient, TRAIT_PARALYSIS_R_LEG), "A body without a spine can move")
	TEST_ASSERT(findtext(jointext(patient.aq_organ_scan_lines(), " "), "Brak kręgosłupa"), "The scanner does not explain the paralysis of a body without a spine")
	qdel(spine)

	var/obj/item/organ/aq_spine/cybernetic/titanium = new()
	titanium.Insert(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM) && !HAS_TRAIT(patient, TRAIT_PARALYSIS_L_LEG), "A new spine left the paralysis")
	var/datum/wound/spinal/wound = patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	TEST_ASSERT(istype(wound, /datum/wound/spinal/bruise), "A titanium spine broke")

#undef TEST_ASSERT
