// AQUILA - testy eventów z kafli mapy hex, etap E3 (nowe anomalie): pule terenów, pojawienie się anomalii i artefaktu
// w obszarze oraz działanie każdej anomalii (kończyny, szlam, piorun, lód, gaz, zwierzęta, fala grozy, krew, materiały),
// brak rdzeni i portal kultu (bany, przełącznik ról, cooldown, antagonista konstrukta)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// The E3 anomalies are in the anomaly field pool only, the cult portal only among the antagonists of star activity
/datum/unit_test/aquila_hex_anomalies_pools

/datum/unit_test/aquila_hex_anomalies_pools/Run()
	var/list/anomaly_events = list(
		/datum/round_event_control/aquila_hex_anomaly_bioscrambler,
		/datum/round_event_control/aquila_hex_anomaly_radiation,
		/datum/round_event_control/aquila_hex_anomaly_storm,
		/datum/round_event_control/aquila_hex_anomaly_frost,
		/datum/round_event_control/aquila_hex_anomaly_gas,
		/datum/round_event_control/aquila_hex_anomaly_lifebringer,
		/datum/round_event_control/aquila_hex_anomaly_insanity_pulse,
		/datum/round_event_control/aquila_hex_anomaly_blood,
		/datum/round_event_control/aquila_hex_anomaly_dimensional,
		/datum/round_event_control/aquila_hex_artifact,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in anomaly_events + /datum/round_event_control/aquila_hex_cult_portal)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		var/in_pools = 0
		var/in_antag_pools = 0
		for(var/id in GLOB.hex_terrains)
			var/datum/hex_terrain/terrain = GLOB.hex_terrains[id]
			if(path in terrain.events)
				in_pools++
				TEST_ASSERT_EQUAL(id, HEX_TERRAIN_ANOMALIES, "[control.name] is in the event pool of [id]")
			if(path in terrain.antags)
				in_antag_pools++
				TEST_ASSERT_EQUAL(id, HEX_TERRAIN_FLARE, "[control.name] is in the antagonist pool of [id]")
		if(path == /datum/round_event_control/aquila_hex_cult_portal)
			TEST_ASSERT(in_pools == 0 && in_antag_pools == 1, "The cult portal is not only among the star activity antagonists")
			TEST_ASSERT(hex_midround_antag_events()[path], "The cult portal is not a midround antagonist event")
		else
			TEST_ASSERT(in_pools == 1 && in_antag_pools == 0, "[control.name] is not only in the anomaly field pool")
			TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// Every E3 event spawns its anomaly (or artifact) on a free floor of the area and announces it
/datum/unit_test/aquila_hex_anomalies_spawn

/datum/unit_test/aquila_hex_anomalies_spawn/Run()
	var/list/expected = list(
		/datum/round_event_control/aquila_hex_anomaly_bioscrambler = /obj/effect/anomaly/aquila_hex_bioscrambler,
		/datum/round_event_control/aquila_hex_anomaly_radiation = /obj/effect/anomaly/aquila_hex_radioactive,
		/datum/round_event_control/aquila_hex_anomaly_storm = /obj/effect/anomaly/aquila_hex_storm,
		/datum/round_event_control/aquila_hex_anomaly_frost = /obj/effect/anomaly/aquila_hex_frost,
		/datum/round_event_control/aquila_hex_anomaly_gas = /obj/effect/anomaly/aquila_hex_gas,
		/datum/round_event_control/aquila_hex_anomaly_lifebringer = /obj/effect/anomaly/aquila_hex_lifebringer,
		/datum/round_event_control/aquila_hex_anomaly_insanity_pulse = /obj/effect/anomaly/aquila_hex_insanity_pulse,
		/datum/round_event_control/aquila_hex_anomaly_blood = /obj/effect/anomaly/aquila_hex_blood,
		/datum/round_event_control/aquila_hex_anomaly_dimensional = /obj/effect/anomaly/aquila_hex_dimensional,
		/datum/round_event_control/aquila_hex_artifact = /obj/item/xenoartifact,
	)
	var/area/test_area = get_area(run_loc_floor_bottom_left)
	for(var/path in expected)
		var/datum/round_event_control/control = hex_event_control(path)
		var/datum/round_event/aquila_hex_anomaly/event = new control.typepath(FALSE)
		event.kill()
		event.control = control
		event.impact_area = test_area
		var/atom/movable/spawned = event.start()
		TEST_ASSERT(istype(spawned, expected[path]), "[control.name] spawned [spawned?.type || "nothing"] instead of [expected[path]]")
		allocated += spawned
		TEST_ASSERT_EQUAL(get_area(spawned), test_area, "[control.name] spawned its object outside the area")
		TEST_ASSERT_EQUAL(event.anomaly_ref?.resolve(), spawned, "[control.name] does not remember what it spawned")
		if(event.announce_kind)
			TEST_ASSERT(findtext(aquila_hex_anomaly_announcement(event.announce_kind, test_area.name), test_area.name), "[control.name] announces no area")
		qdel(event)
	var/datum/round_event/aquila_hex_anomaly/nowhere = new /datum/round_event/aquila_hex_anomaly/frost(FALSE)
	nowhere.kill()
	nowhere.impact_area = null
	TEST_ASSERT(isnull(nowhere.start()), "An anomaly spawned with no area")
	qdel(nowhere)

/// Bioscrambler swaps an arm or a leg for an organic limb of another species; storm, radiation, frost and gas leave their marks
/datum/unit_test/aquila_hex_anomalies_effects

/datum/unit_test/aquila_hex_anomalies_effects/Run()
	var/turf/open/floor/center = run_loc_floor_bottom_left
	var/obj/effect/anomaly/aquila_hex_bioscrambler/scrambler = allocate(/obj/effect/anomaly/aquila_hex_bioscrambler, center)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(center, NORTH))
	var/mob/living/carbon/human/protected = allocate(/mob/living/carbon/human, get_step(center, EAST))
	protected.equip_to_slot_or_del(new /obj/item/clothing/suit/bio_suit(protected), ITEM_SLOT_OCLOTHING)
	protected.equip_to_slot_or_del(new /obj/item/clothing/head/bio_hood(protected), ITEM_SLOT_HEAD)
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human, get_step(get_step(center, EAST), NORTH))
	corpse.death()
	var/list/old_limb_ids = list()
	var/list/obj/item/stuck_items = list()
	for(var/zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/limb = victim.get_bodypart(zone)
		old_limb_ids[zone] = limb.limb_id
		var/obj/item/shard/stuck = new(victim)
		limb.embedded_objects |= stuck
		stuck_items += stuck
	var/list/hit = aquila_hex_bioscrambler_pulse(scrambler, 5)
	TEST_ASSERT(victim in hit, "The bioscrambler pulse missed a human next to it")
	TEST_ASSERT(!(protected in hit), "The bioscrambler pulse went through a full bio suit")
	TEST_ASSERT(!(corpse in hit), "The bioscrambler pulse scrambled a dead body")
	var/obj/item/bodypart/new_part
	for(var/zone in old_limb_ids)
		var/obj/item/bodypart/limb = victim.get_bodypart(zone)
		if(limb?.limb_id != old_limb_ids[zone])
			new_part = limb
	TEST_ASSERT(new_part, "The bioscrambler swapped no arm or leg")
	TEST_ASSERT(new_part.type in aquila_hex_bioscrambler_limbs(new_part.body_zone), "The new limb ([new_part.type]) is not a limb of a roundstart species")
	TEST_ASSERT(!new_part.animal_origin && (new_part.bodytype & BODYTYPE_ORGANIC), "The new limb ([new_part.type]) is not organic")
	var/dropped_items = 0
	for(var/obj/item/shard/stuck as anything in stuck_items)
		TEST_ASSERT(!QDELETED(stuck), "An item stuck in the old limb was deleted with it")
		if(isturf(stuck.loc))
			dropped_items++
		qdel(stuck)
	TEST_ASSERT_EQUAL(dropped_items, 1, "The item stuck in the swapped limb did not fall on the floor")

	var/obj/effect/anomaly/aquila_hex_radioactive/radioactive = allocate(/obj/effect/anomaly/aquila_hex_radioactive, center)
	var/obj/effect/decal/nuclear_waste/sludge = radioactive.leave_sludge(center)
	TEST_ASSERT(istype(sludge) && sludge.loc == center, "The radioactive anomaly left no sludge")
	TEST_ASSERT_EQUAL(radioactive.leave_sludge(center), sludge, "The radioactive anomaly piled a second sludge on the same tile")
	qdel(sludge)

	var/obj/effect/anomaly/aquila_hex_storm/storm = allocate(/obj/effect/anomaly/aquila_hex_storm, center)
	var/vapour_before = center.return_air().get_moles(GAS_H2O)
	storm.discharge()
	TEST_ASSERT(center.return_air().get_moles(GAS_H2O) > vapour_before, "The storm anomaly released no hot steam")

	var/obj/effect/anomaly/aquila_hex_frost/frost = allocate(/obj/effect/anomaly/aquila_hex_frost, center)
	var/list/frozen = frost.freeze_floors(center)
	TEST_ASSERT(length(frozen) >= 2, "The frost anomaly froze [length(frozen)] floors")
	for(var/turf/open/frozen_floor as anything in frozen)
		TEST_ASSERT(frozen_floor.GetComponent(/datum/component/wet_floor), "[frozen_floor] is not icy")
		frozen_floor.ClearWet()

	var/obj/effect/anomaly/aquila_hex_gas/gas = allocate(/obj/effect/anomaly/aquila_hex_gas, center)
	var/reagent_type = gas.release_gas(10, 1)
	TEST_ASSERT(ispath(reagent_type, /datum/reagent), "The gas anomaly released no reagent")
	var/smoke_found = FALSE
	for(var/obj/effect/particle_effect/smoke/smoke in range(2, center))
		smoke_found = TRUE
		qdel(smoke)
	TEST_ASSERT(smoke_found, "The gas anomaly made no smoke")

/// Lifebringer lets an animal out, the sanity disruptor hits everyone nearby, the blood anomaly makes a lying victim bleed
/datum/unit_test/aquila_hex_anomalies_creatures

/datum/unit_test/aquila_hex_anomalies_creatures/Run()
	var/turf/open/floor/center = run_loc_floor_bottom_left
	var/obj/effect/anomaly/aquila_hex_lifebringer/lifebringer = allocate(/obj/effect/anomaly/aquila_hex_lifebringer, center)
	lifebringer.catsplosion = FALSE
	var/mob/living/pet = lifebringer.spawn_pet()
	TEST_ASSERT(istype(pet) && pet.loc == center, "The lifebringer anomaly let no animal out")
	allocated += pet
	TEST_ASSERT_EQUAL(lifebringer.pets_left, 9, "The lifebringer anomaly did not count the animal")
	lifebringer.pets_left = 0
	TEST_ASSERT(isnull(lifebringer.spawn_pet()), "The lifebringer anomaly let an animal out over its limit")

	var/mob/living/carbon/human/witness = allocate(/mob/living/carbon/human, get_step(center, EAST))
	var/list/hit = aquila_hex_insanity_pulse(center, 3)
	TEST_ASSERT(witness in hit, "The sanity disruptor pulse missed a human next to it")
	TEST_ASSERT(witness.has_status_effect(/datum/status_effect/hallucination), "The sanity disruptor pulse gave no hallucinations")
	TEST_ASSERT(witness.jitteriness > 0, "The sanity disruptor pulse gave no jitter")
	for(var/i in 1 to 5)
		aquila_hex_insanity_pulse(center, 3)
	TEST_ASSERT(witness.get_hallucination_duration() <= 90 SECONDS, "Repeated sanity disruptor pulses stack hallucinations over 90 s")

	var/obj/effect/anomaly/aquila_hex_blood/blood = allocate(/obj/effect/anomaly/aquila_hex_blood, center)
	blood.shard_chance = 0
	blood.jump_chance = 100
	var/turf/donor_turf = get_step(get_step(center, NORTH), NORTH)
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human, donor_turf)
	blood.anomalyEffect(1)
	TEST_ASSERT(!blood.sucking && !donor.get_bleed_rate(), "The blood anomaly went for a victim standing up")
	donor.set_resting(TRUE)
	blood.anomalyEffect(1)
	TEST_ASSERT(!QDELETED(blood) && blood.loc == donor_turf, "The blood anomaly did not jump onto the lying victim")
	TEST_ASSERT(!QDELETED(blood.countdown), "The jump stripped the blood anomaly of its countdown")
	TEST_ASSERT(blood.sucking, "The blood anomaly is not sucking the lying victim")
	TEST_ASSERT(donor.get_bleed_rate() > 0, "The blood anomaly did not make the victim bleed")
	donor.forceMove(center)
	blood.suck_blood()
	TEST_ASSERT(!blood.sucking, "The blood anomaly keeps sucking with nobody on its tile")
	var/obj/item/projectile/bullet/shrapnel/aquila_hex_bleed/shard = /obj/item/projectile/bullet/shrapnel/aquila_hex_bleed
	TEST_ASSERT(isnull(initial(shard.shrapnel_type)) && !initial(shard.ricochets_max), "The blood shards leave shrapnel or ricochet")

/// The dimensional anomaly turns floors, walls, chairs and tables into one material and tints windows, but leaves the hull
/// and walls with something in them alone, and keeps what hangs next to a wall it changed
/datum/unit_test/aquila_hex_anomalies_dimensional

/datum/unit_test/aquila_hex_anomalies_dimensional/Run()
	var/turf/open/floor/floor = run_loc_floor_bottom_left
	var/floor_type = floor.type
	var/obj/structure/chair/chair = allocate(/obj/structure/chair, floor)
	var/turf/window_spot = get_step(floor, NORTH)
	var/window_spot_type = window_spot.type
	var/list/window_spot_baseturfs = window_spot.baseturfs
	var/obj/structure/window/fulltile/window = allocate(/obj/structure/window/fulltile, window_spot)
	var/turf/wall_spot = get_step(floor, EAST)
	var/wall_spot_type = wall_spot.type
	var/list/wall_spot_baseturfs = wall_spot.baseturfs
	var/obj/item/radio/intercom/intercom = allocate(/obj/item/radio/intercom, get_step(wall_spot, EAST))
	var/fail = check_transmute(floor, chair, window, wall_spot, intercom)
	if(!QDELETED(floor) && floor.type != floor_type)
		floor.ChangeTurf(floor_type)
	if(wall_spot.type != wall_spot_type)
		wall_spot.ChangeTurf(wall_spot_type, wall_spot_baseturfs)
	if(window_spot.type != window_spot_type) // przemiana okna przerabia też podłogę pod nim
		window_spot.ChangeTurf(window_spot_type, window_spot_baseturfs)
	for(var/obj/structure/chair/leftover in floor)
		qdel(leftover)
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_hex_anomalies_dimensional/proc/check_transmute(turf/open/floor/floor, obj/structure/chair/chair, obj/structure/window/window, turf/wall_spot, obj/item/radio/intercom/intercom)
	var/datum/material/gold = SSmaterials.GetMaterialRef(/datum/material/gold)
	if(!aquila_hex_dimensional_transmute(floor, /datum/material/gold))
		return "The dimensional anomaly changed nothing on a floor with a chair"
	var/turf/open/floor/material/gold_floor = run_loc_floor_bottom_left
	if(!istype(gold_floor) || !gold_floor.custom_materials?[gold])
		return "The floor became [gold_floor.type], not a gold floor"
	if(!QDELETED(chair))
		return "The plain chair was not replaced"
	var/obj/structure/chair/greyscale/gold_chair = locate() in gold_floor
	if(!gold_chair?.custom_materials?[gold])
		return "There is no gold chair on the transmuted floor"
	if(aquila_hex_dimensional_can_transmute(gold_floor, /datum/material/gold))
		return "A gold tile with a gold chair can be transmuted to gold again"
	aquila_hex_dimensional_transmute(get_turf(window), /datum/material/gold)
	if(window.color != gold.greyscale_colors)
		return "The window was not tinted gold"

	var/turf/closed/wall/r_wall/hull = wall_spot.ChangeTurf(/turf/closed/wall/r_wall)
	if(aquila_hex_dimensional_can_transmute(hull, /datum/material/gold))
		return "A reinforced wall (the hull) can be transmuted"
	var/turf/closed/wall/ship/ship_hull = hull.ChangeTurf(/turf/closed/wall/ship)
	if(aquila_hex_dimensional_can_transmute(ship_hull, /datum/material/gold))
		return "An NSV hull wall can be transmuted"
	var/turf/closed/wall/wall = ship_hull.ChangeTurf(/turf/closed/wall)
	var/turf/space_spot = get_step(wall_spot, NORTH)
	var/space_spot_type = space_spot.type
	var/list/space_spot_baseturfs = space_spot.baseturfs
	space_spot.ChangeTurf(/turf/open/space)
	var/next_to_space = aquila_hex_dimensional_wall_ok(wall, /datum/material/gold)
	space_spot.ChangeTurf(space_spot_type, space_spot_baseturfs)
	if(next_to_space)
		return "A wall next to space can be transmuted"
	var/obj/structure/sign/sign = new /obj/structure/sign/warning(wall)
	if(aquila_hex_dimensional_wall_ok(wall, /datum/material/gold))
		return "A wall with a sign in it can be transmuted"
	qdel(sign)
	if(!aquila_hex_dimensional_transmute(wall, /datum/material/gold))
		return "The dimensional anomaly did not change a plain wall"
	var/turf/closed/wall/material/gold_wall = wall_spot
	if(!istype(gold_wall) || !gold_wall.custom_materials?[gold])
		return "The wall became [wall_spot.type], not a gold wall"
	gold_wall.drop_material_sheets(gold_floor)
	var/obj/item/stack/sheet/loot = locate() in gold_floor
	if(loot)
		qdel(loot)
		return "A dismantled gold wall from the anomaly gives back gold sheets"
	if(QDELETED(intercom) || intercom.loc != get_step(wall_spot, EAST))
		return "The intercom next to the changed wall fell off or vanished"

/// The dimensional anomaly only uses harmless materials
/datum/unit_test/aquila_hex_anomalies_dimensional_materials

/datum/unit_test/aquila_hex_anomalies_dimensional_materials/Run()
	var/list/safe = list(/datum/material/gold, /datum/material/silver, /datum/material/glass, /datum/material/wood, /datum/material/titanium)
	for(var/material_type in aquila_hex_dimensional_materials())
		TEST_ASSERT(material_type in safe, "The dimensional anomaly can use [material_type]")
	var/obj/effect/anomaly/aquila_hex_dimensional/dimensional = allocate(/obj/effect/anomaly/aquila_hex_dimensional, run_loc_floor_bottom_left)
	for(var/i in 1 to 10)
		dimensional.remove_atom_colour(FIXED_COLOUR_PRIORITY)
		dimensional.prepare_area()
		TEST_ASSERT(dimensional.theme_material in safe, "The dimensional anomaly picked [dimensional.theme_material]")

/// No E3 anomaly leaves an anomaly core when it is neutralised
/datum/unit_test/aquila_hex_anomalies_no_cores

/datum/unit_test/aquila_hex_anomalies_no_cores/Run()
	var/list/anomaly_types = list(
		/obj/effect/anomaly/aquila_hex_bioscrambler,
		/obj/effect/anomaly/aquila_hex_radioactive,
		/obj/effect/anomaly/aquila_hex_storm,
		/obj/effect/anomaly/aquila_hex_frost,
		/obj/effect/anomaly/aquila_hex_gas,
		/obj/effect/anomaly/aquila_hex_lifebringer,
		/obj/effect/anomaly/aquila_hex_insanity_pulse,
		/obj/effect/anomaly/aquila_hex_blood,
		/obj/effect/anomaly/aquila_hex_dimensional,
		/obj/effect/anomaly/aquila_hex_cult_portal,
	)
	var/turf/center = run_loc_floor_bottom_left
	for(var/anomaly_type in anomaly_types)
		var/obj/effect/anomaly/anomaly = new anomaly_type(center)
		anomaly.anomalyNeutralize()
		TEST_ASSERT(QDELETED(anomaly), "[anomaly_type] was not neutralised")
		var/obj/item/assembly/signaler/anomaly/core = locate() in center
		if(core)
			qdel(core)
			return Fail("[anomaly_type] left an anomaly core")
	for(var/obj/effect/particle_effect/smoke/smoke in range(2, center))
		qdel(smoke)

/// The cult portal pretends to be another anomaly, lets 2-3 constructs in, never without a player, and closes
/datum/unit_test/aquila_hex_anomalies_cult_portal

/datum/unit_test/aquila_hex_anomalies_cult_portal/Run()
	var/datum/round_event/aquila_hex_anomaly/cult_portal/event = new(FALSE)
	event.kill()
	TEST_ASSERT(event.announce_kind in aquila_hex_anomaly_kinds(), "The cult portal does not pretend to be another anomaly")
	TEST_ASSERT(event.max_constructs >= 2 && event.max_constructs <= 3, "The cult portal lets [event.max_constructs] constructs in")
	TEST_ASSERT(event.announceWhen > event.startWhen && event.endWhen > event.announceWhen, "The cult portal is announced before it opens")
	qdel(event)

	var/obj/effect/anomaly/aquila_hex_cult_portal/portal = allocate(/obj/effect/anomaly/aquila_hex_cult_portal, run_loc_floor_bottom_left)
	portal.spawns_left = 2
	var/mob/dead/observer/no_player = allocate(/mob/dead/observer, run_loc_floor_top_right)
	TEST_ASSERT(isnull(portal.create_construct(no_player)), "The cult portal made a construct without a player")
	TEST_ASSERT_EQUAL(portal.spawns_left, 2, "A failed construct used up a shell")
	TEST_ASSERT(!(locate(/mob/living/simple_animal/hostile/construct) in run_loc_floor_bottom_left), "An empty construct came out of the portal")

	// The role switch and a cultist ban keep a ghost out, the cooldown holds the next shell back
	var/mob/dead/observer/ghost = allocate(/mob/dead/observer, run_loc_floor_top_right)
	var/datum/client_interface/mock = new
	mock.prefs = new /datum/preferences
	ghost.mock_client = mock
	TEST_ASSERT(aquila_hex_cult_portal_can_join(ghost), "An eligible ghost cannot join through the cult portal")
	mock.aquila_banned_roles = list(ROLE_CULTIST)
	TEST_ASSERT(!aquila_hex_cult_portal_can_join(ghost), "A ghost banned from the cult can join through the cult portal")
	mock.aquila_banned_roles = null
	var/old_flags = GLOB.ghost_role_flags
	GLOB.ghost_role_flags &= ~GHOSTROLE_MIDROUND_EVENT
	var/joined_while_off = aquila_hex_cult_portal_can_join(ghost)
	GLOB.ghost_role_flags = old_flags
	TEST_ASSERT(!joined_while_off, "A ghost can join through the cult portal with the midround ghost roles off")
	COOLDOWN_START(portal, ghost_spawn_cooldown, portal.ghost_spawn_delay)
	TEST_ASSERT(portal.attack_ghost(ghost), "The cult portal did not handle a ghost click")
	TEST_ASSERT_EQUAL(portal.spawns_left, 2, "The cult portal let a construct in during its cooldown")
	ghost.mock_client = null

	// A construct with a mind gets an antagonist: the blood cult or its own
	var/mob/living/simple_animal/hostile/construct/wraith/construct = allocate(/mob/living/simple_animal/hostile/construct/wraith, run_loc_floor_top_right)
	construct.mind_initialize()
	var/datum/antagonist/antag = portal.give_antagonist(construct)
	TEST_ASSERT(istype(antag, /datum/antagonist/cult) || istype(antag, /datum/antagonist/aquila_hex_portal_construct), "The portal construct got [antag?.type || "no antagonist"]")
	TEST_ASSERT(construct.mind.has_antag_datum(antag.type), "The portal construct's mind does not have its antagonist")
	construct.mind.remove_antag_datum(antag.type)

	portal.disable()
	TEST_ASSERT(!portal.enabled, "The cult portal did not close")

/// The mock client answers the role checks of should_include_for_role() with a list of banned roles
/datum/client_interface/var/list/aquila_banned_roles

/datum/client_interface/proc/should_include_for_role(banning_key = BAN_ROLE_ALL_ANTAGONISTS, role_preference_key = null, poll_ignore_key = null, req_hours = 0, feedback = FALSE)
	return !(banning_key in aquila_banned_roles)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
