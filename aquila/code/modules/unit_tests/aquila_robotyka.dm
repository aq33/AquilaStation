// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Zamienia kończynę człowieka na nową danego typu (jak w lobby, bez kalibracji)
/proc/aq_test_swap_limb(mob/living/carbon/human/H, limb_type)
	var/obj/item/bodypart/new_limb = new limb_type()
	var/obj/item/bodypart/old_limb = H.get_bodypart(new_limb.body_zone)
	new_limb.replace_limb(H, TRUE)
	if(old_limb && old_limb.owner != H)
		qdel(old_limb)
	return new_limb

/// AQUILA - marki protez: sam wygląd (bez mnożników), realistyczna skóra, oględziny, maszyna do dopasowania
/datum/unit_test/aquila_robolimb_brands

/datum/unit_test/aquila_robolimb_brands/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = aq_test_swap_limb(patient, /obj/item/bodypart/l_arm/robot)
	TEST_ASSERT(arm.aq_set_brand("shellguard"), "A robotic arm did not take a brand")
	TEST_ASSERT("[arm.static_icon]" == "[GLOB.aq_robolimb_brands["shellguard"].limb_icon]", "The brand did not change the sprite")
	var/obj/item/bodypart/plain = aq_test_swap_limb(patient, /obj/item/bodypart/r_arm/robot)
	arm.receive_damage(20)
	plain.receive_damage(20)
	TEST_ASSERT(arm.brute_dam == plain.brute_dam, "A brand changed the damage taken ([arm.brute_dam] vs [plain.brute_dam])")
	TEST_ASSERT(length(patient.aq_prosthetic_examine_lines(viewer)), "A branded prosthesis is not seen on examine")

	var/obj/item/bodypart/leg = aq_test_swap_limb(patient, /obj/item/bodypart/l_leg/robot)
	leg.aq_set_brand("veymed")
	TEST_ASSERT(leg.aq_lifelike_disguised(), "A fresh Vey-Med limb does not look like flesh")
	viewer.forceMove(locate(patient.x + 3, patient.y, patient.z))
	var/list/lines = patient.aq_prosthetic_examine_lines(viewer)
	TEST_ASSERT(!findtext(jointext(lines, ""), "ukryta pod sztuczną skórą"), "A lifelike prosthesis is seen from afar")
	leg.receive_damage(leg.max_damage)
	TEST_ASSERT(!leg.aq_lifelike_disguised(), "A wrecked lifelike prosthesis still hides its metal")

	var/obj/item/bodypart/r_arm/robot/loose = allocate(/obj/item/bodypart/r_arm/robot)
	loose.static_icon = 'nsv13/icons/mob/augmentation/bishop.dmi'
	loose.aq_sync_brand_from_icon()
	TEST_ASSERT(loose.aq_brand?.id == "bishop", "The augment manipulator style did not set the brand")

	var/obj/item/bodypart/l_arm/robot/aq_advanced/advanced = allocate(/obj/item/bodypart/l_arm/robot/aq_advanced)
	TEST_ASSERT(!advanced.aq_set_brand("xion"), "An advanced prosthesis lost its own look to a brand")

	// podwozie IPC ma limb_id podwozia, nie "synth": marka go nie zmienia
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/bodypart/ipc_arm = ipc.get_bodypart(BODY_ZONE_L_ARM)
	var/ipc_limb_id = ipc_arm.limb_id
	TEST_ASSERT(!ipc_arm.aq_set_brand("bishop") && !ipc_arm.aq_brand && ipc_arm.limb_id == ipc_limb_id, "A brand went onto an IPC chassis limb ([ipc_limb_id])")

	// Vey-Med na klatce udaje ludzką klatkę, która ma tylko stany z płcią
	var/obj/item/bodypart/chest/robot/lifelike_chest = allocate(/obj/item/bodypart/chest/robot)
	TEST_ASSERT(lifelike_chest.aq_set_brand("veymed", FEMALE) && lifelike_chest.aq_lifelike_disguised(), "A Vey-Med chest does not look like flesh")
	var/list/chest_icons = lifelike_chest.get_limb_icon(FALSE)
	var/image/chest_image = chest_icons[1]
	TEST_ASSERT(icon_exists(chest_image.icon, chest_image.icon_state), "A Vey-Med chest has no sprite ([chest_image.icon] / [chest_image.icon_state])")

/// AQUILA - zaawansowane protezy i ręka ze złomu
/datum/unit_test/aquila_prosthetic_tiers

/datum/unit_test/aquila_prosthetic_tiers/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/bonus_before = patient.unarmed_damage_bonus
	var/obj/item/bodypart/advanced = aq_test_swap_limb(patient, /obj/item/bodypart/r_arm/robot/aq_advanced)
	TEST_ASSERT(patient.unarmed_damage_bonus == bonus_before + 3, "An advanced arm does not punch harder")
	TEST_ASSERT(advanced.max_damage > initial(advanced.max_damage) - 1 && advanced.max_damage >= 75, "An advanced arm is not sturdier")
	advanced.drop_limb()
	TEST_ASSERT(patient.unarmed_damage_bonus == bonus_before, "The punch bonus stayed after the arm came off")
	advanced.attach_limb(patient, TRUE)

	// ręka ze złomu: tania proteza z menu wytwarzania
	var/datum/crafting_recipe/aq_scrap_l_arm/recipe = new
	TEST_ASSERT(recipe.result == /obj/item/bodypart/l_arm/robot/surplus, "The scrap arm recipe does not make a surplus arm")
	qdel(recipe)

/// AQUILA - przyszyta proteza działa od razu, bez kalibracji
/datum/unit_test/aquila_prosthetic_no_calibration

/datum/unit_test/aquila_prosthetic_no_calibration/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/old_arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	old_arm.drop_limb()
	qdel(old_arm)
	var/obj/item/bodypart/r_arm/robot/arm = allocate(/obj/item/bodypart/r_arm/robot)
	arm.attach_limb(patient)
	TEST_ASSERT(arm.disabled == BODYPART_NOT_DISABLED, "A freshly attached prosthesis does not work")

/// AQUILA - szybkie odłączanie protez (cecha „Mocowania protez”)
/datum/unit_test/aquila_limb_mounts

/datum/unit_test/aquila_limb_mounts/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = aq_test_swap_limb(patient, /obj/item/bodypart/l_arm/robot)
	TEST_ASSERT(!length(patient.aq_detachable_limbs()) || !HAS_TRAIT(patient, TRAIT_AQ_LIMB_MOUNTS), "Mounts work without the quirk")
	patient.add_quirk(/datum/quirk/aq_limb_mounts, TRUE)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_AQ_LIMB_MOUNTS), "The quirk gave no mounts")
	TEST_ASSERT(arm in patient.aq_detachable_limbs(), "A healthy prosthesis cannot be detached")
	TEST_ASSERT(patient.aq_detach_own_limb(arm, 0), "Detaching failed")
	TEST_ASSERT(!patient.get_bodypart(BODY_ZONE_L_ARM), "The detached prosthesis is still attached")
	TEST_ASSERT(patient.is_holding(arm), "The detached prosthesis is not in hand (it is in [arm.loc])")
	TEST_ASSERT(arm.aq_easy_attach_to(patient, patient), "The prosthesis did not click back in")
	TEST_ASSERT(patient.get_bodypart(BODY_ZONE_L_ARM) == arm && arm.disabled == BODYPART_NOT_DISABLED, "A remounted prosthesis does not work")

/// AQUILA - EMP rani i paraliżuje protezy, ciało zostaje w spokoju
/datum/unit_test/aquila_limb_emp

/datum/unit_test/aquila_limb_emp/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = aq_test_swap_limb(patient, /obj/item/bodypart/r_arm/robot)
	var/obj/item/bodypart/flesh = patient.get_bodypart(BODY_ZONE_L_ARM)
	arm.receive_damage(arm.max_damage * 0.3)
	var/before = arm.get_damage()
	patient.emp_act(EMP_HEAVY)
	TEST_ASSERT(arm.get_damage() > before, "EMP did not damage the prosthesis")
	TEST_ASSERT(HAS_TRAIT_FROM(arm, TRAIT_PARALYSIS, AQ_LIMB_EMP_TRAIT), "A damaged prosthesis was not paralysed by EMP")
	TEST_ASSERT(!flesh.get_damage(), "EMP hurt an organic arm")
	TEST_ASSERT(!patient.IsParalyzed(), "EMP still paralysed the whole body of a human with a prosthesis")
	arm.aq_emp_recover()
	TEST_ASSERT(!HAS_TRAIT_FROM(arm, TRAIT_PARALYSIS, AQ_LIMB_EMP_TRAIT), "The prosthesis did not recover from EMP")
	TEST_ASSERT(arm.disabled == BODYPART_NOT_DISABLED, "The prosthesis stayed paralysed after recovering from EMP")

	// przy obrażeniach 50-100% bezwładność is_disabled() nie może zostawić paraliżu po końcu awarii
	arm.brute_dam = arm.max_damage * 0.6
	arm.burn_dam = 0
	patient.emp_act(EMP_LIGHT)
	TEST_ASSERT(arm.disabled == BODYPART_DISABLED_PARALYSIS && arm.get_damage() < arm.max_damage, "EMP did not paralyse a half-wrecked prosthesis")
	arm.aq_emp_recover()
	TEST_ASSERT(arm.disabled == BODYPART_NOT_DISABLED, "A prosthesis with 50-100% damage stayed paralysed after EMP")

	// proteza odczepiona w trakcie awarii działa po ponownym przypięciu
	arm.brute_dam = arm.max_damage * 0.3
	patient.emp_act(EMP_LIGHT)
	TEST_ASSERT(arm.disabled == BODYPART_DISABLED_PARALYSIS, "EMP did not paralyse the prosthesis before detaching")
	arm.drop_limb()
	arm.aq_emp_recover()
	arm.attach_limb(patient, TRUE)
	TEST_ASSERT(arm.disabled == BODYPART_NOT_DISABLED, "A prosthesis detached during EMP stayed paralysed after reattaching")

	// IPC ma TRAIT_EASYDISMEMBER: EMP nie może mu odrywać głowy ani kończyn
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/parts_before = length(ipc.bodyparts)
	for(var/i in 1 to 5)
		ipc.aq_robotic_limbs_emp(EMP_LIGHT)
	TEST_ASSERT(length(ipc.bodyparts) == parts_before && ipc.get_bodypart(BODY_ZONE_HEAD), "EMP tore parts off an IPC ([length(ipc.bodyparts)] of [parts_before] left)")

/// AQUILA - rany robotyczne: pojawiają się na protezie, naprawa narzędziami
/datum/unit_test/aquila_robotic_wounds

/datum/unit_test/aquila_robotic_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = aq_test_swap_limb(patient, /obj/item/bodypart/r_arm/robot)

	var/datum/wound/crushed = patient.check_wounding(arm, 25, WOUND_BLUNT, 500)
	TEST_ASSERT(istype(crushed, /datum/wound/aq_robotic/blunt/crushed), "A heavy blow did not crush the servos ([crushed?.type])")
	TEST_ASSERT(!arm.get_wound(WOUND_BLUNT), "A prosthesis got an organic fracture")
	TEST_ASSERT(arm.disabled == BODYPART_DISABLED_PARALYSIS, "Crushed servos do not disable the limb")
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench)
	TEST_ASSERT(patient.get_treatable_wound(arm, wrench) == crushed, "A wrench cannot fix crushed servos")
	var/datum/wound/aq_robotic/robotic = crushed
	robotic.finish_repair()
	var/datum/wound/dent = arm.get_wound(WOUND_AQ_ROBOTIC_BLUNT)
	TEST_ASSERT(istype(dent, /datum/wound/aq_robotic/blunt/dent), "Fixed servos did not leave a dent")
	TEST_ASSERT(arm.disabled != BODYPART_DISABLED_PARALYSIS, "The arm stayed paralysed after the servos were fixed")

	// spawarka zamienia wgniecenie w luźne śruby, śrubokręt je usuwa
	var/obj/item/weldingtool/welder = allocate(/obj/item/weldingtool)
	var/datum/wound/aq_robotic/dent_wound = dent
	TEST_ASSERT(dent_wound.can_treat_with(welder), "A welder cannot fix a dent")
	dent_wound.finish_repair()
	var/datum/wound/aq_robotic/loose = arm.get_wound(WOUND_AQ_ROBOTIC_BLUNT)
	TEST_ASSERT(istype(loose, /datum/wound/aq_robotic/blunt/loose), "A fixed dent did not leave loose screws ([loose?.type])")
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver)
	TEST_ASSERT(loose.can_treat_with(screwdriver), "A screwdriver cannot tighten loose screws")
	loose.finish_repair()
	TEST_ASSERT(!arm.get_wound(WOUND_AQ_ROBOTIC_BLUNT), "Loose screws stayed after the repair")

	var/datum/wound/frayed = patient.check_wounding(arm, 25, WOUND_SLASH, 0)
	if(!frayed) // rzut losowy, więc wymuszamy lekką ranę
		frayed = new /datum/wound/aq_robotic/electric/frayed()
		frayed.apply_wound(arm, silent = TRUE)
	TEST_ASSERT(istype(frayed, /datum/wound/aq_robotic/electric), "A cut on a prosthesis is not an electrical wound")
	if(frayed.severity > WOUND_SEVERITY_MODERATE)
		var/datum/wound/aq_robotic/worse = frayed
		worse.finish_repair()
		frayed = arm.get_wound(WOUND_AQ_ROBOTIC_ELECTRIC)
	var/datum/wound/aq_robotic/frayed_wound = frayed
	var/obj/item/stack/cable_coil/cable = allocate(/obj/item/stack/cable_coil)
	var/cable_before = cable.amount
	TEST_ASSERT(frayed_wound.can_treat_with(cable), "Cable cannot fix frayed wires")
	TEST_ASSERT(frayed_wound.use_repair_item(cable, doctor) && cable.amount < cable_before, "Fixing frayed wires used no cable")
	frayed_wound.finish_repair()
	TEST_ASSERT(QDELETED(frayed_wound) && !arm.get_wound(WOUND_AQ_ROBOTIC_ELECTRIC), "Frayed wires stayed after the repair")

	var/datum/wound/heat = patient.check_wounding(arm, 25, WOUND_BURN, 500)
	TEST_ASSERT(istype(heat, /datum/wound/aq_robotic/heat/warped), "Heavy burns did not warp the plating ([heat?.type])")

	// IPC też ma rany robotyczne
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/datum/wound/ipc_wound = ipc.check_wounding(ipc.get_bodypart(BODY_ZONE_L_LEG), 25, WOUND_BLUNT, 500)
	TEST_ASSERT(istype(ipc_wound, /datum/wound/aq_robotic/blunt), "An IPC got no robotic wound")

/// AQUILA - cyfrowe używki dla IPC
/datum/unit_test/aquila_ipc_overloaders

/datum/unit_test/aquila_ipc_overloaders/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/aq_ipc_overloader/rainbow/drive = allocate(/obj/item/aq_ipc_overloader/rainbow)
	drive.apply_to(ipc)
	TEST_ASSERT(ipc.aq_overloader_level == 1 && ipc.aq_overloader_cycles > 0, "The overloader did not start")
	TEST_ASSERT(ipc.druggy, "Rainbow Essence did not colour the world")
	TEST_ASSERT(drive.uses == 1, "The overloader did not use a charge")
	var/obj/item/aq_ipc_overloader/classic/second = allocate(/obj/item/aq_ipc_overloader/classic)
	second.apply_to(ipc)
	second.apply_to(ipc)
	TEST_ASSERT(ipc.aq_overloader_level == 3, "Stacking overloaders does not overload")
	var/old_cycle_timer = ipc.aq_overloader_timer
	TEST_ASSERT(timeleft(old_cycle_timer), "The overloader cycle timer did not start")
	ipc.aq_clear_overloaders()
	TEST_ASSERT(!ipc.aq_overloader_level && !ipc.aq_overloader_cycles, "The reset did not clear the overloaders")
	TEST_ASSERT(!timeleft(old_cycle_timer), "The reset left the old cycle timer running (a second cycle chain would start)")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/aq_ipc_overloader/classic/third = allocate(/obj/item/aq_ipc_overloader/classic)
	human.put_in_hands(third)
	third.attack_self(human)
	TEST_ASSERT(!human.aq_overloader_level && third.uses == 2, "An overloader worked on an organic")

/// AQUILA - klucz resetu wybudza wyłączonego IPC, IPC nie wstaje już sam po naprawie
/datum/unit_test/aquila_synth_reset_key

/datum/unit_test/aquila_synth_reset_key/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/mob/living/carbon/human/robotist = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!(REVIVESBYHEALING in ipc.dna.species.species_traits), "IPCs still revive by healing")
	ipc.death()
	TEST_ASSERT(ipc.stat == DEAD, "The IPC did not shut down")
	ipc.heal_overall_damage(5, 5)
	TEST_ASSERT(ipc.stat == DEAD, "Healing woke up the IPC without a reset")

	var/obj/item/aq_synth_reset_key/key = allocate(/obj/item/aq_synth_reset_key)
	TEST_ASSERT(key.is_synthetic(ipc), "The reset key does not see the IPC port")
	TEST_ASSERT(!key.is_synthetic(robotist), "The reset key sees a port on a human")
	TEST_ASSERT(key.reboot(ipc, robotist), "The reset key did not reboot the IPC")
	TEST_ASSERT(ipc.stat != DEAD, "The IPC is still dead after the reset")

	// martwy mózg, samobójstwo i DNR: jak przy defibrylatorze, bez restartu
	var/mob/living/carbon/human/braindead = allocate(/mob/living/carbon/human/species/ipc)
	braindead.death()
	var/obj/item/organ/brain/dead_brain = braindead.getorganslot(ORGAN_SLOT_BRAIN)
	dead_brain.organ_flags |= ORGAN_FAILING
	TEST_ASSERT(!key.reboot(braindead, robotist) && braindead.stat == DEAD, "The reset key rebooted an IPC with a failing brain")
	dead_brain.organ_flags &= ~ORGAN_FAILING
	braindead.suiciding = TRUE
	TEST_ASSERT(!key.reboot(braindead, robotist) && braindead.stat == DEAD, "The reset key rebooted an IPC that killed itself")
	braindead.suiciding = FALSE
	braindead.mind_initialize()
	var/mob/dead/observer/ghost = new(braindead)
	ghost.mind = braindead.mind
	ghost.can_reenter_corpse = FALSE
	TEST_ASSERT(braindead.has_dnr(), "The test ghost does not count as DNR")
	TEST_ASSERT(!key.reboot(braindead, robotist) && braindead.stat == DEAD, "The reset key rebooted a DNR IPC")
	ghost.mind = null
	qdel(ghost)

	// zbyt uszkodzonego nie da się zrestartować
	var/mob/living/carbon/human/wreck = allocate(/mob/living/carbon/human/species/ipc)
	wreck.adjustBruteLoss(400)
	wreck.death()
	TEST_ASSERT(!key.reboot(wreck, robotist), "A wrecked IPC was rebooted")

	// na działającym czyści błędy
	ipc.adjust_hallucinations(60 SECONDS)
	ipc.Dizzy(20)
	key.repair_software(ipc, robotist)
	TEST_ASSERT(!ipc.dizziness, "The reset key did not fix software errors")

/// AQUILA - chirurgia mechaniczna: czyszczenie układu, reaktywacja, wygląd protezy i twarzy IPC
/datum/unit_test/aquila_synth_surgery

/datum/unit_test/aquila_synth_surgery/Run()
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/mob/living/carbon/human/robotist = allocate(/mob/living/carbon/human)
	var/datum/surgery_operation/basic/aq_system_purge/purge = new
	ipc.reagents.add_reagent(/datum/reagent/medicine/system_cleaner, 10)
	TEST_ASSERT(purge.state_check(ipc), "Purge is not offered for an IPC with chemicals")
	purge.on_success(ipc, robotist, null, list())
	TEST_ASSERT(!ipc.reagents.total_volume, "Purge did not flush the chemicals")
	qdel(purge)

	var/datum/surgery_operation/basic/aq_ipc_reactivation/reactivation = new
	ipc.death()
	TEST_ASSERT(reactivation.state_check(ipc), "Reactivation is not offered for a dead IPC")
	var/obj/item/organ/brain/ipc_brain = ipc.getorganslot(ORGAN_SLOT_BRAIN)
	ipc_brain.organ_flags |= ORGAN_FAILING
	reactivation.on_success(ipc, robotist, null, list())
	TEST_ASSERT(ipc.stat == DEAD, "Reactivation woke up an IPC with a failing brain")
	ipc_brain.organ_flags &= ~ORGAN_FAILING
	reactivation.on_success(ipc, robotist, null, list())
	TEST_ASSERT(ipc.stat != DEAD, "Reactivation did not wake up the IPC")
	qdel(reactivation)

	var/datum/surgery_operation/limb/aq_prosthetic_restyle/restyle = new
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = aq_test_swap_limb(patient, /obj/item/bodypart/l_arm/robot)
	TEST_ASSERT(restyle.state_check(arm), "Restyling is not offered for a prosthesis")
	restyle.on_success(arm, robotist, null, list("aq_brand" = GLOB.aq_robolimb_brands["zenghu"]))
	TEST_ASSERT(arm.aq_brand?.id == "zenghu", "Restyling did not change the brand")
	TEST_ASSERT(!restyle.state_check(patient.get_bodypart(BODY_ZONE_R_ARM)), "Restyling is offered for flesh")
	qdel(restyle)

	var/new_chassis
	for(var/chassis_name in GLOB.ipc_chassis_list)
		if(chassis_name != ipc.dna.features["ipc_chassis"])
			new_chassis = chassis_name
			break
	TEST_ASSERT(ipc.aq_set_ipc_chassis(new_chassis), "The IPC chassis did not change")
	var/datum/sprite_accessory/ipc_chassis/chassis = GLOB.ipc_chassis_list[new_chassis]
	TEST_ASSERT(ipc.get_bodypart(BODY_ZONE_CHEST).limb_id == chassis.limbs_id, "The IPC body does not use the new chassis")

/// AQUILA - cyberpsychoza rośnie z cybernetyką, lek ją wstrzymuje, syntetyków nie dotyczy
/datum/unit_test/aquila_cyberpsychosis

/datum/unit_test/aquila_cyberpsychosis/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	TEST_ASSERT(patient.aq_cyberpsychosis_stage() == 0, "A fully organic human has cyberpsychosis")
	aq_test_swap_limb(patient, /obj/item/bodypart/l_arm/robot/aq_advanced)
	aq_test_swap_limb(patient, /obj/item/bodypart/r_arm/robot)
	var/load_two = patient.aq_cyberpsychosis_load()
	TEST_ASSERT(load_two >= 24, "Prostheses do not load the mind ([load_two])")
	var/obj/item/organ/cyberimp/chest/aq_bracing/implant = new
	implant.Insert(patient)
	TEST_ASSERT(patient.aq_cyberpsychosis_load() == load_two + implant.aq_cyberpsychosis_cost, "An implant cost is not counted")
	aq_test_swap_limb(patient, /obj/item/bodypart/l_leg/robot)
	aq_test_swap_limb(patient, /obj/item/bodypart/r_leg/robot)
	for(var/organ_type in list(/obj/item/organ/heart/cybernetic, /obj/item/organ/lungs/cybernetic, /obj/item/organ/liver/cybernetic, /obj/item/organ/eyes/robotic))
		var/obj/item/organ/organ = new organ_type
		organ.Insert(patient, TRUE, FALSE)
	TEST_ASSERT(patient.aq_cyberpsychosis_stage() >= 2, "Heavy cybernetics do not cause cyberpsychosis (load [patient.aq_cyberpsychosis_load()])")

	patient.aq_cyberpsychosis_next = 0
	patient.reagents.add_reagent(/datum/reagent/medicine/aq_neuratrextate, 10)
	patient.aq_cyberpsychosis_tick()
	TEST_ASSERT(patient.aq_cyberpsychosis_next > world.time + 4 MINUTES, "Neuratrextate does not hold off the symptoms")
	patient.reagents.clear_reagents()
	patient.aq_cyberpsychosis_next = 0
	patient.aq_cyberpsychosis_tick()
	TEST_ASSERT(patient.aq_cyberpsychosis_next > world.time, "No symptom was scheduled")

	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	TEST_ASSERT(ipc.aq_cyberpsychosis_capacity() == 100, "An IPC can get cyberpsychosis")

/// AQUILA - implant zakłócający augmenty, implant skoku, wzmocnienie stawów
/datum/unit_test/aquila_robotics_implants

/datum/unit_test/aquila_robotics_implants/Run()
	var/mob/living/carbon/human/prisoner = allocate(/mob/living/carbon/human)
	var/obj/item/organ/cyberimp/arm/toolset/toolset = new
	toolset.Insert(prisoner)
	var/obj/item/implant/aq_anti_augment/disrupter = new
	TEST_ASSERT(disrupter.implant(prisoner, null, TRUE), "The disrupter did not implant")
	TEST_ASSERT(HAS_TRAIT(prisoner, TRAIT_AQ_AUGMENTS_DISRUPTED), "The disrupter does not disrupt")
	toolset.ui_action_click()
	TEST_ASSERT(!toolset.active_item, "A disrupted arm implant still extends")
	var/datum/action/item_action/organ_action/action = locate() in toolset.actions
	TEST_ASSERT(!action || !action.IsAvailable(), "A disrupted implant button still works")
	disrupter.removed(prisoner, TRUE)
	qdel(disrupter)
	TEST_ASSERT(!HAS_TRAIT(prisoner, TRAIT_AQ_AUGMENTS_DISRUPTED), "The disruption stayed after removal")

	// skok: jeden implant w dowolnej nodze daje akcję, drugi taki sam nic nie dodaje
	var/mob/living/carbon/human/jumper = allocate(/mob/living/carbon/human)
	var/obj/item/organ/cyberimp/leg/aq_jumpboots/right = new
	right.Insert(jumper)
	TEST_ASSERT(locate(/datum/action/innate/aq_implant_jump) in jumper.actions, "One jump implant gives no jump")
	var/obj/item/organ/cyberimp/leg/aq_jumpboots/left = new
	left.zone = BODY_ZONE_L_LEG
	left.SetSlotFromZone()
	left.Insert(jumper)
	TEST_ASSERT(!left.jump_action, "A second jump implant gave a second jump")
	left.Remove(jumper)
	qdel(left)
	right.Remove(jumper)
	TEST_ASSERT(!(locate(/datum/action/innate/aq_implant_jump) in jumper.actions), "The jump stayed after the implant came out")
	qdel(right)

	// wzmocnienie stawów
	var/mob/living/carbon/human/brawler = allocate(/mob/living/carbon/human)
	var/obj/item/organ/cyberimp/chest/aq_bracing/bracing = new
	bracing.Insert(brawler)
	TEST_ASSERT(brawler.aq_bracing_wound_modifier() < 0, "Skeletal bracing does not protect the joints")

	// koszty cyberpsychozy w skali 0/5/10/18
	var/list/cost_scale = list(0, 5, 10, 18)
	var/obj/item/organ/cyberimp/leg/aq_jumpboots/jump_type = /obj/item/organ/cyberimp/leg/aq_jumpboots
	TEST_ASSERT((bracing.aq_cyberpsychosis_cost in cost_scale) && (initial(jump_type.aq_cyberpsychosis_cost) in cost_scale), "The bracing or jump implant cost is off the 0/5/10/18 scale")

	// implant agonalny: klucz kapitana ma kanał medyczny wyłączony (0), a zgłoszenie ma na nim wyjść
	var/obj/item/implant/deathrattle/aq_medical/rattle = new
	TEST_ASSERT(rattle.implant(brawler, null, TRUE), "The deathrattle implant did not implant")
	rattle.aq_broadcast_death(brawler)
	TEST_ASSERT(rattle.aq_alert_radio?.channels[RADIO_CHANNEL_MEDICAL] && rattle.aq_alert_radio.secure_radio_connections[RADIO_CHANNEL_MEDICAL], "The deathrattle implant cannot broadcast on the medical channel")
	rattle.removed(brawler, TRUE)
	qdel(rattle)

/// AQUILA - neuromody: skan psychoskopem, zapis w powłoce, wstrzyknięcie
/datum/unit_test/aquila_neuromods

/datum/unit_test/aquila_neuromods/Run()
	var/mob/living/carbon/human/scientist = allocate(/mob/living/carbon/human)
	var/mob/living/basic/carp/carp = allocate(/mob/living/basic/carp)
	var/obj/item/aq_psychoscope/scope = allocate(/obj/item/aq_psychoscope)
	var/datum/aq_neuromod/found = scope.record_scan(carp, scientist, TRUE)
	TEST_ASSERT(istype(found, /datum/aq_neuromod/cold_resistance), "Scanning a carp did not find cold resistance")
	TEST_ASSERT(isnull(scope.record_scan(carp, scientist, TRUE)), "The same carp can be scanned twice")
	var/obj/item/aq_neuromod_shell/shell = allocate(/obj/item/aq_neuromod_shell)
	shell.load(/datum/aq_neuromod/cold_resistance)
	TEST_ASSERT(shell.inject(scientist, scientist), "The neuromod was not injected")
	TEST_ASSERT(HAS_TRAIT(scientist, TRAIT_RESISTCOLD), "The cold resistance neuromod did nothing")
	TEST_ASSERT(!shell.stored, "The shell kept the neuromod")

/// AQUILA - bojowe cyberserce z rdzeniem anomalii
/datum/unit_test/aquila_anomalock_heart

/datum/unit_test/aquila_anomalock_heart/Run()
	var/mob/living/carbon/human/soldier = allocate(/mob/living/carbon/human)
	var/obj/item/organ/heart/cybernetic/aq_anomalock/prebuilt/heart = new
	heart.Insert(soldier, TRUE, FALSE)
	TEST_ASSERT(HAS_TRAIT(soldier, TRAIT_SHOCKIMMUNE), "The cored heart gives no shock immunity")
	// sen i narkoza (UNCONSCIOUS przy pełnym zdrowiu) to nie stan krytyczny
	heart.on_stat_change(soldier, UNCONSCIOUS)
	TEST_ASSERT(!soldier.has_status_effect(/datum/status_effect/aq_voltaic_overdrive) && COOLDOWN_FINISHED(heart, survival_cooldown), "The voltaic heart fired on plain sleep")
	TEST_ASSERT(heart.emp_act(EMP_HEAVY) & EMP_PROTECT_SELF, "The cored heart is not EMP-proof")
	TEST_ASSERT(heart.activate_survival(), "The voltaic overdrive did not start")
	TEST_ASSERT(soldier.has_status_effect(/datum/status_effect/aq_voltaic_overdrive), "No voltaic overdrive status")
	TEST_ASSERT(HAS_TRAIT(soldier, TRAIT_NOHARDCRIT), "The overdrive does not keep the body upright")
	TEST_ASSERT(!heart.activate_survival(), "The overdrive ignores its cooldown")
	soldier.remove_status_effect(/datum/status_effect/aq_voltaic_overdrive)
	TEST_ASSERT(!HAS_TRAIT(soldier, TRAIT_NOHARDCRIT), "The overdrive traits stayed")

	var/obj/item/organ/heart/cybernetic/aq_anomalock/empty = allocate(/obj/item/organ/heart/cybernetic/aq_anomalock)
	TEST_ASSERT(!empty.activate_survival(), "A heart without a core works")

/// AQUILA - augmentacje wybierane w lobby
/datum/unit_test/aquila_lobby_augments

/datum/unit_test/aquila_lobby_augments/Run()
	var/mob/living/carbon/human/veteran = allocate(/mob/living/carbon/human)
	veteran.aq_apply_lobby_augments(list(
		"aq_aug_l_arm" = "bishop",
		"aq_aug_r_leg" = "surplus",
		"aq_aug_l_leg" = "advanced",
		"aq_aug_heart" = "cybernetic",
		"aq_aug_lungs" = "upgraded",
		"aq_aug_r_arm" = "organic",
	))
	var/obj/item/bodypart/l_arm = veteran.get_bodypart(BODY_ZONE_L_ARM)
	TEST_ASSERT(l_arm.aq_brand?.id == "bishop", "The lobby did not give a Bishop arm")
	TEST_ASSERT(istype(veteran.get_bodypart(BODY_ZONE_R_LEG), /obj/item/bodypart/r_leg/robot/surplus), "The lobby did not give a surplus leg")
	TEST_ASSERT(IS_ORGANIC_LIMB(veteran.get_bodypart(BODY_ZONE_L_LEG)), "The lobby still gives advanced prostheses")
	TEST_ASSERT(IS_ORGANIC_LIMB(veteran.get_bodypart(BODY_ZONE_R_ARM)), "An organic choice replaced the arm")
	TEST_ASSERT(istype(veteran.getorganslot(ORGAN_SLOT_HEART), /obj/item/organ/heart/cybernetic), "The lobby did not give a cybernetic heart")
	TEST_ASSERT(!istype(veteran.getorganslot(ORGAN_SLOT_LUNGS), /obj/item/organ/lungs/cybernetic), "The lobby still gives upgraded organs")

	// część ciała zajęta przez cechę (tu: tania proteza z cechy Proteza) zostaje z cechy
	var/mob/living/carbon/human/amputee = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/quirk_arm = aq_test_swap_limb(amputee, /obj/item/bodypart/l_arm/robot/surplus)
	amputee.aq_apply_lobby_augments(list("aq_aug_l_arm" = "bishop"))
	TEST_ASSERT(amputee.get_bodypart(BODY_ZONE_L_ARM) == quirk_arm && !quirk_arm.aq_brand, "The lobby replaced a prosthesis from a quirk")

	// cecha zajmująca całą grupę chowa wybór w kreatorze; cech spoza buildu (aq33/AquilaStation#655) nie liczy
	var/datum/quirk/prosthetic = /datum/quirk/prosthetic_limb
	var/list/quirk_names = list(initial(prosthetic.name))
	TEST_ASSERT(aq_quirks_block_augment(quirk_names, list("/datum/quirk/prosthetic_limb")), "A blocking quirk did not block the lobby choice")
	TEST_ASSERT(!aq_quirks_block_augment(quirk_names, list("/datum/quirk/aq_no_such_quirk")), "A quirk missing from the build blocked the lobby choice")
	TEST_ASSERT(!aq_quirks_block_augment(list(), list("/datum/quirk/prosthetic_limb")), "No quirks blocked the lobby choice")

	// każdy wybór w kreatorze ma polską nazwę i jest poprawny
	for(var/pref_type in subtypesof(/datum/preference/choiced/aq_augment))
		var/datum/preference/choiced/aq_augment/pref = GLOB.preference_entries[pref_type]
		if(!pref)
			continue
		var/list/names = pref.get_display_names()
		for(var/choice in pref.get_choices())
			TEST_ASSERT(names[choice], "[pref.db_key] has no name for [choice]")

	// organy gatunkowe zostają: plazmaludź bez swoich płuc się dusi, a zwykłe serce można wymienić
	var/mob/living/carbon/human/plasmaman = allocate(/mob/living/carbon/human/species/plasma)
	plasmaman.aq_apply_lobby_augments(list("aq_aug_lungs" = "cybernetic", "aq_aug_stomach" = "cybernetic", "aq_aug_heart" = "cybernetic"))
	TEST_ASSERT(istype(plasmaman.getorganslot(ORGAN_SLOT_LUNGS), /obj/item/organ/lungs/plasmaman), "The lobby swapped the plasmaman lungs")
	TEST_ASSERT(istype(plasmaman.getorganslot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/plasmaman), "The lobby swapped the plasmaman stomach")
	TEST_ASSERT(istype(plasmaman.getorganslot(ORGAN_SLOT_HEART), /obj/item/organ/heart/cybernetic), "The lobby did not swap a plain plasmaman heart")
	var/mob/living/carbon/human/ethereal = allocate(/mob/living/carbon/human/species/ethereal)
	ethereal.aq_apply_lobby_augments(list("aq_aug_stomach" = "cybernetic", "aq_aug_heart" = "cybernetic"))
	TEST_ASSERT(!istype(ethereal.getorganslot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/cybernetic), "The lobby swapped the ethereal battery stomach")
	TEST_ASSERT(!istype(ethereal.getorganslot(ORGAN_SLOT_HEART), /obj/item/organ/heart/cybernetic), "The lobby swapped the ethereal heart")
	var/datum/preference/choiced/aq_augment/organ/lungs_pref = GLOB.preference_entries[/datum/preference/choiced/aq_augment/organ/lungs]
	var/datum/species/plasmaman/plasma_species = new
	TEST_ASSERT(lungs_pref.aq_species_organ_type(plasma_species) != lungs_pref.aq_default_organ_type(), "The creator offers cybernetic lungs to plasmamen")
	qdel(plasma_species)

	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/bodypart/ipc_arm = ipc.get_bodypart(BODY_ZONE_L_ARM)
	ipc.aq_apply_lobby_augments(list("aq_aug_l_arm" = "bishop"))
	TEST_ASSERT(ipc.get_bodypart(BODY_ZONE_L_ARM) == ipc_arm, "The lobby swapped an IPC limb")

#undef TEST_ASSERT
