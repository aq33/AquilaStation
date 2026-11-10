// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kapłan zaczyna w sutannie i birecie, a oba mają grafikę przedmiotu i noszoną (4 kierunki)
/datum/unit_test/aquila_kaplan

/datum/unit_test/aquila_kaplan/Run()
	var/mob/living/carbon/human/priest = allocate(/mob/living/carbon/human)
	priest.equipOutfit(/datum/outfit/job/chaplain, TRUE)
	TEST_ASSERT(istype(priest.w_uniform, /obj/item/clothing/under/rank/civilian/chaplain/sutanna), "Kapłan nie ma sutanny, tylko [priest.w_uniform?.type]")
	TEST_ASSERT(istype(priest.head, /obj/item/clothing/head/biret), "Kapłan nie ma biretu, tylko [priest.head?.type]")
	for(var/obj/item/clothing/piece as anything in list(priest.w_uniform, priest.head))
		TEST_ASSERT(icon_exists(piece.icon, piece.icon_state), "[piece.type]: brak ikony [piece.icon_state]")
		TEST_ASSERT(icon_exists(piece.worn_icon, piece.icon_state), "[piece.type]: brak noszonej ikony [piece.icon_state]")

#undef TEST_ASSERT
