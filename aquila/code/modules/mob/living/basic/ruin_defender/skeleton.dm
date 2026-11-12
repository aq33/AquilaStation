// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/ruin_defender/skeleton.dm (tg 926bf40c5a)
// Replaces our simple animal skeletons (code/modules/mob/living/simple_animal/hostile/skeleton.dm and the gold core
// override in aquila/). Kept from ours: Polish lines, the per-subtype sprites of simple_human.dmi (tg builds a dynamic human
// appearance we do not have), health, damage, speeds, loot, the eskimo (tg's settler) and the templar war cries.
// From tg: milk heals them (50) and soy milk burns them (25), found by the AI too. Rattling is a random emote (1%/s)
// instead of tg's run_emote (20%/s), because there is no "rattle" emote here. Unlike tg, the AI smashes dense objects in
// its way (doors, tables, windows) as our simple skeletons did; no skeleton breaks walls, the jackhammer miner included
// (its environment_smash is kept only for mechs and player control).

/mob/living/basic/skeleton
	name = "ożywiony szkielet"
	hardattacks = TRUE // nasty blocks (energy sword, chainsaw) do not hurt it, as our simple animal
	desc = "Szkielet z krwi i kości, choć bez krwi. Nie wygląda na towarzyskiego."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skeleton"
	icon_living = "skeleton"
	icon_dead = "skeleton"
	gender = NEUTER
	mob_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	speak_emote = list("grzechocze")
	combat_mode = TRUE
	maxHealth = 40
	health = 40
	speed = 1
	melee_damage = 15
	healable = FALSE //they're skeletons how would bruise packs help them??
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("skeleton")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	death_message = "rozpada się w stos kości!"
	basic_mob_flags = DEL_ON_DEATH
	do_footstep = TRUE
	mobchatspan = "assistant"
	discovery_points = 2000
	ai_controller = /datum/ai_controller/basic_controller/skeleton

/mob/living/basic/skeleton/Initialize(mapload)
	. = ..()
	var/list/drops = get_death_loot()
	if(length(drops))
		AddElement(/datum/element/death_drops, drops)
	var/static/list/good_drinks = list(/obj/item/reagent_containers/food/condiment/milk)
	var/static/list/bad_drinks = list(/obj/item/reagent_containers/food/condiment/soymilk)
	AddElement(/datum/element/basic_eating, heal_amt = 50, drinking = TRUE, food_types = good_drinks)
	AddElement(/datum/element/basic_eating, heal_amt = 0, damage_amount = 25, damage_type = BURN, drinking = TRUE, food_types = bad_drinks)
	weather_immunities |= "snow"
	var/static/list/foods_list
	if(isnull(foods_list))
		foods_list = typecacheof(good_drinks + bad_drinks)
	ai_controller?.set_blackboard_key(BB_BASIC_FOODS, foods_list)

/// What the skeleton leaves behind. A static list per subtype, so the bespoke death_drops element is shared.
/mob/living/basic/skeleton/proc/get_death_loot()
	var/static/list/drops = list(/obj/effect/decal/remains/human)
	return drops

/mob/living/basic/skeleton/eskimo
	name = "nieumarły Eskimos"
	desc = "Ożywione szczątki jakiegoś biednego podróżnika."
	icon_state = "eskimo"
	icon_living = "eskimo"
	icon_dead = "eskimo_dead"
	maxHealth = 55
	health = 55
	gold_core_spawnable = NO_SPAWN
	melee_damage = 20
	attack_vis_effect = ATTACK_EFFECT_SLASH
	death_message = "rozpada się w stos kości, a jego sprzęt spada na podłogę!"

/mob/living/basic/skeleton/eskimo/get_death_loot()
	var/static/list/drops = list(
		/obj/effect/decal/remains/human,
		/obj/item/spear,
		/obj/item/clothing/shoes/winterboots,
		/obj/item/clothing/suit/hooded/wintercoat,
	)
	return drops

/mob/living/basic/skeleton/templar
	name = "nieumarły templariusz"
	desc = "Ożywione szczątki świętego rycerza templariusza."
	icon_state = "templar"
	icon_living = "templar"
	icon_dead = "templar_dead"
	maxHealth = 150
	health = 150
	speed = 2
	gold_core_spawnable = NO_SPAWN
	force_threshold = 10 //trying to simulate actually having armor
	obj_damage = 50
	melee_damage = 30
	attack_vis_effect = ATTACK_EFFECT_SLASH
	death_message = "rozpada się w stos kości, a jego sprzęt z brzękiem uderza o ziemię!"
	ai_controller = /datum/ai_controller/basic_controller/skeleton/templar

/mob/living/basic/skeleton/templar/get_death_loot()
	var/static/list/drops = list(
		/obj/effect/decal/remains/human,
		/obj/item/clothing/suit/armor/riot/chaplain,
		/obj/item/clothing/head/helmet/chaplain,
		/obj/item/claymore/weak{name = "święty miecz"},
	)
	return drops

/mob/living/basic/skeleton/ice
	name = "lodowy szkielet"
	desc = "Ożywiony szkielet chroniony grubym pancerzem z naturalnego lodu. Wygląda jednak na powolnego."
	speed = 5
	maxHealth = 75
	health = 75
	color = rgb(114,228,250)

/mob/living/basic/skeleton/ice/get_death_loot()
	var/static/list/drops = list(/obj/effect/decal/remains/human{color = rgb(114,228,250)})
	return drops

/mob/living/basic/skeleton/plasmaminer
	name = "powłóczący nogami górnik"
	desc = "Przesiąknięty plazmą górnik. Jego odsłonięte kończyny zmieniły się w obrzydliwie żarzące się kości, jakby zrobione z plazmy."
	icon_state = "plasma_miner"
	icon_living = "plasma_miner"
	icon_dead = "plasma_miner"
	maxHealth = 150
	health = 150
	melee_damage = 17
	light_color = LIGHT_COLOR_PURPLE
	death_message = "rozpada się w stos kości, a skafander rozpuszcza się w plazmie!"

/mob/living/basic/skeleton/plasmaminer/Initialize(mapload)
	. = ..()
	set_light(2)

/mob/living/basic/skeleton/plasmaminer/get_death_loot()
	var/static/list/drops = list(/obj/effect/decal/remains/plasma)
	return drops

/mob/living/basic/skeleton/plasmaminer/jackhammer
	desc = "Przesiąknięty plazmą górnik. Jego odsłonięte kończyny zmieniły się w obrzydliwie żarzące się kości, jakby zrobione z plazmy. Wciąż kurczowo ściska w dłoni swoje narzędzie górnicze."
	icon_state = "plasma_miner_tool"
	icon_living = "plasma_miner_tool"
	icon_dead = "plasma_miner_tool"
	maxHealth = 185
	health = 185
	melee_damage = 22
	attack_verb_continuous = "razi"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_vis_effect = null
	environment_smash = ENVIRONMENT_SMASH_WALLS

/mob/living/basic/skeleton/plasmaminer/jackhammer/get_death_loot()
	var/static/list/drops = list(/obj/effect/decal/remains/plasma, /obj/item/pickaxe/drill/jackhammer)
	return drops

// Skeleton AI

/datum/ai_planning_subtree/random_speech/skeleton
	speech_chance = 1
	emote_see = list("grzechocze")

/datum/ai_planning_subtree/random_speech/skeleton/templar
	speak = list("BOGOWIE TEGO CHCĄ!","DEUS VULT!","WYRZUCIĆ KEBAB!")

/// Skeletons mostly just beat people to death, but they'll also find and drink milk.
/datum/ai_controller/basic_controller/skeleton
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS, // AQUILA: our stat_attack, tg HARD_CRIT
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/random_speech/skeleton,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/skeleton/templar
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/random_speech/skeleton/templar,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
