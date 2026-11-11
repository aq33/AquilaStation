// AQUILA: new cat content from BeeStation/BeeStation-Hornet (decision D10): the cat house (code/game/objects/structures/cat_house.dm,
// the reside_in_home subtree of cat_ai.dm, the wood recipe) and the feral cat, Jerry and the tabby (cat.dm, feral.dm).
// Changes against Bee: a cat house only takes cats that are not dead, a cat that dies inside is pushed out, the overlay is
// refreshed through update_icon(); the AI enters the house only by clicking it (our ClickOn), Polish names.

/obj/structure/cat_house
	name = "domek dla kota"
	desc = "Przytulny dom dla kotów."
	icon = 'aquila/icons/obj/cat_house.dmi'
	icon_state = "cat_house"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	///cat residing in this house
	var/mob/living/resident_cat
	/// The timer details
	var/exit_timer_id

/obj/structure/cat_house/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_BASIC_MOB, PROC_REF(enter_home))

/obj/structure/cat_house/proc/enter_home(datum/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(isnull(resident_cat) && iscat(attacker) && attacker.stat == CONSCIOUS)
		attacker.forceMove(src)
		if(exit_timer_id)
			deltimer(exit_timer_id)
			exit_timer_id = null
		if(attacker.client) //  The cat is a player, no need for a timer
			return
		exit_timer_id = addtimer(CALLBACK(src, PROC_REF(eject_cat)), rand(10 SECONDS, 20 SECONDS), TIMER_STOPPABLE)
		return
	if(resident_cat == attacker) // Clicking again? let them out.
		eject_cat()

/// A cat inside clicks around or moves: it goes out
/obj/structure/cat_house/relaymove(mob/living/user, direction)
	if(user == resident_cat)
		eject_cat()

/obj/structure/cat_house/proc/eject_cat()
	if(exit_timer_id)
		deltimer(exit_timer_id)
		exit_timer_id = null
	if(isnull(resident_cat))
		return
	resident_cat.forceMove(drop_location())

/obj/structure/cat_house/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!iscat(arrived) || !isnull(resident_cat))
		return
	resident_cat = arrived
	RegisterSignal(resident_cat, COMSIG_LIVING_DEATH, PROC_REF(on_resident_death))
	update_icon(UPDATE_OVERLAYS)

/obj/structure/cat_house/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != resident_cat)
		return
	UnregisterSignal(resident_cat, COMSIG_LIVING_DEATH)
	resident_cat = null
	if(exit_timer_id)
		deltimer(exit_timer_id)
		exit_timer_id = null
	update_icon(UPDATE_OVERLAYS)

/obj/structure/cat_house/proc/on_resident_death(datum/source)
	SIGNAL_HANDLER
	eject_cat()

/obj/structure/cat_house/Destroy()
	eject_cat()
	return ..()

/obj/structure/cat_house/update_overlays()
	. = ..()
	if(isnull(resident_cat))
		return
	var/image/cat_icon = image(icon = resident_cat.icon, icon_state = resident_cat.icon_state, layer = LOW_ITEM_LAYER)
	cat_icon.transform = cat_icon.transform.Scale(0.7, 0.7)
	cat_icon.pixel_w = 0
	cat_icon.pixel_z = -9
	. += cat_icon

/// Cats now and then find a free cat house nearby, go in and come out after a while
/datum/ai_planning_subtree/reside_in_home
	///chance we enter our home
	var/reside_chance = 5
	///chance we leave our home
	var/leave_home_chance = 15

/datum/ai_planning_subtree/reside_in_home/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	if(istype(living_pawn.loc, /obj/structure/cat_house))
		var/obj/structure/cat_house/home = living_pawn.loc
		if(DT_PROB(leave_home_chance, delta_time))
			home.eject_cat()
		return SUBTREE_RETURN_FINISH_PLANNING

	if(controller.blackboard_key_exists(BB_CAT_HOME))
		controller.queue_behavior(/datum/ai_behavior/enter_cat_home, BB_CAT_HOME)
		return

	if(DT_PROB(reside_chance, delta_time))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_home, BB_CAT_HOME, /obj/structure/cat_house)

/datum/ai_behavior/find_and_set/valid_home/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	for(var/obj/structure/cat_house/home in oview(search_range, controller.pawn))
		if(home.resident_cat)
			continue
		return home

	return null

/datum/ai_behavior/enter_cat_home
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/enter_cat_home/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/enter_cat_home/perform(delta_time, datum/ai_controller/controller, target_key)
	var/obj/structure/cat_house/home = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	if(QDELETED(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(living_pawn == home.resident_cat || isnull(home.resident_cat))
		controller.ai_interact(target = home, combat_mode = FALSE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/enter_cat_home/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// A cat that bites; hostile to everyone but cats and the Syndicate
/mob/living/basic/pet/cat/feral
	name = "zdziczały kot"
	desc = "Kotek!! Czekaj, nie, nie, NIE GRYŹ-"
	health = 30
	maxHealth = 30
	melee_damage = 15
	obj_damage = 0
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_CAT, FACTION_SYNDICATE)

/mob/living/basic/pet/cat/jerry //Holy shit we left jerry on donut ~ Arcane ~Fikou
	name = "Jerry"
	desc = "Tom jest BARDZO rozbawiony."
	gender = MALE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/cat/tabby
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	held_state = "cat"
