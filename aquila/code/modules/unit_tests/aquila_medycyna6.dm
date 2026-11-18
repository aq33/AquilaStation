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

/// AQUILA - AquilaMed 6 spine organ: spine wounds hurt it, a dead one paralyses the legs, none paralyses everything,
/// a titanium one does not break
/datum/unit_test/aquila_spine_organ

/datum/unit_test/aquila_spine_organ/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/aq_spine/spine = patient.getorganslot(ORGAN_SLOT_AQ_SPINE)
	TEST_ASSERT(istype(spine), "A human has no spine")
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_PARALYSIS_L_LEG), "A healthy spine paralyses the legs")

	patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	TEST_ASSERT(spine.damage >= spine.fracture_damage, "A broken spine did not hurt the spine organ")
	var/after_fracture = spine.damage
	patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	patient.aq_injure_spine(WOUND_SEVERITY_SEVERE)
	TEST_ASSERT(spine.damage == after_fracture, "The same spine wound returned again hurt the spine organ again")
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	qdel(chest.get_wound(WOUND_SPINE))

	spine.setOrganDamage(spine.maxHealth)
	spine.on_life()
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_PARALYSIS_L_LEG) && !HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM), "A dead spine does not paralyse only the legs")
	spine.Remove(patient)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM) && HAS_TRAIT(patient, TRAIT_PARALYSIS_R_LEG), "A body without a spine can move")
	qdel(spine)

	var/obj/item/organ/aq_spine/cybernetic/titanium = new()
	titanium.Insert(patient)
	TEST_ASSERT(!HAS_TRAIT(patient, TRAIT_PARALYSIS_L_ARM) && !HAS_TRAIT(patient, TRAIT_PARALYSIS_L_LEG), "A new spine left the paralysis")
	var/datum/wound/spinal/wound = patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	TEST_ASSERT(istype(wound, /datum/wound/spinal/bruise), "A titanium spine broke")

/// AQUILA - AquilaMed 6 paired lungs and kidneys: one side can be taken out and sewn back,
/// one kidney filters less
/datum/unit_test/aquila_paired_organs

/datum/unit_test/aquila_paired_organs/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/lungs/lungs = patient.getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/kidneys/kidneys = patient.getorganslot(ORGAN_SLOT_KIDNEYS)
	TEST_ASSERT(lungs.aq_paired && kidneys.aq_paired && lungs.aq_working_sides() == 2, "Human lungs and kidneys are not a full pair")

	// Taking one kidney out: half stays, half is a new organ, joining it back makes a pair
	var/full = kidneys.aq_efficiency()
	var/datum/surgery_operation/organ/aq_split_pair/kidneys/split = new()
	TEST_ASSERT(split.state_check(kidneys), "A full kidney pair cannot be split")
	split.on_success(kidneys, patient, null, list())
	var/obj/item/organ/kidneys/donated = locate() in get_turf(patient)
	TEST_ASSERT(istype(donated) && donated.aq_sides == AQ_SIDE_LEFT && kidneys.aq_sides == AQ_SIDE_RIGHT, "Splitting did not leave one kidney in the body and give the other")
	TEST_ASSERT(kidneys.aq_efficiency() < full, "One kidney filters as well as two")
	var/datum/surgery_operation/organ/aq_join_pair/kidneys/join = new()
	TEST_ASSERT(join.state_check(kidneys) && join.snowflake_check_availability(patient, patient, donated, BODY_ZONE_PRECISE_GROIN), "The missing kidney cannot be sewn back")
	join.on_success(kidneys, patient, donated, list())
	TEST_ASSERT(kidneys.aq_sides == AQ_SIDES_BOTH && QDELETED(donated), "Sewing the kidney back did not make a pair")
	qdel(split)
	qdel(join)

	// Species lungs are not a pair
	var/obj/item/organ/lungs/plasmaman/filter = allocate(/obj/item/organ/lungs/plasmaman)
	TEST_ASSERT(!filter.aq_paired, "A plasma filter splits into halves")

#undef TEST_ASSERT
