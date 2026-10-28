// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wypróżnienie na miejscu po kliknięciu w alert: nago bez smrodu, w ubraniu wykrywamy spodnie
/datum/unit_test/aquila_defecate_here

/datum/unit_test/aquila_defecate_here/Run()
	var/mob/living/carbon/human/pooper = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!pooper.is_wearing_pants(), "A naked human counts as wearing pants")

	pooper.set_defecation(DEFECATION_SHIT_YOURSELF)
	var/hygiene_before = pooper.hygiene
	pooper.finish_defecate_here(FALSE)
	TEST_ASSERT(pooper.defecation == DEFECATION_NONE, "Defecating did not reset the need")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/feces) in get_turf(pooper), "Defecating naked left nothing on the floor")
	TEST_ASSERT(pooper.hygiene == hygiene_before, "Defecating naked made the human stink")

	pooper.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(pooper), ITEM_SLOT_ICLOTHING)
	TEST_ASSERT(pooper.is_wearing_pants(), "A human in a jumpsuit does not count as wearing pants")

#undef TEST_ASSERT
