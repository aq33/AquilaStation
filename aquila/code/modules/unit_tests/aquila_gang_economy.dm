// Makra asercji z core są #undef na końcu code/modules/unit_tests/_unit_tests.dm, test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - ekonomia gangów jak w Goonie: punkty członków, premia dla zarabiającego, raport bez podwajania,
/// skup narkotyków z malejącym mnożnikiem, teren ze znaku, pranie gotówki, skup broni i przejęcie dowodzenia
/datum/unit_test/aquila_gang_economy

/datum/unit_test/aquila_gang_economy/Run()
	var/turf/open/corner = run_loc_floor_bottom_left
	var/turf/open/next_to_corner = locate(corner.x + 1, corner.y, corner.z)
	var/mob/living/carbon/human/boss = allocate(/mob/living/carbon/human, corner)
	var/mob/living/carbon/human/gangster = allocate(/mob/living/carbon/human, next_to_corner)
	boss.mind_initialize()
	gangster.mind_initialize()
	var/datum/team/gang/clandestine/G = new
	boss.mind.add_antag_datum(/datum/antagonist/gang/boss, G)
	gangster.mind.add_antag_datum(/datum/antagonist/gang, G)

	TEST_ASSERT_EQUAL(G.get_points(boss.mind), GANG_START_POINTS, "Boss should start with the starting points")
	TEST_ASSERT_EQUAL(G.get_points(gangster.mind), GANG_START_POINTS, "Gangster should start with the starting points")

	// Każdy członek dostaje przychód, a zarabiający 25% więcej
	G.add_income(100, GANG_SCORE_GUN, gangster.mind)
	TEST_ASSERT_EQUAL(G.get_points(boss.mind), GANG_START_POINTS + 100, "Every member should get the full income")
	TEST_ASSERT_EQUAL(G.get_points(gangster.mind), GANG_START_POINTS + 125, "The earner should get a 25% bonus")
	TEST_ASSERT_EQUAL(G.total_score(), 100, "Income should count towards the gang score")

	// Regresja: raport co 3 minuty podwajał wpływy (update_influence zwracał wpływy razem z przyrostem)
	var/points_before = G.get_points(boss.mind)
	G.handle_territories()
	G.handle_territories()
	TEST_ASSERT_EQUAL(G.get_points(boss.mind), points_before, "The status report must not add points")
	TEST_ASSERT_EQUAL(G.total_score(), 100, "The status report must not change the score")

	// Narkotyki: pierwsze 300 j. ×3, potem mnożnik maleje do zera przy limicie
	TEST_ASSERT_EQUAL(G.sell_drug(/datum/reagent/drug/methamphetamine, GANG_DRUG_BONUS_UNITS), round(GANG_DRUG_BONUS_UNITS * 1.5 * 3), "The first units of a drug should count triple")
	var/later = G.sell_drug(/datum/reagent/drug/methamphetamine, GANG_DRUG_UNIT_LIMIT - GANG_DRUG_BONUS_UNITS)
	TEST_ASSERT(later > 0 && later < (GANG_DRUG_UNIT_LIMIT - GANG_DRUG_BONUS_UNITS) * 1.5, "Units after the bonus should be worth less than full price, got [later]")
	TEST_ASSERT_EQUAL(G.sell_drug(/datum/reagent/drug/methamphetamine, 100), 0, "A drug past the limit should not be bought")
	TEST_ASSERT_EQUAL(G.sell_drug(/datum/reagent/water, 100), 0, "Water is not a drug")
	// Tuż przed limitem: jednostka warta mniej niż punkt nie jest zapisywana jako sprzedana
	G.drug_units_sold[/datum/reagent/drug/space_drugs] = GANG_DRUG_UNIT_LIMIT - 1
	TEST_ASSERT_EQUAL(G.sell_drug(/datum/reagent/drug/space_drugs, 1), 0, "The last unit before the limit is worth less than a point")
	TEST_ASSERT_EQUAL(G.drug_units_left(/datum/reagent/drug/space_drugs), 1, "A sale worth no points must not use up the limit")

	// Znak zajmuje teren i daje punkty za postawienie (pokój testowy udaje obszar stacji, który da się zająć)
	var/area/test_area = get_area(corner)
	var/old_area_flags = test_area.area_flags
	test_area.area_flags |= VALID_TERRITORY
	TEST_ASSERT(aq_gang_claimable_turf(corner), "The test room floor should be claimable once its area is valid territory")
	points_before = G.get_points(boss.mind)
	var/obj/effect/decal/gang/tag = new(corner, G, "graffiti", 0, gangster)
	TEST_ASSERT(G.claimed_tiles > 0, "A gang tag should claim tiles around it")
	TEST_ASSERT(G.owns_turf(corner), "The tagged turf should belong to the gang")
	TEST_ASSERT_EQUAL(G.get_points(boss.mind), points_before + GANG_TAG_POINTS, "Placing a tag should give points")
	qdel(tag)
	TEST_ASSERT_EQUAL(G.claimed_tiles, 0, "Removing the only tag should free the territory")
	TEST_ASSERT(!G.owns_turf(corner), "The turf should be free after the tag is gone")

	// Szafka: pranie gotówki i skup broni
	var/turf/open/locker_turf = locate(corner.x + 2, corner.y + 2, corner.z)
	var/obj/structure/gang_locker/locker = new(locker_turf, G)
	TEST_ASSERT_EQUAL(G.locker, locker, "The gang should know its locker")
	TEST_ASSERT(G.owns_turf(locker_turf), "The locker should claim territory")
	// Gotówka ponad limit prania zostaje u gracza
	locker.cash = GANG_LOCKER_CASH_CAP - 100
	var/obj/item/holochip/too_much = new(gangster.loc, 500)
	gangster.put_in_hands(too_much)
	TEST_ASSERT(locker.sell(too_much, gangster), "The locker should answer a cash deposit")
	TEST_ASSERT(!QDELETED(too_much) && too_much.loc == gangster, "Cash over the laundering cap should stay with the player")
	TEST_ASSERT_EQUAL(locker.cash, GANG_LOCKER_CASH_CAP - 100, "Cash over the cap must not be accepted")
	qdel(too_much)
	locker.cash = 1000
	var/score_before = G.total_score()
	locker.process(3)
	TEST_ASSERT(locker.cash < 1000, "The locker should launder cash")
	TEST_ASSERT(G.total_score() > score_before, "Laundered cash should give points")
	var/obj/item/gun/ballistic/automatic/pistol/gun = new(gangster.loc)
	gangster.put_in_hands(gun)
	points_before = G.get_points(boss.mind)
	TEST_ASSERT(locker.sell(gun, gangster), "The locker should buy guns")
	TEST_ASSERT_EQUAL(G.get_points(boss.mind), points_before + GANG_GUN_POINTS, "A sold gun should give points to every member")

	// Przejęcie: z szafką dopiero po 5 minutach od śmierci szefa
	TEST_ASSERT(G.is_boss(boss.mind), "The boss should lead the gang")
	TEST_ASSERT(!G.takeover_available(), "No takeover while the boss is alive")
	boss.death()
	TEST_ASSERT(!G.takeover_available(), "With a locker the takeover waits for the delay")
	G.boss_dead_since = world.time - GANG_TAKEOVER_DELAY
	TEST_ASSERT(G.takeover_available(), "After the delay the gang can take over")
	TEST_ASSERT(G.take_over(gangster.mind), "The takeover should succeed")
	TEST_ASSERT(G.is_boss(gangster.mind), "The claimant should become the boss")
	TEST_ASSERT(!G.is_boss(boss.mind), "The old boss should be demoted")
	TEST_ASSERT(boss.mind.has_antag_datum(/datum/antagonist/gang), "The old boss should stay in the gang")

	qdel(locker)
	test_area.area_flags = old_area_flags
	boss.mind.remove_antag_datum(/datum/antagonist/gang)
	gangster.mind.remove_antag_datum(/datum/antagonist/gang)
	qdel(G)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
