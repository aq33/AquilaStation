// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - light wounds: applying, effects, healing
/datum/unit_test/aquila_wounds

/datum/unit_test/aquila_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)

	TEST_ASSERT(!patient.check_wounding(leg, WOUND_MINIMUM_DAMAGE - 1, WOUND_BLUNT), "A scratch caused a wound")

	var/datum/wound/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(leg, silent = TRUE)
	TEST_ASSERT(leg.get_wound(WOUND_BLUNT) == fracture, "The fracture is not on the leg")
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_wounds"), "A broken leg does not slow down")
	TEST_ASSERT(findtext(jointext(patient.get_wound_scan_lines(), ""), fracture.name), "The analyzer does not see the fracture")

	var/obj/item/stack/medical/bandage/bandage = allocate(/obj/item/stack/medical/bandage)
	TEST_ASSERT(patient.get_treatable_wound(leg, bandage) == fracture, "A bandage cannot splint a fracture")
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/bandages_before = bandage.get_amount()
	TEST_ASSERT(fracture.treat(bandage, doctor), "The bandage splint was interrupted")
	TEST_ASSERT(fracture.treated, "The bandage did not splint the fracture")
	TEST_ASSERT(bandage.get_amount() == bandages_before - 1, "Splinting did not use one bandage")
	TEST_ASSERT(!patient.get_treatable_wound(leg, bandage), "A splinted fracture can be splinted again")

	// The bandage took over gauze: it stops bleeding and leaves it bandaged
	var/mob/living/carbon/human/bleeder = allocate(/mob/living/carbon/human)
	bleeder.add_bleeding(BLEED_DEEP_WOUND)
	doctor.zone_selected = BODY_ZONE_CHEST
	bandage.attack(bleeder, doctor)
	TEST_ASSERT(!bleeder.is_bleeding(), "A bandage did not stop the bleeding")
	TEST_ASSERT(bleeder.is_bandaged(), "A bandage did not leave the bleeding bandaged")

	var/datum/wound/compound = patient.check_wounding(leg, 200, WOUND_BLUNT)
	if(compound)
		TEST_ASSERT(QDELETED(fracture), "A worse fracture did not replace the old one")
		TEST_ASSERT(length(leg.wounds) == 1, "Two blunt wounds on one leg")

	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/wound/artery = new /datum/wound/slash/artery()
	artery.apply_wound(arm, silent = TRUE)
	TEST_ASSERT(patient.is_bleeding(), "A torn artery does not bleed")
	var/obj/item/stack/medical/suture/suture = allocate(/obj/item/stack/medical/suture)
	TEST_ASSERT(patient.get_treatable_wound(arm, suture) == artery, "Sutures cannot close a torn artery")
	var/datum/wound/sutured = artery.replace_with(/datum/wound/slash/deep)
	TEST_ASSERT(arm.get_wound(WOUND_SLASH) == sutured && QDELETED(artery), "A sutured artery did not become a deep cut")

	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/wound/burn/burn = new /datum/wound/burn/third_degree()
	burn.apply_wound(chest, silent = TRUE)
	burn.wound_effects(100)
	TEST_ASSERT(patient.getToxLoss() > 0, "An infected burn does not poison")

	patient.fully_heal()
	TEST_ASSERT(!length(leg.wounds) && !length(arm.wounds) && !length(chest.wounds), "Full heal left wounds")
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, "aq_wounds"), "Full heal left the limp")

/// AQUILA - every medkit and the tgstation dressings have a sprite
/datum/unit_test/aquila_medkit_icons

/datum/unit_test/aquila_medkit_icons/Run()
	var/list/types = subtypesof(/obj/item/storage/firstaid) + typesof(/obj/item/stack/medical/suture) + typesof(/obj/item/stack/medical/mesh)
	for(var/obj/item/path as anything in types)
		var/state = initial(path.icon_state)
		var/icon_file = initial(path.icon)
		if(!icon_file || !state)
			continue
		TEST_ASSERT(state in icon_states(icon_file), "[path] has no sprite '[state]' in [icon_file]")

/// AQUILA - the health analyzer window (AuriStation#15) sees damage, wounds and bleeding
/datum/unit_test/aquila_health_analyzer_ui

/datum/unit_test/aquila_health_analyzer_ui/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	arm.receive_damage(20)
	var/datum/wound/cut = new /datum/wound/slash/deep()
	cut.apply_wound(arm, silent = TRUE)
	var/list/data = get_health_analyzer_data(patient, patient, FALSE)
	TEST_ASSERT(data["target"] == patient.name, "Wrong patient in the window")
	var/list/arm_injuries = data["injuries"][BODY_ZONE_L_ARM]
	var/list/names = list()
	for(var/list/injury as anything in arm_injuries)
		names += injury["name"]
	TEST_ASSERT("Obrażenia fizyczne" in names, "Limb damage is missing")
	TEST_ASSERT(cut.name in names, "The wound is missing")
	var/found_bleeding = FALSE
	for(var/list/injury as anything in data["injuries"]["body"])
		if(injury["name"] == "Krwawienie")
			found_bleeding = TRUE
	TEST_ASSERT(found_bleeding, "Bleeding is missing")

/// AQUILA - the advanced analyzer and vitals monitor show the surgical state of operated zones and what can be done next
/datum/unit_test/aquila_surgery_progress

/datum/unit_test/aquila_surgery_progress/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	patient.set_resting(TRUE)
	TEST_ASSERT(!length(patient.get_surgery_progress()), "A patient without surgery shows an operated zone")

	patient.toggle_surgery_prep(doctor, BODY_ZONE_CHEST)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_SKIN_CUT)
	var/list/progress = patient.get_surgery_progress()
	TEST_ASSERT(length(progress) == 1, "The operated chest is missing: [length(progress)] zones")
	var/list/entry = progress[1]
	TEST_ASSERT(entry["zone"] == strefa_pl(BODY_ZONE_CHEST), "Wrong zone: [entry["zone"]]")
	TEST_ASSERT("Skóra nacięta" in entry["state"], "The cut skin is missing from the state: [jointext(entry["state"], ", ")]")
	var/retract_name = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/retract_skin].name
	TEST_ASSERT(retract_name in entry["next"], "Retracting the skin is not offered next: [jointext(entry["next"], ", ")]")

	// the ongoing operation is shown while it lasts
	var/datum/surgery_operation/retract = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/retract_skin]
	LAZYSET(patient.ongoing_operations, BODY_ZONE_CHEST, retract)
	entry = patient.get_surgery_progress()[1]
	TEST_ASSERT(entry["operation"] == capitalize(retract.name), "The ongoing operation is missing: [entry["operation"]]")
	LAZYREMOVE(patient.ongoing_operations, BODY_ZONE_CHEST)

	var/list/data = get_health_analyzer_data(patient, patient, TRUE)
	TEST_ASSERT(length(data["surgeries"]) == 1, "The advanced analyzer window does not show the operated zone")
	TEST_ASSERT(isnull(get_health_analyzer_data(patient, patient, FALSE)["surgeries"]), "The basic analyzer shows the surgery")
	TEST_ASSERT(findtext(healthscan(doctor, patient, advanced = TRUE, tochat = FALSE), "Operacja ("), "The advanced scan (vitals monitor) does not show the surgery")
	TEST_ASSERT(!findtext(healthscan(doctor, patient, advanced = FALSE, tochat = FALSE), "Operacja ("), "The basic scan shows the surgery")

/// AQUILA - vitals monitors mapped over stasis beds are connected to their own bed
/datum/unit_test/aquila_mapped_vitals_monitors

/datum/unit_test/aquila_mapped_vitals_monitors/Run()
	var/checked = 0
	for(var/obj/machinery/vitals_reader/monitor in GLOB.machines)
		if(!findtext(monitor.id_tag, "aq_vitals_"))
			continue
		checked++
		TEST_ASSERT(istype(monitor.connected, /obj/machinery/stasis), "Monitor at [monitor.x],[monitor.y],[monitor.z] is not connected to a stasis bed")
		var/obj/machinery/stasis/bed = monitor.connected
		TEST_ASSERT(bed.id_tag == monitor.id_tag, "Monitor at [monitor.x],[monitor.y],[monitor.z] picked the wrong bed")
	log_world("aquila_mapped_vitals_monitors: [checked] mapped monitors checked")
	// One monitor per stasis bed on the maps in rotation (json map_name)
	var/static/list/expected_per_map = list("NSV Aquilas" = 3, "DLV Trawnik" = 4, "NSV Padalec" = 2, "NSV Atlantis" = 7, "SGV Von Neumann" = 2)
	var/expected = expected_per_map[SSmapping.config?.map_name]
	if(!isnull(expected))
		TEST_ASSERT(checked == expected, "[SSmapping.config.map_name] has [checked] mapped vitals monitors, expected [expected]")

#undef TEST_ASSERT
