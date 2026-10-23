// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Porty drobiazgów z Monkestation: loafer, sterty śmieci, dzwonki działów, plastyczne szklanki
/datum/unit_test/monke_misc

/datum/unit_test/monke_misc/Run()
	// Stopnie bochenka według gęstości
	var/obj/item/food/prison_loaf/loaf = allocate(/obj/item/food/prison_loaf)
	loaf.loaf_density = 30
	loaf.condense()
	TEST_ASSERT_EQUAL(loaf.force, 2, "Dense loaf has wrong force")
	TEST_ASSERT_EQUAL(loaf.icon_state, "loaf0", "Dense loaf has wrong icon")
	var/obj/item/food/prison_loaf/molecular = allocate(/obj/item/food/prison_loaf)
	molecular.loaf_density = 1000
	molecular.condense()
	TEST_ASSERT_EQUAL(molecular.icon_state, "loaf2", "Molecular loaf has wrong icon")
	TEST_ASSERT(molecular.reagents.has_reagent(/datum/reagent/consumable/corn_syrup), "Molecular loaf has no corn syrup")

	// Loafer prasuje zawartość holdera w jeden bochenek i przepuszcza go dalej
	var/obj/structure/disposalpipe/loafer/loafer = allocate(/obj/structure/disposalpipe/loafer, run_loc_floor_bottom_left)
	var/obj/structure/disposalholder/holder = allocate(/obj/structure/disposalholder, loafer)
	var/obj/item/wrench/junk = new(holder)
	TEST_ASSERT_EQUAL(loafer.transfer(holder), loafer, "Loafer did not hold the holder while loafing")
	TEST_ASSERT(loafer.is_loafing, "Loafer is not loafing")
	TEST_ASSERT(QDELETED(junk), "Loafed item still exists")
	TEST_ASSERT_EQUAL(loafer.transfer(holder), loafer, "Loafer let the holder through mid-loaf")
	var/obj/item/food/prison_loaf/made = locate() in loafer
	TEST_ASSERT(made, "Loafer did not make a loaf")
	loafer.finish_loaf(holder, made)
	TEST_ASSERT_EQUAL(made.loc, holder, "Loaf was not put into the holder")
	TEST_ASSERT(holder in loafer.finished_holders, "Loafer would loaf its own loaf again")
	// Holder usuwamy przed rurą, bo Destroy() rury z holderem w środku wyrzuca go i zrywa płytkę podłogi
	qdel(holder)

	// Sterta śmieci: chowanie przedmiotu i losowy wygląd
	var/obj/structure/trash_pile/pile = allocate(/obj/structure/trash_pile, run_loc_floor_bottom_left)
	TEST_ASSERT(pile.icon_state != "randompile", "Trash pile kept the mapping icon")
	TEST_ASSERT(icon_exists(pile.icon, pile.icon_state), "Trash pile picked a missing icon state")
	var/obj/item/stack/sheet/cardboard/hidden = allocate(/obj/item/stack/sheet/cardboard)
	hidden.forceMove(pile)
	qdel(pile)
	TEST_ASSERT(!QDELETED(hidden) && isturf(hidden.loc), "Destroyed trash pile did not drop its contents")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Dzwonek działu: radio na kanale działu, bez możliwości odkręcenia
	var/obj/structure/desk_bell/departmental/medical/bell = allocate(/obj/structure/desk_bell/departmental/medical, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(bell.radio.frequency, FREQ_MEDICAL, "Medical bell radio is on the wrong frequency")
	TEST_ASSERT(bell.anchored, "Department bell is not anchored")
	TEST_ASSERT(bell.bell_location, "Department bell has no location for its announcement")
	TEST_ASSERT(bell.ring_bell(user), "Department bell did not ring")
	TEST_ASSERT(!COOLDOWN_FINISHED(bell, announce_cooldown), "Department bell did not start the announcement cooldown")

	// Plastyczna szklanka: dekoracja trafia na swoją warstwę, druga na tę samą warstwę nie wchodzi
	var/obj/item/reagent_containers/food/drinks/modglass/glass = allocate(/obj/item/reagent_containers/food/drinks/modglass)
	var/obj/item/garnish/lime/lime = allocate(/obj/item/garnish/lime)
	glass.attackby(lime, user)
	TEST_ASSERT(QDELETED(lime), "Garnish was not used up")
	TEST_ASSERT_EQUAL(glass.garnishes["4"], "lime", "Lime is not on the right side of the glass")
	var/obj/item/garnish/lemon/lemon = allocate(/obj/item/garnish/lemon)
	glass.attackby(lemon, user)
	TEST_ASSERT(!QDELETED(lemon), "Second garnish took an occupied slot")
	SEND_SIGNAL(glass, COMSIG_COMPONENT_CLEAN_ACT, 1)
	TEST_ASSERT(!length(glass.garnishes), "Washing did not remove the garnishes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
