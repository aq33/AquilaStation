// Monofobia (tg) i klaustrofobia (tg sprzed /datum/component/fearful, wersja z Monkestation)

/datum/quirk/monophobia
	name = "Monofobia"
	desc = "Panicznie boisz się samotności i zawsze trzymasz się większych grup."
	icon = "user-friends"
	value = -2
	medical_record_text = "Pacjent panicznie boi się zostać sam."

/datum/quirk/monophobia/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(new /datum/brain_trauma/severe/monophobia(), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/monophobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/claustrophobia
	name = "Klaustrofobia"
	desc = "Panicznie boisz się ciasnych przestrzeni i pewnych wesołych postaci. Gdy trafisz do pojemnika, szafki albo maszyny, dopada cię atak paniki i brakuje ci tchu."
	icon = "box-open"
	value = -1
	mood_quirk = TRUE
	process = TRUE
	medical_record_text = "Pacjent boi się ciasnych pomieszczeń."

/datum/quirk/claustrophobia/remove()
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "claustrophobia")

/datum/quirk/claustrophobia/on_process(delta_time)
	if(quirk_holder.stat > SOFT_CRIT || HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return

	var/nick_spotted = FALSE
	for(var/mob/living/carbon/human/possible_claus in view(5, quirk_holder))
		if(evaluate_jolly_levels(possible_claus))
			nick_spotted = TRUE
			break

	if(!nick_spotted && isturf(quirk_holder.loc))
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "claustrophobia")
		return

	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "claustrophobia", /datum/mood_event/claustrophobia)
	quirk_holder.losebreath += 0.25 // co czwarty oddech nie wychodzi
	if(DT_PROB(25, delta_time))
		if(nick_spotted)
			to_chat(quirk_holder, "<span class='warning'>Święty Mikołaj tu jest! Muszę stąd uciekać!</span>")
		else
			to_chat(quirk_holder, "<span class='warning'>Czujesz się uwięziony! Muszę się wydostać... nie mogę oddychać...</span>")

/// Sprawdza, czy ktoś ma na sobie za dużo świątecznego nastroju
/datum/quirk/claustrophobia/proc/evaluate_jolly_levels(mob/living/carbon/human/possible_saint_nick)
	if(!istype(possible_saint_nick))
		return FALSE
	if(istype(possible_saint_nick.back, /obj/item/storage/backpack/santabag))
		return TRUE
	if(istype(possible_saint_nick.head, /obj/item/clothing/head/santa) || istype(possible_saint_nick.head, /obj/item/clothing/head/helmet/space/santahat))
		return TRUE
	if(istype(possible_saint_nick.wear_suit, /obj/item/clothing/suit/space/santa))
		return TRUE
	return FALSE

/datum/mood_event/claustrophobia
	description = "<span class='boldwarning'>Czemu czuję się jak w pułapce?! Wypuśćcie mnie!!!</span>\n"
	mood_change = -7
	timeout = 1 MINUTES
