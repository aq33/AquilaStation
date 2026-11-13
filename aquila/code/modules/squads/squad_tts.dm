// Głos rozkazów drużyny przez ElevenLabs (config/squad_tts.txt). Jeden plik MP3 na rozkaz, grany
// członkom drużyny z pagerem, którzy nie wyłączyli „Głosu rozkazów” w preferencjach.
// Bez klucza albo przy błędzie rozkaz idzie bez głosu.

/datum/config_entry/flag/squad_tts_enabled

/datum/config_entry/string/squad_tts_api_key
	protection = CONFIG_ENTRY_HIDDEN | CONFIG_ENTRY_LOCKED

/datum/config_entry/string/squad_tts_endpoint
	config_entry_value = "https://api.elevenlabs.io"
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/squad_tts_model
	config_entry_value = "eleven_flash_v2_5"

/// Głosy męskie (identyfikatory głosów ElevenLabs), po jednym na linię
/datum/config_entry/str_list/squad_tts_voice_male

/// Głosy żeńskie
/datum/config_entry/str_list/squad_tts_voice_female

/// Ile znaków na rundę wolno wysłać do ElevenLabs łącznie (wszyscy nadawcy); 0 = bez limitu
/datum/config_entry/number/squad_tts_round_char_limit
	config_entry_value = 6000
	min_val = 0

/// Ile znaków poszło już w tej rundzie do ElevenLabs
GLOBAL_VAR_INIT(squad_tts_chars_used, 0)

/datum/config_entry/number/squad_tts_timeout
	config_entry_value = 15
	min_val = 3
	max_val = 60

/// Gotowe głosy ElevenLabs, gdy config nie podaje własnych (model wielojęzyczny mówi nimi po polsku)
GLOBAL_LIST_INIT(squad_tts_default_male, list("pNInz6obpgDQGcFmaJgB", "TxGEqnHWrfWFTfGW9XjX", "ErXwobaYiN019PkySvjV", "VR6AewLTigWG4xSOukaG"))
GLOBAL_LIST_INIT(squad_tts_default_female, list("21m00Tcm4TlvDq8ikWAM", "EXAVITQu4vr4xnSDxMaL", "AZnzlk1XvdvUeBnXmlld"))

/datum/preferences
	/// Czy słyszeć głos rozkazów drużyny
	var/squad_tts = TRUE

/proc/squad_tts_active()
	return CONFIG_GET(flag/squad_tts_enabled) && length(CONFIG_GET(string/squad_tts_api_key))

/// Głos postaci: stały dla imienia, z puli według płci
/proc/squad_tts_voice_for(mob/living/speaker)
	var/list/pool
	if(speaker.gender == FEMALE)
		pool = CONFIG_GET(str_list/squad_tts_voice_female)
		if(!length(pool))
			pool = GLOB.squad_tts_default_female
	else
		pool = CONFIG_GET(str_list/squad_tts_voice_male)
		if(!length(pool))
			pool = GLOB.squad_tts_default_male
	var/hash = md5(speaker.real_name)
	var/index = (hex2num(copytext(hash, 1, 5)) % length(pool)) + 1
	return pool[index]

/proc/aq_squad_tts_speak(mob/living/speaker, message, list/listeners)
	if(!squad_tts_active() || !speaker || !length(message) || !length(listeners))
		return FALSE
	var/list/wanting = list()
	for(var/mob/listener as anything in listeners)
		if(listener.client?.prefs?.squad_tts)
			wanting += listener
	if(!length(wanting))
		return FALSE
	if(!squad_tts_reserve_chars(message))
		return FALSE
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(aq_squad_tts_request), squad_tts_voice_for(speaker), message, wanting)
	return TRUE

/// Wspólny budżet rundy (drużyny i SI): cooldown na nadawcę nie ogranicza sumy płatnych zapytań
/proc/squad_tts_reserve_chars(message)
	var/chars = length_char(message)
	var/char_limit = CONFIG_GET(number/squad_tts_round_char_limit)
	if(char_limit && GLOB.squad_tts_chars_used + chars > char_limit)
		return FALSE
	GLOB.squad_tts_chars_used += chars
	return TRUE

/// Zwraca znaki zarezerwowane na zapytanie, które nie dało dźwięku
/proc/squad_tts_release_chars(message)
	GLOB.squad_tts_chars_used = max(0, GLOB.squad_tts_chars_used - length_char(message))

/// channel: gdy podany, dźwięk idzie bez pozycji na tym kanale (jak VOX), inaczej przez playsound_local
/proc/aq_squad_tts_request(voice, message, list/listeners, channel)
	// rust_g zapisuje odpowiedź tylko do istniejącego folderu
	if(!fexists("tmp/squad_tts/.keep"))
		rustg_file_write("", "tmp/squad_tts/.keep")
	var/file_name = "tmp/squad_tts/[md5("[voice]|[message]|[world.time]")].mp3"
	var/list/headers = list(
		"xi-api-key" = CONFIG_GET(string/squad_tts_api_key),
		"Content-Type" = "application/json",
		"Accept" = "audio/mpeg",
	)
	var/list/payload = list(
		"text" = message,
		"model_id" = CONFIG_GET(string/squad_tts_model),
		"language_code" = "pl",
	)
	var/datum/http_request/request = new
	request.prepare(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/squad_tts_endpoint)]/v1/text-to-speech/[voice]?output_format=mp3_44100_64", json_encode(payload), headers, file_name)
	request.begin_async()
	var/deadline = world.time + CONFIG_GET(number/squad_tts_timeout) SECONDS
	UNTIL(request.is_complete() || world.time > deadline)
	if(!request.is_complete())
		log_runtime("squad_tts: ElevenLabs request timed out")
		return FALSE
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200 || !fexists(file_name))
		log_runtime("squad_tts: ElevenLabs error [response.status_code] [response.error]")
		if(fexists(file_name))
			fdel(file_name)
		return FALSE
	var/voice_file = file(file_name)
	for(var/mob/listener as anything in listeners)
		if(QDELETED(listener) || !listener.client)
			continue
		if(channel)
			// ogłoszenie: słuchacz mógł ogłuchnąć albo wyłączyć ogłoszenia w trakcie syntezy
			if(listener.can_hear() && (listener.client.prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS))
				SEND_SOUND(listener, sound(voice_file, channel = channel))
			continue
		listener.playsound_local(get_turf(listener), null, 80, FALSE, S = sound(voice_file))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aq_squad_tts_cleanup), file_name), 2 MINUTES)
	return TRUE

/proc/aq_squad_tts_cleanup(file_name)
	if(fexists(file_name))
		fdel(file_name)

/datum/preference/toggle/player/squad_tts
	db_key = "squad_tts"
	player_var = "squad_tts"
