// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - traitor made by admin Mass Antag (give_objectives = FALSE) still gets the faction picker, so the uplink is not withheld forever
/datum/unit_test/aquila_traitor_mass_antag_backstory

/datum/unit_test/aquila_traitor_mass_antag_backstory/Run()
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human)
	var/datum/mind/crew_mind = new("aquila_mass_antag")
	crew_mind.current = crew
	crew.mind = crew_mind
	var/datum/antagonist/traitor/traitor = new
	traitor.give_objectives = FALSE
	crew_mind.add_antag_datum(traitor)
	TEST_ASSERT(traitor.uses_backstory(), "A plain human traitor does not use the backstory menu")
	TEST_ASSERT(traitor.ui_name == "TraitorBackstoryMenu", "A traitor without objectives has no faction picker (window [traitor.ui_name]), it never gets the uplink")
	TEST_ASSERT(length(traitor.allowed_backstories), "A traitor without objectives has no backstories to pick")
	crew_mind.remove_all_antag_datums()
	crew.mind = null
	crew_mind.current = null
	qdel(crew_mind)

/// AQUILA - objectives set up before they have an owner (Mass Antag calls admin_edit() first) don't runtime,
/// the planted device is not hard referenced after it gets deleted and the brother beacon race has one winner
/datum/unit_test/aquila_traitor_objective_refs

/datum/unit_test/aquila_traitor_objective_refs/Run()
	var/runtimes_before = GLOB.total_runtimes

	// No owner yet: hoarder took owners[1] of an empty list, the device objectives picked from it
	var/datum/objective/hoarder/hoard = new
	hoard.admin_edit(null)
	var/datum/objective/plant_device/bug/ownerless_bug = new
	ownerless_bug.give_device()
	var/datum/objective/sabotage/power_sink/sink = new
	sink.give_beacon()
	var/datum/objective/poison_items/poison = new
	poison.give_papers()
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "Objectives without an owner caused [GLOB.total_runtimes - runtimes_before] runtime(s)")
	qdel(hoard)
	qdel(ownerless_bug)
	qdel(sink)
	qdel(poison)

	// The device deletes itself (beacon, T1de virus), the objective lets go of it
	var/mob/living/carbon/human/planter = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/mind/planter_mind = new("aquila_planter")
	planter_mind.current = planter
	planter.mind = planter_mind
	var/datum/objective/plant_device/bug/bug = new
	bug.owner = planter_mind
	bug.give_device()
	TEST_ASSERT(bug.device, "The bug objective gave no device")
	qdel(bug.device)
	TEST_ASSERT(isnull(bug.device), "The bug objective still holds its deleted device")
	TEST_ASSERT(!bug.check_completion(), "A deleted bug completes the objective")
	qdel(bug)
	planter.mind = null
	planter_mind.current = null
	qdel(planter_mind)

	// Brother beacon: the first team to hold it wins, the race is over for everyone else
	var/datum/objective/brother_beacon/winners = new
	winners.channel = 0
	var/datum/objective/brother_beacon/losers = new
	losers.channel = 1
	GLOB.brother_beacon_objectives += list(winners, losers)
	var/obj/structure/brother_beacon/deployed = new(run_loc_floor_bottom_left)
	deployed.channel = 0
	deployed.time_left = 0
	deployed.process(1)
	qdel(deployed) // before self_destruct() blows up the test room
	TEST_ASSERT(winners.completed, "The team on the beacon channel did not win")
	TEST_ASSERT(!losers.completed, "The other team completed the beacon objective too")
	TEST_ASSERT(GLOB.brother_beacon_race_won, "The beacon race was not recorded as won")
	var/obj/structure/brother_beacon/spare = new(run_loc_floor_bottom_left)
	spare.channel = 1
	spare.time_left = 0
	spare.process(1)
	qdel(spare)
	TEST_ASSERT(!losers.completed, "The losing team won the race again with a spare beacon")
	qdel(winners)
	qdel(losers)
	GLOB.brother_beacon_race_won = FALSE
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "The test caused [GLOB.total_runtimes - runtimes_before] runtime(s)")

/// AQUILA - a light put out by the shadow demon stays dark, even when it was flickering (flicker() lights it again at the end)
/datum/unit_test/aquila_shadow_extinguished_light

/datum/unit_test/aquila_shadow_extinguished_light/Run()
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light, run_loc_floor_bottom_left)
	TEST_ASSERT(lamp.status == LIGHT_OK, "The test lamp has no working tube")
	lamp.shadow_extinguished = TRUE
	// What the end of flicker() does
	lamp.on = TRUE
	lamp.update(FALSE)
	TEST_ASSERT(!lamp.on, "An extinguished lamp lit up again after flickering")
	lamp.restore_extinguished_light()
	TEST_ASSERT(!lamp.shadow_extinguished, "The lamp is still extinguished after restore_extinguished_light()")

/// AQUILA - a pulse demon moving while it observes the overmap keeps the observer eye (stop observing qdel()'d remote_control, the demon),
/// and after the eye is gone its moves inside a machine are relayed to it again
/datum/unit_test/aquila_pulse_demon_remote_control

/datum/unit_test/aquila_pulse_demon_remote_control/Run()
	var/turf/left = run_loc_floor_bottom_left
	allocate(/obj/structure/cable, left)
	var/mob/living/simple_animal/pulse_demon/demon = allocate(/mob/living/simple_animal/pulse_demon, left)
	demon.can_exit_cable = TRUE
	var/obj/item/radio/radio = allocate(/obj/item/radio, left)
	// Stands in for the overmap observer eye made by CreateEye()
	var/obj/item/stack/sheet/iron/fake_eye = allocate(/obj/item/stack/sheet/iron, left)
	demon.remote_control = fake_eye
	demon.forceMove(radio)
	TEST_ASSERT(demon.remote_control == fake_eye, "Moving into a machine replaced the observer eye with the demon itself")
	demon.forceMove(left)
	TEST_ASSERT(demon.remote_control == fake_eye, "Moving onto a turf dropped the observer eye")
	demon.forceMove(radio)
	// What the overmap "stop observing" does after deleting the eye
	demon.remote_control = null
	demon.cancel_camera()
	TEST_ASSERT(demon.remote_control == demon, "After the eye is gone the moves inside a machine are not relayed to the demon")
	demon.forceMove(left)
	TEST_ASSERT(!demon.remote_control, "Moves still relayed on a turf")

#undef TEST_ASSERT
