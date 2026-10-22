// AQUILA - port z Monkestation2.0 (code/datums/mutations/speech.dm)

/datum/mutation/lisp
	name = "Lisp"
	desc = "Maketh the thubject thpeak with a lithp regardlethth of willingnethth."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='warning'>Coś tu nie gra... Ssseplenisz.</span>"
	text_lose_indication = "<span class='notice'>Znów potrafisz wymawiać spółgłoski.</span>"

/datum/mutation/lisp/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/lisp/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/lisp/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message, "s", "th")
		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/uwuspeak
	name = "Neko Speak"
	desc = "Makes the subject speak in horrific combinations of words."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Coś jest bardzo nie tak.</span>"
	text_lose_indication = "<span class='notice'>Już nie masz ochoty zwymiotować własnego języka.</span>"

/datum/mutation/uwuspeak/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/uwuspeak/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/uwuspeak/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(message && message[1] != "*")
		speech_args[SPEECH_MESSAGE] = monke_uwuify_text(message) || message

/datum/mutation/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>MASZ OCHOTĘ KRZYCZEĆ!</span>"
	text_lose_indication = "<span class='notice'>Masz ochotę być cicho.</span>"

/datum/mutation/loud/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/loud/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/loud/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message, ".", "!")
		message = replacetext(message, "?", "?!")
		message = replacetext(message, "!", "!!")
		speech_args[SPEECH_MESSAGE] = message
