// aq33/AquilaStation#719 - reaktor fuzyjny HFR i wybór silnika HFR (plan maszynowni, etapy E17–E18)

/datum/test_chamber_kit/pr_719
	name = "PR 719: reaktor fuzyjny HFR"
	pr = "aq33/AquilaStation#719"
	description = "Dziewięć skrzynek HFR, kanistry z paliwem i chłodziwem, multitool i karta głównego inżyniera. \
	1) Ułóż skrzynki w kwadrat 3×3 (rdzeń w środku, narożniki w rogach, wloty, wylot i panel po bokach) i użyj multitoola na skrzynce rdzenia: powstaje reaktor. \
	2) Multitool na panelu sterowania: części się łączą, wypada poradnik, okno otwiera się po kliknięciu panelu. Teksty po polsku, na liście paliw tylko trzy: plazma + tlen, tryt + tlen, wodór + tryt. \
	3) Podłącz kanister z wodorem i trytem do wlotu paliwa (rurą albo portem), plazmę albo hel do pętli chłodzącej. Włącz zasilanie i chłodzenie, wybierz wodór + tryt, włącz wtrysk paliwa, przewodnik ciepła na 500. \
	4) Po rozgrzaniu (VV: internal_fusion.set_temperature(5000) przyspiesza) poziom fuzji rośnie, w komorze fuzji pojawia się hel, a kolektory promieniowania obok dają prąd. \
	5) VV: critical_threshold_proximity 100. Przycisk Wyrzut rdzenia na dole okna z kartą głównego inżyniera: 30 s odliczania, potem komora fuzji i moderator są puste, a uszkodzenia zerowe. \
	6) Przełącz język gry na angielski: okno, opisy i komunikaty radia mają być po angielsku. \
	7) Wybór silnika (poza komorą): w preferencjach jest Reaktor fuzyjny HFR. Główny inżynier z tą preferencją na Atlasie, Trawniku albo Padalcu dostaje w maszynowni HFR w dawnej komorze supermaterii, z portami paliwa i moderatora od strony korytarza i panelem sterowania przy wschodnich drzwiach. Bez takiego wyboru HFR nigdy nie wypada w losowaniu."
	items = list(
		/obj/item/hfr_box/corner = 4,
		/obj/item/hfr_box/body/fuel_input = 1,
		/obj/item/hfr_box/body/moderator_input = 1,
		/obj/item/hfr_box/body/waste_output = 1,
		/obj/item/hfr_box/body/interface = 1,
		/obj/item/hfr_box/core = 1,
		/obj/machinery/portable_atmospherics/canister/hydrogen = 1,
		/obj/machinery/portable_atmospherics/canister/tritium = 1,
		/obj/machinery/portable_atmospherics/canister/oxygen = 1,
		/obj/machinery/portable_atmospherics/canister/toxins = 1,
		/obj/machinery/portable_atmospherics/canister/helium = 1,
		/obj/machinery/power/rad_collector/anchored = 2,
		/obj/item/multitool = 1,
		/obj/item/card/id/job/chief_engineer = 1,
	)
