// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - autopsy operation and scanner (tgstation coroner), on the new surgery skeleton
/datum/unit_test/aquila_autopsy

/datum/unit_test/aquila_autopsy/Run()
	var/mob/living/carbon/human/coroner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/obj/item/autopsy_scanner/scanner = allocate(/obj/item/autopsy_scanner)
	var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
	var/datum/surgery_operation/limb/autopsy/autopsy = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/autopsy]
	TEST_ASSERT(autopsy, "No autopsy operation")
	TEST_ASSERT(!autopsy.state_check(chest), "Autopsy can be done on a living patient")

	body.reagents.add_reagent(/datum/reagent/toxin, 10)
	body.death()
	TEST_ASSERT(autopsy.state_check(chest), "Autopsy cannot be done on a body")
	TEST_ASSERT(!autopsy.state_check(body.get_bodypart(BODY_ZONE_HEAD)), "Autopsy can be done on the head")

	autopsy.on_success(chest, coroner, scanner, list())
	var/obj/item/paper/report = locate() in coroner.held_items
	TEST_ASSERT(report, "Autopsy printed no report")
	TEST_ASSERT(!autopsy.state_check(chest), "The same body can be autopsied twice")

	body.revive(full_heal = TRUE, admin_revive = TRUE)
	body.death()
	TEST_ASSERT(autopsy.state_check(chest), "A revived and dead again body cannot be autopsied")

#undef TEST_ASSERT
