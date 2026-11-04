// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the oozeling mutation toxin can be mixed and turns a human into an oozeling, the green extract toxin can too
/datum/unit_test/aquila_oozeling_mutation_toxin

/datum/unit_test/aquila_oozeling_mutation_toxin/Run()
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)
	beaker.reagents.add_reagent(/datum/reagent/mutationtoxin/unstable, 5, no_react = TRUE)
	beaker.reagents.add_reagent(/datum/reagent/medicine/calomel, 10, no_react = TRUE)
	beaker.reagents.add_reagent(/datum/reagent/toxin/bad_food, 30, no_react = TRUE)
	beaker.reagents.add_reagent(/datum/reagent/stable_plasma, 5)
	for(var/i in 1 to 60)
		if(!beaker.reagents.is_reacting)
			break
		beaker.reagents.process(1)
	var/made = beaker.reagents.get_reagent_amount(/datum/reagent/mutationtoxin/oozeling)
	TEST_ASSERT(made >= 4, "The oozeling toxin recipe made only [made]u")

	var/mob/living/carbon/human/subject = allocate(/mob/living/carbon/human)
	beaker.reagents.trans_to(subject, 5, transfered_by = subject, method = INJECT)
	for(var/i in 1 to 30)
		subject.reagents.metabolize(subject)
		if(isoozeling(subject))
			break
	TEST_ASSERT(isoozeling(subject), "The oozeling toxin did not turn a human into an oozeling, species: [subject.dna.species.type]")

	// The green slime extract toxin
	var/mob/living/carbon/human/jelly_subject = allocate(/mob/living/carbon/human)
	jelly_subject.reagents.add_reagent(/datum/reagent/mutationtoxin/jelly, 10)
	for(var/i in 1 to 30)
		jelly_subject.reagents.metabolize(jelly_subject)
		if(!ishumanbasic(jelly_subject))
			break
	TEST_ASSERT(isjellyperson(jelly_subject) || isoozeling(jelly_subject), "The green extract toxin did not turn a human into a slime race, species: [jelly_subject.dna.species.type]")

/// AQUILA - the kitchen grinder and the food processor keep the resprited sprite while they work
/datum/unit_test/aquila_kitchen_machine_sprites

/datum/unit_test/aquila_kitchen_machine_sprites/Run()
	var/obj/machinery/processor/processor = allocate(/obj/machinery/processor)
	processor.processing = TRUE
	processor.update_icon()
	TEST_ASSERT_EQUAL(processor.icon_state, "processor1", "The food processor changes its sprite while working")
	processor.processing = FALSE

	var/obj/machinery/reagentgrinder/grinder = allocate(/obj/machinery/reagentgrinder)
	var/had_beaker = !!grinder.beaker
	grinder.operating = TRUE
	grinder.update_icon()
	TEST_ASSERT_EQUAL(grinder.icon_state, had_beaker ? "juicer1" : "juicer0", "The grinder changes its sprite while working")
	grinder.operating = FALSE

/// AQUILA - the automatic crew wake starts at half of the round's players dead, never in tiny rounds
/datum/unit_test/aquila_auto_crew_wake_threshold

/datum/unit_test/aquila_auto_crew_wake_threshold/Run()
	var/datum/auto_crew_wake/auto_wake = new
	TEST_ASSERT(!auto_wake.should_wake(10, 4), "4 of 10 dead already wakes the crew")
	TEST_ASSERT(auto_wake.should_wake(10, 5), "5 of 10 dead does not wake the crew")
	TEST_ASSERT(auto_wake.should_wake(9, 5), "5 of 9 dead does not wake the crew")
	TEST_ASSERT(!auto_wake.should_wake(3, 3), "A round of 3 players should never wake the crew")
	qdel(auto_wake)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
