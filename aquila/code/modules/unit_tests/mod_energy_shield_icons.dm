// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every MOD energy shield draws a sprite that exists; a missing state shows a random sprite with the walk animation
/datum/unit_test/mod_energy_shield_icons

/datum/unit_test/mod_energy_shield_icons/Run()
	for(var/obj/item/mod/module/energy_shield/shield_type as anything in typesof(/obj/item/mod/module/energy_shield))
		var/icon_file = initial(shield_type.shield_icon_file)
		var/icon_state = initial(shield_type.shield_icon)
		TEST_ASSERT(icon_exists(icon_file, icon_state), "[shield_type] uses missing shield sprite \"[icon_state]\" in [icon_file]")

#undef TEST_ASSERT
