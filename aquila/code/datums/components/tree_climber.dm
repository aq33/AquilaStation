// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/components/tree_climber.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Our is_blocked_turf() is a global proc and examine goes through COMSIG_PARENT_EXAMINE.
/*
 * A component given to mobs that can climb trees
 */
/datum/component/tree_climber
	///the distance to climb up and down
	var/climbing_distance = 20
	///the tree we are on
	var/obj/current_tree

/datum/component/tree_climber/Initialize(climbing_distance = 20)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.climbing_distance = climbing_distance

	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/tree_climber/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_CLIMB_TREE), PROC_REF(climb_tree))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/tree_climber/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_CLIMB_TREE, COMSIG_PARENT_EXAMINE))

/datum/component/tree_climber/Destroy()
	if(current_tree)
		handle_climb_tree(parent, current_tree) //remove mob from tree and handle deletion of signals
	return ..()

/datum/component/tree_climber/proc/climb_tree(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/flora/tree))
		return

	if(!can_climb_tree(target)) //check if another animal is on the tree
		to_chat(source, span_warning("[target] jest zajęte!"))
		return COMPONENT_HOSTILE_NO_ATTACK

	handle_climb_tree(source, target)

	if(current_tree)
		source.forceMove(get_turf(current_tree))
		return COMPONENT_HOSTILE_NO_ATTACK

	var/list/possible_drops = get_adjacent_open_turfs(target)
	for(var/turf/droploc as anything in possible_drops)
		if(!is_blocked_turf(droploc, exclude_mobs = TRUE))
			continue
		possible_drops -= droploc
	if(length(possible_drops))
		source.forceMove(pick(possible_drops))
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/tree_climber/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(current_tree)
		examine_text += span_notice("Kurczowo trzyma się [current_tree]!")

/datum/component/tree_climber/proc/can_climb_tree(obj/structure/flora/tree/target)
	if(current_tree)
		return TRUE
	var/turf/tree_turf = get_turf(target)
	if(locate(/mob/living) in tree_turf.contents)
		return FALSE
	return TRUE

/datum/component/tree_climber/proc/handle_climb_tree(mob/living/climber, obj/structure/target_tree)
	var/offset = current_tree ? -(climbing_distance) : climbing_distance
	animate(climber, pixel_y = climber.pixel_y + offset, time = 2)
	climber.Stun(2 SECONDS, ignore_canstun = TRUE)
	if(current_tree)
		remove_tree_signals()
		current_tree = null
		return

	current_tree = target_tree
	register_tree_signals()

/datum/component/tree_climber/proc/remove_from_tree()
	SIGNAL_HANDLER

	handle_climb_tree(parent, current_tree)

/datum/component/tree_climber/proc/register_tree_signals()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(remove_from_tree))
	RegisterSignal(current_tree, COMSIG_PARENT_PREQDELETED, PROC_REF(remove_from_tree))

/datum/component/tree_climber/proc/remove_tree_signals()
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(current_tree, COMSIG_PARENT_PREQDELETED)

/// AI: find a living tree nearby (BeeStation/BeeStation-Hornet climb_tree.dm)
/datum/ai_behavior/find_and_set/valid_tree

/datum/ai_behavior/find_and_set/valid_tree/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/valid_trees = list()
	for (var/obj/structure/flora/tree/tree_target in oview(search_range, controller.pawn))
		if(istype(tree_target, /obj/structure/flora/tree/dead)) //no died trees
			continue
		valid_trees += tree_target

	if(length(valid_trees))
		return pick(valid_trees)

/datum/ai_behavior/climb_tree
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/climb_tree/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/climb_tree/perform(delta_time, datum/ai_controller/controller, target_key)
	var/obj/structure/flora/target_tree = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	if(QDELETED(living_pawn) || QDELETED(target_tree)) // pawn can be null at this point
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	SEND_SIGNAL(living_pawn, COMSIG_LIVING_CLIMB_TREE, target_tree)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/climb_tree/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_planning_subtree/climb_trees
	operational_datums = list(/datum/component/tree_climber)
	///chance to climb a tree
	var/climb_chance = 35

/datum/ai_planning_subtree/climb_trees/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!DT_PROB(climb_chance, delta_time))
		return

	if(controller.blackboard_key_exists(BB_CLIMBED_TREE))
		controller.queue_behavior(/datum/ai_behavior/climb_tree, BB_CLIMBED_TREE)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_tree, BB_CLIMBED_TREE, /obj/structure/flora/tree)
