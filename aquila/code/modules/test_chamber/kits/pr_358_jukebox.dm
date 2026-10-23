// aq33/AquilaStation#358 - jukebox z YouTube, okrągły zasięg, gałka głośności, playlisty
// Obejmuje też: aq33/AquilaStation#397 (echo z dwóch odbić), aq33/AquilaStation#401 (tłumienie przez ściany i drzwi),
// aq33/AquilaStation#403 (nagłośnienie, amp stack, radio, głośnik Syndykatu), aq33/AquilaStation#425 (mniej echa)

/datum/test_chamber_kit/pr_358
	name = "PR 358: jukebox - zasięg, głośność, playlista, tłumienie"
	pr = "aq33/AquilaStation#358"
	description = "Jukebox (dostęp: zapasowa karta kapitana) gra tylko z YouTube: wklej playlistę, kliknij utwór na liście, \"Losowy utwór\", \"Losowo: TAK/NIE\", gałka 10-100%. \
	Odchodź od jukeboxa: pełna głośność do 3 kratek, dalej płynnie cichnie do 20 kratek, bez uciekania na jedno ucho; z daleka słychać echo jak w sali (dwa krótkie odbicia, nie drugi utwór - #397, #425). \
	Stań za fałszywą ścianą albo zamkniętymi drzwiami - muzyka ma być wyraźnie przytłumiona, po otwarciu drzwi od razu głośniej (#401). \
	Kable w panelu (śrubokręt, multitool): prędkość = tempo, LISTING = losowy utwór, RANCH = tryb losowy, PLAY = graj/stop. Na hoście nie ma wyskakiwać okno CMD. TGUI musi być przebudowane."
	items = list(
		/obj/machinery/jukebox = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1,
		/obj/item/wirecutters = 1,
		/obj/machinery/door/airlock = 1,
		/obj/structure/falsewall = 2,
	)

/datum/test_chamber_kit/pr_403
	name = "PR 403: amp stack, radio, głośnik Syndykatu"
	pr = "aq33/AquilaStation#403"
	description = "Amp stack: multitoolem kliknij jukebox, potem amp stack - podłączony. Klik na amp stack go włącza/wyłącza, gra ciszej (70%) w zasięgu 8 kratek z animacją. \
	Radio (każdy ma dostęp): mały jukebox z własną playlistą, zasięg 10, amp stacki podłącza się tak samo. Głośnik Syndykatu (karta agenta) gra też odkręcony - weź go i ciągnij, muzyka idzie z nim. \
	Odkręcony amp stack przykręć kluczem. Płytki amp stacka i radia są w drukarce od startu (węzeł \"Nagłośnienie\"). \
	Głośnik nagłośnienia stoi tylko do obejrzenia: program \"Nagłośnienie statku\" i rozwieszanie głośników działają tylko na statku (komora nie jest na overmapie) - sprawdź na konsoli dowodzenia w rundzie."
	items = list(
		/obj/machinery/jukebox = 1,
		/obj/machinery/jukebox/radio = 1,
		/obj/machinery/jukebox/nukie = 1,
		/obj/machinery/jukebox_speaker = 1,
		/obj/machinery/jukebox_speaker/unanchored = 1,
		/obj/machinery/ceiling_speaker = 1,
		/obj/item/circuitboard/machine/jukebox_speaker = 1,
		/obj/item/circuitboard/machine/jukebox_radio = 1,
		/obj/item/multitool = 1,
		/obj/item/wrench = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/card/id/syndicate = 1,
	)
