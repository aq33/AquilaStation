// Tłumaczenie mowy przez DeepL API (https://developers.deepl.com/docs/api-reference/translate).
// Korzysta z niego tłumacz obcokrajowca (foreigner.dm). Klucz podaje się w configu jako DEEPL_API_KEY.
// Klucz darmowego planu (DeepL API Free) kończy się na ":fx" i idzie na api-free.deepl.com.
// Zapytania są asynchroniczne (rust_g), a wynik trafia do callbacku. Bez klucza, przy błędzie
// i po TRANSLATION_TIMEOUT callback dostaje null, a wołający zostawia tekst bez tłumaczenia.

/// Klucz DeepL API. Pusty = tłumacz przepuszcza tekst bez tłumaczenia.
/datum/config_entry/string/deepl_api_key
	protection = CONFIG_ENTRY_HIDDEN | CONFIG_ENTRY_LOCKED

/// Najwyżej tyle zapytań naraz, kolejne od razu wracają bez tłumaczenia
#define TRANSLATION_MAX_PENDING 20
/// Po tym czasie mowa idzie bez tłumaczenia, żeby nie wisiała bez końca
#define TRANSLATION_TIMEOUT (5 SECONDS)
/// Najwięcej zapamiętanych tłumaczeń w jednym kierunku, potem pamięć zaczyna się od nowa
#define TRANSLATION_CACHE_SIZE 3000
/// Spóźnione zapytanie, które nie odpowiedziało nawet po tym czasie, przestajemy sprawdzać
#define TRANSLATION_LATE_GIVE_UP (60 SECONDS)

SUBSYSTEM_DEF(translation)
	name = "Tłumacz"
	wait = 1
	flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	can_fire = FALSE
	/// "PL>EN" -> list(tekst -> tłumaczenie)
	var/list/cache = list()
	/// Klucz zapytania -> /datum/translation_job. To samo zdanie słyszane przez kilku graczy idzie do API raz.
	var/list/pending = list()
	/// Zapytania po TRANSLATION_TIMEOUT: wołający dostali już null, ale odpowiedź trzeba odebrać z rust_g i zapamiętać
	var/list/datum/translation_job/late = list()
	/// Kiedy ostatnio zalogowano błąd API (bez zalewania logu, gdy skończy się limit)
	var/last_error_log = -INFINITY

/datum/translation_job
	var/list/texts
	var/source_lang
	var/target_lang
	var/datum/http_request/request
	var/list/datum/callback/callbacks = list()
	var/started
	/// Teksty poszły jako HTML ze znacznikami formatowania (aq_mask_emphasis), odpowiedź trzeba z nich odpakować
	var/html = FALSE

/datum/controller/subsystem/translation/stat_entry(msg)
	msg = "W toku: [length(pending)]"
	return ..()

/datum/controller/subsystem/translation/proc/cache_get(source_lang, target_lang, text)
	var/list/direction = cache["[source_lang]>[target_lang]"]
	return direction?[text]

/datum/controller/subsystem/translation/proc/cache_set(source_lang, target_lang, text, translation)
	var/key = "[source_lang]>[target_lang]"
	var/list/direction = cache[key]
	if(!direction || length(direction) >= TRANSLATION_CACHE_SIZE)
		direction = list()
		cache[key] = direction
	direction[text] = translation

/**
 * Tłumaczy teksty i woła on_done z listą tłumaczeń (w tej samej kolejności) albo z null.
 * Gdy wszystko jest w pamięci albo nie ma klucza, callback rusza od razu, jeszcze przed powrotem z procki.
 * Języki to kody DeepL bez wariantu (DEEPL_LANG_PL, DEEPL_LANG_EN).
 */
/datum/controller/subsystem/translation/proc/translate(list/texts, source_lang, target_lang, datum/callback/on_done)
	var/list/result = list()
	for(var/text in texts)
		var/found = cache_get(source_lang, target_lang, text)
		if(isnull(found))
			result = null
			break
		result += found
	if(result)
		on_done.InvokeAsync(result)
		return
	var/api_key = trim(CONFIG_GET(string/deepl_api_key))
	if(!api_key)
		on_done.InvokeAsync(null)
		return
	var/key = "[source_lang]>[target_lang]|[json_encode(texts)]"
	var/datum/translation_job/job = pending[key]
	if(job)
		job.callbacks += on_done
		return
	if(length(pending) >= TRANSLATION_MAX_PENDING)
		on_done.InvokeAsync(null)
		return
	job = new
	job.texts = texts.Copy()
	job.source_lang = source_lang
	job.target_lang = target_lang
	job.callbacks += on_done
	job.started = world.time
	// Formatowanie mowy (+pogrubienie+, _podkreślenie_, |kursywa|) idzie jako znaczniki HTML, żeby DeepL go nie zjadł ani nie przetłumaczył
	var/list/sent = job.texts
	for(var/text in job.texts)
		if(aq_has_emphasis(text))
			job.html = TRUE
			break
	if(job.html)
		sent = list()
		for(var/text in job.texts)
			sent += aq_mask_emphasis(text)
	var/list/body = list(
		"text" = sent,
		"source_lang" = source_lang,
		"target_lang" = target_lang == DEEPL_LANG_EN ? DEEPL_LANG_EN_TARGET : target_lang,
	)
	if(job.html)
		body["tag_handling"] = "html"
	job.request = new
	job.request.prepare(RUSTG_HTTP_METHOD_POST, deepl_url(api_key), json_encode(body), list(
		"Authorization" = "DeepL-Auth-Key [api_key]",
		"Content-Type" = "application/json",
	))
	job.request.begin_async()
	pending[key] = job
	can_fire = TRUE

/datum/controller/subsystem/translation/proc/deepl_url(api_key)
	if(copytext(api_key, -3) == ":fx")
		return "https://api-free.deepl.com/v2/translate"
	return "https://api.deepl.com/v2/translate"

/datum/controller/subsystem/translation/fire(resumed)
	for(var/key in pending.Copy())
		var/datum/translation_job/job = pending[key]
		var/list/translations
		if(job.request.is_complete())
			translations = read_response(job)
		else if(world.time < job.started + TRANSLATION_TIMEOUT)
			continue
		else
			log_api_error("brak odpowiedzi po [TRANSLATION_TIMEOUT / 10] s")
			late += job
		pending -= key
		for(var/datum/callback/on_done as anything in job.callbacks)
			on_done.InvokeAsync(translations)
		if(MC_TICK_CHECK)
			return
	for(var/datum/translation_job/job as anything in late.Copy())
		if(job.request.is_complete())
			read_response(job)
			late -= job
		else if(world.time > job.started + TRANSLATION_LATE_GIVE_UP)
			late -= job
	if(!length(pending) && !length(late))
		can_fire = FALSE

/// Lista tłumaczeń z odpowiedzi DeepL albo null. Zapamiętuje oba kierunki: obcokrajowiec słyszy własne zdanie w oryginale.
/datum/controller/subsystem/translation/proc/read_response(datum/translation_job/job)
	var/datum/http_response/response = job.request.into_response()
	if(response.errored || response.status_code != 200)
		// 456 = wyczerpany limit znaków, 403 = zły klucz, 429 = za dużo zapytań
		log_api_error("[response.status_code] [response.errored ? response.error : response.body]")
		return null
	var/list/data
	try
		data = json_decode(response.body)
	catch
		data = null
	var/list/items = islist(data) ? data["translations"] : null
	if(!islist(items) || length(items) != length(job.texts))
		log_api_error("nieoczekiwana odpowiedź: [response.body]")
		return null
	. = list()
	for(var/index in 1 to length(items))
		var/list/item = items[index]
		var/translated = islist(item) ? item["text"] : null
		if(!istext(translated))
			log_api_error("nieoczekiwana odpowiedź: [response.body]")
			return null
		if(job.html)
			translated = aq_unmask_emphasis(translated)
		. += translated
		cache_set(job.source_lang, job.target_lang, job.texts[index], translated)
		cache_set(job.target_lang, job.source_lang, translated, job.texts[index])
		// słuchacz dostaje zdanie po treat_message_min() (wielka litera, kropka), więc ta forma też wraca do oryginału
		var/spoken = aq_spoken_form(translated)
		if(spoken != translated)
			cache_set(job.target_lang, job.source_lang, spoken, job.texts[index])

/// Zdanie w formie, w jakiej wychodzi z say(): jak /mob/proc/treat_message_min() (kropka na końcu, wielka litera)
/proc/aq_spoken_form(text)
	if(!length(text))
		return text
	if(!(copytext(text, length(text)) in list("!", ".", "?", ":", "\"", "-", "~")))
		text += "."
	return capitalize(text)

/// Tekst ma znaczniki formatowania mowy, które say_emphasis() zamienia na pogrubienie, podkreślenie i kursywę
/proc/aq_has_emphasis(text)
	return aq_mask_emphasis(text) != html_encode(text)

/**
 * Tekst dla DeepL z tag_handling=html: zakodowany HTML, a znaczniki +x+ _x_ |x| jako <b>, <u>, <i> (te same wzorce co say_emphasis()).
 * DeepL tłumaczy środek znacznika i zostawia sam znacznik, a aq_unmask_emphasis() odwraca to po odpowiedzi.
 */
/proc/aq_mask_emphasis(text)
	var/static/regex/italics = regex("(?<!\\\\)\\|(.+?)(?<!\\\\)\\|", "g")
	var/static/regex/bold = regex("(?<!\\\\)\\+(.+?)(?<!\\\\)\\+", "g")
	var/static/regex/underline = regex("(?<!\\\\)_(.+?)(?<!\\\\)_", "g")
	text = html_encode(text)
	text = italics.Replace_char(text, "<i>$1</i>")
	text = bold.Replace_char(text, "<b>$1</b>")
	text = underline.Replace_char(text, "<u>$1</u>")
	return text

/// Odpowiedź DeepL w HTML z powrotem jako zwykły tekst ze znacznikami formatowania mowy
/proc/aq_unmask_emphasis(text)
	var/static/regex/italics = regex("<i>(.*?)</i>", "gi")
	var/static/regex/bold = regex("<b>(.*?)</b>", "gi")
	var/static/regex/underline = regex("<u>(.*?)</u>", "gi")
	text = italics.Replace_char(text, "|$1|")
	text = bold.Replace_char(text, "+$1+")
	text = underline.Replace_char(text, "_$1_")
	return html_decode(text)

/datum/controller/subsystem/translation/proc/log_api_error(text)
	if(world.time < last_error_log + 1 MINUTES)
		return
	last_error_log = world.time
	log_world("Tłumacz DeepL: [text]")

#undef TRANSLATION_MAX_PENDING
#undef TRANSLATION_TIMEOUT
#undef TRANSLATION_CACHE_SIZE
#undef TRANSLATION_LATE_GIVE_UP
