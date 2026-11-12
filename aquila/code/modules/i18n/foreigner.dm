// Obcokrajowiec: gracz z angielskim w preferencjach (game_language.dm) dołącza do rundy jako ktoś,
// kto nie zna Galaktycznego Wspólnego. Mówi tylko po Angielsku, a polska załoga słyszy bełkot. Polskiej mowy też nie rozumie.
// Tłumacz (czip w słuchawkach, translator_chip.dm, albo tłumacz kieszonkowy, translator_item.dm) przy sobie zmienia to w dwie strony przez DeepL (translation_api.dm):
// - jego angielska wypowiedź idzie do API i wraca przez say() jako polska mowa we Wspólnym (czat, dymki, radio, szept),
// - polską mowę, którą słyszy, dostaje po angielsku (czat i dymek nad głową).
// Bez klucza API albo przy błędzie tekst przechodzi bez tłumaczenia (Polacy dostają angielski, on polski).
// Języki antagonistów i ras (Nar'Siański, Ksenowspólny, mowa cieni itd., aq_auto_translated_language()) tłumaczą się same, bez tłumacza:
// obcokrajowiec mówi w nich angielskim tekstem, który polscy kultyści dostają po polsku, a polską mowę w nich słyszy po angielsku.
// Kanały telepatyczne (kult, ul ksenomorfów, karpie, Mindlink) idą przez to_chat, więc tłumaczy je aq_to_chat_speech().
// Gracz z angielskim, który wszedł do ciała spoza pracy (antagonista, rola ducha, nowe ciało z nowym umysłem), zostaje obcokrajowcem
// z wbudowanym tłumaczem. Wbudowany tłumacz siedzi w umyśle i przechodzi z nim na nowe ciało.

/datum/language/english
	name = "Angielski"
	desc = "Język obcokrajowców z Ziemi. Bez tłumacza polska załoga nic z niego nie rozumie."
	key = "e"
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_UNDERSTOOD
	default_priority = 90
	icon = 'aquila/icons/misc/language_english.dmi'
	icon_state = "english"
	syllables = list(
		"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
		"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
		"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
		"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
		"wh", "ly", "ght", "ough", "ck", "sh", "ew", "oo", "ee", "ay", "ow", "y", "you", "wor", "ple", "ble",
	)

/datum/mind
	/// Dołączył z angielskim w preferencjach: nie zna Wspólnego, a tłumacz tłumaczy mu polską mowę
	var/aq_foreigner = FALSE
	/// Wbudowany tłumacz (silikony, obcokrajowcy spoza prac): idzie z umysłem na każde nowe ciało
	var/aq_builtin_translator = FALSE
	/// Tłumacz już wydany (czip, tłumacz kieszonkowy albo wbudowany), żeby nie dać drugiego
	var/aq_translator_given = FALSE

/mob/living
	/// Ustawiane na czas say() z gotowym tłumaczeniem: mowa nie wraca do tłumacza
	var/aq_translated_say = FALSE
	/// message_mods powtórki po tłumaczeniu: język (Wspólny albo język antagonisty), własny czasownik, emotka bez treści
	var/list/aq_translated_say_mods
	/// Ustawiane na czas sprawdzenia dymka z gotowym tłumaczeniem: ten dymek ma wyjść
	var/aq_hearing_translation = FALSE

/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	aq_handle_foreigner(H, M)

// Cyborg w core nie woła ..(), więc bez tego gracz z angielskim jako borg nie byłby obcokrajowcem
/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	. = ..()
	aq_handle_foreigner(R, M)

/datum/job/proc/aq_handle_foreigner(mob/living/H, mob/M)
	if(!M?.client?.wants_english() || !isliving(H))
		return
	// Przy dołączeniu w trakcie rundy klient wchodzi do ciała przed after_spawn, więc obcokrajowcem może już być (aq_foreigner_login)
	if(!H.mind?.aq_foreigner)
		H.aq_make_foreigner()
	if(H.mind)
		if(H.mind.aq_translator_given)
			return
		H.mind.aq_translator_given = TRUE
	// Po całym after_spawn (też podtypów prac): ochrona z NSV podmienia słuchawki na działowe, a czip ma trafić do końcowych
	addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living, aq_give_translator), M), 1)

/// Blokuje Wspólny i daje Angielski. Źródło LANGUAGE_FOREIGNER przetrwa zmianę ciała (klon, borg), bo języki trzyma umysł.
/mob/living/proc/aq_make_foreigner()
	var/datum/language_holder/holder = get_language_holder()
	holder.grant_language(/datum/language/english, TRUE, TRUE, LANGUAGE_FOREIGNER)
	holder.add_blocked_language(/datum/language/common, LANGUAGE_FOREIGNER)
	holder.selected_language = /datum/language/english
	if(mind)
		mind.aq_foreigner = TRUE
	// mowa w językach antagonistów tłumaczy się też bez tłumacza
	aq_update_translator_hook()

/// Tłumacz z rundy: czip w słuchawkach, bez słuchawek tłumacz kieszonkowy do kieszeni albo do ręki, a silikony mają go wbudowanego.
/// M to gracz z lobby: na starcie rundy klient przechodzi do ciała dopiero w transfer_characters(), czasem już po tym timerze.
/mob/living/proc/aq_give_translator(mob/M)
	aq_give_builtin_translator(M)

/// Wbudowany tłumacz: zapisany w umyśle, więc działa też w każdym następnym ciele (konstrukt, cień, klon, borg)
/mob/living/proc/aq_give_builtin_translator(mob/M)
	if(mind)
		mind.aq_builtin_translator = TRUE
	aq_translator_on(AQ_TRANSLATOR_BUILTIN)
	to_chat(aq_spawn_reader(M), span_notice("Nie znasz polskiego, a załoga nie zna angielskiego. Twój wbudowany tłumacz przekłada mowę w obie strony."))

/mob/living/carbon/aq_give_translator(mob/M)
	// Czip w słuchawkach z ekwipunku pracy (translator_chip.dm); tłumacz kieszonkowy tylko dla tych bez słuchawek
	var/obj/item/radio/headset/headset = get_item_by_slot(ITEM_SLOT_EARS)
	if(istype(headset) && !headset.aq_translator_chip)
		headset.aq_translator_chip = new /obj/item/aquila_translator/chip(headset)
		headset.aq_update_translator_wearer()
		to_chat(aq_spawn_reader(M), span_notice("Nie znasz polskiego, a załoga nie zna angielskiego. Czip tłumacza w twoich słuchawkach przekłada mowę w obie strony, dopóki masz je na uszach."))
		return
	var/obj/item/aquila_translator/translator = new(get_turf(src))
	var/where = equip_in_one_of_slots(translator, list("w lewej kieszeni" = ITEM_SLOT_LPOCKET, "w prawej kieszeni" = ITEM_SLOT_RPOCKET), qdel_on_fail = FALSE)
	if(!where && put_in_hands(translator))
		where = "w ręce"
	if(!where)
		where = equip_in_one_of_slots(translator, list("w plecaku" = ITEM_SLOT_BACKPACK), qdel_on_fail = FALSE)
	if(!where)
		where = "pod nogami"
	to_chat(aq_spawn_reader(M), span_notice("Nie znasz polskiego, a załoga nie zna angielskiego. Tłumacz kieszonkowy ([where]) przekłada mowę w obie strony, dopóki masz go w ręce, w kieszeni albo na pasku."))

/// Kto przeczyta komunikat ze spawnu: ciało, jeśli ma już klienta, inaczej gracz w lobby
/mob/living/proc/aq_spawn_reader(mob/M)
	return (client || !M?.client) ? src : M

// Wejście do ciała: wbudowany tłumacz z umysłu, sygnał mowy, a gracz z angielskim spoza prac zostaje obcokrajowcem
/mob/living/Login()
	. = ..()
	aq_foreigner_login()

/mob/living/proc/aq_foreigner_login()
	if(!mind)
		return
	if(mind.aq_builtin_translator && !HAS_TRAIT_FROM(src, TRAIT_AQ_TRANSLATOR, AQ_TRANSLATOR_BUILTIN))
		aq_translator_on(AQ_TRANSLATOR_BUILTIN)
	aq_update_translator_hook()
	// Tik później: przy dołączeniu w trakcie rundy after_spawn pracy (czip, tłumacz kieszonkowy) przychodzi zaraz po wejściu do ciała
	if(!mind.aq_foreigner && client?.wants_english())
		addtimer(CALLBACK(src, PROC_REF(aq_late_foreigner)), 1)

/// Gracz z angielskim w ciele bez pracy (antagonista, rola ducha, nowe ciało z nowym umysłem): obcokrajowiec z wbudowanym tłumaczem.
/// Tylko klient z angielskim w preferencjach, więc Polakowi Wspólny nie znika.
/mob/living/proc/aq_late_foreigner()
	if(QDELETED(src) || !mind || mind.aq_foreigner || !client?.wants_english())
		return
	aq_make_foreigner()
	if(!mind.aq_translator_given)
		mind.aq_translator_given = TRUE
		aq_give_builtin_translator(src)

// Umysł na nowym ciele (konstrukt, cień, klon, borg): wbudowany tłumacz idzie z nim, a angielski z tłumacza w ręce starego ciała zostaje
/datum/mind/transfer_to(mob/new_character, force_key_move = 0)
	var/mob/living/old_body = current
	. = ..()
	if(!current || old_body == current)
		return
	// Silikony mają tłumacza wbudowanego, także obcokrajowiec zamieniony w borga w trakcie rundy (czip został w słuchawkach)
	if(aq_foreigner && issilicon(current))
		aq_builtin_translator = TRUE
	if(istype(old_body))
		if(aq_builtin_translator)
			old_body.aq_translator_off(AQ_TRANSLATOR_BUILTIN)
		old_body.aq_update_translator_hook()
	if(aq_builtin_translator)
		current.aq_translator_on(AQ_TRANSLATOR_BUILTIN)
	else if(!HAS_TRAIT(current, TRAIT_AQ_TRANSLATOR))
		// Języki trzyma umysł, więc angielski z tłumacza starego ciała przeszedłby razem z nim
		current.remove_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(current))
		var/mob/living/living_current = current
		living_current.aq_update_translator_hook()

/// Sygnał z /mob/living/say() słucha ten, kto ma tłumacza (przedmiot albo wbudowany), i każdy obcokrajowiec (języki antagonistów)
/mob/living/proc/aq_update_translator_hook()
	if(HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR) || mind?.aq_foreigner)
		RegisterSignal(src, COMSIG_LIVING_AQ_PRE_SAY, PROC_REF(aq_on_pre_say), override = TRUE)
	else if(!aq_translated_say)
		UnregisterSignal(src, COMSIG_LIVING_AQ_PRE_SAY)

/mob/living/proc/aq_on_pre_say(datum/source, original_message, message, list/message_mods, datum/language/language, bubble_type, list/spans, forced)
	SIGNAL_HANDLER
	if(aq_translated_say)
		aq_translated_say = FALSE
		var/list/mods = aq_translated_say_mods || list(LANGUAGE_EXTENSION = /datum/language/common)
		aq_translated_say_mods = null
		for(var/mod in mods)
			message_mods[mod] = mods[mod]
		return COMPONENT_AQ_SAY_LANGUAGE_FROM_MODS
	if(aq_translator_intercept(original_message, message, message_mods, language, bubble_type, spans, forced))
		return COMPONENT_AQ_SAY_INTERCEPTED

// Angielski mówi każdy język, który mówi Wspólnym (bez zmiany listy w core)
/obj/item/organ/tongue/could_speak_language(datum/language/dt)
	if(dt == /datum/language/english)
		return !!languages_possible?[/datum/language/common]
	return ..()

/**
 * Język, w którym mowa obcokrajowca tłumaczy się sama, bez tłumacza: każdy poza Wspólnym i Angielskim.
 * To języki antagonistów (Nar'Siański, Ratvariański, Ksenowspólny, mowa cieni, wampirów, robaków krwi) i ras (Draconic, Moffic itd.).
 * Polak i obcokrajowiec znają je oba w grze, więc tekst między nimi ma przejść, choć nikt nie nosi słuchawek.
 * Barierę Wspólny–Angielski zdejmuje dopiero tłumacz (czip, tłumacz kieszonkowy, wbudowany).
 */
/proc/aq_auto_translated_language(datum/language/language)
	return ispath(language, /datum/language) && language != /datum/language/common && language != /datum/language/english

/// Czy tę wypowiedź tłumaczymy na polski: Angielski z tłumaczem przy sobie albo język antagonisty u obcokrajowca
/mob/living/proc/aq_translates_speech(datum/language/language)
	if(language == /datum/language/english)
		return HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR)
	return mind?.aq_foreigner && aq_auto_translated_language(language)

/**
 * Z sygnału COMSIG_LIVING_AQ_PRE_SAY (/mob/living/say, po wyborze języka). Obcokrajowiec mówi po angielsku z tłumaczem przy sobie
 * albo w języku antagonisty: treść idzie do API, a przetłumaczona wraca przez say() z tymi samymi przedrostkami (radio, szept, śpiew,
 * kanał kultu) i z własnym czasownikiem, we Wspólnym (z Angielskiego) albo w tym samym języku antagonisty.
 * TRUE = wiadomość przejęta, oryginał nie wychodzi.
 */
/mob/living/proc/aq_translator_intercept(original_message, message, list/message_mods, datum/language/language, bubble_type, list/spans, forced)
	if(forced || !aq_translates_speech(language))
		return FALSE
	var/emote = message_mods[MODE_CUSTOM_SAY_EMOTE]
	var/erase = message_mods[MODE_CUSTOM_SAY_ERASE_INPUT]
	// Treść jest końcówką oryginału (get_message_mods i własna emotka obcinają tylko początek)
	var/cut = emote ? findlasttext(original_message, "[emote]*") : length(original_message) - length(message) + 1
	if(cut < 1 || (!emote && copytext(original_message, cut) != message))
		cut = 1
	var/prefix = html_decode(copytext(original_message, 1, cut))
	var/list/texts = list()
	if(emote)
		texts += html_decode(emote)
	if(!erase)
		texts += html_decode(message)
	log_talk(message, LOG_SAY, tag = "przed tłumaczeniem", custom_say_emote = emote)
	SStranslation.translate(texts, DEEPL_LANG_EN, DEEPL_LANG_PL, CALLBACK(src, PROC_REF(aq_translator_say), prefix, !!emote, erase, texts, bubble_type, spans?.Copy(), language))
	return TRUE

/**
 * Wypowiedź po tłumaczeniu (albo bez niego, gdy translations jest null). Język i własny czasownik idą prosto do message_mods
 * (aq_on_pre_say), a nie przez tekst z gwiazdką, więc gwiazdki w treści zostają, a czasownik nie wpada do treści.
 */
/mob/living/proc/aq_translator_say(prefix, has_emote, erase, list/originals, bubble_type, list/spans, datum/language/language, list/translations)
	// Martwy w trakcie zapytania: say() wysłałby mowę IC na czat duchów
	if(QDELETED(src) || stat == DEAD)
		return
	var/list/texts = translations || originals
	var/index = 1
	var/list/mods = list(LANGUAGE_EXTENSION = aq_auto_translated_language(language) ? language : /datum/language/common)
	if(has_emote)
		mods[MODE_CUSTOM_SAY_EMOTE] = trim(copytext_char(sanitize(texts[index++]), 1, MAX_MESSAGE_LEN))
	var/content
	if(erase)
		// say() nie przepuści pustej treści, a przy samym czasowniku i tak jej nie widać (jak w check_for_custom_say_emote)
		mods[MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		content = "coś ciekawego do powiedzenia"
	else
		content = texts[index]
	aq_translated_say = TRUE
	aq_translated_say_mods = mods
	// filtry czatu IC i RP sprawdziły już oryginał, powtórka nie karze drugi raz (AQ EDIT w /mob/living/say)
	ADD_TRAIT(src, TRAIT_AQ_TRANSLATED_SPEECH, "tłumacz")
	// tłumacz mógł zniknąć w trakcie zapytania, a powtórka i tak ma wyjść przetłumaczona
	RegisterSignal(src, COMSIG_LIVING_AQ_PRE_SAY, PROC_REF(aq_on_pre_say), override = TRUE)
	// forced: bez drugiego slowmode i antyspamu, a gwiazdka w treści nie robi z niej własnego czasownika
	say("[prefix][content]", bubble_type, spans || list(), TRUE, null, TRUE, "tłumacz")
	REMOVE_TRAIT(src, TRAIT_AQ_TRANSLATED_SPEECH, "tłumacz")
	aq_translated_say = FALSE
	aq_translated_say_mods = null
	aq_update_translator_hook()

/**
 * Mowa, którą obcokrajowiec dostaje przez tłumacza, a nie tak, jak przyszła:
 * Wspólny z tłumaczem przy sobie (zamiast bełkotu) albo znany mu język antagonisty (polski tekst), także bez tłumacza.
 */
/mob/living/proc/aq_hears_via_translator(datum/language/message_language)
	if(aq_hearing_translation || !mind?.aq_foreigner)
		return FALSE
	if(message_language == /datum/language/common)
		return HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR) && !has_language(/datum/language/common)
	return aq_auto_translated_language(message_language) && has_language(message_language)

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(!client || message_mods?[MODE_AQ_TRANSLATED] || !aq_hears_via_translator(message_language))
		return ..()
	aq_translate_heard(message, speaker, message_language, raw_message, radio_freq, spans, message_mods)

/// Polska mowa idzie do tłumacza, a wynik do aq_hear_translated()
/mob/living/proc/aq_translate_heard(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods)
	var/list/texts = list(html_decode(raw_message))
	var/emote = message_mods?[MODE_CUSTOM_SAY_EMOTE]
	if(emote)
		texts += html_decode(emote)
	SStranslation.translate(texts, DEEPL_LANG_PL, DEEPL_LANG_EN, CALLBACK(src, PROC_REF(aq_hear_translated), message, speaker, message_language, radio_freq, spans?.Copy(), message_mods ? message_mods.Copy() : list(), texts))

/// Polska mowa po tłumaczeniu na angielski: czat (przez zwykłe Hear) i dymek nad głową.
/// Wspólnego nie zna, więc tłumaczenie wychodzi w Angielskim; język antagonisty zna, więc mowa zostaje w nim (ikona, czcionka).
/mob/living/proc/aq_hear_translated(message, atom/movable/speaker, datum/language/message_language, radio_freq, list/spans, list/message_mods, list/originals, list/translations)
	if(QDELETED(src) || !speaker)
		return
	var/list/texts = translations || originals
	var/heard = sanitize(texts[1])
	if(length(texts) > 1)
		message_mods[MODE_CUSTOM_SAY_EMOTE] = sanitize(texts[2])
	message_mods[MODE_AQ_TRANSLATED] = TRUE
	var/datum/language/shown_language = message_language == /datum/language/common ? /datum/language/english : message_language
	aq_hearing_translation = TRUE
	var/show_bubble = should_show_chat_message(speaker, shown_language, FALSE, is_heard = TRUE)
	aq_hearing_translation = FALSE
	if(show_bubble)
		create_chat_message(speaker, shown_language, list(src), message_mods[MODE_CUSTOM_SAY_ERASE_INPUT] ? message_mods[MODE_CUSTOM_SAY_EMOTE] : heard, spans, message_mods)
	Hear(message, speaker, shown_language, heard, radio_freq, spans, message_mods)

// Dymek z oryginałem nie wychodzi, bo zaraz przyjdzie przetłumaczony (aq_hear_translated)
/mob/living/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote = FALSE, is_heard = FALSE)
	if(!is_emote && aq_hears_via_translator(message_language))
		return FALSE // CHATMESSAGE_CANNOT_HEAR
	return ..()

/// Odbiorca czyta po angielsku: obcokrajowiec, a mob bez umysłu (duch), gdy gracz ma angielski w preferencjach
/proc/aq_reads_english(mob/target)
	if(!ismob(target))
		return FALSE
	if(target.mind)
		return target.mind.aq_foreigner
	return !!target.client?.wants_english()

/**
 * to_chat dla mowy w kanałach telepatycznych (kult, ul ksenomorfów, karpie, Mindlink), które omijają Hear().
 * html to cała linijka, a message to treść wypowiedzi tak, jak w niej stoi (po sanitize).
 * Obcokrajowiec dostaje polską treść po angielsku, a Polak angielską treść obcokrajowca po polsku; reszta linijki zostaje.
 * Mowa obcokrajowca przetłumaczona już przy mówieniu (TRAIT_AQ_TRANSLATED_SPEECH na czas powtórki) liczy się jako polska.
 * Tłumaczenie jest asynchroniczne, a bez klucza API albo przy błędzie odbiorca dostaje oryginał.
 */
/proc/aq_to_chat_speech(mob/target, html, message, atom/movable/speaker)
	if(!target)
		return
	var/from_english = FALSE
	if(isliving(speaker))
		var/mob/living/talker = speaker
		from_english = talker.mind?.aq_foreigner && !HAS_TRAIT(talker, TRAIT_AQ_TRANSLATED_SPEECH)
	var/to_english = aq_reads_english(target)
	var/cut = length(message) ? findlasttext(html, message) : 0
	if(!from_english == !to_english || !cut)
		to_chat(target, html)
		return
	var/list/texts = list(html_decode(message))
	SStranslation.translate(texts, from_english ? DEEPL_LANG_EN : DEEPL_LANG_PL, to_english ? DEEPL_LANG_EN : DEEPL_LANG_PL, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aq_to_chat_speech_translated), target, html, cut, length(message), texts))

/// Linijka z kanału telepatycznego po tłumaczeniu: treść podmieniona w tym samym miejscu
/proc/aq_to_chat_speech_translated(mob/target, html, cut, cut_length, list/originals, list/translations)
	if(QDELETED(target))
		return
	if(!translations)
		to_chat(target, html)
		return
	to_chat(target, "[copytext(html, 1, cut)][sanitize(translations[1])][copytext(html, cut + cut_length)]")
