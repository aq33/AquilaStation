// Monofobia (tg) oraz lęk przed ogniem i ciasnymi miejscami jako rodzaje Fobii z mastera

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

// ---------------------------------------------------------------------------
// Ogień i ciasne miejsca jako dwa rodzaje istniejącej Fobii (dawniej osobne cechy Pirofobia z tg i Klaustrofobia z Monke).
// Fobia z mastera szuka w polu widzenia typów z list SStraumas, a te dwa lęki potrzebują własnego warunku:
// płomień w zasięgu wzroku albo siedzenie w szafce, skrzyni lub maszynie.

#define AQ_PHOBIA_FIRE "fire"
#define AQ_PHOBIA_CONFINED "confined spaces"

/datum/controller/subsystem/traumas/Initialize()
	. = ..()
	phobia_types[AQ_PHOBIA_FIRE] = 5
	phobia_types[AQ_PHOBIA_CONFINED] = 5
	phobia_words[AQ_PHOBIA_FIRE] = list("ogień", "ognia", "pożar", "płomie", "pali się", "płonie")
	phobia_words[AQ_PHOBIA_CONFINED] = list("szafk", "schowek", "ciasno", "zamknię", "skrzyni")

/datum/brain_trauma/mild/phobia
	/// Kiedy znów sprawdzić ogień albo ciasne miejsce (jak sprawdzanie widoku w on_life, co 5 s)
	var/aq_next_special_check = 0

/datum/brain_trauma/mild/phobia/on_life()
	if((phobia_type == AQ_PHOBIA_FIRE || phobia_type == AQ_PHOBIA_CONFINED) && world.time > aq_next_special_check && owner.stat < UNCONSCIOUS && !HAS_TRAIT(owner, TRAIT_FEARLESS))
		aq_next_special_check = world.time + 5 SECONDS
		// Rzecz w freak_out() straszy tylko o 1 punkt, który on_life() zaraz zdejmuje. Zamknięcie i ogień straszą jak żywa
		// istota (+4), więc dokładamy różnicę przed wywołaniem.
		var/atom/scare
		if(phobia_type == AQ_PHOBIA_CONFINED)
			if(!isturf(owner.loc))
				scare = owner.loc
		else if(owner.on_fire)
			scare = owner
		else if(!is_blind(owner))
			var/list/fires = aq_nearby_fire_sources(owner, 7)
			if(length(fires))
				scare = fires[1]
		if(scare)
			if(!isliving(scare))
				fearscore += 3
			freak_out(scare)
	return ..()
