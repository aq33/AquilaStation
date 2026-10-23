// aq33/AquilaStation#369 - polskie przedmioty i bielizna do odblokowania za Aquilosy

/datum/test_chamber_kit/pr_369
	name = "PR 369: polskie przedmioty i bielizna w loadoucie"
	pr = "aq33/AquilaStation#369"
	description = "Większość testu jest w ustawieniach postaci (zakładka loadoutu): reklamówki Biedronki i Lidla (General, 500), sandały ze skarpetkami (Footwear, 1000), \
	kategoria \"Polska bielizna\" (1000 za wzór). Przy każdym przedmiocie ikonka i przycisk \"Podgląd\" (postać w podglądzie ubrana w przedmiot, bielizna bez ubrania, drugi klik wyłącza). \
	Kupiona bielizna ma napis \"Unlocked\" i pojawia się na liście Underwear/Undershirt/Socks; niekupiona się nie pojawia, a ustawiona wcześniej zmienia się na \"Nude\". \
	W komorze: komoda nie może pokazywać niekupionych polskich wzorów (obejście blokady). Obok przedmioty z loadoutu do obejrzenia sprite'ów."
	items = list(
		/obj/structure/dresser = 1,
		/obj/item/storage/commercial/reklamowka_biedronka = 1,
		/obj/item/storage/commercial/reklamowka_lidl = 1,
		/obj/item/clothing/shoes/aquila/aq_sandals = 1,
	)
