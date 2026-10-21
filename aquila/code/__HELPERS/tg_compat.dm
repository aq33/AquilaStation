// AQUILA - pomocnicze procedury z nowego tgstation, przepięte na nasze API (port heretyka).
// Czasy statusów: tg liczy w dziesiątych sekundy, a nasze stare zmienne (eye_blind, confused, jitteriness...)
// spadają o 1 na Life(), czyli mniej więcej co 2 sekundy.

/// Czas z tg (w dziesiątych sekundy) na liczbę tyknięć Life()
#define TG_TIME_TO_LIFE_TICKS(time) (CEILING((time) / 20, 1))

/// tg: dodaje wiele cech naraz
/datum/proc/add_traits(list/list_of_traits, source)
	if(!islist(list_of_traits))
		CRASH("Invalid arguments passed to add_traits! Invoked on [src] with [list_of_traits], source being [source].")
	for(var/trait in list_of_traits)
		ADD_TRAIT(src, trait, source)

/// tg: zdejmuje wiele cech naraz
/datum/proc/remove_traits(list/list_of_traits, source)
	if(!islist(list_of_traits))
		CRASH("Invalid arguments passed to remove_traits! Invoked on [src] with [list_of_traits], source being [source].")
	for(var/trait in list_of_traits)
		REMOVE_TRAIT(src, trait, source)

/// tg: rejestruje jedną procedurę na wiele sygnałów
/datum/proc/RegisterSignals(datum/target, list/signal_types, proctype, override = FALSE)
	for(var/signal_type in signal_types)
		RegisterSignal(target, signal_type, proctype, override)

/// tg: odświeża otwarte okna TGUI tego datumu
/datum/proc/update_data_for_all_viewers()
	SStgui.update_uis(src)

/// tg: nastrój (u nas przez sygnał do komponentu nastroju)
/mob/living/proc/add_mood_event(category, type, ...)
	if(!comp_lookup || !comp_lookup[COMSIG_ADD_MOOD_EVENT])
		return
	_SendSignal(COMSIG_ADD_MOOD_EVENT, list(src) + args)

/mob/living/proc/clear_mood_event(category)
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, category)

/// tg: komponent nastroju albo null
/mob/living/proc/get_mood()
	RETURN_TYPE(/datum/component/mood)
	return GetComponent(/datum/component/mood)

/// tg: zmienia poczytalność (u nas setSanity na komponencie nastroju)
/mob/living/proc/adjust_sanity(amount, minimum = SANITY_INSANE, maximum = SANITY_GREAT)
	var/datum/component/mood/mood = get_mood()
	if(!mood)
		return
	mood.setSanity(clamp(mood.sanity + amount, minimum, maximum))

/// tg: frakcje (u nas lista faction na mobie)
/mob/proc/add_faction(faction_or_factions)
	if(islist(faction_or_factions))
		faction |= faction_or_factions
	else
		faction |= list(faction_or_factions)

/mob/proc/remove_faction(faction_or_factions)
	if(islist(faction_or_factions))
		faction -= faction_or_factions
	else
		faction -= list(faction_or_factions)

/mob/proc/has_faction(faction_or_factions, match_all = FALSE)
	if(!islist(faction_or_factions))
		return (faction_or_factions in faction)
	for(var/one in faction_or_factions)
		if(one in faction)
			if(!match_all)
				return TRUE
		else if(match_all)
			return FALSE
	return match_all

/// tg: daje akcje z listy typów (albo typ => argument)
/mob/proc/grant_actions_by_list(list/input)
	var/list/output = list()
	for(var/action in input)
		var/datum/action/ability = new action(src)
		ability.Grant(src)
		output[action] = ability
	return output

// Obrażenia w nazewnictwie tg

/mob/living/proc/adjust_brute_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	return adjustBruteLoss(amount, updating_health, forced)

/mob/living/proc/adjust_fire_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	return adjustFireLoss(amount, updating_health, forced)

/mob/living/proc/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	return adjustToxLoss(amount, updating_health, forced)

/mob/living/proc/adjust_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	return adjustOxyLoss(amount, updating_health, forced)

/mob/living/proc/adjust_stamina_loss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	return adjustStaminaLoss(amount, updating_stamina, forced)

/mob/living/proc/adjust_organ_loss(slot, amount, maximum, required_organ_flag)
	return adjustOrganLoss(slot, amount, maximum)

/mob/living/proc/get_total_damage(precision)
	return getBruteLoss() + getFireLoss() + getToxLoss() + getOxyLoss() + getCloneLoss()

/// tg: części ciała (u nas zwykła lista bodyparts na carbonie)
/mob/living/proc/get_bodyparts(include_stumps = FALSE)
	return list()

/mob/living/carbon/get_bodyparts(include_stumps = FALSE)
	return bodyparts.Copy()

// Krew

/mob/living/proc/get_blood_volume(apply_modifiers = FALSE)
	return blood_volume

/mob/living/proc/set_blood_volume(amount, minimum = 0, maximum = BLOOD_VOLUME_MAXIMUM)
	blood_volume = clamp(amount, minimum, maximum)
	return blood_volume

/mob/living/proc/adjust_blood_volume(amount, minimum = 0, maximum = BLOOD_VOLUME_MAXIMUM)
	return set_blood_volume(blood_volume + amount, minimum, maximum)

// Ogień

/mob/living/proc/ignite_mob(silent)
	return IgniteMob()

/mob/living/proc/extinguish_mob()
	return ExtinguishMob()

// Statusy tg na naszych zmiennych (czas w dziesiątych sekundy jak w tg)

/mob/living/proc/adjust_confusion(amount)
	confused = max(confused + TG_TIME_TO_LIFE_TICKS(amount), 0)

/mob/living/proc/set_confusion_if_lower(amount)
	confused = max(confused, TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_dizzy(amount)
	dizziness = max(dizziness + TG_TIME_TO_LIFE_TICKS(amount), 0)

/mob/living/proc/set_dizzy_if_lower(amount)
	dizziness = max(dizziness, TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_jitter(amount)
	Jitter(TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/set_jitter_if_lower(amount)
	jitteriness = max(jitteriness, TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_eye_blur(amount)
	adjust_blurriness(TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/set_eye_blur_if_lower(amount)
	if(eye_blurry < TG_TIME_TO_LIFE_TICKS(amount))
		set_blurriness(TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_temp_blindness(amount)
	if(amount > 0)
		blind_eyes(TG_TIME_TO_LIFE_TICKS(amount))
	else
		adjust_blindness(TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/set_temp_blindness_if_lower(amount)
	if(eye_blind < TG_TIME_TO_LIFE_TICKS(amount))
		set_blindness(TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_stutter(amount)
	stuttering = max(stuttering + TG_TIME_TO_LIFE_TICKS(amount), 0)

/mob/living/proc/set_stutter_if_lower(amount)
	stuttering = max(stuttering, TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_slurring(amount)
	slurring = max(slurring + TG_TIME_TO_LIFE_TICKS(amount), 0)

/mob/living/proc/set_slurring_if_lower(amount)
	slurring = max(slurring, TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_silence(amount)
	return

/mob/living/carbon/adjust_silence(amount)
	silent = max(silent + TG_TIME_TO_LIFE_TICKS(amount), 0)

/mob/living/proc/set_silence_if_lower(amount)
	return

/mob/living/carbon/set_silence_if_lower(amount)
	silent = max(silent, TG_TIME_TO_LIFE_TICKS(amount))

/mob/living/proc/adjust_hallucinations(amount)
	hallucination = max(hallucination + TG_TIME_TO_LIFE_TICKS(amount), 0)

/mob/living/proc/set_hallucinations_if_lower(amount)
	hallucination = max(hallucination, TG_TIME_TO_LIFE_TICKS(amount))

/// tg: czy mob nic nie widzi
/mob/proc/is_blind()
	return eye_blind > 0 || HAS_TRAIT(src, TRAIT_BLIND)

// Różne

/// tg: losowanie z wagami
/proc/pick_weight(list/list_to_pick)
	return pickweight(list_to_pick)

/// tg: znacznik czasu rundy
/proc/round_timestamp(format = "hh:mm:ss")
	return gameTimestamp(format)

/// tg: zapis w logu wiedzy heretyka
/proc/log_heretic_knowledge(text)
	log_game("HERETIC: [text]")

#undef TG_TIME_TO_LIFE_TICKS

/// tg: zdejmowanie cechy z callbacku (TRAIT_CALLBACK_REMOVE)
/proc/___TraitRemove(datum/target, trait, source)
	if(istype(target))
		REMOVE_TRAIT(target, trait, source)
