// AQUILA - testy eventów z kafli mapy hex, etap E8 (Syndykat i najazdy z innych wymiarów): pule terenów, uśpieni agenci,
// saperzy Syndykatu, zamach, porzucony IPC, rozdarcie wymiarów, rozdarcie klaunów i inwazja demonów
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Each E8 event is in the right pool of its own terrain only and does not roll as a plain ship event.
/// Base of the other E8 tests: they clean up whatever appeared on their turfs.
/datum/unit_test/aquila_hex_incursions
	/// Pola testu => to, co na nich było przed testem
	var/list/watched_turfs = list()

/datum/unit_test/aquila_hex_incursions/proc/watch(turf/T)
	if(T && !watched_turfs[T])
		watched_turfs[T] = T.contents.Copy()
	return T

/// Pole testu przesunięte o dx, dy od lewego dolnego rogu, pod obserwacją
/datum/unit_test/aquila_hex_incursions/proc/spot(dx, dy)
	return watch(locate(run_loc_floor_bottom_left.x + dx, run_loc_floor_bottom_left.y + dy, run_loc_floor_bottom_left.z))

/// Wszystkie pola pokoju testu pod obserwacją
/datum/unit_test/aquila_hex_incursions/proc/watch_room()
	for(var/turf/T as anything in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		watch(T)

/// Opróżnia kapsułę (bez wysypywania zawartości) i ją usuwa
/datum/unit_test/aquila_hex_incursions/proc/scrap_pod(obj/structure/closet/supplypod/pod)
	for(var/atom/movable/content as anything in pod.contents)
		qdel(content)
	qdel(pod)

/datum/unit_test/aquila_hex_incursions/Destroy()
	for(var/turf/T as anything in watched_turfs)
		var/list/before = watched_turfs[T]
		for(var/atom/movable/AM as anything in T.contents)
			if(!(AM in before) && !QDELETED(AM))
				qdel(AM)
	watched_turfs.Cut()
	return ..()

/datum/unit_test/aquila_hex_incursions/Run()
	var/list/event_terrains = list(
		/datum/round_event_control/aquila_hex_syndie_bombsquad = HEX_TERRAIN_MINES,
		/datum/round_event_control/aquila_hex_syndicate_assassination = HEX_TERRAIN_MINES,
		/datum/round_event_control/aquila_hex_tear = HEX_TERRAIN_FLARE,
		/datum/round_event_control/aquila_hex_demon_incursion = HEX_TERRAIN_FLARE,
		/datum/round_event_control/aquila_hex_tear_honk = HEX_TERRAIN_WORMHOLE,
	)
	var/list/antag_terrains = list(
		/datum/round_event_control/aquila_hex_sleeper_agent = HEX_TERRAIN_MINES,
		/datum/round_event_control/aquila_hex_abandoned_ipc = HEX_TERRAIN_JUNK,
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
		else
			TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")
	TEST_ASSERT(ispath(hex_event_control(/datum/round_event_control/aquila_hex_abandoned_ipc).typepath, /datum/round_event/ghost_role), "The abandoned IPC does not check the ghost role switch")

/// Sleeper agents: the broadcast reads four groups of digits, only listeners with their headset on hear it, the candidates
/// follow the dynamic traitor rules, nobody is broadcast to without a candidate, and an awakened agent gets a traitor and a drop
/datum/unit_test/aquila_hex_incursions/sleeper_agent

/datum/unit_test/aquila_hex_incursions/sleeper_agent/Run()
	var/numbers = aquila_hex_numbers_broadcast()
	TEST_ASSERT_EQUAL(length(splittext(numbers, ". ")), 4, "The numbers broadcast is not four groups: [numbers]")
	TEST_ASSERT_EQUAL(length(splittext(numbers, "-")), 9, "The numbers broadcast does not have three digits per group: [numbers]")
	var/list/restricted = aquila_hex_sleeper_restricted_roles()
	TEST_ASSERT((JOB_NAME_CYBORG in restricted) && (JOB_NAME_AI in restricted), "Silicons can be woken as sleeper agents")

	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human, spot(0, 0))
	var/mob/living/carbon/human/deaf_radio = allocate(/mob/living/carbon/human, spot(1, 0))
	listener.equip_to_slot_or_del(new /obj/item/radio/headset(listener), ITEM_SLOT_EARS)
	var/obj/item/radio/headset/off_headset = new(deaf_radio)
	deaf_radio.equip_to_slot_or_del(off_headset, ITEM_SLOT_EARS)
	off_headset.on = FALSE
	GLOB.player_list += list(listener, deaf_radio)
	var/list/listeners = aquila_hex_radio_listeners()
	GLOB.player_list -= list(listener, deaf_radio)
	if(is_station_level(listener.z))
		TEST_ASSERT(listener in listeners, "A crew member with a headset on does not hear the broadcast")
	TEST_ASSERT(!(deaf_radio in listeners), "A crew member with the headset off hears the broadcast")
	TEST_ASSERT(!aquila_hex_sleeper_candidate_ok(listener), "A body without a player can become a sleeper agent")
	TEST_ASSERT(!length(aquila_hex_sleeper_candidates(list(listener))), "A body without a player is a sleeper candidate")

	var/datum/round_event/aquila_hex_sleeper_agent/event = new(FALSE)
	event.kill()
	event.start() // nikt z graczy nie słucha
	TEST_ASSERT(!length(event.candidate_refs) && isnull(event.numbers_text), "The numbers went out with no candidate to wake")
	TEST_ASSERT(isnull(event.awaken(listener)), "A body without a player was awakened")

	listener.mind_initialize()
	var/datum/antagonist/traitor/traitor = new
	traitor.give_objectives = FALSE
	traitor.should_equip = FALSE
	traitor.silent = TRUE
	TEST_ASSERT_EQUAL(event.make_agent(listener, traitor), traitor, "The sleeper agent did not become a traitor")
	TEST_ASSERT(listener.mind.has_antag_datum(/datum/antagonist/traitor), "The awakened agent has no traitor datum")
	TEST_ASSERT(listener.mind in event.awakened, "The awakened agent is not counted")
	var/datum/weakref/drop_ref = length(event.drop_refs) ? event.drop_refs[1] : null
	var/obj/item/storage/box/aquila_hex_sleeper_drop/drop = drop_ref?.resolve()
	if(drop) // na mapie testów może nie być bezpiecznego pomieszczenia
		watch(get_turf(drop))
		TEST_ASSERT(drop.owner_ref?.resolve() == listener.mind, "The sleeper drop is not for the awakened agent")
		TEST_ASSERT(locate(/obj/item/stack/telecrystal) in drop, "The sleeper drop has no telecrystals")
		TEST_ASSERT(locate(/obj/item/encryptionkey/syndicate) in drop, "The sleeper drop has no Syndicate key")
		var/area/drop_area = get_area(drop)
		TEST_ASSERT(drop_area && !aquila_hex_closed_area_type(drop_area.type), "The sleeper drop is in a closed area")
		TEST_ASSERT(findtext(listener.mind.memory, "Skrytka Syndykatu"), "The agent does not remember where the drop is")
		qdel(drop)
	listener.mind.remove_antag_datum(/datum/antagonist/traitor)
	qdel(event)

/// The bomb squad pod carries the troopers and an armed small bomb with fixed wires; cutting the activation wire defuses
/// it for good, and next to a window the bomb only burns
/datum/unit_test/aquila_hex_incursions/bombsquad

/datum/unit_test/aquila_hex_incursions/bombsquad/Run()
	var/datum/round_event/aquila_hex_syndie_bombsquad/event = new(FALSE)
	event.kill()
	event.squad_size = 3
	var/obj/structure/closet/supplypod/pod = event.make_pod()
	TEST_ASSERT_EQUAL(pod.explosionSize[3], 0, "The bomb squad pod explodes on landing")
	var/troopers = 0
	for(var/mob/living/basic/trooper/syndicate/trooper in pod)
		troopers++
		TEST_ASSERT_EQUAL(trooper.environment_smash, ENVIRONMENT_SMASH_NONE, "[trooper] smashes obstacles")
	TEST_ASSERT_EQUAL(troopers, 3, "Wrong number of troopers in the pod")
	var/obj/machinery/syndicatebomb/aquila_hex_squad/bomb = locate() in pod
	TEST_ASSERT(bomb?.active && bomb.anchored, "The pod has no armed, bolted bomb")
	TEST_ASSERT(bomb.seconds_remaining() >= 290, "The bomb fuse is shorter than five minutes")
	var/obj/item/bombcore/aquila_hex_squad/core = bomb.payload
	TEST_ASSERT(istype(core) && !core.range_heavy && !core.range_medium && core.range_light <= 2, "The bomb core is not the small one")
	TEST_ASSERT(!bomb.wires.randomize && bomb.wires.colors == GLOB.wire_color_directory[bomb.type], "The bomb wires are not in the fixed order of the blueprints")

	bomb.wires.cut(WIRE_ACTIVATE)
	TEST_ASSERT(!bomb.active, "Cutting the activation wire did not stop the bomb")
	bomb.process()
	TEST_ASSERT(core.inert, "The defused core is not inert")
	core.detonate()
	TEST_ASSERT(!QDELETED(bomb) && !QDELETED(core), "An inert core went off")
	scrap_pod(pod)

	var/turf/floor = spot(2, 2)
	TEST_ASSERT(!aquila_hex_bomb_spot_ok(null), "A bomb spot was found nowhere")
	var/turf/hole = spot(4, 2)
	var/hole_type = hole.type
	hole.ChangeTurf(/turf/open/space)
	var/near_space_ok = aquila_hex_bomb_spot_ok(floor)
	var/obj/item/bombcore/aquila_hex_squad/loose_core = new(floor)
	var/near_space_range = loose_core.light_range_at(floor)
	hole.ChangeTurf(hole_type)
	TEST_ASSERT(!near_space_ok, "A bomb spot two tiles from space is safe")
	TEST_ASSERT_EQUAL(near_space_range, 0, "The bomb would blast two tiles from space")
	loose_core.detonate()
	TEST_ASSERT(!QDELETED(loose_core), "A core outside the bomb went off")
	qdel(loose_core)
	qdel(event)

/// The assassination pod brings two to four weak thugs, never lands on the victim and skips bodies without a player
/datum/unit_test/aquila_hex_incursions/assassination

/datum/unit_test/aquila_hex_incursions/assassination/Run()
	watch_room()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!aquila_hex_assassination_target_ok(victim), "A body without a player is an assassination target")
	var/turf/landing = aquila_hex_assassination_landing(victim)
	if(landing) // pokój testu może nie należeć do statku
		var/dist = get_dist(landing, victim)
		TEST_ASSERT(dist >= 3 && dist <= 6, "The assassination pod lands [dist] tiles from the victim")
		TEST_ASSERT(aquila_hex_free_safe_turf(landing), "The assassination pod lands on a blocked or unsafe floor")
	var/datum/round_event/aquila_hex_syndicate_assassination/event = new(FALSE)
	event.kill()
	event.thug_count = 4
	var/obj/structure/closet/supplypod/pod = event.make_pod()
	TEST_ASSERT_EQUAL(pod.explosionSize[3], 0, "The assassination pod explodes on landing")
	var/thugs = 0
	for(var/mob/living/basic/trooper/syndicate/thug in pod)
		thugs++
		TEST_ASSERT(istype(thug, /mob/living/basic/trooper/syndicate/melee) || istype(thug, /mob/living/basic/trooper/syndicate/ranged), "[thug.type] is not a weak thug")
		TEST_ASSERT(!istype(thug, /mob/living/basic/trooper/syndicate/melee/sword) && !istype(thug, /mob/living/basic/trooper/syndicate/ranged/smg), "[thug.type] is too strong for a thug")
		TEST_ASSERT_EQUAL(thug.environment_smash, ENVIRONMENT_SMASH_NONE, "A thug smashes obstacles")
	TEST_ASSERT_EQUAL(thugs, 4, "Wrong number of thugs in the pod")
	scrap_pod(pod)
	event.start() // bez celu: nic nie leci
	TEST_ASSERT(!(locate(/obj/effect/pod_landingzone) in range(7, victim)), "A pod was sent with no victim")
	qdel(event)

/// The abandoned IPC wakes as a damaged IPC with only tunnel access, two corrupted directives and a survival goal
/datum/unit_test/aquila_hex_incursions/abandoned_ipc

/datum/unit_test/aquila_hex_incursions/abandoned_ipc/Run()
	var/datum/round_event/ghost_role/aquila_hex_abandoned_ipc/event = new(FALSE)
	event.kill()
	var/mob/living/carbon/human/robot = event.make_ipc(spot(0, 0), null)
	TEST_ASSERT(istype(robot) && isipc(robot), "No abandoned IPC")
	allocated += robot
	TEST_ASSERT(robot.getBruteLoss() > 0, "The abandoned IPC is not damaged")
	var/obj/item/card/id/card = robot.wear_id
	TEST_ASSERT(istype(card) && card.access ~= list(ACCESS_MAINT_TUNNELS), "The abandoned IPC has more than tunnel access")
	TEST_ASSERT(locate(/obj/item/weldingtool) in robot.GetAllContents(), "The abandoned IPC has nothing to patch itself up")
	TEST_ASSERT(!(locate(/obj/item/card/emag) in robot.GetAllContents()), "The abandoned IPC has an emag")
	robot.mind_initialize()
	var/datum/antagonist/aquila_hex_abandoned_ipc/antag = robot.mind.add_antag_datum(/datum/antagonist/aquila_hex_abandoned_ipc)
	TEST_ASSERT(istype(antag) && length(antag.directives) == 2, "The abandoned IPC has no corrupted directives")
	TEST_ASSERT(locate(/datum/objective/survive) in antag.objectives, "The abandoned IPC has no survival goal")
	TEST_ASSERT(GLOB.role_preference_entries[/datum/role_preference/midround_ghost/aquila_abandoned_ipc], "The abandoned IPC has no ghost role preference")

	// wybrany duch bez klucza (wyszedł w trakcie ankiety): żadnego pustego ciała
	var/mob/dead/observer/keyless = allocate(/mob/dead/observer, run_loc_floor_top_right)
	event.priority_candidates = list(keyless)
	var/mobs_before = length(GLOB.mob_living_list)
	TEST_ASSERT_EQUAL(event.spawn_role(), NOT_ENOUGH_PLAYERS, "The abandoned IPC spawned for a ghost with no key")
	TEST_ASSERT_EQUAL(length(GLOB.mob_living_list), mobs_before, "The abandoned IPC made a body for a ghost with no key")
	event.priority_candidates = list()
	qdel(event)

/// The dimensional tear lets out its creatures one by one onto free floor (the leader last), never more than its count,
/// all in one faction with an AI that does not attack obstacles; the honk tear lets out clowns that only hit back
/datum/unit_test/aquila_hex_incursions/tear

/datum/unit_test/aquila_hex_incursions/tear/Run()
	watch_room()
	var/datum/round_event/aquila_hex_tear/event = new(FALSE)
	event.kill()
	event.tear_turf = spot(2, 2)
	var/obj/effect/aquila_hex_tear/tear = event.open_tear()
	TEST_ASSERT(istype(tear) && tear.loc == event.tear_turf, "No dimensional tear opened")
	TEST_ASSERT(tear.spawn_max >= 5 && tear.spawn_max <= 10, "The tear lets out [tear.spawn_max] creatures")
	tear.spawn_max = 3
	for(var/i in 1 to 5)
		tear.spawn_next()
	TEST_ASSERT_EQUAL(tear.spawned, 3, "The tear let out more creatures than its count")
	var/mob/living/basic/leader
	for(var/datum/weakref/creature_ref as anything in tear.spawned_refs)
		var/mob/living/basic/creature = creature_ref.resolve()
		TEST_ASSERT(creature, "A tear creature is gone")
		TEST_ASSERT(creature.faction ~= list(AQUILA_HEX_RIFT_FACTION), "[creature] is not in the rift faction")
		TEST_ASSERT_EQUAL(creature.environment_smash, ENVIRONMENT_SMASH_NONE, "[creature] smashes obstacles")
		TEST_ASSERT(istype(creature.ai_controller, /datum/ai_controller/basic_controller/simple_hostile), "[creature] has an AI that attacks obstacles")
		TEST_ASSERT(!(locate(/obj/machinery/door) in creature.loc), "[creature] came out in a doorway")
		leader = creature
	TEST_ASSERT(istype(leader, /mob/living/basic/aquila_hellhound/alpha), "The last creature is not the hellhound leader")
	TEST_ASSERT_EQUAL(initial(leader.gold_core_spawnable), NO_SPAWN, "The hellhound comes from gold cores")
	event.end()
	TEST_ASSERT(QDELETED(tear), "The tear did not close at the end of the event")
	qdel(event)

	var/datum/round_event/aquila_hex_tear/honk/honk_event = new(FALSE)
	honk_event.kill()
	honk_event.tear_turf = spot(2, 2)
	var/obj/effect/aquila_hex_tear/honk/honk_tear = honk_event.open_tear()
	TEST_ASSERT(istype(honk_tear), "No honk tear opened")
	honk_tear.spawn_max = 2
	honk_tear.spawn_next()
	honk_tear.spawn_next()
	TEST_ASSERT_EQUAL(length(honk_tear.spawned_refs), 2, "The honk tear did not let out its clowns")
	for(var/datum/weakref/clown_ref as anything in honk_tear.spawned_refs)
		var/mob/living/basic/clown/clown = clown_ref.resolve()
		TEST_ASSERT(istype(clown), "Something other than a clown came out of the honk tear")
		TEST_ASSERT(istype(clown.ai_controller, /datum/ai_controller/basic_controller/clown), "A clown from the honk tear lost its clown AI")
	TEST_ASSERT(istype(clown_ref_last(honk_tear), /mob/living/basic/clown/clownhulk/honkmunculus), "The honk tear leader is not the honkmunculus")
	qdel(honk_tear)
	qdel(honk_event)

/// Ostatni stwór wypuszczony przez rozdarcie
/datum/unit_test/aquila_hex_incursions/tear/proc/clown_ref_last(obj/effect/aquila_hex_tear/tear)
	var/datum/weakref/last_ref = tear.spawned_refs[length(tear.spawned_refs)]
	return last_ref.resolve()

/// The demon incursion stays within its portal, living creature and total creature limits, and a destroyed portal leaves the incursion
/datum/unit_test/aquila_hex_incursions/demon_incursion

/datum/unit_test/aquila_hex_incursions/demon_incursion/Run()
	watch_room()
	var/datum/round_event/aquila_hex_demon_incursion/event = new(FALSE)
	event.kill()
	event.max_portals = 2
	event.max_total_spawns = 2
	event.max_creatures = 1
	var/obj/structure/aquila_hex_demon_portal/portal = event.open_portal(spot(0, 0))
	TEST_ASSERT(istype(portal) && portal.incursion == event, "No demon portal opened")
	TEST_ASSERT(event.opened && (portal in event.portals), "The incursion does not count its portal")
	var/obj/structure/aquila_hex_demon_portal/second = event.open_portal(spot(4, 4))
	TEST_ASSERT(istype(second), "The second portal did not open")
	TEST_ASSERT(isnull(event.open_portal(spot(4, 0))), "A portal opened over the portal limit")
	TEST_ASSERT(isnull(event.spread()), "The incursion spread over its portal limit")

	var/mob/living/first = event.portal_spawn(portal)
	TEST_ASSERT(istype(first), "The portal let out no creature")
	TEST_ASSERT(first.faction ~= list(AQUILA_HEX_RIFT_FACTION), "The incursion creature is not in the rift faction")
	TEST_ASSERT(isnull(event.portal_spawn(second)), "A portal let out a creature over the living creature limit")
	event.max_creatures = 5
	TEST_ASSERT(event.portal_spawn(second), "The second portal let out no creature")
	TEST_ASSERT(isnull(event.portal_spawn(portal)), "A portal let out a creature over the total limit")
	TEST_ASSERT_EQUAL(event.total_spawned, 2, "The incursion counted its creatures wrong")
	TEST_ASSERT(portal.next_spawn > world.time, "The portal has no spawn cooldown")

	qdel(second)
	TEST_ASSERT(!(second in event.portals), "A destroyed portal is still counted")
	qdel(portal)
	TEST_ASSERT(!length(event.portals), "The incursion still has portals")
	qdel(event)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
