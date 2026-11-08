// AQUILA - zgodność dla ścieżek Lock i Moon (port heretyka z tg).
// Nastroje, dźwięk parady, osiągnięcia wzniesienia.

// Halucynacje (ciała, puls, losowy podtyp) są w aquila/code/modules/hallucination/ (Bee#13095 + tg#89865).

// --- Nastroje ---

/datum/mood_event/moon_smile
	description = "<span class='nicegreen'>KSIĘŻYC POKAZUJE MI PRAWDĘ, A JEGO UŚMIECH JEST ZWRÓCONY KU MNIE!!!</span>\n"
	mood_change = 10
	timeout = 2 MINUTES

/datum/mood_event/moon_insanity
	description = "<span class='boldwarning'>KSIĘŻYC MNIE OSĄDZA I UZNAJE ZA NIEGODNEGO!!!</span>\n"
	mood_change = -3
	timeout = 5 MINUTES

// --- Dźwięk parady ---

/datum/looping_sound/moon_parade
	mid_sounds = list('aquila/sound/effects/moon_parade_soundloop.ogg' = 1)
	mid_length = 2 SECONDS
	volume = 20

// --- Osiągnięcia wzniesienia ---

/datum/award/achievement/misc/lock_ascension
	name = "Sekrety Zamkniętego Labiryntu"
	desc = "Udało ci się otworzyć bramę do Mansusa."
	database_id = "Lock Ascension"

/datum/award/achievement/misc/moon_ascension
	name = "Ostatni akt"
	desc = "Udało ci się zostać przewodnikiem parady i zabić kłamstwo."
	database_id = "Moon Ascension"

