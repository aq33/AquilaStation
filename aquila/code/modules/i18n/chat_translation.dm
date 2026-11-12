// OOC, adminhelpy i PW z adminami zawsze w języku odbiorcy (haki z aquila/code/__HELPERS/chat_translation.dm).
// OOC: odbiorca z innym językiem niż autor widzi samo tłumaczenie.
// Adminhelp i PW: odbiorca widzi oryginał z dopiskiem tłumaczenia, żeby admin mógł sprawdzić, co gracz naprawdę napisał.
// Admini czytają po polsku, więc adminhelp obcokrajowca idzie do nich z polskim tłumaczeniem.

/// Nieudane tłumaczenia czatu (klucz -> world.time): OOC idzie do wielu odbiorców, a błąd API nie może kazać czekać każdemu z osobna.
/// Udane tłumaczenia trzyma pamięć SStranslation.
GLOBAL_LIST_EMPTY(aq_chat_translation_failures)
#define AQ_CHAT_FAILURES_MAX 50
/// Po tym czasie nieudane tłumaczenie można spróbować jeszcze raz
#define AQ_CHAT_FAILURE_MEMORY (30 SECONDS)
#define AQ_CHAT_TRANSLATION_TIMEOUT (6 SECONDS)

/datum/aq_translation_wait
	var/done = FALSE
	var/result

/datum/aq_translation_wait/proc/receive(list/translations)
	result = translations?[1]
	done = TRUE

/**
 * Tłumaczy jeden tekst i czeka na wynik (śpi). Zwraca tłumaczenie albo null (brak klucza, błąd, limit czasu).
 * Dla wołających z verba albo Topic, które mogą spać. Nieudana próba jest pamiętana przez AQ_CHAT_FAILURE_MEMORY, więc kolejni odbiorcy tej samej wiadomości nie czekają.
 */
/proc/aq_translate_wait(text, source_lang, target_lang)
	if(!text)
		return null
	var/key = "[source_lang]>[target_lang]|[text]"
	var/cached = SStranslation.cache_get(source_lang, target_lang, text)
	if(!isnull(cached))
		return cached
	var/failed_at = GLOB.aq_chat_translation_failures[key]
	if(failed_at && world.time - failed_at < AQ_CHAT_FAILURE_MEMORY)
		return null
	var/datum/aq_translation_wait/waiter = new
	SStranslation.translate(list(text), source_lang, target_lang, CALLBACK(waiter, TYPE_PROC_REF(/datum/aq_translation_wait, receive)))
	var/give_up = world.time + AQ_CHAT_TRANSLATION_TIMEOUT
	while(!waiter.done && world.time < give_up)
		sleep(1)
	GLOB.aq_chat_translation_failures -= key
	if(!waiter.result)
		if(length(GLOB.aq_chat_translation_failures) >= AQ_CHAT_FAILURES_MAX)
			GLOB.aq_chat_translation_failures.Cut(1, 2)
		GLOB.aq_chat_translation_failures[key] = world.time
	return waiter.result

// Jedno tłumaczenie na całą wiadomość, przed pętlą rozsyłania, i tylko gdy ktoś, kto ją zobaczy, mówi innym językiem
/client/aq_ooc_prepare(raw_msg)
	var/from_language = game_language()
	/// język odbiorcy -> odbiorcy
	var/list/readers = list()
	for(var/client/C as anything in GLOB.clients)
		if(!C?.prefs || !(C.prefs.chat_toggles & CHAT_OOC))
			continue
		if(!holder && (key in C.prefs.ignoring))
			continue
		var/to_language = C.game_language()
		if(to_language != from_language)
			LAZYADD(readers[to_language], C)
	if(!length(readers))
		return null
	. = list()
	// jedno tłumaczenie na język odbiorców
	for(var/to_language in readers)
		var/translated = aq_translate_wait(html_decode(raw_msg), GLOB.game_language_deepl[from_language], GLOB.game_language_deepl[to_language])
		if(!translated)
			continue
		translated = sanitize(translated)
		for(var/client/C as anything in readers[to_language])
			.[C] = translated
	if(!length(.))
		return null

/client/aq_admin_msg_for(client/recipient, msg, sanitized = TRUE, html = FALSE)
	var/from_language = game_language()
	var/to_language = recipient ? recipient.game_language() : GAME_LANGUAGE_PL
	if(!msg || from_language == to_language)
		return msg
	var/static/regex/html_tags = new(@"<[^>]*>", "g")
	var/source = html ? html_decode(html_tags.Replace(msg, "")) : (sanitized ? html_decode(msg) : msg)
	var/translated = aq_translate_wait(source, GLOB.game_language_deepl[from_language], GLOB.game_language_deepl[to_language])
	if(!translated)
		return msg
	return aq_admin_translation_text(msg, translated, sanitized || html)

/**
 * Oryginał z dopiskiem tłumaczenia. as_html: wynik idzie do czatu bez kolejnego sanitize(), więc tłumaczenie jest
 * sanityzowane, a etykieta ma osobny węzeł, który słownik wersji EN przetłumaczy klientowi na „Translation:”.
 * Bez as_html (treść nowego adminhelpa, sanitize() i obcięcie do MAX_MESSAGE_LEN robi /datum/admin_help/New)
 * oryginał jest skracany tak, żeby całe tłumaczenie zmieściło się w limicie.
 */
/proc/aq_admin_translation_text(msg, translated, as_html)
	if(as_html)
		return "[msg] (<span class='aq_translation_label'>Tłumaczenie:</span> [sanitize(translated)])"
	var/suffix = " (Tłumaczenie: [translated])"
	var/room = MAX_MESSAGE_LEN - 1 - length_char(suffix)
	if(length_char(msg) > room)
		msg = room > 3 ? "[copytext_char(msg, 1, room - 2)]..." : ""
	return "[msg][suffix]"

#undef AQ_CHAT_FAILURES_MAX
#undef AQ_CHAT_FAILURE_MEMORY
#undef AQ_CHAT_TRANSLATION_TIMEOUT
