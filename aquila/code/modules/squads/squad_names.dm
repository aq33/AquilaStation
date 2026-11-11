// Nazwy drużyn Alpha, Bravo, Charlie, Delta (zamiast Able, Baker, Charlie, Duff z NSV13).
// Typy drużyn zostają (/datum/squad/able itd.), zmienia się nazwa widoczna dla gracza i kanał pagera.

/datum/squad/able
	name = "Alpha"
	desc = "Drużyna Alpha to drużyna okrętu w stanie podwyższonej gotowości. Można ją wysłać do przejmowania wrogich jednostek albo do walki z zagrożeniami, choć domyślnie ma pomagać w naprawach podczas walki."

/datum/squad/baker
	name = "Bravo"
	desc = "Drużyna Bravo to drużyna ratownicza okrętu. Specjalizuje się w poszukiwaniu i ratownictwie oraz w ratownictwie medycznym."

/datum/squad/charlie
	desc = "Drużyna Charlie to zapasowa drużyna techniczna okrętu. Zwykle wysyła się ją podczas skomplikowanych abordaży, gdy w drużynie Alpha robi się za tłoczno."

/datum/squad/duff
	name = "Delta"
	desc = "Drużyna Delta wspiera dział uzbrojenia: ładuje działa i nosi amunicję, gdy brakuje rąk do pracy. Dostęp do broni dajesz jej na własne ryzyko."

// Kanały pagera szukane po nazwie drużyny (text2path w /datum/squad/proc/generate_channel)
/datum/component/simple_teamchat/radio_dependent/squad/Alpha
	name = "Drużyna Alpha"
	button_icon_state = "Able"
	key = "Alpha"
	text_span_style = "ableradio"

/datum/component/simple_teamchat/radio_dependent/squad/Bravo
	name = "Drużyna Bravo"
	button_icon_state = "Baker"
	key = "Bravo"
	text_span_style = "bakerradio"

/datum/component/simple_teamchat/radio_dependent/squad/Delta
	name = "Drużyna Delta"
	button_icon_state = "Duff"
	key = "Delta"
	text_span_style = "duffradio"

/datum/character_save
	preferred_squad = "Alpha"

/// Stare nazwy z zapisanych postaci (preferowana drużyna w bazie)
GLOBAL_LIST_INIT(squad_legacy_names, list(
	"Able" = "Alpha",
	"Baker" = "Bravo",
	"Duff" = "Delta",
))

/datum/squad_manager/get_squad(name)
	. = ..()
	if(!. && GLOB.squad_legacy_names[name])
		return ..(GLOB.squad_legacy_names[name])
