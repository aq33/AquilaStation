// AQUILA: simplified port of BeeStation/BeeStation-Hornet code/datums/elements/venomous.dm (BeeStation/BeeStation-Hornet#14771, tg port).
// Bee hooks the on_hit_effect element through AddElementTrait(), which we do not have; here the venom goes in after a successful
// melee attack of a basic mob (COMSIG_HOSTILE_POST_ATTACKINGTARGET), like the poison of our old simple animals.
// Thick clothing stops the bite like in Bee (can_inject() is our try_inject()).
/**
 * Venomous element; which makes the attacks of the simplemob attached poison the enemy.
 */
/datum/element/venomous
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Path of the reagent added
	var/reagent_type
	///How much of the reagent added. if it's a list, it'll pick a range with the range being list(lower_value, upper_value)
	var/list/amount_added
	///Does the bite get through thick clothing
	var/penetrates_thick

/datum/element/venomous/Attach(datum/target, poison_type, amount_added, penetrates_thick = FALSE)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.reagent_type = poison_type
	src.amount_added = amount_added
	src.penetrates_thick = penetrates_thick
	RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_attacked_target))

/datum/element/venomous/Detach(datum/source)
	UnregisterSignal(source, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/datum/element/venomous/proc/on_attacked_target(mob/living/attacker, atom/target, result)
	SIGNAL_HANDLER
	if(!result || !isliving(target))
		return
	var/mob/living/victim = target
	if(victim.stat == DEAD || !victim.reagents)
		return
	if(!victim.can_inject(attacker, FALSE, attacker.zone_selected, penetrates_thick))
		return
	var/final_amount_added = amount_added
	if(islist(amount_added))
		final_amount_added = rand(amount_added[1], amount_added[2])
	victim.reagents.add_reagent(reagent_type, final_amount_added)

/**
 * # simple flying element!
 * (BeeStation/BeeStation-Hornet code/datums/elements/simple_flying.dm, BeeStation/BeeStation-Hornet#14771)
 * Makes animals fly while living and not while dead. We have no TRAIT_MOVE_FLYING handling, so it sets the FLYING movement type.
 */
/datum/element/simple_flying

/datum/element/simple_flying/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/valid_target = target
	on_stat_change(valid_target, valid_target.stat) //immediately try adding flight if they're conscious
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/datum/element/simple_flying/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOB_STATCHANGE)
	var/mob/living/living_target = target
	living_target.setMovetype(living_target.movement_type & ~FLYING)

///signal called by the stat of the target changing
/datum/element/simple_flying/proc/on_stat_change(mob/living/target, new_stat)
	SIGNAL_HANDLER

	if(new_stat == CONSCIOUS)
		target.setMovetype(target.movement_type | FLYING)
	else
		target.setMovetype(target.movement_type & ~FLYING)
