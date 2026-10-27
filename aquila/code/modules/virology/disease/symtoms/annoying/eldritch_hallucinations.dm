/datum/symptom/acute/wendigo_hallucination
	name = "Eldritch Mind Syndrome"
	desc = "UNKNOWN"
	badness = EFFECT_DANGER_ANNOYING
	severity = 2
	stage = 3


/datum/symptom/acute/wendigo_hallucination/first_activate(mob/living/carbon/mob)
	RegisterSignal(mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/acute/wendigo_hallucination/deactivate(mob/living/carbon/mob, datum/disease/acute/disease, safe = FALSE)
	UnregisterSignal(mob, COMSIG_MOB_SAY)

/datum/symptom/acute/wendigo_hallucination/activate(mob/living/carbon/mob)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	H.Jitter(10 SECONDS)

	//creepy sounds copypasted from hallucination code
	var/list/possible_sounds = list(
		'aquila/sound/virology/ghost.ogg', 'aquila/sound/virology/ghost2.ogg', 'aquila/sound/virology/heart_beat_single.ogg', 'aquila/sound/virology/ear_ring_single.ogg', 'aquila/sound/virology/screech.ogg',\
		'aquila/sound/virology/behind_you1.ogg', 'aquila/sound/virology/behind_you2.ogg', 'aquila/sound/virology/far_noise.ogg', 'aquila/sound/virology/growl1.ogg', 'aquila/sound/virology/growl2.ogg',\
		'aquila/sound/virology/growl3.ogg', 'aquila/sound/virology/im_here1.ogg', 'aquila/sound/virology/im_here2.ogg', 'aquila/sound/virology/i_see_you1.ogg', 'aquila/sound/virology/i_see_you2.ogg',\
		'aquila/sound/virology/look_up1.ogg', 'aquila/sound/virology/look_up2.ogg', 'aquila/sound/virology/over_here1.ogg', 'aquila/sound/virology/over_here2.ogg', 'aquila/sound/virology/over_here3.ogg',\
		'aquila/sound/virology/turn_around1.ogg', 'aquila/sound/virology/turn_around2.ogg', 'aquila/sound/virology/veryfar_noise.ogg', 'aquila/sound/virology/wail.ogg')
	mob.playsound_local(mob.loc, pick(possible_sounds))



/datum/symptom/acute/wendigo_hallucination/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	message = replacetext(message,"I","we")
	message = replacetext(message,"me","us")
	speech_args[SPEECH_MESSAGE] = message
