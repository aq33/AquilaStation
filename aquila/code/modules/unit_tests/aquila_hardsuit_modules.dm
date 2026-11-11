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

/// AQUILA - regresje z review aq33/AquilaStation#583: blokada DNA, dolewanie butli, moduły bez prądu, zniszczenie kombinezonu,
/// wspólna lista allowed ochrony, butla w hardsuicie ERT, wizjer Syndykatu
/datum/unit_test/aquila_hardsuit_review_fixes

/datum/unit_test/aquila_hardsuit_review_fixes/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)

	// Blokada DNA nie pozwala obcemu wyjmować ani wkładać części
	var/obj/item/clothing/suit/space/hardsuit/locked_suit = allocate(/obj/item/clothing/suit/space/hardsuit, run_loc_floor_bottom_left)
	var/obj/item/mod/module/dna_lock/lock = allocate(/obj/item/mod/module/dna_lock)
	TEST_ASSERT(locked_suit.install(lock), "install() refused a DNA lock")
	lock.dna = owner.dna.unique_enzymes
	TEST_ASSERT(locked_suit.parts_locked(stranger), "A stranger can take parts out of a DNA-locked hardsuit")
	TEST_ASSERT(!locked_suit.parts_locked(owner), "The owner cannot take parts out of their own DNA-locked hardsuit")

	// Wzmocniona blokada (ninja) nie zabija kogoś, komu kombinezon założył ktoś inny; kombinezon czeka na uruchomienie
	var/obj/item/clothing/suit/space/hardsuit/ninja_suit = allocate(/obj/item/clothing/suit/space/hardsuit, run_loc_floor_bottom_left)
	var/obj/item/mod/module/dna_lock/reinforced/ninja_lock = allocate(/obj/item/mod/module/dna_lock/reinforced)
	TEST_ASSERT(ninja_suit.install(ninja_lock), "install() refused a reinforced DNA lock")
	ninja_lock.dna = owner.dna.unique_enzymes
	var/datum/strippable_item/suit_slot = GLOB.strippable_human_items[STRIPPABLE_ITEM_SUIT]
	suit_slot.finish_equip(stranger, ninja_suit, owner)
	TEST_ASSERT(!QDELETED(stranger), "Dressing someone in a DNA-locked ninja suit gibbed them")
	TEST_ASSERT_EQUAL(stranger.wear_suit, ninja_suit, "Strip menu did not put the suit on")
	TEST_ASSERT(!ninja_suit.active, "A suit put on by someone else started without the wearer")
	stranger.dropItemToGround(ninja_suit)

	// Uruchomienie przez noszącego sprawdza zwykłą blokadę
	suit_slot.finish_equip(stranger, locked_suit, owner)
	TEST_ASSERT(!locked_suit.try_activate(stranger), "A stranger started a DNA-locked hardsuit")
	stranger.dropItemToGround(locked_suit)

	// Dolewanie: wyrównanie ciśnień, najwyżej do pełnej butli, a usunięta butla nie zostaje w kombinezonie
	var/obj/item/clothing/suit/space/hardsuit/tank_suit = allocate(/obj/item/clothing/suit/space/hardsuit, run_loc_floor_bottom_left)
	var/datum/gas_mixture/integrated_air = tank_suit.integrated_tank.return_air()
	integrated_air.set_moles(GAS_O2, integrated_air.get_moles(GAS_O2) * 0.5)
	var/obj/item/tank/internals/oxygen/source = allocate(/obj/item/tank/internals/oxygen, run_loc_floor_bottom_left)
	var/datum/gas_mixture/source_air = source.return_air()
	source_air.set_moles(GAS_O2, (10 * ONE_ATMOSPHERE) * source_air.return_volume() / (R_IDEAL_GAS_EQUATION * source_air.return_temperature()))
	tank_suit.fill_integrated_tank(source, owner)
	var/filled_pressure = integrated_air.return_pressure()
	TEST_ASSERT(filled_pressure <= 6 * ONE_ATMOSPHERE + 1, "Topping up overfilled the integrated tank to [filled_pressure] kPa")
	TEST_ASSERT(filled_pressure >= 6 * ONE_ATMOSPHERE - 1, "Topping up from a 10 atm tank did not fill the integrated tank ([filled_pressure] kPa)")
	qdel(tank_suit.integrated_tank)
	TEST_ASSERT(!tank_suit.integrated_tank, "Deleted integrated tank is still referenced by the suit")

	// Pasywne moduły nie działają bez rdzenia
	var/obj/item/clothing/suit/space/hardsuit/medical/loaded/medical = allocate(/obj/item/clothing/suit/space/hardsuit/medical/loaded, run_loc_floor_bottom_left)
	TEST_ASSERT(owner.equip_to_slot_if_possible(medical, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "The medical hardsuit could not be put on")
	TEST_ASSERT(HAS_TRAIT(owner, TRAIT_QUICK_CARRY), "Powered medical hardsuit gives no quick carry")
	owner.dropItemToGround(medical)
	qdel(medical.core)
	TEST_ASSERT(owner.equip_to_slot_if_possible(medical, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "The medical hardsuit could not be put on again")
	TEST_ASSERT(!HAS_TRAIT(owner, TRAIT_QUICK_CARRY), "Passive module works in a hardsuit without a core")

	// Usunięty noszony kombinezon zdejmuje alert ładunku
	owner.dropItemToGround(medical)
	var/obj/item/clothing/suit/space/hardsuit/drained = allocate(/obj/item/clothing/suit/space/hardsuit, run_loc_floor_bottom_left)
	TEST_ASSERT(drained.install(allocate(/obj/item/mod/module/flashlight)), "install() refused a flashlight module")
	var/obj/item/stock_parts/cell/cell = drained.get_cell()
	cell.charge = 0
	TEST_ASSERT(owner.equip_to_slot_if_possible(drained, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "The drained hardsuit could not be put on")
	TEST_ASSERT(owner.alerts["mod_charge"], "Empty cell gives no charge alert")
	qdel(drained)
	TEST_ASSERT(!owner.alerts["mod_charge"], "Charge alert stayed after the worn hardsuit was deleted")

	// Zniszczenie kombinezonu wyrzuca zawartość schowka
	var/obj/item/clothing/suit/space/hardsuit/stash = allocate(/obj/item/clothing/suit/space/hardsuit, run_loc_floor_bottom_left)
	TEST_ASSERT(stash.install(allocate(/obj/item/mod/module/storage)), "install() refused a storage module")
	var/obj/item/crowbar/stored = allocate(/obj/item/crowbar)
	TEST_ASSERT(SEND_SIGNAL(stash, COMSIG_TRY_STORAGE_INSERT, stored, null, TRUE, TRUE), "Could not put an item into the suit storage")
	stash.obj_destruction("melee")
	TEST_ASSERT(!QDELETED(stored), "Item in the storage of a destroyed hardsuit was deleted")
	TEST_ASSERT(isturf(stored.loc), "Item in the storage of a destroyed hardsuit did not drop to the floor")

	// Uprząż magnetyczna nie zmienia wspólnej listy allowed hardsuitów ochrony
	var/list/allowed_before = GLOB.security_hardsuit_allowed.Copy()
	var/obj/item/clothing/suit/space/hardsuit/security/head_of_security/loaded/hos = allocate(/obj/item/clothing/suit/space/hardsuit/security/head_of_security/loaded)
	var/obj/item/mod/module/magnetic_harness/harness = locate() in hos.modules
	TEST_ASSERT(harness, "HoS hardsuit has no magnetic harness")
	hos.uninstall(harness)
	TEST_ASSERT_EQUAL(length(GLOB.security_hardsuit_allowed), length(allowed_before), "Removing the magnetic harness changed the shared security allowed list")
	for(var/allowed_type in allowed_before)
		TEST_ASSERT(allowed_type in GLOB.security_hardsuit_allowed, "Removing the magnetic harness took [allowed_type] off the shared security allowed list")

	// Butla w hardsuicie ERT (własne ui_action_click)
	var/obj/item/clothing/suit/space/hardsuit/ert/ert = allocate(/obj/item/clothing/suit/space/hardsuit/ert, run_loc_floor_bottom_left)
	TEST_ASSERT(owner.equip_to_slot_if_possible(ert, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "The ERT hardsuit could not be put on")
	ert.ToggleHelmet()
	var/datum/action/item_action/hardsuit_tank/tank_action = locate() in ert.actions
	TEST_ASSERT(tank_action, "ERT hardsuit has no integrated tank action")
	ert.ui_action_click(owner, tank_action)
	TEST_ASSERT_EQUAL(owner.internal, ert.integrated_tank, "Integrated tank action does nothing on an ERT hardsuit")
	owner.dropItemToGround(ert)

	// Uniesiony wizjer Syndykatu nie podaje powietrza
	var/obj/item/clothing/head/helmet/space/hardsuit/syndi/syndi_helmet = allocate(/obj/item/clothing/head/helmet/space/hardsuit/syndi)
	TEST_ASSERT(syndi_helmet.clothing_flags & HEADINTERNALS, "Closed syndicate helmet does not work as a breathing mask")
	syndi_helmet.activate_combat_mode()
	TEST_ASSERT(!(syndi_helmet.clothing_flags & HEADINTERNALS), "Syndicate helmet with the visor up still feeds internals")
	syndi_helmet.activate_space_mode()
	TEST_ASSERT(syndi_helmet.clothing_flags & HEADINTERNALS, "Closing the syndicate visor did not restore internals")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
