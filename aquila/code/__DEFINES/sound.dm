/// AQUILA - tgstation#90775: wartość z tgstation
#define MEDIUM_RANGE_SOUND_EXTRARANGE -5
// Jukebox: maksymalna głośność YouTube (0-1) przy 100% gałki - muzyka z sieci jest zwykle głośna
#define JUKEBOX_YT_MAX_GAIN 0.6

// Dźwięki mowy: słuchacz wybiera w ustawieniach gry nasze „hmm”, głosy z Goona albo ciszę (voice_goon.dm).
// Każda wypowiedź gra w obu wersjach, a głośność danej kategorii u słuchacza wycisza tę, której nie chce.
/// Nasze „hmm” mowy postaci, które mogłyby mówić głosem z Goona (słyszą je gracze z trybem „hmm”)
#define VOLUME_PREF_SPEECH "speech"
/// Głos z Goona tej samej wypowiedzi (słyszą go gracze z trybem głosów z Goona)
#define VOLUME_PREF_SPEECH_GOON "speech_goon"
/// Dźwięk mowy bez wersji do wyboru (rasa z własnym głosem, maszyny, zwierzęta): słyszą go oba tryby
#define VOLUME_PREF_SPEECH_ANY "speech_any"

// Voices: every character has a voice pitch, in semitones, applied to speech sounds and vocal emotes
#define VOICE_PITCH_MIN -5
#define VOICE_PITCH_MAX 5
/// Random pitch of a new voice (NPCs, new characters)
#define VOICE_PITCH_RANDOM rand(-3, 3)
/// Converts semitones to a playback multiplier for /sound/var/frequency
#define SEMITONES_TO_FREQUENCY(semitones) (2 ** ((semitones) / 12))
/// Random wobble of a single organic voice sound, in hundredths of a semitone
#define VOICE_JITTER 40
/// Speech: one phrase sound per this many characters (up to SPEECH_PHRASES_MAX)
#define SPEECH_PHRASE_CHARS 60
#define SPEECH_PHRASES_MAX 3
/// Gap between phrase sounds of one message
#define SPEECH_PHRASE_DELAY (0.6 SECONDS)
/// Distant gunshots: heard beyond normal sound range up to this many tiles
#define DISTANT_GUNSHOT_RANGE 45
// Jukebox: głośność (0-1, przy gałce 100%) głośników nagłośnienia przy nadawaniu na cały statek
#define JUKEBOX_SHIPWIDE_GAIN 0.35
// Jukebox: zasięg głośnika nagłośnienia na korytarzu i mniejszego w kwaterach/toaletach
#define JUKEBOX_CEILING_RANGE 9
#define JUKEBOX_CEILING_SMALL_RANGE 5
