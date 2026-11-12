// AQUILA - mob ability framework for basic mobs: /datum/action/cooldown/mob_cooldown, the ranged_attacks component, the ability
// AI (targeted_mob_ability, pet_use_ability, "Użyj zdolności") and the shared AI core bits. The mobs below are generic test
// mobs that exist only in unit test builds; the families get their own tests.
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
#define RIGHT_CLICK_PARAMS "icon-x=16;icon-y=16;right=1;button=right"

/// Test ability: burns the target a little and remembers it
/datum/action/cooldown/mob_cooldown/aquila_test_zap
	name = "testowe porażenie"
	cooldown_time = 5 SECONDS
	melee_cooldown_time = 3 SECONDS
	/// What the ability was last used on
	var/atom/last_target
	/// How many times it was used
	var/uses = 0

/datum/action/cooldown/mob_cooldown/aquila_test_zap/Activate(atom/activate_target)
	last_target = activate_target
	uses++
	if(isliving(activate_target))
		var/mob/living/living_target = activate_target
		living_target.adjustFireLoss(5)
	StartCooldown()
	return TRUE

/// Shares the cooldown group of the zap
/datum/action/cooldown/mob_cooldown/aquila_test_zap/same_group

/// Has its own cooldown group
/datum/action/cooldown/mob_cooldown/aquila_test_zap/other_group
	shared_cooldown = MOB_SHARED_COOLDOWN_2

/// Test spell aimed with a click, for the AI (decision D6) and the click interplay with mob abilities
/datum/action/cooldown/spell/aquila_test_spell
	name = "testowe zaklęcie"
	click_to_activate = TRUE
	cooldown_time = 5 SECONDS
	/// What the spell was last cast on
	var/atom/last_target

/datum/action/cooldown/spell/aquila_test_spell/cast(atom/cast_on)
	. = ..()
	last_target = cast_on

/// A hostile basic mob with a targeted ability, used by the AI or by a player
/mob/living/basic/aquila_ability_tester
	name = "testowy stwór"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	faction = list(FACTION_HOSTILE)
	melee_damage = 10
	melee_attack_cooldown = 0
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/aquila_ability_tester

/mob/living/basic/aquila_ability_tester/Initialize(mapload)
	. = ..()
	grant_actions_by_list(list(/datum/action/cooldown/mob_cooldown/aquila_test_zap = BB_TARGETED_ACTION))

/// The same mob, played with the legacy intents
/mob/living/basic/aquila_ability_tester/legacy

/mob/living/basic/aquila_ability_tester/legacy/uses_legacy_intents()
	return TRUE

/datum/ai_controller/basic_controller/aquila_ability_tester
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// A hostile basic mob that shoots lasers
/mob/living/basic/aquila_ranged_tester
	name = "testowy strzelec"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	faction = list(FACTION_HOSTILE)
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/aquila_ranged_tester
	/// The ranged_attacks arguments
	var/test_casing_type
	var/test_projectile_type = /obj/item/projectile/beam/laser

/mob/living/basic/aquila_ranged_tester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, casing_type = test_casing_type, projectile_type = test_projectile_type, cooldown_time = 1 SECONDS)

/// The same shooter with 9 mm casings (fire_casing() argument order)
/mob/living/basic/aquila_ranged_tester/casing
	test_casing_type = /obj/item/ammo_casing/c9mm
	test_projectile_type = null

/datum/ai_controller/basic_controller/aquila_ranged_tester
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree,
	)

/// A pet that uses its targeted ability on command
/mob/living/basic/pet/aquila_ability_pet
	name = "testowy zwierzak"
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/aquila_ability_pet

/mob/living/basic/pet/aquila_ability_pet/Initialize(mapload)
	. = ..()
	grant_actions_by_list(list(/datum/action/cooldown/mob_cooldown/aquila_test_zap = BB_TARGETED_ACTION))
	AddComponent(/datum/component/obeys_commands, list(/datum/pet_command/idle, /datum/pet_command/free, /datum/pet_command/use_ability))

/datum/ai_controller/basic_controller/aquila_ability_pet
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	idle_behavior = null
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
	)

/// Records the projectiles that hit a mob
/datum/aquila_bullet_recorder
	var/list/projectiles = list()

/datum/aquila_bullet_recorder/proc/on_bullet_act(datum/source, obj/item/projectile/hit_by, def_zone)
	SIGNAL_HANDLER
	projectiles += hit_by

/// Waits until the mob was hit (or the time ran out); projectiles fly on SSprojectiles
/proc/aquila_wait_for_hit(datum/aquila_bullet_recorder/recorder, time = 3 SECONDS)
	var/wait_until = world.time + time
	while(world.time < wait_until && !length(recorder.projectiles))
		sleep(1)
	return length(recorder.projectiles)

/// The AI uses a mob ability on its target through the controller, then the shared and melee cooldowns hold;
/// a spell in the ability slot works too, any other action type is refused without a runtime
/datum/unit_test/aquila_mob_ability_ai

/datum/unit_test/aquila_mob_ability_ai/Run()
	var/mob/living/basic/aquila_ability_tester/tester = allocate(/mob/living/basic/aquila_ability_tester, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = tester.ai_controller
	var/datum/action/cooldown/mob_cooldown/aquila_test_zap/zap = controller.blackboard[BB_TARGETED_ACTION]
	TEST_ASSERT(istype(zap) && zap.owner == tester, "grant_actions_by_list() did not put the granted ability in its blackboard key")
	var/datum/action/cooldown/mob_cooldown/aquila_test_zap/same_group/shared = new(tester)
	shared.Grant(tester)
	var/datum/action/cooldown/mob_cooldown/aquila_test_zap/other_group/separate = new(tester)
	separate.Grant(tester)

	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/targeted_mob_ability)
	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	controller.SelectBehaviors(1)
	controller.ProcessBehavior(1, find_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The tester did not pick the human next to it")

	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[use_ability], "The AI with a target and a ready ability did not plan to use it")
	TEST_ASSERT(!controller.current_behaviors[melee], "The ability subtree did not finish planning")
	var/burn_before = victim.getFireLoss()
	controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT_EQUAL(zap.last_target, victim, "The AI did not use the ability on its target")
	TEST_ASSERT(victim.getFireLoss() > burn_before, "The ability used by the AI did nothing to the target")
	TEST_ASSERT(zap.next_use_time > world.time, "The ability did not start its cooldown")
	TEST_ASSERT(shared.next_use_time > world.time, "An ability of the same shared cooldown group did not start its cooldown")
	TEST_ASSERT(separate.next_use_time <= world.time, "An ability of another cooldown group went on cooldown")

	// On cooldown the AI goes for melee, but the melee cooldown of the ability holds it back
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[use_ability], "The AI planned to use an ability on cooldown")
	TEST_ASSERT(controller.current_behaviors[melee], "The AI with its ability on cooldown did not plan a melee attack")
	controller.ProcessBehavior(1, melee)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	tester.next_move = 0
	tester.next_click = 0
	var/brute_before = victim.getBruteLoss()
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), brute_before, "The melee attack went through the ability's melee cooldown")
	zap.next_melee_use_time = 0
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	tester.next_move = 0
	tester.next_click = 0 // the AI attacks through ClickOn(), one click a tick
	controller.ProcessBehavior(1, melee)
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The melee attack did not hurt after the melee cooldown")
	controller.CancelActions()

	// A spell in the ability slot (decision D6)
	var/datum/action/cooldown/spell/aquila_test_spell/spell = new(tester)
	spell.Grant(tester)
	controller.set_blackboard_key(BB_TARGETED_ACTION, spell)
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim) // cancelling the melee attack dropped the target
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[use_ability], "The AI did not plan to cast the spell in its ability slot")
	controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT_EQUAL(spell.last_target, victim, "The AI did not cast the spell on its target")
	TEST_ASSERT(isnull(tester.click_intercept), "Casting by the AI left the spell aiming")
	controller.CancelActions()

	// Other actions have no Trigger(target): the subtree skips them and the behaviour refuses them
	var/datum/action/cooldown/old_action = new(tester)
	old_action.Grant(tester)
	controller.set_blackboard_key(BB_TARGETED_ACTION, old_action)
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.current_behaviors[use_ability], "The AI planned to use an action that is not a mob ability or a spell")
	controller.CancelActions()
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET)
	controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT(!controller.current_behaviors[use_ability], "The ability behaviour did not give up on an old action")
	qdel(old_action)

	// Incapacitated: the ability is not available (AB_CHECK_INCAPACITATED)
	zap.ResetCooldown()
	TEST_ASSERT(zap.IsAvailable(), "ResetCooldown() did not make the ability available")
	tester.Paralyze(10 SECONDS, ignore_canstun = TRUE)
	TEST_ASSERT(!zap.IsAvailable(), "The ability is available to a paralyzed mob")
	tester.SetParalyzed(0, ignore_canstun = TRUE)

/// A ranged basic mob finds its target and shoots it through the AI; projectiles and casings both hit and hurt,
/// the casing shot keeps the mob as the shooter (fire_casing() argument order); a player in the mob shoots by clicking
/datum/unit_test/aquila_mob_ability_ranged

/datum/unit_test/aquila_mob_ability_ranged/Run()
	for(var/shooter_type in list(/mob/living/basic/aquila_ranged_tester, /mob/living/basic/aquila_ranged_tester/casing))
		var/mob/living/basic/aquila_ranged_tester/shooter = allocate(shooter_type, run_loc_floor_bottom_left)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
		var/datum/aquila_bullet_recorder/recorder = new
		recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
		var/datum/ai_controller/controller = shooter.ai_controller

		var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets)
		var/datum/ai_behavior/shoot = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_ranged_attack)
		controller.SelectBehaviors(1)
		controller.ProcessBehavior(1, find_target)
		TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "[shooter_type]: the shooter did not pick the human three tiles away")
		controller.SelectBehaviors(1)
		TEST_ASSERT(controller.current_behaviors[shoot], "[shooter_type]: the shooter with a target did not plan a ranged attack")
		var/health_before = victim.health
		controller.ProcessBehavior(1, shoot)
		TEST_ASSERT(aquila_wait_for_hit(recorder), "[shooter_type]: the shot did not hit the target")
		TEST_ASSERT(victim.health < health_before, "[shooter_type]: the shot did not hurt the target")
		var/obj/item/projectile/hit_by = recorder.projectiles[1]
		TEST_ASSERT_EQUAL(hit_by.firer, shooter, "[shooter_type]: the projectile does not know who shot it")
		TEST_ASSERT_EQUAL(hit_by.fired_from, shooter, "[shooter_type]: the projectile was not fired from the shooter")
		if(ispath(shooter_type, /mob/living/basic/aquila_ranged_tester/casing))
			var/obj/item/ammo_casing/spent = locate(/obj/item/ammo_casing/c9mm) in get_turf(shooter)
			TEST_ASSERT(spent && !spent.BB, "The shooter did not leave a spent casing")
		controller.CancelActions()

		// A player in the mob shoots by clicking something out of reach (RangedAttack(), no intent involved)
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

/// A player in a basic mob aims a mob ability with its button and uses it with the next click, in both control modes;
/// the button puts it away again and a spell and a mob ability take the click over from each other
/datum/unit_test/aquila_mob_ability_player_click

/datum/unit_test/aquila_mob_ability_player_click/Run()
	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/mob/living/basic/aquila_ability_tester/tester = allocate(legacy ? /mob/living/basic/aquila_ability_tester/legacy : /mob/living/basic/aquila_ability_tester, run_loc_floor_bottom_left)
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
		tester.ai_controller.set_ai_status(AI_STATUS_OFF)
		TEST_ASSERT(tester.combat_mode_indicator, "[mode]: a playable basic mob has no combat mode indicator")
		TEST_ASSERT_EQUAL(tester.uses_legacy_intents(), legacy, "[mode]: wrong control mode of the test mob")
		var/datum/action/cooldown/mob_cooldown/aquila_test_zap/zap = tester.ai_controller.blackboard[BB_TARGETED_ACTION]

		// Help, harm and the secondary click (right click, the disarm intent) all use the aimed ability
		for(var/click_kind in list("help", "harm", "secondary"))
			if(legacy)
				tester.a_intent_change(click_kind == "harm" ? INTENT_HARM : (click_kind == "secondary" ? INTENT_DISARM : INTENT_HELP))
			else
				tester.set_combat_mode(click_kind == "harm", silent = TRUE)
			zap.ResetCooldown()
			var/uses_before = zap.uses
			zap.Trigger()
			TEST_ASSERT_EQUAL(tester.click_intercept, zap, "[mode], [click_kind]: the ability button did not aim the ability")
			TEST_ASSERT(zap.is_action_active(), "[mode], [click_kind]: the aimed ability does not show as active")
			tester.next_click = 0
			tester.next_move = 0
			tester.ClickOn(victim, (click_kind == "secondary" && !legacy) ? RIGHT_CLICK_PARAMS : LEFT_CLICK)
			TEST_ASSERT_EQUAL(zap.uses, uses_before + 1, "[mode], [click_kind]: the click did not use the aimed ability")
			TEST_ASSERT_EQUAL(zap.last_target, victim, "[mode], [click_kind]: the ability was not used on the clicked mob")
			TEST_ASSERT(isnull(tester.click_intercept), "[mode], [click_kind]: the ability kept aiming after it was used")
			TEST_ASSERT(zap.next_use_time > world.time, "[mode], [click_kind]: the ability used by click did not start its cooldown")

		// The button puts the aimed ability away; the next click does nothing
		zap.ResetCooldown()
		var/uses_before = zap.uses
		zap.Trigger()
		zap.Trigger()
		TEST_ASSERT(isnull(tester.click_intercept), "[mode]: pressing the button again did not put the ability away")
		tester.next_click = 0
		tester.ClickOn(victim, LEFT_CLICK)
		TEST_ASSERT_EQUAL(zap.uses, uses_before, "[mode]: the ability was used after it was put away")

		// A spell and a mob ability take the click over from each other
		var/datum/action/cooldown/spell/aquila_test_spell/spell = new(tester)
		spell.Grant(tester)
		spell.Trigger()
		TEST_ASSERT_EQUAL(tester.click_intercept, spell, "[mode]: the spell button did not aim the spell")
		zap.Trigger()
		TEST_ASSERT_EQUAL(tester.click_intercept, zap, "[mode]: the mob ability did not take the click over from the spell")
		spell.Trigger()
		TEST_ASSERT_EQUAL(tester.click_intercept, spell, "[mode]: the spell did not take the click over from the mob ability")
		spell.Trigger()
		TEST_ASSERT(isnull(tester.click_intercept), "[mode]: pressing the spell button again did not put it away")
		qdel(spell)
		qdel(tester)
		qdel(victim)

/// A tamed pet uses its ability on the target its owner points out with the "Użyj zdolności" command
/datum/unit_test/aquila_mob_ability_pet_command

/datum/unit_test/aquila_mob_ability_pet_command/Run()
	var/mob/living/basic/pet/aquila_ability_pet/pet = allocate(/mob/living/basic/pet/aquila_ability_pet, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/ai_controller/controller = pet.ai_controller
	var/datum/action/cooldown/mob_cooldown/aquila_test_zap/zap = controller.blackboard[BB_TARGETED_ACTION]
	pet.befriend(owner)
	TEST_ASSERT(owner in controller.blackboard[BB_FRIENDS_LIST], "befriend() did not make the owner a friend")

	// "Strzelaj" falls in ordinary combat talk, so it is not a command
	owner.say("Strzelaj!")
	TEST_ASSERT(!controller.blackboard[BB_ACTIVE_PET_COMMAND], "Saying \"Strzelaj\" gave the pet a command")
	// Spoken: the command waits for a pointed target
	owner.say("Użyj zdolności!")
	TEST_ASSERT(istype(controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/use_ability), "The pet did not take the spoken ability command")
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/use_ability = GET_AI_BEHAVIOR(/datum/ai_behavior/pet_use_ability)
	TEST_ASSERT(!controller.current_behaviors[use_ability], "The pet went to use its ability without a target")
	TEST_ASSERT_EQUAL(zap.uses, 0, "The pet used its ability without a target")

	// From the menu: the next click picks the target
	var/datum/component/obeys_commands/obedience = pet.GetComponent(/datum/component/obeys_commands)
	var/datum/pet_command/use_ability/command = obedience.available_commands["Użyj zdolności"]
	TEST_ASSERT(istype(command), "The pet has no \"Użyj zdolności\" command")
	command.try_activate_command(owner, radial_command = TRUE)
	owner.next_click = 0
	owner.ClickOn(victim, LEFT_CLICK)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_CURRENT_PET_TARGET], victim, "Clicking a mob after the menu command did not give the pet a target")
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[use_ability], "The pet with an ability command and a target did not plan to use the ability")
	controller.ProcessBehavior(1, use_ability)
	TEST_ASSERT_EQUAL(zap.last_target, victim, "The pet did not use its ability on the target")
	TEST_ASSERT(zap.next_use_time > world.time, "The pet's ability did not start its cooldown")
	TEST_ASSERT(isnull(controller.blackboard[BB_CURRENT_PET_TARGET]), "The pet kept its target after using the ability")

/// Shared AI core bits: run_emote, step_towards_turf, require_traits and moving in zero gravity with `spacewalk` (decision D8)
/datum/unit_test/aquila_ai_core_bits

/datum/unit_test/aquila_ai_core_bits/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/aquila_ability_tester/tester = allocate(/mob/living/basic/aquila_ability_tester, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(corner, EAST))
	var/datum/ai_controller/controller = tester.ai_controller

	// require_traits: only targets with one of the traits, any target without a list
	var/datum/targeting_strategy/picky = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/require_traits)
	TEST_ASSERT(picky.can_attack(tester, victim), "require_traits without a trait list refused a valid target")
	controller.set_blackboard_key(BB_TARGET_ONLY_WITH_TRAITS, list(TRAIT_NAIVE))
	TEST_ASSERT(!picky.can_attack(tester, victim), "require_traits attacked a target without the trait")
	ADD_TRAIT(victim, TRAIT_NAIVE, "aquila_test")
	TEST_ASSERT(picky.can_attack(tester, victim), "require_traits refused a target with the trait")
	controller.clear_blackboard_key(BB_TARGET_ONLY_WITH_TRAITS)

	// run_emote: an emote from the blackboard
	var/datum/aquila_emote_recorder/emotes = new
	emotes.RegisterSignal(tester, COMSIG_MOB_EMOTE, TYPE_PROC_REF(/datum/aquila_emote_recorder, on_emote))
	controller.set_blackboard_key(BB_EMOTE_KEY, list("flip"))
	controller.queue_behavior(/datum/ai_behavior/run_emote, BB_EMOTE_KEY)
	controller.ProcessBehavior(1, GET_AI_BEHAVIOR(/datum/ai_behavior/run_emote))
	TEST_ASSERT_EQUAL(emotes.last_act, "flip", "run_emote did not run the emote from the blackboard")
	qdel(emotes)

	// step_towards_turf: moves a few tiles at a time towards a far turf
	controller.set_ai_status(AI_STATUS_OFF)
	var/turf/far = locate(corner.x + 4, corner.y + 4, corner.z)
	controller.set_blackboard_key("aquila_test_step_turf", far)
	var/datum/ai_behavior/step_towards_turf/stepper = GET_AI_BEHAVIOR(/datum/ai_behavior/step_towards_turf)
	stepper.step_distance = 2
	TEST_ASSERT(stepper.setup(controller, "aquila_test_step_turf"), "step_towards_turf did not accept a free turf")
	TEST_ASSERT_EQUAL(controller.current_movement_target, locate(corner.x + 2, corner.y + 2, corner.z), "step_towards_turf did not aim two tiles towards the destination")
	stepper.step_distance = initial(stepper.step_distance)
	controller.clear_blackboard_key("aquila_test_step_turf")

	// Zero gravity (the test room has none): a spacewalking basic mob moves on its own, another one drifts
	var/turf/center = locate(corner.x + 2, corner.y + 2, corner.z)
	tester.forceMove(center)
	TEST_ASSERT(!center.has_gravity(), "The test room has gravity, the zero gravity check needs none")
	TEST_ASSERT(!tester.Process_Spacemove(EAST, continuous_move = TRUE), "A basic mob without spacewalk holds on to nothing in zero gravity")
	tester.spacewalk = TRUE
	TEST_ASSERT(tester.Process_Spacemove(EAST, continuous_move = TRUE), "A basic mob with spacewalk cannot move in zero gravity")
	TEST_ASSERT(!tester.newtonian_move(EAST), "A basic mob with spacewalk started drifting")

/// Records the emotes of a mob
/datum/aquila_emote_recorder
	var/last_act

/datum/aquila_emote_recorder/proc/on_emote(datum/source, datum/emote/emote, act, m_type, message, intentional)
	SIGNAL_HANDLER
	last_act = act

#undef LEFT_CLICK
#undef RIGHT_CLICK_PARAMS
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
