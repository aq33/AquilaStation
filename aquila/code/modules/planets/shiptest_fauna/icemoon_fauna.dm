// AQUILA: fauna of the ice planets on our basic mobs. Sprites (CC BY-SA 3.0): tgstation icons/mob/simple/icemoon/
// icemoon_monsters.dmi, Shiptest icons/mob/icemoon/icemoon_monsters.dmi (alpha wolf, primordial demon), icons/mob/basic/
// bear.dmi and icons/mob/basic/snow_monkey.dmi, copied to aquila/icons/planets/fauna/planet_fauna.dmi.
// - white wolf: tgstation code/modules/mob/living/basic/icemoon/wolf/ (AGPLv3) with the lunge and the alpha of Shiptest's
//   asteroid/wolf (mining_mobs/wolf.dm, AGPLv3); tg's behaviour tree is rewritten on our planning subtrees: the pack howls
//   for help, bites, lunges from a distance and runs off when badly hurt. No taming, riding or pet commands (tg) and no
//   wolf sinew or crusher trophy (we have neither);
// - polar bear: tgstation icemoon/polar_bear/ (AGPLv3): it ignores you unless you come within two tiles, then fights to
//   the death; the polar warbear is Shiptest's basic/bear/polar/warrior (space_fauna/bear/bear.dm). No polar bear hide;
// - brown bear: Shiptest's basic/bear/cave, our basic bear with a mining faction;
// - snow legion: tg's lavaland/legion/legion.dm /snow on our basic legion; the spawner_made one leaves a charred skeleton;
// - snow monkey: Shiptest basic/icemoon/snow_monkies/ (AGPLv3). It wanders and chatters; the garden harvesting is left out
//   (our planets have botany plants, not Shiptest's gardens).

/// Lunges at its prey from a distance, calls the pack and flees when badly hurt
/mob/living/basic/mining/wolf
	name = "biały wilk"
	desc = "Stadny łowca lodowych pustkowi. Pojedynczo to tylko utrapienie, ale w większej grupie potrafi być groźny. Uważaj na skok!"
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "whitewolf"
	icon_living = "whitewolf"
	icon_dead = "whitewolf_dead"
	mouse_opacity = MOUSE_OPACITY_ICON
	mob_size = MOB_SIZE_HUMAN
	speak_emote = list("wyje")
	friendly_verb_continuous = "wyje na"
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/item/stack/sheet/bone = 2)
	maxHealth = 130
	health = 130
	speed = 1
	obj_damage = 15
	melee_damage = 7.5
	melee_attack_cooldown = 1.2 SECONDS
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	death_message = "warczy po raz ostatni i pada."
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	weather_immunities = list("snow")
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/wolf
	/// Our lunge
	var/datum/action/cooldown/mob_cooldown/planet_charge/wolf/lunge
	/// Type of our lunge
	var/lunge_type = /datum/action/cooldown/mob_cooldown/planet_charge/wolf

/mob/living/basic/mining/wolf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_flee_while_injured, stop_fleeing_at = 0.5, start_fleeing_below = 0.15)
	lunge = new lunge_type(src)
	lunge.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, lunge)

/mob/living/basic/mining/wolf/Destroy()
	QDEL_NULL(lunge)
	return ..()

/// A player in the wolf lunges by clicking something out of reach
/mob/living/basic/mining/wolf/RangedAttack(atom/target, modifiers)
	. = ..()
	lunge?.Trigger(target = target)

/// Leader of the pack: bigger, tougher, lunges further
/mob/living/basic/mining/wolf/alpha
	name = "wilk alfa"
	desc = "Stary wilk o skołtunionej, brudnej sierści i z jednym okiem, trofeami wielu wygranych walk i udanych łowów. Wygląda na przywódcę tutejszej watahy. Uważaj na skok!"
	icon_state = "alphawolf"
	icon_living = "alphawolf"
	icon_dead = "alphawolf_dead"
	maxHealth = 200
	health = 200
	melee_damage = 10
	obj_damage = 30
	lunge_type = /datum/action/cooldown/mob_cooldown/planet_charge/wolf/alpha

/// A white wolf, now and then an alpha (Shiptest: 15%)
/mob/living/basic/mining/wolf/random

/mob/living/basic/mining/wolf/random/Initialize(mapload)
	// Najpierw pełna inicjalizacja: basic mob zwrócony do qdel przed ..() rozpada się w Destroy
	. = ..()
	if(prob(15))
		new /mob/living/basic/mining/wolf/alpha(loc)
		return INITIALIZE_HINT_QDEL

/datum/action/cooldown/mob_cooldown/planet_charge/wolf
	name = "Skok"
	desc = "Rzuca się na ofiarę i przewraca ją."
	cooldown_time = 10 SECONDS
	charge_distance = 8
	knockdown_duration = 1 SECONDS

/datum/action/cooldown/mob_cooldown/planet_charge/wolf/alpha
	cooldown_time = 8 SECONDS
	charge_distance = 10
	knockdown_duration = 1.5 SECONDS

/datum/ai_controller/basic_controller/wolf
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_BASIC_MOB_FLEE_DISTANCE = 15,
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_REINFORCEMENTS_EMOTE = "wydaje mrożące krew w żyłach wycie, wzywając watahę!",
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/targeted_mob_ability/planet_charge,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Ignores you until you come close, then does not stop
/mob/living/basic/mining/polarbear
	name = "niedźwiedź polarny"
	desc = "Agresywne zwierzę, które broni swojego terytorium z niewiarygodną siłą. Te bestie nie uciekają przed wrogami."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "polarbear"
	icon_living = "polarbear"
	icon_dead = "polarbear_dead"
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "warczy na"
	speak_emote = list("warczy")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	attack_verb_continuous = "drapie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speed = 2
	maxHealth = 300
	health = 300
	obj_damage = 40
	melee_damage = 25
	sharpness = SHARP_EDGED
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/food/meat/slab/bear = 3, /obj/item/stack/sheet/bone = 2)
	weather_immunities = list("snow")
	spacewalk = TRUE
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/polar_bear

/mob/living/basic/mining/polarbear/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	return ..()

/mob/living/basic/mining/polarbear/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(!.)
		return
	move_force = initial(move_force)
	move_resist = initial(move_resist)
	pull_force = initial(pull_force)

/// Shiptest's polar warbear: a remnant of the Wojtek-Aleph programme
/mob/living/basic/mining/polarbear/warrior
	name = "polarny niedźwiedź bojowy"
	desc = "Agresywne zwierzę, które broni swojego terytorium z niewiarygodną siłą. Ten wygląda na pozostałość krótkotrwałego programu Wojtek-Alef."
	icon_state = "warbear"
	icon_living = "warbear"
	icon_dead = "warbear_dead"
	attack_verb_continuous = "okłada ciosami"
	maxHealth = 400
	health = 400
	melee_damage = 35
	obj_damage = 60
	armour_penetration = 20
	butcher_results = list(/obj/item/food/meat/slab/bear = 3, /obj/item/stack/sheet/bone = 2, /obj/item/bear_armor = 1)

/datum/ai_controller/basic_controller/polar_bear
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 2,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/bear,
	)

/// Brown bear of the jungle and water planet caves (Shiptest basic/bear/cave)
/mob/living/basic/bear/cave
	name = "niedźwiedź brunatny"
	desc = "Groźny niedźwiedź brunatny, gotów rozszarpać każdego."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	icon_gib = "brownbear_gib"
	maxHealth = 70
	health = 70
	spacewalk = FALSE
	faction = list("mining")
	gold_core_spawnable = NO_SPAWN

/// A polar bear, now and then a warbear (Shiptest's spawner/random/polar_bear: 85/15)
/obj/effect/spawner/lootdrop/polar_bear
	name = "losowy niedźwiedź polarny"
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "polarbear"
	loot = list(
		/mob/living/basic/mining/polarbear = 85,
		/mob/living/basic/mining/polarbear/warrior = 15,
	)

/// Snow legion: a legion under packed snow, which only stirs when it sees prey
/mob/living/basic/mining/legion/snow
	name = "śnieżny legion"
	desc = "Pod gęsto ubitym śniegiem ledwo widać, kim kiedyś był: człowiekiem. Słodkie, ale makabryczne."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "snowlegion"
	icon_living = "snowlegion"
	icon_dead = "snowlegion"
	brood_type = /mob/living/basic/mining/legion_brood/snow
	weather_immunities = list("snow")

/mob/living/basic/mining/legion/snow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "snowlegion_alive")

/// From a burrow or a vein: leaves only a charred skeleton
/mob/living/basic/mining/legion/snow/spawner_made
	corpse_type = /obj/effect/mob_spawn/human/corpse/charredskeleton

/mob/living/basic/mining/legion_brood/snow
	name = "śnieżny legion"
	desc = "Jeden z wielu."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "snowlegion_head"
	icon_living = "snowlegion_head"
	icon_dead = "snowlegion_head"
	weather_immunities = list("snow")

/mob/living/basic/mining/legion_brood/snow/get_legion_type(mob/living/carbon/human/target)
	return /mob/living/basic/mining/legion/snow

/// Peaceful monkey of the cold planets
/mob/living/basic/snow_monkey
	name = "śnieżna małpa"
	desc = "Spotykana na zimnych planetach. Przyjazne zwierzę o dziwnych zwyczajach: toczy śnieżne kule i kąpie się w gorących źródłach."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "snow_monkey"
	icon_living = "snow_monkey"
	icon_dead = "snow_monkey_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("skrzeczy")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "odpycha"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "drapie"
	maxHealth = 30
	health = 30
	melee_damage = 2
	minimum_survivable_temperature = 170
	weather_immunities = list("snow")
	faction = list(FACTION_NEUTRAL)
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/food/meat/slab/monkey = 2)
	ai_controller = /datum/ai_controller/basic_controller/snow_monkey

/mob/living/basic/snow_monkey/Initialize(mapload)
	. = ..()
	// Ucieczka przed napastnikiem czyta listę atakujących, którą wypełnia ten element
	AddElement(/datum/element/ai_retaliate)
	if(gender == FEMALE)
		icon_state = "snow_monkey_butt"
		icon_living = "snow_monkey_butt"
		icon_dead = "snow_monkey_butt_dead"

/datum/ai_controller/basic_controller/snow_monkey
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
		/datum/ai_planning_subtree/random_speech/snow_monkey,
	)

/datum/ai_planning_subtree/random_speech/snow_monkey
	speech_chance = 2
	speak = list("Uuk!", "Uuk uuk!", "Iii!")
	emote_hear = list("skrzeczy.", "pohukuje.")
	emote_see = list("toczy śnieżną kulkę.", "drapie się po głowie.", "otrzepuje futro ze śniegu.")

/// A troop of 2-5 snow monkeys (Shiptest's spawner/random/snow_monkey_pack)
/obj/effect/spawner/lootdrop/snow_monkey_pack
	name = "stado śnieżnych małp"
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "snow_monkey"
	loot = list(/mob/living/basic/snow_monkey = 1)

/obj/effect/spawner/lootdrop/snow_monkey_pack/Initialize(mapload)
	lootcount = rand(2, 5)
	return ..()
