// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/space_fauna/mushroom.dm (tg 926bf40c5a)
// Replaces our simple animal walking mushroom (code/modules/mob/living/simple_animal/hostile/mushroom.dm), which the Aquila
// botany "killer fruit" trait (walking variant) awakens. Mushrooms only fight other mushrooms: they knock them out, chew
// on them and devour them on the third bite to level up; a bruised mushroom gives no levels; mushrooms in hand revive a
// fainted one. Kept from ours: Polish lines, health and damage rolls, the examine line about its health, the slow
// regeneration while conscious, the brief retreat after a hit (33%), revival only every 30 s. From tg: the AI goes for
// mushrooms on the floor and a mushroom eats one to heal (5). Fixed against tg: the devourer levels up itself (tg levelled
// up the eaten mushroom). Not ported: swabbing.

/mob/living/basic/mushroom
	name = "chodzący grzyb"
	desc = "To ogromny grzyb... z nogami?"
	icon_state = "mushroom_color"
	icon_living = "mushroom_color"
	icon_dead = "mushroom_dead"
	mob_biotypes = list(MOB_ORGANIC)

	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "wali"

	speed = 1
	melee_damage = 1
	maxHealth = 10
	health = 10
	obj_damage = 0
	attack_verb_continuous = "chrupie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(/obj/item/food/hugemushroomslice = 1)

	faction = list("mushroom")
	speak_emote = list("piszczy")
	death_message = "mdleje."
	mouse_opacity = MOUSE_OPACITY_ICON
	ventcrawler = VENTCRAWLER_ALWAYS
	unique_name = 1

	ai_controller = /datum/ai_controller/basic_controller/mushroom
	var/cap_color = "#ffffff"
	///Tracks our general strength level gained from eating other shrooms
	var/powerlevel = 0
	///If someone tries to cheat the system by attacking a shroom to lower its health, punish them so that it won't award levels to shrooms that eat it
	var/bruised = FALSE
	///If we hit three, another mushroom's gonna eat us
	var/faint_ticker = 0
	///Where we store our cap icons so we dont generate them constantly to update our icon
	var/static/mutable_appearance/cap_living
	///Where we store our cap icons so we dont generate them constantly to update our icon
	var/static/mutable_appearance/cap_dead
	///Cooldown that tracks how long its been since revival
	COOLDOWN_DECLARE(recovery_cooldown)

/mob/living/basic/mushroom/Initialize(mapload)
	melee_damage += rand(1, 15)
	maxHealth += rand(40, 60)
	. = ..()
	cap_living = cap_living || mutable_appearance(icon, "mushroom_cap")
	cap_dead = cap_dead || mutable_appearance(icon, "mushroom_cap_dead")
	cap_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	update_mushroomcap()
	health = maxHealth
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/mob/living/basic/mushroom/examine(mob/user)
	. = ..()
	if(health >= maxHealth)
		. += "<span class='info'>Wygląda na zdrowego.</span>"
	else
		. += "<span class='info'>Wygląda na poturbowanego.</span>"

/mob/living/basic/mushroom/Life(seconds, times_fired)
	. = ..()
	if(stat == CONSCIOUS) //Mushrooms slowly regenerate if conscious, for people who want to save them from being eaten
		adjustBruteLoss(-2)

/// Hit by anything: bruised (no levels for whoever eats it), and now and then it runs off for a moment
/mob/living/basic/mushroom/proc/on_attacked(mob/living/source, atom/attacker)
	SIGNAL_HANDLER
	if(stat == DEAD || attacker == src)
		return
	if(!bruised)
		visible_message("[name] zostaje poobijany!")
		bruised = TRUE
	if(prob(33) && ai_controller?.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		ai_controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, FALSE)
		addtimer(CALLBACK(src, PROC_REF(stop_retreat)), 3 SECONDS)

/mob/living/basic/mushroom/proc/stop_retreat()
	ai_controller?.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, TRUE)

/mob/living/basic/mushroom/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(proximity_flag && istype(attack_target, /obj/item/food/grown/mushroom))
		recover(attack_target)
		return TRUE
	return ..()

/mob/living/basic/mushroom/melee_attack(mob/living/basic/mushroom/target, list/modifiers, ignore_cooldown = FALSE)
	if(istype(target) && target.stat == DEAD)
		chew_on(target)
		return TRUE
	return ..()

/// Bites a fainted mushroom; the third bite devours it
/mob/living/basic/mushroom/proc/chew_on(mob/living/basic/mushroom/target)
	face_atom(target)
	changeNext_move(melee_attack_cooldown)
	if(target.faint_ticker < 2)
		target.faint_ticker++
		visible_message("[src] przeżuwa kawałek [target].")
		return
	consume_mushroom(target)

/mob/living/basic/mushroom/proc/consume_mushroom(mob/living/basic/mushroom/consumed)
	visible_message(span_warning("[src] pożera [consumed]!"))
	var/level_gain = (consumed.powerlevel - powerlevel)
	if(level_gain >= -1 && !ckey && !consumed.bruised) //Player shrooms can't level up to become robust gods.
		level_up(max(level_gain, 1)) // AQUILA: tg levelled up the eaten mushroom
	adjustBruteLoss(-maxHealth)
	qdel(consumed)

/mob/living/basic/mushroom/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(!.)
		return
	icon_state = "mushroom_color"
	update_mushroomcap()

/mob/living/basic/mushroom/death(gibbed)
	. = ..()
	update_mushroomcap()

/mob/living/basic/mushroom/proc/update_mushroomcap()
	cut_overlays()
	cap_living.color = cap_color
	cap_dead.color = cap_color
	if(stat == DEAD)
		add_overlay(cap_dead)
	else
		add_overlay(cap_living)

/// Eats a mushroom: a fainted one comes back to itself (once every 30 s), a living one heals a bit
/mob/living/basic/mushroom/proc/recover(obj/item/mush_meal, mob/user)
	if(stat == DEAD)
		if(!COOLDOWN_FINISHED(src, recovery_cooldown))
			if(user)
				to_chat(user, span_warning("[src] tego nie zje!"))
			return FALSE
		qdel(mush_meal)
		visible_message("[src] powoli zaczyna dochodzić do siebie.")
		faint_ticker = 0
		revive(full_heal = TRUE)
		COOLDOWN_START(src, recovery_cooldown, 30 SECONDS)
		return TRUE
	visible_message(span_notice("[src] zjada [mush_meal]!"))
	qdel(mush_meal)
	adjustBruteLoss(-5)
	return TRUE

/mob/living/basic/mushroom/proc/level_up(level_gain)
	adjustBruteLoss(-maxHealth) //They'll always heal, even if they don't gain a level
	if(powerlevel > 9)
		return
	powerlevel += level_gain
	melee_damage += (level_gain * rand(1, 5))
	maxHealth += (level_gain * rand(1, 5))

/mob/living/basic/mushroom/attackby(obj/item/mush, mob/living/carbon/human/user, params)
	if(istype(mush, /obj/item/food/grown/mushroom))
		recover(mush, user)
		return
	return ..()

/mob/living/basic/mushroom/harvest(mob/living/user)
	for(var/counter in 0 to powerlevel)
		var/obj/item/food/hugemushroomslice/shroomslice = new /obj/item/food/hugemushroomslice(src.loc)
		shroomslice.reagents.add_reagent(/datum/reagent/drug/mushroomhallucinogen, powerlevel)
		shroomslice.reagents.add_reagent(/datum/reagent/medicine/omnizine, powerlevel)
		shroomslice.reagents.add_reagent(/datum/reagent/medicine/synaptizine, powerlevel)

/datum/ai_controller/basic_controller/mushroom
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mushroom,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_BASIC_MOB_FLEE_DISTANCE = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target, // AQUILA: the brief retreat after a hit (BB_BASIC_MOB_STOP_FLEEING)
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/mushroom_food,
	)

/datum/targeting_strategy/basic/mushroom

///we only attack other mushrooms
/datum/targeting_strategy/basic/mushroom/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return !living_mob.faction_check_mob(the_target, exact_match = check_factions_exactly)

/datum/ai_planning_subtree/find_and_hunt_target/mushroom_food
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/reset_target
	hunt_targets = list(/obj/item/food/grown/mushroom)
	hunt_range = 6
