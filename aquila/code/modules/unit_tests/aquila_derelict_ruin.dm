// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - misja „Opuszczona stacja”: generator buduje ruinę z celem na własnym poziomie Z, a wykonanie celu Bee zalicza misję
/datum/unit_test/derelict_ruin_mission

/datum/unit_test/derelict_ruin_mission/Run()
	var/datum/overmap_objective/derelict_ruin/mission = new(null, /datum/orbital_objective/recover_blackbox)
	var/datum/orbital_objective/recover_blackbox/blackbox_objective = mission.ruin_objective
	TEST_ASSERT(istype(blackbox_objective), "The forced objective type wasn't used")
	TEST_ASSERT(blackbox_objective.linked_mission == mission, "The Bee objective isn't linked to the mission")
	TEST_ASSERT(blackbox_objective.payout > 0, "The objective has no payout")

	var/maxz_before = world.maxz
	mission.generate_ruin()
	TEST_ASSERT(mission.ruin_generated, "The ruin didn't finish generating")
	TEST_ASSERT_EQUAL(mission.ruin_z, maxz_before + 1, "The ruin isn't on its own new Z level")
	var/floors = 0
	for(var/turf/open/floor/F in block(locate(1, 1, mission.ruin_z), locate(world.maxx, world.maxy, mission.ruin_z)))
		floors++
	TEST_ASSERT(floors > 50, "The generated ruin has only [floors] floor tiles")
	var/obj/item/blackbox/objective/blackbox = blackbox_objective.linked_blackbox
	TEST_ASSERT(blackbox, "The ruin has no blackbox")
	TEST_ASSERT_EQUAL(blackbox.z, mission.ruin_z, "The blackbox isn't in the ruin")

	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 0, "The mission finished before the blackbox was recovered")
	blackbox_objective.complete_objective()
	TEST_ASSERT_EQUAL(mission.status, 1, "Completing the Bee objective didn't complete the mission")
	// Odzyskana skrzynka znika (balon), a to nie może cofnąć wykonanej misji
	qdel(blackbox)
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 1, "The recovered blackbox disappearing changed the mission status")
	qdel(mission)

/// AQUILA - misja „Opuszczona stacja”: likwidacja jądrowa nie przepada od razu bez nadajnika z mapy orbitalnej
/datum/unit_test/derelict_ruin_nuke_check

/datum/unit_test/derelict_ruin_nuke_check/Run()
	var/datum/overmap_objective/derelict_ruin/mission = new(null, /datum/orbital_objective/nuclear_bomb)
	var/datum/orbital_objective/nuclear_bomb/nuke_objective = mission.ruin_objective
	nuke_objective.generated = TRUE
	nuke_objective.nuclear_disk = new(run_loc_floor_bottom_left)
	nuke_objective.nuclear_bomb = allocate(/obj/structure/closet) // Stand-in: the real bomb drops in a supply pod
	TEST_ASSERT(!nuke_objective.check_failed(), "The nuke objective failed with both the bomb and the disk present")
	QDEL_NULL(nuke_objective.nuclear_disk)
	TEST_ASSERT(nuke_objective.check_failed(), "The nuke objective didn't fail after the disk was lost")
	nuke_objective.nuclear_bomb = null
	qdel(mission)

/// AQUILA - wybór kolejnej misji: tylko misje z losowania i Rubikon
/datum/unit_test/mission_extension_choices

/datum/unit_test/mission_extension_choices/Run()
	TEST_ASSERT_EQUAL(GLOB.mission_choice_names["derelict"], "Opuszczona stacja", "The derelict mission has no Polish name")
	// Tryby z logiką w samym trybie mają zniknąć z wyboru także wtedy, gdy konfiguracja daje im dodatnią wagę
	var/list/probabilities = config.Get(/datum/config_entry/keyed_list/omode_probability)
	var/list/old_weights = list()
	for(var/tag in list("armada", "conquest", "hardmode"))
		old_weights[tag] = (tag in probabilities) ? probabilities[tag] : null
		probabilities[tag] = 10
	var/list/choices = SSovermap_mode.get_extension_choices()
	for(var/tag in old_weights)
		if(isnull(old_weights[tag]))
			probabilities -= tag
		else
			probabilities[tag] = old_weights[tag]
	for(var/choice in choices)
		if(choice == "rubicon")
			continue
		TEST_ASSERT(ispath(choice, /datum/overmap_gamemode), "[choice] isn't a mission type")
		var/datum/overmap_gamemode/mode_type = choice
		TEST_ASSERT(!initial(mode_type.whitelist_only), "[choice] is a whitelist-only mission")
		TEST_ASSERT(!ispath(choice, /datum/overmap_gamemode/armada) && !ispath(choice, /datum/overmap_gamemode/galactic_conquest) && !ispath(choice, /datum/overmap_gamemode/hardmode), "[choice] can't work as a next mission, its logic lives in the mode")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
