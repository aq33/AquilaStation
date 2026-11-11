// AQUILA: ports of tgstation basic mobs from the last revision before behaviour trees (tg 926bf40c5a, decision D15), on the Bee AI core:
// space bat (code/modules/mob/living/basic/vermin/space_bat.dm), killer tomato (space_fauna/killer_tomato.dm) and frog (vermin/frog.dm).
// Polish names and lines of our simple animals. Changes against tg:
// - bat: our vampire bat and Sergeant Araneus (the head of security's spider, a bat for historical reasons) stay as subtypes;
// - killer tomato: no MOB_PLANT biotype here; our frenzy (tomatoes attacking each other in a crowd) is gone, as in tg;
// - frog: no fishing fear, swimming, swabbing or regal rat minions (we lack them), so the frog only retaliates; it bites with
//   space drugs as in tg; the rare frog is a 1% roll on the common frog, as before, and also a subtype.

/mob/living/basic/bat
	name = "kosmiczny nietoperz"
	desc = "Rzadka odmiana nietoperza, która gnieździ się na statkach kosmicznych. Raczej nie jest wampirem."
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"

	maxHealth = 15
	health = 15
	melee_damage = 6
	see_in_dark = 10

	response_help_continuous = "odsuwa na bok"
	response_disarm_continuous = "macha rękami na"
	response_harm_continuous = "uderza"
	attack_verb_continuous = "gryzie"
	speak_emote = list("piszczy")

	faction = list(FACTION_HOSTILE)
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	butcher_results = list(/obj/item/food/meat/slab = 1)
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	spacewalk = TRUE

	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	environment_smash = ENVIRONMENT_SMASH_NONE
	mob_size = MOB_SIZE_TINY
	obj_damage = 0
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0

	ai_controller = /datum/ai_controller/basic_controller/space_bat

/mob/living/basic/bat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/bat/vampire
	desc = "Rzadka odmiana nietoperza, która gnieździ się na statkach kosmicznych.\nWygląda na trochę... zakrwawiony."
	speed = -1.5

//Despite being a bat for... reasons, this is now a spider, and is one of the HoS' pets.
/mob/living/basic/bat/sgt_araneus
	name = "Sierżant Araneus"
	real_name = "Sierżant Araneus"
	desc = "Groźny towarzysz Komendanta. Ten pająk został starannie wyszkolony przez specjalistów Nanotrasen. Jego paciorkowate, wpatrzone oczka przyprawiają cię o dreszcze."
	speak_emote = list("terkocze")
	faction = list("spiders")
	icon_dead = "guard_dead"
	icon_gib = "guard_dead"
	icon_living = "guard"
	icon_state = "guard"
	maxHealth = 250
	health = 250
	melee_damage = 15
	response_help_continuous = "głaszcze"
	unsuitable_atmos_damage = 1
	minimum_survivable_temperature = 250
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/space_bat/araneus

/mob/living/basic/bat/sgt_araneus/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/simple_flying)

///Controller for space bats, has nothing unique, just retaliation.
/datum/ai_controller/basic_controller/space_bat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Araneus chitters now and then, as our simple animal did
/datum/ai_controller/basic_controller/space_bat/araneus
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/araneus,
	)

/datum/ai_planning_subtree/random_speech/araneus
	speech_chance = 1
	emote_hear = list("terkocze")

/*
* ## Killer Tomatoes
*
* Side effect from when you try to play God through genetic engineering. Feisty fuckers that want to eat you. Dangerous.
*/
/mob/living/basic/killer_tomato
	name = "pomidor zabójca"
	desc = "To przerażająco ogromny pomidor malinowy, który ma niezłą krzepę!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	mob_biotypes = list(MOB_ORGANIC)
	gender = NEUTER
	speed = 1 // if you wanna touch this, keep in mind we want to incentivize people growing really good botany plants in order to make these buggers faster.
	maxHealth = 30
	health = 30
	see_in_dark = 3
	butcher_results = list(/obj/item/food/meat/slab/killertomato = 2)
	response_help_continuous = "dźga"
	response_disarm_continuous = "odsuwa na bok"
	response_harm_continuous = "trzepie"
	melee_damage = 10
	attack_verb_continuous = "grzmoci"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("plants")
	ventcrawler = VENTCRAWLER_ALWAYS
	mobchatspan = "headofsecurity"
	discovery_points = 1000

	habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 150
	maximum_survivable_temperature = 500
	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/killer_tomato

/datum/ai_controller/basic_controller/killer_tomato
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/killer_tomato,
	)

/datum/ai_planning_subtree/random_speech/killer_tomato
	speech_chance = 3
	emote_hear = list("zgrzyta zębami.", "nisko warczy.", "warczy.")
	emote_see = list("ślini się.")

/mob/living/basic/frog
	name = "żaba"
	desc = "Wydaje się trochę smutna."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("rechocze")
	maxHealth = 15
	health = 15
	speed = 1.1
	melee_damage = 5
	obj_damage = 10
	attack_verb_continuous = "gryzie"
	melee_attack_cooldown = 2.5 SECONDS
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "szturcha"
	response_harm_continuous = "rozpłaszcza"
	density = FALSE
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)
	attack_sound = 'sound/effects/reee.ogg'
	butcher_results = list(/obj/item/food/nugget = 1)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = HOSTILE_SPAWN

	habitable_atmos = list("min_oxy" = 3, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 15, "min_co2" = 0, "max_co2" = 15, "min_n2" = 0, "max_n2" = 0)

	ai_controller = /datum/ai_controller/basic_controller/frog

	var/stepped_sound = 'sound/effects/huuu.ogg'
	///How much of a reagent the mob injects on attack
	var/poison_per_bite = 3
	///What reagent the mob injects targets with
	var/poison_type = /datum/reagent/drug/space_drugs
	/// Can this frog roll the rare look (AQUILA: our old 1% roll)
	var/can_be_rare = TRUE

/mob/living/basic/frog/Initialize(mapload)
	. = ..()
	if(can_be_rare && prob(1))
		make_rare()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/venomous, poison_type, poison_per_bite)
	AddElement(/datum/element/ai_retaliate)

/// The smug look of the rare frog, with more nuggets
/mob/living/basic/frog/proc/make_rare()
	name = "rzadka żaba"
	real_name = name
	desc = "Wydaje się trochę zadowolona z siebie."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	butcher_results = list(/obj/item/food/nugget = 5)

/mob/living/basic/frog/proc/on_entered(datum/source, entered as mob|obj)
	SIGNAL_HANDLER
	if(stat || !isliving(entered))
		return
	var/mob/living/entered_mob = entered
	if(entered_mob.mob_size > MOB_SIZE_TINY)
		playsound(src, stepped_sound, 50, TRUE)

/mob/living/basic/frog/rare
	can_be_rare = FALSE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/frog/rare/Initialize(mapload)
	. = ..()
	make_rare()

/datum/ai_controller/basic_controller/frog
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/random_speech/frog,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/frog
	speech_chance = 1
	speak = list("kum", "rech")
	emote_see = list("skacze w kółko.", "trzęsie się.")
