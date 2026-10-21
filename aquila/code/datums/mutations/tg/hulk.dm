// AQUILA - port z tgstation (code/datums/mutations/hulk.dm): warianty hulka jako podtypy naszego /datum/mutation/hulk

/// Kolor skóry wariantu hulka (bez #), null = zielony z rdzenia
/datum/mutation/hulk/var/tg_bodypart_color

/datum/mutation/hulk/wizardly
	name = "Hulk (Magical)"
	species_allowed = list() // każdy gatunek, także szkielety i jaszczury
	health_req = 0
	instability = 0

/datum/mutation/hulk/wizardly/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	conflicts = typesof(/datum/mutation/hulk)

/datum/mutation/hulk/superhuman
	name = "Hulk (Super)"
	health_req = 0
	instability = 0
	// Walka do ostatniego tchu
	mutation_traits = list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA)

/datum/mutation/hulk/superhuman/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	conflicts = typesof(/datum/mutation/hulk)

/// Nie traci mocy przy ciężkich ranach
/datum/mutation/hulk/superhuman/on_life()
	return

/datum/mutation/hulk/ork
	name = "Ork"
	desc = "A variant of the hulk mutation that is also known to inhibit the subject's brain functions."
	text_gain_indication = "<span class='notice'>Czujesz się znacznie głupszy!</span>"
	tg_bodypart_color = "828163"

/datum/mutation/hulk/ork/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	conflicts = typesof(/datum/mutation/hulk)

/datum/mutation/hulk/ork/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		var/list/ork_words = tgmut_strings("ork", "ork")
		for(var/key in ork_words)
			var/value = ork_words[key]
			if(islist(value))
				value = pick(value)
			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")
		speech_args[SPEECH_MESSAGE] = trim(message)
	return ..()

// Podtypy hulka liczą się jako hulk dla wszystkich check_mutation(HULK) w rdzeniu (spust, kajdanki, kolor skóry...)
/datum/dna/check_mutation(mutation_type)
	if(mutation_type == HULK)
		for(var/datum/mutation/hulk/any_hulk in mutations)
			return any_hulk
	return ..()

// Kolor skóry wariantów hulka (rdzeń daje zawsze zielony)
/obj/item/bodypart/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	. = ..()
	if(dropping_limb || !mutation_color)
		return
	var/mob/living/carbon/limb_owner = source || owner
	if(!limb_owner?.dna)
		return
	var/datum/mutation/hulk/any_hulk = locate() in limb_owner.dna.mutations
	if(any_hulk?.tg_bodypart_color)
		mutation_color = any_hulk.tg_bodypart_color
		draw_color = mutation_color
