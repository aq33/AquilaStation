// Tłumaczenie po stronie serwera dla tekstów, które BYOND rysuje sam: dymki (balloon alerts),
// runechat nad głowami i screentipy. Czat i okna tłumaczy klient (game_language.dm).
// Tylko stałe teksty ze słownika (strings/i18n/en_dm.json), bez szablonów z wstawkami:
// te teksty są krótkie, a wyszukiwanie w tablicy nic nie kosztuje.

/// Tablica PL -> EN (krótkie stałe), wczytywana przy pierwszej potrzebie gracza z językiem EN
GLOBAL_LIST_EMPTY(i18n_en_table)
GLOBAL_VAR_INIT(i18n_en_loaded, FALSE)

/proc/i18n_en_table()
	if(GLOB.i18n_en_loaded)
		return GLOB.i18n_en_table
	GLOB.i18n_en_loaded = TRUE
	var/path = "strings/i18n/en_dm.json"
	if(!fexists(path))
		log_world("i18n: brak [path], teksty serwera zostaną po polsku")
		return GLOB.i18n_en_table
	var/start = REALTIMEOFDAY
	var/list/table = json_decode(file2text(path))
	if(islist(table))
		GLOB.i18n_en_table = table
	log_world("i18n: wczytano [length(GLOB.i18n_en_table)] tekstów EN w [(REALTIMEOFDAY - start) / 10] s")
	return GLOB.i18n_en_table

/**
 * Stały tekst po angielsku albo null. Kod często dokleja znak końca zdania sam
 * ("krzyczy" + "."), więc szukamy też bez niego. Spacje na brzegach zostają.
 */
/proc/i18n_en_exact(text)
	if(!istext(text))
		return null
	var/trimmed = trim(text)
	if(!length(trimmed))
		return null
	var/list/table = i18n_en_table()
	var/found = table[trimmed]
	if(isnull(found))
		var/last = copytext(trimmed, -1)
		if(last == "." || last == "!" || last == "?")
			found = table[copytext(trimmed, 1, -1)]
			if(!isnull(found) && !(copytext(found, -1) in list(".", "!", "?")))
				found += last
	if(isnull(found))
		return null
	var/start = findtext(text, trimmed)
	return copytext(text, 1, start) + found + copytext(text, start + length(trimmed))

/// Węzeł tekstowy HTML (dla regex.Replace): ">tekst<" po angielsku, jeśli jest w słowniku
/proc/i18n_en_text_node(match, inner)
	var/found = i18n_en_exact(inner)
	return isnull(found) ? match : ">[found]<"

/// Tekst albo HTML po angielsku: cały tekst, a jeśli nie ma go w słowniku, każdy węzeł tekstowy osobno
/proc/i18n_en_html(text)
	if(!istext(text) || !length(text))
		return text
	var/whole = i18n_en_exact(text)
	if(!isnull(whole))
		return whole
	if(!findtext(text, "<"))
		return text
	var/static/regex/text_node = regex(@">([^<>]+)<", "g")
	var/wrapped = text_node.Replace(">[text]<", /proc/i18n_en_text_node)
	return copytext(wrapped, 2, -1)

/// Tekst dla konkretnego gracza: po angielsku, jeśli wybrał angielski
/proc/i18n_for_client(client/C, text)
	if(!C?.wants_english())
		return text
	return i18n_en_html(text)

// Dymki: tworzone dla jednego widza, więc wystarczy przetłumaczyć tekst
/atom/balloon_alert(mob/viewer, text, color = null, show_in_chat = TRUE, offset_x, offset_y)
	return ..(viewer, i18n_for_client(viewer?.client, text), color, show_in_chat, offset_x, offset_y)

// Runechat: jedna wiadomość dla wielu słuchaczy. Gracze z językiem EN dostają osobną, przetłumaczoną.
// Wartości domyślne jak w chatmessage.dm (CHAT_MESSAGE_LIFESPAN jest tam #undef, więc liczba wprost)
/datum/chatmessage/New(text, atom/target, list/client/hearers, language_icon, list/extra_classes = list(), lifespan = 5.4 SECONDS)
	if(type == /datum/chatmessage && istext(text) && length(hearers))
		var/list/english = list()
		for(var/client/C as anything in hearers)
			if(C?.wants_english())
				english += C
		if(length(english))
			var/translated = i18n_en_html(text)
			if(translated != text)
				hearers = hearers - english
				new /datum/chatmessage(translated, target, english, language_icon, extra_classes?.Copy(), lifespan)
	return ..(text, target, hearers, language_icon, extra_classes, lifespan)
