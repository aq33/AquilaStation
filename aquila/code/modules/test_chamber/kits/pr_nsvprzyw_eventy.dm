// aq33/AquilaStation#657 - przywrócone eventy overmapy NSV13 na kaflach mapy hex (aquila/code/modules/events/hexmap/)

/datum/test_chamber_kit/pr_nsvprzyw_eventy
	name = "Kafle hex: Samotny łowca"
	pr = "aq33/AquilaStation#657"
	description = "Zestaw nic nie zrzuca: od razu odpala Samotnego łowcę przy okręcie głównym (okręt musi stać w układzie, nie w skoku; zestaw pomija warunek sektora). \
		1) W czacie ostrzeżenie „Łącze DRADIS: Wykryto sygnaturę bluespace.”. \
		2) Po 4–6 s na DRADIS-ie jeden okręt Syndykatu (fregata Mako) kilkanaście pól od okrętu, który od razu atakuje. \
		3) Po zestrzeleniu nie ma ogłoszenia „Przetworzono wypłatę nagrody” (o ile nic innego nie zestrzelono). \
		W zwykłej grze event wypada tylko po skoku na pole asteroid albo mgławicę na pograniczu lub w sektorze Syndykatu, i to rzadko (25% szans na wejście do losowania z puli kafla)."
	items = list()
	/// Event odpalany przez zestaw
	var/event_path = /datum/round_event_control/aquila_hex_lone_hunter

/datum/test_chamber_kit/pr_nsvprzyw_eventy/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user) // test jednostkowy komory zrzuca zestawy bez admina: bez eventów na overmapie
		return
	var/datum/round_event_control/control = hex_event_control(event_path)
	if(!control)
		to_chat(user, span_warning("Brak kontrolki eventu [event_path]."))
		return
	control.runEvent()
	to_chat(user, span_notice("Odpalono event „[control.name]” przy okręcie głównym."))

/datum/test_chamber_kit/pr_nsvprzyw_eventy/szczury
	name = "Kafle hex: Szczury z pasa"
	description = "Zestaw nic nie zrzuca: od razu odpala Szczury z pasa przy okręcie głównym (okręt musi stać w układzie, nie w skoku; zestaw pomija warunek sektora). \
		1) Bez ogłoszenia na DRADIS-ie pojawiają się 2–3 myśliwce przechwytujące Syndykatu, 10–14 pól od okrętu, z różnych stron, i od razu atakują. \
		2) Po zestrzeleniu nie ma ogłoszenia „Przetworzono wypłatę nagrody” (o ile nic innego nie zestrzelono). \
		W zwykłej grze event wypada tylko po skoku na pole asteroid na pograniczu lub w sektorze Syndykatu, i to rzadko (25% szans na wejście do losowania z puli kafla)."
	event_path = /datum/round_event_control/aquila_hex_belt_rats
