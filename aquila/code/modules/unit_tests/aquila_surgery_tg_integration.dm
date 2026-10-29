// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - new surgery skeleton (tgstation#93697): a real surgery disk loaded into an operating computer next to the table
/// unlocks the operation for the patient on that table, and the computer window shows it
/datum/unit_test/aquila_surgery_disk_unlock

/datum/unit_test/aquila_surgery_disk_unlock/Run()
	var/obj/structure/table/optable/table = allocate(/obj/structure/table/optable)
	var/obj/machinery/computer/operating/computer = allocate(/obj/machinery/computer/operating, get_step(table, EAST))
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, table.loc)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human, get_step(table, NORTH))
	TEST_ASSERT(table.computer == computer, "The operating computer did not link to the table next to it")

	patient.set_resting(TRUE)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_HEAD)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	head.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED|SURGERY_VESSELS_CLAMPED)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)
	surgeon.put_in_active_hand(hemostat)
	var/brainwash_type = /datum/surgery_operation/organ/brainwash
	var/datum/surgery_operation/brainwash = GLOB.operations.operations_by_typepath[brainwash_type]
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, hemostat, BODY_ZONE_HEAD), brainwash), "Brainwashing offered without a disk")

	var/obj/item/disk/surgery/brainwashing/disk = allocate(/obj/item/disk/surgery/brainwashing)
	computer.attackby(disk, surgeon)
	TEST_ASSERT(brainwash_type in computer.advanced_surgeries, "The disk did not load brainwashing into the computer")
	TEST_ASSERT(has_operation(surgeon.get_available_operations(patient, hemostat, BODY_ZONE_HEAD), brainwash), "Brainwashing not offered on the table of a computer with the disk")

	// the computer window: loaded operation, state of the selected zone, operations possible next
	computer.target_zone = BODY_ZONE_HEAD
	var/list/data = computer.ui_data(surgeon)
	TEST_ASSERT("[brainwash_type]" in data["surgeries"], "The computer window does not list the loaded operation")
	TEST_ASSERT("Kość przepiłowana" in data["patient"]["surgery_state"], "The computer window does not show the head state: [jointext(data["patient"]["surgery_state"], ", ")]")
	TEST_ASSERT("[brainwash_type]" in data["next_operations"], "The computer window does not offer brainwashing next")
	TEST_ASSERT("[/datum/surgery_operation/limb/close_skin]" in data["next_operations"], "The computer window does not offer closing the incision next")

	// another table without a computer does not get the unlock
	var/obj/structure/table/optable/other_table = allocate(/obj/structure/table/optable, get_step(get_step(table, NORTH), NORTH))
	patient.forceMove(other_table.loc)
	TEST_ASSERT(!has_operation(surgeon.get_available_operations(patient, hemostat, BODY_ZONE_HEAD), brainwash), "Brainwashing offered away from the computer with the disk")

/datum/unit_test/aquila_surgery_disk_unlock/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

/// AQUILA - every locked operation can be unlocked somehow, and disks and research designs only hold operation types
/datum/unit_test/aquila_surgery_unlock_sources

/datum/unit_test/aquila_surgery_unlock_sources/Run()
	var/list/unlockable = GLOB.abductor_operations.Copy()
	for(var/design_id in SSresearch.techweb_designs)
		var/datum/design/surgery/design = SSresearch.techweb_designs[design_id]
		if(!istype(design) || (design_id in list("surgery_parent", "surgery_healing_base"))) // typy bazowe bez operacji
			continue
		TEST_ASSERT(design.surgery, "Design [design_id] unlocks nothing")
		var/list/design_operations = islist(design.surgery) ? design.surgery : list(design.surgery)
		for(var/operation_type in design_operations)
			TEST_ASSERT(operation_type in GLOB.operations.locked, "Design [design_id] holds [operation_type], which is not a locked operation")
		unlockable |= design_operations
	for(var/disk_type in subtypesof(/obj/item/disk/surgery))
		var/obj/item/disk/surgery/disk = allocate(disk_type)
		for(var/operation_type in disk.surgeries)
			TEST_ASSERT(operation_type in GLOB.operations.locked, "Disk [disk_type] holds [operation_type], which is not a locked operation")
		if(disk_type != /obj/item/disk/surgery/debug)
			unlockable |= disk.surgeries
	for(var/operation_type in GLOB.operations.locked)
		TEST_ASSERT(operation_type in unlockable, "Locked operation [operation_type] has no disk, design or other way to unlock it")

/// AQUILA - a dental implant can be done on yourself again: the mouth steps before it allow self surgery
/datum/unit_test/aquila_surgery_self_dental

/datum/unit_test/aquila_surgery_self_dental/Run()
	var/mob/living/carbon/human/dentist = allocate(/mob/living/carbon/human)
	dentist.set_resting(TRUE)
	dentist.toggle_surgery_prep(dentist, BODY_ZONE_PRECISE_MOUTH)
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	dentist.put_in_active_hand(scalpel)
	var/datum/surgery_operation/incise = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]
	TEST_ASSERT(has_operation(dentist.get_available_operations(dentist, scalpel, BODY_ZONE_PRECISE_MOUTH), incise), "Incision not offered on your own mouth")
	TEST_ASSERT(!has_operation(dentist.get_available_operations(dentist, scalpel, BODY_ZONE_HEAD), incise), "Incision offered on your own head outside the mouth")

	var/obj/item/bodypart/head = dentist.get_bodypart(BODY_ZONE_HEAD)
	head.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_UNCLAMPED)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)
	var/datum/surgery_operation/clamp = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/clamp_bleeders]
	TEST_ASSERT(has_operation(dentist.get_available_operations(dentist, hemostat, BODY_ZONE_PRECISE_MOUTH), clamp), "Clamping not offered on your own mouth")
	head.remove_surgical_state(SURGERY_VESSELS_UNCLAMPED)
	head.add_surgical_state(SURGERY_VESSELS_CLAMPED)
	var/obj/item/surgicaldrill/drill = allocate(/obj/item/surgicaldrill)
	var/datum/surgery_operation/drill_bones = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/drill_bones]
	TEST_ASSERT(has_operation(dentist.get_available_operations(dentist, drill, BODY_ZONE_PRECISE_MOUTH), drill_bones), "Drilling not offered on your own mouth")
	head.add_surgical_state(SURGERY_BONE_DRILLED)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/surgery_operation/dental = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/add_dental_implant]
	TEST_ASSERT(has_operation(dentist.get_available_operations(dentist, pill, BODY_ZONE_PRECISE_MOUTH), dental), "Dental implant not offered on your own drilled mouth")

/datum/unit_test/aquila_surgery_self_dental/proc/has_operation(list/operations, datum/surgery_operation/operation)
	for(var/radial_slice in operations)
		var/list/entry = operations[radial_slice]
		if(entry[1] == operation)
			return TRUE
	return FALSE

#undef TEST_ASSERT
