/datum/test_chamber_kit/pr_639
	name = "Planety: lądowanie, kapsuły, ostrzał i misje"
	pr = "aq33/AquilaStation#639"
	description = "Zestaw: wyrzutnia kapsuł desantowych, lornetka taktyczna, zestaw do próbek, sonda badawcza, GPS i sprzęt górnika (kombinezon, maska, butla). Na serwerze (nie w CI) zestaw pyta, czy dodać planetę wulkaniczną w układzie okrętu i czy dodać misję planetarną. \
	1) Planeta: na overmapie duży sprite planety bez kolizji, na DRADIS-ie jej nie ma. Stanowisko rozpoznania, obiekt „planeta”, przycisk „Skanuj planetę” → opis z typem, atmosferą i zagrożeniami (oględziny planety). Za daleko (ponad 60 pól) → komunikat, że trzeba podlecieć (negatyw). \
	2) Lądowanie: Sabre w trybie dokowania nad środkiem planety → komunikat o mapowaniu, po kilku-kilkunastu sekundach wybór lądowiska (Alfa, Bravo, Charlie), kamera lądowania nad lądowiskiem, „Wyląduj tutaj” → prom stoi na bazalcie. Na powierzchni: krawędź z nieprzebytych skał, jaskinie z rudami, lawa, goliaty i inne moby, ruiny Lavalandu, co kilka minut burza popiołu tylko na tej planecie (ludzie na okręcie nic nie widzą). Lawa i skała pod kadłubem nie przejdą (czerwony obrys, negatyw). \
	3) Lornetka: przyłożona do oczu (oburącz), kliknięcie pola na powierzchni i 4 s bez ruchu → czerwony znacznik, komunikat na mostku. Na okręcie (nie na planecie) → odmowa (negatyw). Z mostka strzał z NAC albo torpeda w planetę → na ziemi przy znaczniku przez 4 s cel i świst, potem wybuch. Bez znacznika uderzenie w losowe miejsce. PDC i lekkie działka nic nie robią. \
	4) Kapsuła: usiąść w wyrzutni (najlepiej w hangarze, w skafandrze), „Cel zrzutu” → lądowisko, znacznik albo kamera, „Zrzut” → lot kapsułą zaopatrzeniową, lądowanie do 2 pól od celu. Wyrzutnia przez 2 minuty bez kapsuły. W układzie bez planety → komunikat (negatyw). \
	5) Skok FTL: z kimś żywym na planecie → ostrzeżenie dla ludzi na dole i na mostku, planeta zostaje; prom na planecie bez okrętu w układzie nie wystartuje (negatyw). Bez nikogo na dole → po kilkunastu sekundach powierzchnia znika (log „surface unloaded”). \
	6) Misje: „Badanie planety” → skrzynia ze sprzętem kapsułą na okręt, punkt badawczy na GPS po lądowaniu, sonda w punkcie 3 minuty, 4 rodzaje próbek na okręcie → misja wykonana. „Ewakuacja kolonii” → schron z 4 kolonistami (sygnał GPS „Schron kolonii”), duchy dostają propozycję, koloniści-NPC idą za załogą, 3 żywych na okręcie → wykonana, 2 martwych → nieudana."
	items = list(
		/obj/machinery/drop_pod_bay = 1,
		/obj/item/binoculars/tactical = 1,
		/obj/item/planet_sample_kit = 1,
		/obj/item/planet_survey_probe = 1,
		/obj/item/gps/mining = 1,
		/obj/item/clothing/suit/hooded/explorer = 1,
		/obj/item/clothing/mask/gas/explorer = 1,
		/obj/item/tank/internals/emergency_oxygen/engi = 1,
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
