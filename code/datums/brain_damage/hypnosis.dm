/datum/brain_trauma/hypnosis
	name = "Hipnoza"
	desc = "Podświadomość pacjenta jest całkowicie zniewolona przez słowo lub zdanie, na którym skupia on myśli i działania."
	scan_desc = "zapętlony wzorzec myślowy"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY

	var/hypnotic_phrase = ""
	var/regex/target_phrase

/datum/brain_trauma/hypnosis/New(phrase)
	if(!phrase)
		qdel(src)
	hypnotic_phrase = phrase
	try
		target_phrase = new("(\\b[hypnotic_phrase]\\b)","ig")
	catch(var/exception/e)
		stack_trace("[e] on [e.file]:[e.line]")
		qdel(src)
	..()

/datum/brain_trauma/hypnosis/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] zostaje zahipnotyzowany frazą '[hypnotic_phrase]'.")
	owner.log_message("was hypnotized with the phrase '[hypnotic_phrase]'.", LOG_ATTACK, color="#960000")
	log_game("[key_name(owner)] was hypnotized with the phrase '[hypnotic_phrase]'.")
	to_chat(owner, "<span class='reallybig hypnophrase'>[hypnotic_phrase]</span>")
	to_chat(owner, "<span class='notice'>[pick("Czujesz, jak twoje myśli skupiają się na tym zdaniu... nie możesz wyrzucić go z głowy.",\
												"Boli cię głowa, ale tylko o tym potrafisz myśleć. To musi być niezwykle ważne.",\
												"Część twojego umysłu powtarza to w kółko. Musisz wykonać te słowa.",\
												"Z jakiegoś powodu to brzmi... słusznie. Czujesz, że powinieneś wykonać te słowa.",\
												"Te słowa wciąż odbijają się echem w twoim umyśle. Całkowicie cię fascynują.")]</span>")
	to_chat(owner, "<span class='boldwarning'>Zahipnotyzowało cię to zdanie. Musisz wykonywać te słowa. Jeśli nie jest to jasny rozkaz, możesz dowolnie interpretować, jak go wykonać, o ile zachowujesz się tak, jakby te słowa były twoim najwyższym priorytetem.</span>")
	var/atom/movable/screen/alert/hypnosis/hypno_alert = owner.throw_alert("hypnosis", /atom/movable/screen/alert/hypnosis)
	hypno_alert.desc = "„[hypnotic_phrase]”... twój umysł obsesyjnie krąży wokół tej myśli."
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	traitorhud.join_hud(owner.mind.current)
	if(!owner.mind.antag_hud_icon_state)
		set_antag_hud(owner.mind.current, "brainwash")
	..()

/datum/brain_trauma/hypnosis/on_lose()
	message_admins("[ADMIN_LOOKUPFLW(owner)] nie jest już zahipnotyzowany frazą '[hypnotic_phrase]'.")
	log_game("[key_name(owner)] is no longer hypnotized with the phrase '[hypnotic_phrase]'.")
	owner.log_message("is no longer hypnotized with the phrase '[hypnotic_phrase]'.", LOG_ATTACK, color="#960000")
	to_chat(owner, "<span class='userdanger'>Nagle wyrywasz się z hipnozy. Wyrażenie '[hypnotic_phrase]' nie wydaje ci się już ważne.</span>")
	owner.clear_alert("hypnosis")
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	traitorhud.leave_hud(owner.mind.current)
	if(owner.mind.antag_hud_icon_state == "brainwash")
		set_antag_hud(owner.mind.current, null)
	..()

/datum/brain_trauma/hypnosis/on_life()
	..()
	if(prob(2))
		switch(rand(1,2))
			if(1)
				to_chat(owner, "<i>...[lowertext(hypnotic_phrase)]...</i>")
			if(2)
				new /datum/hallucination/chat(owner, TRUE, FALSE, "<span class='hypnophrase'>[hypnotic_phrase]</span>")

/datum/brain_trauma/hypnosis/handle_hearing(datum/source, list/hearing_args)
	hearing_args[HEARING_RAW_MESSAGE] = target_phrase.Replace(hearing_args[HEARING_RAW_MESSAGE], "<span class='hypnophrase'>$1</span>")
