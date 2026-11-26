// AQUILA - testy eventów z kafli mapy hex, etap E5 (kosmiczna fauna i widowiska za oknem): pule terenów, stwory z przelotów
// (koi, muszki, meduzy, płaszczki, rekiny, wieloryby z młodymi), ich trasa i cele, pas komet i rój dziwnych meteorów
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
		event.end()
		for(var/mob/living/basic/aquila_void_fauna/creature as anything in fauna)
			TEST_ASSERT(isnull(creature.ai_controller?.blackboard[BB_AQUILA_FLYBY_PATH]), "[creature] did not leave when [event_type] ended")
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
	koi.death()
	TEST_ASSERT(!koi.leave_flyby(), "A dead koi flew away")

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

	// The pod strikes back at whoever hurts a calf
	var/mob/living/basic/aquila_void_fauna/space_whale/whale = allocate(/mob/living/basic/aquila_void_fauna/space_whale, far_point)
	var/mob/living/basic/aquila_void_fauna/space_whale/calf/calf = allocate(/mob/living/basic/aquila_void_fauna/space_whale/calf, locate(far_point.x - 1, far_point.y, far_point.z))
	var/mob/living/carbon/human/hunter = allocate(/mob/living/carbon/human, locate(far_point.x - 1, far_point.y - 1, far_point.z))
	SEND_SIGNAL(calf, COMSIG_ATOM_WAS_ATTACKED, hunter)
	TEST_ASSERT(hunter in whale.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The adult whale did not take on the calf's attacker")

/// The comet belt tints the starlight and puts it back; the strange meteors look like their cargo and drop it
/datum/unit_test/aquila_hex_fauna_shows

/datum/unit_test/aquila_hex_fauna_shows/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/datum/round_event/aquila_hex_comet_belt/belt = new(FALSE)
	belt.kill()
	var/old_color = floor.light_color
	belt.lit_space = list(floor)
	belt.next_phase()
	TEST_ASSERT_EQUAL(floor.light_color, belt.belt_colors[1], "The comet belt did not tint the starlight")
	belt.next_phase()
	TEST_ASSERT_EQUAL(floor.light_color, belt.belt_colors[2], "The comet belt did not change the tint")
	belt.tint_space(belt.lit_space, null)
	TEST_ASSERT_EQUAL(floor.light_color, old_color, "The comet belt did not put the starlight back")
	qdel(belt)

	var/list/drops = list(
		/obj/effect/meteor/aquila_fun/cow = /mob/living/basic/cow,
		/obj/effect/meteor/aquila_fun/clown = /obj/item/bikehorn,
		/obj/effect/meteor/aquila_fun/potato = /obj/item/food/grown/potato,
		/obj/effect/meteor/aquila_fun/gnome = /mob/living/basic/garden_gnome,
	)
	for(var/meteor_type in drops)
		var/obj/effect/meteor/aquila_fun/meteor = new meteor_type(floor, run_loc_floor_top_right)
		var/atom/look = meteor.look_like
		TEST_ASSERT_EQUAL(meteor.icon_state, initial(look.icon_state), "[meteor_type] does not look like its cargo")
		TEST_ASSERT(meteor.hitpwr == EXPLODE_LIGHT && meteor.hits == 1, "[meteor_type] is not a weak meteor")
		meteor.get_hit()
		TEST_ASSERT(QDELETED(meteor), "[meteor_type] did not break")
		var/atom/movable/cargo = locate(drops[meteor_type]) in floor
		TEST_ASSERT(cargo, "[meteor_type] dropped no [drops[meteor_type]]")
		for(var/atom/movable/leftover in floor)
			if(ismob(leftover) || isitem(leftover))
				qdel(leftover)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
