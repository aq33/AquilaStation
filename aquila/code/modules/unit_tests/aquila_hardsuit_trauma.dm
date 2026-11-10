// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - hardsuity Orlenu i zespołu urazowego: każdy stan (przedmiot, noszony, hełm włączony i wyłączony) ma grafikę,
/// szafa lekarzy wydaje skafander zespołu urazowego, a włączenie lampy hełmu przełącza go na istniejący stan
/datum/unit_test/aquila_hardsuit_trauma

/datum/unit_test/aquila_hardsuit_trauma/Run()
	var/list/suit_types = list(
		/obj/item/clothing/suit/space/hardsuit/engine,
		/obj/item/clothing/suit/space/hardsuit/engine/atmos,
		/obj/item/clothing/suit/space/hardsuit/engine/elite,
		/obj/item/clothing/suit/space/hardsuit/medical/cmo,
		/obj/item/clothing/suit/space/hardsuit/medical/trauma,
	)
	for(var/suit_type in suit_types)
		var/obj/item/clothing/suit/space/hardsuit/suit = allocate(suit_type)
		TEST_ASSERT(icon_exists(suit.icon, suit.icon_state), "[suit_type]: brak stanu [suit.icon_state] w [suit.icon]")
		var/worn = suit.worn_icon || 'icons/mob/clothing/suit.dmi'
		TEST_ASSERT(icon_exists(worn, suit.icon_state), "[suit_type]: brak noszonego stanu [suit.icon_state] w [worn]")
		// Nowe sprite'y nie mają wersji digitigrade, więc skafander nie może jej deklarować
		TEST_ASSERT(!(suit.supports_variations & DIGITIGRADE_VARIATION), "[suit_type] deklaruje wersję digitigrade, której arkusz nie ma")
		var/helmet_type = suit.helmettype
		var/obj/item/clothing/head/helmet/space/hardsuit/helmet = allocate(helmet_type)
		var/helmet_worn = helmet.worn_icon || 'icons/mob/clothing/head.dmi'
		for(var/on in list(0, 1))
			var/state = "[helmet.basestate][on]-[helmet.hardsuit_type]"
			TEST_ASSERT(icon_exists(helmet.icon, state), "[helmet_type]: brak stanu [state] w [helmet.icon]")
			TEST_ASSERT(icon_exists(helmet_worn, state), "[helmet_type]: brak noszonego stanu [state] w [helmet_worn]")

	var/obj/machinery/suit_storage_unit/medical/trauma/unit = allocate(/obj/machinery/suit_storage_unit/medical/trauma)
	TEST_ASSERT(istype(unit.suit, /obj/item/clothing/suit/space/hardsuit/medical/trauma), "Szafa zespołu urazowego nie ma skafandra zespołu urazowego, tylko [unit.suit?.type]")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/head/helmet/space/hardsuit/medical/trauma/trauma_helmet = allocate(/obj/item/clothing/head/helmet/space/hardsuit/medical/trauma)
	trauma_helmet.attack_self(user)
	TEST_ASSERT_EQUAL(trauma_helmet.icon_state, "hardsuit1-trauma", "Włączenie lampy hełmu zespołu urazowego")
	trauma_helmet.attack_self(user)
	TEST_ASSERT_EQUAL(trauma_helmet.icon_state, "hardsuit0-trauma", "Wyłączenie lampy hełmu zespołu urazowego")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
