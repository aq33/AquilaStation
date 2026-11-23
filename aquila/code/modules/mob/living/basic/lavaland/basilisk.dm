// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/basilisk/basilisk.dm (tg 926bf40c5a) in place of our simple
// animal basilisk (/mob/living/simple_animal/hostile/asteroid/basilisk). Polish lines, sprites, health, our frost blast
// and the two diamonds it drops. Changes against tg: no overheating (tg: a hot hit heals it fully, speeds it up and switches
// it to a 40 brute beam, with a 90% burn resistance; our basilisk was never heat resistant), the alert sprite is the aggro
// state; our explosion damage table stays.

/// Watchers' ground-dwelling cousins, they shoot at you until they get into melee.
/mob/living/basic/mining/basilisk
	name = "bazyliszek"
	desc = "Terytorialna bestia pokryta grubym pancerzem, który pochłania energię. Jej spojrzenie zamraża ofiary od środka."
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	speak_emote = list("terkocze")
	speed = 20
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage = 12
	attack_verb_continuous = "wgryza się w"
	throw_blocked_message = "nie przebija twardej skorupy"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	gold_core_spawnable = HOSTILE_SPAWN
	discovery_points = 2000
	ai_controller = /datum/ai_controller/basic_controller/basilisk

/mob/living/basic/mining/basilisk/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/item/projectile/temp/basilisk, projectile_sound = 'sound/weapons/pierce.ogg', cooldown_time = 3 SECONDS)
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "Basilisk_alert")
	var/static/list/death_loot = list(/obj/item/stack/ore/diamond = 2)
	AddElement(/datum/element/death_drops, death_loot)

/mob/living/basic/mining/basilisk/ex_act(severity, target, origin)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(140)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(110)

/datum/ai_controller/basic_controller/basilisk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction, // AQUILA: never a fellow mining mob (as the goliath and watcher)
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
