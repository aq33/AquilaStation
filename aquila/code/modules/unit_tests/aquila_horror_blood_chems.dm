// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - pradawny horror uczy się substancji z krwi nosiciela (Monkestation): wykluczenia, koszt, limit i wstrzykiwanie
/datum/unit_test/aquila_horror_blood_chems

/datum/unit_test/aquila_horror_blood_chems/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/simple_animal/horror/horror = allocate(/mob/living/simple_animal/horror, run_loc_floor_bottom_left)
	TEST_ASSERT(horror.has_ability(/datum/action/innate/horror/learn_blood_chem), "Horror has no blood chemical learning ability")
	horror.victim = host
	horror.chemicals = 250

	host.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 5)
	host.reagents.add_reagent(/datum/reagent/medicine/morphine, 5)
	host.reagents.add_reagent(/datum/reagent/toxin/plasma, 5)
	host.reagents.add_reagent(/datum/reagent/medicine/adminordrazine, 5)
	host.reagents.add_reagent(/datum/reagent/medicine/bicaridine, 5)
	var/list/options = horror.learnable_blood_reagents()
	TEST_ASSERT(/datum/reagent/medicine/spaceacillin in flatten_list(options), "Spaceacillin in the host's blood cannot be learned")
	TEST_ASSERT(!(/datum/reagent/toxin/plasma in flatten_list(options)), "Blacklisted plasma can be learned")
	TEST_ASSERT(!(/datum/reagent/medicine/adminordrazine in flatten_list(options)), "Admin-only adminordrazine can be learned")
	TEST_ASSERT(!(/datum/reagent/medicine/bicaridine in flatten_list(options)), "Bicaridine, a chemical the horror already has, is offered again")

	TEST_ASSERT(horror.learn_reagent(/datum/reagent/medicine/spaceacillin), "Horror failed to learn spaceacillin")
	TEST_ASSERT(horror.chemicals == 250 - 75, "Learning cost [250 - horror.chemicals] chemicals instead of 75")
	TEST_ASSERT(!horror.learn_reagent(/datum/reagent/medicine/spaceacillin), "Horror learned the same chemical twice")

	// wstrzyknięcie nauczonej substancji z okna chemikaliów
	var/before = host.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
	horror.inject_learned_reagent(/datum/reagent/medicine/spaceacillin)
	TEST_ASSERT(host.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin) == before + 10, "Injecting a learned chemical did not add 10 units")
	var/found_entry = FALSE
	for(var/list/entry in horror.learned_reagents_ui_data())
		if(entry["path"] == "[/datum/reagent/medicine/spaceacillin]")
			found_entry = TRUE
	TEST_ASSERT(found_entry, "Learned chemical is missing from the chemical menu")

	// limit znanych substancji
	horror.chemicals = 250
	horror.learned_reagents = list(/datum/reagent/water, /datum/reagent/oxygen, /datum/reagent/carbon, /datum/reagent/iron, /datum/reagent/copper)
	TEST_ASSERT(!horror.learn_reagent(/datum/reagent/medicine/morphine), "Horror learned a sixth chemical over the limit")
	TEST_ASSERT(horror.chemicals == 250, "A refused lesson still cost chemicals")
	horror.victim = null

#undef TEST_ASSERT
