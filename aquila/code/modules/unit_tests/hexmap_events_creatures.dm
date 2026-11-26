// AQUILA - testy eventów z kafli mapy hex, etap E4 (stwory, które już mamy): pule terenów i to, co każdy event
// wypuszcza na pokład (mimiki, skrzynia-mimik, szlamy, facehugger, gniazdo obcych, hiveboty, drony, kocichirurg,
// żywy smar, cyborg Syndykatu, meteor zmiennokształtnego, napromieniowana mysz)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Each E4 event is in the pool of its own terrain only: NPC events among the events, ghost roles among the antagonists
/datum/unit_test/aquila_hex_creatures_pools

/datum/unit_test/aquila_hex_creatures_pools/Run()
	var/list/event_terrains = list(
		/datum/round_event_control/aquila_hex_mimics_invasion = HEX_TERRAIN_SIGNAL,
		/datum/round_event_control/aquila_hex_station_incident_mimic = HEX_TERRAIN_JUNK,
		/datum/round_event_control/aquila_hex_slimes_spawn_horde = HEX_TERRAIN_COMET,
		/datum/round_event_control/aquila_hex_stray_facehugger = HEX_TERRAIN_COMET,
		/datum/round_event_control/aquila_hex_xenohive = HEX_TERRAIN_ASTEROIDS,
		/datum/round_event_control/aquila_hex_hivebots = HEX_TERRAIN_WORMHOLE,
		/datum/round_event_control/aquila_hex_rogue_maint_drones = HEX_TERRAIN_JUNK,
		/datum/round_event_control/aquila_hex_cat_surgeon = HEX_TERRAIN_SIGNAL,
		/datum/round_event_control/aquila_hex_irradiated_mouse = HEX_TERRAIN_RADIATION,
	)
	var/list/antag_terrains = list(
		/datum/round_event_control/aquila_hex_living_lube = HEX_TERRAIN_WORMHOLE,
		/datum/round_event_control/aquila_hex_derelict_syndicate_cyborg = HEX_TERRAIN_MINES,
		/datum/round_event_control/aquila_hex_changeling_meteor = HEX_TERRAIN_COMET,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in event_terrains + antag_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		var/is_antag = !isnull(antag_terrains[path])
		var/terrain_id = is_antag ? antag_terrains[path] : event_terrains[path]
		for(var/id in GLOB.hex_terrains)
			var/datum/hex_terrain/terrain = GLOB.hex_terrains[id]
			var/in_events = (path in terrain.events)
			var/in_antags = (path in terrain.antags)
			if(id == terrain_id)
				TEST_ASSERT(is_antag ? (in_antags && !in_events) : (in_events && !in_antags), "[control.name] is not in the right pool of [id]")
			else
				TEST_ASSERT(!in_events && !in_antags, "[control.name] is also in a pool of [id]")
		if(is_antag)
			TEST_ASSERT(hex_midround_antag_events()[path], "[control.name] is not a midround antagonist event")
			TEST_ASSERT(ispath(control.typepath, /datum/round_event/ghost_role), "[control.name] does not check the ghost role switch")
		else
			TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// Loose items come to life as mimics (important ones do not); the salvage crate is an inert crate mimic with loot
/datum/unit_test/aquila_hex_creatures_mimics

/datum/unit_test/aquila_hex_creatures_mimics/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, floor)
	var/datum/round_event/aquila_hex_mimics_invasion/invasion = new(FALSE)
	invasion.kill()
	var/mob/living/basic/mimic/copy/mimic = invasion.animate_item(wrench)
	TEST_ASSERT(istype(mimic) && mimic.loc == floor, "The wrench did not come to life")
	allocated += mimic
	TEST_ASSERT(wrench.loc == mimic, "The mimic did not take the wrench")
	TEST_ASSERT_EQUAL(mimic.name, wrench.name, "The mimic does not look like the wrench")
	var/obj/item/card/id/card = allocate(/obj/item/card/id, floor)
	TEST_ASSERT(isnull(invasion.animate_item(card)), "An ID card came to life")
	TEST_ASSERT(card.loc == floor, "The ID card moved")
	qdel(invasion)

	var/datum/round_event/aquila_hex_station_incident_mimic/incident = new(FALSE)
	incident.kill()
	var/obj/structure/closet/supplypod/pod = incident.make_shipment()
	allocated += pod
	var/mob/living/basic/mimic/crate/crate = locate() in pod
	TEST_ASSERT(crate, "The salvage pod carries no crate mimic")
	TEST_ASSERT(crate.ai_controller?.ai_status == AI_STATUS_OFF, "The crate mimic is awake before anyone opens it")
	TEST_ASSERT(locate(/obj/item/stack/sheet/iron) in crate, "The crate mimic holds no metal")
	TEST_ASSERT(locate(/obj/item/paper) in pod, "The salvage pod has no manifest")
	TEST_ASSERT(crate.trigger(), "The crate mimic did not wake up")
	qdel(incident)

/// The slime horde comes out of the vents as rabid adults, at most two per vent
/datum/unit_test/aquila_hex_creatures_slimes

/datum/unit_test/aquila_hex_creatures_slimes/Run()
	var/datum/round_event/aquila_hex_slimes_spawn_horde/horde = new(FALSE)
	horde.kill()
	var/list/slimes = horde.spawn_slimes(list(run_loc_floor_bottom_left), 5)
	allocated += slimes
	TEST_ASSERT_EQUAL(length(slimes), 2, "One vent let out a wrong number of slimes")
	for(var/mob/living/simple_animal/slime/slime as anything in slimes)
		TEST_ASSERT(slime.rabid && slime.is_adult, "[slime] is not a rabid adult slime")
		TEST_ASSERT(slime.colour in list("blue", "green", "yellow"), "[slime] is [slime.colour]")
	var/list/more = horde.spawn_slimes(list(run_loc_floor_bottom_left, run_loc_floor_top_right), 3)
	allocated += more
	TEST_ASSERT_EQUAL(length(more), 3, "Two vents let out a wrong number of slimes")
	TEST_ASSERT(!length(horde.spawn_slimes(null, 4)), "Slimes came out with no vents")
	qdel(horde)

/// The stray facehugger leaps at a victim nearby, not again right away; the nest has weeds, a drone and its guards
/datum/unit_test/aquila_hex_creatures_xenos

/datum/unit_test/aquila_hex_creatures_xenos/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/datum/round_event/aquila_hex_stray_facehugger/stray = new(FALSE)
	stray.kill()
	var/obj/item/clothing/mask/facehugger/aquila_stray/hugger = stray.spawn_facehugger(floor)
	TEST_ASSERT(istype(hugger) && hugger.loc == floor, "No stray facehugger")
	allocated += hugger
	hugger.sterile = TRUE // bez zarodka, gdyby zdążył doskoczyć
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(floor.x + 2, floor.y, floor.z))
	COOLDOWN_RESET(hugger, leap_cooldown) // monitor zbliżenia mógł już skoczyć, gdy ofiara się pojawiła
	TEST_ASSERT(hugger.leap_at(victim), "The facehugger did not leap at a victim 2 tiles away")
	TEST_ASSERT(!hugger.leap_at(victim), "The facehugger leapt twice in a row")
	TEST_ASSERT(isnull(stray.spawn_facehugger(null)), "A facehugger spawned nowhere")
	qdel(stray)

	var/turf/center = locate(floor.x + 1, floor.y + 1, floor.z)
	var/datum/round_event/aquila_hex_xenohive/hive_event = new(FALSE)
	hive_event.kill()
	var/list/aliens = hive_event.build_hive(center)
	allocated += aliens
	TEST_ASSERT(length(aliens) >= 2 && length(aliens) <= 3, "The nest has [length(aliens)] xenomorphs")
	TEST_ASSERT(istype(aliens[1], /mob/living/basic/alien/drone), "The nest has no drone")
	TEST_ASSERT(locate(/obj/structure/alien/weeds/node) in center, "The nest has no weed node")
	var/resin = 0
	for(var/obj/structure/alien/resin/piece in range(2, center))
		resin++
	TEST_ASSERT(resin >= 1, "The nest has no resin")
	for(var/obj/structure/alien/leftover in range(3, center))
		qdel(leftover)
	qdel(hive_event)

/// The hivebot teleporter spits its bots out once; rogue maintenance drones come in a group
/datum/unit_test/aquila_hex_creatures_bots

/datum/unit_test/aquila_hex_creatures_bots/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/structure/aquila_hex_hivebot_teleporter/tele = allocate(/obj/structure/aquila_hex_hivebot_teleporter, floor)
	var/list/bots = tele.warp_bots()
	allocated += bots
	TEST_ASSERT(length(bots) >= 4 && length(bots) <= 6, "The teleporter let out [length(bots)] hivebots")
	for(var/mob/living/basic/hivebot/bot as anything in bots)
		TEST_ASSERT(istype(bot), "The teleporter let out [bot]")
	TEST_ASSERT(!length(tele.warp_bots()), "The teleporter let out hivebots twice")

	var/datum/round_event/aquila_hex_rogue_maint_drones/drones_event = new(FALSE)
	drones_event.kill()
	var/list/drones = drones_event.spawn_group(locate(floor.x + 2, floor.y + 2, floor.z), 3)
	allocated += drones
	TEST_ASSERT(length(drones) >= 1, "No rogue maintenance drones")
	for(var/mob/living/basic/hivebot/range/aquila_hex_maint_drone/drone as anything in drones)
		TEST_ASSERT(istype(drone) && ("rogue_drone" in drone.faction), "[drone] is not a rogue maintenance drone")
	TEST_ASSERT(!length(drones_event.spawn_group(null, 3)), "Drones spawned nowhere")
	qdel(drones_event)

/// The cat surgeon comes with a warning fax
/datum/unit_test/aquila_hex_creatures_cat_surgeon

/datum/unit_test/aquila_hex_creatures_cat_surgeon/Run()
	var/datum/round_event/aquila_hex_cat_surgeon/event = new(FALSE)
	event.kill()
	var/mob/living/simple_animal/hostile/cat_butcherer/surgeon = event.spawn_surgeon(run_loc_floor_bottom_left)
	TEST_ASSERT(istype(surgeon), "No cat surgeon")
	allocated += surgeon
	var/obj/machinery/fax/fax = allocate(/obj/machinery/fax, run_loc_floor_top_right)
	var/obj/item/paper/warning = event.send_warning(fax)
	TEST_ASSERT(warning, "The fax did not get the warning")
	allocated += warning
	TEST_ASSERT(length(fax.fax_history), "The fax has no history")
	var/list/last = fax.fax_history[length(fax.fax_history)]
	TEST_ASSERT_EQUAL(last["history_type"], "Receive", "The fax did not receive the warning")
	TEST_ASSERT(isnull(event.send_warning(null)), "A warning was sent with no fax")
	qdel(event)

/// The ghost role bodies: living lube, the derelict Syndicate cyborg and the changeling in its meteor
/datum/unit_test/aquila_hex_creatures_ghost_roles

/datum/unit_test/aquila_hex_creatures_ghost_roles/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/datum/round_event/ghost_role/aquila_hex_living_lube/lube_event = new(FALSE)
	lube_event.kill()
	var/mob/living/basic/clown/lube/lube = lube_event.make_lube(floor, null)
	TEST_ASSERT(istype(lube) && lube.loc == floor, "No living lube")
	allocated += lube
	lube.mind_initialize()
	var/datum/antagonist/aquila_hex_living_lube/lube_antag = lube.mind.add_antag_datum(/datum/antagonist/aquila_hex_living_lube)
	TEST_ASSERT(istype(lube_antag) && length(lube_antag.objectives) == 1, "The living lube got no antagonist with an objective")
	qdel(lube_event)

	var/datum/round_event/ghost_role/aquila_hex_derelict_syndicate_cyborg/borg_event = new(FALSE)
	borg_event.kill()
	var/mob/living/silicon/robot/modules/syndicate/aquila_hex_derelict/borg = borg_event.make_cyborg(run_loc_floor_top_right, null)
	TEST_ASSERT(istype(borg), "No derelict Syndicate cyborg")
	allocated += borg
	TEST_ASSERT(istype(borg.module, /obj/item/robot_module/syndicate), "The derelict cyborg is not an assault cyborg")
	TEST_ASSERT(borg.cell && borg.cell.charge < borg.cell.maxcharge, "The derelict cyborg has a full cell")
	TEST_ASSERT(borg.getBruteLoss() > 0, "The derelict cyborg is not damaged")
	TEST_ASSERT(borg.ionpulse, "The derelict cyborg cannot fly in space")
	qdel(borg_event)

	var/datum/round_event/ghost_role/aquila_hex_changeling_meteor/ling_event = new(FALSE)
	ling_event.kill()
	var/mob/living/carbon/human/changeling = ling_event.make_changeling(floor, null)
	TEST_ASSERT(istype(changeling), "No changeling body")
	allocated += changeling
	TEST_ASSERT(istype(changeling.wear_suit, /obj/item/clothing/suit/space), "The changeling has no space suit")
	TEST_ASSERT(istype(changeling.s_store, /obj/item/tank/internals), "The changeling has no air tank")
	var/obj/effect/meteor/meaty/aquila_hex_changeling/meteor = ling_event.launch(changeling, floor, run_loc_floor_top_right)
	TEST_ASSERT(istype(meteor) && changeling.loc == meteor, "The changeling is not in the meteor")
	var/turf/meteor_turf = get_turf(meteor)
	qdel(meteor)
	TEST_ASSERT_EQUAL(changeling.loc, meteor_turf, "The meteor did not let the changeling out")
	qdel(ling_event)

/// The irradiated mouse glows, is immune to its own radiation, can be picked up and sends out a pulse
/datum/unit_test/aquila_hex_creatures_mouse

/datum/unit_test/aquila_hex_creatures_mouse/Run()
	var/datum/round_event/aquila_hex_irradiated_mouse/event = new(FALSE)
	event.kill()
	var/mob/living/basic/mouse/aquila_hex_irradiated/mouse = event.spawn_mouse(run_loc_floor_bottom_left)
	TEST_ASSERT(istype(mouse), "No irradiated mouse")
	allocated += mouse
	TEST_ASSERT(mouse.light_range > 0, "The irradiated mouse does not glow")
	TEST_ASSERT(HAS_TRAIT(mouse, TRAIT_RADIMMUNE), "The irradiated mouse is not immune to radiation")
	TEST_ASSERT(mouse.can_be_held, "The irradiated mouse cannot be caught")
	TEST_ASSERT(mouse.irradiate(), "The irradiated mouse sent out no pulse")
	TEST_ASSERT(!COOLDOWN_FINISHED(mouse, pulse_cooldown), "The pulse did not start its cooldown")
	TEST_ASSERT(isnull(event.spawn_mouse(null)), "A mouse spawned nowhere")
	qdel(event)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
