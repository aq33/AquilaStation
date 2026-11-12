// AQUILA - troopers as basic mobs (tg trooper/ port): shooting, retaliating and calling reinforcements through the AI controller,
// pirate plunder, the spawner with basic mobs, and the Syndicate boarding interiors on KNPC (aq33 decision 2026-11-11).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Armed troopers find a target and shoot it through the AI (pistol, burst and shotgun controllers)
/datum/unit_test/aquila_trooper_shoots

/datum/unit_test/aquila_trooper_shoots/Run()
	var/list/shooters = list(
		/mob/living/basic/trooper/syndicate/ranged = /datum/ai_behavior/basic_ranged_attack/trooper,
		/mob/living/basic/trooper/syndicate/ranged/smg = /datum/ai_behavior/basic_ranged_attack/trooper_burst,
		/mob/living/basic/trooper/syndicate/ranged/shotgun = /datum/ai_behavior/basic_ranged_attack/trooper_shotgun,
		/mob/living/basic/trooper/nanotrasen/ranged = /datum/ai_behavior/basic_ranged_attack/trooper,
		/mob/living/basic/trooper/russian/ranged = /datum/ai_behavior/basic_ranged_attack/trooper,
		/mob/living/basic/trooper/pirate/ranged = /datum/ai_behavior/basic_ranged_attack/trooper,
	)
	for(var/shooter_type in shooters)
		var/mob/living/basic/trooper/shooter = allocate(shooter_type, run_loc_floor_bottom_left)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		var/datum/ai_controller/controller = shooter.ai_controller

		var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
		var/datum/ai_behavior/shoot = GET_AI_BEHAVIOR(shooters[shooter_type])
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, find_target)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "[shooter_type]: the trooper did not pick the human two tiles away")
		controller.SelectBehaviors(1)
		TEST_ASSERT(controller.current_behaviors[shoot], "[shooter_type]: the trooper with a target did not plan its ranged attack")
		var/health_before = victim.health
		controller.ProcessBehavior(1, shoot)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[shooter_type]: the shot did not hit the target")
		TEST_ASSERT(victim.health < health_before, "[shooter_type]: the shot did not hurt the target")
		qdel(recorder)
		qdel(shooter)
		qdel(victim)

/// A hostile NT officer that spots someone calls the officers around: they get the target and walk to the caller;
/// the call has a cooldown
/datum/unit_test/aquila_trooper_calls_reinforcements

/datum/unit_test/aquila_trooper_calls_reinforcements/Run()
	var/mob/living/basic/trooper/nanotrasen/caller_officer = allocate(/mob/living/basic/trooper/nanotrasen, run_loc_floor_bottom_left)
	var/mob/living/basic/trooper/nanotrasen/ranged/helper = allocate(/mob/living/basic/trooper/nanotrasen/ranged, locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/ai_controller/controller = caller_officer.ai_controller
	var/datum/ai_controller/helper_controller = helper.ai_controller

	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	var/datum/ai_behavior/call_help = GET_AI_BEHAVIOR(/datum/ai_behavior/call_reinforcements)
	var/datum/ai_behavior/shout = GET_AI_BEHAVIOR(/datum/ai_behavior/perform_speech)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The officer did not pick the human next to it")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[call_help], "The officer with a target did not plan to call reinforcements")
	TEST_ASSERT(controller.current_behaviors[shout], "The officer did not plan its reinforcement line")
	controller.ProcessBehavior(1, call_help)
	TEST_ASSERT_EQUAL(helper_controller.blackboard[BB_BASIC_MOB_REINFORCEMENT_TARGET], caller_officer, "The officer nearby was not called to the caller")
	TEST_ASSERT(victim in helper_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The officer nearby was not told who to fight")
	TEST_ASSERT(controller.blackboard[BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN] > world.time, "Calling reinforcements did not start the cooldown")
	controller.CancelActions()
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[call_help], "The officer called reinforcements again during the cooldown")

	// The called officer walks to the caller while it has nobody to shoot
	helper_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	helper.forceMove(locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y + 3, run_loc_floor_bottom_left.z))
	victim.forceMove(locate(run_loc_floor_top_right.x, run_loc_floor_top_right.y, run_loc_floor_top_right.z))
	helper_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, caller_officer)
	helper_controller.SelectBehaviors(1)
	TEST_ASSERT(helper_controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/travel_towards/stop_on_arrival)], "The called officer did not plan to walk to the caller")

/// A peaceful NT officer only fights back: hit, it targets the attacker, tells the officers around and calls them
/datum/unit_test/aquila_trooper_peaceful_retaliates

/datum/unit_test/aquila_trooper_peaceful_retaliates/Run()
	var/mob/living/basic/trooper/nanotrasen/peaceful/officer = allocate(/mob/living/basic/trooper/nanotrasen/peaceful, run_loc_floor_bottom_left)
	var/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful/partner = allocate(/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/ai_controller/controller = officer.ai_controller
	var/datum/ai_behavior/from_list = GET_AI_BEHAVIOR(/datum/ai_behavior/target_from_retaliate_list)
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)

	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[find_target], "The peaceful officer looks for targets on its own")
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The peaceful officer attacks without being hit")

	puncher.set_combat_mode(TRUE)
	officer.attack_hand(puncher)
	var/wait_until = world.time + 2 SECONDS // the callback runs asynchronously
	while(world.time < wait_until && !(puncher in partner.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]))
		sleep(1)
	TEST_ASSERT(puncher in partner.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The hit officer did not tell the officer next to it")
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, from_list)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], puncher, "The peaceful officer did not go for the one who hit it")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/call_reinforcements)], "The hit officer did not plan to call reinforcements")

/// A pirate hit takes credits from the ID card of the victim and drops them as a holochip on death
/datum/unit_test/aquila_pirate_plunders

/datum/unit_test/aquila_pirate_plunders/Run()
	var/mob/living/basic/trooper/pirate/melee/pirate = allocate(/mob/living/basic/trooper/pirate/melee, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	var/datum/bank_account/account = new /datum/bank_account("Okradziony test", SSjob.GetJobType(/datum/job/assistant))
	account.account_balance = 100
	card.registered_account = account
	victim.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(victim), ITEM_SLOT_ICLOTHING) // the ID slot needs a jumpsuit
	victim.equip_to_slot_or_del(card, ITEM_SLOT_ID)
	TEST_ASSERT_EQUAL(victim.wear_id, card, "Could not put the ID card on the victim")
	var/datum/ai_controller/controller = pirate.ai_controller

	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets))
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The pirate did not pick the human next to it")
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	TEST_ASSERT(controller.current_behaviors[melee], "The pirate did not plan a melee attack")
	controller.ProcessBehavior(1, melee) // the first step only sets the attack delay
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	pirate.next_move = 0
	pirate.next_click = 0 // the AI attacks through ClickOn(), one click a tick
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The pirate did not hit the human")
	TEST_ASSERT_EQUAL(account.account_balance, 50, "The pirate hit did not take 50 credits")

	var/turf/pirate_turf = get_turf(pirate)
	pirate.death()
	var/obj/item/holochip/loot = locate() in pirate_turf
	TEST_ASSERT(loot, "The dead pirate dropped no holochip")
	TEST_ASSERT_EQUAL(loot.credits, 50, "The holochip of the dead pirate does not hold the plunder")
	qdel(loot)
	qdel(account)

/// The Syndicate spawner makes basic troopers and frees the slot when one is gone
/datum/unit_test/aquila_spawner_basic_troopers

/datum/unit_test/aquila_spawner_basic_troopers/Run()
	var/obj/structure/spawner/syndicate/beacon = allocate(/obj/structure/spawner/syndicate, run_loc_floor_bottom_left)
	var/datum/component/spawner/spawner = beacon.GetComponent(/datum/component/spawner)
	spawner.spawn_delay = 0
	spawner.try_spawn_mob()
	TEST_ASSERT_EQUAL(length(spawner.spawned_mobs), 1, "The beacon did not spawn a trooper")
	var/mob/living/basic/trooper/syndicate/ranged/trooper = spawner.spawned_mobs[1]
	TEST_ASSERT(istype(trooper), "The beacon spawned [trooper ? trooper.type : "nothing"] instead of a basic Syndicate trooper")
	// qdel instead of death(): its gibs would streak in the zero gravity test room, and our drift component refuses
	// a decal already on a move loop (runtime); both signals go to the same handler
	qdel(trooper)
	TEST_ASSERT_EQUAL(length(spawner.spawned_mobs), 0, "A deleted basic trooper still counts for the beacon")

/// Counts KNPC and simple animal hostiles on a boarding interior without loading it (the parsed map keeps the models)
/proc/aquila_count_boarding_mobs(map_path)
	var/datum/parsed_map/parsed = new(file(map_path))
	var/list/result = list("knpc" = 0, "simple" = 0, "unknown" = list())
	var/list/per_key = list()
	for(var/key in parsed.grid_models)
		var/model = parsed.grid_models[key]
		var/knpc = 0
		var/simple = 0
		var/static/regex/mob_path = new(@"/mob/living/[\w/]+", "g")
		mob_path.next = 1
		while(mob_path.Find(model))
			var/found = mob_path.match
			if(!ispath(text2path(found)))
				result["unknown"] |= found
			if(findtext(found, "/mob/living/carbon/human/ai_boarder") == 1)
				knpc++
			else if(findtext(found, "/mob/living/simple_animal/hostile") == 1)
				simple++
		if(knpc || simple)
			per_key[key] = list(knpc, simple)
	for(var/datum/grid_set/grid as anything in parsed.gridSets)
		for(var/line in grid.gridLines)
			line = replacetext(line, ascii2text(13), "") // maps checked out with CRLF
			for(var/position in 1 to length(line) step parsed.key_len)
				var/list/counts = per_key[copytext(line, position, position + parsed.key_len)]
				if(counts)
					result["knpc"] += counts[1]
					result["simple"] += counts[2]
	qdel(parsed)
	return result

/// The Syndicate boarding interiors have only KNPC, as many as planned in raport/mobabilities_05_abordaz.md
/datum/unit_test/aquila_boarding_interiors_knpc

/datum/unit_test/aquila_boarding_interiors_knpc/Run()
	var/list/planned = list(
		"marine_frigate" = 21,
		"carrier" = 14,
		"destroyer" = 13,
		"mako" = 7,
		"mako_carrier" = 7,
		"nukefrigate" = 10,
		"smalloutpost" = 6,
	)
	for(var/map_name in planned)
		var/list/counts = aquila_count_boarding_mobs("_maps/templates/boarding/syndicate/[map_name].dmm")
		TEST_ASSERT_EQUAL(counts["simple"], 0, "[map_name]: simple animal hostiles left on the boarding interior")
		TEST_ASSERT_EQUAL(counts["knpc"], planned[map_name], "[map_name]: wrong number of KNPC")
		var/list/unknown = counts["unknown"]
		TEST_ASSERT(!length(unknown), "[map_name]: unknown mob types [jointext(unknown, ", ")]")

/// Syndicate KNPC carry no microbomb; on a boarding interior a KNPC far from the patrol route guards its post (and walks back
/// to it), one next to a patrol node patrols; with no player on the interior's z level the KNPC wait
/datum/unit_test/aquila_boarding_knpc_posts
	/// Turfs of the test room moved into the boarding interior area, with their own areas
	var/list/moved_turfs = list()

/datum/unit_test/aquila_boarding_knpc_posts/Run()
	var/area/interior = GLOB.areas_by_type[/area/ruin/powered/nsv13/boarding_interior]
	if(!interior)
		interior = new /area/ruin/powered/nsv13/boarding_interior
	for(var/turf/room_turf as anything in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		var/area/own_area = room_turf.loc
		moved_turfs[room_turf] = own_area
		interior.contents += room_turf
		room_turf.change_area(own_area, interior)

	var/turf/post = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/syndicate/pistol/guard = allocate(/mob/living/carbon/human/ai_boarder/syndicate/pistol, post)
	TEST_ASSERT(!(locate(/obj/item/implant/explosive) in guard.implants), "A Syndicate KNPC still carries a microbomb")
	var/obj/effect/landmark/patrol_node/node = allocate(/obj/effect/landmark/patrol_node, run_loc_floor_top_right)
	TEST_ASSERT(get_dist(node, post) > 3, "The test room is too small for a post far from the patrol node")
	var/mob/living/carbon/human/ai_boarder/syndicate/pistol/patroller = allocate(/mob/living/carbon/human/ai_boarder/syndicate/pistol, get_step(run_loc_floor_top_right, WEST))
	var/datum/component/knpc/guard_brain = guard.GetComponent(/datum/component/knpc)
	var/datum/component/knpc/patrol_brain = patroller.GetComponent(/datum/component/knpc)
	TEST_ASSERT(guard_brain.guard_the_post(), "A KNPC far from the patrol route does not guard its post")
	TEST_ASSERT_EQUAL(guard_brain.guard_post, post, "The guard took the wrong post")
	TEST_ASSERT(!patrol_brain.guard_the_post(), "A KNPC next to a patrol node does not patrol")

	// After a chase the guard walks back to its post
	guard.forceMove(get_step(post, NORTHEAST))
	guard_brain.path = list()
	guard_brain.dest = null
	guard_brain.pathfind_timeout = 0
	guard_brain.guard_the_post()
	TEST_ASSERT(length(guard_brain.path) && guard_brain.dest == post, "The guard does not walk back to its post")

	// No player on the interior's z level: the KNPC do nothing (the interior loads when the mission starts)
	guard_brain.next_action = 0
	guard_brain.process()
	TEST_ASSERT_EQUAL(guard_brain.next_action, 0, "A KNPC on an interior without players still acts")

/datum/unit_test/aquila_boarding_knpc_posts/Destroy()
	for(var/turf/room_turf as anything in moved_turfs)
		var/area/own_area = moved_turfs[room_turf]
		var/area/interior = room_turf.loc
		own_area.contents += room_turf
		room_turf.change_area(interior, own_area)
	moved_turfs = null
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
