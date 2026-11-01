// AQUILA - port z tgstation (code/datums/mutations/speech.dm)

/datum/mutation/piglatin
	name = "Świńska łacina"
	desc = "Historycy mówią, że pięć wieków temu cała ludzkość posługiwała się tym mistycznym językiem. \
		Pacjent musi w nim mówić, a często trudno go zrozumieć."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Ośćcay ziwnieday ięsay zujeczay.</span>"
	text_lose_indication = "<span class='notice'>Dziwne uczucie mija.</span>"

/datum/mutation/piglatin/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/piglatin/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/piglatin/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return
	speech_args[SPEECH_MESSAGE] = piglatin_sentence(message)

/datum/mutation/heckacious
	name = "Krtań do kwadratu"
	desc = "ziom co ŻE twoje słowa stary..........."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='sans'>o KURDE stary. twoje gardło jest jakieś TAKIE.</span>"
	text_lose_indication = "<span class='notice'>Demoniczna istota, która opętała twoją krtań, w końcu cię puszcza.</span>"
	locked = TRUE

/datum/mutation/heckacious/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/heckacious/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/heckacious/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return
	var/list/super_wacky_words = tgmut_strings("heckacious", "heckacious")
	var/list/edited_message_words = list()
	for(var/editing_word in splittext(message, " "))
		if(editing_word == "")
			continue
		var/og_word = editing_word
		var/word_edited = FALSE
		for(var/key in super_wacky_words)
			var/value = super_wacky_words[key]
			if(islist(value))
				value = pick(value)
			editing_word = replacetextEx(editing_word, "[uppertext(key)]", "[uppertext(value)]")
			editing_word = replacetextEx(editing_word, "[capitalize(key)]", "[capitalize(value)]")
			editing_word = replacetextEx(editing_word, "[key]", "[value]")
			if(editing_word != og_word)
				word_edited = TRUE

		// Losowe wielkie litery
		if(prob(10))
			editing_word = prob(85) ? uppertext(editing_word) : lowertext(editing_word)
		// czasem....... KROPKI...
		if(prob(10))
			for(var/dotnum in 1 to rand(2, 8))
				editing_word += "."
		// pogrubienie, kursywa albo podkreślenie
		if(prob(10))
			var/extra_emphasis = pick("+", "_", "|")
			editing_word = extra_emphasis + editing_word + extra_emphasis

		// Bez zamiany przekręcamy litery sami
		if(!word_edited)
			if(prob(65))
				editing_word = replacetext(editing_word, pick(TGMUT_VOWELS), pick(TGMUT_VOWELS))
			for(var/i in 1 to rand(1, 2))
				editing_word = replacetext(editing_word, pick(TGMUT_CONSONANTS), pick(TGMUT_CONSONANTS))
			// rzadko litera jest PODWOJJONA...
			var/patchword = ""
			for(var/letter_index in 1 to length_char(editing_word))
				var/letter = copytext_char(editing_word, letter_index, letter_index + 1)
				patchword += prob(92) ? letter : letter + letter
			editing_word = patchword

		edited_message_words += editing_word

	speech_args[SPEECH_MESSAGE] = trim(jointext(edited_message_words, " "))
