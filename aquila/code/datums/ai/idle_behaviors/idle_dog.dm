// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/idle_behaviors/idle_dog.dm (bee/master 0adf0fe9ae), lines of our old dog AI
/datum/idle_behavior/idle_dog

///Dog specific idle behavior.
/datum/idle_behavior/idle_dog/perform_idle_behavior(delta_time, datum/ai_controller/basic_controller/dog/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	var/obj/item/carry_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	// if we're just ditzing around carrying something, occasionally print a message so people know we have something
	if(carry_item && DT_PROB(5, delta_time))
		living_pawn.visible_message(span_notice("[living_pawn] delikatnie przygryza [carry_item] w pysku."), vision_distance=COMBAT_MESSAGE_RANGE)

	// Custom movement rate, for old corgis, etc.
	var/move_chance = controller.blackboard[BB_DOG_IS_SLOW] ? 2.5 : 5

	if(DT_PROB(move_chance, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE))
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(DT_PROB(10, delta_time))
		living_pawn.manual_emote(pick("kręci się w kółko.", "goni swój ogon!"))
		living_pawn.AddComponent(/datum/component/spinny)
	else if(DT_PROB(2, delta_time))
		living_pawn.manual_emote(pick("kręci się w kółko.", "goni swój ogon!"))
		for(var/mob/living/carbon/human/H in oviewers(living_pawn))
			if(H.mind)
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "animal_play", /datum/mood_event/animal_play, living_pawn)

