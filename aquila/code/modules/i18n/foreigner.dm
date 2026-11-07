// Obcokrajowiec: gracz z angielskim w preferencjach (game_language.dm) dołącza do rundy jako ktoś,
// kto nie zna Galaktycznego Wspólnego. Mówi tylko po Angielsku, a polska załoga słyszy bełkot. Polskiej mowy też nie rozumie.
// Tłumacz (czip w słuchawkach, translator_chip.dm, albo tłumacz kieszonkowy, translator_item.dm) przy sobie zmienia to w dwie strony przez DeepL (translation_api.dm):
// - jego angielska wypowiedź idzie do API i wraca przez say() jako polska mowa we Wspólnym (czat, dymki, radio, szept),
// - polską mowę, którą słyszy, dostaje po angielsku (czat i dymek nad głową).
// Bez klucza API albo przy błędzie tekst przechodzi bez tłumaczenia (Polacy dostają angielski, on polski).

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

/mob/living
	/// Ustawiane na czas say() z gotowym tłumaczeniem: mowa idzie we Wspólnym i nie wraca do tłumacza
	var/aq_translated_say = FALSE

/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	aq_handle_foreigner(H, M)

// Cyborg w core nie woła ..(), więc bez tego gracz z angielskim jako borg nie byłby obcokrajowcem
/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	. = ..()
	aq_handle_foreigner(R, M)

/datum/job/proc/aq_handle_foreigner(mob/living/H, mob/M)
	if(!M?.client?.wants_english() || !isliving(H) || H.mind?.aq_foreigner)
		return
	H.aq_make_foreigner()
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

/// Tłumacz z rundy: czip w słuchawkach, bez słuchawek tłumacz kieszonkowy do kieszeni albo do ręki, a silikony mają go wbudowanego.
/// M to gracz z lobby: na starcie rundy klient przechodzi do ciała dopiero w transfer_characters(), czasem już po tym timerze.
/mob/living/proc/aq_give_translator(mob/M)
	ADD_TRAIT(src, TRAIT_AQ_TRANSLATOR, "wbudowany")
	aq_update_translator_hook()
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

/// Sygnał z /mob/living/say() słucha tylko ten, kto ma tłumacza (przedmiot albo wbudowany)
/mob/living/proc/aq_update_translator_hook()
	if(HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR))
		RegisterSignal(src, COMSIG_LIVING_AQ_PRE_SAY, PROC_REF(aq_on_pre_say), override = TRUE)
	else if(!aq_translated_say)
		UnregisterSignal(src, COMSIG_LIVING_AQ_PRE_SAY)

/mob/living/proc/aq_on_pre_say(datum/source, original_message, message, list/message_mods, datum/language/language, bubble_type, list/spans, forced)
	SIGNAL_HANDLER
	if(aq_translated_say)
		aq_translated_say = FALSE
		return COMPONENT_AQ_SAY_AS_COMMON
	if(aq_translator_intercept(original_message, message, message_mods, language, bubble_type, spans, forced))
		return COMPONENT_AQ_SAY_INTERCEPTED

// Angielski mówi każdy język, który mówi Wspólnym (bez zmiany listy w core)
/obj/item/organ/tongue/could_speak_language(datum/language/dt)
	if(dt == /datum/language/english)
		return !!languages_possible?[/datum/language/common]
	return ..()

/**
 * Z sygnału COMSIG_LIVING_AQ_PRE_SAY (/mob/living/say, po wyborze języka). Obcokrajowiec mówi po angielsku z tłumaczem przy sobie:
 * treść idzie do API, a przetłumaczona wraca przez say() z tymi samymi przedrostkami (radio, szept, śpiew).
 * TRUE = wiadomość przejęta, oryginał nie wychodzi.
 */
/mob/living/proc/aq_translator_intercept(original_message, message, list/message_mods, datum/language/language, bubble_type, list/spans, forced)
	if(forced || language != /datum/language/english || !HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR))
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
	SStranslation.translate(texts, DEEPL_LANG_EN, DEEPL_LANG_PL, CALLBACK(src, PROC_REF(aq_translator_say), prefix, !!emote, erase, texts, bubble_type, spans?.Copy()))
	return TRUE

/// Wypowiedź po tłumaczeniu (albo bez niego, gdy translations jest null)
/mob/living/proc/aq_translator_say(prefix, has_emote, erase, list/originals, bubble_type, list/spans, list/translations)
	// Martwy w trakcie zapytania: say() wysłałby mowę IC na czat duchów
	if(QDELETED(src) || stat == DEAD)
		return
	var/list/texts = translations || originals
	var/rebuilt = prefix
	var/index = 1
	if(has_emote)
		// gwiazdka oddziela własną emotkę od treści
		rebuilt += "[replacetext(texts[index++], "*", "")]*"
	if(!erase)
		rebuilt += replacetext(texts[index], "*", "")
	aq_translated_say = TRUE
	// filtry czatu IC i RP sprawdziły już oryginał, powtórka nie karze drugi raz (AQ EDIT w /mob/living/say)
	ADD_TRAIT(src, TRAIT_AQ_TRANSLATED_SPEECH, "tłumacz")
	// tłumacz mógł zniknąć w trakcie zapytania, a powtórka i tak ma wyjść we Wspólnym
	RegisterSignal(src, COMSIG_LIVING_AQ_PRE_SAY, PROC_REF(aq_on_pre_say), override = TRUE)
	say(rebuilt, bubble_type, spans || list(), TRUE, null, TRUE)
	REMOVE_TRAIT(src, TRAIT_AQ_TRANSLATED_SPEECH, "tłumacz")
	aq_translated_say = FALSE
	aq_update_translator_hook()

/// Obcokrajowiec z tłumaczem słyszy mowę we Wspólnym: tłumaczymy ją, zamiast pokazać bełkot
/mob/living/proc/aq_hears_via_translator(datum/language/message_language)
	return message_language == /datum/language/common && mind?.aq_foreigner && HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR) && !has_language(/datum/language/common)

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(!client || !aq_hears_via_translator(message_language))
		return ..()
	var/list/texts = list(html_decode(raw_message))
	var/emote = message_mods[MODE_CUSTOM_SAY_EMOTE]
	if(emote)
		texts += html_decode(emote)
	SStranslation.translate(texts, DEEPL_LANG_PL, DEEPL_LANG_EN, CALLBACK(src, PROC_REF(aq_hear_translated), message, speaker, radio_freq, spans?.Copy(), message_mods.Copy(), texts))

/// Polska mowa po tłumaczeniu na angielski: czat (przez zwykłe Hear w Angielskim, który zna) i dymek nad głową
/mob/living/proc/aq_hear_translated(message, atom/movable/speaker, radio_freq, list/spans, list/message_mods, list/originals, list/translations)
	if(QDELETED(src) || !speaker)
		return
	var/list/texts = translations || originals
	var/heard = sanitize(texts[1])
	if(length(texts) > 1)
		message_mods[MODE_CUSTOM_SAY_EMOTE] = sanitize(texts[2])
	if(should_show_chat_message(speaker, /datum/language/english, FALSE, is_heard = TRUE))
		create_chat_message(speaker, /datum/language/english, list(src), message_mods[MODE_CUSTOM_SAY_ERASE_INPUT] ? message_mods[MODE_CUSTOM_SAY_EMOTE] : heard, spans, message_mods)
	Hear(message, speaker, /datum/language/english, heard, radio_freq, spans, message_mods)

// Dymek z bełkotem nie wychodzi, bo zaraz przyjdzie przetłumaczony (aq_hear_translated)
/mob/living/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote = FALSE, is_heard = FALSE)
	if(!is_emote && aq_hears_via_translator(message_language))
		return FALSE // CHATMESSAGE_CANNOT_HEAR
	return ..()
