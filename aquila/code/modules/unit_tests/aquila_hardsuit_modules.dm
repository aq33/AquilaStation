// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - moduły w hardsuicie (zamiast MODsuitów): instalacja, praca na noszącym, pobór prądu, odinstalowanie,
/// oddychanie z wbudowanej butli przez hełm i sprzątanie po zdjęciu i usunięciu kombinezonu
/datum/unit_test/aquila_hardsuit_modules

/datum/unit_test/aquila_hardsuit_modules/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/suit/space/hardsuit/suit = allocate(/obj/item/clothing/suit/space/hardsuit)
	TEST_ASSERT(suit.core, "A hardsuit has no power core")
	TEST_ASSERT(suit.get_charge() > 0, "A new hardsuit has an empty or missing cell")
	TEST_ASSERT(suit.integrated_tank, "A hardsuit has no integrated oxygen tank")

	// Instalacja: moduł widzi kombinezon jako swoje `mod`
	var/obj/item/mod/module/magboot/magboot = allocate(/obj/item/mod/module/magboot)
	TEST_ASSERT(suit.install(magboot), "install() refused a magboot module")
	TEST_ASSERT_EQUAL(magboot.mod, suit, "Installed module has the wrong mod")
	TEST_ASSERT(magboot in suit.modules, "Installed module is missing from the module list")
	TEST_ASSERT_EQUAL(magboot.loc, suit, "Installed module is not inside the suit")
	var/obj/item/mod/module/storage/storage = allocate(/obj/item/mod/module/storage)
	TEST_ASSERT(suit.install(storage), "install() refused a storage module")

	// Założenie: on_equip i aktywacja części
	TEST_ASSERT(wearer.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "The hardsuit could not be put on")
	TEST_ASSERT_EQUAL(suit.wearer, wearer, "Worn hardsuit has the wrong wearer")
	TEST_ASSERT(suit.active, "Worn hardsuit is not active")
	TEST_ASSERT(magboot.part_activated, "Module parts were not activated on equip")

	// Aktywny moduł działa i pobiera prąd
	magboot.on_select()
	TEST_ASSERT(magboot.active, "Magboot module did not activate")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_NEGATES_GRAVITY), "Active magboot module gives no gravity trait")
	var/charge_before = suit.get_charge()
	suit.process(1)
	TEST_ASSERT(suit.get_charge() < charge_before, "Charge did not drain with an active module ([charge_before] -> [suit.get_charge()])")

	// Wbudowana butla: hełm działa jak maska
	suit.ToggleHelmet()
	TEST_ASSERT_EQUAL(wearer.head, suit.helmet, "Helmet was not deployed")
	TEST_ASSERT(suit.helmet.clothing_flags & HEADINTERNALS, "Hardsuit helmet does not work as a breathing mask")
	suit.toggle_integrated_tank(wearer)
	TEST_ASSERT_EQUAL(wearer.internal, suit.integrated_tank, "Wearer does not breathe from the integrated tank")
	var/datum/gas_mixture/breath = wearer.get_breath_from_internal(BREATH_VOLUME)
	TEST_ASSERT(breath && breath.get_moles(GAS_O2) > 0, "No oxygen came from the integrated tank")
	TEST_ASSERT_EQUAL(wearer.internal, suit.integrated_tank, "Internals were dropped although the tank is in the worn suit")
	suit.RemoveHelmet()
	wearer.get_breath_from_internal(BREATH_VOLUME)
	TEST_ASSERT(!wearer.internal, "Wearer still breathes from the tank without a helmet or mask")

	// Odinstalowanie zdejmuje efekty modułu
	suit.uninstall(magboot)
	TEST_ASSERT(!magboot.mod, "Uninstalled module still points at the suit")
	TEST_ASSERT(!(magboot in suit.modules), "Uninstalled module is still in the module list")
	TEST_ASSERT(!magboot.active, "Uninstalled module is still active")
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_NEGATES_GRAVITY), "Uninstalled magboot module left its trait")
	TEST_ASSERT_EQUAL(suit.complexity, storage.complexity, "Complexity was not lowered on uninstall")

	// Zdjęcie i usunięcie kombinezonu nie zostawia referencji
	suit.ToggleHelmet()
	suit.toggle_integrated_tank(wearer)
	TEST_ASSERT_EQUAL(wearer.internal, suit.integrated_tank, "Integrated tank could not be reopened")
	wearer.dropItemToGround(suit)
	TEST_ASSERT(!suit.wearer, "Dropped hardsuit still has a wearer")
	TEST_ASSERT(!suit.active, "Dropped hardsuit is still active")
	TEST_ASSERT(!wearer.internal, "Wearer still breathes from the tank of a dropped suit")
	TEST_ASSERT(!wearer.head, "Helmet stayed on the head after the suit was dropped")
	qdel(suit)
	TEST_ASSERT(QDELETED(storage), "Module inside a deleted suit was not deleted")
	TEST_ASSERT(!storage.mod, "Module of a deleted suit still points at it")
	TEST_ASSERT(!suit.core, "Deleted suit still holds its core")
	TEST_ASSERT(!suit.integrated_tank, "Deleted suit still holds its tank")

/// AQUILA - każdy gotowy hardsuit (dawne MODsuity) tworzy i instaluje wszystkie swoje moduły startowe
/datum/unit_test/aquila_hardsuit_variants

/datum/unit_test/aquila_hardsuit_variants/Run()
	for(var/obj/item/clothing/suit/space/hardsuit/suit_type as anything in typesof(/obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/suit = allocate(suit_type)
		if(!length(suit.initial_modules))
			continue
		TEST_ASSERT_EQUAL(length(suit.modules), length(suit.initial_modules), "[suit_type] did not install all of its starting modules")
		for(var/module_type in suit.initial_modules)
			var/obj/item/mod/module/module = locate(module_type) in suit.modules
			TEST_ASSERT(module, "[suit_type] is missing starting module [module_type]")
			TEST_ASSERT_EQUAL(module.mod, suit, "[module_type] in [suit_type] has the wrong mod")
		if(ispath(suit.initial_core))
			TEST_ASSERT(suit.get_charge() > 0, "[suit_type] has starting modules but no charge")
		qdel(suit)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
