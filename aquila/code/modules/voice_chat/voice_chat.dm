// Czat głosowy: gracz trzyma klawisz, mówi do mikrofonu, a postać wypowiada rozpoznany tekst.
// Mikrofon trzyma strona w zwykłej przeglądarce gracza (BYOND 516 odrzuca prośbę o mikrofon w swoich oknach),
// a rozpoznawaniem mowy zajmuje się serwis z tools/voice_chat (Whisper). Ten podsystem rozmawia z serwisem
// jednym zapytaniem /api/sync naraz: wysyła listę sesji i polecenia start/stop, odbiera rozpoznany tekst.

#define COMSIG_KB_CLIENT_VOICE_SAY_DOWN "keybinding_client_voice_say_down"
#define COMSIG_KB_CLIENT_VOICE_RADIO_DOWN "keybinding_client_voice_radio_down"

#define VOICE_CHANNEL_SAY "say"
#define VOICE_CHANNEL_RADIO "radio"
/// Plik z tokenami graczy, żeby otwarta strona działała też w następnej rundzie.
#define VOICE_CHAT_TOKENS_FILE "data/voice_chat_tokens.json"
/// Jak długo czekamy na tekst po puszczeniu klawisza.
#define VOICE_CHAT_RESULT_TIMEOUT (15 SECONDS)
/// Jak często pytamy serwis, gdy nikt nie mówi (stan połączenia strony).
#define VOICE_CHAT_IDLE_SYNC (1 SECONDS)
/// Krótsze wciśnięcie klawisza traktujemy jak przypadkowe.
#define VOICE_CHAT_MIN_PRESS (0.3 SECONDS)

/datum/config_entry/flag/voice_chat_enabled

/// Adres serwisu widziany przez serwer gry.
/datum/config_entry/string/voice_chat_service_url
	config_entry_value = "http://127.0.0.1:8179"

/// Adres strony widziany przez gracza (na teście lokalnym ten sam komputer).
/datum/config_entry/string/voice_chat_public_url
	config_entry_value = "http://localhost:8179"

/datum/config_entry/string/voice_chat_secret
	protection = CONFIG_ENTRY_HIDDEN | CONFIG_ENTRY_LOCKED

/datum/config_entry/number/voice_chat_max_seconds
	config_entry_value = 15
	min_val = 3
	max_val = 20

/datum/voice_chat_session
	var/ckey
	var/token
	/// Czy strona gracza jest otwarta i połączona z serwisem.
	var/connected = FALSE
	/// Numer trwającego nagrania (klawisz wciśnięty) albo null.
	var/recording_seq
	var/recording_channel
	var/recording_started
	/// seq -> world.time puszczenia klawisza; czekamy na tekst.
	var/list/awaiting = list()

/datum/voice_chat_session/New(ckey, token)
	src.ckey = ckey
	src.token = token

SUBSYSTEM_DEF(voice_chat)
	name = "Czat głosowy"
	wait = 1
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	init_order = INIT_ORDER_DEFAULT

	/// ckey -> /datum/voice_chat_session
	var/list/sessions = list()
	/// Polecenia czekające na najbliższe /api/sync.
	var/list/pending_cmds = list()
	var/datum/http_request/sync_request
	var/next_idle_sync = 0
	var/last_seq = 0
	/// Czy ostatnie /api/sync się udało (żeby nie spamować logu, gdy serwis leży).
	var/service_up = TRUE

/datum/controller/subsystem/voice_chat/Initialize(start_timeofday)
	if(!CONFIG_GET(flag/voice_chat_enabled))
		can_fire = FALSE
		return ..()
	load_tokens()
	return ..()

/datum/controller/subsystem/voice_chat/fire(resumed)
	if(sync_request)
		if(!sync_request.is_complete())
			return
		handle_sync_response(sync_request.into_response())
		sync_request = null
	check_timeouts()
	if(!length(sessions))
		return
	if(!length(pending_cmds) && !anyone_awaiting() && world.time < next_idle_sync)
		return
	send_sync()

/datum/controller/subsystem/voice_chat/proc/anyone_awaiting()
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		if(session.recording_seq || length(session.awaiting))
			return TRUE
	return FALSE

/datum/controller/subsystem/voice_chat/proc/send_sync()
	var/list/session_map = list()
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		session_map[session.token] = ckey
	var/list/payload = list("sessions" = session_map, "cmds" = pending_cmds)
	pending_cmds = list()
	next_idle_sync = world.time + VOICE_CHAT_IDLE_SYNC
	sync_request = new
	sync_request.prepare(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/voice_chat_service_url)]/api/sync", json_encode(payload), list(
		"Content-Type" = "application/json",
		"X-Voice-Secret" = CONFIG_GET(string/voice_chat_secret),
	))
	sync_request.begin_async()

/datum/controller/subsystem/voice_chat/proc/handle_sync_response(datum/http_response/response)
	if(response.errored || response.status_code != 200)
		if(service_up)
			log_world("Czat głosowy: serwis nie odpowiada ([response.errored ? response.error : response.status_code]).")
		service_up = FALSE
		for(var/ckey in sessions)
			set_connected(sessions[ckey], FALSE)
		return
	service_up = TRUE
	var/list/data = json_decode(response.body)
	var/list/status = data["status"]
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		var/list/session_status = status?[session.token]
		set_connected(session, session_status?["connected"] ? TRUE : FALSE)
	for(var/list/result in data["results"])
		handle_result(result)

/datum/controller/subsystem/voice_chat/proc/session_by_token(token)
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		if(session.token == token)
			return session

/datum/controller/subsystem/voice_chat/proc/set_connected(datum/voice_chat_session/session, connected)
	if(session.connected == connected)
		return
	session.connected = connected
	var/client/player = GLOB.directory[session.ckey]
	if(!player)
		return
	if(connected)
		to_chat(player, span_notice("Czat głosowy połączony. Trzymaj [key_for(player, "voice_say")], żeby mówić, albo [key_for(player, "voice_radio")], żeby mówić przez radio."))
		return
	if(session.recording_seq)
		cancel_recording(player, session)
	to_chat(player, span_warning("Czat głosowy rozłączony. Kliknij „Czat głosowy” w zakładce OOC, żeby otworzyć stronę ponownie."))

/datum/controller/subsystem/voice_chat/proc/handle_result(list/result)
	var/datum/voice_chat_session/session = session_by_token(result["token"])
	if(!session)
		return
	var/seq = result["seq"]
	if(!("[seq]" in session.awaiting))
		return
	session.awaiting -= "[seq]"
	var/client/player = GLOB.directory[session.ckey]
	if(!player?.mob)
		return
	var/text = result["text"]
	if(!text)
		to_chat(player, span_notice("Czat głosowy: [result["error"] || "nie rozpoznano mowy"]."))
		return
	if(result["channel"] == VOICE_CHANNEL_RADIO)
		text = ";[text]"
	player.mob.say_verb(text)

/datum/controller/subsystem/voice_chat/proc/check_timeouts()
	var/max_recording = CONFIG_GET(number/voice_chat_max_seconds) SECONDS
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		var/client/player = GLOB.directory[ckey]
		// Puszczenie klawisza mogło nie dojść (np. Alt+Tab z wciśniętym klawiszem).
		if(session.recording_seq && world.time - session.recording_started > max_recording + 1 SECONDS)
			if(player)
				stop_recording(player)
			else
				session.recording_seq = null
		for(var/seq in session.awaiting)
			if(world.time - session.awaiting[seq] < VOICE_CHAT_RESULT_TIMEOUT)
				continue
			session.awaiting -= seq
			if(player)
				to_chat(player, span_warning("Czat głosowy: strona nie przysłała nagrania. Sprawdź, czy karta jest otwarta."))

/// Wciśnięcie klawisza mówienia.
/datum/controller/subsystem/voice_chat/proc/start_recording(client/player, channel)
	if(!can_fire)
		to_chat(player, span_warning("Czat głosowy jest wyłączony na tym serwerze."))
		return
	var/datum/voice_chat_session/session = sessions[player.ckey]
	if(!session?.connected)
		to_chat(player, span_notice("Czat głosowy nie jest połączony. Otwieram stronę w przeglądarce…"))
		open_page(player)
		return
	if(session.recording_seq)
		return
	session.recording_seq = ++last_seq
	session.recording_channel = channel
	session.recording_started = world.time
	pending_cmds += list(list("token" = session.token, "cmd" = "start", "seq" = session.recording_seq, "channel" = channel, "max" = CONFIG_GET(number/voice_chat_max_seconds)))
	player.mob?.create_typing_indicator(TRUE) // TRUE: bez otwartego okna mówienia

/// Puszczenie klawisza mówienia.
/datum/controller/subsystem/voice_chat/proc/stop_recording(client/player)
	var/datum/voice_chat_session/session = sessions[player.ckey]
	if(!session?.recording_seq)
		return
	// Przypadkowe dotknięcie klawisza: strona i tak doklejałaby początek sprzed wciśnięcia.
	if(world.time - session.recording_started < VOICE_CHAT_MIN_PRESS)
		cancel_recording(player, session)
		return
	pending_cmds += list(list("token" = session.token, "cmd" = "stop", "seq" = session.recording_seq))
	session.awaiting["[session.recording_seq]"] = world.time
	session.recording_seq = null
	player.mob?.remove_typing_indicator()

/datum/controller/subsystem/voice_chat/proc/cancel_recording(client/player, datum/voice_chat_session/session)
	pending_cmds += list(list("token" = session.token, "cmd" = "cancel", "seq" = session.recording_seq))
	session.recording_seq = null
	player.mob?.remove_typing_indicator()

/// Zakłada sesję (albo bierze istniejącą) i otwiera graczowi stronę z mikrofonem.
/datum/controller/subsystem/voice_chat/proc/open_page(client/player)
	if(!can_fire)
		to_chat(player, span_warning("Czat głosowy jest wyłączony na tym serwerze."))
		return
	var/datum/voice_chat_session/session = sessions[player.ckey]
	if(!session)
		session = new(player.ckey, md5("[rand(1, 999999999)]-[rand(1, 999999999)]-[world.realtime]-[REALTIMEOFDAY]-[player.ckey]"))
		sessions[player.ckey] = session
		save_tokens()
		next_idle_sync = 0
	var/url = "[CONFIG_GET(string/voice_chat_public_url)]/?t=[session.token]"
	player << link(url)
	to_chat(player, span_notice("Otwieram stronę czatu głosowego w przeglądarce. Zezwól na mikrofon, zostaw kartę otwartą i wróć do gry. Jeśli nic się nie otworzyło, wejdź na: [url]"))

/datum/controller/subsystem/voice_chat/proc/key_for(client/player, keybind_name)
	for(var/bound_key in player.prefs?.key_bindings)
		if(keybind_name in player.prefs.key_bindings[bound_key])
			return bound_key
	return "(klawisz nieprzypisany, ustaw go w Preferencjach)"

/datum/controller/subsystem/voice_chat/proc/load_tokens()
	if(!fexists(VOICE_CHAT_TOKENS_FILE))
		return
	var/list/saved = json_decode(rustg_file_read(VOICE_CHAT_TOKENS_FILE))
	for(var/ckey in saved)
		sessions[ckey] = new /datum/voice_chat_session(ckey, saved[ckey])

/datum/controller/subsystem/voice_chat/proc/save_tokens()
	var/list/saved = list()
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		saved[ckey] = session.token
	rustg_file_write(json_encode(saved), VOICE_CHAT_TOKENS_FILE)

/client/verb/voice_chat()
	set name = "Czat głosowy"
	set category = "OOC"
	set desc = "Otwiera w przeglądarce stronę, przez którą mówisz do mikrofonu."
	SSvoice_chat.open_page(src)

/datum/keybinding/client/voice_say
	key = "N"
	name = "voice_say"
	full_name = "Mów głosem"
	description = "Trzymaj i mów do mikrofonu. Wymaga otwartej strony czatu głosowego (OOC → Czat głosowy)."
	keybind_signal = COMSIG_KB_CLIENT_VOICE_SAY_DOWN

/datum/keybinding/client/voice_say/down(client/user)
	. = ..()
	if(.)
		return
	SSvoice_chat.start_recording(user, VOICE_CHANNEL_SAY)
	return TRUE

/datum/keybinding/client/voice_say/up(client/user)
	SSvoice_chat.stop_recording(user)
	return TRUE

/datum/keybinding/client/voice_radio
	key = "U"
	name = "voice_radio"
	full_name = "Mów głosem przez radio"
	description = "Trzymaj i mów do mikrofonu, postać powie to przez radio."
	keybind_signal = COMSIG_KB_CLIENT_VOICE_RADIO_DOWN

/datum/keybinding/client/voice_radio/down(client/user)
	. = ..()
	if(.)
		return
	SSvoice_chat.start_recording(user, VOICE_CHANNEL_RADIO)
	return TRUE

/datum/keybinding/client/voice_radio/up(client/user)
	SSvoice_chat.stop_recording(user)
	return TRUE

// Zapisane keybindy nie dostają nowych skrótów same (jak sprint). Dopisujemy klawisze głosu, jeśli są wolne.
/datum/preferences/load_from_database()
	. = ..()
	if(!islist(key_bindings))
		return
	for(var/list/default_bind in list(list("voice_say", "N"), list("voice_radio", "U")))
		var/keybind_name = default_bind[1]
		var/bound = FALSE
		for(var/bound_key in key_bindings)
			var/list/names = key_bindings[bound_key]
			if(islist(names) && (keybind_name in names))
				bound = TRUE
				break
		if(!bound && !length(key_bindings[default_bind[2]]))
			key_bindings[default_bind[2]] = list(keybind_name)

#undef VOICE_CHANNEL_SAY
#undef VOICE_CHANNEL_RADIO
#undef VOICE_CHAT_TOKENS_FILE
#undef VOICE_CHAT_RESULT_TIMEOUT
#undef VOICE_CHAT_IDLE_SYNC
#undef VOICE_CHAT_MIN_PRESS
