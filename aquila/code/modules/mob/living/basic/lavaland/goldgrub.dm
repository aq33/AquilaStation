// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/goldgrub/ (tg 926bf40c5a) in place of our simple animal
// goldgrub (/mob/living/simple_animal/hostile/asteroid/goldgrub), in its smallest form: it eats ore it sees (basic_eating
// into its stomach), runs from everyone outside the mining faction and spits the ore out when it dies. Polish lines,
// sprites, health and our bullet immunity. Not ported from tg: burrowing as an ability (our goldgrub still burrows away
// for good after 10 s of being chased, as before), boulders and ore vents (we have neither), eggs and babies, taming with
// ore and pet commands (the primal lasso can still tame it), the weather alarm, emissives.

//An ore-devouring but easily scared creature
/mob/living/basic/mining/goldgrub
	name = "złoty pędrak"
	desc = "Robak, który tyje, pożerając wszystko, co zobaczy. Najwyraźniej uwielbia metale szlachetne i inne błyszczące rzeczy, stąd nazwa."
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	speed = 5
	maxHealth = 45
	health = 45
	melee_damage = 0
	friendly_verb_continuous = "niegroźnie wtacza się na"
	attack_verb_continuous = "taranuje"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = FALSE
	speak_emote = list("skrzeczy")
	throw_blocked_message = "powoli się zagłębia, po czym zostaje wypchnięty z "
	death_message = "wypluwa zawartość żołądka i zdycha!"
	status_flags = CANPUSH
	ai_controller = /datum/ai_controller/basic_controller/goldgrub
	/// How long it lets itself be chased before it burrows away
	var/chase_time = 10 SECONDS
	/// Does it burrow away when chased?
	var/will_burrow = TRUE
	/// How much ore fits in its stomach
	var/max_ore = 10

/mob/living/basic/mining/goldgrub/Initialize(mapload)
	. = ..()
	generate_loot()
	// AQUILA: no healing values (tg heals with rarer ores, but basic_eating destroys food that heals instead of keeping it),
	// so every ore stays in the stomach as loot
	var/static/list/food_types = list(/obj/item/stack/ore)
	AddElement(/datum/element/basic_eating, food_types = food_types, add_to_contents = TRUE)
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "Goldgrub_alert", target_key = BB_BASIC_MOB_FLEE_TARGET)
	var/static/list/wanted_ores
	if(!wanted_ores)
		wanted_ores = typecacheof(list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver, /obj/item/stack/ore/uranium, /obj/item/stack/ore/bluespace_crystal, /obj/item/stack/ore/bananium, /obj/item/stack/ore/plasma, /obj/item/stack/ore/titanium))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, wanted_ores)
	RegisterSignal(src, COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_FLEE_TARGET), PROC_REF(on_chased))
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_pre_eat))

/// Fills the stomach with 1-3 random precious ores
/mob/living/basic/mining/goldgrub/proc/generate_loot()
	var/loot_amount = rand(1, 3)
	for(var/i in 1 to loot_amount)
		var/picked_loot = pick(/obj/item/stack/ore/silver, /obj/item/stack/ore/gold, /obj/item/stack/ore/uranium, /obj/item/stack/ore/diamond)
		new picked_loot(src)

/// No more room in the stomach
/mob/living/basic/mining/goldgrub/proc/on_pre_eat(datum/source, atom/food, mob/feeder, list/effect_mult)
	SIGNAL_HANDLER
	var/held = 0
	for(var/obj/item/stack/ore/ore in src)
		held += ore.amount
	if(held >= max_ore)
		return COMSIG_MOB_CANCEL_EAT

/// Someone is after us: burrow away if they keep at it
/mob/living/basic/mining/goldgrub/proc/on_chased(datum/source)
	SIGNAL_HANDLER
	if(!will_burrow || stat == DEAD)
		return
	visible_message(span_danger("[name] próbuje uciec przed [ai_controller.blackboard[BB_BASIC_MOB_FLEE_TARGET]]!"))
	addtimer(CALLBACK(src, PROC_REF(burrow)), chase_time, TIMER_UNIQUE)

/// Begin the chase to kill the goldgrub in time
/mob/living/basic/mining/goldgrub/proc/burrow()
	if(stat != CONSCIOUS || client || !ai_controller?.blackboard_key_exists(BB_BASIC_MOB_FLEE_TARGET))
		return
	visible_message(span_danger("[name] zakopuje się w ziemi i znika z oczu!"))
	qdel(src)

/mob/living/basic/mining/goldgrub/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	visible_message(span_danger("[P.name] odbija się od tłustego cielska [name]!"))
	return BULLET_ACT_BLOCK

/mob/living/basic/mining/goldgrub/death(gibbed)
	barf_contents(gibbed)
	return ..()

/// Spit out the swallowed ore
/mob/living/basic/mining/goldgrub/proc/barf_contents(gibbed)
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	for(var/obj/item/stack/ore/ore in src)
		ore.forceMove(drop_location())

/datum/ai_controller/basic_controller/goldgrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/simple_find_target/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
