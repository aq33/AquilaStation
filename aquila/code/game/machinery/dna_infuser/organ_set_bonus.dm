// AQUILA - port z tgstation (code/datums/elements/organ_set_bonus.dm)
/**
 * Element zestawu organów: organy z tego samego zestawu, wszczepione jednej osobie, dają wspólny bonus.
 * Używany przez organy z DNA infusera.
 */
/datum/element/organ_set_bonus
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// typ efektu statusu nakładanego na właściciela
	var/datum/status_effect/organ_set_bonus/bonus_type

/datum/element/organ_set_bonus/Attach(datum/target, bonus_type)
	. = ..()
	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE
	src.bonus_type = bonus_type
	RegisterSignal(target, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

/datum/element/organ_set_bonus/Detach(obj/item/organ/target)
	UnregisterSignal(target, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	return ..()

/datum/element/organ_set_bonus/proc/on_implanted(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	var/datum/status_effect/organ_set_bonus/set_bonus = receiver.has_status_effect(bonus_type)
	if(!set_bonus)
		set_bonus = receiver.apply_status_effect(bonus_type)
	if(!set_bonus)
		return
	set_bonus.set_organs(set_bonus.organs + 1, target)

/datum/element/organ_set_bonus/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER
	var/datum/status_effect/organ_set_bonus/set_bonus = loser.has_status_effect(bonus_type)
	if(set_bonus)
		set_bonus.set_organs(set_bonus.organs - 1, target)

/datum/status_effect/organ_set_bonus
	id = "organ_set_bonus"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	/// ile organów zestawu ma właściciel
	var/organs = 0
	/// ile organów potrzeba do bonusu
	var/organs_needed = 0
	/// czy bonus jest aktywny
	var/bonus_active = FALSE
	var/bonus_activate_text = "<span class='notice'>DNA ??? przeniknęło cię do głębi! Nauczyłeś się zgłaszać błędy!</span>"
	var/bonus_deactivate_text = "<span class='notice'>Twoje DNA nie jest już w większości ???. Zgłosiłeś błąd, prawda?</span>"
	/// wymagany biotyp; dla MOB_ORGANIC sprawdzane jest też can_mutate()
	var/required_biotype = MOB_ORGANIC
	/// cechy nadawane po aktywacji bonusu
	var/list/bonus_traits = list()
	/// biotyp dodawany po aktywacji bonusu
	var/bonus_biotype
	/// czy biotyp faktycznie został dodany (do zdjęcia przy dezaktywacji)
	var/biotype_added = FALSE

/datum/status_effect/organ_set_bonus/proc/set_organs(new_value, obj/item/organ/organ)
	organs = new_value
	if(!organs)
		qdel(src)
		return
	if(organs >= organs_needed)
		if(!bonus_active)
			INVOKE_ASYNC(src, PROC_REF(enable_bonus), organ)
	else if(bonus_active)
		INVOKE_ASYNC(src, PROC_REF(disable_bonus), organ)

/datum/status_effect/organ_set_bonus/on_remove()
	if(bonus_active)
		disable_bonus()
	return ..()

/datum/status_effect/organ_set_bonus/proc/enable_bonus(obj/item/organ/inserted_organ)
	SHOULD_CALL_PARENT(TRUE)
	if(required_biotype)
		if(!(required_biotype in owner.mob_biotypes))
			return FALSE
		if(required_biotype == MOB_ORGANIC)
			var/mob/living/carbon/carbon_owner = owner
			if(!istype(carbon_owner) || !carbon_owner.can_mutate())
				return FALSE
	bonus_active = TRUE
	if(length(bonus_traits))
		owner.add_traits(bonus_traits, TRAIT_STATUS_EFFECT(id))
	if(bonus_biotype)
		add_bonus_biotype()
		RegisterSignal(owner, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))
	if(bonus_activate_text)
		to_chat(owner, bonus_activate_text)
	return TRUE

/datum/status_effect/organ_set_bonus/proc/disable_bonus(obj/item/organ/removed_organ)
	SHOULD_CALL_PARENT(TRUE)
	bonus_active = FALSE
	if(length(bonus_traits))
		owner.remove_traits(bonus_traits, TRAIT_STATUS_EFFECT(id))
	if(bonus_biotype)
		UnregisterSignal(owner, COMSIG_SPECIES_GAIN)
		if(biotype_added)
			owner.mob_biotypes = owner.mob_biotypes - bonus_biotype
			biotype_added = FALSE
	if(bonus_deactivate_text && !QDELETED(owner))
		to_chat(owner, bonus_deactivate_text)

/// u nas mob_biotypes to lista współdzielona z gatunkiem, więc zawsze tworzymy nową
/datum/status_effect/organ_set_bonus/proc/add_bonus_biotype()
	if(bonus_biotype in owner.mob_biotypes)
		biotype_added = FALSE
		return
	owner.mob_biotypes = owner.mob_biotypes + bonus_biotype
	biotype_added = TRUE

/// nowy gatunek nadpisuje biotypy - dodajemy nasz ponownie
/datum/status_effect/organ_set_bonus/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	add_bonus_biotype()
