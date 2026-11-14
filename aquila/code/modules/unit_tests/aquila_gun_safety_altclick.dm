// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test ma własne kopie.
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Alt+klik na trzymanej broni przełącza bezpiecznik; rewolwer zostaje przy kręceniu bębenkiem,
/// a z tłumikiem na zabezpieczonej broni Alt+klik dalej go odkręca
/datum/unit_test/aquila_gun_safety_altclick

/datum/unit_test/aquila_gun_safety_altclick/Run()
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human)
	var/obj/item/gun/ballistic/automatic/pistol/pistol = allocate(/obj/item/gun/ballistic/automatic/pistol)
	TEST_ASSERT(pistol.has_safety && pistol.aq_firemode == AQ_FIREMODE_SAFE, "The pistol does not start on safe")

	// W ręce: Alt+klik odbezpiecza i zabezpiecza
	shooter.put_in_active_hand(pistol)
	pistol.AltClick(shooter)
	TEST_ASSERT(pistol.aq_firemode != AQ_FIREMODE_SAFE, "Alt-click on a held gun did not take the safety off")
	pistol.AltClick(shooter)
	TEST_ASSERT(pistol.aq_firemode == AQ_FIREMODE_SAFE, "Alt-click on a held gun did not put the safety on")

	// Na ziemi: bez zmiany
	shooter.dropItemToGround(pistol)
	pistol.AltClick(shooter)
	TEST_ASSERT(pistol.aq_firemode == AQ_FIREMODE_SAFE, "Alt-click on a gun on the floor toggled the safety")

	// Tłumik na zabezpieczonej broni: Alt+klik go odkręca, bezpiecznik zostaje
	shooter.put_in_active_hand(pistol)
	var/obj/item/suppressor/suppressor = allocate(/obj/item/suppressor)
	pistol.install_suppressor(suppressor)
	pistol.AltClick(shooter)
	TEST_ASSERT(!pistol.suppressed, "Alt-click on a safe suppressed gun did not unscrew the suppressor")
	TEST_ASSERT(pistol.aq_firemode == AQ_FIREMODE_SAFE, "Unscrewing the suppressor toggled the safety")

	// Rewolwer: Alt+klik to dalej bębenek, nie bezpiecznik
	shooter.dropItemToGround(pistol)
	var/obj/item/gun/ballistic/revolver/revolver = allocate(/obj/item/gun/ballistic/revolver)
	shooter.put_in_active_hand(revolver)
	// Samego AltClick() nie wołamy: kręcenie bębenkiem to werb czytający usr, którego w teście nie ma
	TEST_ASSERT(!revolver.aq_alt_click_is_safety(), "Alt-click on a revolver would toggle the safety instead of spinning")
	TEST_ASSERT(!revolver.aq_alt_click_safety(shooter), "Alt-click on a revolver toggled the safety")

#undef TEST_ASSERT
