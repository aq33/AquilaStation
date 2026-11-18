// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - fabricator windows get the English design name, so the search finds "health analyzer" in the Polish game too
/datum/unit_test/aquila_fabricator_english_search

/datum/unit_test/aquila_fabricator_english_search/Run()
	var/list/designs = fabricator_ui_designs(list("healthanalyzer"))
	var/list/design = designs["healthanalyzer"]
	TEST_ASSERT(islist(design), "fabricator_ui_designs did not serialize the health analyzer design")
	TEST_ASSERT_EQUAL(design["name"], "Analizator zdrowia", "Unexpected Polish design name")
	TEST_ASSERT_EQUAL(design["nameEn"], "Health Analyzer", "English design name missing from the fabricator data")

/// AQUILA - an item thrown from the hand starts its flight on the thrower's tile instead of appearing 1-2 tiles away
/datum/unit_test/aquila_throw_from_hand

/datum/unit_test/aquila_throw_from_hand/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/two_east = locate(start.x + 2, start.y, start.z)
	var/turf/one_north = locate(start.x, start.y + 1, start.z)

	var/list/offset = throw_start_offset(start, two_east, 2)
	TEST_ASSERT(islist(offset), "No offset for a throw that moved 2 tiles")
	TEST_ASSERT_EQUAL(offset[1], -2 * world.icon_size, "Wrong horizontal offset")
	TEST_ASSERT_EQUAL(offset[2], 0, "Wrong vertical offset")
	TEST_ASSERT_EQUAL(offset[3], 1, "2 tiles at 2 tiles/ds should take 1 ds")
	offset = throw_start_offset(start, one_north, 4)
	TEST_ASSERT_EQUAL(offset[2], -world.icon_size, "Wrong vertical offset")
	TEST_ASSERT(isnull(throw_start_offset(start, start, 2)), "An item that did not move needs no offset")

	var/turf/target = locate(start.x + 4, start.y, start.z)
	TEST_ASSERT(isopenturf(target), "No open turf 4 tiles east of the test room corner")
	var/mob/living/carbon/human/thrower = allocate(/mob/living/carbon/human, start)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red)
	thrower.put_in_active_hand(crayon)
	TEST_ASSERT(thrower.throw_item(target), "The human did not throw the crayon")
	TEST_ASSERT_EQUAL(crayon.thrown_from_hand_time, world.time, "A throw from the hand was not recorded")
	TEST_ASSERT(get_turf(crayon) != start, "Quickstart did not move the crayon on the throw tick")
	TEST_ASSERT_EQUAL(crayon.pixel_w, 0, "The flight offset must end at the item's own pixel_w")

/// AQUILA - a dormant eldritch horror can show up in a xenobiology cell and wakes up as a horror for a ghost
/datum/unit_test/aquila_horror_xenobio

/datum/unit_test/aquila_horror_xenobio/Run()
	var/obj/effect/mob_spawn/horror_xenobio/spawner = allocate(/obj/effect/mob_spawn/horror_xenobio, run_loc_floor_bottom_left)
	TEST_ASSERT(spawner in GLOB.mob_spawners[spawner.name], "The dormant horror is not in the ghost spawner menu")
	var/obj/effect/xenobio_specimen_monitor/monitor = allocate(/obj/effect/xenobio_specimen_monitor, run_loc_floor_bottom_left)
	monitor.cell_turfs = list(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(monitor.count_specimens(), 1, "The dormant horror does not count as a xenobiology specimen")

	spawner.create()
	var/mob/living/simple_animal/horror/horror = locate() in run_loc_floor_bottom_left
	TEST_ASSERT(horror, "The spawner did not create a horror")
	TEST_ASSERT(horror.stat != DEAD, "The horror from the cell spawned dead")
	TEST_ASSERT(QDELETED(spawner), "The one-use spawner was not removed")
	var/datum/antagonist/horror/xenobio/datum_type = /datum/antagonist/horror/xenobio
	TEST_ASSERT(!initial(datum_type.delay_roundend), "A horror from a xenobiology cell must not keep the round going")
	qdel(horror)

/// AQUILA - "Chcę być celem antagonistów": players with the option are picked first by find_target
/datum/unit_test/aquila_antag_target_opt_in

/datum/unit_test/aquila_antag_target_opt_in/Run()
	var/mob/living/carbon/human/volunteer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/traitor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	for(var/mob/living/carbon/human/H as anything in list(volunteer, bystander, traitor))
		H.mind_initialize()
	volunteer.mind.key = "aqtestoptinvolunteer"
	bystander.mind.key = "aqtestoptinbystander"
	traitor.mind.key = "aqtestoptintraitor"
	// Gracze są w grze (klient testowy): opcja nie działa dla tych, którzy wyszli
	volunteer.mock_client = new
	bystander.mock_client = new

	var/datum/preferences/prefs = new
	prefs.active_character = new
	prefs.active_character.features["antag_target_opt_in"] = TRUE
	GLOB.preferences_datums["aqtestoptinvolunteer"] = prefs
	var/datum/preferences/other_prefs = new
	other_prefs.active_character = new
	GLOB.preferences_datums["aqtestoptinbystander"] = other_prefs

	var/datum/objective/aquila_test_opt_in_probe/objective = new
	objective.owner = traitor.mind
	objective.crew = list(volunteer.mind, bystander.mind)
	// Inny antagonista, który już ma chętnego na celu
	var/datum/antagonist/other_antag = new /datum/antagonist/custom
	var/datum/objective/taken = new
	. = TRUE
	var/list/opted_in = opted_in_antag_targets(list(volunteer.mind, bystander.mind))
	if(length(opted_in) != 1 || opted_in[1] != volunteer.mind)
		. = Fail("opted_in_antag_targets returned [length(opted_in)] minds instead of only the volunteer")
	else
		for(var/i in 1 to 10)
			if(objective.find_target() != volunteer.mind)
				. = Fail("find_target picked someone other than the opted-in player")
				break
		// Chętny, który wyszedł z gry, nie ma pierwszeństwa
		var/datum/client_interface/volunteer_client = volunteer.mock_client
		volunteer.mock_client = null
		if(length(opted_in_antag_targets(list(volunteer.mind))))
			. = Fail("An opted-in player who left the game still gets priority")
		volunteer.mock_client = volunteer_client
		// Chętny, który jest już celem innego antagonisty, nie zbiera celów wszystkich antagów
		taken.target = volunteer.mind
		other_antag.objectives += taken
		if(length(opted_in_antag_targets(list(volunteer.mind))))
			. = Fail("An opted-in player already targeted by another antagonist still gets priority")

		// Losowy wygląd postaci (be_random_body) nie kasuje opcji
		prefs.active_character.randomise()
		if(!wants_to_be_antag_target(volunteer.mind))
			. = Fail("Randomising the character's look turned the antag target option off")

	other_antag.objectives -= taken
	qdel(taken)
	qdel(other_antag)
	qdel(objective)
	QDEL_NULL(volunteer.mock_client)
	QDEL_NULL(bystander.mock_client)
	GLOB.preferences_datums -= "aqtestoptinvolunteer"
	GLOB.preferences_datums -= "aqtestoptinbystander"

/// Objective whose crew list comes from the test instead of the crew records
/datum/objective/aquila_test_opt_in_probe
	var/list/crew

/datum/objective/aquila_test_opt_in_probe/get_crewmember_minds()
	return crew.Copy()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
