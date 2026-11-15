/datum/test_chamber_kit/pr_643_glowice
	name = "Głowice specjalne torped"
	pr = "aq33/AquilaStation#643"
	description = "Pięć torped z głowicami specjalnymi (zapalająca, chemiczna, ogłuszająca, jonowa, desantowa). \
		Załaduj je do wyrzutni torped okrętu i strzel w okręt Syndykatu: bez wnętrza w oknie modułów celu widać pożar, straty załogi albo moduł wyłączony na 10 s; z wczytanym wnętrzem (Call Proc ai_load_interior) skutek pojawia się na pokładzie w miejscu trafienia. \
		Odwrotnie: ustaw zmienną globalną ai_special_torpedo_chance na 100 i zespawnuj przy okręcie /obj/structure/overmap/syndicate/ai/destroyer/elite (ma wyrzutnię torped); jego torpedy powinny podpalać, truć, ogłuszać, robić EMP albo zrzucać 3 droidy na pokład w miejscu trafienia, także przy pełnym pancerzu (wtedy tuż za poszyciem). \
		Głowice są też w protolacie amunicji (węzeł „Głowice specjalne”) i w paczce „Głowice torped specjalne” w zaopatrzeniu."
	items = list(
		/obj/item/ship_weapon/ammunition/torpedo/special_incendiary = 1,
		/obj/item/ship_weapon/ammunition/torpedo/special_chemical = 1,
		/obj/item/ship_weapon/ammunition/torpedo/special_flash = 1,
		/obj/item/ship_weapon/ammunition/torpedo/special_ion = 1,
		/obj/item/ship_weapon/ammunition/torpedo/special_boarding = 1,
	)

/datum/test_chamber_kit/pr_643_walka
	name = "Skutki trafień, amunicja, działa, strefy"
	pr = "aq33/AquilaStation#643"
	description = "Odłamki: zespawnuj przy okręcie wrogi okręt i daj mu zbić pancerz ćwiartki; trafienie przez zbity pancerz wypuszcza za poszyciem odłamki w głąb, a przy głębokim wyłomie idzie seria małych wybuchów w kierunku lotu. \
		Wybuch amunicji: podpal worek prochu (np. zapalniczką i plazmą na podłodze) albo strzel w niego; po 2–4 s syczenia wybucha, a wyjęty z ognia stygnie. \
		Kalibracja: przy MAC, railgunie albo dziale pokładowym odkręć panel śrubokrętem i użyj multitoola, odgadnij 4 cyfry (6 prób); spalony aktuator wyjmij łomem i włóż manipulator; strzał z otwartym panelem poraża. \
		Strefy: Debug > Toggle overmap hazards; w układzie z polem szczątków albo mgławicą widać strefy na DRADIS; szybki przelot przez pole asteroid ściąga meteory, mgławica ukrywa i zakłóca radio, burza zrywa maskowanie."
	items = list(
		/obj/item/powder_bag = 2,
		/obj/item/multitool = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/lighter = 1,
	)
