//These are all minor mutations that affect your speech somehow.
//Individual ones aren't commented since their functions should be evident at a glance

/datum/mutation/nervousness
	name = "Nerwowość"
	desc = "Sprawia, że nosiciel się jąka."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>Czujesz się zdenerwowany.</span>"

/datum/mutation/nervousness/on_life()
	if(prob(10))
		owner.stuttering = max(10, owner.stuttering)


/datum/mutation/wacky
	name = "Zwariowany głos"
	desc = "Nieznane."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='sans'>Czujesz dziwne uczucie w krtani.</span>"
	text_lose_indication = "<span class='notice'>Dziwne uczucie mija.</span>"

/datum/mutation/wacky/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/wacky/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/wacky/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_SANS

/datum/mutation/mute
	name = "Niemota"
	desc = "Całkowicie blokuje ośrodek mowy w mózgu."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>Czujesz, że w ogóle nie potrafisz się wyrazić.</span>"
	text_lose_indication = "<span class='danger'>Czujesz, że znów możesz swobodnie mówić.</span>"

/datum/mutation/mute/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/mute/on_losing(mob/living/carbon/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)


/datum/mutation/smile
	name = "Uśmiech"
	desc = "Wprawia w ciągłą manię."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Czujesz się taki szczęśliwy. Nic nie może być źle. :)</span>"
	text_lose_indication = "<span class='notice'>Znów wszystko jest okropne. :(</span>"

/datum/mutation/smile/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/smile/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/smile/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		//Time for a friendly game of SS13
		message = replacetext(message," stupid "," smart ")
		message = replacetext(message," unrobust "," robust ")
		message = replacetext(message," dumb "," smart ")
		message = replacetext(message," awful "," great ")
		message = replacetext(message," gay ",pick(" nice "," ok "," alright "))
		message = replacetext(message," horrible "," fun ")
		message = replacetext(message," terrible "," terribly fun ")
		message = replacetext(message," terrifying "," wonderful ")
		message = replacetext(message," gross "," cool ")
		message = replacetext(message," disgusting "," amazing ")
		message = replacetext(message," loser "," winner ")
		message = replacetext(message," useless "," useful ")
		message = replacetext(message," oh god "," ser i krakersy ")
		message = replacetext(message," jesus "," gee wiz ")
		message = replacetext(message," weak "," strong ")
		message = replacetext(message," kill "," hug ")
		message = replacetext(message," murder "," tease ")
		message = replacetext(message," ugly "," beautiful ")
		message = replacetext(message," douchbag "," nice guy ")
		message = replacetext(message," douchebag "," nice guy ")
		message = replacetext(message," whore "," lady ")
		message = replacetext(message," nerd "," smart guy ")
		message = replacetext(message," moron "," fun person ")
		message = replacetext(message," IT'S LOOSE "," WSZYSTKO W PORZĄDKU ")
		message = replacetext(message," sex "," hug fight ")
		message = replacetext(message," idiot "," genius ")
		message = replacetext(message," fat "," thin ")
		message = replacetext(message," beer "," woda z lodem ")
		message = replacetext(message," drink "," water ")
		message = replacetext(message," feminist "," empowered woman ")
		message = replacetext(message," nienawidzę cię "," jesteś wredny ")
		message = replacetext(message," jew "," jewish ")
		message = replacetext(message," shit "," shiz ")
		message = replacetext(message," crap "," poo ")
		message = replacetext(message," slut "," tease ")
		message = replacetext(message," ass "," butt ")
		message = replacetext(message," damn "," dang ")
		message = replacetext(message," fuck ","  ")
		message = replacetext(message," penis "," privates ")
		message = replacetext(message," cunt "," privates ")
		message = replacetext(message," dick "," jerk ")
		message = replacetext(message," vagina "," privates ")
		speech_args[SPEECH_MESSAGE] = trim(message)


/datum/mutation/unintelligible
	name = "Niezrozumiałość"
	desc = "Częściowo blokuje ośrodek mowy w mózgu, mocno zniekształcając mowę."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>Nie potrafisz ułożyć żadnej spójnej myśli!</span>"
	text_lose_indication = "<span class='danger'>Twój umysł wydaje się jaśniejszy.</span>"

/datum/mutation/unintelligible/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/unintelligible/on_losing(mob/living/carbon/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/polish//AQ EDIT
	name = "Polskość"
	desc = "Straszliwa mutacja z odległej przeszłości. Uważano ją za wytępioną po incydencie z 2137 roku."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Czujesz się Polakiem, jakkolwiek to działa.</span>"
	text_lose_indication = "<span class='notice'>Uczucie polskości mija.</span>"

/datum/mutation/polish/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/polish/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/polish/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,"o","ó")
		message = replacetext(message,"l","ł")
		message = replacetext(message,"a","ą")
		message = replacetext(message,"e","ę")
		message = replacetext(message,"c","ć")
		message = replacetext(message,"n","ń")
		message = replacetext(message,"z",pick("ź","ż"))
		if(prob(30))
			message += " Kur[pick("",", kurrrłaaa",", kurwa", " i tak to jest")]!"
		speech_args[SPEECH_MESSAGE] = trim(message)

/datum/mutation/chav
	name = "Dresiarz"
	desc = "Nieznane"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Czujesz się jak skończony dureń, nie?</span>"
	text_lose_indication = "<span class='notice'>Nie masz już ochoty być niegrzeczny i pyskaty.</span>"

/datum/mutation/chav/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/chav/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/chav/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings(BRIISH_TALK_FILE, "words")
		var/list/british_sounds = strings(BRIISH_TALK_FILE, "sounds")
		var/list/british_appends = strings(BRIISH_TALK_FILE, "appends")

		for(var/key in whole_words)
			var/value = whole_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		for(var/key in british_sounds)
			var/value = british_sounds[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")

		if(prob(8))
			message += pick(british_appends)
	speech_args[SPEECH_MESSAGE] = trim(message)


/datum/mutation/elvis
	name = "Elvis"
	desc = "Przerażająca mutacja nazwana na cześć swojego „pacjenta zero”."
	quality = MINOR_NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Czujesz się całkiem nieźle, laleczko.</span>"
	text_lose_indication = "<span class='notice'>Czujesz, że trochę mniej gadania byłoby super.</span>"

/datum/mutation/elvis/on_life()
	switch(pick(1,2))
		if(1)
			if(prob(15))
				var/list/dancetypes = list("swingowe", "wymyślne", "stylowe", "z XX wieku", "jive'owe", "rockandrollowe", "odlotowe", "nieprzyzwoite", "zawadiackie", "obłędne")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> wykonuje kilka ruchów: [dancemoves]!")
		if(2)
			if(prob(15))
				owner.visible_message("<b>[owner]</b> [pick("kołysze biodrami", "kręci biodrami", "wywija biodrami", "przytupuje", "tańczy do wyimaginowanej piosenki", "potrząsa nogami", "pstryka palcami")]!")

/datum/mutation/elvis/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/elvis/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/elvis/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		message = replacetext(message," i'm not "," I ain't ")
		message = replacetext(message," girl ",pick(" honey "," baby "," baby doll "))
		message = replacetext(message," man ",pick(" son "," buddy "," brother"," pal "," friendo "))
		message = replacetext(message," out of "," outta ")
		message = replacetext(message," dziękuję "," dziękuję, bardzo dziękuję ")
		message = replacetext(message," thanks "," dziękuję, bardzo dziękuję ")
		message = replacetext(message," czym ty jesteś "," whatcha ")
		message = replacetext(message," yes ",pick(" sure", "yea "))
		message = replacetext(message," muh valids "," my kicks ")
		speech_args[SPEECH_MESSAGE] = trim(message)


/datum/mutation/stoner
	name = "Zjarus"
	desc = "Częsta mutacja, która mocno obniża inteligencję."
	quality = NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Czujesz się... totalnie wyluzowany, stary!</span>"
	text_lose_indication = "<span class='notice'>Czujesz, że masz lepsze wyczucie czasu.</span>"

/datum/mutation/stoner/on_acquiring(mob/living/carbon/owner)
	..()
	owner.grant_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_STONER)
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/stoner/on_losing(mob/living/carbon/owner)
	..()
	owner.remove_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_STONER)
	owner.remove_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/medieval
	name = "Średniowiecze"
	desc = "Okropna przypadłość genetyczna, na którą cierpiano w dawnych czasach."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Czujesz, iżby mógł wyruszyć na poszukiwanie Graala.</span>"
	text_lose_indication = "<span class='notice'>Nie masz już ochoty niczego szukać.</span>"

/datum/mutation/medieval/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/medieval/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/medieval/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings(MEDIEVAL_SPEECH_FILE, "words")

		for(var/key in whole_words)
			var/value = whole_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

	speech_args[SPEECH_MESSAGE] = trim(message)
