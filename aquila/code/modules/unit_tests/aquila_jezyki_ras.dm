// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - tongues allow the species' own language and don't change the shared base list
/datum/unit_test/aquila_jezyki_ras

/datum/unit_test/aquila_jezyki_ras/Run()
	var/obj/item/organ/tongue/ethereal/ethereal_tongue = allocate(/obj/item/organ/tongue/ethereal)
	TEST_ASSERT(ethereal_tongue.could_speak_language(/datum/language/voltaic), "Ethereal tongue can't speak Voltaic")

	var/obj/item/organ/tongue/egg/egg_tongue = allocate(/obj/item/organ/tongue/egg)
	TEST_ASSERT(egg_tongue.could_speak_language(/datum/language/ovarian), "Egg tongue can't speak Ovarian")
	TEST_ASSERT(egg_tongue.could_speak_language(/datum/language/common), "Egg tongue can't speak Common")
	TEST_ASSERT(!egg_tongue.could_speak_language(/datum/language/voltaic), "Egg tongue got Voltaic from the ethereal tongue")

	var/obj/item/organ/tongue/squid/squid_tongue = allocate(/obj/item/organ/tongue/squid)
	TEST_ASSERT(squid_tongue.could_speak_language(/datum/language/rlyehian), "Squid tongue can't speak R'lyehian")

	var/obj/item/organ/tongue/human_tongue = allocate(/obj/item/organ/tongue)
	TEST_ASSERT(!human_tongue.could_speak_language(/datum/language/ovarian), "Every tongue can speak Ovarian")
	TEST_ASSERT(!human_tongue.could_speak_language(/datum/language/voltaic), "Every tongue can speak Voltaic")
	TEST_ASSERT(human_tongue.could_speak_language(/datum/language/vampiric), "Tongue can't speak the vampire language")
	TEST_ASSERT(human_tongue.could_speak_language(/datum/language/darkspawn), "Tongue can't speak the darkspawn language")

#undef TEST_ASSERT
