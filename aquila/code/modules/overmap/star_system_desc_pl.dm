// AQ - polskie opisy układów gwiezdnych (komunikat „Wchodzimy do ...” przy skoku FTL, ftl_jump.dm).
// Serwer czyta config/starmap/starmap.json, który save() nadpisuje co rundę, więc produkcja ma własną kopię
// z angielskimi opisami. Opis znanego układu podmieniamy przy tworzeniu, a następny save() utrwala polski tekst.
// Teksty są te same co w config/starmap/starmap_default.json (pilnuje tego test aquila_star_system_desc_pl).

/// Nazwa układu -> polski opis
GLOBAL_LIST_INIT(star_system_desc_pl, list(
	"Staging" = "Służy do inicjalizacji rundy i przygotowywania eventów przez adminów",
	"Sol" = "Serce i dom ludzkości, centrum technologicznej osobliwości. Nawet po katastrofie Ziemia pozostaje prawdziwą twierdzą, rozległą metropolią i absolutnym rajem. Żyją tu miliardy ludzi, a to bijące serce Federacji mieści bramy tunelowe, hiperbramy i hiperlinie prowadzące do reszty Federacji, ale teraz nie masz tam nic do roboty.",
	"Ross 154" = "Ross, jedna z najwcześniejszych kolonii ludzkości, to ogromny świat, który rozmiarami dorównuje dawnemu Księżycowi sprzed jego zniszczenia. Planeta ma rozległe orbitalne suche doki i kopalnie na asteroidach, a jej żyzna powierzchnia daje sporo żywności i materii organicznej, na przykład drewna. Ross 154, jak wiele innych układów w przestrzeni SolGovu, ma duże znaczenie, dlatego strzeże go flota, a bliskość Sol sprawia, że w razie potrzeby Siły Obrony Ziemi mogą wysłać obrońcom na pomoc grupę bojową.",
	"Alpha Centauri" = "Skraj układów wewnętrznych tętni cywilnym ruchem. Frachtowce, transportowce i wszelkiego rodzaju cywilne jednostki co kilka minut przylatują i odlatują hiperlinią prowadzącą od strony Sol.",
	"Sirius" = "Gdy SolGov zrozumiał, jak bardzo zniszczył ekosystem Ziemi, wezwał do zamknięcia wielu zakładów przemysłowych. Sirius był wtedy dopiero kolonizowany i nie miał jeszcze właściwych przepisów, więc przeniesienie tam przemysłu było bardzo kuszące. Dziś Sirius jest największym układem przemysłowym w Sektorze Sol.",
	"Wolf 359" = "Układ Wolf jest znany przede wszystkim jako miejsce narodzin felinidów, podgatunku ludzi. Niebieska gwiazda ciągu głównego, od której układ wziął nazwę, jest głównym źródłem energii i obiektem badań krążących wokół niej stacji. Bez własnych planet Wolf okazał się doskonałym poligonem dla eksperymentalnych technologii, z mnóstwem miejsca na gęsto zaludnione cylindry O'Neilla i stacje badawcze.",
	"Lalande 21185" = "W Lalande od zawsze działały hiperbramy dla ruchu w Federacji. Od Przestworza Delfickiego po Gromadę Rosetta statki ciągle tu przylatują i odlatują, by wspierać wysiłek wojenny oraz obsługiwać ruch korporacyjny i cywilny.",
	"Outpost 45" = "Punkt zborny wszystkich okrętów wracających z patroli, dostaw i rejsów próbnych. Tutaj personel WhiteRapids zdaje sprzęt, oddaje kontrabandę i dostaje przepustkę.",
	"Feliciana" = "Feliciana to naprawdę ogromny port handlowy: łączy dwie hiperbramy, a do tego krzyżują się tu szlaki do wszystkich członków Federacji, więc nikogo nie powinno dziwić, jak dobrze broniona jest główna stacja, „Stacja Felicity”. Stacja ma nawet solidne doki wojskowe, w których każdy okręt Federacji może zacumować i uzupełnić zapasy.",
	"Argo" = "Spokojny układ, który niestety rozsławiła popularna kosmiczna szanta. Mieszkańcy Argo wolą trzymać drzwi zamknięte przed konfliktem na zewnątrz i rzadko wpuszczają handlarzy czy gości. Na szczęście wokół planety krąży stacja CzanekCorp, która chętnie wpuszcza jednych i drugich.",
	"Orion's Arm" = "Nazwany na cześć ramienia tragicznego myśliwego, który zginął od skorpiona, ten układ razem z Outpost 73 chroni przed atakami z zaskoczenia i służy uszkodzonym okrętom za punkt odwrotu.",
	"Keid" = "Keid, nazywany czasem układem plastiku, jest największym producentem plastiku w galaktyce, a przez to także największym zabójcą kosmicznego życia, bo odpady wyrzuca w bezmiar kosmosu. Wielu kosmicznych „entuzjastów” ekologii próbowało spowolnić albo nawet zatrzymać główny przemysł Keid, ale bez skutku.",
	"Caph" = "Miejsce interesujące dla niektórych badaczy. Statki w Caph doświadczają tajemniczych, niewytłumaczalnych anomalii, które od wieków są zagadką dla świata nauki.",
	"Alpha Carinae" = "Podróżni zaglądają tu zwykle tylko na chwilę po drodze, a kupcy przelotem w drodze do regionów niezależnych, więc Alpha Carinae postawiła wyłącznie na atrakcje turystyczne: oferuje jeden z najlepszych serwisów cywilnych statków i bezmyślną rozrywkę.",
	"Helios Sigma" = "Choć sam układ jest dość pusty, stanowi ważny szlak zaopatrzeniowy zarówno do układu Medea, jak i do Gliese 581-G. Ze wszystkich układów nazwanych na cześć Heliosa tylko ten ma jaskrawoniebieską gwiazdę.",
	"Medea" = "Baza operacyjna większości działań Nanotrasen przeciwko Syndykatowi. Dziesiątki, jeśli nie setki ataków flot Syndykatu na próżno rozbiły się o obronę układu Medea: działa orbitalne, pola minowe i flotę zawsze o jeden skok stąd. Żaden atak nigdy się nie powiódł, więc Syndykatowi zostały tylko bardziej podstępne sposoby atakowania układów wewnętrznych leżących za Medeą.",
	"Gliese 581-G" = "Znany jako tani cel wakacyjny. Jedyna nadająca się do zamieszkania planeta jest w obrocie synchronicznym, więc podróżni muszą wybrać, czy wolą spędzać czas w świetle dnia, czy poznać nocne życie. Ostatnie konflikty wydłużyły listę kontrabandy dozwolonej na planecie.",
	"Tortuga" = "Dom tytułowych Najeźdźców z Tortugi. Układ długo zmagał się z wewnętrznymi konfliktami, które utorowały drogę do władzy obecnej grupie najeźdźców. Sama Tortuga, a raczej to, co z niej zostało, nosi wszystkie blizny swojej burzliwej historii. Jest drugim domem dla wszystkich piratów i korsarzy w sektorze.",
	"Feaf" = "Układ mieszkalny Najeźdźców z Tortugi. Stąd wyruszają na większość rajdów i stąd chronią Tortugę. Trafia tu wiele zmęczonych, nieudanych klonów i chodzących wad genetycznych, by przyłączyć się do jedynych ludzi, którzy w ogóle zwrócą na nich uwagę.",
	"Chalawan" = "Pośrednik między układami Medea i Gliese 581-G. Przechodzi tędy zarówno ruch wojskowy, jak i cywilny w głąb Gromady Rosetta, choć ostatnio bardziej wojskowy niż cywilny.",
	"Atik" = "Niczym niewyróżniający się układ. Przekaźnik dla ruchu w dalszych rejonach Gromady Rosetta.",
	"Outpost 73" = "Wysunięta baza operacyjna WhiteRapids. Dobrze strzeżona i dobrze zorganizowana.",
	"Abious II" = "Abious II założył bogacz, który chciał zrobić z niego swój prywatny układ gwiezdny. Pierwsza próba prawie go zrujnowała, ale nie powstrzymała go przed kolejną.",
	"Beta Centauri" = "O Beta Centauri niewiele można powiedzieć. Jedyne, co się tu wyróżnia, to odległość od rzekomego siostrzanego układu.",
	"Abious I" = "Dawno, dawno temu Abious założył bogacz marzący o własnym prywatnym układzie gwiezdnym. Niegrzeczni sąsiedzi szybko zniweczyli to marzenie.",
	"Ethor" = "Ethor wpadł w ręce piratów wkrótce po układzie Zurs. Złupiony z cywilnego sprzętu górniczego, jest dziś głównym źródłem zaopatrzenia i materiałów Najeźdźców z Tortugi.",
	"Zurs" = "Niegdyś znakomite miejsce na wakacje i kurort, dziś przejęte przez piratów. Złupili je do cna i teraz trzymają tu wysuniętą bazę w sercu Gromady Rosetta.",
	"Priar" = "Niczyj układ, nieprzyjemnie blisko pirackich placówek. Na szczęście piraci nie mieli dotąd powodu, by po niego sięgnąć, choć wkrótce może się to zmienić.",
	"Viiman" = "Przez Viiman przechodzi duży ruch Nanotrasen, bo prowadzi tędy najkrótsza droga do układu Karip.",
	"Karip" = "Obecne ognisko walk między NT a Syndykatem. Fala za falą obie strony rzucają się tu na siebie w nadziei, że przeciwnik wyjdzie z tego w gorszym stanie.",
	"Arbeia" = "Przez układ Arbeia przechodzi duży ruch Syndykatu: to najkrótsza droga do układu Karip z układów kontrolowanych przez Syndykat.",
	"Zharkov" = "Według plotek w układzie Zharkov działała kiedyś nielegalna klonownia. Zostały po niej tylko opuszczone stacje i porzucony sprzęt górniczy z ostatniej korporacyjnej operacji.",
	"Bemike" = "Gdyby Bemike był niezamieszkany, byłby świetną autostradą, którą każda ze stron mogłaby słać kolejne okręty prosto na front. Działa tu jednak wiele małych, niezależnych stacji górniczych, które handlują z obiema stronami.",
	"UY Scuti" = "W układzie UY Scuti niewiele się dzieje: największa gwiazda znanego wszechświata utrudnia nawigację, nie mówiąc już o manewrach bojowych. Ciągłe impulsy silnego promieniowania i rozbłyski słoneczne czynią układ skrajnie niebezpiecznym.",
	"Rubicon" = "Układ Rubicon jest w całości pod kontrolą Syndykatu. Łączy ze sobą kilka układów i od zawsze jest potężną twierdzą, że tak powiem, dziurą w ulu, otwierającą drogę w głąb przestrzeni Syndykatu.",
	"Veneto" = "W układzie Veneto znajduje się groźna czarna dziura, która trzyma Syndykat z dala od układu, ale przez nią próba ominięcia układu Rubicon to nierozważne przedsięwzięcie.",
	"Remus" = "Wbrew zwyczajowi układu Remus strzeże tylko kilka, za to wytrzymałych okrętów, które mają spowolnić najeźdźców. Zyskują czas, by bardziej uprzemysłowione rejony terytorium Syndykatu mogły ewakuować cywilów i przygotować się do walki.",
	"Lombard" = "Układ Lombard leży głęboko na terytorium Syndykatu, z dala od większości ruchu atakujących sił wroga. Ale skoro tu jesteś, to właśnie się zmienia.",
	"Economus" = "Bliskość układu Rubicon sprawiła, że ten układ stał się czymś w rodzaju punktu zbornego okrętów Syndykatu. Liczne porzucone stacje zaopatrzeniowe dryfują bez celu w pustce, każda powykręcana i stopiona tak, że ściska cię w żołądku. Możesz tylko mieć nadzieję, że nie było na nich załogi.",
	"Volsci" = "Układ Volsci zawsze był tylko skrawkiem przestrzeni, z którego zwiadowcy Syndykatu pilnują swojego terytorium. Bez surowców i bez gwiazdy, wokół której można krążyć, pusta, zimna przestrzeń to doskonała placówka nasłuchowa, z której okręty Syndykatu ostrzegają Strażników Bramy w układzie Rubicon przed nieproszonymi gośćmi.",
	"Lesziru" = "Syndykat używał tego układu tylko jako ostatniego punktu odwrotu. Infrastruktury starcza tu akurat na kilka wycofujących się flot i nic więcej.",
	"Zeta Reticuli" = "Są dwa powody, dla których Syndykat jeszcze nie zajął układu Zeta Reticuli. Po pierwsze, mieszka tu osławiony Randy Random, a to oznacza własny zestaw problemów. Bardziej znanym problemem jest gęsta mgławica, przez którą trudno ten układ zdobyć, utrzymać, a nawet znaleźć w nim cokolwiek przydatnego, chyba że ktoś potrzebuje miliardów kilometrów sześciennych obojętnego pyłu kosmicznego.",
	"Zalosi" = "Układ Zalosi strzeże tylnych drzwi do układów Syndykatu. Jest silnie broniony i zawsze czujny, a jego siły regularnie patrolują ten sektor razem z siłami z Guriibuu.",
	"Guriibuu" = "Choć Guriibuu nie jest już jedynym znanym Federacji układem potrójnym, nadal byłby wspaniałym punktem orientacyjnym i celem turystów, gdyby nie ciągłe patrole Syndykatu.",
	"Dolos Remnants" = "Miejsce, w którym upadli giganci. Nie czujesz nic poza dziwnym niepokojem i upiorną ciszą.",
))

// Pełna lista parametrów jak w nsv13/code/controllers/subsystem/starsystem.dm: instantiate_systems() woła new z argumentami
// nazwanymi, a BYOND sprawdza ich nazwy według ostatniego nadpisania (bez nich: runtime „bad arg name” i pusta mapa).
/datum/star_system/New(name, desc, threat_level, alignment, owner, hidden, system_type, system_traits, is_capital, adjacency_list, wormhole_connections, fleet_type, x, y, parallax_property, visitable, sector, is_hypergate, preset_trader, audio_cues, startup_proc)
	. = ..()
	var/polish_desc = GLOB.star_system_desc_pl[src.name]
	if(polish_desc)
		src.desc = polish_desc
