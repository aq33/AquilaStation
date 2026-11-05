// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Zastępstwo klienta: SSvoice_chat potrzebuje od gracza tylko ckey i moba.
/datum/voice_chat_test_player
	var/ckey = "voicechattest"
	var/mob/mob

/// AQUILA - czat głosowy: klawisz mówienia steruje nagraniem, a rozpoznany tekst wypowiada postać
/datum/unit_test/aquila_voice_chat
	var/list/heard = list()
	var/datum/voice_chat_test_player/player
	var/old_enabled
	var/list/old_cmds

/datum/unit_test/aquila_voice_chat/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	player = new
	player.mob = speaker
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
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
