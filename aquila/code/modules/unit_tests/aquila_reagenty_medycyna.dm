// AQUILA - testy reagentów z grupy medycyna (raport/reagenty_02_plan_portu.md).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - new medicine reagents: each one does what the plan says and no more
/datum/unit_test/aquila_reagenty_medycyna

/// Runs the patient's reagents for a few Life cycles
/datum/unit_test/aquila_reagenty_medycyna/proc/metabolize_cycles(mob/living/carbon/human/patient, cycles)
	for(var/i in 1 to cycles)
		patient.reagents.metabolize(patient, can_overdose = TRUE)

/datum/unit_test/aquila_reagenty_medycyna/Run()
	// Osteodaksyn: speeds up a taped fracture, does nothing to an untreated one
	var/mob/living/carbon/human/bones = allocate(/mob/living/carbon/human)
	var/datum/wound/blunt/fracture/taped = new()
	taped.apply_wound(bones.get_bodypart(BODY_ZONE_R_LEG), silent = TRUE)
	taped.gelled = TRUE
	taped.start_knitting()
	var/datum/wound/blunt/fracture/bare = new()
	bare.apply_wound(bones.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	bones.reagents.add_reagent(/datum/reagent/medicine/osteodaxon, 10)
	metabolize_cycles(bones, 3)
	TEST_ASSERT(taped.regen_progress >= 6 SECONDS, "Osteodaksyn did not speed up a taped fracture ([taped.regen_progress])")
	TEST_ASSERT(bare.regen_progress == 0, "Osteodaksyn knitted a fracture without gel and tape")

	// Osteodaksyn is a weak painkiller, Ignizol burns like fuel, the quick clot medipen goes into the squad medic kit
	TEST_ASSERT(GLOB.aq_painkillers[/datum/reagent/medicine/osteodaxon] > 0, "Osteodaksyn takes no pain off")
	var/datum/reagent/medicine/ignisol/ignisol = GLOB.chemical_reagents_list[/datum/reagent/medicine/ignisol]
	TEST_ASSERT(ignisol.accelerant_quality > 0, "Ignizol does not burn like fuel")
	var/datum/squad_loadout/aquila/nt/medic/medic_kit = new()
	TEST_ASSERT(/obj/item/reagent_containers/hypospray/medipen/quickclot in medic_kit.items, "The squad medic kit has no quick clot medipen")
	qdel(medic_kit)

	// Szybkie krzepnięcie: no blood lost from bleeding while it works, the bleeding is still there
	var/mob/living/carbon/human/bleeder = allocate(/mob/living/carbon/human)
	bleeder.add_bleeding(BLEED_DEEP_WOUND)
	bleeder.reagents.add_reagent(/datum/reagent/medicine/quickclot, 10)
	metabolize_cycles(bleeder, 1)
	TEST_ASSERT(HAS_TRAIT(bleeder, TRAIT_AQ_QUICKCLOT), "Szybkie krzepnięcie gave no clotting trait")
	var/datum/status_effect/bleeding/bleed = bleeder.has_status_effect(STATUS_EFFECT_BLEED)
	TEST_ASSERT(bleed, "The patient is not bleeding")
	var/blood_before = bleeder.blood_volume
	bleed.tick()
	TEST_ASSERT(bleeder.blood_volume == blood_before, "Blood was lost under Szybkie krzepnięcie ([blood_before] -> [bleeder.blood_volume])")
	TEST_ASSERT(bleeder.is_bleeding(), "Szybkie krzepnięcie healed the wound instead of holding it")
	bleeder.reagents.clear_reagents()
	metabolize_cycles(bleeder, 1)
	TEST_ASSERT(!HAS_TRAIT(bleeder, TRAIT_AQ_QUICKCLOT), "The clotting trait stayed after the drug ran out")

	// Szybkie krzepnięcie works with a failing liver too (the liver then runs only self-consuming reagents)
	var/mob/living/carbon/human/liver_failure = allocate(/mob/living/carbon/human)
	var/obj/item/organ/liver/bad_liver = liver_failure.getorganslot(ORGAN_SLOT_LIVER)
	bad_liver.setOrganDamage(bad_liver.maxHealth)
	liver_failure.reagents.add_reagent(/datum/reagent/medicine/quickclot, 10)
	for(var/i in 1 to 2)
		bad_liver.process_reagents(liver_failure)
	TEST_ASSERT(HAS_TRAIT(liver_failure, TRAIT_AQ_QUICKCLOT), "Szybkie krzepnięcie does not work with a failing liver")

	// Sangwiryt and heparin cancel each other
	var/mob/living/carbon/human/clotter = allocate(/mob/living/carbon/human)
	clotter.reagents.add_reagent(/datum/reagent/medicine/sanguirite, 10)
	clotter.reagents.add_reagent(/datum/reagent/toxin/heparin, 5)
	metabolize_cycles(clotter, 3)
	TEST_ASSERT(clotter.reagents.get_reagent_amount(/datum/reagent/toxin/heparin) < 3, "Sangwiryt did not flush heparin")

	// Perydaksyna: heals a failing organ only down to light damage
	var/mob/living/carbon/human/organs = allocate(/mob/living/carbon/human)
	var/obj/item/organ/liver/liver = organs.getorganslot(ORGAN_SLOT_LIVER)
	TEST_ASSERT(liver, "The patient has no liver")
	liver.setOrganDamage(liver.maxHealth)
	organs.reagents.add_reagent(/datum/reagent/medicine/peridaxon, 15)
	metabolize_cycles(organs, 200)
	TEST_ASSERT(liver.damage < liver.maxHealth, "Perydaksyna did not heal a failing liver")
	TEST_ASSERT(liver.damage >= liver.low_threshold, "Perydaksyna healed the liver past light damage ([liver.damage] < [liver.low_threshold])")

	// Addictions: Aminazyna holds off withdrawal without ending the addiction, Bupropion weans off nicotine
	var/mob/living/carbon/human/junkie = allocate(/mob/living/carbon/human)
	junkie.mind_initialize()
	junkie.mind.aq_add_addiction_points(/datum/addiction/nicotine, 700)
	TEST_ASSERT(junkie.mind.aq_is_addicted(/datum/addiction/nicotine), "Could not make the patient addicted")
	LAZYSET(junkie.mind.aq_active_addictions, /datum/addiction/nicotine, 200)
	junkie.reagents.add_reagent(/datum/reagent/medicine/aminazine, 5)
	metabolize_cycles(junkie, 1)
	TEST_ASSERT(junkie.mind.aq_active_addictions[/datum/addiction/nicotine] == 1, "Aminazyna did not hold off the withdrawal")
	TEST_ASSERT(junkie.mind.aq_is_addicted(/datum/addiction/nicotine), "Aminazyna ended the addiction")
	junkie.reagents.clear_reagents()
	junkie.reagents.add_reagent(/datum/reagent/medicine/bupropion, 30)
	metabolize_cycles(junkie, 30)
	TEST_ASSERT(!junkie.mind.aq_is_addicted(/datum/addiction/nicotine), "Bupropion did not end a nicotine addiction")

	// Sole trzeźwiące wake a sleeper, but not someone in crit
	var/mob/living/carbon/human/sleeper = allocate(/mob/living/carbon/human)
	sleeper.Sleeping(60 SECONDS)
	sleeper.reagents.add_reagent(/datum/reagent/medicine/ammonium_bicarbonate, 5)
	metabolize_cycles(sleeper, 1)
	TEST_ASSERT(!sleeper.IsSleeping(), "Sole trzeźwiące did not wake a sleeper")
	var/mob/living/carbon/human/dying = allocate(/mob/living/carbon/human)
	dying.adjustBruteLoss(150)
	dying.Sleeping(60 SECONDS)
	dying.reagents.add_reagent(/datum/reagent/medicine/ammonium_bicarbonate, 5)
	metabolize_cycles(dying, 1)
	TEST_ASSERT(dying.IsSleeping(), "Sole trzeźwiące woke someone in crit")

	// Ignizol warms a cold body and takes frost off the limbs
	var/mob/living/carbon/human/frozen = allocate(/mob/living/carbon/human)
	frozen.bodytemperature = BODYTEMP_NORMAL - 40
	var/obj/item/bodypart/arm = frozen.get_bodypart(BODY_ZONE_L_ARM)
	arm.aq_frost = 30
	frozen.reagents.add_reagent(/datum/reagent/medicine/ignisol, 5)
	metabolize_cycles(frozen, 1)
	TEST_ASSERT(frozen.bodytemperature > BODYTEMP_NORMAL - 40, "Ignizol did not warm the body")
	TEST_ASSERT(arm.aq_frost < 30, "Ignizol did not take frost off the arm")

	// Equalizon evens the damage out without healing it
	var/mob/living/carbon/human/uneven = allocate(/mob/living/carbon/human)
	uneven.adjustBruteLoss(40)
	var/total_before = uneven.getBruteLoss() + uneven.getFireLoss() + uneven.getToxLoss() + uneven.getOxyLoss()
	uneven.reagents.add_reagent(/datum/reagent/medicine/equalizone, 10)
	metabolize_cycles(uneven, 1)
	TEST_ASSERT(uneven.getBruteLoss() < 40 && uneven.getFireLoss() > 0, "Equalizon did not move brute damage to other kinds")
	var/total_after = uneven.getBruteLoss() + uneven.getFireLoss() + uneven.getToxLoss() + uneven.getOxyLoss()
	TEST_ASSERT(abs(total_after - total_before) < 0.05, "Equalizon changed the total damage ([total_before] -> [total_after])")

	// Toksyna hamująca metabolizm flushes medicine faster than it would go by itself
	var/mob/living/carbon/human/poisoned = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/control = allocate(/mob/living/carbon/human)
	poisoned.reagents.add_reagent(/datum/reagent/toxin/metabolism_inhibitor, 10)
	poisoned.reagents.add_reagent(/datum/reagent/medicine/bicaridine, 10)
	control.reagents.add_reagent(/datum/reagent/medicine/bicaridine, 10)
	metabolize_cycles(poisoned, 3)
	metabolize_cycles(control, 3)
	TEST_ASSERT(poisoned.reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine) < control.reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine), "The metabolism toxin did not flush bicaridine")

	// Dermagen on the skin removes scars
	var/mob/living/carbon/human/scarred = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/chest = scarred.get_bodypart(BODY_ZONE_CHEST)
	chest.add_scar("długą bliznę")
	var/datum/reagent/medicine/dermagen/dermagen = GLOB.chemical_reagents_list[/datum/reagent/medicine/dermagen]
	dermagen.reaction_mob(scarred, TOUCH, 10, FALSE)
	TEST_ASSERT(!LAZYLEN(chest.scars), "Dermagen did not remove the scar")

	// Perydaksyna through the real liver path: a failing liver metabolizes only self-consuming reagents
	var/mob/living/carbon/human/liverless = allocate(/mob/living/carbon/human)
	var/obj/item/organ/liver/dead_liver = liverless.getorganslot(ORGAN_SLOT_LIVER)
	dead_liver.setOrganDamage(dead_liver.maxHealth)
	TEST_ASSERT(dead_liver.organ_flags & ORGAN_FAILING, "A liver at full damage is not failing")
	liverless.reagents.add_reagent(/datum/reagent/medicine/peridaxon, 15)
	for(var/i in 1 to 5)
		dead_liver.process_reagents(liverless)
	TEST_ASSERT(dead_liver.damage < dead_liver.maxHealth, "Perydaksyna did not work with a failing liver")

	// Equalizon keeps the total on a toxin-immune body
	var/mob/living/carbon/human/immune = allocate(/mob/living/carbon/human)
	ADD_TRAIT(immune, TRAIT_TOXIMMUNE, "aquila_reagenty_test")
	immune.adjustBruteLoss(40)
	var/immune_before = immune.getBruteLoss() + immune.getFireLoss() + immune.getToxLoss() + immune.getOxyLoss()
	immune.reagents.add_reagent(/datum/reagent/medicine/equalizone, 10)
	metabolize_cycles(immune, 1)
	var/immune_after = immune.getBruteLoss() + immune.getFireLoss() + immune.getToxLoss() + immune.getOxyLoss()
	TEST_ASSERT(abs(immune_after - immune_before) < 0.05, "Equalizon changed the total damage of a toxin-immune body ([immune_before] -> [immune_after])")
	TEST_ASSERT(immune.getBruteLoss() < 40, "Equalizon moved no damage on a toxin-immune body")

	// Equalizon keeps the total on a toxin lover (toxins heal it) and does not count damage it cannot take off a prosthesis
	var/mob/living/carbon/human/slime = allocate(/mob/living/carbon/human)
	ADD_TRAIT(slime, TRAIT_TOXINLOVER, "aquila_reagenty_test")
	slime.adjustBruteLoss(8)
	slime.adjustOxyLoss(8)
	var/slime_before = slime.getBruteLoss() + slime.getFireLoss() + slime.getToxLoss() + slime.getOxyLoss()
	slime.reagents.add_reagent(/datum/reagent/medicine/equalizone, 10)
	metabolize_cycles(slime, 1)
	var/slime_after = slime.getBruteLoss() + slime.getFireLoss() + slime.getToxLoss() + slime.getOxyLoss()
	TEST_ASSERT(abs(slime_after - slime_before) < 0.05, "Equalizon changed the total damage of a toxin lover ([slime_before] -> [slime_after])")
	var/mob/living/carbon/human/cyborg_arm = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/old_arm = cyborg_arm.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/r_arm/robot/prosthesis = new()
	prosthesis.replace_limb(cyborg_arm, TRUE)
	qdel(old_arm)
	prosthesis.receive_damage(6)
	var/cyborg_before = cyborg_arm.getBruteLoss() + cyborg_arm.getFireLoss() + cyborg_arm.getToxLoss() + cyborg_arm.getOxyLoss()
	cyborg_arm.reagents.add_reagent(/datum/reagent/medicine/equalizone, 10)
	metabolize_cycles(cyborg_arm, 1)
	var/cyborg_after = cyborg_arm.getBruteLoss() + cyborg_arm.getFireLoss() + cyborg_arm.getToxLoss() + cyborg_arm.getOxyLoss()
	TEST_ASSERT(abs(cyborg_after - cyborg_before) < 0.05, "Equalizon added damage because of a damaged prosthesis ([cyborg_before] -> [cyborg_after])")

	// Szybkie krzepnięcie: a dragged patient loses no blood while it works, and does lose it without it
	var/mob/living/carbon/human/dragged = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	dragged.add_bleeding(BLEED_DEEP_WOUND)
	dragged.adjustBruteLoss(100)
	dragged.blood_volume = BLOOD_VOLUME_NORMAL // a trail needs enough blood, and dragging costs blood only lying down
	dragged.mobility_flags &= ~MOBILITY_STAND
	var/turf/drag_start = run_loc_floor_bottom_left
	var/turf/drag_next = get_step(drag_start, EAST)
	var/area/drag_area = get_area(drag_start)
	var/old_gravity = drag_area.has_gravity
	drag_area.has_gravity = STANDARD_GRAVITY // no trails in zero gravity, and the test room has no generator
	ADD_TRAIT(dragged, TRAIT_AQ_QUICKCLOT, "aquila_reagenty_test")
	var/dragged_blood = dragged.blood_volume
	dragged.make_blood_trail(drag_next, drag_start, EAST, EAST)
	var/clotted_loss = dragged_blood - dragged.blood_volume
	REMOVE_TRAIT(dragged, TRAIT_AQ_QUICKCLOT, "aquila_reagenty_test")
	dragged_blood = dragged.blood_volume
	dragged.make_blood_trail(drag_next, drag_start, EAST, EAST)
	var/bare_loss = dragged_blood - dragged.blood_volume
	drag_area.has_gravity = old_gravity
	// The unit test cleanup skips effects: the trails would stay for the next tests
	for(var/turf/used in list(drag_start, drag_next))
		for(var/obj/effect/decal/cleanable/blood/stain in used)
			qdel(stain)
		for(var/obj/effect/blood_trace/trace in used)
			qdel(trace)
	TEST_ASSERT(clotted_loss == 0, "A dragged patient lost [clotted_loss] blood under Szybkie krzepnięcie")
	TEST_ASSERT(bare_loss > 0, "A dragged bleeding patient lost no blood even without Szybkie krzepnięcie, so the test proves nothing")




#undef TEST_ASSERT
