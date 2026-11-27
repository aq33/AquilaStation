// AQUILA - testy eventów z kafli mapy hex, etap E5 (kosmiczna fauna i widowiska za oknem): pule terenów, stwory z przelotów
// (koi, muszki, meduzy, płaszczki, rekiny, wieloryby z młodymi), ich trasa na scenie z kosmosem i kadłubem, cele, limit fal,
// odlot na końcu eventu, pas komet i rój dziwnych meteorów
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Each E5 event is in the pool of its own terrain only and does not roll as a plain ship event
/datum/unit_test/aquila_hex_fauna_pools

/datum/unit_test/aquila_hex_fauna_pools/Run()
	var/list/event_terrains = list(
		/datum/round_event_control/aquila_hex_carp_migration_koi = HEX_TERRAIN_CARP,
		/datum/round_event_control/aquila_hex_gnat_migration = HEX_TERRAIN_CARP,
		/datum/round_event_control/aquila_hex_jellyfish_migration = HEX_TERRAIN_CARP,
		/datum/round_event_control/aquila_hex_ray_migration = HEX_TERRAIN_CARP,
		/datum/round_event_control/aquila_hex_shark_migration = HEX_TERRAIN_CARP,
		/datum/round_event_control/aquila_hex_whale_migration = HEX_TERRAIN_CARP,
		/datum/round_event_control/aquila_hex_comet_belt = HEX_TERRAIN_COMET,
		/datum/round_event_control/aquila_hex_fun_swarm = HEX_TERRAIN_ASTEROIDS,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in event_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		for(var/id in GLOB.hex_terrains)
			var/datum/hex_terrain/terrain = GLOB.hex_terrains[id]
			var/in_pool = (path in terrain.events) || (path in terrain.antags)
			if(id == event_terrains[path])
				TEST_ASSERT((path in terrain.events) && !(path in terrain.antags), "[control.name] is not among the events of [id]")
			else
				TEST_ASSERT(!in_pool, "[control.name] is also in a pool of [id]")
		TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// Every flyby event spawns its creatures on the given spots and sends them on the route; whale calves follow an adult
/datum/unit_test/aquila_hex_fauna_spawns

/datum/unit_test/aquila_hex_fauna_spawns/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/turf/far_point = run_loc_floor_top_right
	var/list/spots = list(corner, locate(corner.x + 1, corner.y, corner.z), locate(corner.x, corner.y + 1, corner.z))
	var/list/expected = list(
		/datum/round_event/aquila_hex_fauna_flyby/koi = /mob/living/basic/aquila_void_fauna/koi,
		/datum/round_event/aquila_hex_fauna_flyby/gnats = /mob/living/basic/aquila_void_fauna/gnat,
		/datum/round_event/aquila_hex_fauna_flyby/jellyfish = /mob/living/basic/aquila_void_fauna/jellyfish,
		/datum/round_event/aquila_hex_fauna_flyby/rays = /mob/living/basic/aquila_void_fauna/ray,
		/datum/round_event/aquila_hex_fauna_flyby/sharks = /mob/living/basic/aquila_void_fauna/shark,
	)
	for(var/event_type in expected)
		var/datum/round_event/aquila_hex_fauna_flyby/event = new event_type(FALSE)
		event.kill()
		var/list/fauna = event.spawn_at(spots, list(far_point))
		allocated += fauna
		TEST_ASSERT_EQUAL(length(fauna), length(spots), "[event_type] spawned a wrong number of creatures")
		for(var/mob/living/basic/aquila_void_fauna/creature as anything in fauna)
			TEST_ASSERT(istype(creature, expected[event_type]), "[event_type] spawned [creature.type]")
			TEST_ASSERT(creature.spacewalk && creature.unsuitable_atmos_damage == 0, "[creature] cannot live in space")
			var/list/route = creature.ai_controller?.blackboard[BB_AQUILA_FLYBY_PATH]
			TEST_ASSERT(length(route) == 1 && route[1] == far_point, "[creature] got no flyby route")
		TEST_ASSERT_EQUAL(event.living_fauna(), length(spots), "[event_type] does not count its creatures")
		TEST_ASSERT(!length(event.spawn_group(null, 3, list(far_point))), "[event_type] spawned creatures nowhere")
		var/mob/living/basic/aquila_void_fauna/corpse = fauna[1]
		corpse.death()
		event.leave_fade = 0
		event.end()
		TEST_ASSERT(!length(event.spawned), "[event_type] still tracks its creatures after the end")
		TEST_ASSERT(!QDELETED(corpse) && !(corpse in event.signal_procs), "[event_type] deleted a corpse or kept its signal")
		for(var/mob/living/basic/aquila_void_fauna/creature as anything in fauna - corpse)
			TEST_ASSERT(QDELETED(creature), "[creature] did not leave when [event_type] ended")
		qdel(event)

	var/datum/round_event/aquila_hex_fauna_flyby/whales/pod_event = new(FALSE)
	pod_event.kill()
	var/list/pod = pod_event.spawn_at(spots.Copy(1, 3), list(far_point))
	allocated += pod
	var/adults = 0
	var/calves = 0
	for(var/mob/living/basic/aquila_void_fauna/space_whale/whale as anything in pod)
		if(istype(whale, /mob/living/basic/aquila_void_fauna/space_whale/calf))
			calves++
			var/mob/living/basic/aquila_void_fauna/space_whale/mother = whale.ai_controller?.blackboard[BB_FOUND_MOM]
			TEST_ASSERT(istype(mother) && !istype(mother, /mob/living/basic/aquila_void_fauna/space_whale/calf) && (mother in pod), "A calf follows no adult of its pod")
		else
			adults++
	TEST_ASSERT_EQUAL(adults, 2, "The pod has a wrong number of adults")
	TEST_ASSERT(calves >= 1 && calves <= 2, "The pod has [calves] calves")
	qdel(pod_event)

/// Creatures follow their route and leave at its end; hunters ignore people inside the ship and go for people in space;
/// whales defend their calves; the ray, jellyfish and shark hits do their extra harm
/datum/unit_test/aquila_hex_fauna_behaviour

/datum/unit_test/aquila_hex_fauna_behaviour/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/turf/far_point = run_loc_floor_top_right

	// Route: the point becomes the target and the creature flies towards it; with the route done it leaves
	var/mob/living/basic/aquila_void_fauna/koi/koi = allocate(/mob/living/basic/aquila_void_fauna/koi, corner)
	var/datum/ai_controller/controller = koi.ai_controller
	TEST_ASSERT(koi.fly_by(list(far_point)), "The koi took no route")
	TEST_ASSERT(!controller.can_idle, "A flying koi can still idle")
	controller.SelectBehaviors(1)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_AQUILA_FLYBY_TARGET], far_point, "The route point did not become the target")
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/step_towards_turf)], "The koi does not fly towards its point")
	controller.CancelActions()
	controller.clear_blackboard_key(BB_AQUILA_FLYBY_TARGET)
	controller.SelectBehaviors(1)
	TEST_ASSERT(isnull(controller.blackboard[BB_AQUILA_FLYBY_PATH]), "The koi kept a finished route")
	controller.CancelActions()
	TEST_ASSERT(koi.fly_by(list(far_point)) && koi.fly_by(list(corner)), "A second route crashed the koi")
	var/list/new_route = controller.blackboard[BB_AQUILA_FLYBY_PATH]
	TEST_ASSERT(length(new_route) == 1 && new_route[1] == corner, "The second route did not replace the first")

	// Hunting only in space
	var/turf/space_turf = locate(corner.x + 2, corner.y, corner.z)
	var/old_type = space_turf.type
	var/list/old_baseturfs = space_turf.baseturfs
	space_turf = space_turf.ChangeTurf(/turf/open/space/basic)
	var/mob/living/basic/aquila_void_fauna/shark/shark = allocate(/mob/living/basic/aquila_void_fauna/shark, locate(corner.x + 1, corner.y, corner.z))
	var/mob/living/carbon/human/indoors = allocate(/mob/living/carbon/human, corner)
	var/mob/living/carbon/human/spacewalker = allocate(/mob/living/carbon/human, space_turf)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/aquila_outside_ship)
	var/hunts_indoors = strategy.can_attack(shark, indoors, 9)
	var/hunts_outside = strategy.can_attack(shark, spacewalker, 9)
	var/list/space_spots = aquila_hex_free_space_near(space_turf, 3, 1)
	var/datum/round_event/aquila_hex_comet_belt/belt = new(FALSE)
	belt.kill()
	var/obj/effect/temp_visual/aquila_comet_streak/streak = belt.spawn_streak(space_turf)
	var/no_streak_indoors = isnull(belt.spawn_streak(corner))
	if(streak)
		qdel(streak)
	qdel(spacewalker)
	space_turf.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT(!hunts_indoors, "The shark hunts a human inside the ship")
	TEST_ASSERT(hunts_outside, "The shark does not hunt a human in space")
	TEST_ASSERT(length(space_spots) == 1 && space_spots[1] == space_turf, "Creatures may spawn on [length(space_spots)] turfs around a single space turf")
	TEST_ASSERT(streak, "No comet streak over space")
	TEST_ASSERT(no_streak_indoors, "A comet streak flew inside the ship")

	// Extra harm of the hits
	shark.knockdown_chance = 100
	shark.melee_attack(indoors, null, TRUE)
	TEST_ASSERT(indoors.IsKnockdown(), "The shark bite did not knock down")
	var/mob/living/basic/aquila_void_fauna/ray/ray = allocate(/mob/living/basic/aquila_void_fauna/ray, locate(corner.x, corner.y + 1, corner.z))
	ray.buffet_chance = 100
	var/stamina = indoors.getStaminaLoss()
	ray.melee_attack(indoors, null, TRUE)
	TEST_ASSERT(indoors.getStaminaLoss() > stamina, "The ray buffet did not tire")
	var/mob/living/basic/aquila_void_fauna/jellyfish/jelly = allocate(/mob/living/basic/aquila_void_fauna/jellyfish, locate(corner.x + 1, corner.y + 1, corner.z))
	var/burn = indoors.getFireLoss()
	jelly.melee_attack(indoors, null, TRUE)
	TEST_ASSERT(indoors.getFireLoss() > burn, "The jellyfish sting did not burn")
	jelly.death()
	TEST_ASSERT(!jelly.light_range, "A dead jellyfish still glows")

	// The pod strikes back at whoever hurts a calf
	var/mob/living/basic/aquila_void_fauna/space_whale/whale = allocate(/mob/living/basic/aquila_void_fauna/space_whale, far_point)
	var/mob/living/basic/aquila_void_fauna/space_whale/calf/calf = allocate(/mob/living/basic/aquila_void_fauna/space_whale/calf, locate(far_point.x - 1, far_point.y, far_point.z))
	var/mob/living/carbon/human/hunter = allocate(/mob/living/carbon/human, locate(far_point.x - 1, far_point.y - 1, far_point.z))
	SEND_SIGNAL(calf, COMSIG_ATOM_WAS_ATTACKED, hunter)
	TEST_ASSERT(hunter in whale.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The adult whale did not take on the calf's attacker")

/// Space turfs from origin (width x height) for a test scene: turns them into space and returns what was there
/proc/aquila_fauna_test_space_scene(turf/origin, width, height)
	. = list()
	for(var/turf/T as anything in block(origin, locate(origin.x + width - 1, origin.y + height - 1, origin.z)))
		.[T] = list(T.type, T.baseturfs)
		if(!istype(T, /turf/open/space/basic))
			T.ChangeTurf(/turf/open/space/basic)

/// Puts back the turfs saved by aquila_fauna_test_space_scene()
/proc/aquila_fauna_test_restore_scene(list/saved)
	for(var/turf/T as anything in saved)
		var/list/old = saved[T]
		if(T.type != old[1])
			T.ChangeTurf(old[1], old[2])

/// Flyby event with a fixed route instead of one past the ship
/datum/round_event/aquila_hex_fauna_flyby/aquila_test
	fauna_types = list(/mob/living/basic/aquila_void_fauna/koi = 1)
	var/list/test_route

/datum/round_event/aquila_hex_fauna_flyby/aquila_test/find_route(side, clearance)
	return test_route ? test_route.Copy() : list()

/// The flyby route is made of space only and stops before the hull; creatures never leave space on their own;
/// with no route the event ends before its announcement; waves keep to fauna_cap; no creature comes from gold cores
/datum/unit_test/aquila_hex_fauna_routes
	var/list/scene

/datum/unit_test/aquila_hex_fauna_routes/Destroy()
	aquila_fauna_test_restore_scene(scene)
	return ..()

/datum/unit_test/aquila_hex_fauna_routes/Run()
	// Scene: 17x11 of space east of the test room, a 3x3 hull in the middle and a lone wall on the pass line
	var/turf/origin = locate(run_loc_floor_top_right.x + 4, run_loc_floor_bottom_left.y - 3, run_loc_floor_bottom_left.z)
	scene = aquila_fauna_test_space_scene(origin, 17, 11)
	var/cx = origin.x + 8
	var/cy = origin.y + 5
	var/z = origin.z
	for(var/turf/T as anything in block(locate(cx - 1, cy - 1, z), locate(cx + 1, cy + 1, z)))
		T.ChangeTurf(/turf/closed/wall/ship)
	var/turf/rock = locate(cx + 4, cy + 4, z)
	rock.ChangeTurf(/turf/closed/wall/r_wall)
	var/turf/hull = locate(cx, cy + 2, z)

	var/list/route = aquila_hex_flyby_route_from(hull, NORTH, EAST, 2, 6)
	TEST_ASSERT_EQUAL(length(route), 3, "No flyby route past a hull with space around it")
	TEST_ASSERT(route[1] == locate(cx - 6, cy + 4, z) && route[2] == locate(cx, cy + 4, z), "Wrong start or pass point of the route")
	TEST_ASSERT_EQUAL(route[3], locate(cx + 3, cy + 4, z), "The route does not stop before the wall on its line")
	var/list/flown = getline(hull, route[2]) + getline(route[1], route[2]) + getline(route[2], route[3])
	for(var/turf/T as anything in flown)
		TEST_ASSERT(isspaceturf(T), "The route crosses [T.type] at [T.x],[T.y]")
	TEST_ASSERT(!length(aquila_hex_flyby_route_from(locate(cx, cy, z), NORTH, EAST, 2, 6)), "A route starts inside the hull")

	// Creatures stay in space on their own
	var/turf/deck = locate(cx - 3, cy + 1, z)
	deck.ChangeTurf(/turf/open/floor/plating)
	TEST_ASSERT(!length(aquila_hex_flyby_route_from(deck, NORTH, EAST, 2, 6)), "A route starts on a deck")
	var/mob/living/basic/aquila_void_fauna/koi/koi = allocate(/mob/living/basic/aquila_void_fauna/koi, locate(cx - 3, cy + 2, z))
	var/turf/koi_turf = koi.loc
	TEST_ASSERT(!koi.Move(deck, SOUTH) && koi.loc == koi_turf, "A creature flew from space onto the deck")
	TEST_ASSERT(koi.Move(get_step(koi_turf, NORTH), NORTH), "A creature cannot fly through space")
	qdel(koi)

	// No route: the event ends before it is announced
	var/datum/round_event/aquila_hex_fauna_flyby/aquila_test/lost = new(FALSE)
	lost.start()
	TEST_ASSERT(!length(lost.spawned) && !(lost in SSevents.running), "A flyby without a route did not end")
	qdel(lost)
	for(var/path in subtypesof(/datum/round_event/aquila_hex_fauna_flyby))
		var/datum/round_event/aquila_hex_fauna_flyby/flyby = path
		TEST_ASSERT(initial(flyby.announceWhen) > initial(flyby.startWhen), "[path] is announced before it finds a route")

	// Waves keep to the cap and refill after losses; all creatures start in space and vanish when the event ends
	var/datum/round_event/aquila_hex_fauna_flyby/aquila_test/swarm = new(FALSE)
	swarm.test_route = route
	swarm.fauna_cap = 3
	swarm.groups_min = 2
	swarm.groups_max = 2
	swarm.group_min = 3
	swarm.group_max = 3
	swarm.waves = 3
	swarm.start()
	TEST_ASSERT_EQUAL(length(swarm.spawned), 3, "The first wave does not fill the cap")
	swarm.activeFor = swarm.next_wave
	swarm.tick()
	TEST_ASSERT_EQUAL(length(swarm.spawned), 3, "A wave went over the cap")
	qdel(swarm.spawned[1])
	swarm.tick()
	TEST_ASSERT_EQUAL(swarm.living_fauna(), 3, "A wave did not refill the cap")
	for(var/mob/living/creature as anything in swarm.spawned)
		TEST_ASSERT(isspaceturf(creature.loc), "[creature] spawned on [creature.loc]")
	var/list/swarm_fauna = swarm.spawned.Copy()
	swarm.leave_fade = 0
	swarm.end()
	swarm.kill()
	qdel(swarm)
	for(var/mob/living/creature as anything in swarm_fauna)
		TEST_ASSERT(QDELETED(creature), "[creature] stayed after the event ended")

	for(var/path in typesof(/mob/living/basic/aquila_void_fauna))
		var/mob/living/basic/aquila_void_fauna/fauna = path
		TEST_ASSERT_EQUAL(initial(fauna.gold_core_spawnable), NO_SPAWN, "[path] comes from gold slime cores")
	var/mob/living/basic/aquila_void_fauna/gnat/gnat_type = /mob/living/basic/aquila_void_fauna/gnat
	TEST_ASSERT(!(initial(gnat_type.pass_flags) & PASSMOB), "Gnats swarm through each other")

/// The comet belt tints only space on the ship levels, puts the starlight back on end() and kill(), and leaves the sky
/// to the blood cult eclipse; the strange meteors only dent the hull, bruise who they hit and drop their cargo as items
/datum/unit_test/aquila_hex_fauna_shows
	var/list/scene

/datum/unit_test/aquila_hex_fauna_shows/Destroy()
	aquila_fauna_test_restore_scene(scene)
	return ..()

/datum/unit_test/aquila_hex_fauna_shows/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/turf/origin = locate(run_loc_floor_top_right.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	scene = aquila_fauna_test_space_scene(origin, 4, 6)
	var/turf/sky = origin

	var/list/levels = aquila_hex_ship_zlevels()
	var/datum/round_event/aquila_hex_comet_belt/belt = new(FALSE)
	for(var/turf/T as anything in belt.starlit_space())
		TEST_ASSERT(isspaceturf(T) && T.light_range > 0 && (T.z in levels), "The comet belt would tint [T.type] on z [T.z]")
	var/old_sky = sky.light_color
	var/old_floor = floor.light_color
	belt.lit_space = list(sky, floor)
	belt.next_phase()
	belt.process_tint()
	TEST_ASSERT_EQUAL(sky.light_color, belt.belt_colors[1], "The comet belt did not tint the starlight")
	TEST_ASSERT_EQUAL(floor.light_color, old_floor, "The comet belt tinted a floor")
	belt.next_phase()
	belt.process_tint()
	TEST_ASSERT_EQUAL(sky.light_color, belt.belt_colors[2], "The comet belt did not change the tint")
	belt.end()
	TEST_ASSERT_EQUAL(sky.light_color, old_sky, "end() did not put the starlight back")
	belt.kill()
	qdel(belt)

	var/datum/round_event/aquila_hex_comet_belt/killed = new(FALSE)
	killed.lit_space = list(sky)
	killed.next_phase()
	killed.process_tint()
	killed.kill()
	qdel(killed)
	TEST_ASSERT_EQUAL(sky.light_color, old_sky, "kill() did not put the starlight back")

	var/hell_was = SShell_universe.hell_time
	SShell_universe.hell_time = TRUE
	var/datum/round_event/aquila_hex_comet_belt/eclipsed = new(FALSE)
	eclipsed.lit_space = list(sky)
	eclipsed.next_phase()
	eclipsed.process_tint()
	var/eclipse_color = sky.light_color
	eclipsed.kill()
	SShell_universe.hell_time = hell_was
	qdel(eclipsed)
	TEST_ASSERT_EQUAL(eclipse_color, old_sky, "The comet belt tinted the sky during the eclipse")

	// Meteors against the hull: walls stay, get a dent, nothing explodes, the cargo lands as items
	var/turf/ship_spot = locate(origin.x, origin.y, origin.z)
	var/turf/reinforced_spot = locate(origin.x, origin.y + 2, origin.z)
	var/list/walls = list(ship_spot.ChangeTurf(/turf/closed/wall/ship), reinforced_spot.ChangeTurf(/turf/closed/wall/r_wall))
	var/list/drops = list(
		/obj/effect/meteor/aquila_fun/cow = /obj/item/food/meat/slab,
		/obj/effect/meteor/aquila_fun/clown = /obj/item/bikehorn,
		/obj/effect/meteor/aquila_fun/potato = /obj/item/food/grown/potato,
		/obj/effect/meteor/aquila_fun/gnome = /obj/item/aquila_gnome_figurine,
	)
	for(var/meteor_type in drops)
		for(var/turf/closed/wall/wall as anything in walls)
			var/wall_type = wall.type
			var/turf/flight = get_step(wall, EAST)
			var/obj/effect/meteor/aquila_fun/meteor = new meteor_type(flight, locate(flight.x + 2, flight.y, flight.z))
			var/atom/look = meteor.look_like
			TEST_ASSERT_EQUAL(meteor.icon_state, initial(look.icon_state), "[meteor_type] does not look like its cargo")
			meteor.Bump(wall)
			TEST_ASSERT(QDELETED(meteor), "[meteor_type] did not break on [wall_type]")
			TEST_ASSERT(wall.type == wall_type && LAZYLEN(wall.dent_decals), "[meteor_type] broke [wall_type] or left no dent")
			TEST_ASSERT(!(wall in SSexplosions.lowturf) && !(wall in SSexplosions.medturf) && !(wall in SSexplosions.highturf), "[meteor_type] blew up [wall_type]")
			TEST_ASSERT(locate(drops[meteor_type]) in flight, "[meteor_type] dropped no [drops[meteor_type]]")
			for(var/atom/movable/leftover in flight)
				TEST_ASSERT(!ismob(leftover), "[meteor_type] dropped a creature: [leftover]")
				qdel(leftover)

	// A meteor flying through a crewman's turf bruises him without blowing up the turf
	var/turf/crossing = locate(origin.x + 2, origin.y + 4, origin.z)
	var/mob/living/carbon/human/crewman = allocate(/mob/living/carbon/human, crossing)
	var/obj/effect/meteor/aquila_fun/potato/spud = new(get_step(crossing, WEST), get_step(crossing, EAST))
	spud.ram_turf(crossing)
	var/bruise = crewman.getBruteLoss()
	var/max_bruise = spud.impact_damage
	qdel(spud)
	TEST_ASSERT(bruise > 0 && bruise <= max_bruise, "A strange meteor hit for [bruise] brute")
	TEST_ASSERT(!(crossing in SSexplosions.lowturf), "A strange meteor blew up the turf it flew through")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
