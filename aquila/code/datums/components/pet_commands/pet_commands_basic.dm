// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/components/pet_commands/pet_commands_basic.dm (bee/master 0adf0fe9ae)
// None of these are really complex enough to merit their own file
// AQUILA: names, radial tooltips, balloons and emotes in Polish. Speech triggers react to Polish words first and keep
// Bee's English ones (lowercase, the spoken text is lowercased before matching).

/**
 * # Pet Command: Idle
 * Tells a pet to resume its idle behaviour, usually staying put where you leave it
 */
/datum/pet_command/idle
	command_name = "Zostań"
	command_desc = "Każ zwierzakowi zostać w miejscu."
	radial_icon_state = "halt"
	speech_commands = list("siad", "zostań", "zostan", "stój", "stoj", "sit", "stay", "stop", "halt")
	command_feedback = "siada"

/datum/pet_command/idle/execute_action(datum/ai_controller/controller)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning

/datum/pet_command/idle/retrieve_command_text(atom/living_pet, atom/target)
	return "daje znak [living_pet], żeby został w miejscu!"

/**
 * # Pet Command: Stop
 * Tells a pet to exit command mode and resume its normal behaviour, which includes regular target-seeking and what have you
 */
/datum/pet_command/free
	command_name = "Wolne"
	command_desc = "Pozwól zwierzakowi wrócić do zwykłych zajęć."
	radial_icon_state = "free"
	speech_commands = list("wolne", "spocznij", "luz", "free", "loose")
	command_feedback = "odpręża się"

/datum/pet_command/free/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return // Just move on to the next planning subtree.

/datum/pet_command/free/retrieve_command_text(atom/living_pet, atom/target)
	return "daje znak [living_pet], że ma wolne!"

/**
 * # Pet Command: Follow
 * Tells a pet to follow you until you tell it to do something else
 */
/datum/pet_command/follow
	command_name = "Za mną"
	command_desc = "Każ zwierzakowi iść za tobą."
	radial_icon_state = "follow"
	speech_commands = list("do nogi", "za mną", "za mna", "chodź", "chodz", "heel", "follow")
	///the behavior we use to follow
	var/follow_behavior = /datum/ai_behavior/pet_follow_friend
	///should we activate immediately if we're doing nothing else and gain a friend?
	var/activate_on_befriend = FALSE

/datum/pet_command/follow/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/follow/retrieve_command_text(atom/living_pet, atom/target)
	return "daje znak [living_pet], żeby szedł za nim!"

/datum/pet_command/follow/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(follow_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/follow/add_new_friend(mob/living/tamer)
	. = ..()
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (activate_on_befriend && !parent.ai_controller.blackboard_key_exists(BB_ACTIVE_PET_COMMAND))
		try_activate_command(tamer)

/// Like follow but start active
/datum/pet_command/follow/start_active
	activate_on_befriend = TRUE

/**
 * # Pet Command: Play Dead
 * Pretend to be dead for a random period of time
 */
/datum/pet_command/play_dead
	command_name = "Udawaj trupa"
	command_desc = "Makabryczna sztuczka."
	radial_icon_state = "play_dead"
	speech_commands = list("udawaj trupa", "padnij", "play dead") // Don't get too creative here, people talk about dying pretty often

/datum/pet_command/play_dead/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/play_dead)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/play_dead/retrieve_command_text(atom/living_pet, atom/target)
	return "daje znak [living_pet], żeby udawał trupa!"

/**
 * # Pet Command: Good Boy
 * React if complimented
 */
/datum/pet_command/good_boy
	command_name = "Dobry piesek"
	command_desc = "Pochwal zwierzaka."
	hidden = TRUE

/datum/pet_command/good_boy/New(mob/living/parent)
	. = ..()
	speech_commands += "good [lowertext(parent.name)]"
	switch (parent.gender)
		if (MALE)
			speech_commands += list("dobry [lowertext(parent.name)]", "dobry piesek", "dobry chłopiec", "grzeczny piesek", "good boy")
			return
		if (FEMALE)
			speech_commands += list("dobra [lowertext(parent.name)]", "dobra suczka", "dobra dziewczynka", "grzeczna", "good girl")
			return
	// If we get past this point someone has finally added a non-binary dog

/datum/pet_command/good_boy/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return SUBTREE_RETURN_FINISH_PLANNING

	new /obj/effect/temp_visual/heart(parent.loc)
	parent.emote("spin")
	return SUBTREE_RETURN_FINISH_PLANNING

// AQUILA: untargeted_ability and use_ability need mob abilities (mob_cooldown actions), not ported yet

/**
 * # Pet Command: Attack
 * Tells a pet to chase and bite the next thing you point at
 */
/datum/pet_command/attack
	command_name = "Atakuj"
	command_desc = "Każ zwierzakowi zaatakować to, co mu wskażesz."
	radial_icon_state = "attack"
	requires_pointing = TRUE
	speech_commands = list("atakuj", "bierz go", "bierz ją", "zagryź", "attack", "sic", "kill")
	command_feedback = "warczy"
	pointed_reaction = "i groźnie warczy"
	/// Balloon alert to display if providing an invalid target
	var/refuse_reaction = "kręci głową"
	/// Attack behaviour to use
	var/attack_behaviour = /datum/ai_behavior/basic_melee_attack

// Refuse to target things we can't target, chiefly other friends
/datum/pet_command/attack/set_command_target(mob/living/parent, atom/target)
	if (!target)
		return FALSE
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return FALSE
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(living_parent.ai_controller.blackboard[targeting_strategy_key])
	if (!targeter)
		return FALSE
	if (!targeter.can_attack(living_parent, target))
		refuse_target(parent, target)
		return FALSE
	return ..()

/datum/pet_command/attack/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "daje znak [living_pet], żeby zaatakował [target]!"

/// Display feedback about not targeting something
/datum/pet_command/attack/proc/refuse_target(mob/living/parent, atom/target)
	var/mob/living/living_parent = parent
	living_parent.balloon_alert_to_viewers("[refuse_reaction]")
	living_parent.visible_message(span_notice("[living_parent] nie chce zaatakować [target]."))

/datum/pet_command/attack/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(attack_behaviour, BB_CURRENT_PET_TARGET, targeting_strategy_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Breed command. breed with a partner!
 */
/datum/pet_command/breed
	command_name = "Rozmnażaj się"
	command_desc = "Każ zwierzakowi spróbować rozmnożyć się z partnerem."
	requires_pointing = TRUE
	radial_icon_state = "breed"
	speech_commands = list("rozmnażaj", "rozmnazaj", "breed", "consummate")
	///the behavior we use to make babies
	var/datum/ai_behavior/reproduce_behavior = /datum/ai_behavior/make_babies

/datum/pet_command/breed/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !isliving(target))
		return FALSE
	if(!HAS_TRAIT(parent, TRAIT_MOB_BREEDER) || !HAS_TRAIT(target, TRAIT_MOB_BREEDER))
		return FALSE
	if(isnull(parent.ai_controller))
		return FALSE
	if(!parent.ai_controller.blackboard[BB_BREED_READY] || isnull(parent.ai_controller.blackboard[BB_BABIES_PARTNER_TYPES]))
		return FALSE
	var/mob/living/living_target = target
	if(!living_target.ai_controller?.blackboard[BB_BREED_READY])
		return FALSE
	return ..()

/datum/pet_command/breed/execute_action(datum/ai_controller/controller)
	if(is_type_in_list(controller.blackboard[BB_CURRENT_PET_TARGET], controller.blackboard[BB_BABIES_PARTNER_TYPES]))
		controller.queue_behavior(reproduce_behavior, BB_CURRENT_PET_TARGET)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/breed/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "daje znak [living_pet], żeby rozmnożył się z [target]!"

/datum/pet_command/protect_owner
	command_name = "Chroń właściciela"
	command_desc = "Zwierzak pobiegnie ci na pomoc."
	hidden = TRUE
	///the range our owner needs to be in for us to protect him
	var/protect_range = 9
	///the behavior we will use when he is attacked
	var/protect_behavior = /datum/ai_behavior/basic_melee_attack
	///message cooldown to prevent too many people from telling you not to commit suicide
	COOLDOWN_DECLARE(self_harm_message_cooldown)

/datum/pet_command/protect_owner/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(set_attacking_target))
	if(!HAS_TRAIT(tamer, TRAIT_RELAYING_ATTACKER))
		tamer.AddElement(/datum/element/relay_attackers)

/datum/pet_command/protect_owner/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, COMSIG_ATOM_WAS_ATTACKED)

/datum/pet_command/protect_owner/execute_action(datum/ai_controller/controller)
	var/mob/living/victim = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(QDELETED(victim))
		return
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!targeter.can_attack(controller.pawn, victim))
		return
	// cancel the action if they're below our given crit stat, OR if we're trying to attack ourselves (this can happen on tamed mobs w/ protect subtree rarely)
	if(victim.stat > controller.blackboard[BB_TARGET_MINIMUM_STAT] || victim == controller.pawn)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return
	controller.queue_behavior(protect_behavior, BB_CURRENT_PET_TARGET, BB_PET_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/protect_owner/set_command_active(mob/living/parent, mob/living/victim)
	. = ..()
	set_command_target(parent, victim)

/datum/pet_command/protect_owner/proc/set_attacking_target(atom/source, mob/living/attacker)
	SIGNAL_HANDLER

	var/mob/living/basic/owner = weak_parent.resolve()
	if(isnull(owner))
		return
	if(source == attacker)
		var/list/interventions = owner.ai_controller?.blackboard[BB_OWNER_SELF_HARM_RESPONSES] || list()
		if (length(interventions) && COOLDOWN_FINISHED(src, self_harm_message_cooldown) && prob(30))
			COOLDOWN_START(src, self_harm_message_cooldown, 5 SECONDS)
			var/chosen_statement = pick(interventions)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, say), chosen_statement)
		return
	var/mob/living/current_target = owner.ai_controller?.blackboard[BB_CURRENT_PET_TARGET]
	if(attacker == current_target) //we are already dealing with this target
		return
	if(isliving(attacker) && can_see(owner, attacker, protect_range))
		set_command_active(owner, attacker)

/datum/pet_command/move
	command_name = "Idź"
	command_desc = "Każ zwierzakowi pójść we wskazane miejsce!"
	requires_pointing = TRUE
	radial_icon_state = "move"
	speech_commands = list("idź tam", "idz tam", "move", "walk")
	///the behavior we use to walk towards targets
	var/datum/ai_behavior/walk_behavior = /datum/ai_behavior/travel_towards

/datum/pet_command/move/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !can_see(parent, target, 9))
		return FALSE
	return ..()

/datum/pet_command/move/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(walk_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/move/retrieve_command_text(atom/living_pet, atom/target)
	return "daje znak [living_pet], żeby poszedł we wskazane miejsce!"
