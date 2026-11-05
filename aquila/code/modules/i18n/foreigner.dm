// Obcokrajowiec: gracz z angielskim w preferencjach (game_language.dm) dołącza do rundy jako ktoś,
// kto nie zna Galaktycznego Wspólnego. Mówi tylko po Angielsku, a polska załoga słyszy bełkot. Polskiej mowy też nie rozumie.
// Tłumacz (translator_item.dm) przy sobie zmienia to w dwie strony przez DeepL (translation_api.dm):
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
	if(M?.client?.wants_english() && isliving(H))
		H.aq_make_foreigner()
		H.aq_give_translator(M)

/// Blokuje Wspólny i daje Angielski. Źródło LANGUAGE_FOREIGNER przetrwa zmianę ciała (klon, borg), bo języki trzyma umysł.
/mob/living/proc/aq_make_foreigner()
	var/datum/language_holder/holder = get_language_holder()
	holder.grant_language(/datum/language/english, TRUE, TRUE, LANGUAGE_FOREIGNER)
	holder.add_blocked_language(/datum/language/common, LANGUAGE_FOREIGNER)
	holder.selected_language = /datum/language/english
	if(mind)
		mind.aq_foreigner = TRUE

/// Tłumacz z rundy: do kieszeni albo do ręki, a silikony mają go wbudowanego. Komunikat idzie do M, bo H nie ma jeszcze klucza.
/mob/living/proc/aq_give_translator(mob/M)
	ADD_TRAIT(src, TRAIT_AQ_TRANSLATOR, "wbudowany")
	to_chat(M, span_notice("Nie znasz polskiego, a załoga nie zna angielskiego. Twój wbudowany tłumacz przekłada mowę w obie strony."))

/mob/living/carbon/aq_give_translator(mob/M)
	var/obj/item/aquila_translator/translator = new(get_turf(src))
	var/where = equip_in_one_of_slots(translator, list("w lewej kieszeni" = ITEM_SLOT_LPOCKET, "w prawej kieszeni" = ITEM_SLOT_RPOCKET), qdel_on_fail = FALSE)
	if(!where && put_in_hands(translator))
		where = "w ręce"
	if(!where)
		where = equip_in_one_of_slots(translator, list("w plecaku" = ITEM_SLOT_BACKPACK), qdel_on_fail = FALSE)
	to_chat(M, span_notice("Nie znasz polskiego, a załoga nie zna angielskiego. Tłumacz kieszonkowy ([where || "pod nogami"]) przekłada mowę w obie strony, dopóki masz go w ręce, w kieszeni albo na pasku."))

/**
 * Hook z /mob/living/say, po wyborze języka. Obcokrajowiec mówi po angielsku z tłumaczem przy sobie:
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
	if(QDELETED(src))
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
	say(rebuilt, bubble_type, spans || list(), TRUE, null, TRUE)
	aq_translated_say = FALSE

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
