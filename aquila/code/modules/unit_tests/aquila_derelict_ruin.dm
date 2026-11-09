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

/// AQUILA - szablon wczytany obok innego (części ruin) nie zostawia jednostronnych połączeń rur: rura z nowej
/// części, która wzięła za węzeł zajęty już nawiewnik, nie wywraca budowy sieci (runtime w set_pipenet)
/datum/unit_test/template_one_way_pipe_link

/datum/unit_test/template_one_way_pipe_link/Run()
	var/turf/vent_turf = run_loc_floor_bottom_left
	var/turf/pipe_turf = get_step(vent_turf, EAST)
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = allocate(/obj/machinery/atmospherics/components/unary/vent_pump, vent_turf, TRUE, EAST)
	var/obj/machinery/atmospherics/pipe/simple/general/visible/first_pipe = allocate(/obj/machinery/atmospherics/pipe/simple/general/visible, pipe_turf, TRUE, EAST)
	SSair.setup_template_machinery(list(vent, first_pipe))
	TEST_ASSERT_EQUAL(vent.nodes[1], first_pipe, "The vent didn't connect to the first part's pipe")
	// Druga część kładzie swoją rurę na tym samym polu: nawiewnik ma już węzeł
	var/obj/machinery/atmospherics/pipe/simple/general/visible/second_pipe = allocate(/obj/machinery/atmospherics/pipe/simple/general/visible, pipe_turf, TRUE, EAST)
	SSair.setup_template_machinery(list(second_pipe))
	TEST_ASSERT(!(vent in second_pipe.nodes), "The second part's pipe kept a one-way link to the taken vent")
	TEST_ASSERT_EQUAL(vent.nodes[1], first_pipe, "The vent lost its own pipe")

/// AQUILA - nakładające się wczytywania map: koniec pierwszego nie przywraca stanu, póki drugie trwa,
/// a nadmiarowe zakończenie nie schodzi poniżej zera
/datum/unit_test/atoms_overlapping_map_loads

/datum/unit_test/atoms_overlapping_map_loads/Run()
	TEST_ASSERT(!SSatoms.initialized_changed, "A map load is already running")
	var/before = SSatoms.initialized
	SSatoms.map_loader_begin()
	SSatoms.map_loader_begin()
	SSatoms.map_loader_stop()
	var/during = SSatoms.initialized
	var/still_loading = SSatoms.initialized_changed
	SSatoms.map_loader_stop()
	SSatoms.map_loader_stop()
	TEST_ASSERT(still_loading, "The first load to finish ended the other one too")
	TEST_ASSERT_EQUAL(during, INITIALIZATION_INSSATOMS, "Initialization came back while a load was still running")
	TEST_ASSERT_EQUAL(SSatoms.initialized, before, "Initialization didn't come back after both loads")
	TEST_ASSERT_EQUAL(SSatoms.initialized_changed, 0, "An extra stop left the load counter off zero")

/// AQUILA - dopełnienie wyboru misji nie dokłada misji odrzuconej za zbyt wielu graczy
/datum/unit_test/mission_low_pop_max_players

/datum/unit_test/mission_low_pop_max_players/Run()
	var/list/max_pop = config.Get(/datum/config_entry/keyed_list/omode_max_pop)
	var/had_entry = ("derelict" in max_pop)
	var/old_max = had_entry ? max_pop["derelict"] : null
	var/old_players = SSovermap_mode.player_check
	SSovermap_mode.player_check = 3
	max_pop["derelict"] = 2
	var/list/capped = SSovermap_mode.low_pop_missions(list())
	max_pop["derelict"] = 0
	var/list/uncapped = SSovermap_mode.low_pop_missions(list())
	if(had_entry)
		max_pop["derelict"] = old_max
	else
		max_pop -= "derelict"
	SSovermap_mode.player_check = old_players
	if(!(/datum/overmap_gamemode/derelict_ruin in uncapped))
		return // Opuszczona stacja jest w zwykłej puli (dość graczy) albo zablokowana: nie ma czego sprawdzać
	TEST_ASSERT(!(/datum/overmap_gamemode/derelict_ruin in capped), "A mission over its player limit was added to the choice")

/// AQUILA - przy małej liczbie graczy (w testach 0) kapitan i tak wybiera z trzech różnych misji
/datum/unit_test/mission_choice_three

/datum/unit_test/mission_choice_three/Run()
	TEST_ASSERT(SSovermap_mode.mode, "No overmap mode")
	var/list/old_choices = SSovermap_mode.mission_choices
	var/old_forced = SSovermap_mode.forced_mode
	SSovermap_mode.forced_mode = null
	SSovermap_mode.roll_mission_choices()
	var/list/rolled = SSovermap_mode.mission_choices
	SSovermap_mode.mission_choices = old_choices
	SSovermap_mode.forced_mode = old_forced
	TEST_ASSERT_EQUAL(length(rolled), 3, "The captain doesn't get three missions to pick from")
	TEST_ASSERT_EQUAL(length(uniqueList(rolled)), 3, "The mission choice repeats a mission")
	TEST_ASSERT_EQUAL(rolled[1], SSovermap_mode.mode.type, "The rolled round mode isn't the first choice")
	var/next_missions = 0
	for(var/choice in SSovermap_mode.get_extension_choices())
		if(choice != "rubicon")
			next_missions++
	TEST_ASSERT(next_missions >= 3, "Only [next_missions] missions to pick as the next mission")

/// Misja bez celów do testu wyboru kolejnej misji (nie tworzy flot ani poziomów Z)
/datum/overmap_gamemode/unit_test_next_mission
	name = "misja testowa"
	config_tag = "unit_test_next_mission"
	brief = "Misja testowa."
	starting_faction = "syndicate"
	reminder_one = "Przypomnienie misji testowej."
	objective_reminder_interval = 7 MINUTES

/// AQUILA - kolejna misja zastępuje cały tryb: przypomnienia od pierwszego, jej teksty, nowy licznik celów, frakcja statku zostaje
/datum/unit_test/mission_extension_switch

/datum/unit_test/mission_extension_switch/Run()
	var/datum/overmap_gamemode/round_mode = SSovermap_mode.mode
	TEST_ASSERT(round_mode, "No overmap mode to extend")
	var/round_mode_type = round_mode.type
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	var/old_faction = main_ship?.faction
	var/old_difficulty = round_mode.difficulty
	var/old_stacks = SSovermap_mode.objective_reminder_stacks
	var/old_highest = SSovermap_mode.highest_objective_completion
	var/old_extended = SSovermap_mode.round_extended

	// Stan po długiej pierwszej misji
	SSovermap_mode.objective_reminder_stacks = 3
	SSovermap_mode.highest_objective_completion = 4
	SSovermap_mode.round_extended = TRUE
	SSovermap_mode.extension_choice_pending = TRUE
	SSovermap_mode.extension_choices = list(/datum/overmap_gamemode/unit_test_next_mission)
	SSovermap_mode.finish_extension_choice(/datum/overmap_gamemode/unit_test_next_mission)

	var/datum/overmap_gamemode/next = SSovermap_mode.mode
	TEST_ASSERT(istype(next, /datum/overmap_gamemode/unit_test_next_mission), "The next mission didn't replace the round mode")
	TEST_ASSERT(QDELETED(round_mode), "The previous mission's mode wasn't cleaned up")
	TEST_ASSERT_EQUAL(next.reminder_one, "Przypomnienie misji testowej.", "The next mission uses the previous mission's reminders")
	TEST_ASSERT_EQUAL(SSovermap_mode.objective_reminder_stacks, 0, "The next mission continues the previous reminder escalation")
	TEST_ASSERT_EQUAL(SSovermap_mode.highest_objective_completion, 0, "The next mission keeps the previous objective count")
	TEST_ASSERT(!SSovermap_mode.round_extended, "The next mission doesn't count as a normal mission")
	TEST_ASSERT_EQUAL(next.difficulty, old_difficulty, "The next mission lost the round difficulty")
	if(main_ship)
		TEST_ASSERT_EQUAL(main_ship.faction, old_faction, "Picking the next mission changed the ship's faction")
	TEST_ASSERT(!SSovermap_mode.extension_choice_pending, "The choice is still pending")

	// Przywrócenie trybu rundy dla kolejnych testów
	var/datum/overmap_gamemode/restored = new round_mode_type()
	restored.objectives = list()
	restored.difficulty = old_difficulty
	SSovermap_mode.mode = restored
	qdel(next)
	SSovermap_mode.objective_reminder_stacks = old_stacks
	SSovermap_mode.highest_objective_completion = old_highest
	SSovermap_mode.round_extended = old_extended

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
