// Mikser dźwięku: osobny suwak głośności (0-100%) dla każdej kategorii dźwięków w ustawieniach gry (Dźwięk -> Mikser).
// Dźwięk dostaje kategorię przez volume_pref w playsound()/playsound_local(), które już mnożą głośność przez
// get_volume_pref(). Dźwięki wysyłane wprost przez SEND_SOUND (relay okrętu, otoczenie, TTS) mnożą się przez
// mob.sound_volume_mult(). Wartości zapisują się w jednej liście JSON (PREFERENCE_TAG_SOUND_VOLUMES).
// Stare przełączniki (otoczenie, odgłosy statku, ogłoszenia) zostają: wyłączają całość, suwak tylko ścisza.

/// Kategorie miksera w kolejności suwaków. Tesla ma własny, starszy suwak (tesla_volume).
GLOBAL_LIST_INIT(sound_mixer_categories, list(
	VOLUME_PREF_SHIP_ALERTS,
	VOLUME_PREF_SHIP_FX,
	VOLUME_PREF_GUNS,
	VOLUME_PREF_EMOTES,
	VOLUME_PREF_VOICES,
	VOLUME_PREF_BOTS,
	VOLUME_PREF_TTS,
	VOLUME_PREF_ANNOUNCEMENTS,
	VOLUME_PREF_AMBIENCE,
	VOLUME_PREF_AMBIENT_MUSIC,
))

/datum/preferences
	/// Głośność kategorii miksera (VOLUME_PREF_* -> 0-100). Brak wpisu = 100.
	var/list/sound_volumes = list()

/datum/preferences/proc/get_sound_volumes()
	RETURN_TYPE(/list)
	if(!islist(sound_volumes))
		sound_volumes = list()
	return sound_volumes

/// Głośność kategorii miksera, 0-100
/datum/preferences/proc/get_sound_volume(category)
	var/volume = get_sound_volumes()[category]
	return isnum(volume) ? volume : 100

/datum/preferences/proc/set_sound_volume(category, volume)
	if(!(category in GLOB.sound_mixer_categories))
		return
	get_sound_volumes()[category] = clamp(round(volume), 0, 100)

/// Po wczytaniu z bazy: tylko znane kategorie i liczby 0-100 (JSON mógł być uszkodzony albo stary)
/datum/preferences/proc/sanitize_sound_volumes()
	var/list/loaded = sound_volumes
	sound_volumes = list()
	if(!islist(loaded))
		return
	for(var/category in GLOB.sound_mixer_categories)
		var/volume = loaded[category]
		if(istext(volume))
			volume = text2num(volume)
		if(isnum(volume))
			set_sound_volume(category, volume)

/datum/preferences/get_volume_pref(volume_pref)
	. = ..()
	var/category = volume_pref
	// dźwięki mowy mają trzy warianty (voice_goon.dm), a suwak jeden
	if(volume_pref == VOLUME_PREF_SPEECH || volume_pref == VOLUME_PREF_SPEECH_GOON || volume_pref == VOLUME_PREF_SPEECH_ANY)
		category = VOLUME_PREF_VOICES
	if(category in GLOB.sound_mixer_categories)
		. = . * get_sound_volume(category) / 100 // najpierw mnożenie: 100 * 0.3 to nie dokładnie 30

/// Mnożnik 0-1 głośności kategorii u tego gracza (1 bez klienta albo bez kategorii)
/mob/proc/sound_volume_mult(volume_pref)
	var/datum/preferences/prefs = client?.prefs || mock_client?.prefs
	if(!volume_pref || !prefs)
		return 1
	return prefs.get_volume_pref(volume_pref) / 100

/client
	/// Głośność przy 100% suwaka pętli grającej na danym kanale ("[kanał]" -> głośność), żeby suwak ściszał ją na żywo
	var/list/mixer_channel_bases

/// Puszcza dźwięk ściszony przez kategorię miksera. Dźwięk na kanale zapamiętuje swoją głośność bazową,
/// więc ruszenie suwaka przelicza ją od tego, co naprawdę gra (alarm 100, kokpit 50, szum 40).
/client/proc/play_mixed_sound(sound/S, volume_pref)
	var/base_volume = S.volume
	if(S.channel)
		LAZYSET(mixer_channel_bases, "[S.channel]", base_volume)
	S.volume = base_volume * (prefs ? prefs.get_volume_pref(volume_pref) / 100 : 1)
	SEND_SOUND(src, S)

/mob/proc/play_mixed_sound(sound/S, volume_pref)
	if(client)
		client.play_mixed_sound(S, volume_pref)

// Suwaki w oknie preferencji

/datum/preference/numeric/sound_mixer
	abstract_type = /datum/preference/numeric/sound_mixer
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	step = 5
	/// VOLUME_PREF_* tego suwaka
	var/volume_category
	/// Kanały pętli puszczanych przez play_mixed_sound(): po zmianie suwaka grająca pętla od razu dostaje nową głośność
	var/list/live_channels

/datum/preference/numeric/sound_mixer/read_value(datum/preferences/prefs)
	return prefs.get_sound_volume(volume_category)

/datum/preference/numeric/sound_mixer/write_value(datum/preferences/prefs, value)
	prefs.set_sound_volume(volume_category, value)

/datum/preference/numeric/sound_mixer/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(!C?.mob || !length(live_channels))
		return
	var/mult = C.mob.sound_volume_mult(volume_category)
	for(var/channel in live_channels)
		var/base_volume = LAZYACCESS(C.mixer_channel_bases, "[channel]")
		if(!isnull(base_volume))
			C.mob.set_sound_channel_volume(channel, base_volume * mult)

/datum/preference/numeric/sound_mixer/ship_alerts
	db_key = "sound_mixer_ship_alerts"
	volume_category = VOLUME_PREF_SHIP_ALERTS
	live_channels = list(CHANNEL_SHIP_ALERT, CHANNEL_REACTOR_ALERT, CHANNEL_SHIP_FX, CHANNEL_IMPORTANT_SHIP_ALERT)

/datum/preference/numeric/sound_mixer/ship_fx
	db_key = "sound_mixer_ship_fx"
	volume_category = VOLUME_PREF_SHIP_FX
	live_channels = list(AQUILA_CHANNEL_HULL_CREAK) // skrzypienie kadłuba

/datum/preference/numeric/sound_mixer/guns
	db_key = "sound_mixer_guns"
	volume_category = VOLUME_PREF_GUNS

/datum/preference/numeric/sound_mixer/emotes
	db_key = "sound_mixer_emotes"
	volume_category = VOLUME_PREF_EMOTES

/datum/preference/numeric/sound_mixer/voices
	db_key = "sound_mixer_voices"
	volume_category = VOLUME_PREF_VOICES

/datum/preference/numeric/sound_mixer/bots
	db_key = "sound_mixer_bots"
	volume_category = VOLUME_PREF_BOTS

/datum/preference/numeric/sound_mixer/tts
	db_key = "sound_mixer_tts"
	volume_category = VOLUME_PREF_TTS

/datum/preference/numeric/sound_mixer/announcements
	db_key = "sound_mixer_announcements"
	volume_category = VOLUME_PREF_ANNOUNCEMENTS

/datum/preference/numeric/sound_mixer/ambience
	db_key = "sound_mixer_ambience"
	volume_category = VOLUME_PREF_AMBIENCE
	// efekty otoczenia (CHANNEL_AMBIENT_EFFECTS) to krótkie jednorazowe dźwięki: zmiana obejmie następny
	live_channels = list(CHANNEL_BUZZ)

/datum/preference/numeric/sound_mixer/ambient_music
	db_key = "sound_mixer_ambient_music"
	volume_category = VOLUME_PREF_AMBIENT_MUSIC
	live_channels = list(CHANNEL_AMBIENT_MUSIC)

/// Kategoria miksera dźwięku relay(): na kanale grają alarmy i sygnały, bez kanału salwy, trafienia i manewry
/proc/aq_relay_volume_pref(channel)
	return channel ? VOLUME_PREF_SHIP_ALERTS : VOLUME_PREF_SHIP_FX
