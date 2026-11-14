/datum/test_chamber_kit/pr_643
	name = "Wnętrza abordażu: Syndykat i piraci"
	pr = "aq33/AquilaStation#643"
	description = "Jako admin zespawnuj na overmapie przy okręcie jeden z okrętów: /obj/structure/overmap/syndicate/ai/cruiser (Barracuda), /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/kadesh, /obj/structure/overmap/syndicate/ai/assault_cruiser (Inquisitor), /obj/structure/overmap/syndicate/ai/submarine (Aspala), /obj/structure/overmap/spacepirate/ai (frachtowiec), /obj/structure/overmap/spacepirate/ai/nt_missile, /obj/structure/overmap/spacepirate/ai/syndie_gunboat albo /obj/structure/overmap/spacepirate/ai/dreadnought. \
		Wnętrze wczytasz konsolą odzysku (zakłócanie celu) albo przez Call Proc ai_load_interior(główny okręt) na tym okręcie. \
		Sprawdź: wejście śluzą i dokowanie promem, czy każde pomieszczenie jest osiągalne, światło, KNPC chodzą po punktach patrolu, konsole na mostku i IFF działają. \
		Na pirackich okrętach są piraci KNPC i nie ma ról duchów; Barracuda, Kadesh i piracka kanonierka mają działo MAC z lufą przez dziób."
	items = list(
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/ammo_box/magazine/smgm45 = 2,
		/obj/item/flashlight/seclite = 1,
		/obj/item/multitool = 1,
	)

/datum/test_chamber_kit/pr_643_konsole
	name = "Konsole okrętu: scalone okna i nowy wygląd"
	pr = "aq33/AquilaStation#643"
	description = "Konsole stoją na mostku i w inżynierii okrętu (Padalec, Atlas, Von Neumann, Trawnik). \
		Stanowisko rozpoznania: wszystko jak dotąd plus „Wywołaj” w karcie kontaktu; usiądź przy sterze, a otworzy się to samo okno tylko do podglądu (bez sterowania sensorami). \
		Konsola taktyczna: sekcja „Obrona punktowa (AMS)” pod uzbrojeniem (źródło celów, tryby, liczba strzałów). \
		Nawigacja: zakładka „Napęd FTL” rozkręca stary napęd tylko z dostępem inżynierii; komputer FTL w maszynowni otwiera to samo okno na tej zakładce. \
		Lotnictwo (kontrola lotów i konsola katapult) i Odzysk i abordaż (zakłócacz i magnes) mają po dwie zakładki, każda konsola otwiera swoją. \
		Kontrola uszkodzeń: przedziały na schemacie mają prawdziwy kształt, korytarze nie zasłaniają pomieszczeń. \
		Wszystkie okna konsol okrętu mają wygląd stanowiska rozpoznania."
	items = list(
		/obj/item/card/id/captains_spare = 1,
	)
