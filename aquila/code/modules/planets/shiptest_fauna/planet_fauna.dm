// AQUILA: fauna of the rock, sand, desert, shrouded and jungle planets, ported from Shiptest (AGPLv3) on our mobs.
// Sprites (CC BY-SA 3.0): Shiptest icons/mob/lavaland/lavaland_monsters.dmi, lavaland_monsters_wide.dmi and
// icons/mob/pets.dmi, copied to aquila/icons/planets/fauna/planet_fauna.dmi and planet_fauna_wide.dmi.
// - kapibara: Shiptest simple_animal/friendly/capybara.dm (a corgi subtype there) as a peaceful basic mob, no dog fashion;
// - mrówkolew and królowa mrówkolwów: Shiptest mining_mobs/antlion.dm; the burrow is a mob ability on a timer (Shiptest
//   switched the simple animal AI off and slept); while underground the antlion is untouchable and heals;
// - cragenoy (royalcrab): Shiptest datums/mapgen/planetary/shroudedGenerator.dm, a plain biting basic mob;
// - gruboid: Shiptest goliath/beast/rockplanet on our basic goliath (our goliath tentacles, not the gruboid's own sprite);
// - goliat z białych piasków: Shiptest goliath/beast/whitesands (+ /random with the ancient one, + /nest for burrows and
//   veins without the hide); its shell is a bullet and laser resistance (Shiptest's armour) on our basic goliath;
// - bazyliszek z białych piasków: Shiptest basilisk/whitesands on our basic basilisk: the shell soaks almost all damage until
//   it cracks (60 points), then drops two diamonds; as in Shiptest it also hunts watchers;
// - młody gruboid: Shiptest elite/broodmother_child/rockplanet, a sprite subtype of our simple broodmother child.
// Shiptest's hostile/lizard of the desert is the ordinary bug-eating lizard (our basic lizard), so it gets no type here.

/// Peaceful rodent of the jungle planets
/mob/living/basic/capybara
	name = "kapibara"
	desc = "To kapibara. Emanuje spokojem."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "capybara"
	icon_living = "capybara"
	icon_dead = "capybara_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("popiskuje", "szczeka")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "pacnięciem odsuwa"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "gryzie"
	maxHealth = 40
	health = 40
	melee_damage = 2
	faction = list(FACTION_NEUTRAL)
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/food/meat/slab = 2)
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/capybara

/datum/ai_controller/basic_controller/capybara
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_FLEE_DISTANCE = 7,
	)
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/capybara,
	)

/datum/ai_planning_subtree/random_speech/capybara
	speech_chance = 1
	speak = list("Iiik!", "Iiik.", "Hau!")
	emote_hear = list("popiskuje.", "pochrząkuje.")
	emote_see = list("kręci łebkiem.", "medytuje w spokoju.", "wygląda na pogodzoną ze światem.", "drży.")

/// Insect that burrows under its prey and bursts out beneath it
/mob/living/basic/mining/antlion
	name = "mrówkolew"
	desc = "Wielki owadopodobny stwór."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "antlion"
	icon_living = "antlion"
	icon_dead = "antlion_dead"
	mob_size = MOB_SIZE_HUMAN
	speak_emote = list("klika")
	maxHealth = 35
	health = 35
	speed = 2
	melee_damage = 10
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	sharpness = SHARP_POINTY
	butcher_results = list(/obj/item/food/meat/slab = 1)
	ai_controller = /datum/ai_controller/basic_controller/antlion
	/// Our burrowing ability
	var/datum/action/cooldown/mob_cooldown/antlion_burrow/burrow
	/// Health regained per second while burrowed
	var/heal_amount = 5

/mob/living/basic/mining/antlion/Initialize(mapload)
	. = ..()
	burrow = new(src)
	burrow.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, burrow)

/mob/living/basic/mining/antlion/Destroy()
	QDEL_NULL(burrow)
	return ..()

/mob/living/basic/mining/antlion/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat != DEAD && burrow?.burrowed)
		adjustBruteLoss(-heal_amount * delta_time)

/// A player in the antlion burrows towards something out of reach
/mob/living/basic/mining/antlion/RangedAttack(atom/target, modifiers)
	. = ..()
	burrow?.Trigger(target = target)

/// The antlion queen: huge and hard to kill
/mob/living/basic/mining/antlion/mega
	name = "królowa mrówkolwów"
	desc = "Ogromny mrówkolew. Nie wygląda na zadowolonego."
	icon_state = "queen"
	icon_living = "queen"
	icon_dead = "queen_dead"
	mob_size = MOB_SIZE_LARGE
	maxHealth = 175
	health = 175
	melee_damage = 25
	heal_amount = 20
	butcher_results = list(/obj/item/food/meat/slab = 4)

/mob/living/basic/mining/antlion/mega/Initialize(mapload)
	. = ..()
	transform = transform.Scale(2, 2)
	transform = transform.Translate(0, 16)

/// Dig in, tunnel next to the target, burst out and bite whoever stands on the tile
/datum/action/cooldown/mob_cooldown/antlion_burrow
	name = "Zakop się"
	desc = "Zakopuje się w ziemi i wyskakuje spod celu."
	icon_icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	button_icon_state = "antlion"
	cooldown_time = 15 SECONDS
	shared_cooldown = NONE
	/// Are we underground
	var/burrowed = FALSE
	/// Who we tunnel towards
	var/datum/weakref/burrow_target
	/// Timer of the tunnelling and of the emerging
	var/burrow_timer

/datum/action/cooldown/mob_cooldown/antlion_burrow/Destroy()
	if(burrow_timer)
		deltimer(burrow_timer)
		burrow_timer = null
	if(burrowed && !QDELETED(owner))
		emerge(attack = FALSE)
	return ..()

/datum/action/cooldown/mob_cooldown/antlion_burrow/Activate(atom/target)
	var/mob/living/living_owner = owner
	if(burrowed || !istype(living_owner) || living_owner.stat != CONSCIOUS)
		return FALSE
	var/turf/owner_turf = get_turf(owner)
	if(!istype(owner_turf, /turf/open/floor/plating/asteroid) || islava(owner_turf))
		owner.balloon_alert(owner, "za twardy grunt!")
		return FALSE
	burrow_target = WEAKREF(target)
	burrowed = TRUE
	playsound(owner_turf, 'sound/effects/bamf.ogg', 50, FALSE)
	owner.visible_message(span_notice("[owner] zakopuje się w [owner_turf]!"))
	new /obj/effect/temp_visual/burrow_sand_splash(owner_turf)
	living_owner.invisibility = INVISIBILITY_MAXIMUM
	living_owner.density = FALSE
	living_owner.status_flags |= GODMODE
	ADD_TRAIT(living_owner, TRAIT_IMMOBILIZED, REF(src))
	living_owner.ai_controller?.set_ai_status(AI_STATUS_OFF)
	burrow_timer = addtimer(CALLBACK(src, PROC_REF(tunnel)), 2 SECONDS, TIMER_STOPPABLE)
	StartCooldown()
	return TRUE

/// Move underground next to the target (or anywhere close if it is gone)
/datum/action/cooldown/mob_cooldown/antlion_burrow/proc/tunnel()
	burrow_timer = null
	if(QDELETED(owner))
		return
	var/atom/target = burrow_target?.resolve()
	var/list/exits = list()
	var/turf/center = target ? get_turf(target) : get_turf(owner)
	var/radius = target ? 1 : 5
	if(center && (!target || center.z == owner.z))
		for(var/turf/open/floor/plating/asteroid/exit in range(radius, center))
			if(!islava(exit) && !is_blocked_turf(exit, exclude_mobs = TRUE))
				exits += exit
	if(length(exits))
		owner.forceMove(pick(exits))
	burrow_timer = addtimer(CALLBACK(src, PROC_REF(emerge)), 1 SECONDS, TIMER_STOPPABLE)

/// Burst out of the ground
/datum/action/cooldown/mob_cooldown/antlion_burrow/proc/emerge(attack = TRUE)
	burrow_timer = null
	if(QDELETED(owner) || !burrowed)
		return
	burrowed = FALSE
	burrow_target = null
	var/mob/living/living_owner = owner
	var/turf/owner_turf = get_turf(owner)
	living_owner.invisibility = initial(living_owner.invisibility)
	living_owner.density = initial(living_owner.density)
	living_owner.status_flags &= ~GODMODE
	REMOVE_TRAIT(living_owner, TRAIT_IMMOBILIZED, REF(src))
	if(living_owner.stat != DEAD)
		living_owner.ai_controller?.set_ai_status(living_owner.ai_controller.get_expected_ai_status())
	if(!owner_turf)
		return
	owner.visible_message(span_danger("[owner] wyskakuje spod [owner_turf]!"))
	playsound(owner_turf, 'sound/effects/bamf.ogg', 50, FALSE)
	new /obj/effect/temp_visual/burrow_sand_splash(owner_turf)
	if(!attack || !isbasicmob(owner) || living_owner.stat != CONSCIOUS)
		return
	var/mob/living/basic/basic_owner = owner
	for(var/mob/living/carbon/human/victim in range(1, owner_turf))
		if(basic_owner.faction_check_mob(victim))
			continue
		basic_owner.melee_attack(victim, ignore_cooldown = TRUE)
		owner.visible_message(span_danger("[owner] wgryza się w [victim] spod ziemi!"))
		break

/obj/effect/temp_visual/burrow_sand_splash
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosionOLD"
	color = "#dbc56b"
	duration = 0.6 SECONDS

/datum/ai_controller/basic_controller/antlion
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/antlion_burrow,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/antlion,
	)

/// Burrow at a target 2-7 tiles away, most of the time (Shiptest: 70% of its ranged turns)
/datum/ai_planning_subtree/targeted_mob_ability/antlion_burrow

/datum/ai_planning_subtree/targeted_mob_ability/antlion_burrow/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		return FALSE
	var/distance = get_dist(controller.pawn, target)
	return distance >= 2 && distance <= 7 && prob(70)

/datum/ai_planning_subtree/random_speech/antlion
	speech_chance = 1
	emote_hear = list("kłapie żuwaczkami.")
	emote_see = list("otrzepuje się z piasku.")

/// Crustacean of the shrouded planets
/mob/living/basic/mining/royalcrab
	name = "cragenoy"
	desc = "Wygląda jak skorupiak o niezwykle twardym pancerzu. Uważaj na szczypce!"
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "royalcrab"
	icon_living = "royalcrab"
	icon_dead = "royalcrab_dead"
	mob_size = MOB_SIZE_HUMAN
	maxHealth = 50
	health = 50
	speed = 1
	melee_damage = 5
	attack_verb_continuous = "szczypie"
	attack_sound = 'sound/weapons/bite.ogg'
	butcher_results = list(/obj/item/food/meat/slab/rawcrab = 2)
	ai_controller = /datum/ai_controller/basic_controller/royalcrab

/datum/ai_controller/basic_controller/royalcrab
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/royalcrab,
	)

/datum/ai_planning_subtree/random_speech/royalcrab
	speech_chance = 1
	emote_see = list("przebiera odnóżami.", "sączy płyn z pyska.", "drapie ziemię.", "kłapie szczypcami.")

/// Burrowing worm of the rock planets
/mob/living/basic/mining/goliath/rockplanet
	name = "gruboid"
	desc = "Wygląda na olbrzymiego ryjącego robaka. Jego wici oplatają ofiary, które nie mogą się wtedy ruszyć."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "gruboid2"
	icon_living = "gruboid2"
	icon_dead = "gruboid_dead"
	tentacle_warning_state = "gruboid"
	tameable = FALSE

/// Goliath of the sand planets: a harder shell, a weaker body
/mob/living/basic/mining/goliath/whitesands
	name = "goliat z białych piasków"
	desc = "Gatunek goliata żyjący na piaszczystych planetach. Jego skorupa wytrzymuje więcej, ale skóra jest za to słabsza."
	icon = 'aquila/icons/planets/fauna/planet_fauna_wide.dmi'
	icon_state = "ws_goliath"
	icon_living = "ws_goliath"
	icon_dead = "ws_goliath_dead"
	tentacle_warning_state = "ws_goliath_preattack"
	pixel_x = -11
	base_pixel_x = -11
	maxHealth = 200
	health = 200
	speed = 10
	tameable = FALSE
	butcher_results = list(/obj/item/food/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/ore/silver = 10)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 2)
	/// How much of the damage of shots the shell lets through
	var/shell_ranged_coeff = 0.6

/mob/living/basic/mining/goliath/whitesands/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(istype(hitting_projectile) && hitting_projectile.damage > 0)
		hitting_projectile.damage *= shell_ranged_coeff
	return ..()

/// From a burrow or a vein: no hide
/mob/living/basic/mining/goliath/whitesands/nest
	guaranteed_butcher_results = list()

/// A sand goliath, now and then an ancient one (Shiptest: 5%)
/mob/living/basic/mining/goliath/whitesands/random

/mob/living/basic/mining/goliath/whitesands/random/Initialize(mapload)
	if(prob(5))
		new /mob/living/basic/mining/goliath/whitesands/ancient(loc)
		return INITIALIZE_HINT_QDEL
	return ..()

/mob/living/basic/mining/goliath/whitesands/ancient
	name = "pradawny goliat z białych piasków"
	desc = "Goliaty są biologicznie nieśmiertelne i rzadkie okazy przeżywają stulecia. Ten jest wyraźnie pradawny, a jego skorupa jest niebezpiecznie wytrzymała."
	icon_state = "ws_ancient_goliath"
	icon_living = "ws_ancient_goliath"
	icon_dead = "ws_ancient_goliath_dead"
	tentacle_warning_state = "ws_ancient_goliath_preattack"
	maxHealth = 300
	health = 300
	shell_ranged_coeff = 0.4

/// Basilisk of the sand planets, armoured by a shell until it cracks
/mob/living/basic/mining/basilisk/whitesands
	name = "bazyliszek z białych piasków"
	desc = "Rodzima bestia piaszczystych planet. Ta wyjątkowa mutacja wykształciła wokół ciała skorupę, która odbija wszystkie ataki, póki nie pęknie."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "basilisk_whitesands"
	icon_living = "basilisk_whitesands"
	icon_dead = "basilisk_whitesands_dead"
	maxHealth = 40
	health = 40
	butcher_results = list(/obj/item/stack/sheet/sinew = 4, /obj/item/stack/sheet/bone = 2)
	ai_controller = /datum/ai_controller/basic_controller/basilisk/whitesands
	/// Damage the shell soaks before it cracks
	var/shell_health = 60
	/// Part of the damage that gets through the shell
	var/shell_bleed = 0.1

/mob/living/basic/mining/basilisk/whitesands/Initialize(mapload)
	. = ..()
	// Our sprites have no alert state: the shell shows the alert of the plain basilisk
	qdel(GetComponent(/datum/component/appearance_on_aggro))

/mob/living/basic/mining/basilisk/whitesands/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && shell_health > 0 && !forced)
		shell_health -= amount
		amount *= shell_bleed
		if(shell_health <= 0)
			crack_shell()
		update_appearance()
	return ..()

/// The shell breaks: drop the diamonds in it
/mob/living/basic/mining/basilisk/whitesands/proc/crack_shell()
	var/turf/drop_turf = get_turf(src)
	if(drop_turf)
		new /obj/item/stack/ore/diamond(drop_turf, 2)
	playsound(src, "shatter", 80, FALSE)
	audible_message(span_danger("Skorupa [src] pęka z trzaskiem!"))
	throw_blocked_message = "odbija się od"

/mob/living/basic/mining/basilisk/whitesands/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	var/shell_state = "basilisk_whitesands"
	if(shell_health <= 0)
		shell_state = "basilisk_whitesands_shell0"
	else if(shell_health <= initial(shell_health) / 2)
		shell_state = "basilisk_whitesands_shell50"
	icon_state = shell_state
	icon_living = shell_state

/// Hunts watchers too, as in Shiptest
/datum/ai_controller/basic_controller/basilisk/whitesands
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/whitesands_basilisk,
		BB_AGGRO_RANGE = 5,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/targeting_strategy/basic/whitesands_basilisk

/datum/targeting_strategy/basic/whitesands_basilisk/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if(istype(the_target, /mob/living/basic/mining/watcher))
		return FALSE
	return ..()

/// Newborn gruboid of the rock planets
/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet
	name = "młody gruboid"
	desc = "Świeżo narodzony gruboid. Jego skóra jest słabsza niż u dorosłego, ale broni się równie skutecznie."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "gruboid_baby"
	icon_living = "gruboid_baby"
	icon_aggro = "gruboid_baby"
	icon_dead = "gruboid_baby_dead"
