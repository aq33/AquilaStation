/datum/test_chamber_kit/pr_455
	name = "Tweaki"
	pr = "aq33/AquilaStation#455"
	description = "Siedem niezależnych drobiazgów, każdy w osobnym kroku. \
		1) Toaleta stoi odkręcona: przykręć ją kluczem, potem odkręć i przesuń → oczekiwane: da się to robić wielokrotnie. Konsola cargo z zestawu, dział Service → oczekiwane: paczki „Toaleta” (1000 kr) i „Toalety (3 szt.)” (2500 kr), przyjeżdżają odkręcone. \
		2) Starożytny syntezator: Alt+klik i wskaż plik dźwiękowy z dysku (wymaga pliku na twoim komputerze), Ctrl+klik zmienia głośność 1-100, użycie w ręce odtwarza → oczekiwane: dźwięk gra, a admini dostają komunikat. Negatyw: bez pliku nic się nie odtwarza. \
		3) Skrzynka zabawek klauna → oczekiwane: 5 losowych zabawek (tylko typ zabawek). \
		4) Wstrzyknij sobie clumsy i pierdz (*fart) wiele razy → oczekiwane: za ok. 5% razy wypluwasz losowy organ z krwią i dźwiękiem „splat”; zwykle nic się nie dzieje, więc powtarzaj. \
		5) Stoperan: połknij 5 pigułek naraz (25 j.) → oczekiwane: skurcze, po ok. 16 s wybuch z brązowymi plamami. Negatyw: połknij tylko 2 (10 j.) → oczekiwane: brak przedawkowania i wybuchu. \
		6) Syntezator chemiczny (kanalizacja): przykręć kluczem, wybierz odczynnik, odczekaj → oczekiwane: prekursor w examine rośnie sam o 1 j./s do 2000. \
		7) Szafka górnika (bez zamka) → oczekiwane: leży w niej kombinezon bitrunnera. Rolę Bitrunner sprawdzisz tylko w lobby (nie ma jej na liście prac), a dostęp górnika do pracowni sprawdzisz na mapie."
	items = list(
		/obj/structure/toilet/unanchored = 1,
		/obj/item/wrench = 1,
		/obj/item/soundsynth/ancient = 1,
		/obj/item/storage/toolbox/clown_toys = 1,
		/obj/item/dnainjector/clumsymut = 1,
		/obj/item/reagent_containers/pill/stoperan = 5,
		/obj/machinery/plumbing/synthesizer = 1,
		/obj/structure/closet/secure_closet/miner/unlocked = 1,
		/obj/machinery/computer/cargo = 1,
	)
