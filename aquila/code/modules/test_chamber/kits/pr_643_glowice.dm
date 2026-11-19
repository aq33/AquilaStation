/datum/test_chamber_kit/pr_643_glowice
	name = "Głowice specjalne torped"
	pr = "aq33/AquilaStation#643"
	description = "Trzy torpedy specjalne: chemiczna, ogłuszająca i opancerzona z visceratorami. \
		Załaduj je do wyrzutni torped okrętu i strzel w okręt Syndykatu: bez wnętrza w oknie modułów celu widać straty załogi albo ogłuszenie; z wczytanym wnętrzem (Call Proc ai_load_interior) skutek pojawia się na pokładzie w miejscu trafienia, a z opancerzonej wysypują się visceratory. \
		Odwrotnie: ustaw zmienną globalną ai_special_torpedo_chance na 100 i zespawnuj przy okręcie /obj/structure/overmap/syndicate/ai/destroyer/elite (ma wyrzutnię torped); jego torpedy powinny truć albo ogłuszać na pokładzie w miejscu trafienia, także przy pełnym pancerzu (wtedy tuż za poszyciem). \
		Głowice są też w protolacie amunicji (węzeł „Głowice specjalne”) i w paczce „Głowice torped specjalne” w zaopatrzeniu."
	items = list(
		/obj/item/ship_weapon/ammunition/torpedo/special_chemical = 1,
		/obj/item/ship_weapon/ammunition/torpedo/special_flash = 1,
		/obj/item/ship_weapon/ammunition/torpedo/viscerator = 1,
	)

/datum/test_chamber_kit/pr_643_walka
	name = "Skutki trafień, amunicja, działa, strefy"
	pr = "aq33/AquilaStation#643"
	description = "Odłamki: zespawnuj przy okręcie wrogi okręt i daj mu zbić pancerz ćwiartki; trafienie przez zbity pancerz wypuszcza za poszyciem odłamki w głąb, a przy głębokim wyłomie idzie seria małych wybuchów w kierunku lotu; pocisk przebija się przez ściany najdalej na głębokość wyłomu od burty, także przy trafieniu w starą dziurę. \
		Wybuch amunicji: podpal worek prochu (np. zapalniczką i plazmą na podłodze) albo strzel w niego; po 2–4 s syczenia wybucha, a wyjęty z ognia stygnie. \
		Kalibracja: przy MAC, railgunie albo dziale pokładowym odkręć panel śrubokrętem i użyj multitoola, odgadnij 4 cyfry (6 prób); spalony aktuator wyjmij łomem i włóż manipulator; strzał z otwartym panelem poraża. \
		Strefy: Debug > Toggle overmap hazards; na kaflu złomowiska widać na DRADIS pola szczątków; szybki przelot przez pole ściąga odłamki, a pole ukrywa okręt i zakłóca radio. Pole asteroid, mgławica, burze, promieniowanie i rozbłyski nie mają stref, bo robią je eventy kafla. \
		Pole przyciągania: zespawnuj przy okręcie /obj/effect/overmap_anomaly/hazard/gravity_well (ciągnie do środka, z wyłączonymi silnikami nie uciekniesz). \
		Tło według terenu: w View Variables obecnego układu ustaw hex_terrain_id (meteor, junk, nebula, estorm, storm, rad, flare, anom, grav, carp, wh, comet, mines), potem Call Proc force_parallax_update z 0 na okręcie; nad tłem układu pojawia się pył, szczątki, mgła, błyski, zorza, poświata, karpie albo miny. \
		Martwa załoga: na okręcie Syndykatu po pierwszym trafieniu View Variables > ship_modules, w każdym module crew_lost = 1, potem Call Proc apply_effects na ship_modules; okręt milknie, przestaje strzelać i dryfuje."
	items = list(
		/obj/item/powder_bag = 2,
		/obj/item/multitool = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/lighter = 1,
	)
