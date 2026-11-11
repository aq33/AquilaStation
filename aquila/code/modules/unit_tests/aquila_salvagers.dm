// Makra asercji z core są #undef na końcu code/modules/unit_tests/_unit_tests.dm, test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - złomiarze: reklamator rozbiera maszyny (bez rur i rzeczy niezniszczalnych), skup liczy płytki i części,
/// szablon statku się wczytuje, a złomiarz dostaje drużynę z celem „sprzedajcie złom”
/datum/unit_test/aquila_salvagers

/datum/unit_test/aquila_salvagers/Run()
	var/turf/open/corner = run_loc_floor_bottom_left
	var/turf/open/east = locate(corner.x + 1, corner.y, corner.z)
	var/turf/open/north = locate(corner.x, corner.y + 1, corner.z)

	var/obj/item/salvage_reclaimer/reclaimer = allocate(/obj/item/salvage_reclaimer)
	var/obj/machinery/recharger/lathe = allocate(/obj/machinery/recharger, east)
	TEST_ASSERT_EQUAL(reclaimer.salvage_time(lathe), 10 SECONDS, "A machine should take 10 seconds to salvage")
	lathe.resistance_flags |= INDESTRUCTIBLE
	TEST_ASSERT_EQUAL(reclaimer.salvage_time(lathe), 0, "Indestructible machines must not be salvaged")
	lathe.resistance_flags &= ~INDESTRUCTIBLE
	var/obj/machinery/atmospherics/pipe/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/simple, north)
	TEST_ASSERT_EQUAL(reclaimer.salvage_time(pipe), 0, "Pipes must not be salvaged")

	// Rozbiórka zostawia płytkę, którą skupuje platforma
	lathe.deconstruct(TRUE)
	var/obj/item/circuitboard/machine/board = locate() in east
	TEST_ASSERT(board, "A salvaged machine should leave its circuit board")
	TEST_ASSERT_EQUAL(salvage_price(board), 250, "A machine board should be worth 250")

	var/obj/machinery/piratepad/pad = allocate(/obj/machinery/piratepad, east)
	var/obj/machinery/computer/piratepad_control/salvage/console = allocate(/obj/machinery/computer/piratepad_control/salvage, corner)
	console.set_pad(pad)
	var/expected = 0
	for(var/atom/movable/AM in east)
		if(AM != pad)
			expected += console.salvage_value(AM, TRUE)
	TEST_ASSERT(expected >= 250, "The pad should value the salvage at least at the board price, got [expected]")
	console.sending = TRUE
	console.send()
	TEST_ASSERT(console.points >= expected, "Selling should give at least [expected] credits, got [console.points]")
	TEST_ASSERT(QDELETED(board), "The sold board should be gone")

	// Szablon statku jest poprawną mapą
	var/datum/map_template/shuttle/pirate/salvager/ship = new
	TEST_ASSERT(ship.width > 0 && ship.height > 0, "The salvager ship template did not load its map")

	// Złomiarz dostaje własną drużynę z celem sprzedaży złomu
	var/mob/living/carbon/human/salvager = allocate(/mob/living/carbon/human, north)
	salvager.mind_initialize()
	salvager.mind.add_antag_datum(/datum/antagonist/pirate/salvager)
	var/datum/antagonist/pirate/salvager/datum = salvager.mind.has_antag_datum(/datum/antagonist/pirate/salvager)
	TEST_ASSERT(istype(datum?.crew, /datum/team/pirate/salvager), "A salvager should get a salvager crew")
	TEST_ASSERT(locate(/datum/objective/loot/salvage) in datum.crew.objectives, "The salvager crew should have the salvage objective")
	salvager.mind.remove_antag_datum(/datum/antagonist/pirate/salvager)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
