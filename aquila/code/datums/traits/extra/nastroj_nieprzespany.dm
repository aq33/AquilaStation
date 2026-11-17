// Zarwana noc (tg All Nighter): stały zły nastrój i twardy sen. Sen ładuje „bank snu”, a środki pobudzające usuwają zły nastrój.
// Uproszczenie: zamiast nakładki z workami pod oczami (tg bodypart_overlay, u nas brak) widać je w opisie postaci.

#define AQ_SLEEP_BANK_MULTIPLIER 10

/datum/quirk/all_nighter
	name = "Zarwana Noc"
	desc = "Nie zmrużyłeś oka zeszłej nocy i wszyscy to widzą! Masz stale zły humor i śpisz dłużej. Pomogą środki pobudzające albo drzemka."
	icon = "moon"
	value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	mood_quirk = TRUE
	process = TRUE
	gain_text = "<span class='danger'>Czujesz się wykończony.</span>"
	lose_text = "<span class='notice'>Czujesz się wypoczęty.</span>"
	medical_record_text = "Pacjent wygląda na niewyspanego."
	/// „Bank snu”: sen go ładuje, czuwanie opróżnia
	var/five_more_minutes = 0
	/// Czy widać worki pod oczami
	var/eye_bags = TRUE

/datum/quirk/all_nighter/add()
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "all_nighter", /datum/mood_event/all_nighter)
	RegisterSignal(quirk_holder, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/quirk/all_nighter/remove()
	UnregisterSignal(quirk_holder, COMSIG_PARENT_EXAMINE)
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "all_nighter")

/datum/quirk/all_nighter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!eye_bags || !ishuman(quirk_holder))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!human_holder.get_bodypart(BODY_ZONE_HEAD) || (human_holder.wear_mask && (human_holder.wear_mask.flags_inv & HIDEFACE)) || (human_holder.head && (human_holder.head.flags_inv & HIDEFACE)))
		return
	examine_list += "<span class='warning'>Ma ciemne worki pod oczami.</span>"

/// Czy we krwi płynie coś pobudzającego (tg: TRAIT_STIMULATED z kawy, herbaty, napojów energetycznych, nikotyny i stymulantów)
/datum/quirk/all_nighter/proc/is_stimulated()
	if(!quirk_holder.reagents)
		return FALSE
	var/static/list/stimulants = typecacheof(list(
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/monkey_energy,
		/datum/reagent/drug/nicotine,
		/datum/reagent/drug/methamphetamine,
		/datum/reagent/drug/aranesp,
		/datum/reagent/medicine/ephedrine,
		/datum/reagent/medicine/modafinil,
	))
	for(var/datum/reagent/reagent as anything in quirk_holder.reagents.reagent_list)
		if(is_type_in_typecache(reagent, stimulants))
			return TRUE
	return FALSE

/datum/quirk/all_nighter/on_process(delta_time)
	var/happy_camper = TRUE
	var/beauty_sleep = TRUE
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	var/has_moodlet = mood?.get_event("all_nighter")

	if(quirk_holder.IsSleeping())
		five_more_minutes += AQ_SLEEP_BANK_MULTIPLIER * delta_time
	else if(five_more_minutes > 0)
		five_more_minutes = max(five_more_minutes - delta_time, 0)
	else
		beauty_sleep = FALSE // bez snu są worki pod oczami
		if(!is_stimulated())
			happy_camper = FALSE

	if(has_moodlet && happy_camper)
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "all_nighter")
	if(!has_moodlet && !happy_camper)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "all_nighter", /datum/mood_event/all_nighter)
		to_chat(quirk_holder, "<span class='danger'>Znowu czujesz zmęczenie.</span>")

	eye_bags = !beauty_sleep

/datum/mood_event/all_nighter
	description = "<span class='warning'>W ogóle nie spałem zeszłej nocy. Jestem wykończony.</span>\n"
	mood_change = -5

#undef AQ_SLEEP_BANK_MULTIPLIER
