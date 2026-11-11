// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/space_fauna/turtle/turtle.dm and turtle_ai.dm
// (BeeStation/BeeStation-Hornet#14771; Bee's own turtle, not the tg botany turtle). Polish lines from our simple animal turtle Frank.
// Changes against Bee: the shell hiding drops the turtle below projectiles (Bee set MOB_LAYER both ways, so hiding did nothing to the
// layer), our icon updates (no update_appearance flags), immobilised through a trait source; no new idle sounds.
#define TURTLE_SHELL_SOURCE "turtle_shell"

/mob/living/basic/turtle
	name = "Frank"
	desc = "Uroczy, powolny kumpel z Teksasu."
	icon = 'icons/mob/pets.dmi'
	icon_state = "yeeslow"
	icon_living = "yeeslow"
	icon_dead = "yeeslow_dead"
	base_icon_state = "yeeslow"
	speak_emote = list("ziewa")
	butcher_results = list(/obj/item/food/meat/slab = 1, /obj/item/clothing/head/franks_hat = 1)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	gold_core_spawnable = NO_SPAWN
	melee_damage = 0.5
	health = 2500
	maxHealth = 2500
	speed = 4
	can_be_held = TRUE
	chat_color = "#E7D26F"
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/turtle

	/// If we're currently hiding in our shell or not
	var/hiding = FALSE
	/// How long we wait in our shell after being attacked
	var/hide_time = 25 SECONDS

/mob/living/basic/turtle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/mob/living/basic/turtle/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER
	if(victim == attacker || stat == DEAD)
		return

	addtimer(CALLBACK(src, PROC_REF(emerge_from_shell)), hide_time, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(hiding)
		return

	hiding = TRUE
	layer = BELOW_MOB_LAYER // Allows projectiles to go over the shell instead of through it
	manual_emote("chowa się w skorupie!")
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, TURTLE_SHELL_SOURCE)
	update_mobility()
	icon_state = "[base_icon_state]_scared"

/mob/living/basic/turtle/proc/emerge_from_shell()
	if(!hiding)
		return
	hiding = FALSE
	layer = initial(layer)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TURTLE_SHELL_SOURCE)
	update_mobility()
	if(stat != DEAD)
		icon_state = icon_living

/mob/living/basic/turtle/death(gibbed)
	emerge_from_shell()
	return ..()

//Bullets
/mob/living/basic/turtle/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	return hiding ? BULLET_ACT_FORCE_PIERCE : ..()

/datum/ai_controller/basic_controller/turtle
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/headbutt_people, //playfully headbutt people's legs
		/datum/ai_planning_subtree/random_speech/turtle,
	)

/datum/ai_planning_subtree/find_and_hunt_target/headbutt_people
	target_key = BB_TURTLE_HEADBUTT_VICTIM
	finding_behavior = /datum/ai_behavior/find_hunt_target/human_to_headbutt
	hunting_behavior = /datum/ai_behavior/hunt_target/headbutt_leg
	hunt_targets = list(/mob/living/carbon/human)
	hunt_range = 4
	hunt_chance = 45

/datum/ai_behavior/find_hunt_target/human_to_headbutt
	action_cooldown = 2 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_hunt_target/human_to_headbutt/valid_dinner(mob/living/source, mob/living/carbon/human/dinner, radius, datum/ai_controller/controller, delta_time)
	if(dinner.stat != CONSCIOUS)
		return FALSE
	if(isnull(dinner.get_bodypart(BODY_ZONE_R_LEG)) && isnull(dinner.get_bodypart(BODY_ZONE_L_LEG))) //no legs to headbutt!
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/hunt_target/headbutt_leg
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/headbutt_leg/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("żartobliwie trąca łbem nogi [hunted]!")

/datum/ai_planning_subtree/random_speech/turtle
	speech_chance = 1
	emote_hear = list("chrapie.", "ziewa.")
	emote_see = list("wyciąga szyję.", "powoli się rozgląda.")

#undef TURTLE_SHELL_SOURCE
