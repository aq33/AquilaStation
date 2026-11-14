/datum/test_chamber_kit/pr_639
	name = "Planety: lądowanie, kapsuły, ostrzał i misje"
	pr = "aq33/AquilaStation#639"
	description = "Zestaw: wyrzutnia kapsuł desantowych, lornetka taktyczna, zestaw do próbek, sonda badawcza, GPS, sprzęt górnika (kombinezon, maska, butla), ciężkie laserowe wiertło górnicze z ogniwem, georadarowy skaner górniczy, analizator i sygnalizator do anomalii oraz nóż. Na serwerze (nie w CI) zestaw pyta, czy dodać planetę wulkaniczną w układzie okrętu i czy dodać misję planetarną. \
	1) Planeta: na overmapie duży sprite planety bez kolizji, na DRADIS-ie jej nie ma. Stanowisko rozpoznania, obiekt „planeta”, przycisk „Skanuj planetę” → opis z typem, atmosferą i zagrożeniami (oględziny planety). Za daleko (ponad 60 pól) → komunikat, że trzeba podlecieć (negatyw). \
	2) Lądowanie: Sabre w trybie dokowania nad środkiem planety → komunikat o mapowaniu, po kilku-kilkunastu sekundach wybór lądowiska (Alfa, Bravo, Charlie), kamera lądowania nad lądowiskiem, „Wyląduj tutaj” → prom stoi na bazalcie. Na powierzchni: krawędź z nieprzebytych skał, wulkaniczny piasek, szkarłatna trawa, mech i obsydian, piekielne krzaki, martwe drzewa, paproć, ogniokwiat i pucestal do zbierania, jaskinie z rudami, lawa, goliaty, obserwatorzy, legiony, siarkodemony, lawowe pędraki, nory wypuszczające zwierzęta (zniszczona nora się zawala i zostawia rudę), rzadko kryształowy goliat, zapomniany obserwator i zniekształcony legion, przy górnej krawędzi jedna duża ruina z Shiptesta (Dynamitowa Dziura, Zniszczona Fabryka, Rozbity Starwalker, Opuszczony Posterunek Nasłuchowy albo Ostatni Bastion Twardogłowych, z zasilaniem i powietrzem), małe ruiny Lavalandu, co kilka minut burza popiołu tylko na tej planecie (ludzie na okręcie nic nie widzą). Lawa i skała pod kadłubem nie przejdą (czerwony obrys, negatyw). \
	3) Lornetka: przyłożona do oczu (oburącz), kliknięcie pola na powierzchni i 4 s bez ruchu → czerwony znacznik, komunikat na mostku. Na okręcie (nie na planecie) → odmowa (negatyw). Z mostka strzał z NAC albo torpeda w planetę → na ziemi przy znaczniku przez 4 s cel i świst, potem wybuch. Bez znacznika uderzenie w losowe miejsce. PDC i lekkie działka nic nie robią. \
	4) Kapsuła: usiąść w wyrzutni (najlepiej w hangarze, w skafandrze), „Cel zrzutu” → lądowisko, znacznik albo kamera, „Zrzut” → kapsuła zamyka się, wylatuje w górę, na celu przez 8 s świeci znacznik, kapsuła spada (wybuch bez obrażeń dla pasażera), otwiera się, a jej skorupa zostaje. Lądowanie do 2 pól od celu. Wyrzutnia przez 2 minuty pokazuje pusty luk. W układzie bez planety → komunikat (negatyw). \
	5) Skok FTL: z kimś żywym na planecie → ostrzeżenie dla ludzi na dole i na mostku, planeta zostaje; prom na planecie bez okrętu w układzie nie wystartuje (negatyw). Bez nikogo na dole → po kilkunastu sekundach powierzchnia znika (log „surface unloaded”). \
	6) Misje (wybór w zestawie albo u kapitana): „Badanie planety” → skrzynia ze sprzętem kapsułą na okręt, punkt badawczy na GPS po lądowaniu, sonda w punkcie 3 minuty, 4 rodzaje próbek na okręcie → misja wykonana. „Ewakuacja kolonii” → schron z 4 kolonistami (sygnał GPS „Schron kolonii”), duchy dostają propozycję, koloniści-NPC idą za załogą, 3 żywych na okręcie → wykonana, 2 martwych → nieudana. „Próbki geologiczne” → skrzynia z wiertłem misji i druga ze skanerem i częściami, na planecie żyła wymaganej klasy (skaner w trybie podziemia ją wskazuje), wiertło misji na żyle zbiera próbki zamiast rudy, po wymaganej liczbie wiertło na okręt → wykonana; zniszczone wiertło → nieudana. „Głęboki odwiert” → skrzynia z wiertłem do próbek głębinowych i skrzynia z pojemnikiem, na planecie żyła klasy 4 (klasy 4 generator sam nie stawia), wiertło wydobywa próbkę, próbkę do pojemnika, pojemnik na okręt → wykonana, z wiertłem dopłata; zniszczony pojemnik albo próbka → nieudana. \
	7) Wiertło: na żyle (skaner przyłożony do żyły podaje klasę i rudy) klucz, potem włączenie ręką → co ~30 s ruda, a co 45 s przy żyle otwierają się wyrwy sejsmiczne wypuszczające goliaty, legiony i siarkodemony (trzy fale, potem minuta przerwy). Na żyle klasy 4 fale są większe i częstsze, a żyła daje kryształy bluespace. Uszkodzone wiertło psuje się: wymiana części, spawarka albo multitool. Alt-klik zatrzymuje. Bez żyły pod spodem nie ruszy (negatyw). \
	8) Anomalie: na równinach planety nieruchome anomalie (bluespace, strumienia, grawitacyjna, halucynacji, piroklastyczna, dusza plazmy), które nie znikają same. Analizator podaje częstotliwość i kod, sygnalizator z nimi neutralizuje anomalię i zostawia rdzeń. Dusza plazmy co kilka sekund wstrzykuje plazmę ludziom w promieniu 3 pól. \
	9) Łupy: oskórowany kryształowy goliat daje dziwne kryształy (nóż rozbija na kryształową krawędź do szklanek, młynek daje Odczynnik kryształowy, który leczy), zniekształcony legion zostawia kryształowe serce (jak rdzeń regeneracyjny), siarkodemon siarkowy pył (zgarnia się zlewką), a z pyłu, kości i ścięgna da się zrobić czujnik rud na ucho."
	items = list(
		/obj/machinery/drop_pod_bay = 1,
		/obj/item/binoculars/tactical = 1,
		/obj/item/planet_sample_kit = 1,
		/obj/item/planet_survey_probe = 1,
		/obj/item/gps/mining = 1,
		/obj/item/clothing/suit/hooded/explorer = 1,
		/obj/item/clothing/mask/gas/explorer = 1,
		/obj/item/tank/internals/emergency_oxygen/engi = 1,
		/obj/machinery/drill = 1,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/pinpointer/mineral = 1,
		/obj/item/analyzer = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/kitchen/knife = 1,
	)

/datum/test_chamber_kit/pr_639/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
#ifndef UNIT_TESTS
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!user || !ship?.current_system)
		return
	if(tgui_alert(user, "Dodać planetę wulkaniczną w układzie okrętu ([ship.current_system]), 20 pól od okrętu?", "Komora testowa", list("Tak", "Nie")) == "Tak")
		var/planet_x = clamp(ship.x + 20, 30, world.maxx - 40)
		var/obj/structure/overmap/planet/planet = ship.current_system.add_planet(/datum/planet_type/lava, planet_x, clamp(ship.y, 30, world.maxy - 40))
		to_chat(user, span_notice("Dodano [planet] w układzie [ship.current_system]."))
	var/datum/controller/subsystem/overmap_mode/omode = SSovermap_mode
	if(!omode.mode || omode.mission_choice_pending || omode.extension_choice_pending)
		return
	var/static/list/missions = list(
		"Badanie planety" = /datum/overmap_objective/planet/survey,
		"Ewakuacja kolonii" = /datum/overmap_objective/planet/evacuation,
		"Próbki geologiczne" = /datum/overmap_objective/planet/drill_samples,
		"Głęboki odwiert" = /datum/overmap_objective/planet/deep_vein,
	)
	var/picked = tgui_input_list(user, "Dodać misję planetarną do obecnych celów? (Anuluj = bez misji)", "Komora testowa", missions)
	if(!picked)
		return
	var/mission_type = missions[picked]
	var/datum/overmap_objective/planet/mission = new mission_type(ship.current_system)
	omode.mode.objectives += mission
	mission.objective_number = length(omode.mode.objectives)
	mission.instance()
	to_chat(user, span_notice("Dodano misję [picked] w układzie [mission.target_system] ([mission.target_planet])."))
#endif
