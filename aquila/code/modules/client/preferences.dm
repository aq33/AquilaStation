/datum/preferences
	/// -1 = zalecane (RECOMMENDED_CLIENT_FPS), 0 = zgodnie z tickiem serwera
	clientfps = -1
	/// Stare domyślne FPS 40 zostało już raz zamienione na zalecane (zapisywane w bazie)
	var/clientfps_migrated = FALSE
	/// Nazwy jednorazowych migracji, które już przeszły (zapisywane w bazie, PREFERENCE_TAG_KEYBIND_MIGRATIONS): keybindy
	/// (storage_grid.dm) i opcje (gunplay/preferences.dm). Nie czyścić ani nie filtrować, bo migracje odpalą się ponownie.
	var/list/keybind_migrations

/// FPS, które faktycznie dostaje klient. Zalecane = odświeżanie monitora zmierzone przez panel czatu
/// (client.monitor_refresh_rate), a dopóki go nie ma, RECOMMENDED_CLIENT_FPS.
/datum/preferences/proc/get_client_fps()
	if(clientfps >= 0)
		return clientfps
	return parent?.monitor_refresh_rate || RECOMMENDED_CLIENT_FPS

/// Body sizes the active character can pick. "Polak" also needs its loadout unlock.
/datum/preferences/proc/get_body_size_choices()
	var/datum/gear/ooc/polak/polak_unlock = /datum/gear/ooc/polak
	if(md5(initial(polak_unlock.display_name)) in purchased_gear)
		return active_character.pref_species.get_body_sizes()
	return active_character.pref_species.get_body_sizes() - "Polak"

// Voice pitch of the character, stored in features["voice_pitch"] (semitones), see aquila/code/modules/mob/voice.dm

/proc/random_voice_pitch()
	return VOICE_PITCH_RANDOM

/// Old characters have no voice yet. They get one from their name, so it stays the same until it is saved.
/proc/sanitize_voice_pitch(value, real_name)
	if(isnum(value))
		return clamp(round(value), VOICE_PITCH_MIN, VOICE_PITCH_MAX)
	if(!real_name)
		return random_voice_pitch()
	var/hash = text2num(copytext(md5(real_name), 1, 3), 16)
	return (hash % (VOICE_PITCH_MAX - VOICE_PITCH_MIN + 1)) + VOICE_PITCH_MIN

/// Plays a speech sound of the character's species and gender at the chosen pitch, only to the player
/datum/preferences/proc/play_voice_pitch_test(mob/user)
	var/datum/species/species = active_character.pref_species
	var/sound_key = species?.speech_sound || "human"
	if(species?.gendered_speech)
		sound_key += active_character.gender == FEMALE ? FEMALE : MALE
	var/pitch = active_character.features["voice_pitch"]
	var/sound/voice = sound(get_sfx(sound_key))
	voice.volume = 50
	voice.channel = SSsounds.random_available_channel()
	voice.frequency = SEMITONES_TO_FREQUENCY(isnum(pitch) ? pitch : 0)
	SEND_SOUND(user, voice)
