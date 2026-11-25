// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - stos korowy wyjęty z ciała zapisuje rekord klonowania, konsola klonowania dodaje z niego rekord,
/// a pusty stos dostaje w konsoli kopię rekordu (zgłoszenie 25.11)
/datum/unit_test/aquila_cortical_stack_copy

/datum/unit_test/aquila_cortical_stack_copy/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	patient.mind_initialize()
	var/obj/item/organ/cortical_stack/stack = patient.getorganslot(ORGAN_SLOT_CORTICAL_STACK)
	if(!stack)
		stack = allocate(/obj/item/organ/cortical_stack)
		stack.Insert(patient)
	TEST_ASSERT(!stack.clone_fields, "A stack in a body already holds a stale record")
	stack.Remove(patient)
	TEST_ASSERT(stack.clone_fields, "A stack taken out of a body didn't record the clone record")
	TEST_ASSERT(stack.clone_fields["name"] == patient.real_name, "The stack recorded [stack.clone_fields["name"]] instead of [patient.real_name]")
	TEST_ASSERT(stack.clone_fields["mindref"] == "[REF(patient.mind)]", "The stack didn't record the patient's mind")

	var/obj/machinery/computer/cloning/console = allocate(/obj/machinery/computer/cloning, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	TEST_ASSERT(console.load_cortical_stack(stack, doctor), "The cloning console didn't load the stack")
	var/datum/data/record/record = find_record("id", stack.clone_fields["id"], console.records)
	TEST_ASSERT(record, "The cloning console has no record from the stack")
	TEST_ASSERT(record.fields["mindref"] == stack.clone_fields["mindref"] && !record.fields["body_only"], "The record from the stack can't bring back the mind")
	console.load_cortical_stack(stack, doctor)
	TEST_ASSERT(length(console.records) == 1, "Loading the same stack twice made [length(console.records)] records")

	// Kopia na pusty stos (bez okna wyboru: zapis wybranego rekordu)
	var/obj/item/organ/cortical_stack/blank = allocate(/obj/item/organ/cortical_stack)
	blank.write_record(record)
	TEST_ASSERT(blank.clone_fields?["mindref"] == record.fields["mindref"], "The copy on the blank stack doesn't hold the mind")
	TEST_ASSERT(blank.clone_fields != record.fields, "The copy shares the record list with the console")
	// Stos wszczepiony z powrotem zapisuje się od nowa przy następnym wyjęciu
	blank.Insert(patient)
	TEST_ASSERT(!blank.clone_fields, "An implanted stack kept the old copy")

/// AQUILA - horror wycina się operacją manipulacji organami głowy, opcją „wyciągnięcie pasożyta” (zgłoszenie 25.11)
/datum/unit_test/aquila_horror_surgery_removal

/datum/unit_test/aquila_horror_surgery_removal/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/simple_animal/horror/horror = allocate(/mob/living/simple_animal/horror, run_loc_floor_bottom_left)
	// Wejście do głowy jak w infect_victim (bez sprawdzania ducha i klienta)
	horror.victim = host
	horror.forceMove(host)
	TEST_ASSERT(host.has_horror_inside() == horror, "The horror isn't inside the host")
	var/datum/surgery_operation/limb/organ_manipulation/internal/manip = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/organ_manipulation/internal]
	var/obj/item/bodypart/head = host.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(manip.is_remove_available(head, BODY_ZONE_HEAD), "The head organ manipulation has nothing to take out of a host with a horror")
	var/found_option = FALSE
	for(var/option in manip.get_remove_options(head, BODY_ZONE_HEAD))
		var/list/option_args = manip.get_remove_options(head, BODY_ZONE_HEAD)[option]
		if(option_args[OPERATION_ACTION] == "remove_horror")
			found_option = TRUE
	TEST_ASSERT(found_option, "The head organ manipulation has no parasite extraction option")
	manip.on_success_remove_horror(head, surgeon)
	TEST_ASSERT(!host.has_horror_inside(), "The horror stayed inside after the extraction")
	TEST_ASSERT(isturf(horror.loc), "The extracted horror isn't on the floor ([horror.loc])")

#undef TEST_ASSERT
