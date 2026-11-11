// Ogłoszenie SI przez TTS ElevenLabs (ten sam klucz i budżet znaków co rozkazy drużyn, squad_tts.dm).
// Gdy TTS działa, przycisk ogłoszenia w HUD-zie SI pyta o dowolny tekst i czyta go głosem SI tym samym
// słuchaczom co VOX. Bez klucza zostaje stary VOX ze słownikiem nagranych słów.

/// Głos SI (identyfikator głosu ElevenLabs)
/datum/config_entry/string/ai_tts_voice
	config_entry_value = "21m00Tcm4TlvDq8ikWAM"

#define AQ_AI_TTS_MAX_CHARS 300
#define AQ_AI_TTS_DELAY (60 SECONDS)

/// Kiedy SI może znów ogłosić coś głosem (wspólne dla wszystkich SI, jak przy VOX)
GLOBAL_VAR_INIT(aq_ai_tts_next_announcement, 0)

/mob/living/silicon/ai/announcement_help()
	if(!squad_tts_active())
		return ..()
	to_chat(src, "<span class='notice'>Syntezator mowy jest włączony: przycisk ogłoszenia przyjmuje dowolny tekst po polsku (najwyżej [AQ_AI_TTS_MAX_CHARS] znaków, jedno ogłoszenie na [DisplayTimeText(AQ_AI_TTS_DELAY)]).</span>")

/mob/living/silicon/ai/announcement()
	if(!squad_tts_active())
		return ..()
	if(GLOB.aq_ai_tts_next_announcement > world.time)
		to_chat(src, "<span class='notice'>Zaczekaj [DisplayTimeText(GLOB.aq_ai_tts_next_announcement - world.time)].</span>")
		return

	var/message = capped_input(src, "Wpisz tekst ogłoszenia (najwyżej [AQ_AI_TTS_MAX_CHARS] znaków). Usłyszy je cała załoga statku. Nadużywanie ogłoszeń może skończyć się banem na rolę.", "Ogłoszenie", last_announcement, AQ_AI_TTS_MAX_CHARS)
	if(!message)
		return
	last_announcement = message

	if(GLOB.aq_ai_tts_next_announcement > world.time || incapacitated())
		return
	if(control_disabled)
		to_chat(src, "<span class='warning'>Interfejs bezprzewodowy wyłączony, nie można użyć systemu ogłoszeń.</span>")
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(src, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
		return
	if(!squad_tts_reserve_chars(message))
		to_chat(src, "<span class='warning'>Syntezator mowy wyczerpał limit na tę zmianę. Ogłoszenie nie poszło.</span>")
		return

	GLOB.aq_ai_tts_next_announcement = world.time + AQ_AI_TTS_DELAY
	log_game("[key_name(src)] made a TTS vocal announcement with the following message: [message].")
	message_admins("[key_name(src)] wygłasza ogłoszenie głosowe o treści: [html_encode(message)].")
	to_chat(src, "<span class='notice'>Ogłaszasz: \"[html_encode(message)]\"</span>")

	var/list/listeners = aq_announcement_listeners()
	if(length(listeners))
		INVOKE_ASYNC(src, PROC_REF(aq_tts_announce), message, listeners)

/mob/living/silicon/ai/proc/aq_tts_announce(message, list/listeners)
	if(!aq_squad_tts_request(CONFIG_GET(string/ai_tts_voice), message, listeners, CHANNEL_VOX) && !QDELETED(src))
		to_chat(src, "<span class='warning'>Syntezator mowy nie odpowiedział. Ogłoszenie nie zostało odtworzone.</span>")

/// Ci sami słuchacze co w play_vox_word: cały statek SI albo jej poziom Z, z włączonymi ogłoszeniami dźwiękowymi
/mob/living/silicon/ai/proc/aq_announcement_listeners()
	. = list()
	var/obj/structure/overmap/ship = get_overmap()
	var/z_level = get_virtual_z_level()
	for(var/mob/listener as anything in (ship ? ship.mobs_in_ship : GLOB.player_list))
		if(!listener.client || !listener.can_hear() || !(listener.client.prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS))
			continue
		if(!ship)
			var/turf/listener_turf = get_turf(listener)
			if(listener_turf?.get_virtual_z_level() != z_level)
				continue
		. += listener

#undef AQ_AI_TTS_MAX_CHARS
#undef AQ_AI_TTS_DELAY
