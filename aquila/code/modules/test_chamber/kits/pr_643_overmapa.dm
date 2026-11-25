/datum/test_chamber_kit/pr_643
	name = "Wnętrza abordażu: Syndykat i piraci"
	pr = "aq33/AquilaStation#643"
	description = "Jako admin zespawnuj na overmapie przy okręcie jeden z okrętów: /obj/structure/overmap/syndicate/ai/cruiser (Barracuda), /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/kadesh, /obj/structure/overmap/syndicate/ai/assault_cruiser (Inquisitor), /obj/structure/overmap/syndicate/ai/submarine (Aspala), /obj/structure/overmap/spacepirate/ai (frachtowiec), /obj/structure/overmap/spacepirate/ai/nt_missile, /obj/structure/overmap/spacepirate/ai/syndie_gunboat, /obj/structure/overmap/spacepirate/ai/dreadnought,/obj/structure/overmap/syndicate/ai/fistofsol (Fist of Sol) albo /obj/structure/overmap/syndicate/ai/battleship (Sol's Revenge, boss). \
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
		Ekran taktyczny: stanowisko rozpoznania, konsola taktyczna, DRADIS mostka, monitorowanie uzbrojenia i konsola AMS otwierają jedno okno z trybami Rozpoznanie, Ogień i Podgląd. Stanowisko startuje w Rozpoznaniu i tylko z niego da się sterować sensorami; konsola taktyczna (gdy siedzisz przy niej jako strzelec) startuje w Ogniu, z AMS pod uzbrojeniem; pozostałe konsole otwierają Podgląd, a przyciski innych trybów są wyszarzone. Usiądź przy sterze: okno otwiera się w Podglądzie z przyciskiem „Impuls radaru”, a w karcie kontaktu jest „Wywołaj”. Myśliwce na radarze mają mały wypełniony znacznik ze strzałką kursu, a na zasięgu 200 pól przerywany obrys. \
		Nawigacja: zakładka „Napęd FTL” rozkręca stary napęd tylko z dostępem inżynierii; komputer FTL w maszynowni otwiera to samo okno na tej zakładce. \
		Lotnictwo (kontrola lotów i konsola katapult) i Odzysk i abordaż (zakłócacz i magnes) mają po dwie zakładki, każda konsola otwiera swoją. \
		Wszystkie okna konsol okrętu mają wygląd stanowiska rozpoznania. \
		Szafka kontroli uszkodzeń (szara z żółtymi drzwiami) stoi w korytarzach przy drzwiach pożarowych; w środku gaśnice, nadmuchiwane ściany, uszczelniacz i taśma."
	items = list(
		/obj/item/card/id/captains_spare = 1,
		/obj/structure/closet/damage_control = 1,
	)

/datum/test_chamber_kit/pr_643_abordaz_cywile
	name = "Abordaż kapsułą i cywile z IFF"
	pr = "aq33/AquilaStation#643"
	description = "Kapsuła: jako admin postaw /obj/machinery/drop_pod_bay na pokładzie okrętu (komora nie leży na okręcie) i zespawnuj przy okręcie na overmapie /obj/structure/overmap/syndicate/ai; zbij mu tarcze. Usiądź w kapsule, „Cel zrzutu” ma teraz pozycję „Abordaż: …”, potem „Zrzut”. Kapsuła leci ok. 30 s, ląduje na losowej podłodze celu i wybija sąsiednią ścianę; zestrzelona przez PDC wyrzuca rannego pasażera w kosmos przy okręcie. \
		Cywile: zespawnuj /obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/independent. Z daleka DRADIS pokazuje klasę („Kontakt 3 (średni)”), po rozpoznaniu niebieski kolor cywila. Strzał w niego: ogłoszenie Centrali, a kupcy niezależni (stacja handlowa) biorą drożej; przy złej reputacji odmawiają. \
		Fałszywy IFF: ustaw zmienną globalną civilian_fake_iff_chance na 100 i zespawnuj okręt Syndykatu; z daleka nadaje się jako frachtowiec, z bliska (8 pól) albo po strzale wychodzi prawda."
	items = list(
		/obj/item/card/id/captains_spare = 1,
	)

/datum/test_chamber_kit/pr_643_mysliwce_rakiety
	name = "Myśliwce przy wrakach, eskorta myśliwców, rakiety w moduł"
	pr = "aq33/AquilaStation#643"
	description = "Wraki: zestrzel okręt AI (np. /obj/structure/overmap/syndicate/ai/gunboat), żeby został wrak. Włóż ładownię z zestawu do myśliwca (hardpoint użytkowy), wystartuj i podleć do wraku na najwyżej 4 pola. W oknie myśliwca sekcja „Wrak:” pokazuje cel i liczbę przeszukań, „Przeszukaj wrak” po 15 s wkłada do ładowni 2 fanty: złom zawsze, a z ocalałych modułów materiały, amunicję działek, broń, apteczki albo części. Odlot w trakcie przerywa przeszukiwanie. \
		Eskorta: na mapie hex w stoczni albo u handlarza bronią kup „Klucz myśliwców eskorty” (1000): dwa myśliwce Viper lecą za okrętem i biją jego cele, liczone osobno od okrętów (do 6 myśliwców i 4 okrętów). \
		Rakiety: w konsoli taktycznej wybierz moduł namierzonego okrętu i strzel torpedą przy pełnym pancerzu: moduł dostaje obrażenia mimo pancerza. Artyleria MAC leci teraz w wybrany moduł zamiast w środek. Torpeda wroga w nasz okręt robi wyłom w losowym miejscu, także przy pełnym pancerzu burty. \n		Skala: myśliwiec na pokładzie jest dwa razy większy (hitbox 2×2 bez zmian), na overmapie dalej mały. Hangary: Atlas 2 myśliwce (jeden przodem do wyjścia), Padalec 1, Von Neumann 2, Atlantis 3; obejrzyj, czy nie wchodzą na ściany i przechodzą przez drzwi hangaru."
	items = list(
		/obj/item/fighter_component/secondary/utility/hold = 1,
		/obj/item/card/id/captains_spare = 1,
	)
