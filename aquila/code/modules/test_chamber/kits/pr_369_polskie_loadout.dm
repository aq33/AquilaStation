// aq33/AquilaStation#369 - polskie przedmioty i bielizna do odblokowania za Aquilosy

/datum/test_chamber_kit/pr_369
	name = "PR 369: polskie przedmioty i bielizna w loadoucie"
	pr = "aq33/AquilaStation#369"
	description = "Test wymaga co najmniej 3000 Aquilosów na koncie (zakup zapisuje się w bazie, więc zestaw nie nadaje salda sam - dodaj je przez verb Modify Metacoins w panelu admina). Zakup i lista \"Unlocked\" są w ustawieniach postaci (zakładka loadoutu), poza areną. \
	1) W loadoucie sprawdź ceny → oczekiwane: reklamówki Biedronki i Lidla (General) po 500, sandały ze skarpetkami (Footwear) 1000, kategoria \"Polska bielizna\" po 1000 za wzór; przy każdym ikonka i przycisk \"Podgląd\". \
	2) Kliknij \"Podgląd\" przy bieliźnie → oczekiwane: postać w podglądzie ma bieliznę bez ubrania; drugi klik wyłącza podgląd. \
	3) Na arenie użyj komody (dresser) przed jakimkolwiek zakupem → oczekiwane: na listach bielizny, koszulek i skarpet nie ma polskich wzorów (blokada). \
	4) Kup jeden polski wzór bielizny, wejdź do komory ponownie i użyj komody → oczekiwane: kupiony wzór jest na liście, pozostałe niekupione nadal ukryte. \
	5) W loadoucie kupiony wzór ma napis \"Unlocked\" i jest wybieralny w Underwear/Undershirt/Socks. \
	6) Negatyw: spróbuj kupić przedmiot z saldem poniżej ceny → oczekiwane: odmowa, brak odjęcia. Ustaw niekupiony wzór i wczytaj postać → oczekiwane: zmienia się na \"Nude\". \
	7) Przedmioty na arenie (reklamówki, sandały) podnieś i załóż → oczekiwane: poprawne sprite'y; reklamówka mieści przedmioty."
	items = list(
		/obj/structure/dresser = 1,
		/obj/item/storage/commercial/reklamowka_biedronka = 1,
		/obj/item/storage/commercial/reklamowka_lidl = 1,
		/obj/item/clothing/shoes/aquila/aq_sandals = 1,
	)
