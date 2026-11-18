// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - NIF (port z Monkestation): kalibracja po wszczepieniu, instalacja NIFSoftu z dysku,
/// zużycie energii przez włączony program, chwilowa awaria po EMP i czyszczenie programów po wyjęciu
/datum/unit_test/aquila_nif

/datum/unit_test/aquila_nif/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/cyberimp/brain/nif/standard/nif = new()

	// Wszczepienie zaczyna kalibrację
	nif.Insert(patient)
	TEST_ASSERT(patient.getorganslot(ORGAN_SLOT_BRAIN_NIF) == nif, "The NIF did not take its slot")
	TEST_ASSERT(nif.linked_mob == patient, "The NIF did not link to its host")
	TEST_ASSERT(nif.calibrating && !nif.is_calibrated, "Implanting a NIF did not start the calibration")
	TEST_ASSERT(patient.GetComponent(/datum/component/nif_examine), "The host got no NIF examine text")

	// Podczas kalibracji nic się nie instaluje
	var/obj/item/disk/nifsoft_uploader/money_sense/early_disk = allocate(/obj/item/disk/nifsoft_uploader/money_sense)
	TEST_ASSERT(!early_disk.attempt_software_install(patient, patient), "A NIFSoft installed on a calibrating NIF")
	TEST_ASSERT(!QDELETED(early_disk), "A failed install used up the disk")

	// Skalibrowany NIF instaluje NIFSoft z dysku, a dysk się zużywa
	nif.calibrating = FALSE
	nif.is_calibrated = TRUE
	var/obj/item/disk/nifsoft_uploader/money_sense/disk = new(get_turf(patient))
	TEST_ASSERT(disk.attempt_software_install(patient, patient), "A calibrated NIF did not install the NIFSoft from the disk")
	var/datum/nifsoft/money_sense/soft = patient.find_nifsoft(/datum/nifsoft/money_sense)
	TEST_ASSERT(istype(soft) && (soft in nif.loaded_nifsofts), "The installed NIFSoft is not on the NIF")
	TEST_ASSERT(QDELETED(disk), "A single-use disk survived the install")
	TEST_ASSERT(!early_disk.attempt_software_install(patient, patient), "The same NIFSoft installed twice")

	// Włączony program zużywa energię
	TEST_ASSERT(nif.power_level == nif.max_power_level, "A new NIF is not fully charged")
	TEST_ASSERT(soft.activate() && soft.active, "The NIFSoft did not turn on")
	TEST_ASSERT(patient.GetComponent(/datum/component/money_sense), "The running NIFSoft gave no effect")
	nif.process(2)
	TEST_ASSERT(nif.power_level < nif.max_power_level, "A running NIFSoft did not drain power")

	// Zasilanie z odżywienia ładuje NIF i zwiększa głód
	var/hunger_before = patient.physiology.hunger_mod
	patient.set_nutrition(NUTRITION_LEVEL_FED)
	TEST_ASSERT(nif.toggle_nutrition_drain(), "Nutrition drain did not turn on")
	TEST_ASSERT(patient.physiology.hunger_mod > hunger_before, "Nutrition drain did not raise hunger")
	var/power_before = nif.power_level
	nif.process(2)
	TEST_ASSERT(nif.power_level > power_before, "Nutrition drain did not charge the NIF")

	// EMP chwilowo psuje NIF i wyłącza programy
	var/durability_before = nif.durability
	nif.emp_act(EMP_HEAVY)
	TEST_ASSERT(nif.broken, "EMP did not break the NIF")
	TEST_ASSERT(nif.durability < durability_before, "EMP did not damage the NIF")
	TEST_ASSERT(!soft.active, "EMP left the NIFSoft running")
	TEST_ASSERT(!soft.activate(), "A NIFSoft turned on while the NIF is broken")
	TEST_ASSERT(nif.fix_nif() && !nif.broken, "The NIF did not recover after EMP")

	// Wyjęcie czyści programy i zwraca głód do normy
	nif.Remove(patient)
	TEST_ASSERT(!length(nif.loaded_nifsofts), "Removing the NIF left NIFSofts installed")
	TEST_ASSERT(QDELETED(soft), "The removed NIF's NIFSoft was not deleted")
	TEST_ASSERT(!patient.GetComponent(/datum/component/money_sense), "The NIFSoft effect stayed after removal")
	TEST_ASSERT(!patient.GetComponent(/datum/component/nif_examine), "The NIF examine text stayed after removal")
	TEST_ASSERT(patient.physiology.hunger_mod == hunger_before, "Removing the NIF did not restore hunger")
	TEST_ASSERT(!patient.getorganslot(ORGAN_SLOT_BRAIN_NIF), "The NIF slot is still taken")
	qdel(nif)

	// Zniszczenie wszczepionego NIF-u z włączonym programem też sprząta ciało nosiciela
	var/obj/item/organ/cyberimp/brain/nif/debug/debug_nif = new()
	debug_nif.Insert(patient)
	TEST_ASSERT(!debug_nif.calibrating, "A pre-calibrated NIF started calibrating")
	var/datum/nifsoft/money_sense/debug_soft = new(debug_nif)
	TEST_ASSERT(debug_soft.activate() && debug_nif.toggle_nutrition_drain(), "The NIFSoft or nutrition drain did not turn on")
	qdel(debug_nif)
	TEST_ASSERT(QDELETED(debug_soft), "The destroyed NIF's NIFSoft was not deleted")
	TEST_ASSERT(!patient.GetComponent(/datum/component/money_sense), "The NIFSoft effect stayed after the NIF was destroyed")
	TEST_ASSERT(patient.physiology.hunger_mod == hunger_before, "Destroying the NIF did not restore hunger")

#undef TEST_ASSERT
