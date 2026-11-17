// Głosy mowy z Goonstation (sound/misc/talk, CC BY-NC-SA 3.0, autorzy: zespół Goonstation).
// Zamiast gatunkowego dźwięku mowy postać może mówić jednym z czterech głosów. Pytanie (?) i okrzyk (!)
// mają osobne nagrania, jak w Goonie. Rasa może narzucić własny głos (np. mops szczeka) w /datum/species/var/goon_voice.
// Gracz, który nie chce słyszeć dźwięków mowy (naszych i z Goona), wyłącza je w preferencjach (CHAT_DISABLE_SPEECH_SOUNDS).

/// Wartość preferencji: mówi dźwiękiem gatunku (domyślnie)
#define SPEECH_VOICE_SPECIES "species"

/// Głos -> nagrania wypowiedzi, pytania i okrzyku
GLOBAL_LIST_INIT(goon_speech_voices, list(
	"speak_1" = list("say" = 'aquila/sound/voice/goon/speak_1.ogg', "ask" = 'aquila/sound/voice/goon/speak_1_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_1_exclaim.ogg'),
	"speak_2" = list("say" = 'aquila/sound/voice/goon/speak_2.ogg', "ask" = 'aquila/sound/voice/goon/speak_2_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_2_exclaim.ogg'),
	"speak_3" = list("say" = 'aquila/sound/voice/goon/speak_3.ogg', "ask" = 'aquila/sound/voice/goon/speak_3_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_3_exclaim.ogg'),
	"speak_4" = list("say" = 'aquila/sound/voice/goon/speak_4.ogg', "ask" = 'aquila/sound/voice/goon/speak_4_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/speak_4_exclaim.ogg'),
	"pug" = list("say" = 'aquila/sound/voice/goon/pug.ogg', "ask" = 'aquila/sound/voice/goon/pug_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/pug_exclaim.ogg'),
	"pugg" = list("say" = 'aquila/sound/voice/goon/pugg.ogg', "ask" = 'aquila/sound/voice/goon/pugg_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/pugg_exclaim.ogg'),
	"amphibian" = list("say" = 'aquila/sound/voice/goon/amphibian.ogg', "ask" = 'aquila/sound/voice/goon/amphibian_ask.ogg', "exclaim" = 'aquila/sound/voice/goon/amphibian_exclaim.ogg'),
))

/// Głosy do wyboru w oknie postaci. Głosy gatunkowe Goona (mops, żaba) daje rasa.
GLOBAL_LIST_INIT(selectable_speech_voices, list(SPEECH_VOICE_SPECIES, "speak_1", "speak_2", "speak_3", "speak_4"))

/datum/species
	/// Głos Goona narzucony przez rasę zamiast wyboru gracza, klucz z GLOB.goon_speech_voices
	var/goon_voice

/// Klucz głosu Goona, którym mówi ten obiekt, albo null dla zwykłego dźwięku mowy
/atom/movable/proc/get_goon_voice()
	return null

/mob/living/carbon/get_goon_voice()
	if(!dna)
		return null
	if(dna.species?.goon_voice)
		return dna.species.goon_voice
	var/voice = dna.features["speech_voice"]
	if(voice && voice != SPEECH_VOICE_SPECIES && GLOB.goon_speech_voices[voice])
		return voice
	return null

/// Nagranie głosu Goona dla wypowiedzi zakończonej znakiem last_char
/proc/get_goon_voice_sound(voice, last_char)
	var/list/recordings = GLOB.goon_speech_voices[voice]
	if(!recordings)
		return null
	if(last_char == "?")
		return recordings["ask"]
	if(last_char == "!")
		return recordings["exclaim"]
	return recordings["say"]

/datum/preferences/get_volume_pref(volume_pref)
	if(volume_pref == VOLUME_PREF_SPEECH)
		return (chat_toggles & CHAT_DISABLE_SPEECH_SOUNDS) ? 0 : 100
	return ..()

/// Dźwięki mowy postaci (gatunkowe i z Goona) słyszane przez gracza
/datum/preference/toggle/player/sound_speech
	db_key = "sound_speech"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_DISABLE_SPEECH_SOUNDS
	toggle_inverted = TRUE

/// Głos mowy postaci
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
		SPEECH_VOICE_SPECIES = "Głos gatunku",
		"speak_1" = "Głos 1",
		"speak_2" = "Głos 2",
		"speak_3" = "Głos 3",
		"speak_4" = "Głos 4",
	)

/// Stare postacie nie mają tej cechy: mówią głosem gatunku
/datum/preference/choiced/speech_voice/read_value(datum/preferences/prefs)
	return ..() || SPEECH_VOICE_SPECIES

/datum/preference/choiced/speech_voice/create_random_value(datum/preferences/prefs)
	return SPEECH_VOICE_SPECIES

/datum/preference/choiced/speech_voice/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(C?.mob)
		prefs.play_voice_pitch_test(C.mob)

#undef SPEECH_VOICE_SPECIES
