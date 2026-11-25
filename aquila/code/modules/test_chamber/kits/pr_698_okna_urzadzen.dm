// aq33/AquilaStation#698 - okna maszyn w formie urządzeń (PixelUi, port pomysłu z Polonium Station)

/datum/test_chamber_kit/pr_698
	name = "Okna urządzeń: mikrofalówka, młynek, dozowniki, utylizator, pulpit fabrykatora"
	pr = "aq33/AquilaStation#698"
	description = "1) Mikrofalówka: włóż jedzenie, kliknij maszynę - okno z komorą, rzeczy na talerzu, kliknięcie rzeczy wyjmuje ją do ręki, START zamyka drzwiczki, talerz się kręci, wyświetlacz odlicza, po końcu GOTOWE i jedzenie na podłodze. Prawy przycisk dalej włącza od razu. \
	2) Młynek: kliknij dzbanek z pomidorem w ręce (wrzuca), MIEL i WYCIŚNIJ trzęsą zawartością i lecą do zlewki, kartka pokazuje odczynniki, kliknięcie zlewki ją oddaje, z pustą niszą i zlewką w ręce - wstawia. \
	3) Dozownik alkoholi: butelki na półce i klawisze nalewają do szklanki pod dyszą (strumień w kolorze napoju, lód kostkami), DAWKA, WYLEJ, WYJMIJ, STARE otwiera stare okno z recepturami; dozownik napojów bez półki. \
	4) Blok utylizacyjny: pociągnij dźwignię myszką w dół albo kliknij, lampki, wskaźnik ciśnienia, przełącznik pompy, kliknięcie otworu z przedmiotem w ręce wrzuca, pustą ręką wyjmuje ostatni. \
	5) Autolat i protolat: pulpit z katalogiem (szukanie, kategorie pod klawiszami), ilość +/-, kliknięcie projektu drukuje, ploter rysuje przedmiot, zlecenia na stojaku (autolat), STOP zatrzymuje, przytrzymany czyści kolejkę, klawisz z kreskami otwiera stare okno. \
	Sprawdź oba tryby sterowania (combat mode i intencje) przy klikaniu maszyn."
	items = list(
		/obj/machinery/microwave = 1,
		/obj/item/food/donkpocket = 2,
		/obj/item/food/grown/tomato = 3,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/machinery/reagentgrinder = 1,
		/obj/machinery/chem_dispenser/drinks/beer = 1,
		/obj/machinery/chem_dispenser/drinks = 1,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
		/obj/machinery/disposal/bin = 1,
		/obj/item/trash/can = 2,
		/obj/machinery/modular_fabricator/autolathe = 1,
		/obj/machinery/rnd/production/protolathe = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
	)
