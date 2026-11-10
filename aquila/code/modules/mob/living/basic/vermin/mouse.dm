// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/vermin/mouse.dm and
// code/datums/ai/hunting_behavior/hunting_mouse.dm (bee/master 0adf0fe9ae), decision D7 of the basic mobs port:
// the mouse keeps our player-mouse system ("szczury", aquila/code/modules/mob/living/simple_animal/friendly/mouse.dm:
// cheese, migration, CtrlClick eating, ghost possession, mouse_report), the NSV13 disease vector and our corpse.
// From Bee it takes the AI only: running away from people, cheese, cables and the piano synthesizer.
// Not taken: taming by cheese and pet commands, the rat cap and cheese spawning new mice (our migration does that),
// the hamster wheel (we have none) and the hostile rat (decision D8, our regal rat army stays simple_animal).
/mob/living/basic/mouse
	name = "mysz"
	desc = "To paskudny, brzydki, zły i roznoszący choroby gryzoń."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	held_state = "mouse_gray"
	see_in_dark = 8 //AQ szczury 6->8
	maxHealth = 5
	health = 5
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES)
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)
	chat_color = "#82AF84"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	move_force = MOVE_FORCE_EXTREMELY_WEAK

	speak_emote = list("piszczy")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "rozpłaszcza"

	ai_controller = /datum/ai_controller/basic_controller/mouse

	/// What color our mouse is. Brown, gray and white - leave blank for random.
	var/body_color
	/// NSV13: diseases this mouse carries and passes on with its blood
	var/list/ratdisease = list()
	/// AQ szczury: ate a cheese wedge lately (AI mice)
	var/full = FALSE
	/// AQ szczury: busy eating something (player mice)
	var/eating = FALSE
	/// AQ szczury: ate cheese, bigger and faster for a while (player mice)
	var/cheesed = FALSE
	/// AQ szczury: when the cheese wears off
	var/cheese_time = 0

/mob/living/basic/mouse/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg'=1), 100)
	if(!body_color)
		body_color = pick("brown", "gray", "white")
	icon_state = "mouse_[body_color]"
	icon_living = "mouse_[body_color]"
	icon_dead = "mouse_[body_color]_dead"
	held_state = "mouse_[body_color]"
	if(prob(75))
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 6), 9, 1, infected = src)
		ratdisease += R
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/basic/mouse/Life(seconds, times_fired)
	. = ..()
	handle_stomach() // AQ szczury: the cheese wears off (the simple animal mouse never called this)

/mob/living/basic/mouse/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(!ratdisease.len)
		return FALSE
	if(scan)
		E.scan(src, ratdisease, user)
	else
		E.extrapolate(src, ratdisease, user)
	return TRUE

/// Kills the mouse and makes it look splatted. A player mouse only takes damage (AQ szczury).
/mob/living/basic/mouse/proc/splat()
	if(!key)
		icon_dead = "mouse_[body_color]_splat"
		adjust_health(maxHealth)
		return
	adjust_health(rand(7, 12))
	if(health <= 0)
		icon_dead = "mouse_[body_color]_splat"

/// Mice turn into a dead mouse you can pick up; player mice stay as a body
/mob/living/basic/mouse/death(gibbed, toast)
	var/list/data = list("donor" = type, "viruses" = ratdisease) // NSV13 - Add mouse donor field for tracking later
	GLOB.mouse_killed++ //AQ szczury
	if(ckey)
		return ..()
	// Parent with gibbed = TRUE, because we are getting rid of the body
	..(TRUE)
	if(!gibbed && isturf(loc))
		var/obj/item/food/deadmouse/corpse = new(loc)
		corpse.icon_state = icon_dead
		corpse.name = name
		corpse.reagents.add_reagent(/datum/reagent/blood, 2, data)
		if(toast)
			corpse.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
			corpse.desc = "Już po niej."
	qdel(src)

/// Signal proc for [COMSIG_ATOM_ENTERED]. Sends a lil' squeak to chat when someone walks over us.
/mob/living/basic/mouse/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(ishuman(entered) && stat == CONSCIOUS)
		to_chat(entered, span_notice("[icon2html(src, entered)] Pisk!"))

/// The AI bites cables and eats cheese by clicking them; player mice eat through CtrlClick (AQ szczury)
/mob/living/basic/mouse/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(client || !proximity_flag)
		return ..()
	if(istype(attack_target, /obj/item/food/cheese))
		eat_cheese(attack_target)
		return TRUE
	if(istype(attack_target, /obj/structure/cable))
		try_bite_cable(attack_target)
		return TRUE
	return ..()

/// Biting into a live cable fries the mouse (NSV13: never through catwalks, see the hunt below)
/mob/living/basic/mouse/proc/try_bite_cable(obj/structure/cable/cable)
	if(cable.avail() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		visible_message(span_warning("[src] przegryza [cable]. Po nim!"))
		playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
		cable.deconstruct()
		death(toast = TRUE)
		return
	cable.deconstruct()
	visible_message(span_warning("[src] przegryza [cable]."))

/mob/living/basic/mouse/white
	body_color = "white"
	icon_state = "mouse_white"
	held_state = "mouse_white"

/mob/living/basic/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/basic/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"
	held_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/basic/mouse/brown/tom
	name = "Tom"
	desc = "Kot Jerry nie jest rozbawiony."
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/mouse/brown/tom/Initialize(mapload)
	. = ..()
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "piszczy.")

/obj/item/food/deadmouse
	name = "martwa mysz"
	desc = "Wygląda, jakby ktoś spuścił na nią bas. Ulubiony posiłek jaszczurów. Może roznosić choroby."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray_dead"
	bite_consumption = 3
	eatverbs = list("pożera")
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GORE | MEAT | RAW
	grind_results = list(
		/datum/reagent/blood = 20,
		/datum/reagent/liquidgibs = 5
	)
	decomp_req_handle = TRUE
	decomp_type = /obj/item/food/deadmouse/moldy

/obj/item/food/deadmouse/moldy
	name = "spleśniała martwa mysz"
	desc = "Martwy gryzoń strawiony przez pleśń i zgniliznę. Istnieje niewielka szansa, że jaszczur wciąż by go zjadł."
	icon_state = "mouse_gray_dead"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/mold = 10
	)
	foodtypes = GORE | MEAT | RAW | GROSS
	grind_results = list(
		/datum/reagent/blood = 20,
		/datum/reagent/liquidgibs = 5,
		/datum/reagent/consumable/mold = 10
	)
	preserved_food = TRUE

/obj/item/food/deadmouse/attackby(obj/item/I, mob/living/user, params)
	if(I.is_sharp() && user.combat_mode)
		if(isturf(loc))
			new /obj/item/food/meat/slab/mouse(loc)
			to_chat(user, "<span class='notice'>Ćwiartujesz [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>Musisz położyć [src] na jakiejś powierzchni, by go oprawić!</span>")
	else
		return ..()

/obj/item/food/deadmouse/on_grind()
	reagents.clear_reagents()

/// The mouse AI controller
/datum/ai_controller/basic_controller/mouse
	blackboard = list( // Always cowardly
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic, // Use this to find people to run away from
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
		BB_SONG_LINES = MOUSE_SONG,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		// Try to speak, because it's cute
		/datum/ai_planning_subtree/random_speech/mouse,
		// Look for and execute hunts for cheese even if someone is looking at us
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		// Next priority is to try and appreoach a keyboard
		/datum/ai_planning_subtree/approach_synthesizer,
		// And play it if we are near it
		/datum/ai_planning_subtree/generic_play_instrument/end_planning,
		// Next priority is see if anyone is looking at us
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		// Skedaddle
		/datum/ai_planning_subtree/flee_target/mouse,
		// Otherwise, look for and execute hunts for cabling
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

/// Don't look for anything to run away from if you are distracted by being adjacent to cheese
/datum/ai_planning_subtree/flee_target/mouse

/datum/ai_planning_subtree/flee_target/mouse/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/hunted_cheese = controller.blackboard[BB_CURRENT_HUNTING_TARGET]
	if (!isnull(hunted_cheese))
		return // We see some cheese, which is more important than our life
	return ..()

/datum/ai_planning_subtree/random_speech/mouse
	speech_chance = 1
	speak = list("Pi!", "PIII!", "Pi?")
	sound = list('sound/effects/mousesqueek.ogg')
	emote_hear = list("piszczy.")
	emote_see = list("biega w kółko.", "trzęsie się.")

// Mouse subtree to hunt down delicious cheese.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_targets = list(/obj/item/food/cheese)
	hunt_range = 1

// Mouse subtree to hunt down ... delicious cabling?
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	finding_behavior = /datum/ai_behavior/find_hunt_target/mouse_cable
	hunt_targets = list(/obj/structure/cable)
	hunt_range = 0 // Only look below us
	hunt_chance = 1

// When looking for a cable, we can only bite things we can reach.
/datum/ai_behavior/find_hunt_target/mouse_cable

/datum/ai_behavior/find_hunt_target/mouse_cable/valid_dinner(mob/living/source, obj/structure/cable/dinner, radius)
	. = ..()
	if(!.)
		return

	var/turf/open/floor/below_the_cable = get_turf(dinner)
	if(!istype(below_the_cable))
		return FALSE
	// AQUILA: our floors have intact instead of underfloor_accessibility; NSV13 - no chewing through catwalks
	return !below_the_cable.intact && !(locate(/obj/structure/lattice/catwalk) in below_the_cable)

// Our hunts have a decent cooldown.
/datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_cooldown = 20 SECONDS

/datum/ai_planning_subtree/approach_synthesizer

/datum/ai_planning_subtree/approach_synthesizer/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	var/atom/instrument = controller.blackboard[BB_SONG_INSTRUMENT]
	if(!isnull(instrument))
		if (!isturf(instrument.loc) || !can_see(pawn, instrument))
			controller.clear_blackboard_key(BB_SONG_INSTRUMENT)
			return
		if (instrument.IsReachableBy(pawn))
			return
		controller.queue_behavior(/datum/ai_behavior/travel_towards/adjacent, BB_SONG_INSTRUMENT)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/piano_synth, BB_SONG_INSTRUMENT, /obj/item/instrument/piano_synth)

/datum/ai_behavior/find_and_set/piano_synth // Disinclude subtypes

/datum/ai_behavior/find_and_set/piano_synth/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	for(var/obj/item/instrument/piano_synth/synth in oview(search_range, controller.pawn))
		if(synth.type == /obj/item/instrument/piano_synth)
			return synth
