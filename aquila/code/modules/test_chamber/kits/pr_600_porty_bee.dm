/datum/test_chamber_kit/pr_600
	name = "Porty z Bee: jetpack, dostępy, żołądek, promieniowanie"
	pr = "aq33/AquilaStation#600"
	description = "Zestaw: plecak odrzutowy, hardsuit inżynieryjny, kombinezon i kaptur przeciwradiacyjny, licznik Geigera, pręt plutonowy, butelka jodku potasu, analizator zdrowia, strzykawka, butelka toksyny, burger, cola, konsola ID, konsola dowództwa NtOS (program kart), konsola Centrali, zapasowa karta kapitana, karta Centrali i czysta karta. \
	1) Jetpack: załóż plecak, włącz go i wyjdź w kosmos. Lot zużywa paliwo (analizator gazu na butli: spada z każdym krokiem w próżni), w grawitacji nie zużywa. Ze stabilizacją postać staje po puszczeniu klawisza, bez niej dryfuje dalej. Pusta butla → plecak się wyłącza (negatyw). Jetpack trzymany w ręce nie ma przycisku włączania (negatyw). Puść ciągnięty przedmiot w locie → leci dalej. Tło kosmosu przesuwa się płynnie; skok FTL i widok pilota na overmapie bez zmian. \
	2) Dostępy: włóż kartę kapitana i czystą kartę do konsoli ID → 8 grup stacji po polsku, zaznaczenie pojedynczego dostępu działa. Ustaw czystej karcie stanowisko MAA, wyloguj się i zaloguj kartą MAA → widzi tylko Uzbrojenie, dostępu Kapitana nie nada (negatyw). Degraduj Majtka → działa. W konsoli dowództwa otwórz program kart i zaloguj się kartą kapitana → od razu widać grupy (bez ponownego otwierania okna), „Nadaj region” daje kliknięty dział. Na konsoli Centrali kartą Centrali: grupy Centrala i Inne. \
	3) Żołądek: zjedz burgera i wypij colę, zeskanuj analizatorem → reagenty w sekcji „Zawartość żołądka”, po ok. 40 s we krwi. Wstrzyknij 10 j. toksyny strzykawką → od razu we krwi, wątroba dostaje uszkodzenia; 2 j. toksyny w jedzeniu → bez efektu. Zwymiotuj → ubywa z żołądka, nie z krwi. \
	4) Promieniowanie: stań obok pręta plutonowego bez ochrony → licznik Geigera trzeszczy i pokazuje stopień, skan pokazuje procent napromieniowania; od 20% poświata i alert. W pełnym kombinezonie przeciwradiacyjnym → brak przyrostu; w hardsuicie inżynieryjnym z hełmem też. Sam strój bez hełmu nie chroni (negatyw). Odejdź → procent spada sam ok. 0,1%/s, jodek potasu szybciej. Ściana między tobą a prętem osłabia impuls."
	items = list(
		/obj/item/tank/jetpack/oxygen = 1,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/item/clothing/suit/radiation = 1,
		/obj/item/clothing/head/radiation = 1,
		/obj/item/geiger_counter = 1,
		/obj/item/fuel_rod/plutonium = 1,
		/obj/item/reagent_containers/glass/bottle/potass_iodide = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/reagent_containers/glass/bottle/toxin = 1,
		/obj/item/food/burger/plain = 1,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola = 1,
		/obj/machinery/computer/card = 1,
		/obj/machinery/modular_computer/console/preset/command = 1,
		/obj/machinery/computer/card/centcom = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/card/id/centcom = 1,
		/obj/item/card/id = 1,
	)
