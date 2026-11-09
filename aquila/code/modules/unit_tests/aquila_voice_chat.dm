// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Zastępstwo klienta: SSvoice_chat potrzebuje od gracza tylko ckey i moba, bind głosu także klawiszy.
/datum/voice_chat_test_player
	var/ckey = "voicechattest"
	var/mob/mob
	var/list/keys_held = list()
	var/datum/voice_chat_test_prefs/prefs

/datum/voice_chat_test_prefs
	var/list/key_bindings = list("N" = list("voice_say"))

/// AQUILA - czat głosowy: klawisz mówienia steruje nagraniem, a rozpoznany tekst wypowiada postać
/datum/unit_test/aquila_voice_chat
	var/list/heard = list()
	var/datum/voice_chat_test_player/player
	var/old_enabled
	var/list/old_cmds
	var/old_failed

/datum/unit_test/aquila_voice_chat/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	player = new
	player.mob = speaker
	player.prefs = new
	var/datum/voice_chat_session/session = new(player.ckey, "0123456789abcdef0123456789abcdef")
	session.connected = TRUE
	// Bez can_fire: podsystem nie łączy się z serwisem, sprawdzamy samą logikę.
	old_enabled = SSvoice_chat.enabled
	old_cmds = SSvoice_chat.pending_cmds
	SSvoice_chat.enabled = TRUE
	SSvoice_chat.pending_cmds = list()
	SSvoice_chat.sessions[player.ckey] = session
	RegisterSignal(speaker, COMSIG_MOB_SAY, PROC_REF(on_say))

	SSvoice_chat.start_recording(player, "say")
	TEST_ASSERT(session.recording_seq, "Wciśnięcie klawisza nie zaczęło nagrania")
	TEST_ASSERT(speaker.typing_indicator, "Podczas nagrania nie ma dymka nad postacią")
	TEST_ASSERT_EQUAL(last_cmd(), "start", "Do strony nie poszło polecenie nagrywania")

	// Przypadkowe dotknięcie klawisza: nagranie anulowane, nic nie czeka na tekst
	SSvoice_chat.stop_recording(player)
	TEST_ASSERT_EQUAL(last_cmd(), "cancel", "Krótkie wciśnięcie nie anulowało nagrania")
	TEST_ASSERT(!length(session.awaiting), "Po anulowaniu gra dalej czeka na tekst")
	TEST_ASSERT(!speaker.typing_indicator, "Dymek nie zniknął po anulowaniu")

	SSvoice_chat.start_recording(player, "say")
	var/seq = session.recording_seq
	session.recording_started -= 1 SECONDS
	SSvoice_chat.stop_recording(player)
	TEST_ASSERT_EQUAL(last_cmd(), "stop", "Puszczenie klawisza nie zatrzymało nagrania")
	TEST_ASSERT("[seq]" in session.awaiting, "Gra nie czeka na tekst po puszczeniu klawisza")

	GLOB.directory[player.ckey] = player
	SSvoice_chat.handle_result(list("token" = session.token, "seq" = seq, "channel" = "say", "text" = "Halo, tu kapitan"))
	TEST_ASSERT_EQUAL(length(heard), 1, "Postać nie wypowiedziała rozpoznanego tekstu")
	TEST_ASSERT(findtext(heard[1], "Halo, tu kapitan"), "Postać powiedziała coś innego: [heard[1]]")
	TEST_ASSERT(!("[seq]" in session.awaiting), "Wynik nie zdjął nagrania z oczekujących")

	// Ten sam wynik drugi raz (np. powtórzona odpowiedź serwisu) nie może zostać powiedziany ponownie
	SSvoice_chat.handle_result(list("token" = session.token, "seq" = seq, "channel" = "say", "text" = "Halo, tu kapitan"))
	TEST_ASSERT_EQUAL(length(heard), 1, "Ten sam wynik został wypowiedziany dwa razy")

	TEST_ASSERT_EQUAL(SSvoice_chat.speech_text("radio", "Ochrona na mostek"), ";Ochrona na mostek", "Mowa przez radio bez przedrostka kanału")
	TEST_ASSERT_EQUAL(SSvoice_chat.speech_text("say", "Ochrona na mostek"), "Ochrona na mostek", "Zwykła mowa z przedrostkiem")
	TEST_ASSERT_EQUAL(SSvoice_chat.speech_text("department", "Ochrona na mostek"), ":h Ochrona na mostek", "Kanał działu bez przedrostka :h")

	// Przy wyłączonym czacie klawisze głosu nie mogą przechwytywać wciśnięć (np. J/N/U zajęte przez inne bindy)
	var/datum/keybinding/voice_bind = GLOB.keybindings_by_name["voice_department"]
	TEST_ASSERT(voice_bind, "Brak bindu voice_department")
	TEST_ASSERT(voice_bind.can_use(player), "Bind głosu nie działa przy włączonym czacie")
	SSvoice_chat.enabled = FALSE
	TEST_ASSERT(!voice_bind.can_use(player), "Bind głosu działa przy wyłączonym czacie")
	SSvoice_chat.enabled = TRUE
	TEST_ASSERT(voice_bind.any_modifier, "Bind głosu nie działa z wciśniętym Shiftem (sprint)")

	// Bind zaczyna nagranie tylko przy fizycznie wciśniętym klawiszu (np. nie z Advanced ProcCall na down())
	var/datum/keybinding/say_bind = GLOB.keybindings_by_name["voice_say"]
	say_bind.down(player)
	TEST_ASSERT(!session.recording_seq, "Bind głosu włączył nagrywanie bez wciśniętego klawisza")
	player.keys_held["N"] = world.time
	say_bind.down(player)
	TEST_ASSERT(session.recording_seq, "Wciśnięty klawisz nie zaczął nagrania")
	SSvoice_chat.cancel_recording(player, session)
	player.keys_held.Cut()
	// Tokenów i polecenia nagrywania nie da się ruszyć z VV ani Advanced ProcCall
	TEST_ASSERT(!SSvoice_chat.CanProcCall("start_recording"), "Advanced ProcCall może włączyć nagrywanie")
	TEST_ASSERT(!SSvoice_chat.can_vv_get("sessions"), "Tokeny graczy widać w VV")
	TEST_ASSERT(!session.can_vv_get("token"), "Token gracza widać w VV")
	TEST_ASSERT(!say_bind.CanProcCall("down"), "Advanced ProcCall może wcisnąć klawisz mówienia")

	// Strona sama kończy nagranie po VOICE_CHAT_MAX_SECONDS i tekst wraca, zanim gra dostała puszczenie klawisza
	SSvoice_chat.start_recording(player, "say")
	var/long_seq = session.recording_seq
	SSvoice_chat.handle_result(list("token" = session.token, "seq" = long_seq, "channel" = "say", "text" = "Długie zdanie"))
	TEST_ASSERT_EQUAL(length(heard), 2, "Tekst długiego nagrania przepadł")
	TEST_ASSERT(!session.recording_seq, "Po tekście długiego nagrania gra dalej uważa, że trwa nagranie")
	TEST_ASSERT(!speaker.typing_indicator, "Dymek nie zniknął po tekście długiego nagrania")

	// Gracz wyszedł z gry z wciśniętym klawiszem: strona dostaje „cancel”
	SSvoice_chat.start_recording(player, "say")
	GLOB.directory -= player.ckey
	SSvoice_chat.check_timeouts()
	TEST_ASSERT_EQUAL(last_cmd(), "cancel", "Wyjście gracza w trakcie nagrania nie anulowało nagrania na stronie")
	TEST_ASSERT(!session.recording_seq, "Nagranie gracza, który wyszedł, dalej trwa")
	GLOB.directory[player.ckey] = player

	// Nieudany /api/sync: polecenia wracają do kolejki, a jeden błąd nie rozłącza strony
	old_failed = SSvoice_chat.failed_syncs
	SSvoice_chat.failed_syncs = 0
	var/list/sent = list(list("token" = session.token, "cmd" = "stop", "seq" = 999))
	SSvoice_chat.in_flight_cmds = sent
	SSvoice_chat.pending_cmds = list()
	var/datum/http_response/failed = new
	failed.errored = TRUE
	failed.error = "test"
	SSvoice_chat.handle_sync_response(failed)
	TEST_ASSERT_EQUAL(last_cmd(), "stop", "Polecenie z nieudanego zapytania nie wróciło do kolejki")
	TEST_ASSERT(session.connected, "Jeden nieudany sync rozłączył stronę")

	// Serwis liczy ten sam skrót sekretu w Pythonie (hashlib.sha256 z UTF-8), także z polskimi literami
	TEST_ASSERT_EQUAL(rustg_hash_string(RUSTG_HASH_SHA256, "tajne_hasło"), "2c349d8acc997c876a843354c9cbc237da5bc30c431a4a19c38f01f5f4fd4c5f", "Skrót sekretu w grze różni się od skrótu w serwisie")

	// Adres z configu wklejony z ukośnikiem na końcu nie może dać „//?t=” w linku do strony
	TEST_ASSERT_EQUAL(trim_voice_chat_url("https://aquila-glos.duckdns.org/ "), "https://aquila-glos.duckdns.org", "Ukośnik na końcu adresu nie został obcięty")
	TEST_ASSERT_EQUAL(trim_voice_chat_url("http://127.0.0.1:8179"), "http://127.0.0.1:8179", "Adres bez ukośnika się zmienił")

/datum/unit_test/aquila_voice_chat/proc/last_cmd()
	var/list/cmds = SSvoice_chat.pending_cmds
	if(!length(cmds))
		return null
	var/list/cmd = cmds[length(cmds)]
	return cmd["cmd"]

/datum/unit_test/aquila_voice_chat/proc/on_say(datum/source, list/speech_args)
	SIGNAL_HANDLER
	heard += speech_args[SPEECH_MESSAGE]

/datum/unit_test/aquila_voice_chat/Destroy()
	if(player)
		SSvoice_chat.sessions -= player.ckey
		GLOB.directory -= player.ckey
	SSvoice_chat.enabled = old_enabled
	if(old_cmds)
		SSvoice_chat.pending_cmds = old_cmds
	if(!isnull(old_failed))
		SSvoice_chat.failed_syncs = old_failed
	SSvoice_chat.in_flight_cmds = null
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
