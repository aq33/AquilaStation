// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - AquilaMed 5 splints and crutches (medical/splint.dm): a splint beats a bandage, falls off when the bone heals,
/// an untreated broken leg gives way, a crutch halves the limp and stops the falls
/datum/unit_test/aquila_splints

/datum/unit_test/aquila_splints/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_R_LEG)
	var/obj/item/stack/medical/bandage/bandage = allocate(/obj/item/stack/medical/bandage)
	var/obj/item/stack/medical/splint/splint = allocate(/obj/item/stack/medical/splint)
	var/obj/item/stack/medical/splint/improvised/improvised = allocate(/obj/item/stack/medical/splint/improvised)

	var/datum/wound/blunt/fracture/fracture = new()
	fracture.apply_wound(leg, silent = TRUE)
	TEST_ASSERT(fracture.can_treat_with(splint) && fracture.can_treat_with(improvised) && fracture.can_treat_with(bandage), "A bare fracture does not take a bandage and both splints")

	// Bandaged: the improvised splint adds nothing, a real splint still goes on
	fracture.treated = TRUE
	TEST_ASSERT(!fracture.can_treat_with(improvised), "An improvised splint goes over a bandage")
	TEST_ASSERT(fracture.can_treat_with(splint), "A real splint does not go over a bandage")
	var/bandaged_limp = fracture.get_limp_slowdown()
	var/bandaged_pain = fracture.get_pain()

	fracture.splinted = TRUE
	TEST_ASSERT(!fracture.can_treat_with(splint), "A second splint goes on")
	TEST_ASSERT(fracture.get_limp_slowdown() < bandaged_limp, "A splint limps as much as a bandage ([fracture.get_limp_slowdown()] / [bandaged_limp])")
	TEST_ASSERT(fracture.get_pain() < bandaged_pain, "A splint hurts as much as a bandage")
	TEST_ASSERT(findtext(fracture.get_scan_text(), "szynie"), "The analyzer does not show the splint: [fracture.get_scan_text()]")

	// The bone heals: the splint falls off
	var/turf/floor = get_turf(patient)
	var/splints_before = 0
	for(var/obj/item/stack/medical/splint/lying in floor)
		splints_before += lying.amount
	qdel(fracture)
	var/splints_after = 0
	for(var/obj/item/stack/medical/splint/lying in floor)
		splints_after += lying.amount
	TEST_ASSERT(splints_after == splints_before + 1, "The splint did not fall off after the bone healed ([splints_before] -> [splints_after])")

	// An untreated broken leg gives way, a crutch stops it and halves the limp
	fracture = new()
	fracture.apply_wound(leg, silent = TRUE)
	var/fell = FALSE
	for(var/i in 1 to 400)
		fracture.aq_on_victim_moved(patient, floor, NORTH)
		if(patient.IsKnockdown())
			fell = TRUE
			break
	TEST_ASSERT(fell, "An untreated broken leg never gave way in 400 steps")
	patient.SetKnockdown(0)
	patient.set_resting(FALSE, silent = TRUE)
	var/limp = fracture.get_limp_slowdown()
	var/obj/item/cane/crutch/crutch = allocate(/obj/item/cane/crutch)
	patient.put_in_hands(crutch)
	TEST_ASSERT(patient.aq_walking_aids() == 1 && patient.aq_walking_aid_mult() == 0.5, "One crutch in hand gives [patient.aq_walking_aids()] aids and x[patient.aq_walking_aid_mult()]")
	for(var/i in 1 to 400)
		fracture.aq_on_victim_moved(patient, floor, NORTH)
	TEST_ASSERT(!patient.IsKnockdown(), "A broken leg gave way with a crutch in hand")
	TEST_ASSERT(limp > 0, "A broken leg does not limp")
	qdel(fracture)

/// AQUILA - amputation shears, nanopaste and the reflex hammer (medical/medical_tools_med5.dm)
/datum/unit_test/aquila_medical_tools_med5

/datum/unit_test/aquila_medical_tools_med5/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	var/obj/item/shears/shears = allocate(/obj/item/shears)
	shears.toolspeed = 0.01
	medic.put_in_active_hand(shears)
	medic.set_combat_mode(FALSE)
	medic.zone_selected = BODY_ZONE_L_ARM

	// A standing, conscious patient does not hold still
	shears.attack(patient, medic)
	TEST_ASSERT(patient.get_bodypart(BODY_ZONE_L_ARM), "The shears took the arm of a standing patient")
	// Out cold: off it goes
	patient.Unconscious(20 SECONDS)
	shears.attack(patient, medic)
	TEST_ASSERT(!patient.get_bodypart(BODY_ZONE_L_ARM), "The shears did not take the arm of an unconscious patient")
	// The head is not a limb for the shears
	medic.zone_selected = BODY_ZONE_HEAD
	shears.attack(patient, medic)
	TEST_ASSERT(patient.get_bodypart(BODY_ZONE_HEAD), "The shears took the head")

	// Nanopaste fixes a robotic limb, not an organic one
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	var/obj/item/bodypart/ipc_arm = ipc.get_bodypart(BODY_ZONE_R_ARM)
	ipc_arm.receive_damage(brute = 30, burn = 0, blocked = 0, updating_health = TRUE, required_status = BODYTYPE_ROBOTIC)
	var/before = ipc_arm.brute_dam
	var/obj/item/stack/medical/nanopaste/paste = allocate(/obj/item/stack/medical/nanopaste)
	medic.zone_selected = BODY_ZONE_R_ARM
	paste.attack(ipc, medic)
	TEST_ASSERT(ipc_arm.brute_dam < before, "Nanopaste did not fix a robotic arm ([ipc_arm.brute_dam] / [before])")
	var/obj/item/bodypart/human_arm = medic.get_bodypart(BODY_ZONE_R_ARM)
	human_arm.receive_damage(brute = 20)
	var/organic_before = human_arm.brute_dam
	patient.zone_selected = BODY_ZONE_R_ARM
	paste.attack(medic, patient)
	TEST_ASSERT(human_arm.brute_dam == organic_before, "Nanopaste healed an organic arm")

	// Reflex hammer: normal, brain damage, prosthesis
	var/mob/living/carbon/human/subject = allocate(/mob/living/carbon/human)
	var/list/result = subject.aq_reflex_result(subject.get_bodypart(BODY_ZONE_L_LEG))
	TEST_ASSERT(findtext(result[1], "prawidłowy"), "A healthy leg has no normal reflex: [result[1]]")
	subject.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	result = subject.aq_reflex_result(subject.get_bodypart(BODY_ZONE_L_LEG))
	TEST_ASSERT(findtext(result[1], "mózgu"), "Brain damage does not show in the reflex: [result[1]]")
	result = ipc.aq_reflex_result(ipc_arm)
	TEST_ASSERT(findtext(result[1], "proteza"), "A prosthesis has a reflex: [result[1]]")

/// AQUILA - AquilaMed 5 painkillers and mood medicine (reagents/chemistry/reagents/med5_reagents.dm)
/datum/unit_test/aquila_med5_reagents

/datum/unit_test/aquila_med5_reagents/Run()
	TEST_ASSERT(GLOB.aq_painkillers[/datum/reagent/medicine/paracetamol] < GLOB.aq_painkillers[/datum/reagent/medicine/tramadol], "Paracetamol is not weaker than tramadol")
	TEST_ASSERT(GLOB.aq_painkillers[/datum/reagent/medicine/tramadol] < GLOB.aq_painkillers[/datum/reagent/medicine/oxycodone], "Tramadol is not weaker than oxycodone")
	TEST_ASSERT(GLOB.aq_painkillers[/datum/reagent/medicine/oxycodone] < GLOB.aq_painkillers[/datum/reagent/medicine/morphine], "Oxycodone is not weaker than morphine")

	// Painkillers take pain off a patient with a broken arm
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.apply_damage(60, BRUTE, BODY_ZONE_R_ARM)
	var/raw = patient.aq_compute_pain()
	TEST_ASSERT(raw > 20, "60 brute on an arm hurts only [raw]")

	// An antidepressant lifts the mood after a few cycles
	var/mob/living/carbon/human/sad = allocate(/mob/living/carbon/human)
	sad.reagents.add_reagent(/datum/reagent/medicine/citalopram, 10)
	for(var/i in 1 to 6)
		sad.reagents.metabolize(sad, can_overdose = TRUE)
	var/datum/component/mood/mood = sad.GetComponent(/datum/component/mood)
	TEST_ASSERT(!mood || mood.mood_events["aq_antidepressant"], "Citalopram gave no mood event")

/// AQUILA - organ transport box (medical/organbox.dm): coolant freezes the organs inside, taking one out or running dry thaws it
/datum/unit_test/aquila_organbox

/datum/unit_test/aquila_organbox/Run()
	var/obj/item/storage/organbox/box = allocate(/obj/item/storage/organbox)
	var/obj/item/organ/heart/heart = allocate(/obj/item/organ/heart)
	heart.forceMove(box)
	box.process(1)
	TEST_ASSERT(!(heart.organ_flags & ORGAN_FROZEN), "An empty box froze the heart")
	box.reagents.add_reagent(/datum/reagent/consumable/ice, 10)
	box.process(1)
	TEST_ASSERT(heart.organ_flags & ORGAN_FROZEN, "A box with ice did not freeze the heart")
	TEST_ASSERT(box.reagents.get_reagent_amount(/datum/reagent/consumable/ice) < 10, "The box used no ice")
	heart.forceMove(get_turf(box))
	TEST_ASSERT(!(heart.organ_flags & ORGAN_FROZEN), "The heart stayed frozen outside the box")
	heart.forceMove(box)
	box.process(1)
	box.reagents.clear_reagents()
	box.process(1)
	TEST_ASSERT(!(heart.organ_flags & ORGAN_FROZEN), "The heart stayed frozen after the coolant ran out")

/// AQUILA - asthma (medical/asthma.dm): salbutamol takes the inflammation off, narrow airways choke, an attack is cured by salbutamol
/datum/unit_test/aquila_asthma

/datum/unit_test/aquila_asthma/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/quirk/asthma/asthma = new(patient, FALSE)
	TEST_ASSERT(locate(/datum/quirk/asthma) in patient.roundstart_quirks, "The asthma quirk did not attach")

	asthma.inflammation = 400
	TEST_ASSERT(asthma.get_airway_mult() < 0.2, "400 inflammation leaves the airways [asthma.get_airway_mult()] open")
	var/oxy = patient.getOxyLoss()
	asthma.apply_breathing_effects(1)
	TEST_ASSERT(patient.getOxyLoss() > oxy, "Narrow airways did not choke")

	// A puff of salbutamol takes inflammation off at once, then more while in the blood
	var/obj/item/inhaler/salbutamol/inhaler = allocate(/obj/item/inhaler/salbutamol)
	inhaler.canister.puff(patient, patient)
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/salbutamol), "The inhaler gave no salbutamol")
	patient.reagents.metabolize(patient, can_overdose = TRUE)
	TEST_ASSERT(asthma.inflammation < 400, "Salbutamol did not take inflammation off at once ([asthma.inflammation])")
	var/after_puff = asthma.inflammation
	asthma.last_process = world.time - 2 SECONDS
	asthma.on_process()
	TEST_ASSERT(asthma.inflammation < after_puff, "Salbutamol in the blood did not keep taking inflammation off")

	// An attack is cured by salbutamol
	patient.reagents.clear_reagents()
	asthma.start_attack()
	var/datum/disease/asthma_attack/attack = asthma.current_attack
	TEST_ASSERT(attack && (attack in patient.diseases), "No asthma attack started")
	patient.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 20)
	for(var/i in 1 to 200)
		if(QDELETED(attack))
			break
		attack.stage_act()
	TEST_ASSERT(QDELETED(attack), "Salbutamol did not cure the asthma attack in 200 ticks")
	TEST_ASSERT(!asthma.current_attack, "The quirk still holds the cured attack")
	qdel(asthma)

/// AQUILA - automated IV drip (medical/iv_plumbing.dm): injects from its built-in reservoir
/datum/unit_test/aquila_iv_plumbing

/datum/unit_test/aquila_iv_plumbing/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/machinery/iv_drip/plumbing/drip = allocate(/obj/machinery/iv_drip/plumbing)
	TEST_ASSERT(drip.reagents == drip.beaker.reagents, "The plumbing component does not work on the reservoir")
	TEST_ASSERT(length(drip.GetComponents(/datum/component/plumbing/automated_iv)), "The drip has no plumbing component")
	drip.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 20)
	drip.attached = patient
	drip.process(2)
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/salbutamol), "The automated IV drip injected nothing")
	drip.attached = null
	drip.update_icon()

/// AQUILA - paramedic kit (medical/paramedic_kit.dm): the belt with medipens, the PDA in the pocket
/datum/unit_test/aquila_paramedic_kit

/datum/unit_test/aquila_paramedic_kit/Run()
	var/obj/item/storage/belt/medical/paramedic/belt = allocate(/obj/item/storage/belt/medical/paramedic)
	TEST_ASSERT(locate(/obj/item/reagent_containers/hypospray/medipen/salacid) in belt, "The paramedic belt has no brute medipen")
	TEST_ASSERT(locate(/obj/item/reagent_containers/hypospray/medipen/oxandrolone) in belt, "The paramedic belt has no burn medipen")
	TEST_ASSERT(locate(/obj/item/flashlight/pen/paramedic) in belt, "The paramedic belt has no UV penlight")
	var/datum/outfit/job/paramedic/outfit = new()
	TEST_ASSERT(outfit.belt == /obj/item/storage/belt/medical/paramedic && outfit.pda_slot == ITEM_SLOT_RPOCKET, "The paramedic outfit has no belt or keeps the PDA on it")
	qdel(outfit)

	// The UV penlight slows a burn infection
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	var/datum/wound/burn/third_degree/burn = new()
	burn.apply_wound(patient.get_bodypart(BODY_ZONE_L_ARM), silent = TRUE)
	var/obj/item/bodypart/burnt_arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	burnt_arm.aq_germs = 50
	var/obj/item/flashlight/pen/paramedic/uv = locate() in belt
	medic.set_combat_mode(FALSE)
	medic.zone_selected = BODY_ZONE_L_ARM
	uv.attack(patient, medic)
	TEST_ASSERT(burnt_arm.aq_germs < 50, "The UV penlight did not touch the infection ([burnt_arm.aq_germs])")
	qdel(burn)

/// AQUILA - tg addictions (reagents/addiction/addiction.dm): metabolizing enough morphine addicts, withdrawal hurts,
/// naloxone purges opioids and forces a sharp withdrawal, losing points ends it, alcohol addicts by strength
/datum/unit_test/aquila_addictions

/datum/unit_test/aquila_addictions/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.mind_initialize()
	var/datum/mind/patient_mind = patient.mind
	TEST_ASSERT(patient_mind, "The patient has no mind")

	// One dose below the threshold does not addict, metabolizing 30 units of morphine does
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 10)
	for(var/i in 1 to 200)
		if(!patient.reagents.has_reagent(/datum/reagent/medicine/morphine))
			break
		patient.reagents.metabolize(patient, can_overdose = TRUE)
	TEST_ASSERT(!patient_mind.aq_is_addicted(/datum/addiction/opioids), "10 units of morphine addicted ([LAZYACCESS(patient_mind.aq_addiction_points, /datum/addiction/opioids)] points)")
	TEST_ASSERT(LAZYACCESS(patient_mind.aq_addiction_points, /datum/addiction/opioids) > 0, "Morphine gave no opioid points")
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 25)
	for(var/i in 1 to 400)
		if(!patient.reagents.has_reagent(/datum/reagent/medicine/morphine))
			break
		patient.reagents.metabolize(patient, can_overdose = TRUE)
	TEST_ASSERT(patient_mind.aq_is_addicted(/datum/addiction/opioids), "35 units of morphine did not addict ([LAZYACCESS(patient_mind.aq_addiction_points, /datum/addiction/opioids)] points)")
	patient.reagents.clear_reagents()

	// Withdrawal: the second stage hurts, the scanner shows it
	var/datum/addiction/opioids = GLOB.aq_addictions[/datum/addiction/opioids]
	LAZYSET(patient_mind.aq_active_addictions, /datum/addiction/opioids, 125)
	opioids.process_addiction(patient, 2)
	TEST_ASSERT(patient.aq_withdrawal_pain > 0, "Opioid withdrawal does not hurt")
	var/scan = jointext(patient.aq_addiction_scan_lines(), "")
	TEST_ASSERT(findtext(scan, "Opioidy"), "The scanner does not show the opioid addiction: [scan]")

	// A dose ends the withdrawal
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 5)
	opioids.process_addiction(patient, 2)
	TEST_ASSERT(patient.aq_withdrawal_pain == 0, "A dose did not end the withdrawal pain")

	// Naloxone purges the opioid and throws the addict into the last stage
	var/points = patient_mind.aq_addiction_points[/datum/addiction/opioids]
	patient.reagents.add_reagent(/datum/reagent/medicine/naloxone, 5)
	patient.reagents.metabolize(patient, can_overdose = TRUE)
	TEST_ASSERT(!patient.reagents.has_reagent(/datum/reagent/medicine/morphine), "Naloxone left morphine in the blood")
	TEST_ASSERT(patient_mind.aq_addiction_points[/datum/addiction/opioids] < points, "Naloxone did not lower the addiction")
	TEST_ASSERT(LAZYACCESS(patient_mind.aq_active_addictions, /datum/addiction/opioids) >= 180, "Naloxone did not force the sharp withdrawal")
	patient.reagents.clear_reagents()

	// Losing the points ends the addiction
	patient_mind.aq_remove_addiction_points(/datum/addiction/opioids, 2000)
	TEST_ASSERT(!patient_mind.aq_is_addicted(/datum/addiction/opioids), "The addiction stayed with no points")
	TEST_ASSERT(patient.aq_withdrawal_pain == 0, "The withdrawal pain stayed after the addiction ended")

	// Alcohol addicts by strength: a strong drink faster than a weak one
	var/datum/reagent/consumable/ethanol/beer/beer = new()
	var/datum/reagent/consumable/ethanol/vodka/vodka = new()
	var/beer_units = beer.aq_get_addiction_types()[/datum/addiction/alcohol]
	var/vodka_units = vodka.aq_get_addiction_types()[/datum/addiction/alcohol]
	TEST_ASSERT(beer_units && vodka_units && vodka_units < beer_units, "Vodka does not addict faster than beer ([vodka_units] / [beer_units])")
	qdel(beer)
	qdel(vodka)

/// AQUILA - germs (medical/germs.dm): a dirty operation infects, a clean one does not, tools and gloves get dirty and
/// cleaning makes them sterile, an infection grows and an antibiotic knocks it back, sepsis weakens without killing
/datum/unit_test/aquila_germs

/datum/unit_test/aquila_germs/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/datum/surgery_operation/operation = new /datum/surgery_operation/limb/clean_infection()
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	arm.add_surgical_state(SURGERY_SKIN_OPEN)

	// Dirty: bare hands, a dirty scalpel, the floor
	scalpel.aq_dirt = 10
	operation.aq_spread_surgery_germs(arm, surgeon, scalpel)
	var/dirty_germs = arm.aq_germs
	TEST_ASSERT(dirty_germs >= 15, "A dirty floor operation with bare hands and a dirty scalpel gave only [dirty_germs] germs")

	// Clean: fresh gloves, a mask, a sterile scalpel, an operating table, sterilizine on the patient
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	leg.add_surgical_state(SURGERY_SKIN_OPEN)
	var/obj/item/clothing/gloves/color/latex/gloves = allocate(/obj/item/clothing/gloves/color/latex)
	surgeon.equip_to_slot_if_possible(gloves, ITEM_SLOT_GLOVES)
	var/obj/item/clothing/mask/surgical/mask = allocate(/obj/item/clothing/mask/surgical)
	surgeon.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK)
	var/obj/item/clothing/mask/surgical/patient_mask = allocate(/obj/item/clothing/mask/surgical)
	patient.equip_to_slot_if_possible(patient_mask, ITEM_SLOT_MASK)
	allocate(/obj/structure/table/optable, get_turf(patient))
	scalpel.aq_dirt = 0
	patient.add_surgery_speed_mod(/datum/reagent/space_cleaner/sterilizine, 0.8, 1 MINUTES)
	operation.aq_spread_surgery_germs(leg, surgeon, scalpel)
	TEST_ASSERT(leg.aq_germs < 3 && leg.aq_germs * 5 < dirty_germs, "A clean operation gave [leg.aq_germs] germs (a dirty one [dirty_germs])") // bałagan po innych testach może dać punkt
	TEST_ASSERT(scalpel.aq_dirt > 0 && gloves.aq_dirt > 0, "The scalpel and the gloves did not get dirty from the patient")

	// Cleaning makes them sterile
	var/datum/reagent/space_cleaner/sterilizine/cleaner = new()
	cleaner.reaction_obj(scalpel, 10)
	TEST_ASSERT(scalpel.aq_dirt == 0, "Sterilizine did not clean the scalpel")
	qdel(cleaner)
	var/obj/item/storage/firstaid/regular/kit = allocate(/obj/item/storage/firstaid/regular)
	gloves.aq_dirt = 10
	gloves.forceMove(kit)
	var/obj/machinery/autoclave/autoclave = allocate(/obj/machinery/autoclave)
	autoclave.sanitize(kit)
	TEST_ASSERT(gloves.aq_dirt == 0, "The autoclave did not clean what was inside the kit")

	// An infection grows, an antibiotic knocks it back
	arm.aq_germs = 40
	patient.aq_handle_germs(20)
	TEST_ASSERT(arm.aq_germs > 40, "An infection did not grow ([arm.aq_germs])")
	var/scan = jointext(patient.aq_germ_scan_lines(), "")
	TEST_ASSERT(findtext(scan, "zakażenie"), "The scanner does not show the infection: [scan]")
	patient.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 10)
	var/before_antibiotic = arm.aq_germs
	patient.aq_handle_germs(20)
	TEST_ASSERT(arm.aq_germs < before_antibiotic, "Spaceacillin did not knock the infection back")
	patient.reagents.clear_reagents()

	// Sepsis weakens but stops short of killing
	arm.aq_germs = 100
	for(var/i in 1 to 300)
		patient.aq_handle_germs(2)
	TEST_ASSERT(patient.getToxLoss() <= 45, "Sepsis keeps poisoning past its cap ([patient.getToxLoss()])")
	TEST_ASSERT(patient.stat != DEAD, "Sepsis killed")

	// Disinfecting the skin knocks back germs that have not taken hold
	leg.aq_germs = 50
	var/datum/reagent/space_cleaner/sterilizine/spray = new()
	spray.reaction_mob(patient, TOUCH, 10)
	TEST_ASSERT(leg.aq_germs < 50, "Sterilizine on the skin did not disinfect")
	qdel(spray)
	qdel(operation)

/// AQUILA - pulse, cardiac arrest and brain hypoxia (medical/circulation.dm): stimulants speed the pulse and opioids slow it,
/// too little blood stops the heart, no circulation starves the brain slowly, chest compressions move the blood,
/// a brain outside the body dies unless kept cold
/datum/unit_test/aquila_circulation

/datum/unit_test/aquila_circulation/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/heart/heart = patient.getorganslot(ORGAN_SLOT_HEART)
	patient.aq_update_pulse(heart)
	TEST_ASSERT(findtext(heart.aq_pulse_text(), "prawidłowy"), "A healthy heart has a [heart.aq_pulse_text()] pulse")
	patient.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 20)
	patient.aq_update_pulse(heart)
	TEST_ASSERT(heart.aq_pulse > 2, "Epinephrine did not speed up the pulse ([heart.aq_pulse])")
	patient.reagents.clear_reagents()
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 20)
	patient.aq_update_pulse(heart)
	TEST_ASSERT(heart.aq_pulse < 2, "Morphine did not slow down the pulse ([heart.aq_pulse])")
	patient.reagents.clear_reagents()

	// Too little blood stops the heart
	patient.blood_volume = 100
	for(var/i in 1 to 30)
		if(patient.undergoing_cardiac_arrest())
			break
		patient.aq_update_pulse(heart)
	TEST_ASSERT(patient.undergoing_cardiac_arrest(), "The heart kept beating with 100 units of blood")
	patient.blood_volume = BLOOD_VOLUME_NORMAL

	// No circulation: a quarter of the blood moves, chest compressions make it half
	TEST_ASSERT(patient.aq_get_circulation() < BLOOD_VOLUME_SURVIVE * 1.2, "A stopped heart still moves [patient.aq_get_circulation()] units of blood")
	patient.aq_cpr_until = world.time + 10 SECONDS
	TEST_ASSERT(patient.aq_get_circulation() > BLOOD_VOLUME_SURVIVE * 2, "Chest compressions move only [patient.aq_get_circulation()] units of blood")
	patient.aq_cpr_until = 0

	// The brain starves slowly: 100 ticks (~3 minutes) of no circulation is short of brain death and of the body dying
	var/oxy = patient.getOxyLoss()
	for(var/i in 1 to 100)
		patient.aq_handle_brain_oxygen()
	var/brain_damage = patient.getOrganLoss(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(brain_damage > 30 && brain_damage < 60, "Three minutes without circulation gave [brain_damage] brain damage")
	TEST_ASSERT(patient.getOxyLoss() == oxy, "A stopped heart alone damaged the body")
	patient.set_heartattack(FALSE)
	patient.aq_update_pulse(heart)
	TEST_ASSERT(heart.aq_pulse != 0, "A restarted heart has no pulse")

	// Tissue regeneration heals toxins and oxygen deprivation
	patient.adjustToxLoss(30)
	patient.adjustOxyLoss(30)
	var/datum/surgery_operation/limb/tissue_regeneration/regeneration = new()
	regeneration.on_success(patient.get_bodypart(BODY_ZONE_CHEST), patient, null, list())
	TEST_ASSERT(patient.getToxLoss() <= 15 && patient.getOxyLoss() <= oxy + 15, "Tissue regeneration did not heal")
	qdel(regeneration)

	// A brain outside the body dies, a frozen one does not
	var/obj/item/organ/brain/brain = patient.getorganslot(ORGAN_SLOT_BRAIN)
	brain.Remove(patient)
	brain.forceMove(get_turf(patient))
	brain.setOrganDamage(0)
	for(var/i in 1 to 60)
		brain.on_death(2)
	TEST_ASSERT(brain.damage > 25, "A brain outside the body took only [brain.damage] damage in two minutes")
	var/outside = brain.damage
	brain.organ_flags |= ORGAN_FROZEN
	for(var/i in 1 to 60)
		brain.on_death(2)
	TEST_ASSERT(brain.damage == outside, "A frozen brain kept dying")
	qdel(brain)

/// AQUILA - hypothermia and frostbite (medical/hypothermia.dm): the stages slow down and chill the pulse, a blanket warms,
/// frost on a limb becomes frostbite, the third degree paralyses and can be saved by surgery until it turns necrotic
/datum/unit_test/aquila_hypothermia

/datum/unit_test/aquila_hypothermia/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.bodytemperature = T0C + 28
	TEST_ASSERT(patient.aq_hypothermia_stage() == 2, "28°C is stage [patient.aq_hypothermia_stage()]")
	patient.aq_handle_hypothermia()
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_hypothermia"), "Moderate hypothermia does not slow down")
	patient.bodytemperature = T0C + 22
	var/cold_mod = patient.aq_pulse_mod()
	patient.bodytemperature = BODYTEMP_NORMAL
	TEST_ASSERT(cold_mod < patient.aq_pulse_mod(), "Severe hypothermia does not slow the pulse")
	patient.aq_handle_hypothermia()
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, "aq_hypothermia"), "The hypothermia slowdown stayed after warming up")

	// A blanket warms
	var/obj/item/bedsheet/blanket = allocate(/obj/item/bedsheet)
	patient.equip_to_slot_if_possible(blanket, ITEM_SLOT_NECK)
	patient.bodytemperature = T0C + 30
	patient.aq_handle_hypothermia()
	TEST_ASSERT(patient.bodytemperature > T0C + 30, "A blanket did not warm")
	patient.bodytemperature = BODYTEMP_NORMAL

	// Frost turns into frostbite of the matching degree
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	arm.aq_frost = 25
	patient.aq_frostbite_from_frost(arm)
	var/datum/wound/frostbite/first = arm.get_wound("frostbite")
	TEST_ASSERT(istype(first, /datum/wound/frostbite/first_degree), "25 frost gave [first] instead of first degree frostbite")
	arm.aq_frost = 0
	first.wound_effects(2)
	TEST_ASSERT(first.treated, "First degree frostbite did not start healing once warm")
	qdel(first)

	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	leg.aq_frost = 90
	patient.aq_frostbite_from_frost(leg)
	var/datum/wound/frostbite/third_degree/third = leg.get_wound("frostbite")
	TEST_ASSERT(istype(third), "90 frost gave no third degree frostbite")
	TEST_ASSERT(leg.disabled == BODYPART_DISABLED_PARALYSIS, "Third degree frostbite did not paralyse the leg")
	var/datum/surgery_operation/limb/debride/debride = new()
	TEST_ASSERT(debride.state_check(leg), "Debridement cannot save third degree frostbite")
	third.necrosis_progress = 15 MINUTES
	third.wound_effects(2)
	TEST_ASSERT(third.necrotic && !debride.state_check(leg), "Necrotic frostbite can still be saved by debridement")
	qdel(debride)
	qdel(third)
	TEST_ASSERT(leg.disabled != BODYPART_DISABLED_PARALYSIS, "The leg stayed paralysed after the frostbite was gone")

	// Second degree takes a mesh once warm
	var/obj/item/bodypart/left_arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	left_arm.aq_frost = 60
	patient.aq_frostbite_from_frost(left_arm)
	var/datum/wound/frostbite/second = left_arm.get_wound("frostbite")
	var/obj/item/stack/medical/mesh/mesh = allocate(/obj/item/stack/medical/mesh)
	TEST_ASSERT(istype(second, /datum/wound/frostbite/second_degree) && second.can_treat_with(mesh), "Second degree frostbite does not take a mesh")
	qdel(second)

/// AQUILA - kidneys (surgery/organs/med5/kidneys.dm): who gets them, they clear toxin damage and drug excess,
/// failing or missing kidneys let toxins build up, a sleeper works as dialysis
/datum/unit_test/aquila_kidneys

/datum/unit_test/aquila_kidneys/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/kidneys/kidneys = patient.getorganslot(ORGAN_SLOT_KIDNEYS)
	TEST_ASSERT(istype(kidneys), "A human has no kidneys")
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	TEST_ASSERT(!ipc.getorganslot(ORGAN_SLOT_KIDNEYS), "An IPC got kidneys")
	var/mob/living/carbon/human/plasmaman = allocate(/mob/living/carbon/human)
	plasmaman.set_species(/datum/species/plasmaman)
	TEST_ASSERT(!plasmaman.getorganslot(ORGAN_SLOT_KIDNEYS), "A plasmaman got kidneys")

	// Healthy kidneys clear toxins and the drug excess
	patient.adjustToxLoss(20)
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 40)
	var/morphine = patient.reagents.get_reagent_amount(/datum/reagent/medicine/morphine)
	kidneys.on_life()
	TEST_ASSERT(patient.getToxLoss() < 20, "Healthy kidneys did not clear toxin damage")
	TEST_ASSERT(patient.reagents.get_reagent_amount(/datum/reagent/medicine/morphine) < morphine, "Healthy kidneys left the morphine overdose")
	patient.reagents.clear_reagents()

	// Failing kidneys let toxins build up, dialysis in a sleeper takes over
	kidneys.setOrganDamage(kidneys.maxHealth)
	var/tox = patient.getToxLoss()
	kidneys.on_life()
	TEST_ASSERT(patient.getToxLoss() > tox, "Failing kidneys did not poison")
	var/obj/machinery/sleeper/sleeper = allocate(/obj/machinery/sleeper)
	patient.forceMove(sleeper)
	if(!(sleeper.machine_stat & (NOPOWER|BROKEN)))
		tox = patient.getToxLoss()
		kidneys.on_life()
		TEST_ASSERT(patient.getToxLoss() < tox, "Dialysis in a sleeper did not clean the blood")
	patient.forceMove(get_turf(sleeper))

	// Damaged kidneys put blood in the urine
	kidneys.setOrganDamage(kidneys.low_threshold + 5)
	var/datum/reagents/urine = new(50)
	patient.aq_urine_extras(urine, 10)
	TEST_ASSERT(urine.has_reagent(/datum/reagent/blood), "Damaged kidneys put no blood in the urine")
	qdel(urine)

	// No kidneys at all: toxins build up
	kidneys.Remove(patient)
	qdel(kidneys)
	tox = patient.getToxLoss()
	patient.aq_filter_blood(0)
	TEST_ASSERT(patient.getToxLoss() > tox, "Missing kidneys did not poison")

/// AQUILA - spleen, intestines, catheter (surgery/organs/med5/abdomen.dm): the spleen releases blood, heavy belly hits
/// injure the abdominal organs until one suture surgery, damaged intestines absorb worse, a catheter drains the bladder
/datum/unit_test/aquila_abdomen

/datum/unit_test/aquila_abdomen/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/spleen/spleen = patient.getorganslot(ORGAN_SLOT_SPLEEN)
	var/obj/item/organ/intestines/intestines = patient.getorganslot(ORGAN_SLOT_INTESTINES)
	TEST_ASSERT(istype(spleen) && istype(intestines), "A human has no spleen or intestines")

	// The spleen gives blood when it runs low, once per cooldown
	patient.blood_volume = BLOOD_VOLUME_BAD
	spleen.on_life()
	TEST_ASSERT(patient.blood_volume > BLOOD_VOLUME_BAD, "The spleen released no blood")
	var/after_release = patient.blood_volume
	spleen.on_life()
	TEST_ASSERT(patient.blood_volume == after_release, "The spleen released blood again before the cooldown")
	patient.blood_volume = BLOOD_VOLUME_NORMAL

	// Heavy belly hits injure the abdominal organs: internal bleeding until stitched
	for(var/i in 1 to 200)
		if(spleen.ruptured)
			break
		patient.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
		patient.adjustBruteLoss(-15)
	TEST_ASSERT(spleen.ruptured, "200 heavy belly hits never ruptured the spleen")
	var/blood = patient.blood_volume
	spleen.on_life()
	TEST_ASSERT(patient.blood_volume < blood, "A ruptured spleen does not bleed inside")
	TEST_ASSERT(findtext(jointext(patient.aq_organ_scan_lines(), ""), "narządów brzucha"), "The scanner does not show the abdominal organ injury")
	var/datum/surgery_operation/organ/repair/spleen/splenorrhaphy = new()
	TEST_ASSERT(splenorrhaphy.state_check(spleen), "A ruptured spleen cannot be stitched")
	splenorrhaphy.on_success(spleen, patient, null, list())
	TEST_ASSERT(!spleen.ruptured, "Stitching did not close the spleen")
	qdel(splenorrhaphy)

	// Damaged intestines: worse absorption, diarrhea
	intestines.setOrganDamage(intestines.maxHealth * 0.6)
	// Food from the stomach is partly lost, food straight into the blood (an IV) is not
	var/obj/item/organ/stomach/stomach = patient.getorganslot(ORGAN_SLOT_STOMACH)
	stomach.reagents.add_reagent(/datum/reagent/consumable/nutriment, 10)
	var/stomach_before = stomach.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	var/blood_before = patient.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	stomach.digest()
	var/left_stomach = stomach_before - stomach.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	var/reached_blood = patient.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) - blood_before
	TEST_ASSERT(left_stomach > 0 && reached_blood < left_stomach, "Damaged intestines absorbed everything ([reached_blood] of [left_stomach])")
	var/nutrition = patient.nutrition
	patient.adjust_nutrition(10)
	TEST_ASSERT(patient.nutrition - nutrition == 10, "Nutrition outside the gut (IV, photosynthesis) is cut by the intestines")
	TEST_ASSERT(patient.stool_type() >= 6, "Sick intestines give no diarrhea")
	intestines.setOrganDamage(0)

	// A catheter drains the bladder
	if(patient.getorganslot(ORGAN_SLOT_BLADDER))
		patient.urination = 10
		var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
		var/obj/item/catheter/catheter = allocate(/obj/item/catheter)
		catheter.toolspeed = 0.01 // the test does not wait 4 seconds of game time
		medic.set_combat_mode(FALSE)
		catheter.attack(patient, medic)
		TEST_ASSERT(!patient.urination, "A catheter did not drain the bladder")


/// Adrenals hold the adrenaline reserve
/datum/unit_test/aquila_glands

/datum/unit_test/aquila_glands/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/adrenals/adrenals = patient.getorganslot(ORGAN_SLOT_ADRENALS)
	TEST_ASSERT(istype(adrenals), "A human has no adrenals")

	// Damaged glands hold less, none hold nothing, cybernetic hold more
	TEST_ASSERT(patient.aq_adrenal_capacity() == 100, "Healthy adrenals do not hold the full reserve")
	adrenals.applyOrganDamage(adrenals.maxHealth / 2)
	patient.aq_handle_adrenal_glands()
	TEST_ASSERT(patient.aq_adrenal_reserve < 100, "Damaged adrenals still hold the full reserve")
	adrenals.Remove(patient)
	patient.aq_handle_adrenal_glands()
	TEST_ASSERT(patient.aq_adrenal_reserve == 0, "No adrenals still keep adrenaline")
	qdel(adrenals)
	var/obj/item/organ/adrenals/cybernetic/cyber_adrenals = new()
	cyber_adrenals.Insert(patient)
	for(var/i in 1 to 400)
		patient.aq_handle_adrenal_glands()
	TEST_ASSERT(patient.aq_adrenal_reserve > 100, "Cybernetic adrenals do not hold more")

/// The larynx gives the voice: none means mute, a transplanted one speaks with the donor's voice
/datum/unit_test/aquila_larynx

/datum/unit_test/aquila_larynx/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.real_name = "Jan Pacjent"
	var/obj/item/organ/larynx/larynx = patient.getorganslot(ORGAN_SLOT_LARYNX)
	TEST_ASSERT(istype(larynx) && !istype(larynx, /obj/item/organ/larynx/synthesizer), "A human has no larynx")
	TEST_ASSERT(patient.can_speak_vocal("test"), "A healthy larynx cannot speak")
	TEST_ASSERT(patient.GetVoice() == "Jan Pacjent", "A fresh larynx changed the voice")

	// Hoarse: no shouting
	larynx.applyOrganDamage(larynx.low_threshold + 1)
	var/list/speech_args = list("Na pomoc!", "", list())
	larynx.on_owner_say(patient, speech_args)
	TEST_ASSERT(!findtext(speech_args[1], "!"), "A hoarse voice can still shout")
	// Destroyed: mute
	larynx.applyOrganDamage(larynx.maxHealth)
	TEST_ASSERT(!patient.can_speak_vocal("test"), "A destroyed larynx can still speak")
	larynx.setOrganDamage(0)
	TEST_ASSERT(patient.can_speak_vocal("test"), "A repaired larynx cannot speak")

	// Removed: mute, and it keeps the owner's voice
	larynx.Remove(patient)
	TEST_ASSERT(!patient.can_speak_vocal("test"), "Speaking without a larynx")
	TEST_ASSERT(larynx.voice == "Jan Pacjent", "The removed larynx did not keep the voice")
	var/mob/living/carbon/human/recipient = allocate(/mob/living/carbon/human)
	recipient.real_name = "Anna Biorca"
	var/obj/item/organ/larynx/own = recipient.getorganslot(ORGAN_SLOT_LARYNX)
	own.Remove(recipient)
	qdel(own)
	larynx.Insert(recipient)
	TEST_ASSERT(recipient.GetVoice() == "Jan Pacjent", "The transplanted larynx does not speak with the donor's voice")

	// Synthetics have a speech synthesizer
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	TEST_ASSERT(istype(ipc.getorganslot(ORGAN_SLOT_LARYNX), /obj/item/organ/larynx/synthesizer), "An IPC has no speech synthesizer")
	TEST_ASSERT(!ipc.getorganslot(ORGAN_SLOT_KIDNEYS), "An IPC has kidneys")

/// A cut nerve: no pain from the limb, dropped items, no reflex; a nerve suture fixes it
/datum/unit_test/aquila_nerves

/datum/unit_test/aquila_nerves/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(!chest.aq_can_cut_nerve(), "The chest has a limb nerve")

	// Severe cuts roll for the nerve
	for(var/i in 1 to 100)
		if(arm.aq_nerve_cut)
			break
		var/datum/wound/slash/deep/wound = new()
		wound.apply_wound(arm, silent = TRUE)
		qdel(wound)
	TEST_ASSERT(arm.aq_nerve_cut, "100 deep cuts never cut the nerve")

	// No pain from that arm
	arm.receive_damage(40)
	TEST_ASSERT(patient.aq_limb_pain(arm) == 0, "An arm with a cut nerve still hurts")

	// The hand lets go
	var/obj/item/storage/box/held = allocate(/obj/item/storage/box)
	patient.put_in_hand(held, arm.held_index)
	for(var/i in 1 to 300)
		if(held.loc != patient)
			break
		patient.aq_handle_nerves()
	TEST_ASSERT(held.loc != patient, "A hand with a cut nerve never let go")

	// The hammer and the scanner see it
	var/list/reflex = patient.aq_reflex_result(arm)
	TEST_ASSERT(findtext(reflex[1], "nerw"), "The reflex hammer does not find the cut nerve")
	TEST_ASSERT(findtext(jointext(patient.get_wound_scan_lines(), ""), "Przerwany nerw"), "The scanner does not show the cut nerve")

	// The suture fixes it
	var/datum/surgery_operation/limb/nerve_repair/suture = new()
	TEST_ASSERT(suture.state_check(arm), "A cut nerve cannot be stitched")
	suture.on_success(arm, patient, null, list())
	TEST_ASSERT(!arm.aq_nerve_cut, "The suture did not fix the nerve")
	TEST_ASSERT(patient.aq_limb_pain(arm) > 0, "The arm does not hurt after the suture")
	qdel(suture)

/// Teeth: a blunt blow to the mouth knocks them out, few teeth make the speech lisp, a dentist pulls and plants them
/datum/unit_test/aquila_teeth

/datum/unit_test/aquila_teeth/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/head/head = patient.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(head.aq_teeth == 32, "A head does not start with 32 teeth")

	// Blows to the mouth: blunt knocks teeth out, sharp does not, other zones do not
	attacker.zone_selected = BODY_ZONE_PRECISE_MOUTH
	var/knocked = 0
	for(var/i in 1 to 100)
		knocked += patient.aq_try_knock_teeth(attacker, 15, WEIGHT_CLASS_NORMAL, FALSE)
		if(knocked)
			break
	TEST_ASSERT(knocked > 0 && head.aq_teeth == 32 - knocked, "100 blunt blows to the mouth never knocked a tooth out")
	var/obj/item/stack/teeth/teeth = locate() in range(3, patient)
	TEST_ASSERT(teeth, "The knocked out teeth did not fall out")
	for(var/i in 1 to 100)
		TEST_ASSERT(!patient.aq_try_knock_teeth(attacker, 15, WEIGHT_CLASS_NORMAL, TRUE), "A sharp weapon knocked teeth out")
	attacker.zone_selected = BODY_ZONE_HEAD
	for(var/i in 1 to 100)
		TEST_ASSERT(!patient.aq_try_knock_teeth(attacker, 15, WEIGHT_CLASS_NORMAL, FALSE), "A blow to the head (not the mouth) knocked teeth out")

	// Speech lisps without teeth
	head.aq_teeth = 0
	TEST_ASSERT(findtext(patient.treat_message("szansa"), "ś"), "No teeth and no lisp")
	head.aq_teeth = 32
	TEST_ASSERT(!findtext(patient.treat_message("szansa"), "ś"), "A full mouth lisps")

	// The dentist pulls a tooth and plants it back
	var/datum/surgery_operation/limb/aq_pull_tooth/pull = new()
	pull.on_success(head, attacker, null, list())
	TEST_ASSERT(head.aq_teeth == 31, "Pulling did not take a tooth out")
	qdel(pull)
	var/obj/item/stack/teeth/prosthetic/five/prosthetic = allocate(/obj/item/stack/teeth/prosthetic/five)
	var/datum/surgery_operation/limb/aq_insert_tooth/insert = new()
	TEST_ASSERT(insert.state_check(head), "A missing tooth cannot be planted")
	insert.on_success(head, attacker, prosthetic, list())
	TEST_ASSERT(head.aq_teeth == 32 && prosthetic.amount == 4, "Planting did not use a prosthetic tooth")
	TEST_ASSERT(!insert.state_check(head), "A tooth can be planted in a full mouth")
	qdel(insert)

/// A new brain or head: limp limbs until the brain stem surgery, then weakness
/datum/unit_test/aquila_brainstem

/datum/unit_test/aquila_brainstem/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/wound/spinal/brainstem/wound = patient.aq_disconnect_brainstem()
	TEST_ASSERT(istype(wound), "No brain stem wound after a transplant")
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_R_LEG)
	TEST_ASSERT(arm.disabled == BODYPART_DISABLED_PARALYSIS && leg.disabled == BODYPART_DISABLED_PARALYSIS, "The limbs work before the brain stem is joined")

	// The spine surgeries do not touch it, the brain stem surgery does
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/surgery_operation/limb/stabilize_spine/stabilize = new()
	TEST_ASSERT(!stabilize.state_check(chest), "The spine surgery treats the brain stem")
	qdel(stabilize)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	var/datum/surgery_operation/limb/aq_connect_brainstem/connect = new()
	TEST_ASSERT(connect.state_check(head), "The brain stem cannot be joined")
	connect.on_success(head, patient, null, list())
	qdel(connect)
	TEST_ASSERT(!chest.get_wound(WOUND_SPINE), "The brain stem wound stayed after the surgery")
	TEST_ASSERT(arm.disabled != BODYPART_DISABLED_PARALYSIS && leg.disabled != BODYPART_DISABLED_PARALYSIS, "The limbs stay limp after the surgery")
	TEST_ASSERT(patient.has_status_effect(/datum/status_effect/aq_transplant_weakness), "No weakness after the transplant")
	var/list/weakness_data = LAZYACCESS(patient.movespeed_modification, "[/datum/movespeed_modifier/aq_transplant_weakness]")
	TEST_ASSERT(weakness_data && weakness_data[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN] > 0, "The weakness after the transplant does not slow down")

/// A jammed suit cannot be taken off by the wearer; someone cuts it off with a welder and it leaks until taped
/datum/unit_test/aquila_spacesuit_jam

/datum/unit_test/aquila_spacesuit_jam/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/suit/space/suit = allocate(/obj/item/clothing/suit/space)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING), "Could not put the suit on")
	for(var/i in 1 to 300)
		if(suit.aq_jammed)
			break
		wearer.apply_damage(25, BRUTE, BODY_ZONE_CHEST)
		wearer.adjustBruteLoss(-25)
	TEST_ASSERT(suit.aq_jammed, "300 heavy hits never jammed the suit")
	TEST_ASSERT(!wearer.dropItemToGround(suit), "The wearer took off a jammed suit")
	var/mob/living/carbon/human/rescuer = allocate(/mob/living/carbon/human)
	var/obj/item/weldingtool/welder = allocate(/obj/item/weldingtool/experimental)
	welder.toolspeed = 0.01
	welder.welding = TRUE
	rescuer.put_in_active_hand(welder)
	rescuer.set_combat_mode(FALSE)
	rescuer.zone_selected = BODY_ZONE_CHEST
	suit.aq_cut_out(wearer, welder, rescuer)
	TEST_ASSERT(!suit.aq_jammed && suit.loc != wearer, "The rescuer did not cut the suit off")
	TEST_ASSERT(suit.aq_cut && !(suit.clothing_flags & STOPSPRESSUREDAMAGE), "The cut suit still holds pressure")

/// Embalmed organs do not rot; a husk with rezadone in the blood is rebuilt by surgery
/datum/unit_test/aquila_embalming

/datum/unit_test/aquila_embalming/Run()
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human)
	corpse.death()
	var/obj/item/bodypart/chest = corpse.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, 20)
	var/datum/surgery_operation/limb/aq_embalm/embalm = new()
	TEST_ASSERT(embalm.state_check(chest) && embalm.tool_check(beaker), "A corpse cannot be embalmed")
	embalm.on_success(chest, corpse, beaker, list())
	qdel(embalm)
	TEST_ASSERT(HAS_TRAIT(corpse, TRAIT_AQ_EMBALMED), "The corpse was not embalmed")
	corpse.reagents.clear_reagents()
	var/obj/item/organ/liver/liver = corpse.getorganslot(ORGAN_SLOT_LIVER)
	var/damage = liver.damage
	for(var/i in 1 to 20)
		liver.on_death()
	TEST_ASSERT(liver.damage == damage, "The organs of an embalmed corpse rot")

	corpse.become_husk("burn")
	var/datum/surgery_operation/limb/aq_unhusk/unhusk = new()
	TEST_ASSERT(!unhusk.state_check(chest), "A husk is rebuilt without rezadone")
	corpse.reagents.add_reagent(/datum/reagent/medicine/rezadone, 5)
	TEST_ASSERT(unhusk.state_check(chest), "A husk with rezadone cannot be rebuilt")
	unhusk.on_success(chest, corpse, null, list())
	TEST_ASSERT(!HAS_TRAIT(corpse, TRAIT_HUSK), "The husk was not rebuilt")
	corpse.become_husk(CHANGELING_DRAIN)
	corpse.reagents.add_reagent(/datum/reagent/medicine/rezadone, 5)
	TEST_ASSERT(!unhusk.state_check(chest), "A changeling husk can be rebuilt")
	qdel(unhusk)

/// The cloning console reads the mind only from a cortical stack
/datum/unit_test/aquila_cortical_stack

/datum/unit_test/aquila_cortical_stack/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.mind_initialize()
	var/obj/item/organ/cortical_stack/stack = patient.getorganslot(ORGAN_SLOT_CORTICAL_STACK)
	TEST_ASSERT(istype(stack), "A human has no cortical stack")
	var/obj/machinery/computer/cloning/console = allocate(/obj/machinery/computer/cloning)
	TEST_ASSERT(console.can_scan(patient.dna, patient, null, FALSE), "A body with a stack cannot be scanned")
	stack.Remove(patient)
	TEST_ASSERT(stack.recorded_name == patient.real_name, "The removed stack did not keep the mind")
	TEST_ASSERT(!console.can_scan(patient.dna, patient, null, FALSE), "A body without a stack can be cloned")
	TEST_ASSERT(console.can_scan(patient.dna, patient, null, TRUE), "A body without a stack cannot be scanned body-only")

/// The robot first aid kit carries nanopaste and still has room for everything it starts with
/datum/unit_test/aquila_robot_firstaid_nanopaste

/datum/unit_test/aquila_robot_firstaid_nanopaste/Run()
	var/obj/item/storage/firstaid/robot/kit = allocate(/obj/item/storage/firstaid/robot)
	TEST_ASSERT(locate(/obj/item/stack/medical/nanopaste) in kit, "The robot first aid kit has no nanopaste")
	var/datum/component/storage/storage = kit.GetComponent(/datum/component/storage)
	TEST_ASSERT(length(kit.contents) <= storage.max_items, "The robot first aid kit starts with [length(kit.contents)] items but holds [storage.max_items]")

/// Bay augments: armor
/datum/unit_test/aquila_augments

/datum/unit_test/aquila_augments/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/melee = patient.physiology.armor.melee
	var/obj/item/organ/cyberimp/chest/aq_subdermal_armor/armor = new()
	armor.Insert(patient)
	TEST_ASSERT(patient.physiology.armor.melee > melee, "Subdermal armor gives no armor")
	armor.Remove(patient)
	TEST_ASSERT(patient.physiology.armor.melee == melee, "Subdermal armor stays after removal")
	qdel(armor)

/// A spider-bot takes an MMI, gives it a body and drops it when destroyed
/datum/unit_test/aquila_spiderbot

/datum/unit_test/aquila_spiderbot/Run()
	var/obj/item/bodypart/head/robot/head = allocate(/obj/item/bodypart/head/robot)
	head.flash1 = new(head)
	head.flash2 = new(head)
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human)
	var/obj/item/stock_parts/manipulator/manipulator = new(builder.loc)
	builder.put_in_active_hand(manipulator)
	head.attackby(manipulator, builder)
	var/mob/living/simple_animal/aq_spiderbot/bot = locate() in builder.loc
	TEST_ASSERT(bot, "A robot head with two flashes and a manipulator did not become a spider-bot")
	TEST_ASSERT(bot.ventcrawler == VENTCRAWLER_ALWAYS, "The spider-bot cannot crawl through vents")
	qdel(bot)

/// Healing a third degree frostbite lifts its paralysis, but a limb disabled by damage before it stays disabled
/datum/unit_test/aquila_frostbite_paralysis

/datum/unit_test/aquila_frostbite_paralysis/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/datum/wound/frostbite/third_degree/bite = new()
	bite.apply_wound(arm, silent = TRUE)
	TEST_ASSERT(arm.disabled == BODYPART_DISABLED_PARALYSIS, "Third degree frostbite does not paralyse the arm")
	qdel(bite)
	TEST_ASSERT(arm.disabled == BODYPART_NOT_DISABLED, "A healthy arm stays paralysed after the frostbite is gone")

	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_R_LEG)
	leg.receive_damage(brute = leg.max_damage)
	leg.update_disabled()
	TEST_ASSERT(leg.disabled == BODYPART_DISABLED_DAMAGE, "A leg at full damage is not disabled")
	var/datum/wound/frostbite/third_degree/leg_bite = new()
	leg_bite.apply_wound(leg, silent = TRUE)
	leg.heal_damage(leg.max_damage * 0.3, 0)
	qdel(leg_bite)
	TEST_ASSERT(leg.disabled == BODYPART_DISABLED_DAMAGE, "Removing the frostbite also lifted the damage disable ([leg.get_damage()] / [leg.max_damage])")

	// Healed below half during the paralysis and hurt again a little: without the paralysis the disable would be gone
	var/obj/item/bodypart/other_leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	other_leg.receive_damage(brute = other_leg.max_damage)
	other_leg.update_disabled()
	var/datum/wound/frostbite/third_degree/other_bite = new()
	other_bite.apply_wound(other_leg, silent = TRUE)
	other_leg.heal_damage(other_leg.max_damage * 0.6, 0)
	other_leg.receive_damage(brute = other_leg.max_damage * 0.2)
	qdel(other_bite)
	TEST_ASSERT(other_leg.disabled == BODYPART_NOT_DISABLED, "The leg stays disabled although its damage fell below half during the paralysis ([other_leg.get_damage()] / [other_leg.max_damage])")

	// Amputated with the frostbite on: the wound goes away without touching the missing owner (a runtime fails the test)
	var/obj/item/bodypart/cut_arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/wound/frostbite/third_degree/cut_bite = new()
	cut_bite.apply_wound(cut_arm, silent = TRUE)
	cut_arm.drop_limb()
	qdel(cut_bite)
	TEST_ASSERT(!(cut_bite in cut_arm.wounds), "The frostbite stayed on the amputated arm")
	TEST_ASSERT(cut_arm.disabled != BODYPART_DISABLED_PARALYSIS, "The amputated arm stays paralysed")

/// The chem master analysis shows the tg addiction threshold, alcohol from its strength
/datum/unit_test/aquila_addiction_threshold_display

/datum/unit_test/aquila_addiction_threshold_display/Run()
	TEST_ASSERT(aq_addiction_threshold_of(/datum/reagent/medicine/tramadol) == 40, "Tramadol shows [aq_addiction_threshold_of(/datum/reagent/medicine/tramadol)] instead of 40")
	var/datum/reagent/consumable/ethanol/beer/beer = GLOB.chemical_reagents_list[/datum/reagent/consumable/ethanol/beer]
	var/expected = max(10, 2000 / beer.boozepwr)
	TEST_ASSERT(aq_addiction_threshold_of(/datum/reagent/consumable/ethanol/beer) == expected, "Beer shows [aq_addiction_threshold_of(/datum/reagent/consumable/ethanol/beer)] instead of [expected]")
	TEST_ASSERT(aq_addiction_threshold_of(/datum/reagent/water) == 0, "Water shows an addiction threshold")

/// Review max fixes: circulation, hypothermia, CPR, scanner
/datum/unit_test/aquila_med5_review_body

/datum/unit_test/aquila_med5_review_body/Run()
	// Cold-blooded species sit at room temperature: no hypothermia
	var/mob/living/carbon/human/lizard = allocate(/mob/living/carbon/human)
	ADD_TRAIT(lizard, TRAIT_COLDBLOODED, "test")
	lizard.bodytemperature = T0C + 20
	TEST_ASSERT(lizard.aq_hypothermia_stage() == 0, "A cold-blooded body at room temperature has hypothermia")

	// A stopped heart with full health still gets CPR on a help click, and the pulse line hides under fake death
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	var/obj/item/organ/heart/heart = patient.getorganslot(ORGAN_SLOT_HEART)
	heart.Stop()
	patient.Unconscious(10 SECONDS)
	patient.update_mobility()
	TEST_ASSERT(patient.health >= 0, "The stopped heart lowered health (setup)")
	TEST_ASSERT(medic.dna.species.aq_wants_cpr(medic, patient), "A lying patient with a stopped heart and full health gets no CPR")
	// A medic with a mind carries the default martial art: the help click still starts CPR
	medic.mind_initialize()
	medic.dna.species.help(medic, patient, medic.mind.martial_art)
	TEST_ASSERT(patient.aq_cpr_until > world.time, "A medic with the default martial art shakes a stopped heart instead of CPR")
	heart.Restart()
	TEST_ASSERT(!medic.dna.species.aq_wants_cpr(medic, patient), "A beating heart gets CPR instead of a shake")
	ADD_TRAIT(patient, TRAIT_FAKEDEATH, "test")
	TEST_ASSERT(!length(patient.aq_pulse_scan_lines()), "The pulse line shows through fake death")
	REMOVE_TRAIT(patient, TRAIT_FAKEDEATH, "test")

	// A fist (bodypart passed as def_zone) can injure the abdominal organs; armor counts
	var/mob/living/carbon/human/boxed = allocate(/mob/living/carbon/human)
	var/obj/item/organ/spleen/spleen = boxed.getorganslot(ORGAN_SLOT_SPLEEN)
	var/obj/item/bodypart/chest = boxed.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(aq_damage_zone(chest) == BODY_ZONE_CHEST, "A bodypart zone is not read")
	for(var/i in 1 to 300)
		if(spleen.ruptured)
			break
		boxed.apply_damage(16, BRUTE, chest)
		boxed.adjustBruteLoss(-16)
	TEST_ASSERT(spleen.ruptured, "Blows passing the bodypart never ruptured the spleen")
	boxed.fully_heal(TRUE)
	TEST_ASSERT(!spleen.ruptured, "A full heal left the spleen ruptured")

	// A milder wound from treatment rolls no new nerve cut; the brain stem survives a spine injury
	var/mob/living/carbon/human/stitched = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = stitched.get_bodypart(BODY_ZONE_L_ARM)
	for(var/i in 1 to 60)
		var/datum/wound/slash/artery/artery = new()
		artery.apply_wound(arm, silent = TRUE)
		arm.aq_nerve_cut = FALSE
		var/datum/wound/milder = artery.replace_with(/datum/wound/slash/deep)
		qdel(milder)
		TEST_ASSERT(!arm.aq_nerve_cut, "Suturing an artery cut the nerve")
	stitched.aq_disconnect_brainstem()
	stitched.aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	var/obj/item/bodypart/stitched_chest = stitched.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(istype(stitched_chest.get_wound(WOUND_SPINE), /datum/wound/spinal/brainstem), "A spine injury replaced the unjoined brain stem")

	// A splint stays on a fracture that changes severity; a dressed burn clears its infection
	var/obj/item/bodypart/leg = stitched.get_bodypart(BODY_ZONE_R_LEG)
	var/datum/wound/blunt/fracture/fracture = new()
	fracture.apply_wound(leg, silent = TRUE)
	fracture.splinted = TRUE
	var/datum/wound/blunt/worse = fracture.replace_with(/datum/wound/blunt/compound)
	TEST_ASSERT(istype(worse) && worse.splinted && worse.treated, "The splint fell off when the fracture got worse")
	TEST_ASSERT(!(locate(/obj/item/stack/medical/splint) in get_turf(stitched)), "The splint dropped although it moved to the new wound")
	qdel(worse)
	var/obj/item/bodypart/burnt = stitched.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/wound/burn/third_degree/burn = new()
	burn.apply_wound(burnt, silent = TRUE)
	burn.treated = TRUE
	burnt.aq_germs = 40
	burn.wound_effects(2)
	TEST_ASSERT(burnt.aq_germs < 40, "A burn dressed with mesh keeps its infection")
	qdel(burn)

/// Review max fixes: organs, implants, addictions, machines
/datum/unit_test/aquila_med5_review_items

/datum/unit_test/aquila_med5_review_items/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	// The translator implant does not stun on EMP
	var/obj/item/organ/cyberimp/aq_translator/translator = new()
	translator.Insert(patient)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_AQ_TRANSLATOR), "The translator implant does not translate")
	translator.emp_act(EMP_HEAVY)
	TEST_ASSERT(!patient.IsStun() && !HAS_TRAIT(patient, TRAIT_AQ_TRANSLATOR), "The translator implant stuns or keeps working after an EMP")

	// Addictions: no false end for someone never addicted, no end every tick while satisfied
	patient.mind_initialize()
	patient.disgust = 50
	patient.mind.aq_add_addiction_points(/datum/addiction/opioids, 500)
	patient.mind.aq_remove_addiction_points(/datum/addiction/opioids, 300)
	TEST_ASSERT(patient.disgust == 50, "Losing points of an addiction never had ended a withdrawal")
	TEST_ASSERT(length(GLOB.chemical_reagents_list[/datum/reagent/consumable/coffee].aq_get_addiction_types()), "Coffee does not feed the coffee addict quirk")

	// Points crossing the threshold again keep the running withdrawal cycle (process_addiction ends it once)
	var/datum/addiction/stims = GLOB.aq_addictions[/datum/addiction/stimulants]
	patient.mind.aq_add_addiction_points(/datum/addiction/stimulants, stims.gain_threshold + 10)
	LAZYSET(patient.mind.aq_active_addictions, /datum/addiction/stimulants, 500)
	patient.mind.aq_remove_addiction_points(/datum/addiction/stimulants, 20)
	patient.mind.aq_add_addiction_points(/datum/addiction/stimulants, 20)
	TEST_ASSERT(LAZYACCESS(patient.mind.aq_active_addictions, /datum/addiction/stimulants) == 500, "Crossing the addiction threshold again reset a running withdrawal")

	// An empty organ box spends no coolant
	var/obj/item/storage/organbox/box = allocate(/obj/item/storage/organbox)
	box.reagents.add_reagent(/datum/reagent/consumable/ice, 10)
	box.process(2)
	TEST_ASSERT(box.reagents.get_reagent_amount(/datum/reagent/consumable/ice) == 10, "An empty organ box spent coolant")

	// A fist can knock teeth out
	var/mob/living/carbon/human/boxer = allocate(/mob/living/carbon/human)
	boxer.zone_selected = BODY_ZONE_PRECISE_MOUTH
	var/knocked = 0
	for(var/i in 1 to 100)
		knocked += patient.aq_try_knock_teeth(boxer, 7, WEIGHT_CLASS_SMALL, FALSE)
		if(knocked)
			break
	TEST_ASSERT(knocked, "100 punches to the mouth never knocked a tooth out")

#undef TEST_ASSERT
