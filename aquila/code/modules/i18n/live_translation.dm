// Tłumaczenie na żywo: odbiorca od razu widzi oryginał z „…”, a gdy DeepL odpowie, ta sama linijka w czacie
// zamienia się w tłumaczenie (panel: tgui/packages/tgui-panel/chat/aqLiveTranslation.ts), a dymek nad głową w przetłumaczony.
// Przy błędzie, braku odpowiedzi albo przepełnionej kolejce zostaje oryginał. Tekst z pamięci tłumaczeń idzie od razu przetłumaczony.
// Korzystają z tego: słyszenie obcokrajowca (foreigner.dm), kanały telepatyczne (aq_to_chat_speech) i OOC (chat_translation.dm).
// Mowa samego obcokrajowca dalej czeka na tłumaczenie, a w tym czasie nad jego głową wisi dymek „…”.

/// Typ wiadomości panelu: typy internal/ trafiają do każdej karty i nie są sklejane z sąsiednimi
#define AQ_LIVE_TRANSLATION_PANEL_TYPE "internal/aq_translation"

GLOBAL_VAR_INIT(aq_live_translation_count, 0)
/// Inny przy każdym starcie serwera: panel trzyma linijki z poprzednich rund, a sam licznik od zera by się z nimi pomylił
GLOBAL_VAR_INIT(aq_live_translation_prefix, "[world.timeofday]-[rand(1000, 9999)]")

/mob/living
	/// Na czas Hear() z oryginałem: identyfikator, którym compose_message() owija treść w linijce czatu
	var/aq_live_wrap_id
	/// Treść do owinięcia (raw_message tej wypowiedzi)
	var/aq_live_wrap_text
	/// compose_message() znalazło treść w linijce i ją owinęło
	var/aq_live_wrapped = FALSE

/proc/aq_live_translation_id()
	return "aqtr-[GLOB.aq_live_translation_prefix]-[++GLOB.aq_live_translation_count]"

/// Oryginał w znaczniku, który panel znajdzie po identyfikatorze, gdy przyjdzie tłumaczenie
/proc/aq_live_translation_wrap(html, id)
	return "<span class=\"aq-tr aq-tr-pending\" data-aq-tr=\"[id]\">[html]</span>"

/**
 * Wysyła panelowi wynik: HTML tłumaczenia (po sanitize) albo null, gdy się nie udało (panel zdejmuje „…” i zostawia oryginał).
 * Idzie przez SSchat jak zwykłe linijki, więc nie przepada i nie wyprzedza linijki, której dotyczy.
 */
/proc/aq_live_translation_send(clients, id, translated_html)
	SSchat.queue(clients, list("type" = AQ_LIVE_TRANSLATION_PANEL_TYPE, "id" = id, "html" = translated_html))

/// TRUE, gdy tłumaczenie przyjdzie dopiero z API: jest klucz, a nie wszystko jest w pamięci (z pamięci callback rusza od razu)
/datum/controller/subsystem/translation/proc/will_request(list/texts, source_lang, target_lang)
	if(!trim(CONFIG_GET(string/deepl_api_key)))
		return FALSE
	for(var/text in texts)
		if(isnull(cache_get(source_lang, target_lang, text)))
			return TRUE
	return FALSE

/**
 * Wstawia znacznik wokół treści wypowiedzi w gotowej linijce. compose_message() puszcza całą linijkę przez say_emphasis(),
 * więc treść z |kursywą| stoi w niej już ze znacznikami HTML. Zwraca null, gdy treści nie ma w linijce.
 */
/atom/proc/aq_live_translation_wrap_in(html, raw_message, id)
	for(var/part in list(raw_message, say_emphasis(raw_message)))
		var/pos = findlasttext(html, part)
		if(pos)
			return "[copytext(html, 1, pos)][aq_live_translation_wrap(part, id)][copytext(html, pos + length(part))]"
	return null

/mob/living/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), face_name = FALSE)
	. = ..()
	if(isnull(aq_live_wrap_id) || raw_message != aq_live_wrap_text)
		return
	var/wrapped = aq_live_translation_wrap_in(., raw_message, aq_live_wrap_id)
	aq_live_wrap_id = null
	if(wrapped)
		aq_live_wrapped = TRUE
		return wrapped

/**
 * Dymek nad mówiącym tylko dla tego moba, z tym samym sprawdzeniem co w aq_hear_translated().
 * Zwraca weakref do dymka albo null (runechat wyłączony, lag switch, mówiący zniknął).
 */
/mob/living/proc/aq_translation_bubble(atom/movable/speaker, datum/language/language, text, list/spans, list/message_mods)
	var/datum/chatmessage/bubble
	// Flaga trwa także w create_chat_message(), które sprawdza dymek drugi raz (inaczej znany język antagonisty go blokuje)
	aq_hearing_translation = TRUE
	if(should_show_chat_message(speaker, language, FALSE, is_heard = TRUE))
		bubble = create_chat_message(speaker, language, list(src), text, spans, message_mods)
	aq_hearing_translation = FALSE
	return bubble ? WEAKREF(bubble) : null

/// Usuwa dymek od razu, jeśli jeszcze wisi. FALSE, gdy już zniknął albo nie skończył się rysować (wtedy zostaje do końca).
/proc/aq_remove_chat_bubble(datum/weakref/bubble_ref)
	var/datum/chatmessage/bubble = bubble_ref?.resolve()
	if(QDELETED(bubble) || bubble.isFading || !bubble.fadertimer)
		return FALSE
	qdel(bubble)
	return TRUE

/**
 * Obcokrajowiec słyszy polską mowę: oryginał od razu w czacie (owinięty) i w dymku z „…”, tłumaczenie potem w tym samym miejscu.
 * FALSE, gdy na żywo się nie da (własny czasownik, wszystko w pamięci, brak klucza) i trzeba czekać jak dotąd.
 */
/mob/living/proc/aq_hear_live(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, list/texts)
	if(message_mods?[MODE_CUSTOM_SAY_EMOTE] || !SStranslation.will_request(texts, DEEPL_LANG_PL, DEEPL_LANG_EN))
		return FALSE
	var/datum/language/shown_language = message_language == /datum/language/common ? /datum/language/english : message_language
	var/list/mods = message_mods ? message_mods.Copy() : list()
	mods[MODE_AQ_TRANSLATED] = TRUE
	var/datum/weakref/bubble = aq_translation_bubble(speaker, shown_language, "[raw_message] …", spans, mods)
	var/id = aq_live_translation_id()
	aq_live_wrap_id = id
	aq_live_wrap_text = raw_message
	aq_live_wrapped = FALSE
	Hear(message, speaker, shown_language, raw_message, radio_freq, spans, mods)
	var/wrapped = aq_live_wrapped
	aq_live_wrap_id = null
	aq_live_wrap_text = null
	aq_live_wrapped = FALSE
	SStranslation.translate(texts, DEEPL_LANG_PL, DEEPL_LANG_EN, CALLBACK(src, PROC_REF(aq_hear_live_translated), id, wrapped, bubble, message, speaker, shown_language, radio_freq, spans?.Copy(), mods, texts))
	return TRUE

/// Wynik dla aq_hear_live(): podmiana linijki i dymka. Gdy linijki nie dało się owinąć (głuchota, nietypowy format), tłumaczenie idzie nową linijką.
/mob/living/proc/aq_hear_live_translated(id, wrapped, datum/weakref/bubble, message, atom/movable/speaker, datum/language/shown_language, radio_freq, list/spans, list/message_mods, list/originals, list/translations)
	if(QDELETED(src))
		return
	var/heard = sanitize((translations || originals)[1])
	if(aq_remove_chat_bubble(bubble) && !QDELETED(speaker))
		aq_translation_bubble(speaker, shown_language, heard, spans, message_mods)
	if(wrapped)
		if(client)
			aq_live_translation_send(client, id, translations ? say_emphasis(heard) : null)
	else if(translations && !QDELETED(speaker))
		Hear(message, speaker, shown_language, heard, radio_freq, spans, message_mods)

/// Linijka z kanału telepatycznego po tłumaczeniu na żywo
/proc/aq_to_chat_speech_live_translated(mob/target, id, list/translations)
	if(target?.client)
		aq_live_translation_send(target.client, id, translations ? sanitize(translations[1]) : null)

/// OOC po tłumaczeniu na żywo. Z opóźnieniem, bo przy przepełnionej kolejce null przychodzi od razu, jeszcze przed rozesłaniem linijek.
/proc/aq_ooc_live_translated(list/readers, id, list/translations)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aq_live_translation_send), readers, id, translations ? emoji_parse(sanitize(translations[1])) : null), 1)

/// Dymek „…” nad obcokrajowcem, którego wypowiedź czeka na tłumaczenie. Widzą go ci, którzy zobaczyliby dymek emotki.
/mob/living/proc/aq_translator_wait_bubble(list/message_mods)
	var/list/viewers = list()
	for(var/mob/M in get_hearers_in_view(message_mods?[WHISPER_MODE] ? 1 : 7, src))
		if(M.client)
			viewers += M
	if(!length(viewers))
		return null
	var/list/mods = list()
	mods[CHATMESSAGE_EMOTE] = TRUE
	var/datum/chatmessage/bubble = create_chat_message(src, null, viewers, "…", null, mods)
	return bubble ? WEAKREF(bubble) : null

#undef AQ_LIVE_TRANSLATION_PANEL_TYPE
