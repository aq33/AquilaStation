#define FOLLOW_TOLERANCE 19

///Better than traditional follow, for our needs
/datum/ai_behavior/tamed_follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/tamed_follow/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/pawn = controller.pawn
	//If pawn can't access target, finish
	if(get_dist(pawn, controller.blackboard[BB_FOLLOW_TARGET]) > FOLLOW_TOLERANCE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/tamed_follow/finish_action(datum/ai_controller/controller, succeeded, ...)
	var/mob/living/simple_animal/pawn = controller.pawn
	pawn.visible_message("[pawn] przestaje podążać za [controller.blackboard[BB_FOLLOW_TARGET]]!")
	..()

//Agressive >:)
/datum/ai_behavior/tamed_follow/attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	action_cooldown = 1.3 SECONDS

/datum/ai_behavior/tamed_follow/attack/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/pawn = controller.pawn
	var/mob/living/target = controller.blackboard[BB_ATTACK_TARGET]
	//If pawn can't access target, finish
	if(QDELETED(target) || get_dist(pawn, target) > FOLLOW_TOLERANCE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(get_dist(pawn, target) <= 1)
		if(istype(target) && IS_DEAD_OR_INCAP(target))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		target.attack_animal(pawn)
	return AI_BEHAVIOR_DELAY

/// This trys to lock the pawn to a position
/datum/ai_behavior/tamed_sit/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(DT_PROB(0.5, delta_time))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY
