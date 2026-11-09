// Czat głosowy: gracz trzyma klawisz, mówi do mikrofonu, a postać wypowiada rozpoznany tekst.
// Mikrofon trzyma strona w zwykłej przeglądarce gracza (BYOND 516 odrzuca prośbę o mikrofon w swoich oknach),
// a rozpoznawaniem mowy zajmuje się serwis z tools/voice_chat (Whisper). Ten podsystem rozmawia z serwisem
// jednym zapytaniem /api/sync naraz: wysyła listę sesji i polecenia start/stop, odbiera rozpoznany tekst.

#define COMSIG_KB_CLIENT_VOICE_SAY_DOWN "keybinding_client_voice_say_down"
#define COMSIG_KB_CLIENT_VOICE_RADIO_DOWN "keybinding_client_voice_radio_down"
#define COMSIG_KB_CLIENT_VOICE_DEPARTMENT_DOWN "keybinding_client_voice_department_down"

#define VOICE_CHANNEL_SAY "say"
#define VOICE_CHANNEL_RADIO "radio"
#define VOICE_CHANNEL_DEPARTMENT "department"
/// Plik z tokenami graczy, żeby otwarta strona działała też w następnej rundzie.
#define VOICE_CHAT_TOKENS_FILE "data/voice_chat_tokens.json"
/// Token nieużywany tyle czasu (w dziesiątych sekundy world.realtime) wygasa.
#define VOICE_CHAT_TOKEN_LIFETIME (30 * 24 * 60 * 60 * 10)
/// Jak długo czekamy na tekst po puszczeniu klawisza.
#define VOICE_CHAT_RESULT_TIMEOUT (15 SECONDS)
/// Jak często pytamy serwis, gdy nikt nie mówi (stan połączenia strony).
#define VOICE_CHAT_IDLE_SYNC (1 SECONDS)
/// Krótsze wciśnięcie klawisza traktujemy jak przypadkowe.
#define VOICE_CHAT_MIN_PRESS (0.3 SECONDS)
/// Tyle nieudanych /api/sync z rzędu, zanim uznamy strony graczy za rozłączone (jeden błąd to zwykle restart serwisu).
#define VOICE_CHAT_FAILS_TO_DISCONNECT 3
/// Najwięcej poleceń trzymanych do ponownego wysłania, gdy serwis nie odpowiada.
#define VOICE_CHAT_MAX_QUEUED_CMDS 200
/// Klawisz mówienia bez połączenia otwiera stronę najwyżej raz na tyle czasu.
#define VOICE_CHAT_AUTO_OPEN_COOLDOWN (60 SECONDS)
/// Podpowiedź „otwórz stronę” najwyżej raz na tyle czasu.
#define VOICE_CHAT_HINT_COOLDOWN (10 SECONDS)
/// Strona otwarta tak niedawno jeszcze się łączy, więc nie zmieniamy jej tokenu.
#define VOICE_CHAT_REOPEN_GRACE (30 SECONDS)

/datum/config_entry/flag/voice_chat_enabled

/// Adres serwisu widziany przez serwer gry.
/datum/config_entry/string/voice_chat_service_url
	config_entry_value = "http://127.0.0.1:8179"

/// Adres strony widziany przez gracza (na teście lokalnym ten sam komputer).
/datum/config_entry/string/voice_chat_public_url
	config_entry_value = "http://localhost:8179"

// Adres wklejony z przeglądarki zwykle kończy się ukośnikiem, a doklejamy do niego ścieżkę.
/datum/config_entry/string/voice_chat_service_url/ValidateAndSet(str_val)
	return ..(trim_voice_chat_url(str_val))

/datum/config_entry/string/voice_chat_public_url/ValidateAndSet(str_val)
	return ..(trim_voice_chat_url(str_val))

/proc/trim_voice_chat_url(url)
	var/static/regex/trailing_slashes = regex(@"/+$")
	return trailing_slashes.Replace(trim(url), "")

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
	/// world.realtime ostatniego połączenia strony (stare tokeny wygasają).
	var/last_used
	/// world.time ostatniego otwarcia strony w tej rundzie.
	var/opened_at

// Tokeny graczy i polecenie nagrywania nie mogą być dostępne przez VV ani Advanced ProcCall:
// token pozwala mówić za postać, a wywołanie start_recording() włączyłoby graczowi mikrofon bez wciśnięcia klawisza.
GENERAL_PROTECT_DATUM(/datum/voice_chat_session)

/datum/voice_chat_session/New(ckey, token, last_used)
	src.ckey = ckey
	src.token = token
	src.last_used = isnull(last_used) ? world.realtime : last_used

GENERAL_PROTECT_DATUM(/datum/controller/subsystem/voice_chat)

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
	/// Polecenia wysłane w trwającym /api/sync (wracają do kolejki, gdy zapytanie się nie uda).
	var/list/in_flight_cmds
	var/datum/http_request/sync_request
	var/next_idle_sync = 0
	var/last_seq = 0
	/// Ile /api/sync z rzędu się nie udało.
	var/failed_syncs = 0
	/// VOICE_CHAT_ENABLED z configu (osobno od can_fire, żeby test mógł sprawdzić logikę bez łączenia z serwisem).
	var/enabled = FALSE
	/// ckey -> world.time ostatniego otwarcia strony klawiszem mówienia
	var/list/last_auto_open = list()
	/// ckey -> world.time ostatniej podpowiedzi o niepołączonej stronie
	var/list/last_hint = list()

/datum/controller/subsystem/voice_chat/Initialize(start_timeofday)
	enabled = CONFIG_GET(flag/voice_chat_enabled)
	if(!enabled)
		can_fire = FALSE
		return ..()
	load_tokens()
	// Klienci podłączeni przed startem podsystemu nie dostali komendy w /client/New()
	for(var/client/player as anything in GLOB.clients)
		player.add_verb(/client/proc/voice_chat)
	return ..()

/datum/controller/subsystem/voice_chat/fire(resumed)
	if(sync_request)
		if(!sync_request.is_complete())
			return
		handle_sync_response(sync_request.into_response())
		sync_request = null
	check_timeouts()
	var/list/session_map = online_session_map()
	if(!length(session_map) && !length(pending_cmds))
		return
	if(!length(pending_cmds) && !anyone_awaiting() && world.time < next_idle_sync)
		return
	send_sync(session_map)

/// token -> ckey dla graczy, którzy są teraz na serwerze. Strona gracza spoza serwera dostaje „koniec sesji” i czeka.
/datum/controller/subsystem/voice_chat/proc/online_session_map()
	var/list/session_map = list()
	for(var/ckey in sessions)
		if(!GLOB.directory[ckey])
			continue
		var/datum/voice_chat_session/session = sessions[ckey]
		session_map[session.token] = ckey
	return session_map

/datum/controller/subsystem/voice_chat/proc/anyone_awaiting()
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		if(session.recording_seq || length(session.awaiting))
			return TRUE
	return FALSE

/datum/controller/subsystem/voice_chat/proc/send_sync(list/session_map)
	in_flight_cmds = pending_cmds
	pending_cmds = list()
	var/list/payload = list("sessions" = session_map, "cmds" = in_flight_cmds)
	next_idle_sync = world.time + VOICE_CHAT_IDLE_SYNC
	sync_request = new
	sync_request.prepare(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/voice_chat_service_url)]/api/sync", json_encode(payload), list(
		"Content-Type" = "application/json",
		// Skrót, nie sam sekret: nagłówek HTTP przyjmuje tylko ASCII, a sekret może mieć polskie litery.
		"X-Voice-Secret" = rustg_hash_string(RUSTG_HASH_SHA256, CONFIG_GET(string/voice_chat_secret)),
	))
	sync_request.begin_async()

/datum/controller/subsystem/voice_chat/proc/handle_sync_response(datum/http_response/response)
	if(response.errored || response.status_code != 200)
		// Polecenia mogły nie dojść: wracają na początek kolejki, a strony uznajemy za rozłączone dopiero po kilku błędach.
		if(length(in_flight_cmds))
			pending_cmds = in_flight_cmds + pending_cmds
			if(length(pending_cmds) > VOICE_CHAT_MAX_QUEUED_CMDS)
				pending_cmds.Cut(1, length(pending_cmds) - VOICE_CHAT_MAX_QUEUED_CMDS + 1)
		in_flight_cmds = null
		failed_syncs++
		if(failed_syncs == 1)
			log_world("Czat głosowy: serwis nie odpowiada ([response.errored ? response.error : response.status_code]).")
		if(failed_syncs >= VOICE_CHAT_FAILS_TO_DISCONNECT)
			for(var/ckey in sessions)
				set_connected(sessions[ckey], FALSE)
		return
	in_flight_cmds = null
	failed_syncs = 0
	var/list/data = json_decode(response.body)
	var/list/status = data["status"]
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		var/list/session_status = status?[session.token]
		set_connected(session, session_status?["connected"] ? TRUE : FALSE)
		if(session_status?["replaced"])
			var/client/player = GLOB.directory[ckey]
			if(player)
				to_chat(player, span_warning("Strona czatu głosowego została otwarta w innej karcie i przejęła mikrofon. Jeśli to nie ty, kliknij „Czat głosowy” w zakładce OOC: nowy link unieważni stary."))
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
	player?.escape_menu?.send_voice_chat_state() // dymek przycisku w menu pod Esc
	if(connected)
		session.last_used = world.realtime
		save_tokens()
		if(player)
			to_chat(player, span_notice("Czat głosowy połączony. Trzymaj [key_for(player, "voice_say")], żeby mówić, [key_for(player, "voice_radio")], żeby mówić przez radio, albo [key_for(player, "voice_department")], żeby mówić na kanale działu."))
		return
	if(session.recording_seq)
		cancel_recording(player, session)
	if(player)
		to_chat(player, span_warning("Czat głosowy rozłączony. Kliknij „Czat głosowy” w menu pod Esc (albo w zakładce OOC), żeby otworzyć stronę ponownie."))

/datum/controller/subsystem/voice_chat/proc/handle_result(list/result)
	var/datum/voice_chat_session/session = session_by_token(result["token"])
	if(!session)
		return
	var/seq = result["seq"]
	var/client/player = GLOB.directory[session.ckey]
	if("[seq]" in session.awaiting)
		session.awaiting -= "[seq]"
	else if(session.recording_seq && session.recording_seq == seq)
		// Strona sama skończyła nagranie po VOICE_CHAT_MAX_SECONDS, zanim doszło puszczenie klawisza.
		session.recording_seq = null
		player?.mob?.remove_typing_indicator()
	else
		return
	if(!player?.mob)
		return
	var/text = result["text"]
	if(!text)
		to_chat(player, span_notice("Czat głosowy: [result["error"] || "nie rozpoznano mowy"]."))
		return
	player.mob.say_verb(speech_text(result["channel"], text))

/// Tekst do say() z przedrostkiem kanału: radio jak „;”, kanał działu jak „:h”.
/datum/controller/subsystem/voice_chat/proc/speech_text(channel, text)
	switch(channel)
		if(VOICE_CHANNEL_RADIO)
			return "[RADIO_KEY_COMMON][text]"
		if(VOICE_CHANNEL_DEPARTMENT)
			return "[GLOB.department_radio_prefixes[1]][MODE_KEY_DEPARTMENT] [text]"
	return text

/datum/controller/subsystem/voice_chat/proc/check_timeouts()
	var/max_recording = CONFIG_GET(number/voice_chat_max_seconds) SECONDS
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		var/client/player = GLOB.directory[ckey]
		if(session.recording_seq)
			if(!player)
				// Gracz wyszedł z klawiszem wciśniętym: strona nie może nagrywać dalej.
				cancel_recording(null, session)
			else if(world.time - session.recording_started > max_recording + 1 SECONDS)
				// Puszczenie klawisza mogło nie dojść (np. Alt+Tab z wciśniętym klawiszem).
				stop_recording(player)
		for(var/seq in session.awaiting)
			if(world.time - session.awaiting[seq] < VOICE_CHAT_RESULT_TIMEOUT)
				continue
			session.awaiting -= seq
			if(player)
				to_chat(player, span_warning("Czat głosowy: strona nie przysłała nagrania. Sprawdź, czy karta jest otwarta."))

/// Wciśnięcie klawisza mówienia.
/datum/controller/subsystem/voice_chat/proc/start_recording(client/player, channel)
	if(!enabled)
		to_chat(player, span_warning("Czat głosowy jest wyłączony na tym serwerze."))
		return
	var/datum/voice_chat_session/session = sessions[player.ckey]
	if(!session?.connected)
		not_connected(player, session)
		return
	if(session.recording_seq)
		return
	session.recording_seq = ++last_seq
	session.recording_channel = channel
	session.recording_started = world.time
	pending_cmds += list(list("token" = session.token, "cmd" = "start", "seq" = session.recording_seq, "channel" = channel, "max" = CONFIG_GET(number/voice_chat_max_seconds)))
	player.mob?.create_typing_indicator(TRUE) // TRUE: bez otwartego okna mówienia

/// Klawisz mówienia bez połączonej strony. Stronę otwieramy tylko temu, kto już kiedyś z niej korzystał,
/// i nie częściej niż raz na minutę, żeby przypadkowe wciśnięcia (pisanie z kursorem na mapie) nie otwierały kart.
/datum/controller/subsystem/voice_chat/proc/not_connected(client/player, datum/voice_chat_session/session)
	var/last_open = last_auto_open[player.ckey]
	if(session && (isnull(last_open) || world.time - last_open >= VOICE_CHAT_AUTO_OPEN_COOLDOWN))
		last_auto_open[player.ckey] = world.time
		to_chat(player, span_notice("Czat głosowy nie jest połączony. Otwieram stronę w przeglądarce…"))
		open_page(player)
		return
	var/hinted = last_hint[player.ckey]
	if(!isnull(hinted) && world.time - hinted < VOICE_CHAT_HINT_COOLDOWN)
		return
	last_hint[player.ckey] = world.time
	to_chat(player, span_notice("Czat głosowy nie jest połączony. Otwórz stronę komendą „Czat głosowy” w zakładce OOC."))

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

/// player może być null (gracz wyszedł z gry w trakcie nagrania).
/datum/controller/subsystem/voice_chat/proc/cancel_recording(client/player, datum/voice_chat_session/session)
	pending_cmds += list(list("token" = session.token, "cmd" = "cancel", "seq" = session.recording_seq))
	session.recording_seq = null
	player?.mob?.remove_typing_indicator()

/datum/controller/subsystem/voice_chat/proc/new_token(ckey)
	return md5("[rand(1, 999999999)]-[rand(1, 999999999)]-[rand(1, 999999999)]-[world.realtime]-[REALTIMEOFDAY]-[world.cpu]-[ckey]")

/// Zakłada sesję (albo bierze istniejącą) i otwiera graczowi stronę z mikrofonem.
/// Każde otwarcie daje nowy token, więc stary link (np. pokazany na streamie) przestaje działać.
/datum/controller/subsystem/voice_chat/proc/open_page(client/player)
	if(!enabled)
		to_chat(player, span_warning("Czat głosowy jest wyłączony na tym serwerze."))
		return
	var/datum/voice_chat_session/session = sessions[player.ckey]
	if(!session)
		session = new(player.ckey, new_token(player.ckey))
		sessions[player.ckey] = session
		save_tokens()
		next_idle_sync = 0
	else if(isnull(session.opened_at) || world.time - session.opened_at >= VOICE_CHAT_REOPEN_GRACE)
		// Nowy link przy każdym otwarciu (poza świeżo otwartą stroną, która jeszcze się łączy).
		// Stara karta dostaje koniec sesji, także cudza, otwarta z wykradzionego linku.
		if(session.recording_seq)
			cancel_recording(player, session)
		session.token = new_token(player.ckey)
		session.connected = FALSE
		session.awaiting = list()
		session.last_used = world.realtime
		save_tokens()
		next_idle_sync = 0
	session.opened_at = world.time
	var/url = "[CONFIG_GET(string/voice_chat_public_url)]/?t=[session.token]"
	player << link(url)
	// Sam adres zawiera token, więc w czacie jest tylko klikalne słowo (zrzut ekranu ani stream go nie zdradzą).
	to_chat(player, span_notice("Otwieram stronę czatu głosowego w przeglądarce. Zezwól na mikrofon, zostaw kartę otwartą i wróć do gry. Jeśli nic się nie otworzyło, kliknij <a href='[url]'>ten link</a>. Nie pokazuj go nikomu: kto go ma, może mówić za twoją postać."))

/datum/controller/subsystem/voice_chat/proc/key_for(client/player, keybind_name)
	for(var/bound_key in player.prefs?.key_bindings)
		if(keybind_name in player.prefs.key_bindings[bound_key])
			return bound_key
	return "(klawisz nieprzypisany, ustaw go w Preferencjach)"

/datum/controller/subsystem/voice_chat/proc/load_tokens()
	if(!fexists(VOICE_CHAT_TOKENS_FILE))
		return
	var/list/saved = json_decode(rustg_file_read(VOICE_CHAT_TOKENS_FILE))
	if(!islist(saved))
		return
	var/expired = FALSE
	for(var/ckey in saved)
		var/entry = saved[ckey]
		var/token
		var/last_used
		if(islist(entry))
			token = entry["token"]
			last_used = entry["used"]
		else
			token = entry // stary zapis: ckey -> token
		if(!istext(token) || (isnum(last_used) && world.realtime - last_used > VOICE_CHAT_TOKEN_LIFETIME))
			expired = TRUE
			continue
		sessions[ckey] = new /datum/voice_chat_session(ckey, token, isnum(last_used) ? last_used : null)
	if(expired)
		save_tokens()

/datum/controller/subsystem/voice_chat/proc/save_tokens()
	var/list/saved = list()
	for(var/ckey in sessions)
		var/datum/voice_chat_session/session = sessions[ckey]
		saved[ckey] = list("token" = session.token, "used" = session.last_used)
	rustg_file_write(json_encode(saved), VOICE_CHAT_TOKENS_FILE)

/// Komenda OOC. Gracz dostaje ją tylko wtedy, gdy czat głosowy jest włączony w configu.
/client/proc/voice_chat()
	set name = "Czat głosowy"
	set category = "OOC"
	set desc = "Otwiera w przeglądarce stronę, przez którą mówisz do mikrofonu."
	SSvoice_chat.open_page(src)

/client/New(TopicData)
	. = ..()
	if(!QDELETED(src) && SSvoice_chat?.enabled)
		add_verb(/client/proc/voice_chat)

/// Klawisze mówienia głosem. Przy wyłączonym czacie nie działają wcale (wciśnięcie idzie do innych bindów).
/datum/keybinding/client/voice
	/// Działa też z wciśniętym Shiftem (sprint), Ctrl albo Alt.
	any_modifier = TRUE
	/// Kanał przekazywany do SSvoice_chat.start_recording()
	var/voice_channel

GENERAL_PROTECT_DATUM(/datum/keybinding/client/voice)

/datum/keybinding/client/voice/can_use(client/user)
	return SSvoice_chat.enabled

/datum/keybinding/client/voice/down(client/user)
	. = ..()
	if(.)
		return
	// Nagranie tylko przy fizycznie wciśniętym klawiszu (keyDown wpisuje go do keys_held przed bindami),
	// nie z wywołania down() z innego miejsca
	if(!key_is_held(user))
		return
	SSvoice_chat.start_recording(user, voice_channel)
	return TRUE

/// Któryś klawisz przypisany do tego bindu jest teraz wciśnięty przez gracza
/datum/keybinding/client/voice/proc/key_is_held(client/user)
	var/list/held = user.keys_held
	for(var/bound_key in user.prefs?.key_bindings)
		if(!(name in user.prefs.key_bindings[bound_key]))
			continue
		// „Shift-N”: w keys_held jest sam klawisz bez modyfikatora
		var/list/parts = splittext(bound_key, "-")
		if(held?[parts[length(parts)]])
			return TRUE
	return FALSE

/datum/keybinding/client/voice/up(client/user)
	SSvoice_chat.stop_recording(user)
	return TRUE

/datum/keybinding/client/voice/say
	key = "N"
	name = "voice_say"
	full_name = "Mów głosem"
	description = "Trzymaj i mów do mikrofonu. Wymaga otwartej strony czatu głosowego (OOC → Czat głosowy)."
	keybind_signal = COMSIG_KB_CLIENT_VOICE_SAY_DOWN
	voice_channel = VOICE_CHANNEL_SAY

/datum/keybinding/client/voice/radio
	key = "U"
	name = "voice_radio"
	full_name = "Mów głosem przez radio"
	description = "Trzymaj i mów do mikrofonu, postać powie to przez słuchawki (kanał ogólny, jak ;)."
	keybind_signal = COMSIG_KB_CLIENT_VOICE_RADIO_DOWN
	voice_channel = VOICE_CHANNEL_RADIO

/datum/keybinding/client/voice/department
	key = "J"
	name = "voice_department"
	full_name = "Mów głosem na kanale działu"
	description = "Trzymaj i mów do mikrofonu, postać powie to na kanale swojego działu (jak :h)."
	keybind_signal = COMSIG_KB_CLIENT_VOICE_DEPARTMENT_DOWN
	voice_channel = VOICE_CHANNEL_DEPARTMENT

// Zapisane keybindy nie dostają nowych skrótów same. Klawisze głosu dopisujemy raz, jeśli są wolne.
/datum/preferences/load_from_database()
	. = ..()
	offer_default_keybind("voice_say", "N")
	offer_default_keybind("voice_radio", "U")
	offer_default_keybind("voice_department", "J")

// Menu pod Esc: przycisk „Czat głosowy”, gdy serwer ma go włączony (wzór: przełącznik języka w i18n/language_choice.dm)
/datum/escape_menu/New(client/client)
	. = ..()
	send_voice_chat_state()

/datum/escape_menu/proc/send_voice_chat_state()
	if(!client || !window)
		return
	var/datum/voice_chat_session/session = SSvoice_chat.sessions[client.ckey]
	send_update(list("voiceChat" = !!SSvoice_chat.enabled, "voiceChatConnected" = !!session?.connected))

/datum/escape_menu/on_message(type, payload, href_list)
	if(type == "action" && islist(payload) && client && payload["action"] == "voice_chat")
		SSvoice_chat.open_page(client)
		return TRUE
	. = ..()
	// Przy każdym otwarciu: menu powstaje raz na sesję, często zanim SSvoice_chat wczyta konfigurację (enabled)
	if(type == "ready" || (type == "action" && islist(payload) && payload["action"] == "opened"))
		send_voice_chat_state()

#undef VOICE_CHANNEL_SAY
#undef VOICE_CHANNEL_RADIO
#undef VOICE_CHANNEL_DEPARTMENT
#undef VOICE_CHAT_TOKENS_FILE
#undef VOICE_CHAT_TOKEN_LIFETIME
#undef VOICE_CHAT_RESULT_TIMEOUT
#undef VOICE_CHAT_IDLE_SYNC
#undef VOICE_CHAT_MIN_PRESS
#undef VOICE_CHAT_FAILS_TO_DISCONNECT
#undef VOICE_CHAT_MAX_QUEUED_CMDS
#undef VOICE_CHAT_AUTO_OPEN_COOLDOWN
#undef VOICE_CHAT_HINT_COOLDOWN
#undef VOICE_CHAT_REOPEN_GRACE
