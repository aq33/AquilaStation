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
	qdel(fracture)
	TEST_ASSERT(locate(/obj/item/stack/medical/splint) in floor, "The splint did not fall off after the bone healed")

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

/// AQUILA - asthma (medical/asthma.dm): albuterol takes the inflammation off, narrow airways choke, an attack is cured by albuterol
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

	// A puff of albuterol takes inflammation off at once, then more while in the blood
	var/obj/item/inhaler/albuterol/inhaler = allocate(/obj/item/inhaler/albuterol)
	inhaler.canister.puff(patient, patient)
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/albuterol), "The inhaler gave no albuterol")
	patient.reagents.metabolize(patient, can_overdose = TRUE)
	TEST_ASSERT(asthma.inflammation < 400, "Albuterol did not take inflammation off at once ([asthma.inflammation])")
	var/after_puff = asthma.inflammation
	asthma.last_process = world.time - 2 SECONDS
	asthma.on_process()
	TEST_ASSERT(asthma.inflammation < after_puff, "Albuterol in the blood did not keep taking inflammation off")

	// An attack is cured by albuterol
	patient.reagents.clear_reagents()
	asthma.start_attack()
	var/datum/disease/asthma_attack/attack = asthma.current_attack
	TEST_ASSERT(attack && (attack in patient.diseases), "No asthma attack started")
	patient.reagents.add_reagent(/datum/reagent/medicine/albuterol, 20)
	for(var/i in 1 to 200)
		if(QDELETED(attack))
			break
		attack.stage_act()
	TEST_ASSERT(QDELETED(attack), "Albuterol did not cure the asthma attack in 200 ticks")
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
	burn.infection = 50
	var/obj/item/flashlight/pen/paramedic/uv = locate() in belt
	medic.set_combat_mode(FALSE)
	medic.zone_selected = BODY_ZONE_L_ARM
	uv.attack(patient, medic)
	TEST_ASSERT(burn.infection < 50, "The UV penlight did not touch the infection ([burn.infection])")
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

#undef TEST_ASSERT
