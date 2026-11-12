// AQUILA - basic mob families of part 2 (tg 926bf40c5a): hivebots, goose, simple xenomorphs, carp.
// The AI is exercised through the controller (SelectBehaviors / ProcessBehavior); the framework test mobs and helpers
// (aquila_bullet_recorder, aquila_wait_for_hit) are in aquila_mob_abilities.dm.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define LEFT_CLICK "icon-x=16;icon-y=16;left=1;button=left"

/// Records what a mob says
/datum/aquila_say_recorder
	var/list/messages = list()

/datum/aquila_say_recorder/proc/on_say(datum/source, list/speech_args)
	SIGNAL_HANDLER
	messages += speech_args[SPEECH_MESSAGE]

/// Hivebots: the ranged ones shoot their target through the AI (and a player in one shoots by clicking), the plain one
/// claws, a dead hivebot falls apart into debris, and they beep binary at each other although they are silent mobs
/datum/unit_test/aquila_hivebot_family

/datum/unit_test/aquila_hivebot_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)

	// Ranged hivebots shoot a human three tiles away
	for(var/shooter_type in list(/mob/living/basic/hivebot/range, /mob/living/basic/hivebot/rapid, /mob/living/basic/hivebot/strong))
		var/mob/living/basic/hivebot/shooter = allocate(shooter_type, corner)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 3, corner.y, corner.z))
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		var/datum/ai_controller/controller = shooter.ai_controller
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, find_target)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "[shooter_type] did not pick the human three tiles away")
		controller.SelectBehaviors(1)
		var/shoot_type = shooter_type == /mob/living/basic/hivebot/rapid ? /datum/ai_behavior/basic_ranged_attack/hivebot_rapid : /datum/ai_behavior/basic_ranged_attack/hivebot
		var/datum/ai_behavior/shoot = GET_AI_BEHAVIOR(shoot_type)
		TEST_ASSERT(controller.current_behaviors[shoot], "[shooter_type] with a target did not plan its ranged attack")
		var/health_before = victim.health
		controller.ProcessBehavior(1, shoot)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[shooter_type]: the shot did not hit the human")
		TEST_ASSERT(istype(recorder.projectiles[1], /obj/item/projectile/hivebotbullet), "[shooter_type] did not fire a hivebot bullet")
		TEST_ASSERT(victim.health < health_before, "[shooter_type]: the shot did not hurt")
		controller.CancelActions()

		// A ghost in the hivebot shoots by clicking the far human
		controller.set_ai_status(AI_STATUS_OFF)
		recorder.projectiles.Cut()
		var/datum/component/ranged_attacks/ranged = shooter.GetComponent(/datum/component/ranged_attacks)
		COOLDOWN_RESET(ranged, fire_cooldown)
		shooter.next_click = 0
		shooter.next_move = 0
		shooter.ClickOn(victim, LEFT_CLICK)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[shooter_type]: a player click on a far target did not shoot")
		qdel(recorder)
		qdel(shooter)
		qdel(victim)

	// The plain hivebot has no gun and claws
	var/mob/living/basic/hivebot/clawer = allocate(/mob/living/basic/hivebot, corner)
	TEST_ASSERT(!clawer.GetComponent(/datum/component/ranged_attacks), "The plain hivebot has a gun")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(corner, EAST))
	var/datum/ai_controller/controller = clawer.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_target)
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	TEST_ASSERT(controller.current_behaviors[melee], "The plain hivebot did not plan a melee attack")
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	clawer.next_move = 0
	clawer.next_click = 0
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The plain hivebot did not claw the human")
	controller.CancelActions()
	qdel(victim)

	// Hive chatter: a silent hivebot still beeps binary at its partner
	var/mob/living/basic/hivebot/partner = allocate(/mob/living/basic/hivebot, get_step(corner, NORTH))
	TEST_ASSERT(!clawer.should_talk, "The hivebot is not a silent mob any more")
	var/datum/aquila_say_recorder/speech = new
	speech.RegisterSignal(clawer, COMSIG_MOB_SAY, TYPE_PROC_REF(/datum/aquila_say_recorder, on_say))
	controller.set_blackboard_key("BB_hive_partner", partner)
	controller.queue_behavior(/datum/ai_behavior/relay_message, "BB_hive_partner")
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/relay_message))
	TEST_ASSERT(length(speech.messages), "The hivebot did not beep at its partner")
	var/beep = speech.messages[1]
	var/digits = copytext(beep, 1, 5)
	TEST_ASSERT(length(digits) == 4 && !length(replacetext(replacetext(digits, "0", ""), "1", "")), "The hivebot said [beep] instead of four binary digits")
	TEST_ASSERT(!clawer.should_talk, "Beeping left the hivebot able to talk")
	qdel(speech)

	// Death: it falls apart into robot debris
	var/turf/death_turf = get_turf(clawer)
	clawer.death()
	TEST_ASSERT(QDELETED(clawer), "A dead hivebot was not deleted")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/robot_debris) in death_turf, "A dead hivebot left no robot debris")

/// Goose: the AI finds food right next to it and gobbles it up (and ignores other junk), plastic chokes it to death,
/// a player feeds it by hand; Birdboat keeps what it eats and throws it all up through its ability, used by the AI
/datum/unit_test/aquila_goose_family

/datum/unit_test/aquila_goose_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/goose/goose = allocate(/mob/living/basic/goose, corner)
	var/datum/ai_controller/controller = goose.ai_controller
	// Keep it calm: no random anger during the test
	controller.set_blackboard_key(BB_RANDOM_AGGRO_CHANCE, 0.0001) // 0 falls back to the default
	var/obj/item/wrench/junk = allocate(/obj/item/wrench, get_step(corner, NORTH))
	var/obj/item/food/cookie/cookie = allocate(/obj/item/food/cookie, get_step(corner, EAST))
	var/datum/ai_behavior/find_food = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list/goose_food)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)

	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[find_food], "The goose did not plan to look for food")
	controller.ProcessBehavior(1, find_food)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], cookie, "The goose did not go for the cookie next to it (or went for the wrench)")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[melee], "The goose with food in sight did not plan to peck at it")
	controller.ProcessBehavior(1, melee) // the first run only sets the attack delay
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	goose.next_move = 0
	goose.next_click = 0
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(QDELETED(cookie), "The goose did not eat the cookie")
	TEST_ASSERT(!QDELETED(junk) && junk.loc == get_step(corner, NORTH), "The goose ate or moved the wrench")
	controller.CancelActions()

	// Plastic: the goose chokes on it and dies when the choking runs out
	var/obj/item/stack/sheet/plastic/plastic = allocate(/obj/item/stack/sheet/plastic, get_step(corner, EAST))
	TEST_ASSERT(goose_is_plastic(plastic), "A plastic sheet does not count as plastic")
	controller.set_blackboard_key(BB_NEXT_FOOD_EAT, 0)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_food)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], plastic, "The goose did not go for the plastic")
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	goose.next_move = 0
	goose.next_click = 0
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(plastic.loc == goose, "The goose did not swallow the plastic")
	var/datum/status_effect/goose_choking/choking = goose.has_status_effect(/datum/status_effect/goose_choking)
	TEST_ASSERT(choking, "The goose is not choking on the plastic")
	TEST_ASSERT(controller.blackboard[BB_GOOSE_PANICKED], "A choking goose does not panic")
	controller.CancelActions()
	controller.set_blackboard_key(BB_NEXT_FOOD_EAT, 0)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[find_food], "A choking goose looks for more food")
	choking.duration = world.time - 1
	choking.process()
	TEST_ASSERT_EQUAL(goose.stat, DEAD, "The goose did not die when the choking ran out")
	TEST_ASSERT(plastic.loc != goose, "The dead goose kept the plastic inside")

	// A player feeds Birdboat by hand (no combat mode); it keeps the food inside
	var/mob/living/basic/goose/vomit/birdboat = allocate(/mob/living/basic/goose/vomit, locate(corner.x + 2, corner.y + 2, corner.z))
	var/datum/ai_controller/boat_controller = birdboat.ai_controller
	boat_controller.set_ai_status(AI_STATUS_OFF)
	var/mob/living/carbon/human/feeder = allocate(/mob/living/carbon/human, get_step(birdboat, WEST))
	feeder.set_combat_mode(FALSE, silent = TRUE)
	for(var/i in 1 to 3)
		var/obj/item/food/badrecipe/slop = allocate(/obj/item/food/badrecipe)
		feeder.put_in_active_hand(slop)
		feeder.next_click = 0
		feeder.next_move = 0
		feeder.ClickOn(birdboat, LEFT_CLICK)
		TEST_ASSERT(slop.loc == birdboat, "Birdboat did not eat the slop a player fed it")
	TEST_ASSERT_EQUAL(boat_controller.blackboard[BB_GOOSE_VOMIT_CHANCE], 9, "Gross food did not make Birdboat more likely to throw up")

	// The AI throws up: the vomit ability is used and everything comes back out
	boat_controller.set_ai_status(AI_STATUS_ON)
	boat_controller.set_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 100)
	var/datum/action/cooldown/mob_cooldown/goose_vomit/vomit = birdboat.vomit_action
	TEST_ASSERT(vomit.IsAvailable(), "Birdboat with a full stomach cannot throw up")
	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/use_mob_ability)
	boat_controller.SelectBehaviors(1)
	TEST_ASSERT(boat_controller.current_behaviors[use_ability], "Birdboat about to throw up did not plan to use its ability")
	boat_controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT(vomit.next_use_time > world.time, "The vomit ability was not used")
	var/wait_until = world.time + 10 SECONDS
	while(world.time < wait_until && length(birdboat.contents))
		sleep(1)
	TEST_ASSERT(!length(birdboat.contents), "Birdboat did not throw everything up")
	wait_until = world.time + 3 SECONDS // the status notices the empty stomach on its next tick
	while(world.time < wait_until && birdboat.has_status_effect(/datum/status_effect/goose_vomit))
		sleep(1)
	TEST_ASSERT(!birdboat.has_status_effect(/datum/status_effect/goose_vomit), "Birdboat kept throwing up with an empty stomach")
	TEST_ASSERT(!vomit.IsAvailable(), "The vomit ability is available with an empty stomach")
	TEST_ASSERT(vomit.next_use_time <= world.time, "The vomit ability stayed on cooldown after throwing up")

/// Counts a signal
/datum/aquila_signal_counter
	var/count = 0

/datum/aquila_signal_counter/proc/on_signal(datum/source)
	SIGNAL_HANDLER
	count++

/// Simple xenomorphs: the sentinel and the queen spit neurotoxin at their target through the AI (and a player in one spits by
/// clicking), the hunter slashes, drones and queens plant weeds unless told not to, a fertile queen lays eggs, the maid
/// polishes instead of hurting and cleans up messes, the barmaid has no AI and cannot be hurt
/datum/unit_test/aquila_xenomorph_family

/datum/unit_test/aquila_xenomorph_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	var/datum/ai_behavior/spit = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_ranged_attack/alien)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)

	for(var/spitter_type in list(/mob/living/basic/alien/sentinel, /mob/living/basic/alien/queen))
		var/mob/living/basic/alien/spitter = allocate(spitter_type, corner)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 3, corner.y, corner.z))
		TEST_ASSERT(isalienadult(spitter), "[spitter_type] is not an adult alien for isalienadult()")
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		var/datum/ai_controller/controller = spitter.ai_controller
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, find_target)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "[spitter_type] did not pick the human three tiles away")
		controller.SelectBehaviors(1)
		TEST_ASSERT(controller.current_behaviors[spit], "[spitter_type] with a target did not plan to spit")
		var/health_before = victim.health
		controller.ProcessBehavior(1, spit)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[spitter_type]: the neurotoxin did not hit the human")
		TEST_ASSERT(istype(recorder.projectiles[1], /obj/item/projectile/neurotox), "[spitter_type] did not spit neurotoxin")
		TEST_ASSERT(victim.health < health_before, "[spitter_type]: the neurotoxin did not hurt")
		controller.CancelActions()

		controller.set_ai_status(AI_STATUS_OFF)
		recorder.projectiles.Cut()
		var/datum/component/ranged_attacks/ranged = spitter.GetComponent(/datum/component/ranged_attacks)
		COOLDOWN_RESET(ranged, fire_cooldown)
		spitter.next_click = 0
		spitter.next_move = 0
		spitter.ClickOn(victim, LEFT_CLICK)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[spitter_type]: a player click on a far target did not spit")
		qdel(recorder)
		qdel(spitter)
		qdel(victim)

	// The hunter slashes the human next to it
	var/mob/living/basic/alien/hunter = allocate(/mob/living/basic/alien, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(corner, EAST))
	var/datum/ai_controller/controller = hunter.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_target)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[melee], "The hunter did not plan a melee attack")
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	hunter.next_move = 0
	hunter.next_click = 0
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The hunter did not slash the human")
	controller.CancelActions()
	qdel(hunter)

	// The maid goes for the human, but polishes instead of hurting; she cleans up the blood she clicks
	var/mob/living/basic/alien/maid/maid = allocate(/mob/living/basic/alien/maid, corner)
	var/datum/aquila_signal_counter/attacks = new
	attacks.RegisterSignal(maid, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, TYPE_PROC_REF(/datum/aquila_signal_counter, on_signal))
	controller = maid.ai_controller
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_target)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	maid.next_move = 0
	maid.next_click = 0
	brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(attacks.count, "The maid did not go for the human at all")
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), brute_before, "The maid hurt the human")
	qdel(attacks)
	controller.CancelActions()
	controller.set_ai_status(AI_STATUS_OFF)
	var/obj/effect/decal/cleanable/blood/mess = allocate(/obj/effect/decal/cleanable/blood, get_step(corner, NORTH))
	maid.next_move = 0
	maid.next_click = 0
	maid.ClickOn(mess, LEFT_CLICK)
	TEST_ASSERT(QDELETED(mess), "The maid did not clean up the blood she clicked")
	qdel(maid)
	qdel(victim)

	// Weeds: a drone plants a node after its cooldown unless plants_off is set
	var/turf/far_corner = locate(corner.x + 4, corner.y + 4, corner.z)
	for(var/plants_off in list(FALSE, TRUE))
		var/mob/living/basic/alien/drone/drone = allocate(/mob/living/basic/alien/drone, plants_off ? far_corner : corner)
		drone.plants_off = plants_off
		drone.plant_cooldown = 1
		var/datum/idle_behavior/idle = drone.ai_controller.idle_behavior
		TEST_ASSERT(istype(idle, /datum/idle_behavior/idle_random_walk/plant_weeds), "The drone does not have the weed planting idle behaviour")
		drone.mobility_flags &= ~MOBILITY_MOVE // stand still for the check
		idle.perform_idle_behavior(1, drone.ai_controller)
		var/obj/structure/alien/weeds/node/node = locate() in get_turf(drone)
		if(plants_off)
			TEST_ASSERT(!node, "A drone with plants_off planted weeds")
		else
			TEST_ASSERT(node, "The drone did not plant weeds after its cooldown")
		qdel(drone)

	// Eggs: a fertile queen lays one, a sterile one does not
	for(var/sterile in list(TRUE, FALSE))
		var/turf/queen_turf = sterile ? locate(corner.x + 2, corner.y + 2, corner.z) : locate(corner.x + 3, corner.y + 3, corner.z)
		var/mob/living/basic/alien/queen/queen = allocate(/mob/living/basic/alien/queen, queen_turf)
		queen.sterile = sterile
		queen.plants_off = TRUE
		queen.egg_cooldown = 1
		queen.mobility_flags &= ~MOBILITY_MOVE
		queen.ai_controller.idle_behavior.perform_idle_behavior(1, queen.ai_controller)
		var/obj/structure/alien/egg/egg = locate() in get_turf(queen)
		if(sterile)
			TEST_ASSERT(!egg, "A sterile queen laid an egg")
		else
			TEST_ASSERT(egg, "A fertile queen did not lay an egg")
		qdel(queen)

	// The shuttle barmaid: no AI, cannot be hurt, can open the bar
	var/mob/living/basic/alien/maid/barmaid/barmaid = allocate(/mob/living/basic/alien/maid/barmaid, corner)
	TEST_ASSERT(isnull(barmaid.ai_controller), "The barmaid has an AI")
	var/barmaid_health = barmaid.health
	barmaid.adjustBruteLoss(50)
	TEST_ASSERT_EQUAL(barmaid.health, barmaid_health, "The barmaid was hurt")
	TEST_ASSERT(barmaid.access_card && (ACCESS_CENT_BAR in barmaid.access_card.access), "The barmaid has no bar access")

/// Carp: the AI bites a human, a school picks the same prey, a hurt carp opens a rift away from its attacker and then flees,
/// regenerates after a while without damage, rifts towards far prey, eats raw meat, follows a migration path,
/// the dragon's rift heals basic carp and a player carp opens a rift with the secondary click in both control modes
/datum/unit_test/aquila_carp_family

/datum/unit_test/aquila_carp_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	var/datum/ai_behavior/rift_away = GET_AI_BEHAVIOR(/datum/ai_behavior/make_carp_rift/away)
	var/datum/ai_behavior/rift_towards = GET_AI_BEHAVIOR(/datum/ai_behavior/make_carp_rift/towards/aggressive)
	var/datum/ai_behavior/flee = GET_AI_BEHAVIOR(/datum/ai_behavior/run_away_from_target)

	// A school: two carp go for the same human, the first bites it
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 1, corner.y + 1, corner.z))
	var/mob/living/basic/carp/biter = allocate(/mob/living/basic/carp, corner)
	var/mob/living/basic/carp/schoolmate = allocate(/mob/living/basic/carp, locate(corner.x + 2, corner.y + 1, corner.z))
	TEST_ASSERT(biter.playable, "A space carp cannot be taken over by ghosts any more")
	for(var/mob/living/basic/carp/fish as anything in list(biter, schoolmate))
		fish.ai_controller.SelectBehaviors(1)
		fish.ai_controller.ProcessBehavior(1, find_target)
		TEST_ASSERT_EQUAL(fish.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "A carp of the school did not go for the human")
	var/datum/ai_controller/controller = biter.ai_controller
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[melee], "The carp next to its prey did not plan to bite")
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	biter.next_move = 0
	biter.next_click = 0
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The carp did not bite the human")
	controller.CancelActions()
	qdel(schoolmate)

	// Hurt below half: a rift away from the attacker first, then running away
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	biter.adjustBruteLoss(biter.maxHealth * 0.6)
	TEST_ASSERT(!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING], "A badly hurt carp does not want to flee")
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[rift_away], "A hurt carp with its rift ready did not plan to rift away")
	var/distance_before = get_dist(biter, victim)
	controller.ProcessBehavior(1, rift_away)
	TEST_ASSERT(get_dist(biter, victim) > distance_before, "The panic rift did not take the carp away from the human")
	TEST_ASSERT(!biter.teleport.IsAvailable(), "The rift did not go on cooldown")
	TEST_ASSERT(locate(/obj/effect/temp_visual/lesser_carp_rift/entrance) in range(1, locate(corner.x, corner.y, corner.z)), "The panic rift left no entrance behind")
	controller.CancelActions()
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[flee] || get_dist(biter, victim) >= DEFAULT_BASIC_FLEE_DISTANCE, "The hurt carp with its rift on cooldown did not run away")
	controller.CancelActions()

	// Regeneration: nothing right after damage, then 2 health a second
	var/health_hurt = biter.health
	biter.Life()
	TEST_ASSERT_EQUAL(biter.health, health_hurt, "The carp regenerated right after taking damage")
	biter.regeneration_cooldown = world.time - 1
	biter.Life()
	TEST_ASSERT(biter.health > health_hurt, "The carp did not regenerate after a while without damage")
	qdel(biter)

	// Far prey: a rift towards it
	var/mob/living/basic/carp/hunter = allocate(/mob/living/basic/carp, corner)
	controller = hunter.ai_controller
	var/mob/living/carbon/human/far_victim = allocate(/mob/living/carbon/human, locate(corner.x + 4, corner.y + 4, corner.z))
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, far_victim)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[rift_towards], "A carp with far prey did not plan a rift towards it")
	distance_before = get_dist(hunter, far_victim)
	controller.ProcessBehavior(1, rift_towards)
	TEST_ASSERT(get_dist(hunter, far_victim) < distance_before, "The rift did not take the carp closer to its prey")
	controller.CancelActions()
	qdel(far_victim)
	qdel(victim)

	// Raw meat: found and eaten (the rifts are cleared first, the entrance left on the corner would teleport the carp away again)
	for(var/obj/effect/temp_visual/lesser_carp_rift/rift in range(6, corner))
		qdel(rift)
	hunter.forceMove(corner)
	var/obj/item/food/meat/slab/meat = allocate(/obj/item/food/meat/slab, get_step(corner, EAST))
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	controller.set_blackboard_key(BB_NEXT_FOOD_EAT, 0)
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/find_food = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list)
	TEST_ASSERT(controller.current_behaviors[find_food], "A carp without prey did not look for food")
	controller.ProcessBehavior(1, find_food)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], meat, "The carp did not go for the raw meat")
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	hunter.next_move = 0
	hunter.next_click = 0
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(QDELETED(meat), "The carp did not eat the raw meat")
	controller.CancelActions()

	// Migration: the next point of the path becomes the target and the carp steps towards it
	var/turf/far_point = locate(corner.x + 4, corner.y + 4, corner.z)
	hunter.migrate_to(list(far_point))
	TEST_ASSERT(!controller.can_idle, "A migrating carp can still idle")
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/next_step = GET_AI_BEHAVIOR(/datum/ai_behavior/find_next_carp_migration_step)
	TEST_ASSERT(controller.current_behaviors[next_step], "A migrating carp did not plan its next point")
	controller.ProcessBehavior(1, next_step)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_CARP_MIGRATION_TARGET], far_point, "The migration point did not become the target")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/step_towards_turf)], "The migrating carp does not swim towards its point")
	controller.CancelActions()
	qdel(hunter)

	// The migration event picks a real path: a safe ship turf on the given z level, then space beyond it
	var/station_z = SSmapping.levels_by_trait(ZTRAIT_STATION)[1]
	var/list/event_path = pick_carp_migration_points(station_z)
	TEST_ASSERT_EQUAL(length(event_path), 2, "The carp migration event found no path through the ship")
	var/turf/ship_point = event_path[1]
	TEST_ASSERT_EQUAL(ship_point.z, station_z, "The carp migration point is on another z level")
	TEST_ASSERT(is_type_in_list(get_area(ship_point), GLOB.the_station_areas), "The carp migration point is not on the ship")

	// The dragon's rift heals basic carp next to it
	var/mob/living/basic/carp/advanced/rift_carp = allocate(/mob/living/basic/carp/advanced, corner)
	rift_carp.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/obj/structure/carp_rift/dragon_rift = allocate(/obj/structure/carp_rift, get_step(corner, EAST))
	rift_carp.adjustBruteLoss(20)
	var/hurt = rift_carp.health
	dragon_rift.process(1)
	TEST_ASSERT(rift_carp.health > hurt, "The dragon's rift did not heal a basic carp next to it")
	// A crew member of the carp faction (carp costume, carp sect) is not a carp
	var/mob/living/carbon/human/carp_fan = allocate(/mob/living/carbon/human, get_step(corner, NORTHEAST))
	carp_fan.faction |= "carp"
	carp_fan.adjustBruteLoss(20)
	hurt = carp_fan.health
	dragon_rift.process(1)
	TEST_ASSERT_EQUAL(carp_fan.health, hurt, "The dragon's rift healed a human of the carp faction")
	qdel(dragon_rift)

	// A player carp opens a rift with the secondary click: right click, or the disarm intent in the legacy controls
	for(var/legacy in list(FALSE, TRUE))
		var/mob/living/basic/carp/player = allocate(legacy ? /mob/living/basic/carp/aquila_legacy_test : /mob/living/basic/carp, corner)
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		TEST_ASSERT(player.combat_mode_indicator, "A player carp has no combat mode indicator")
		var/turf/aim = locate(corner.x + 3, corner.y, corner.z)
		player.next_click = 0
		player.next_move = 0
		if(legacy)
			player.a_intent_change(INTENT_DISARM)
			player.ClickOn(aim, "icon-x=16;icon-y=16;left=1;button=left")
		else
			player.ClickOn(aim, "icon-x=16;icon-y=16;right=1;button=right")
		TEST_ASSERT(get_dist(player, aim) <= 1, "[legacy ? "Legacy intents" : "Combat mode"]: the secondary click did not open a rift to the clicked spot")
		TEST_ASSERT(!player.teleport.IsAvailable(), "[legacy ? "Legacy intents" : "Combat mode"]: the player rift did not go on cooldown")
		qdel(player)
	qdel(rift_carp)

/// A carp played with the legacy intents
/mob/living/basic/carp/aquila_legacy_test

/mob/living/basic/carp/aquila_legacy_test/uses_legacy_intents()
	return TRUE

/// A magicarp played with the legacy intents
/mob/living/basic/carp/magic/aquila_legacy_test

/mob/living/basic/carp/magic/aquila_legacy_test/uses_legacy_intents()
	return TRUE

/// Magicarp: the AI finds a target for its bolt and fires it, the chaos magicarp picks from its list, a player shoots by clicking
/// in combat mode (the harm intent in the legacy controls) and not outside it; the megacarp gets its random name and stats
/datum/unit_test/aquila_magicarp_family

/datum/unit_test/aquila_magicarp_family/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/datum/ai_behavior/find_spell_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets/nearest/magicarp)
	var/datum/ai_behavior/cast = GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability/and_clear_target)

	for(var/carp_type in list(/mob/living/basic/carp/magic, /mob/living/basic/carp/magic/chaos))
		var/mob/living/basic/carp/magic/magicarp = allocate(carp_type, corner)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 3, corner.y, corner.z))
		var/datum/ai_controller/controller = magicarp.ai_controller
		// A plain bolt for the test (the random spells transform, teleport or animate)
		if(istype(magicarp.spell, /datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos))
			var/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/chaos_bolt = magicarp.spell
			chaos_bolt.permitted_projectiles = list(/obj/item/projectile/magic/arcane_barrage)
		else
			magicarp.spell.projectile_type = /obj/item/projectile/magic/arcane_barrage
			controller.clear_blackboard_key(BB_MAGICARP_SPELL_SPECIAL_TARGETING)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_MAGICARP_SPELL], magicarp.spell, "[carp_type]: the spell is not in the AI's blackboard")
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		controller.SelectBehaviors(1)
		TEST_ASSERT(controller.current_behaviors[find_spell_target], "[carp_type] with its spell ready did not look for a spell target")
		controller.ProcessBehavior(1, find_spell_target)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_MAGICARP_SPELL_TARGET], victim, "[carp_type] did not pick the human as its spell target")
		controller.SelectBehaviors(1)
		TEST_ASSERT(controller.current_behaviors[cast], "[carp_type] with a spell target did not plan to cast")
		controller.ProcessBehavior(1, cast)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[carp_type]: the bolt did not hit the human")
		TEST_ASSERT(istype(recorder.projectiles[1], /obj/item/projectile/magic/arcane_barrage), "[carp_type] fired the wrong bolt")
		TEST_ASSERT(!magicarp.spell.IsAvailable(), "[carp_type]: the spell did not go on cooldown")
		TEST_ASSERT(isnull(controller.blackboard[BB_MAGICARP_SPELL_TARGET]), "[carp_type] kept its spell target")
		controller.CancelActions()
		qdel(recorder)
		qdel(magicarp)
		qdel(victim)

	// The door and animate bolts are shot at prey: alone next to a wall and a loose item the magicarp picks no spell target
	// (tg aimed them at the nearest wall or object every 5 s and opened the hull)
	for(var/bolt_type in list(/obj/item/projectile/magic/door, /obj/item/projectile/magic/animate))
		var/mob/living/basic/carp/magic/idle_carp = allocate(/mob/living/basic/carp/magic, corner)
		var/obj/item/toy/crayon/loose_item = allocate(/obj/item/toy/crayon, get_step(corner, NORTH))
		idle_carp.spell.projectile_type = bolt_type
		idle_carp.assign_spell_ai(bolt_type)
		var/datum/ai_controller/idle_controller = idle_carp.ai_controller
		TEST_ASSERT(isnull(idle_controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETING]), "[bolt_type]: the magicarp still aims at walls or objects")
		idle_controller.SelectBehaviors(1)
		if(idle_controller.current_behaviors[find_spell_target])
			idle_controller.ProcessBehavior(1, find_spell_target)
		TEST_ASSERT(isnull(idle_controller.blackboard[BB_MAGICARP_SPELL_TARGET]), "[bolt_type]: a magicarp without prey picked [idle_controller.blackboard[BB_MAGICARP_SPELL_TARGET]] as its spell target")
		idle_controller.CancelActions()
		qdel(loose_item)
		qdel(idle_carp)

	// A player magicarp: clicking far away shoots in combat mode only, in both control modes
	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/mob/living/basic/carp/magic/player = allocate(legacy ? /mob/living/basic/carp/magic/aquila_legacy_test : /mob/living/basic/carp/magic, corner)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 3, corner.y, corner.z))
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		player.spell.projectile_type = /obj/item/projectile/magic/arcane_barrage
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		if(legacy)
			player.a_intent_change(INTENT_HELP)
		else
			player.set_combat_mode(FALSE, silent = TRUE)
		player.next_click = 0
		player.next_move = 0
		player.ClickOn(victim, "icon-x=16;icon-y=16;left=1;button=left")
		TEST_ASSERT(player.spell.IsAvailable(), "[mode]: the magicarp shot outside combat mode")
		if(legacy)
			player.a_intent_change(INTENT_HARM)
		else
			player.set_combat_mode(TRUE, silent = TRUE)
		player.next_click = 0
		player.next_move = 0
		player.ClickOn(victim, "icon-x=16;icon-y=16;left=1;button=left")
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[mode]: the magicarp did not shoot in combat mode")
		qdel(recorder)
		qdel(player)
		qdel(victim)

	// Megacarp: a random name, more damage and full health
	var/mob/living/basic/carp/mega/mega = allocate(/mob/living/basic/carp/mega, corner)
	TEST_ASSERT(mega.name != initial(mega.name), "The megacarp did not get a random name")
	TEST_ASSERT(mega.melee_damage > initial(mega.melee_damage), "The megacarp did not get extra damage")
	TEST_ASSERT(mega.maxHealth > initial(mega.maxHealth), "The megacarp did not get extra health")
	TEST_ASSERT_EQUAL(mega.health, mega.maxHealth, "The megacarp did not start at full health")

/// Cayenne: picks the nuclear disk up with a click, holds it in her mouth and puts it down on a floor she clicks
/datum/unit_test/aquila_cayenne_disk

/datum/unit_test/aquila_cayenne_disk/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/carp/pet/cayenne/cayenne = allocate(/mob/living/basic/carp/pet/cayenne, corner)
	cayenne.ai_controller.set_ai_status(AI_STATUS_OFF)
	TEST_ASSERT(HAS_TRAIT(cayenne, TRAIT_CAN_USE_NUKE), "Cayenne cannot use the nuke")
	var/obj/item/disk/nuclear/fake/disk = allocate(/obj/item/disk/nuclear/fake, get_step(corner, EAST))
	qdel(disk.GetComponent(/datum/component/stationloving)) // the test room is off the station, the disk would jump away
	disk.forceMove(get_step(corner, EAST))
	cayenne.next_click = 0
	cayenne.next_move = 0
	cayenne.ClickOn(disk, "icon-x=16;icon-y=16;left=1;button=left")
	TEST_ASSERT_EQUAL(disk.loc, cayenne, "Cayenne did not pick the disk up")
	TEST_ASSERT_EQUAL(cayenne.disky, disk, "Cayenne does not know she holds the disk")
	var/turf/drop_turf = get_step(corner, NORTH)
	cayenne.next_click = 0
	cayenne.next_move = 0
	cayenne.ClickOn(drop_turf, "icon-x=16;icon-y=16;left=1;button=left")
	TEST_ASSERT_EQUAL(disk.loc, drop_turf, "Cayenne did not put the disk down on the clicked floor")
	TEST_ASSERT(isnull(cayenne.disky), "Cayenne still thinks she holds the disk")

#undef LEFT_CLICK
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
