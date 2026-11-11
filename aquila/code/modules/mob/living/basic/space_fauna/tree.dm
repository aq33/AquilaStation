// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/tree.dm and festivus_pole.dm (tg 926bf40c5a)
// Replaces our simple animal pine tree and festivus pole (code/modules/mob/living/simple_animal/hostile/tree.dm).
// Polish lines, health, damage and the oxygen it breathes out from our tree; from tg: knocking down people (more often
// those holding a chainsaw, hatchet or wood) and the growl when it picks a target. The festivus pole is a subtype of the
// tree, as in our code: it recharges cells when rubbed (tg), but its APC charging ability waits for the mob ability
// framework (decision 10 of raport/mobabilities_03). Not ported: seethrough_mob and swabbing (we have neither).

/mob/living/basic/tree
	name = "sosna"
	desc = "Wkurzony obcy przypominający drzewo. Chyba irytują go świąteczne obchody..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	mob_biotypes = list(MOB_ORGANIC)
	gender = NEUTER
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH

	response_help_continuous = "szczotkuje"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "uderza"

	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	base_pixel_x = -16

	speed = 1
	maxHealth = 250
	health = 250
	melee_damage = 10
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list("hostile")
	speak_emote = list("szumi")

	habitable_atmos = list("min_oxy" = 2, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2.5
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1200

	death_message = "zostaje posiekany na kawałki!"
	discovery_points = 1000

	ai_controller = /datum/ai_controller/basic_controller/tree

	///items that make us angry
	var/list/infuriating_objects = list(/obj/item/chainsaw, /obj/item/hatchet, /obj/item/stack/sheet/mineral/wood)
	///chance of target getting paralyzed
	var/paralyze_prob = 15
	///for how the target is  paralyzed
	var/paralyze_value = 5 SECONDS
	///Additional paralyze chance
	var/anger_boost = 50

/mob/living/basic/tree/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, get_death_loot())
	AddComponent(/datum/component/aggro_emote, emote_list = string_list(list("warczy")), emote_chance = 20)

/// What the tree leaves behind (static per subtype, the death_drops element is bespoke)
/mob/living/basic/tree/proc/get_death_loot()
	var/static/list/drops = list(/obj/item/stack/sheet/mineral/wood)
	return drops

/mob/living/basic/tree/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || QDELETED(src))
		return
	if(!isopenturf(loc))
		return
	var/turf/open/our_turf = src.loc
	if(!our_turf.air)
		return
	var/co2 = our_turf.air.get_moles(GAS_CO2)
	if(co2 > 0 && prob(25))
		var/amt = min(co2, 9)
		our_turf.air.adjust_moles(GAS_CO2, -amt)
		our_turf.atmos_spawn_air("o2=[amt];TEMP=293.15")

/mob/living/basic/tree/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()

	if(!.)
		return

	if(!isliving(target))
		return

	var/mob/living/victim = target
	var/boost = 0
	if(iscarbon(victim))
		for(var/item_path in infuriating_objects)
			if(locate(item_path) in victim.held_items)
				boost = anger_boost
				break

	if(prob(paralyze_prob + boost))
		victim.Paralyze(paralyze_value + boost)
		victim.visible_message(
			span_danger("[src] przewraca [victim]!"),
			span_userdanger("[src] cię przewraca!"),
		)

/datum/ai_planning_subtree/random_speech/tree
	speech_chance = 3
	emote_see = list("ze złością fotosyntetyzuje.")

/datum/ai_controller/basic_controller/tree
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/tree,
	)

///how much charge we give off to cells around us when rubbed
#define FESTIVUS_RECHARGE_VALUE 75

/mob/living/basic/tree/festivus
	name = "słup Festivusa"
	desc = "Spokój... SPOKÓJ NATYCHMIAST!"
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	mob_biotypes = list(MOB_MINERAL)
	response_help_continuous = "pociera"
	speak_emote = list("szeleści")
	maxHealth = 200
	health = 200
	faction = list("hostile")
	// tg's pole only bites, it does not knock people down
	paralyze_prob = 0
	anger_boost = 0
	ai_controller = /datum/ai_controller/basic_controller/tree/festivus

/mob/living/basic/tree/festivus/get_death_loot()
	var/static/list/drops = list(/obj/item/stack/rods)
	return drops

/mob/living/basic/tree/festivus/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		return
	visible_message(span_warning("[src] trzeszczy od ładunków elektrostatycznych!"))
	for(var/atom/affected in range(2, get_turf(src)))
		if(istype(affected, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/cell = affected
			cell.give(FESTIVUS_RECHARGE_VALUE)
			cell.update_icon()
		if(istype(affected, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/robot = affected
			robot.cell?.give(FESTIVUS_RECHARGE_VALUE)
		if(istype(affected, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc_target = affected
			apc_target.cell?.give(FESTIVUS_RECHARGE_VALUE)

#undef FESTIVUS_RECHARGE_VALUE

/// The pole has no APC charging ability yet (mob ability framework), so it only hunts people like the tree
/datum/ai_controller/basic_controller/tree/festivus
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
