// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/elements/basic_eating.dm (bee/master 0adf0fe9ae)
/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Amount to heal
	var/heal_amt
	/// Amount to hurt
	var/damage_amount
	/// Type of hurt to apply
	var/damage_type
	/// Whether to flavor it as drinking rather than eating.
	var/drinking
	/// If true, we put food in our tummy instead of deleting it
	var/add_to_contents
	/// Types the animal can eat.
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, heal_amt = 0, damage_amount = 0, damage_type = null, drinking = FALSE, add_to_contents = FALSE, food_types = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_MOB_EATER, REF(src))
	src.heal_amt = heal_amt
	src.damage_amount = damage_amount
	src.damage_type = damage_type
	src.drinking = drinking
	src.add_to_contents = add_to_contents
	src.food_types = food_types

	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(try_feed))
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))

/datum/element/basic_eating/Detach(datum/target)
	REMOVE_TRAIT(target, TRAIT_MOB_EATER, REF(src))

	UnregisterSignal(target, list(
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_PARENT_ATTACKBY,
	))
	return ..()

/// AQUILA: we have no item_interaction() chain (decision D5), feeding goes through attackby
/datum/element/basic_eating/proc/try_feed(atom/source, obj/item/possible_food, mob/living/user, params)
	SIGNAL_HANDLER
	if(user.combat_mode || !is_type_in_list(possible_food, food_types))
		return NONE
	var/mob/living/living_source = source
	if(living_source.stat != CONSCIOUS)
		return NONE
	return try_eating(source, possible_food, user) ? COMPONENT_NO_AFTERATTACK : NONE

/datum/element/basic_eating/proc/on_unarm_attack(mob/living/eater, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE

	if(try_eating(eater, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/basic_eating/proc/try_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(!is_type_in_list(target, food_types))
		return FALSE
	var/list/effect_mult = list()
	if(SEND_SIGNAL(eater, COMSIG_MOB_PRE_EAT, target, feeder, effect_mult) & COMSIG_MOB_CANCEL_EAT)
		return FALSE
	if(add_to_contents && !ismovable(target))
		return FALSE
	// AQUILA: Polish verbs, third person for everyone and second person for the eater
	var/static/list/drink_verbs = list("siorbie" = "siorbiesz", "popija" = "popijasz", "chłepcze" = "chłepczesz", "pije" = "pijesz", "żłopie" = "żłopiesz", "wysysa" = "wysysasz")
	var/static/list/eat_verbs = list("gryzie" = "gryziesz", "przeżuwa" = "przeżuwasz", "skubie" = "skubiesz", "obgryza" = "obgryzasz", "pożera" = "pożerasz", "chrupie" = "chrupiesz")
	var/eat_verb = pick(drinking ? drink_verbs : eat_verbs)
	var/eat_verb_self = drinking ? drink_verbs[eat_verb] : eat_verbs[eat_verb]

	var/best_match = null
	var/best_value = 0
	for (var/food_path in food_types)
		// Not an assoc list
		if (isnull(food_types[food_path]))
			break
		if (istype(target, food_path) && (!best_match || ispath(food_path, best_match)))
			best_match = food_path
			best_value = food_types[food_path]

	var/to_heal = heal_amt
	var/to_damage = damage_amount

	if (best_match)
		to_heal = 0
		to_damage = 0
		if (best_value > 0)
			to_heal = best_value
		else if (best_value < 0)
			to_damage = -best_value

		for (var/mult in effect_mult)
			to_heal *= mult
			to_damage *= mult

	if (to_heal > 0)
		var/health_before = eater.health
		eater.heal_overall_damage(to_heal, to_heal)
		var/healed = eater.health > health_before
		eater.visible_message(span_notice("[eater] [eat_verb] [target]."), span_notice("[capitalize(eat_verb_self)] [target][healed ? " i odzyskujesz trochę zdrowia" : ""]."))
	else if (to_damage > 0 && damage_type)
		var/damaged = eater.apply_damage(to_damage, damage_type)
		eater.visible_message(span_notice("[eater] [eat_verb] [target][damaged ? " i chyba robi sobie krzywdę!" : "."]"), span_notice("[capitalize(eat_verb_self)] [target][damaged ? " i robisz sobie krzywdę" : ""]."))
	else
		eater.visible_message(span_notice("[eater] [eat_verb] [target]."), span_notice("[capitalize(eat_verb_self)] [target]."))

	finish_eating(eater, target, feeder, to_heal)
	return TRUE

/datum/element/basic_eating/proc/finish_eating(mob/living/eater, atom/target, mob/living/feeder, to_heal)
	set waitfor = FALSE
	if(drinking)
		playsound(eater.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	else
		playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	var/atom/final_target = target
	if(SEND_SIGNAL(eater, COMSIG_MOB_ATE, final_target, feeder) & COMSIG_MOB_TERMINATE_EAT)
		return
	if(isstack(target)) //if stack, only consume 1
		var/obj/item/stack/food_stack = target
		final_target = food_stack.change_stack(null, 1) // AQUILA: our stacks split with change_stack()

	var/devour = add_to_contents && !to_heal
	eater.log_message("has eaten [target], [devour ? "swallowing it" : "destroying it"]!", LOG_ATTACK)

	if (devour)
		var/atom/movable/movable_target = final_target
		movable_target.forceMove(eater)
	else
		qdel(final_target)
