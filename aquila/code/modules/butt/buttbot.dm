// Buttbot, ported from HippieStation13 (code/modules/hippie/mobs/simple/buttbot.dm).
// Build one by hitting a butt with a robotic arm.
// Od części BOTY to basic bot (aquila/code/modules/mob/living/basic/bots/): łazi losowo i powtarza zasłyszane zdania.

/mob/living/basic/bot/buttbot
	name = "tyłkobot"
	desc = "To robotyczny tyłek. Tępy jesteś czy co??"
	icon = 'aquila/icons/mob/buttbot.dmi'
	icon_state = "buttbot"
	maxHealth = 25
	health = 25
	model = "Tyłkobot"
	robot_arm = null
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT
	possessed_message = "Jesteś tyłkobotem. Nikt nie wie po co."
	/// Do we hiss when buttspeech?
	var/xeno = FALSE
	COOLDOWN_DECLARE(speech_cooldown)
	var/list/speech_buffer = list()
	var/list/speech_list = list("tyłek.", "tyłki.", "dupa.", "pierd.", "dupowybuch usa", "łiu, czas na inspekcję tyłka", "woop") //Hilarious.

/mob/living/basic/bot/buttbot/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/mob/living/basic/bot/buttbot/update_icon_state()
	. = ..()
	icon_state = xeno ? "buttbot_xeno" : "buttbot"

/mob/living/basic/bot/buttbot/proc/make_xeno()
	xeno = TRUE
	speech_list = list("syczące tyłki", "syk syk, skurczybyku", "niezłe trofeum, kujonie", "tyłek", "łiu, czas na inspekcję obcego")
	update_appearance()

/mob/living/basic/bot/buttbot/explode()
	visible_message(span_userdanger("[src] rozpada się na kawałki!"))
	var/turf/T = get_turf(src)
	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(T)
	if(xeno)
		new /obj/item/organ/butt/xeno(T)
	else
		new /obj/item/organ/butt(T)
	do_sparks(3, TRUE, src)

/mob/living/basic/bot/buttbot/Life(seconds, times_fired)
	. = ..()
	if(stat || client || !(bot_mode_flags & BOT_MODE_ON))
		return
	if(isturf(loc) && !ai_controller?.blackboard[BB_BOT_SUMMON_TARGET])
		var/anydir = pick(GLOB.cardinals)
		if(Process_Spacemove(anydir))
			Move(get_step(src, anydir), anydir)
	if(prob(10) && COOLDOWN_FINISHED(src, speech_cooldown))
		COOLDOWN_START(src, speech_cooldown, 20 SECONDS)
		if(xeno) //Hiss like a motherfucker
			playsound(loc, "hiss", 15, TRUE, 1)
		var/phrase
		if(prob(70) && length(speech_buffer))
			phrase = buttificate(pick(speech_buffer))
			if(prob(5))
				speech_buffer -= pick(speech_buffer) //so they're not magic wizard guru buttbots that hold arcane information collected during an entire round.
		speak(phrase || pick(speech_list))

/mob/living/basic/bot/buttbot/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	//Also dont imitate ourselves. Imitate other buttbots though heheh
	if(speaker != src && raw_message && prob(40))
		if(length(speech_buffer) >= 20)
			speech_buffer -= pick(speech_buffer)
		speech_buffer |= html_decode(raw_message)

/// Randomly replaces words with "butt". Returns null if nothing got buttified.
/proc/buttificate(phrase)
	var/list/words = splittext(phrase, " ")
	var/list/out = list()
	var/buttified = FALSE
	for(var/word in words)
		if(prob(20))
			word = "tyłek"
			buttified = TRUE
		out += word
	if(!buttified)
		return
	return jointext(out, " ")
