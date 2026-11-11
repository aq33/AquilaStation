// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - bleeding per limb (blood_limbs.dm): a hit bleeds from the limb that was hit, bandages and tourniquets work on
/// their own limb only, a stump bleeds from its zone
/datum/unit_test/aquila_bleeding_limbs

/datum/unit_test/aquila_bleeding_limbs/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)

	// Bleeding right after a hit comes from the limb that was hit
	patient.apply_damage(10, BRUTE, BODY_ZONE_L_LEG)
	patient.add_bleeding(BLEED_CUT)
	TEST_ASSERT(patient.aq_get_limb_bleed(BODY_ZONE_L_LEG) > 0, "Bleeding after a hit on the left leg is not on the left leg ([json_encode(patient.aq_get_limb_bleeds())])")
	TEST_ASSERT(!patient.aq_get_limb_bleed(BODY_ZONE_CHEST), "Bleeding after a hit on the leg also went to the chest")

	// A second limb bleeds on its own and the total is the sum
	patient.add_bleeding(BLEED_SURFACE, BODY_ZONE_R_ARM)
	TEST_ASSERT(abs(patient.get_bleed_rate() - (BLEED_CUT + BLEED_SURFACE)) < 0.01, "The bleed rate [patient.get_bleed_rate()] is not the sum of the limbs")

	// A bandage on the arm does not stop the leg
	var/obj/item/stack/medical/bandage/bandage = allocate(/obj/item/stack/medical/bandage)
	medic.zone_selected = BODY_ZONE_R_ARM
	bandage.attack(patient, medic)
	TEST_ASSERT(!patient.is_bleeding(BODY_ZONE_R_ARM), "The bandage did not stop the arm")
	TEST_ASSERT(patient.is_bandaged(BODY_ZONE_R_ARM), "The arm is not bandaged")
	TEST_ASSERT(patient.is_bleeding(BODY_ZONE_L_LEG), "A bandage on the arm stopped the leg")

	// A tourniquet on the leg holds the leg; new bleeding on the arm gets through
	var/obj/item/tourniquet/tourniquet = allocate(/obj/item/tourniquet)
	tourniquet.attach(patient, BODY_ZONE_L_LEG)
	TEST_ASSERT(patient.aq_get_limb_bleed(BODY_ZONE_L_LEG) < BLEED_CUT * 0.2, "The tourniquet did not stop the leg")
	patient.add_bleeding(BLEED_CUT, BODY_ZONE_L_ARM)
	TEST_ASSERT(abs(patient.aq_get_limb_bleed(BODY_ZONE_L_ARM) - BLEED_CUT) < 0.01, "A tourniquet on the leg held the arm")
	tourniquet.detach()

	// Cautery on one limb closes that limb only
	patient.cauterise_wounds(zone = BODY_ZONE_L_ARM)
	TEST_ASSERT(!patient.is_bleeding(BODY_ZONE_L_ARM), "Cautery did not close the arm")
	TEST_ASSERT(patient.is_bleeding(BODY_ZONE_L_LEG), "Cautery on the arm closed the leg")

	// Holding a wound cuts the held limb only
	patient.cauterise_wounds()
	patient.add_bleeding(BLEED_CRITICAL, BODY_ZONE_CHEST)
	patient.add_bleeding(BLEED_SCRATCH, BODY_ZONE_HEAD)
	patient.zone_selected = BODY_ZONE_HEAD
	patient.hold_wounds()
	TEST_ASSERT(patient.aq_held_bleed_zone == BODY_ZONE_HEAD, "Holding the head holds [patient.aq_held_bleed_zone]")
	var/datum/status_effect/bleeding/bleed = patient.get_bleed_status()
	TEST_ASSERT(abs(bleed.get_held_reduction() - BLEED_SCRATCH) < 0.01, "Holding a scratch on the head cut [bleed.get_held_reduction()] instead of the scratch")
	patient.stop_holding_wounds()
	patient.cauterise_wounds()

	// A torn off arm bleeds from its stump, and a bandage on the stump stops it
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	arm.dismember()
	TEST_ASSERT(patient.aq_get_limb_bleed(BODY_ZONE_R_ARM) > 0, "The stump does not bleed ([json_encode(patient.aq_get_limb_bleeds())])")
	medic.zone_selected = BODY_ZONE_R_ARM
	bandage.attack(patient, medic)
	TEST_ASSERT(!patient.is_bleeding(BODY_ZONE_R_ARM), "A bandage on the stump did not stop it")
	qdel(arm)

/// AQUILA - a cracked or caved-in skull: head names, the head displacement from cranial_fissure.dmi and brain traumas
/datum/unit_test/aquila_skull_wounds

/datum/unit_test/aquila_skull_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/brain/brain = patient.getorganslot(ORGAN_SLOT_BRAIN)

	var/datum/wound/blunt/fracture/crack = new()
	crack.apply_wound(head, silent = TRUE)
	TEST_ASSERT(crack.name == "Pęknięta czaszka", "A fracture on the head is called [crack.name]")
	TEST_ASSERT(patient.get_filter("cranial_fissure_displacement"), "A cracked skull does not bend the head")
	TEST_ASSERT(crack.skull_trauma, "A cracked skull gave no brain trauma")
	TEST_ASSERT(istype(crack.skull_trauma, /datum/brain_trauma/mild), "A cracked skull gave [crack.skull_trauma?.type] instead of a mild trauma")
	TEST_ASSERT(crack.skull_trauma in brain.traumas, "The skull trauma is not in the brain")

	// The trauma goes away for a while and comes back
	crack.next_skull_trauma = 0
	crack.wound_effects(1)
	TEST_ASSERT(!crack.skull_trauma, "The skull trauma did not go away for a while")
	crack.next_skull_trauma = 0
	crack.wound_effects(1)
	TEST_ASSERT(crack.skull_trauma, "The skull trauma did not come back")

	// Healed: no trauma, no displacement
	var/datum/brain_trauma/trauma = crack.skull_trauma
	qdel(crack)
	TEST_ASSERT(QDELETED(trauma), "The skull trauma stayed after the bone healed")
	TEST_ASSERT(!patient.get_filter("cranial_fissure_displacement"), "The head is still bent after the skull healed")

	// A caved-in skull gives severe traumas, a fracture elsewhere keeps the limb name
	var/datum/wound/blunt/compound/dent = new()
	dent.apply_wound(head, silent = TRUE)
	TEST_ASSERT(dent.name == "Wgnieciona czaszka", "A compound fracture on the head is called [dent.name]")
	TEST_ASSERT(istype(dent.skull_trauma, /datum/brain_trauma/severe), "A caved-in skull gave [dent.skull_trauma?.type] instead of a severe trauma")
	qdel(dent)
	var/datum/wound/blunt/fracture/arm_fracture = new()
	arm_fracture.apply_wound(patient.get_bodypart(BODY_ZONE_L_ARM), silent = TRUE)
	TEST_ASSERT(arm_fracture.name == "Pęknięcie kości", "A fracture on the arm is called [arm_fracture.name]")
	TEST_ASSERT(!arm_fracture.skull_trauma, "A fracture on the arm gave a brain trauma")
	TEST_ASSERT(!patient.get_filter("cranial_fissure_displacement"), "A fracture on the arm bends the head")
	qdel(arm_fracture)
	patient.cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)

/// AQUILA - pain (pain.dm): damage hurts, pain slows instead of damage, painkillers and analgesia take it off
/datum/unit_test/aquila_pain

/datum/unit_test/aquila_pain/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.aq_adrenal_reserve = 0 // no adrenaline here, it has its own test

	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	leg.receive_damage(brute = 45)
	patient.updatehealth()
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, MOVESPEED_ID_DAMAGE_SLOWDOWN), "Damage still slows down by itself")
	for(var/i in 1 to 10)
		patient.aq_handle_pain()
	TEST_ASSERT(patient.aq_pain_raw >= 45, "45 brute on the leg makes only [patient.aq_pain_raw] pain")
	TEST_ASSERT(patient.aq_pain >= 40, "The felt pain [patient.aq_pain] did not catch up with [patient.aq_pain_raw]")
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_pain"), "Pain [patient.aq_pain] does not slow down")
	TEST_ASSERT(patient.aq_worst_pain_zone() == BODY_ZONE_L_LEG, "The worst pain is in [patient.aq_worst_pain_zone()] instead of the left leg")
	TEST_ASSERT(patient.stamina.regen_rate < STAMINA_REGEN, "Pain does not slow the stamina regeneration")

	// Morphine takes the pain off, and the slowdown with it
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 10)
	for(var/i in 1 to 10)
		patient.aq_handle_pain()
	TEST_ASSERT(patient.aq_pain < 10, "Morphine left [patient.aq_pain] pain from [patient.aq_pain_raw]")
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, "aq_pain"), "No pain but still slowed down")
	patient.reagents.clear_reagents()

	// Painkillers take off less from a big pain (cmss13)
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 10)
	TEST_ASSERT(patient.aq_pain_suppression(200) < patient.aq_pain_suppression(20), "A painkiller takes off as much from a big pain as from a small one")
	patient.reagents.clear_reagents()

	// A limb under analgesia (anaesthesia) feels nothing
	ADD_TRAIT(patient, TRAIT_ANALGESIA, TRAIT_GENERIC)
	patient.aq_handle_pain()
	TEST_ASSERT(patient.aq_pain_raw == 0, "Analgesia left [patient.aq_pain_raw] pain")
	REMOVE_TRAIT(patient, TRAIT_ANALGESIA, TRAIT_GENERIC)

	// A paralysed limb feels nothing
	ADD_TRAIT(patient, TRAIT_PARALYSIS_L_LEG, TRAIT_GENERIC)
	patient.update_disabled_bodyparts()
	TEST_ASSERT(!patient.aq_limb_pain(leg), "A paralysed leg hurts")
	REMOVE_TRAIT(patient, TRAIT_PARALYSIS_L_LEG, TRAIT_GENERIC)
	patient.update_disabled_bodyparts()

	// A wound hurts more untreated
	var/datum/wound/blunt/fracture/fracture = new()
	fracture.apply_wound(patient.get_bodypart(BODY_ZONE_R_ARM), silent = TRUE)
	var/untreated = fracture.get_pain()
	fracture.treated = TRUE
	TEST_ASSERT(fracture.get_pain() < untreated, "A splinted fracture hurts as much as an untreated one")
	qdel(fracture)

/// AQUILA - adrenaline (adrenaline.dm): the glands release it under pain until the reserve runs dry, doses build
/// tolerance, the rush ends with a crash, the recipe and the autoinjector in the survival box
/datum/unit_test/aquila_adrenaline

/datum/unit_test/aquila_adrenaline/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	chest.receive_damage(brute = 60)

	// Strong pain: the glands release adrenaline and use the reserve
	patient.aq_handle_pain()
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/adrenaline), "Strong pain released no adrenaline")
	TEST_ASSERT(patient.aq_adrenal_reserve < 100, "The release did not use the reserve")
	TEST_ASSERT(patient.aq_pain_suppression(patient.aq_pain_raw) > 0, "Adrenaline does not numb the pain")

	// The reserve runs dry
	for(var/i in 1 to 10)
		patient.reagents.clear_reagents()
		patient.aq_next_adrenal_release = 0
		patient.aq_handle_adrenal_glands()
	patient.reagents.clear_reagents()
	patient.aq_next_adrenal_release = 0
	patient.aq_handle_adrenal_glands()
	TEST_ASSERT(!patient.reagents.has_reagent(/datum/reagent/medicine/adrenaline), "The glands still release adrenaline with [patient.aq_adrenal_reserve]% reserve")

	// Tolerance makes it weaker
	var/fresh = patient.aq_adrenaline_strength()
	patient.aq_adrenaline_tolerance = 1
	TEST_ASSERT(patient.aq_adrenaline_strength() < fresh, "Tolerance does not weaken adrenaline")
	patient.aq_adrenaline_tolerance = 0

	// A big rush ends with a crash
	patient.reagents.add_reagent(/datum/reagent/medicine/adrenaline, 10)
	var/datum/reagent/medicine/adrenaline/adrenaline = patient.reagents.has_reagent(/datum/reagent/medicine/adrenaline)
	adrenaline.on_mob_life(patient)
	adrenaline.on_mob_end_metabolize(patient)
	patient.reagents.del_reagent(/datum/reagent/medicine/adrenaline)
	TEST_ASSERT(patient.has_status_effect(/datum/status_effect/aq_adrenaline_crash), "No crash after the rush")
	patient.remove_status_effect(/datum/status_effect/aq_adrenaline_crash)

	// Recipe: epinephrine + sugar + salt
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)
	beaker.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 10, reagtemp = 320, no_react = TRUE)
	beaker.reagents.add_reagent(/datum/reagent/consumable/sugar, 10, reagtemp = 320, no_react = TRUE)
	beaker.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 10, reagtemp = 320)
	for(var/i in 1 to 60)
		if(!beaker.reagents.is_reacting)
			break
		beaker.reagents.process(1)
	TEST_ASSERT(beaker.reagents.get_reagent_amount(/datum/reagent/medicine/adrenaline) >= 15, "The recipe made [beaker.reagents.get_reagent_amount(/datum/reagent/medicine/adrenaline)]u of adrenaline from 10u of each")

	// One autoinjector in the survival box
	var/obj/item/storage/box/survival/box = allocate(/obj/item/storage/box/survival)
	var/obj/item/reagent_containers/hypospray/medipen/aq_adrenaline/pen = locate() in box
	TEST_ASSERT(pen, "No adrenaline autoinjector in the survival box")
	TEST_ASSERT(pen.reagents.get_reagent_amount(/datum/reagent/medicine/adrenaline) == 10, "The autoinjector holds [pen.reagents.get_reagent_amount(/datum/reagent/medicine/adrenaline)]u instead of 10u")
	TEST_ASSERT(locate(/obj/item/stack/medical/bandage) in box, "The autoinjector took the place of the bandages")

/// AQUILA - spine (spinal.dm, operation_spine.dm): a bruise heals lying down, a fracture paralyses the legs until
/// the two operations and the nerves regrow, a broken neck paralyses all limbs, a vending machine breaks the spine
/datum/unit_test/aquila_spine

/datum/unit_test/aquila_spine/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)

	// Bruise: slows down, heals while lying
	var/datum/wound/spinal/bruise/bruise = patient.aq_injure_spine(WOUND_SEVERITY_SEVERE)
	TEST_ASSERT(istype(bruise), "No spinal bruise")
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_spine"), "A bruised spine does not slow down")
	patient.set_resting(TRUE, silent = TRUE)
	bruise.wound_effects(bruise.rest_time / (1 SECONDS))
	TEST_ASSERT(QDELETED(bruise), "The bruise did not heal while lying")
	patient.set_resting(FALSE, silent = TRUE)

	// Fracture: legs paralysed and numb, arms fine
	var/datum/wound/spinal/fracture/fracture = patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	TEST_ASSERT(istype(fracture), "No spinal fracture")
	TEST_ASSERT(leg.disabled == BODYPART_DISABLED_PARALYSIS, "A broken spine does not paralyse the legs")
	TEST_ASSERT(arm.disabled != BODYPART_DISABLED_PARALYSIS, "A broken lower spine paralyses the arms")
	leg.receive_damage(brute = 30)
	TEST_ASSERT(!patient.aq_limb_pain(leg), "A leg below the broken spine hurts")
	TEST_ASSERT(findtext(jointext(patient.get_wound_scan_lines(), ""), "Złamanie kręgosłupa"), "The analyzer does not see the broken spine")

	// Surgery: stabilise, then fuse, then the nerves regrow
	var/datum/surgery_operation/limb/stabilize_spine/stabilize = new()
	var/datum/surgery_operation/limb/fuse_spine/fuse = new()
	TEST_ASSERT(stabilize.state_check(chest), "Stabilising is not offered for a broken spine")
	TEST_ASSERT(!fuse.state_check(chest), "Fusing is offered before stabilising")
	stabilize.on_success(chest, patient, null, list())
	TEST_ASSERT(fuse.state_check(chest), "Fusing is not offered after stabilising")
	fuse.on_success(chest, patient, null, list())
	TEST_ASSERT(fracture.treated, "Fusing did not start the nerve regrowth")
	TEST_ASSERT(leg.disabled == BODYPART_DISABLED_PARALYSIS, "The legs moved before the nerves regrew")
	patient.reagents.add_reagent(/datum/reagent/medicine/mannitol, 10)
	fracture.wound_effects(fracture.regen_time / (2 SECONDS))
	TEST_ASSERT(QDELETED(fracture), "Mannitol did not speed up the nerve regrowth")
	TEST_ASSERT(leg.disabled != BODYPART_DISABLED_PARALYSIS, "The legs are still paralysed after the spine healed")
	patient.reagents.clear_reagents()
	qdel(stabilize)
	qdel(fuse)

	// Broken neck: all limbs
	var/datum/wound/spinal/fracture/neck = patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL, cervical = TRUE)
	TEST_ASSERT(arm.disabled == BODYPART_DISABLED_PARALYSIS, "A broken neck does not paralyse the arms")
	qdel(neck)
	TEST_ASSERT(arm.disabled != BODYPART_DISABLED_PARALYSIS, "The arms stayed paralysed")

	// A vending machine breaks the spine instead of the permanent paraplegia
	var/obj/machinery/vending/machine = allocate(/obj/machinery/vending/cola)
	machine.forcecrit = 4 // the crushed spine case
	machine.tilt(patient, crit = TRUE)
	TEST_ASSERT(chest.get_wound(WOUND_SPINE), "A vending machine crit did not break the spine")
	var/obj/item/organ/brain/brain = patient.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(!(locate(/datum/brain_trauma/severe/paralysis/paraplegic) in brain.traumas), "The vending machine still gives the permanent paraplegia")

/// AQUILA - medical overlays (medical_overlays.dm): bandage, splint, brace, open skull and stump
/datum/unit_test/aquila_medical_overlays

/datum/unit_test/aquila_medical_overlays/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	patient.add_bleeding(BLEED_CUT, BODY_ZONE_L_ARM)
	patient.suppress_bloodloss(BLEED_CUT, BODY_ZONE_L_ARM)
	patient.update_wound_overlays()
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "bandage_l_arm"), "A bandaged arm shows no bandage ([patient.aq_wound_overlay_key])")
	patient.cauterise_wounds()

	var/datum/wound/blunt/fracture/fracture = new()
	fracture.apply_wound(patient.get_bodypart(BODY_ZONE_R_LEG), silent = TRUE)
	fracture.treated = TRUE
	patient.update_wound_overlays()
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "splint_r_leg") && findtext(patient.aq_wound_overlay_key, "splint_r_foot"), "A splinted leg shows no splint ([patient.aq_wound_overlay_key])")
	qdel(fracture)
	TEST_ASSERT(!findtext(patient.aq_wound_overlay_key, "splint_r_leg"), "The splint stayed after the bone healed")

	var/datum/wound/spinal/fracture/spine = patient.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	spine.stabilize()
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "brace_torso"), "A stabilised spine shows no brace ([patient.aq_wound_overlay_key])")
	qdel(spine)

	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	head.add_surgical_state(SURGERY_BONE_SAWED)
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "skull_open"), "A sawed skull shows no open skull ([patient.aq_wound_overlay_key])")
	head.remove_surgical_state(SURGERY_BONE_SAWED)
	TEST_ASSERT(!findtext(patient.aq_wound_overlay_key, "skull_open"), "The open skull stayed after closing")

	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	arm.drop_limb()
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "stump_r_arm_bone"), "A torn off arm shows no stump ([patient.aq_wound_overlay_key])")
	arm.attach_limb(patient)
	TEST_ASSERT(!findtext(patient.aq_wound_overlay_key, "stump_r_arm"), "The stump stayed after the arm was attached again")

#undef TEST_ASSERT
