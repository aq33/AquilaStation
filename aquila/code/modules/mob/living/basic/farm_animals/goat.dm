// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/farm_animals/goat/goat.dm and goat_ai.dm
// (BeeStation/BeeStation-Hornet#14771, tg port), decision D9 (udder component instead of the old /obj/item/udder of the simple animal goat).
// Polish lines from our simple animal goat. Changes against Bee:
// - the udder gives goat milk (Bee gave the default cow milk), a male goat has no udder (as in Bee) and is called "kozioł";
// - the plant eating proc can say "Nom", so the attack and move signal handlers call it asynchronously (Bee called it directly);
// - we have no MOB_PLANT biotype: the big chomp hits pod people, like our old goat; the alien flower bud is our flower_bud_enemy;
// - no Pete and no rabid Pete (not on our maps), no cliff climbing.

/// The Greatest (animal) Of All Time. Cud chewing, shin-kicking, kitchen-dwelling nuisance.
/mob/living/basic/goat
	name = "koza"
	desc = "Nie słynie z miłego usposobienia."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"

	speak_emote = list("ryczy")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK

	butcher_results = list(/obj/item/food/meat/slab = 4)

	faction = list(FACTION_NEUTRAL)
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)

	health = 40
	maxHealth = 40
	melee_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE
	see_in_dark = 6
	minimum_survivable_temperature = 180

	blood_volume = BLOOD_VOLUME_NORMAL
	chat_color = "#B2CEB3"
	do_footstep = TRUE

	ai_controller = /datum/ai_controller/basic_controller/goat

	/// How often will we develop an evil gleam in our eye?
	var/gleam_delay = 20 SECONDS
	/// Time until we can next gleam evilly
	COOLDOWN_DECLARE(gleam_cooldown)
	/// List of stuff (flora) that we want to eat
	var/static/list/edibles = list(
		/obj/structure/alien/resin/flower_bud_enemy,
		/obj/structure/glowshroom,
		/obj/structure/spacevine,
	)

/mob/living/basic/goat/Initialize(mapload)
	. = ..()
	if(gender == MALE && name == initial(name))
		name = "kozioł"
		real_name = name
	add_udder()
	AddElement(/datum/element/ai_retaliate)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attack))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move))

	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

/// Called when we attack something in order to piece together the intent of the AI/user and provide desired behavior.
/// Goats are really good at beating up plants by taking bites out of them, but we use the default attack for everything else
/mob/living/basic/goat/proc/on_pre_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(is_type_in_list(target, edibles))
		INVOKE_ASYNC(src, PROC_REF(eat_plant), list(target))
		return COMPONENT_HOSTILE_NO_ATTACK

	if(!ishuman(target))
		return
	var/mob/living/carbon/human/plant_man = target
	if(!istype(plant_man.dna?.species, /datum/species/pod))
		return

	INVOKE_ASYNC(src, PROC_REF(chomp_plant), plant_man)
	return COMPONENT_HOSTILE_NO_ATTACK

/// Takes a big bite out of a plant person: brute damage and a lost limb
/mob/living/basic/goat/proc/chomp_plant(mob/living/carbon/human/plant_man)
	plant_man.adjustBruteLoss(20)
	playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)
	var/obj/item/bodypart/edible_bodypart = length(plant_man.bodyparts) ? pick(plant_man.bodyparts) : null
	plant_man.visible_message(
		span_warning("[src] odgryza spory kęs [plant_man]!"),
		span_userdanger("[src] odgryza spory kęs twojej kończyny ([edible_bodypart])!"),
	)
	edible_bodypart?.dismember()

/// If we are being attacked by someone, give a nice fluff message. But only once in a while.
/mob/living/basic/goat/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER

	if (!COOLDOWN_FINISHED(src, gleam_cooldown) || stat == DEAD)
		return
	visible_message(span_danger("W oku [src] pojawia się złowrogi błysk."))
	COOLDOWN_START(src, gleam_cooldown, gleam_delay)

/// Handles automagically eating a plant when we move into a turf that has one.
/mob/living/basic/goat/proc/on_move(datum/source, atom/entering_loc)
	SIGNAL_HANDLER
	if(!isturf(entering_loc) || stat == DEAD)
		return

	var/list/edible_plants = list()
	for(var/obj/target in entering_loc)
		if(is_type_in_list(target, edibles))
			edible_plants += target

	if(length(edible_plants))
		INVOKE_ASYNC(src, PROC_REF(eat_plant), edible_plants)

/// When invoked, adds an udder when applicable. Male goats do not have udders.
/mob/living/basic/goat/proc/add_udder()
	if(gender == MALE)
		return
	AddComponent(/datum/component/udder, /obj/item/udder/goat)

/// Proc that handles dealing with the various types of plants we might eat. Assumes that a valid list of type(s) will be passed in.
/mob/living/basic/goat/proc/eat_plant(list/plants)
	var/eaten = FALSE

	for(var/atom/target as anything in plants)
		if(QDELETED(target))
			continue
		if(istype(target, /obj/structure/spacevine))
			var/obj/structure/spacevine/vine = target
			vine.eat(src)
			eaten = TRUE

		if(istype(target, /obj/structure/alien/resin/flower_bud_enemy))
			var/obj/structure/flower_bud = target
			flower_bud.take_damage(rand(30, 50), BRUTE)
			eaten = TRUE

		if(istype(target, /obj/structure/glowshroom))
			qdel(target)
			eaten = TRUE

	if(eaten && prob(10))
		say("Nom") // bon appetit
		playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)

/obj/item/udder/goat
	name = "wymię kozy"
	reagent_produced_typepath = /datum/reagent/consumable/milk/goat

/// Goats are normally content to sorta hang around and crunch any plant in sight, but they will go ape on someone who attacks them.
/datum/ai_controller/basic_controller/goat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/capricious_retaliate, // Capricious like Capra, get it?
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/goat,
	)

/datum/ai_planning_subtree/random_speech/goat
	speech_chance = 3
	speak = list("EHEHEHEHEH", "eh?")
	emote_hear = list("ryczy.")
	emote_see = list("potrząsa głową.", "tupie nogą.", "rozgląda się gniewnie.")
