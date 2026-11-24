// Głosy mowy z Goonstation (sound/misc/talk, CC BY-NC-SA 3.0, autorzy: zespół Goonstation).
// Słuchacz wybiera w ustawieniach gry, co słyszy, gdy postać mówi: nasze „hmm” (domyślnie), głosy z Goona albo nic.
// Głos z Goona ma cztery warianty z osobnym nagraniem pytania (?) i okrzyku (!). Postać wybiera swój w oknie postaci,
// a bez wyboru dostaje stały wariant liczony z imienia. Rasa może mieć własny głos (mops szczeka, żaba rechocze,
// Akwarianin bulgocze, /datum/species/var/goon_voice): ten słychać w obu trybach, jak dźwięki maszyn i zwierząt.

/// Wartość preferencji postaci: głos z Goona wybrany automatycznie (stały, z imienia)
#define SPEECH_VOICE_SPECIES "species"

/// Tryby słuchacza (preferencja gry speech_sounds, zapisana w bitach chat_toggles)
#define SPEECH_SOUNDS_HMM "hmm"
#define SPEECH_SOUNDS_GOON "goon"
#define SPEECH_SOUNDS_OFF "off"

/// Głos -> nagrania wypowiedzi, pytania i okrzyku
GLOBAL_LIST_INIT(goon_speech_voices, list(
	"speak_1" = list("say" = 'aquila/sound/voice/goon/speak_1.ogg', "ask" = 'aquila/sound/voice/goon/speak_1_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_1_exclaim.ogg'),
	"speak_2" = list("say" = 'aquila/sound/voice/goon/speak_2.ogg', "ask" = 'aquila/sound/voice/goon/speak_2_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_2_exclaim.ogg'),
	"speak_3" = list("say" = 'aquila/sound/voice/goon/speak_3.ogg', "ask" = 'aquila/sound/voice/goon/speak_3_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_3_exclaim.ogg'),
	"speak_4" = list("say" = 'aquila/sound/voice/goon/speak_4.ogg', "ask" = 'aquila/sound/voice/goon/speak_4_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_4_exclaim.ogg'),
	"pug" = list("say" = 'aquila/sound/voice/goon/pug.ogg', "ask" = 'aquila/sound/voice/goon/pug_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/pug_exclaim.ogg'),
	"pugg" = list("say" = 'aquila/sound/voice/goon/pugg.ogg', "ask" = 'aquila/sound/voice/goon/pugg_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/pugg_exclaim.ogg'),
	"amphibian" = list("say" = 'aquila/sound/voice/goon/amphibian.ogg', "ask" = 'aquila/sound/voice/goon/amphibian_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/amphibian_exclaim.ogg'),
	"blub" = list("say" = 'aquila/sound/voice/goon/blub.ogg', "ask" = 'aquila/sound/voice/goon/blub_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/blub_exclaim.ogg'),
	// Grod piszczy jak gumowa zabawka, Mięsoczłowiek charczy jak zombie z Minecrafta, Borowik cicho pyka
	"grod" = list(
		"say" = list('aquila/sound/species/grod/squeak_double.ogg', 'aquila/sound/species/grod/squeak_double_low.ogg', 'aquila/sound/species/grod/squeak_trembling.ogg', 'aquila/sound/species/grod/squeak_triple.ogg', 'aquila/sound/species/grod/squeak_double_high.ogg'),
		"ask" = list('aquila/sound/species/grod/squeak_double_high.ogg', 'aquila/sound/species/grod/squeak_trembling.ogg'),
		"exclaim" = list('aquila/sound/species/grod/squeak_triple.ogg', 'aquila/sound/species/grod/squeak_double.ogg'),
	),
	"beefman" = list("say" = 'aquila/sound/voice/goon/beefman.ogg', "ask" = 'aquila/sound/voice/goon/beefman_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/beefman_exclaim.ogg'),
	"borowik" = list("say" = 'aquila/sound/voice/goon/borowik.ogg', "ask" = 'aquila/sound/voice/goon/borowik_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/borowik_exclaim.ogg'),
))

/// Głosy do wyboru w oknie postaci. Głosy gatunkowe Goona (mops, żaba) daje rasa.
GLOBAL_LIST_INIT(selectable_speech_voices, list(SPEECH_VOICE_SPECIES, "speak_1", "speak_2", "speak_3", "speak_4"))

/datum/species
	/// Własny głos rasy (klucz z GLOB.goon_speech_voices), słyszany w obu trybach zamiast „hmm”
	var/goon_voice

/// Własny głos rasy, który zastępuje dźwięk mowy dla wszystkich słuchaczy, albo null
/atom/movable/proc/get_species_goon_voice()
	return null

/mob/living/carbon/get_species_goon_voice()
	return dna?.species?.goon_voice

/// Głos z Goona dla słuchaczy w trybie głosów z Goona, albo null gdy ta postać nie ma wersji z Goona (maszyny, zwierzęta)
/atom/movable/proc/get_goon_voice()
	return null

/mob/living/carbon/human/get_goon_voice()
	if(!dna)
		return null
	// Maszyny (IPC, android) brzmią po swojemu w obu trybach, a rasa bez dźwięku mowy milczy też w trybie Goona
	var/species_sound = dna.species?.speech_sound
	if(!species_sound || species_sound == "synthetic")
		return null
	var/voice = dna.features["speech_voice"]
	if(voice && voice != SPEECH_VOICE_SPECIES && GLOB.goon_speech_voices[voice])
		return voice
	return aquila_default_goon_voice(real_name)

/// Stały wariant głosu z Goona dla postaci bez wyboru: liczony z imienia, więc ta sama postać brzmi zawsze tak samo
/proc/aquila_default_goon_voice(name)
	var/list/human_voices = GLOB.selectable_speech_voices - SPEECH_VOICE_SPECIES
	if(!name)
		return human_voices[1]
	var/hash = text2num(copytext(md5(name), 1, 3), 16)
	return human_voices[(hash % length(human_voices)) + 1]

/// Nagranie głosu Goona dla wypowiedzi zakończonej znakiem last_char. Lista nagrań = losowy wariant (Grod).
/proc/get_goon_voice_sound(voice, last_char)
	var/list/recordings = GLOB.goon_speech_voices[voice]
	if(!recordings)
		return null
	var/kind = "say"
	if(last_char == "?")
		kind = "ask"
	else if(last_char == "!")
		kind = "exclaim"
	var/recording = recordings[kind]
	return islist(recording) ? pick(recording) : recording

/// Co słuchacz chce słyszeć, gdy postacie mówią
/datum/preferences/proc/get_speech_sounds_mode()
	if(chat_toggles & CHAT_DISABLE_SPEECH_SOUNDS)
		return SPEECH_SOUNDS_OFF
	if(chat_toggles & CHAT_GOON_SPEECH_SOUNDS)
		return SPEECH_SOUNDS_GOON
	return SPEECH_SOUNDS_HMM

/datum/preferences/get_volume_pref(volume_pref)
	switch(volume_pref)
		if(VOLUME_PREF_SPEECH)
			return get_speech_sounds_mode() == SPEECH_SOUNDS_HMM ? 100 : 0
		if(VOLUME_PREF_SPEECH_GOON)
			return get_speech_sounds_mode() == SPEECH_SOUNDS_GOON ? 100 : 0
		if(VOLUME_PREF_SPEECH_ANY)
			return get_speech_sounds_mode() == SPEECH_SOUNDS_OFF ? 0 : 100
	return ..()

/// Dźwięki mowy postaci w ustawieniach gry: nasze „hmm”, głosy z Goona albo cisza
/datum/preference/choiced/speech_sounds
	db_key = "speech_sounds"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/speech_sounds/init_possible_values()
	return list(SPEECH_SOUNDS_HMM, SPEECH_SOUNDS_GOON, SPEECH_SOUNDS_OFF)

/datum/preference/choiced/speech_sounds/get_display_names()
	return list(
		SPEECH_SOUNDS_HMM = "Nasze „hmm”",
		SPEECH_SOUNDS_GOON = "Głosy z Goona",
		SPEECH_SOUNDS_OFF = "Wyłączone",
	)

/datum/preference/choiced/speech_sounds/read_value(datum/preferences/prefs)
	return prefs.get_speech_sounds_mode()

/datum/preference/choiced/speech_sounds/write_value(datum/preferences/prefs, value)
	prefs.chat_toggles &= ~(CHAT_DISABLE_SPEECH_SOUNDS | CHAT_GOON_SPEECH_SOUNDS)
	switch(value)
		if(SPEECH_SOUNDS_OFF)
			prefs.chat_toggles |= CHAT_DISABLE_SPEECH_SOUNDS
		if(SPEECH_SOUNDS_GOON)
			prefs.chat_toggles |= CHAT_GOON_SPEECH_SOUNDS

/// Głos z Goona tej postaci (słyszą go gracze, którzy wybrali głosy z Goona)
/datum/preference/choiced/speech_voice
	db_key = "speech_voice"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	feature_key = "speech_voice"
	can_randomize = TRUE

/datum/preference/choiced/speech_voice/init_possible_values()
	return GLOB.selectable_speech_voices.Copy()

/datum/preference/choiced/speech_voice/get_display_names()
	return list(
		SPEECH_VOICE_SPECIES = "Automatyczny",
		"speak_1" = "Głos 1",
		"speak_2" = "Głos 2",
		"speak_3" = "Głos 3",
		"speak_4" = "Głos 4",
	)

/// Stare postacie nie mają tej cechy: głos dobiera się sam
/datum/preference/choiced/speech_voice/read_value(datum/preferences/prefs)
	return ..() || SPEECH_VOICE_SPECIES

/datum/preference/choiced/speech_voice/create_random_value(datum/preferences/prefs)
	return SPEECH_VOICE_SPECIES

/datum/preference/choiced/speech_voice/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(C?.mob)
		prefs.play_voice_pitch_test(C.mob)

#undef SPEECH_VOICE_SPECIES
#undef SPEECH_SOUNDS_HMM
#undef SPEECH_SOUNDS_GOON
#undef SPEECH_SOUNDS_OFF
