// OOC, adminhelpy i PW z adminami zawsze w języku odbiorcy (haki z aquila/code/__HELPERS/chat_translation.dm).
// OOC: odbiorca z innym językiem niż autor widzi samo tłumaczenie.
// Adminhelp i PW: odbiorca widzi oryginał z dopiskiem tłumaczenia, żeby admin mógł sprawdzić, co gracz naprawdę napisał.
// Admini czytają po polsku, więc adminhelp obcokrajowca idzie do nich z polskim tłumaczeniem.

/// Ostatnie tłumaczenia czatu: OOC idzie do wielu odbiorców, a nieudane zapytanie nie może kazać czekać każdemu z osobna
GLOBAL_LIST_EMPTY(aq_chat_translations)
#define AQ_CHAT_TRANSLATIONS_MAX 50
#define AQ_CHAT_TRANSLATION_TIMEOUT (6 SECONDS)

/datum/aq_translation_wait
	var/done = FALSE
	var/result

/datum/aq_translation_wait/proc/receive(list/translations)
	result = translations?[1]
	done = TRUE

/**
 * Tłumaczy jeden tekst i czeka na wynik (śpi). Zwraca tłumaczenie albo null (brak klucza, błąd, limit czasu).
 * Dla wołających z verba albo Topic, które mogą spać. Nieudane próby też są zapamiętane, więc drugi raz nie czekamy.
 */
/proc/aq_translate_wait(text, source_lang, target_lang)
	if(!text)
		return null
	var/key = "[source_lang]>[target_lang]|[text]"
	if(key in GLOB.aq_chat_translations)
		return GLOB.aq_chat_translations[key] || null
	var/datum/aq_translation_wait/waiter = new
	SStranslation.translate(list(text), source_lang, target_lang, CALLBACK(waiter, TYPE_PROC_REF(/datum/aq_translation_wait, receive)))
	var/give_up = world.time + AQ_CHAT_TRANSLATION_TIMEOUT
	while(!waiter.done && world.time < give_up)
		sleep(1)
	if(length(GLOB.aq_chat_translations) >= AQ_CHAT_TRANSLATIONS_MAX)
		GLOB.aq_chat_translations.Cut(1, 2)
	GLOB.aq_chat_translations[key] = waiter.result || ""
	return waiter.result

/client/aq_ooc_for(client/recipient, raw_msg)
	var/from_english = wants_english()
	if(!recipient || from_english == recipient.wants_english())
		return null
	var/translated = aq_translate_wait(html_decode(raw_msg), from_english ? DEEPL_LANG_EN : DEEPL_LANG_PL, from_english ? DEEPL_LANG_PL : DEEPL_LANG_EN)
	return translated ? sanitize(translated) : null

/client/aq_admin_msg_for(client/recipient, msg, sanitized = TRUE)
	var/from_english = wants_english()
	var/to_english = recipient ? recipient.wants_english() : FALSE
	if(!msg || from_english == to_english)
		return msg
	var/translated = aq_translate_wait(sanitized ? html_decode(msg) : msg, from_english ? DEEPL_LANG_EN : DEEPL_LANG_PL, to_english ? DEEPL_LANG_EN : DEEPL_LANG_PL)
	if(!translated)
		return msg
	return "[msg] ([to_english ? "Translation" : "Tłumaczenie"]: [sanitized ? sanitize(translated) : translated])"

#undef AQ_CHAT_TRANSLATIONS_MAX
#undef AQ_CHAT_TRANSLATION_TIMEOUT
