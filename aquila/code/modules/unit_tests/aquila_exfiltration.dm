// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - exfiltration flare and changeling extraction mass: objectives that need the agent until the end deny it,
/// the lit flare opens a portal that only lets its owner escape, the crew can break the flare, the changeling gets one mass per round
/datum/unit_test/aquila_exfiltration

/datum/unit_test/aquila_exfiltration/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/turf/other_spot = locate(spot.x + 2, spot.y, spot.z)

	// Picked rooms are never the bridge or security
	for(var/area/picked as anything in aquila_pick_exfiltration_areas())
		TEST_ASSERT(!istype(picked, /area/bridge) && !istype(picked, /area/security), "Picked a forbidden extraction area: [picked.type]")

	var/mob/living/carbon/human/agent = make_mob("Agent Ewakuacji", spot)
	var/datum/antagonist/traitor/traitor = new
	traitor.give_objectives = FALSE
	traitor.should_equip = FALSE
	agent.mind.add_antag_datum(traitor)

	// Objectives that need the agent until the end deny the extraction
	var/datum/objective/hijack/hijack = new
	hijack.owner = agent.mind
	traitor.objectives += hijack
	TEST_ASSERT(agent.mind.aquila_exfiltration_denial(FALSE), "Hijack objective did not deny the extraction")
	traitor.objectives -= hijack
	qdel(hijack)
	TEST_ASSERT(!agent.mind.aquila_exfiltration_denial(FALSE), "Extraction denied without a blocking objective")
	var/datum/objective/escape/escape = new
	escape.owner = agent.mind
	traitor.objectives += escape

	// Lit outside of the calibrated rooms: nothing happens
	var/obj/item/aquila_exfiltration_flare/admin/flare = allocate(/obj/item/aquila_exfiltration_flare/admin)
	flare.extractable_areas = list()
	TEST_ASSERT(!flare.activate(agent), "Flare lit outside of its rooms")
	TEST_ASSERT(!QDELETED(flare), "Flare used up outside of its rooms")

	// The crew can break a lit flare before the portal opens
	var/obj/structure/aquila_exfiltration_beacon/broken = new(other_spot, agent.mind, 10 MINUTES)
	broken.take_damage(100)
	TEST_ASSERT(QDELETED(broken), "Lit flare survived being broken")
	TEST_ASSERT(!(locate(/obj/effect/aquila_exfiltration_portal) in other_spot), "Broken flare still opened a portal")

	// Lit in its room: the flare is used up and the portal opens in its place
	flare.extractable_areas = list(get_area(spot))
	var/obj/structure/aquila_exfiltration_beacon/beacon = flare.activate(agent)
	TEST_ASSERT(beacon, "Flare did not light in its room")
	TEST_ASSERT(QDELETED(flare), "Flare was not used up")
	var/obj/effect/aquila_exfiltration_portal/portal = beacon.open_portal()
	TEST_ASSERT(portal, "Lit flare did not open a portal")
	TEST_ASSERT(QDELETED(beacon), "Lit flare stayed after opening the portal")

	// A crew member jumping in is thrown back and doesn't escape
	var/mob/living/carbon/human/bystander = make_mob("Gapiowski Testowy", spot)
	portal.pass_through(bystander)
	TEST_ASSERT(!bystander.mind.force_escaped, "Crew member escaped through someone else's portal")
	TEST_ASSERT(bystander.IsParalyzed(), "Crew member was not stunned by someone else's portal")
	TEST_ASSERT(!QDELETED(portal), "Portal closed after rejecting a crew member")

	// The owner escapes and leaves the round
	portal.pass_through(agent)
	TEST_ASSERT(agent.mind.force_escaped, "Agent was not marked as escaped")
	TEST_ASSERT(!agent.loc, "Agent stayed in the round after the extraction")
	TEST_ASSERT(escape.check_completion(), "Escape objective not completed by the extraction")
	TEST_ASSERT(QDELETED(portal), "Portal stayed open after the extraction")

	// Changeling: one extraction mass per round, only after the calibration time
	var/mob/living/carbon/human/ling = make_mob("Zmiennokształtny Testowy", other_spot)
	var/datum/antagonist/changeling/changeling = new
	changeling.give_objectives = FALSE
	ling.mind.add_antag_datum(changeling)
	var/datum/action/changeling/aquila_exfiltration/power = locate() in changeling.purchasedpowers
	TEST_ASSERT(power, "Changeling did not get the extraction mass power")
	changeling.chem_charges = 100
	var/old_start = SSticker.round_start_time
	SSticker.round_start_time = world.time
	power.try_to_sting(ling)
	var/early_mass = locate(/obj/item/aquila_exfiltration_flare/changeling) in ling.held_items
	TEST_ASSERT(!early_mass, "Extraction mass given before the calibration time")
	SSticker.round_start_time = world.time - 2 HOURS
	power.try_to_sting(ling)
	power.try_to_sting(ling)
	SSticker.round_start_time = old_start
	var/masses = 0
	for(var/obj/item/aquila_exfiltration_flare/changeling/mass in ling.held_items)
		masses++
	TEST_ASSERT(masses == 1, "Changeling got [masses] extraction masses instead of one")
	TEST_ASSERT(changeling.chem_charges == 70, "Extraction mass cost [100 - changeling.chem_charges] chemicals instead of 30")
	for(var/obj/item/aquila_exfiltration_flare/changeling/mass in ling.held_items)
		qdel(mass)

/datum/unit_test/aquila_exfiltration/proc/make_mob(new_name, turf/where)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, where)
	crew.fully_replace_character_name(null, new_name)
	var/datum/mind/crew_mind = new("aquila_exfil_[ckey(new_name)]")
	crew_mind.current = crew
	crew.mind = crew_mind
	return crew

#undef TEST_ASSERT
