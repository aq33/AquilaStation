/datum/test_chamber_kit/pr_608
	name = "Premie działów, wadliwa SI, statystyki postaci"
	pr = "aq33/AquilaStation#608"
	description = "Zestaw: kajdanki, laser, defibrylator. \
	1) Statystyki: strzel kilka razy z lasera, zakuj obiekt testowy w kajdanki, potem OOC → Statystyki postaci → na górze sekcja „W tej rundzie” z oddanymi strzałami i zakuciami. Zakucie samego siebie się nie liczy (negatyw). Zapis do bazy dopiero na koniec rundy: po restarcie te same liczby są w zakładce postaci, a rozegrane rundy rosną o 1. \
	2) Reanimacja: zabij obiekt testowy (ciało zdatne do reanimacji) i przywróć go defibrylatorem → w oknie „Reanimacje defibrylatorem” rośnie o 1. \
	Poza komorą: automat górniczy sprzedaje „200 kosmicznych kredytów” za 1200 punktów. Premia: jako naukowiec sprzedaj artefakt w konsoli ksenoarcheologii i poczekaj do wypłaty (co 5 minut) → karta mówi „Premia działu nauki za pracę działu: X kr.”. Wadliwa SI: admin ustawia tryb malf przy co najmniej 20 graczach i chętnym z preferencją „Wadliwa SI” i pracą SI; bez takiego gracza tryb nie startuje (negatyw)."
	items = list(
		/obj/item/restraints/handcuffs = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/defibrillator/loaded = 1,
	)
