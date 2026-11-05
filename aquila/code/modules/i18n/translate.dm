// Tłumaczenie po stronie serwera dla tekstów, które BYOND rysuje sam: dymki (balloon alerts),
// runechat nad głowami i screentipy. Czat i okna tłumaczy klient (game_language.dm).
// Słownik: strings/i18n/en_dm.json (krótkie stałe i szablony bez HTML, tools/i18n/build_chat_dict.py).
// Szablony działają tak jak w kliencie (tgui/packages/tgui/i18n.ts), w prostszej wersji:
// cały tekst, bez dzielenia wielowyrazowych imion między sąsiednie wstawki.

/// Stałe PL -> EN
GLOBAL_LIST_EMPTY(i18n_en_table)
/// Szablony: [kotwice, teksty PL, części EN, alternatywy?]
GLOBAL_LIST_EMPTY(i18n_en_templates)
/// Słowo-kotwica -> numery szablonów
GLOBAL_LIST_EMPTY(i18n_en_anchors)
/// Tekst -> tłumaczenie (albo ten sam tekst), dymki i runechat często się powtarzają
GLOBAL_LIST_EMPTY(i18n_en_cache)
GLOBAL_VAR_INIT(i18n_en_loaded, FALSE)

/// Najwięcej zapamiętanych tłumaczeń, potem pamięć zaczyna się od nowa
#define I18N_CACHE_SIZE 5000
/// Ile nierozpoznanego tekstu (litery słów pisanych małą literą) może zostać w wartościach na jedną literę
/// rozpoznanego. Jak MAX_UNKNOWN_RATIO w kliencie: lepiej nic nie tłumaczyć niż zrobić mieszankę.
#define I18N_MAX_UNKNOWN_RATIO 1.5

/proc/i18n_en_load()
	if(GLOB.i18n_en_loaded)
		return
	GLOB.i18n_en_loaded = TRUE
	var/path = "strings/i18n/en_dm.json"
	if(!fexists(path))
		log_world("i18n: brak [path], teksty serwera zostaną po polsku")
		return
	var/start = REALTIMEOFDAY
	var/list/data = json_decode(file2text(path))
	if(!islist(data))
		return
	GLOB.i18n_en_table = data["exact"] || list()
	GLOB.i18n_en_templates = data["templates"] || list()
	var/list/anchors = GLOB.i18n_en_anchors
	for(var/index in 1 to length(GLOB.i18n_en_templates))
		var/list/template = GLOB.i18n_en_templates[index]
		var/list/keys = islist(template[1]) ? template[1] : list(template[1])
		for(var/key in keys)
			LAZYADD(anchors[key], index)
	log_world("i18n: wczytano [length(GLOB.i18n_en_table)] tekstów i [length(GLOB.i18n_en_templates)] szablonów EN w [(REALTIMEOFDAY - start) / 10] s")

/proc/i18n_en_table()
	i18n_en_load()
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
	var/found = i18n_en_cased(table, trimmed)
	// BYOND dokleja "the" przed wstawionym obiektem: tłumaczymy samą nazwę, przedimek zostaje
	if(isnull(found) && (copytext(trimmed, 1, 5) == "the " || copytext(trimmed, 1, 5) == "The "))
		var/name = i18n_en_exact(copytext(trimmed, 5))
		if(!isnull(name))
			found = copytext(trimmed, 1, 5) + name
	if(isnull(found))
		var/last = copytext(trimmed, -1)
		if(last == "." || last == "!" || last == "?")
			found = i18n_en_cased(table, copytext(trimmed, 1, -1))
			if(!isnull(found) && !(copytext(found, -1) in list(".", "!", "?")))
				found += last
	if(isnull(found))
		return null
	var/start = findtext(text, trimmed)
	return copytext(text, 1, start) + found + copytext(text, start + length(trimmed))

/// Stała z tolerancją wielkości pierwszej litery ("amoniak" z "Amoniak"); wynik dostaje wielkość litery tekstu
/proc/i18n_en_cased(list/table, text)
	. = table[text]
	if(!isnull(.) || !length(text))
		return
	var/first = copytext_char(text, 1, 2)
	var/lower = lowertext(first)
	var/is_lower = (first == lower)
	var/other = table[(is_lower ? uppertext(first) : lower) + copytext_char(text, 2)]
	if(!istext(other) || !length(other))
		return other
	var/head = copytext_char(other, 1, 2)
	return (is_lower ? lowertext(head) : uppertext(head)) + copytext_char(other, 2)

/// Tekst do wyrażenia regularnego: znaki specjalne dosłownie, odstępy elastycznie
/proc/i18n_regex_escape(text)
	var/static/list/special = list("\\", "^", "$", ".", "|", "?", "*", "+", "(", ")", "\[", "]", "{", "}")
	var/static/regex/space = regex(@"\s+", "g")
	for(var/character in special) // backslash pierwszy, żeby nie zdublować dodanych
		text = replacetext(text, character, "\\[character]")
	return space.Replace(text, "\\s+")

/// Wyrażenie dla szablonu (cały tekst) albo FALSE, jeśli się nie da go zbudować
/proc/i18n_en_template_regex(index)
	var/static/list/cache = list()
	var/key = "[index]"
	if(!isnull(cache[key]))
		return cache[key]
	var/list/template = GLOB.i18n_en_templates[index]
	var/list/texts = template[2]
	var/list/alts = length(template) >= 4 ? template[4] : null
	var/source = "^\\s*"
	for(var/i in 1 to length(texts))
		if(i > 1)
			var/list/options = alts ? alts["[i - 2]"] : null
			if(options)
				source += "([i18n_regex_escape(options[1])]|[i18n_regex_escape(options[2])])"
			else
				source += (i == length(texts)) ? "(.*)" : "(.*?)"
		var/fixed = texts[i]
		// odstępy na brzegach całego tekstu łapią ^\s* i \s*$
		if(i == 1)
			fixed = trim_left(fixed)
		if(i == length(texts))
			fixed = trim_right(fixed)
		source += i18n_regex_escape(fixed)
	source += "\\s*$"
	var/regex/built = regex(source)
	cache[key] = built || FALSE
	return cache[key]

/// Litery w słowach pisanych małą literą: miara polskiego tekstu, który by został (imiona się nie liczą)
/proc/i18n_lowercase_letters(text)
	var/static/regex/separators = regex(@{"[\s.,!?;:()"'\-]+"})
	// wprost, bez uppertext(): wielkość polskich liter nie musi być obsłużona
	var/static/list/polish_lowercase = list("ą", "ć", "ę", "ł", "ń", "ó", "ś", "ź", "ż")
	var/count = 0
	for(var/word in splittext(text, separators))
		if(!length(word))
			continue
		var/first = copytext_char(word, 1, 2)
		var/code = text2ascii(first)
		if((code >= 97 && code <= 122) || (first in polish_lowercase))
			count += length_char(word)
	return count

/// Wartość wstawiona w szablon: stała ze słownika albo bez zmian
/proc/i18n_en_value(value)
	var/found = i18n_en_exact(value)
	return isnull(found) ? value : found

/// Przedimek przed nazwą pospolitą (\the, \a z angielskiego oryginału)
/proc/i18n_with_article(value, article)
	var/first = copytext_char(trim(value), 1, 2)
	if(!length(first) || first == "<" || first != lowertext(first))
		return value
	var/word
	if(lowertext(article) == "the")
		word = "the"
	else
		word = (lowertext(first) in list("a", "e", "i", "o", "u")) ? "an" : "a"
	if(copytext(article, 1, 2) != lowertext(copytext(article, 1, 2)))
		word = capitalize(word)
	return "[word] [value]"

/// Tekst po angielsku według najlepszego szablonu albo null
/proc/i18n_en_template(text)
	i18n_en_load()
	if(!length(GLOB.i18n_en_templates) || length(text) > 300)
		return null
	var/list/candidates = list()
	var/static/regex/separators = regex(@{"[\s.,!?;:()\[\]"'<>/\-]+"})
	for(var/word in splittext(lowertext(text), separators))
		var/list/found = GLOB.i18n_en_anchors[word]
		if(found)
			candidates |= found
	var/best
	var/best_score = -1
	for(var/index in candidates)
		var/regex/matcher = i18n_en_template_regex(index)
		if(!matcher || !matcher.Find(text))
			continue
		var/list/template = GLOB.i18n_en_templates[index]
		var/list/alts = length(template) >= 4 ? template[4] : null
		var/list/captures = matcher.group.Copy()
		var/fixed = length(jointext(template[2], ""))
		var/known = 0
		var/unknown = 0
		for(var/i in 1 to length(captures))
			var/value = captures[i]
			if(alts && alts["[i - 1]"])
				known += length(value)
			else if(!isnull(i18n_en_exact(value)))
				known += length(trim(value))
			else
				unknown += i18n_lowercase_letters(value)
		if(unknown > I18N_MAX_UNKNOWN_RATIO * (fixed + known))
			continue
		if(fixed + known <= best_score)
			continue
		best_score = fixed + known
		best = i18n_en_render(template, captures)
	if(isnull(best))
		return null
	// odstępy na brzegach jak w tekście wejściowym, nie jak w szablonie
	var/trimmed = trim(text)
	var/start = findtext(text, trimmed)
	return copytext(text, 1, start) + trim(best) + copytext(text, start + length(trimmed))

/// Angielska strona szablonu z wartościami (numery wstawek w JSON liczone od zera)
/proc/i18n_en_render(list/template, list/captures)
	var/list/alts = length(template) >= 4 ? template[4] : null
	. = ""
	for(var/part in template[3])
		if(!islist(part))
			. += part
			continue
		var/list/piece = part
		if(piece[1] == "?")
			// gałąź warunku: ta, której polska alternatywa wystąpiła w tekście
			var/list/options = alts ? alts["[piece[2]]"] : null
			var/value = captures[piece[2] + 1]
			var/branch = (options && trim(value) == trim(options[2])) ? 2 : 1
			. += piece[3][branch]
			continue
		var/value = i18n_en_value(captures[piece[1] + 1] || "")
		. += length(piece) > 1 ? i18n_with_article(value, piece[2]) : value

/// Węzeł tekstowy HTML (dla regex.Replace): ">tekst<" po angielsku, jeśli jest w słowniku
/proc/i18n_en_text_node(match, inner)
	var/found = i18n_en_exact(inner)
	return isnull(found) ? match : ">[found]<"

/// Tekst albo HTML po angielsku: stała, szablon (zwykły tekst), a w HTML każdy węzeł tekstowy osobno
/proc/i18n_en_html(text)
	if(!istext(text) || !length(text))
		return text
	if(findtext(text, "<"))
		// HTML (screentipy) jest zmienny i tani: tylko stałe, węzeł po węźle, bez pamięci podręcznej
		. = i18n_en_exact(text)
		if(isnull(.))
			var/static/regex/text_node = regex(@">([^<>]+)<", "g")
			var/wrapped = text_node.Replace(">[text]<", /proc/i18n_en_text_node)
			. = copytext(wrapped, 2, -1)
		return
	// zwykły tekst (dymki, runechat) się powtarza, a szablony kosztują: pamięć podręczna
	var/list/cache = GLOB.i18n_en_cache
	var/cached = cache[text]
	if(!isnull(cached))
		return cached
	. = i18n_en_exact(text)
	if(isnull(.))
		. = i18n_en_template(text) || text
	if(length(cache) >= I18N_CACHE_SIZE)
		cache.Cut()
	cache[text] = .

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
	// To, co powiedział gracz, zostaje, jak je napisał: tłumaczymy emotki i mowę maszyn/NPC (teksty z kodu)
	var/player_speech = FALSE
	if(ismob(target) && !("emote" in extra_classes))
		var/mob/speaker = target
		player_speech = !!speaker.ckey
	if(type == /datum/chatmessage && istext(text) && length(hearers) && !player_speech)
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

#undef I18N_CACHE_SIZE
#undef I18N_MAX_UNKNOWN_RATIO
