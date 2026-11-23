// AQUILA: port of tgstation code/modules/mob/living/basic/farm_animals/goose/ (goose.dm, goose_ai.dm, goose_vomit.dm) from the
// last revision before behaviour trees (tg 926bf40c5a), on the Bee AI core. Polish names and lines of our simple animal geese.
// Changes against tg:
// - meat stays /obj/item/food/meat/slab (NSV13 gave the goose meat; we have no grassfed meat);
// - our hiss at a new victim (the simple animal taunt) stays through aggro_emote;
// - Birdboat keeps our deadchat control: 50% of rounds, directions and "vomit" (plus tg's "honk" and "spin"), 2 s between
//   inputs; our deadchat_control has no cardinal_movement subtype, so the directions are plain inputs as before;
// - plastic is read from custom_materials (we have no has_material_type()), no TRAIT_NOT_BARFABLE (nothing here needs it);
// - the AI of Birdboat finds its vomit ability in BB_GENERIC_ACTION (tg granted it without a key, so use_mob_ability never fired),
//   and it throws up for 2.5 s plus the gross food bonus like our simple animal (tg counted seconds as deciseconds);
// - fixes our Birdboat, which only ate /obj/item/reagent_containers/food and so, after the newfood port, nothing:
//   geese eat any /obj/item that is food (the edible component) or plastic.

/// The most random things a goose can have inside of it
#define GOOSE_SATIATED 50

/// Blackboard key: chance to throw up after a step or when planning
#define BB_GOOSE_VOMIT_CHANCE "BB_goose_vomit_chance"
/// Blackboard key: the goose is choking or throwing up and should run around instead of eating
#define BB_GOOSE_PANICKED "BB_goose_panicked"

/// A mob that gets mad at people at random and tries to eat nearby objects
/mob/living/basic/goose
	name = "gęś"
	desc = "Gęś na wolności."
	icon_state = "goose" // sprites by cogwerks from goonstation, used with permission
	icon_living = "goose"
	icon_dead = "goose_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list(FACTION_NEUTRAL)
	maxHealth = 25
	health = 25
	speed = 1 // basic mobs skip the simple animal +1 movespeed config: 2 (run) + 1 = the old 3 ds per tile
	melee_damage = 5
	attack_verb_continuous = "dziobie"
	attack_sound = "goose"
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("trąbi")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	ai_controller = /datum/ai_controller/basic_controller/goose
	butcher_results = list(/obj/item/food/meat/slab = 2) //NSV13 made the goose drop meat
	gold_core_spawnable = HOSTILE_SPAWN
	/// Do we actually destroy food we eat?
	var/conserve_food = FALSE
	/// Unfortunately, geese want to eat every item
	var/static/list/item_typecache = typecacheof(/obj/item)

/mob/living/basic/goose/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/content_barfer)
	AddElement(/datum/element/basic_eating, add_to_contents = conserve_food, food_types = string_list(list(/obj/item)))
	AddComponent(/datum/component/aggro_emote, living_only = TRUE, emote_list = string_list(list("syczy")), emote_chance = 30, minimum_chance = 30, subtract_chance = 0)

	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_tried_gobbling))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(on_gobbled))

	ai_controller.set_blackboard_key(BB_BASIC_FOODS, item_typecache)

/mob/living/basic/goose/death(gibbed)
	if(!gibbed && length(contents))
		var/turf/drop_turf = drop_location()
		if(istype(drop_turf))
			playsound(drop_turf, 'sound/effects/splat.ogg', 50, TRUE)
			drop_turf.add_vomit_floor(src)
	return ..()

/// Is this item made of plastic? (tg: has_material_type())
/proc/goose_is_plastic(obj/item/thing)
	for(var/datum/material/material as anything in thing.custom_materials)
		if(istype(material, /datum/material/plastic) || ispath(material, /datum/material/plastic))
			return TRUE
	return FALSE

/**
 * AQUILA: can a goose eat this? Food or plastic, but never a brain or anything with someone inside: brains are edible here
 * (ORGAN_EDIBLE) and eating one deleted the brainmob, so a player was gone for good.
 */
/proc/goose_can_eat(obj/item/thing)
	if(istype(thing, /obj/item/organ/brain) || (locate(/mob) in thing))
		return FALSE
	return goose_is_plastic(thing) || IS_EDIBLE(thing)

/// Called when we try to eat something
/mob/living/basic/goose/proc/on_tried_gobbling(datum/source, obj/item/potential_food)
	SIGNAL_HANDLER
	if(ai_controller?.blackboard[BB_GOOSE_PANICKED])
		return COMSIG_MOB_CANCEL_EAT
	if(goose_can_eat(potential_food))
		return NONE // Geese only eat FOOD or PLASTIC
	return COMSIG_MOB_CANCEL_EAT

/// Called when we've eaten something
/mob/living/basic/goose/proc/on_gobbled(atom/source, obj/item/tasty, mob/feeder)
	SIGNAL_HANDLER
	if(!goose_is_plastic(tasty))
		return NONE
	visible_message(span_boldwarning("[src] dławi się [tasty]!"))
	tasty.forceMove(src)
	choke(tasty)
	return COMSIG_MOB_TERMINATE_EAT

/// Start choking on something we just ate
/mob/living/basic/goose/proc/choke(obj/item/not_food_after_all)
	apply_status_effect(/datum/status_effect/goose_choking)

/// A less grumpy but much grosser variant of the goose, who will decorate the halls in their own special way
/mob/living/basic/goose/vomit
	name = "Birdboat"
	real_name = "Birdboat"
	desc = "Gęś o chorym wyglądzie, pewnie zjadła za dużo śmieci z tuneli technicznych. Lepiej za bardzo jej nie ruszać."
	gender = MALE
	faction = list(FACTION_NEUTRAL, FACTION_MAINT_CREATURES)
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/goose/calm
	conserve_food = TRUE
	/// Cooldown to make sure we can't spam chat with notifications that we are full
	COOLDOWN_DECLARE(eat_fail_feedback_cooldown)
	/// An action we use to throw up
	var/datum/action/cooldown/mob_cooldown/goose_vomit/vomit_action

/mob/living/basic/goose/vomit/Initialize(mapload)
	. = ..()
	vomit_action = new(src)
	vomit_action.Grant(src)
	ai_controller?.set_blackboard_key(BB_GENERIC_ACTION, vomit_action) // AQUILA: tg never put it where use_mob_ability looks
	RegisterSignal(src, COMSIG_MOB_ABILITY_STARTED, PROC_REF(on_started_vomiting))
	if(!prob(50))
		return
	desc = "[initial(desc)] Kołysze się bardziej niż zwykle. Wygląda na opętaną."
	deadchat_plays_goose()

/mob/living/basic/goose/vomit/Destroy()
	. = ..()
	QDEL_NULL(vomit_action)

/mob/living/basic/goose/vomit/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	var/vomit_chance = ai_controller?.blackboard[BB_GOOSE_VOMIT_CHANCE] || 0
	if(prob(vomit_chance))
		vomit()

/mob/living/basic/goose/vomit/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Jakimś cudem wciąż wygląda na głodną.</span>"

/mob/living/basic/goose/vomit/on_gobbled(atom/source, obj/item/tasty, mob/feeder)
	if(length(contents) > GOOSE_SATIATED)
		if(COOLDOWN_FINISHED(src, eat_fail_feedback_cooldown))
			if(feeder)
				visible_message("<span class='notice'>[src] wygląda na zbyt najedzoną, by zjeść [tasty]!</span>")
			COOLDOWN_START(src, eat_fail_feedback_cooldown, 5 SECONDS)
		return COMSIG_MOB_TERMINATE_EAT

	. = ..()
	if(. == COMSIG_MOB_TERMINATE_EAT)
		return NONE // It's plastic, if it's not plastic we already filtered it for edible

	var/datum/component/edible/edible = tasty.GetComponent(/datum/component/edible)
	if(edible?.foodtypes & GROSS)
		ai_controller?.add_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 3)
		vomit_action?.extra_duration += 0.2 SECONDS
	else
		ai_controller?.add_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 1)

/mob/living/basic/goose/vomit/choke(obj/item/not_food_after_all)
	if(prob(75))
		return ..()
	visible_message(span_warning("[src] krztusi się [not_food_after_all]!"))
	manual_emote("krztusi się!")
	addtimer(CALLBACK(src, PROC_REF(vomit)), 5 SECONDS)

/// Start making a mess
/mob/living/basic/goose/vomit/proc/vomit()
	vomit_action?.Trigger(target = src)

/mob/living/basic/goose/vomit/proc/on_started_vomiting(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if(activated != vomit_action)
		return
	remove_status_effect(/datum/status_effect/goose_choking) // We're going to cough it out

/// Lets deadchat steer Birdboat (our inputs, plus tg's honk and spin)
/mob/living/basic/goose/vomit/proc/deadchat_plays_goose()
	ai_controller?.idle_behavior = null // Stop wandering, keep eating so you can lead the goose to the plastic
	ai_controller?.remove_from_unplanned_controllers() // AQUILA: the idle subsystem would call the idle behaviour we just removed
	AddComponent(/datum/component/deadchat_control, ANARCHY_MODE, list(
		"up" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, NORTH),
		"down" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, SOUTH),
		"left" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, WEST),
		"right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, EAST),
		"vomit" = CALLBACK(src, PROC_REF(vomit)),
		"honk" = CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), "HONK!!!"),
		"spin" = CALLBACK(src, TYPE_PROC_REF(/mob, emote), "spin")), 2 SECONDS)

/// A goose that lives in space (the Mining26 ruin); the map used var edits for this
/mob/living/basic/goose/space
	name = "kosmiczna gęś"
	desc = "Zwykła gęś, choć zdolna przetrwać w kosmosie. Prawdziwy kosmiczny szkodnik. Nie pozwól jej się wymknąć!"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	spacewalk = TRUE

/// Geese like to eat random objects and kill themselves, and occasionally get pissed off for no reason
/datum/ai_controller/basic_controller/goose
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SEARCH_RANGE = 1,
		BB_EAT_FOOD_COOLDOWN = 10 SECONDS,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/goose

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/random_speech/goose,
		/datum/ai_planning_subtree/capricious_retaliate,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food/goose,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Goose who doesn't randomly retaliate but does still try to die by eating random items
/datum/ai_controller/basic_controller/goose/calm
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SEARCH_RANGE = 1,
		BB_EAT_FOOD_COOLDOWN = 0.5 SECONDS, // Uh oh
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/goose,
		/datum/ai_planning_subtree/use_mob_ability/goose_vomit,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food/goose,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Walk more if we're choking or vomiting
/datum/idle_behavior/idle_random_walk/goose

/datum/idle_behavior/idle_random_walk/goose/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	walk_chance = controller.blackboard[BB_GOOSE_PANICKED] ? 100 : 25 // Shared by every goose, but set right before use
	return ..()

/// Only look for things geese will try to eat, right next to the goose
/datum/ai_planning_subtree/find_food/goose

/datum/ai_planning_subtree/find_food/goose/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_GOOSE_PANICKED])
		return // Don't look for food while choking or vomiting
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return // Busy with something
	if(world.time < controller.blackboard[BB_NEXT_FOOD_EAT])
		return
	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list/goose_food, BB_BASIC_MOB_CURRENT_TARGET, controller.blackboard[BB_BASIC_FOODS], controller.blackboard[BB_SEARCH_RANGE])

/// Only set things geese will try to eat
/datum/ai_behavior/find_and_set/in_list/goose_food

/datum/ai_behavior/find_and_set/in_list/goose_food/search_tactic(datum/ai_controller/controller, locate_paths, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	if(!length(found))
		return
	var/list/filtered = list()
	for(var/obj/item/thing as anything in found)
		if(goose_can_eat(thing))
			filtered += thing
	if(length(filtered))
		return pick(filtered)

/// Use this ability only if we roll a dice correctly
/datum/ai_planning_subtree/use_mob_ability/goose_vomit

/datum/ai_planning_subtree/use_mob_ability/goose_vomit/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/trigger_prob = controller.blackboard[BB_GOOSE_VOMIT_CHANCE] || 0
	if(prob(trigger_prob))
		return ..()

/datum/ai_planning_subtree/random_speech/goose
	speech_chance = 3
	emote_hear = list("trąbi.", "trąbi głośno.", "trąbi agresywnie.")
	emote_see = list("trzepocze skrzydłami.", "czyści pióra.", "rozgląda się groźnie.")
	speak = list("Gęę!")

/// Repeatedly throw up until there's nothing left inside
/datum/action/cooldown/mob_cooldown/goose_vomit
	name = "Zwymiotuj"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	button_icon_state = "vomit"
	icon_icon = 'icons/mob/animal.dmi'
	cooldown_time = INFINITY // We reset the cooldown when we are done throwing up
	text_cooldown = FALSE
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE
	/// Extra time to spend chundering
	var/extra_duration = 0 SECONDS

/datum/action/cooldown/mob_cooldown/goose_vomit/Grant(mob/granted_to)
	. = ..()
	if(!owner)
		return
	RegisterSignals(owner, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/goose_vomit/Remove(mob/removed_from)
	UnregisterSignal(owner, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	return ..()

/datum/action/cooldown/mob_cooldown/goose_vomit/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!length(owner.contents))
		if(feedback)
			owner.balloon_alert(owner, "pusty żołądek!")
		return FALSE
	if(!isliving(owner))
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/goose_vomit/Activate(atom/target)
	StartCooldown(INFINITY)
	if(istype(owner, /mob/living/basic/goose))
		owner.icon_state = "vomit"
		flick("vomit_start", owner)
		owner.ai_controller?.set_blackboard_key(BB_GOOSE_VOMIT_CHANCE, 0)
		addtimer(CALLBACK(src, PROC_REF(start_vomiting)), 13) // 13 frame long animation
	else
		start_vomiting()
	return TRUE

/// Start the performance
/datum/action/cooldown/mob_cooldown/goose_vomit/proc/start_vomiting()
	var/mob/living/living_owner = owner
	if(QDELETED(living_owner))
		return
	living_owner.apply_status_effect(/datum/status_effect/goose_vomit, extra_duration)
	extra_duration = 0

/// Handles iteratively emptying our stomach
/datum/status_effect/goose_vomit
	id = "goose_vomit"
	alert_type = null
	tick_interval = 1 SECONDS
	/// How long do we vomit for?
	var/vomit_duration = 2.5 SECONDS
	/// How long have we spent vomiting?
	var/elapsed_time = 0 SECONDS
	/// Chance to step in a random direction
	var/move_chance = 80
	/// Chance to produce an item per tick
	var/vomit_item_chance = 50
	/// Getting the rest out, one item every fast process
	var/finale = FALSE

/datum/status_effect/goose_vomit/on_creation(mob/living/new_owner, extra_duration = 0)
	vomit_duration += extra_duration
	return ..()

/datum/status_effect/goose_vomit/on_apply()
	owner.set_jitter_if_lower(vomit_duration)
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, TRUE)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_died))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	return TRUE

/datum/status_effect/goose_vomit/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED))
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, FALSE)
	if(istype(owner, /mob/living/basic/goose) && owner.stat != DEAD)
		var/mob/living/basic/goose_mob = owner
		flick("vomit_end", owner)
		goose_mob.icon_state = goose_mob.icon_living
	var/datum/action/cooldown/mob_cooldown/goose_vomit/vomit_action = locate() in owner.actions
	vomit_action?.StartCooldown(0 SECONDS)

/// Don't keep vomiting from beyond the grave
/datum/status_effect/goose_vomit/proc/on_owner_died()
	SIGNAL_HANDLER
	qdel(src)

/// For good measure we'll spit up every time we take a step too
/datum/status_effect/goose_vomit/proc/on_owner_moved()
	SIGNAL_HANDLER
	vomit_iteratively(can_move = FALSE)

/datum/status_effect/goose_vomit/tick(seconds_between_ticks)
	elapsed_time += seconds_between_ticks * 1 SECONDS // AQUILA: tg added seconds to deciseconds, so it threw up ten times longer
	if(!length(owner.contents))
		qdel(src)
		return
	if(elapsed_time <= vomit_duration)
		vomit_iteratively()
	else
		vomit_finale()

/// AQUILA: our status effects tick at a fixed interval, so the finale (tg: every 0.2 s) throws up on every fast process
/datum/status_effect/goose_vomit/process()
	if(!finale)
		return ..()
	if(!owner || !length(owner.contents))
		qdel(src)
		return
	hurl_item(vomit_strongly = TRUE)

/// One to come up
/datum/status_effect/goose_vomit/proc/vomit_iteratively(can_move = TRUE)
	if(prob(vomit_item_chance))
		hurl_item()
	else
		make_mess(owner.drop_location())

	if(can_move && prob(move_chance))
		var/move_dir = pick(GLOB.alldirs)
		var/turf/destination_turf = get_step(owner, move_dir)
		owner.Move(destination_turf, move_dir)

/// Stop fooling around and get the rest of it out
/datum/status_effect/goose_vomit/proc/vomit_finale()
	finale = TRUE
	owner.set_jitter_if_lower(1 SECONDS)
	hurl_item(vomit_strongly = TRUE)

/// Produce an item from our inventory
/datum/status_effect/goose_vomit/proc/hurl_item(vomit_strongly = FALSE)
	if(!length(owner.contents))
		return
	var/obj/item/thing = pick_n_take(owner.contents)
	if(!ismovable(thing))
		qdel(src) // Someone is messing around with this goose, let's not get stuck in this forever
		return
	var/drop_location = owner.drop_location()

	thing.forceMove(drop_location)
	if(isopenturf(drop_location))
		make_mess(drop_location)
		var/destination = get_edge_target_turf(drop_location, pick(GLOB.alldirs))
		var/throw_range = vomit_strongly ? rand(2, 8) : 1
		thing.safe_throw_at(destination, throw_range, 2)

/// Make a mess
/datum/status_effect/goose_vomit/proc/make_mess(turf/open/drop_turf)
	if(!istype(drop_turf))
		return
	playsound(drop_turf, 'sound/effects/splat.ogg', 50, TRUE)
	drop_turf.add_vomit_floor(owner)

/// Wheeze until we die
/datum/status_effect/goose_choking
	id = "goose_choking"
	alert_type = null
	duration = 30 SECONDS
	tick_interval = 2 SECONDS
	/// Chance per second to emote
	var/emote_prob = 18
	/// What things do we do while dying
	var/static/list/emotes = list("dławi się.", "kaszle.", "łapie powietrze.", "rozpaczliwie próbuje złapać oddech.", "gwałtownie się wzdryga.", "rzęzi.")

/datum/status_effect/goose_choking/tick(seconds_between_ticks)
	if(DT_PROB(emote_prob, seconds_between_ticks))
		owner.manual_emote(pick(emotes))

/datum/status_effect/goose_choking/on_apply()
	owner.set_jitter_if_lower(duration)
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, TRUE)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_died))
	return TRUE

/datum/status_effect/goose_choking/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	owner.ai_controller?.set_blackboard_key(BB_GOOSE_PANICKED, FALSE)
	if(owner.stat == DEAD || duration >= world.time) // our duration is the end time (tg counts it down)
		return // Saved by something, although probably by dying early
	var/mob/living/basic/goose_mob = owner
	if(istype(goose_mob))
		goose_mob.death_message = "wydaje ostatnie, zduszone gęgnięcie i bezwładnie opada..."
	owner.death()

/// Don't keep dying if we died
/datum/status_effect/goose_choking/proc/on_owner_died()
	SIGNAL_HANDLER
	qdel(src)

#undef GOOSE_SATIATED
