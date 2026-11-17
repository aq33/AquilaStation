/datum/test_chamber_kit/pr_nsvprzyw_statek
	name = "Przywrócone NSV: studnia nanonaprawcza i holomapa"
	pr = "aq33/AquilaStation#657"
	description = "Moduły podkręcania: weź trzy moduły i łom, idź do studni nanonaprawczej statku (pomieszczenie pomp pancerza w inżynierii). \
		1. Włóż moduł nadmiaru mocy: w oknie studni suwak mocy sięga 12 MW, a przy mocy powyżej 3 MW powietrze przy studni się nagrzewa. Drugi taki sam moduł studnia odrzuca. \
		2. Włóż przeciążenie i chłodzenie, obejrzyj studnię: opis wspomina wyważanie łomem. \
		3. Łom wyjmuje ostatnio włożony moduł (komunikat po polsku), parametr wraca do zwykłego, wyjęty moduł da się włożyć z powrotem. \
		4. Moduły są w badaniach (Zaawansowana inżynieria, protolathe inżynierii) i w ofercie stoczni Minsky Heavy Engineering. \
		Holomapa inżynieryjna: płytka jest w badaniach (Inżynieria przemysłowa, imprinter). Zestaw daje ramę, płytkę i części: zbuduj, kluczem obróć przy otwartym panelu. W komorze mapa pokaże, że obszaru nie da się zmapować, to normalne. \
		Na statku dotknij holomapy: hologram pokładu, po podpaleniu pomieszczenia albo rozszczelnieniu na planie pojawiają się znaczniki alarmów pożarowych i atmosferycznych (mapę zamknij i otwórz ponownie). \
		Holomapy na mapach: Atlas mostek (131,120) ściana wschodnia, Atlas atmosferyka przy wejściu (112,140) ściana północna; \
		Trawnik sala odpraw mostka (169,122) ściana południowa, korytarz inżynierii (86,128) ściana północna; \
		Serendipity mostek (158,133) ściana południowa, inżynieria (133,144) ściana zachodnia; \
		Atlantis mostek (128,141) ściana południowa, inżynieria przy schodach (83,120) ściana zachodnia; \
		Von Neumann mostek (155,90) ściana południowa, sterownia reaktora (47,93) ściana zachodnia."
	items = list(
		/obj/item/apnw_oc_module/power = 1,
		/obj/item/apnw_oc_module/load = 1,
		/obj/item/apnw_oc_module/cooling = 1,
		/obj/item/crowbar = 1,
		/obj/structure/frame/machine = 1,
		/obj/item/circuitboard/machine/station_map/engineering = 1,
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/micro_laser/ultra = 4,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/storage/belt/utility/full = 1,
	)
