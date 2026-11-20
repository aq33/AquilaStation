// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - granat dymny zniszczony wybuchem czeka w prime() na usunięcie; kolejne trafienie z wybuchu nie może wtedy
/// zgłaszać obrażeń przy zerowej wytrzymałości (runtime ze stack_trace kończy test porażką)
/datum/unit_test/grenade_destroyed_explosion

/datum/unit_test/grenade_destroyed_explosion/Run()
	var/obj/item/grenade/smokebomb/grenade = allocate(/obj/item/grenade/smokebomb, run_loc_floor_bottom_left)
	// Stan granatu w trakcie prime() po zniszczeniu: zero wytrzymałości, jeszcze nie usunięty
	grenade.obj_integrity = 0
	grenade.ex_act(EXPLODE_LIGHT)
	grenade.ex_act(EXPLODE_HEAVY)
	TEST_ASSERT(!QDELETED(grenade), "A grenade waiting to go off was deleted by another explosion hit")

#undef TEST_ASSERT
