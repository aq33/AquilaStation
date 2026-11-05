// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Kliknięcie pustą ręką w kafel obok (albo w leżący na nim katwalk) przesuwa ciągnięty przedmiot na ten kafel, z combat mode i bez
/datum/unit_test/pull_click_moves_pulled

/datum/unit_test/pull_click_moves_pulled/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/turf/start = get_turf(user)
	var/obj/structure/lattice/catwalk/over/ship/catwalk
	for(var/pass in 1 to 3)
		var/combat = pass == 2
		user.set_combat_mode(combat, silent = TRUE)
		if(pass == 3)
			catwalk = allocate(/obj/structure/lattice/catwalk/over/ship, get_step(start, NORTH))
		var/obj/item/crowbar/pulled = allocate(/obj/item/crowbar, get_step(start, EAST))
		user.start_pulling(pulled)
		TEST_ASSERT_EQUAL(user.pulling, pulled, "Pulling did not start (combat mode [combat])")
		var/turf/target = get_step(start, NORTH)
		user.next_click = 0
		user.next_move = 0
		user.ClickOn(catwalk || target, "icon-x=16;icon-y=16;left=1;button=left")
		TEST_ASSERT_EQUAL(pulled.loc, target, "Clicking [catwalk ? "a catwalk" : "a turf"] next to you did not move the pulled item there (combat mode [combat])")
		user.stop_pulling()
		qdel(pulled)

#undef TEST_ASSERT_EQUAL
