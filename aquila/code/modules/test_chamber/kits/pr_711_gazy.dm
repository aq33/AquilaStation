// aq33/AquilaStation#711 - plan maszynowni E5–E8: ogień liczony jak w auxmos, wodór i elektrolizer, frezon, metan

/datum/test_chamber_kit/pr_711
	name = "PR 711: ogień, wodór, frezon, metan"
	pr = "aq33/AquilaStation#711"
	description = "Kanistry nowych gazów, elektrolizer, bańka gazu bagiennego i narzędzia. \
	1) Elektrolizer: otwórz okno (klik), włącz; obok wypuść trochę pary wodnej z kanistra. Analizator gazów na kafelku: para ubywa, przybywa wodoru i połowa tyle tlenu. Odkręcony działa na ogniwie (pasek w oknie spada), przykręcony kluczem bierze prąd z komory i ładuje ogniwo. Śrubokręt otwiera właz, przycisk w oknie wyjmuje ogniwo. \
	2) Wodór i metan: wypuść trochę z kanistra i zapal spawarką. Pali się od samej iskry (wcześniej paliła się tak tylko plazma i tryt), po pożarze w powietrzu jest para wodna, a po metanie też CO2. \
	3) Frezon: wypuść odrobinę do powietrza (azot!) i patrz na termometr analizatora: kafelek gwałtownie się chłodzi, a w powietrzu pojawia się podtlenek azotu. Wdech frezonu bez maski: tęcza, upojenie i komunikat o zimnie w płucach. \
	4) Bańka gazu bagiennego co około 40 s wypuszcza 4 mole metanu (analizator na jej kafelku). Na planecie dżungli bańki są na błotach. \
	5) Progi alarmu powietrza i ceny eksportu z danych gazu sprawdza test aquila_generic_fire (w komorze nie ma alarmu)."
	items = list(
		/obj/machinery/electrolyzer = 1,
		/obj/machinery/portable_atmospherics/canister/water_vapor = 1,
		/obj/machinery/portable_atmospherics/canister/hydrogen = 1,
		/obj/machinery/portable_atmospherics/canister/methane = 1,
		/obj/machinery/portable_atmospherics/canister/frezon = 1,
		/obj/structure/swamp_gas = 1,
		/obj/item/analyzer = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/clothing/mask/gas = 1,
	)
