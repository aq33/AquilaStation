// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/basic_mobs/basic_subtrees/find_parent.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Bee defined BB_PARENT_EMOTE_COOLDOWN but never used it, so a baby next to its parent emoted every few seconds; here it waits.
/datum/ai_planning_subtree/look_for_adult
	///how far we must be from the mom
	var/minimum_distance = 1
	///how long we wait between emotes at the parent
	var/emote_cooldown = 40 SECONDS

/datum/ai_planning_subtree/look_for_adult/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/target = controller.blackboard[BB_FOUND_MOM]
	var/mob/baby = controller.pawn

	if(QDELETED(target))
		find_mom(controller)
		return

	if(get_dist(target, baby) > minimum_distance)
		controller.queue_behavior(/datum/ai_behavior/travel_towards/stop_on_arrival, BB_FOUND_MOM)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(controller.blackboard[BB_PARENT_EMOTE_COOLDOWN] > world.time || !DT_PROB(15, delta_time))
		return

	controller.set_blackboard_key(BB_PARENT_EMOTE_COOLDOWN, world.time + emote_cooldown)
	if(target.stat == DEAD)
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "płacze za rodzicem!")
	else
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "tańczy wokół rodzica!")

	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/look_for_adult/proc/find_mom(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/find_mom, BB_FIND_MOM_TYPES, BB_IGNORE_MOM_TYPES, BB_FOUND_MOM)
