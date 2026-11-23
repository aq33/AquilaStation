/datum/test_chamber_kit/pr_625_fam
	name = "Basic moby cz. 2: gęsi, karpie-pupile, barmanka"
	pr = "aq33/AquilaStation#625"
	description = "Zestaw: gęś, Birdboat, kosmiczna gęś, Lia, Cayenne, barmanka, kosmiczne lasso, fałszywy dysk atomowy, 2 płaty mięsa, 3 spalone breje, 2 ciastka, arkusz plastiku, łom. Sprawdzaj w obu trybach sterowania (combat mode i stare intencje). Nie zrzucaj razem z wrogimi mobami. \
	1) Gęś zjada ciastko leżące obok niej, nie rusza łomu; arkusz plastiku położony obok → dławi się (drgawki, kaszel), po 30 s pada. Czasem bez powodu wpada w gniew, syczy i dziobie, po chwili się uspokaja. \
	2) Bez combat mode / na intencji pomocy daj Birdboatowi spaloną breję z ręki → zjada ją i trzyma w środku. Po kilku breją albo przez przycisk „Zwymiotuj” wymiotuje: drży, chodzi losowo, plamy wymiocin i zjedzone rzeczy wylatują na boki. Pusty żołądek → przycisk nieaktywny. Oględziny: „Jakimś cudem wciąż wygląda na głodną.” \
	3) Kosmiczna gęś przeżywa w próżni i porusza się w kosmosie bez dryfu. \
	4) Lia i Cayenne nie atakują same; uderzone oddają i uciekają, ranne otwierają szczelinę karpi i znikają kawałek dalej. Głaskanie: serce i „radośnie bulgocze!”. \
	5) Przejmij Cayenne (VV albo duch): kliknięcie dysku podnosi go do pyska (nakładka na sprite), kliknięcie podłogi go odkłada; oględziny Cayenne z dyskiem mówią o dysku. PPM / intencja rozbrajania w dal → szczelina karpi i teleport. \
	6) Barmanka stoi bez SI i nie da się jej zranić. \
	7) Złap lassem Lię: oswojona ma polecenia („za mną”, „zostań”, „atakuj”, menu pod Alt+klikiem), da się na niej jeździć, ranna nadal ucieka szczeliną (SI karpia zostaje)."
	items = list(
		/mob/living/basic/goose = 1,
		/mob/living/basic/goose/vomit = 1,
		/mob/living/basic/goose/space = 1,
		/mob/living/basic/carp/pet/lia = 1,
		/mob/living/basic/carp/pet/cayenne = 1,
		/mob/living/basic/alien/maid/barmaid = 1,
		/obj/item/mob_lasso = 1,
		/obj/item/food/meat/slab = 2,
		/obj/item/food/badrecipe = 3,
		/obj/item/food/cookie = 2,
		/obj/item/stack/sheet/plastic = 1,
		/obj/item/crowbar = 1,
	)

/// The fake disk would jump to the station (the chamber is off it), so it comes without its stationloving component
/datum/test_chamber_kit/pr_625_fam/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/item/disk/nuclear/fake/disk = new(center)
	qdel(disk.GetComponent(/datum/component/stationloving))
	disk.forceMove(center)

/datum/test_chamber_kit/pr_625_fam_wrogie
	name = "Basic moby cz. 2: hiveboty, ksenomorfy, karpie"
	pr = "aq33/AquilaStation#625"
	description = "Zestaw: hivebot, hivebot strzelający, szybkostrzelny i silny, łowca, dron, strażnik i królowa ksenomorfów, pokojówka, 2 kosmiczne karpie, zaawansowany karp, megakarp, magikarp, magikarp chaosu, holokarp, gałka oczna, odwodniony karp, 3 płaty mięsa. Uwaga: prawie wszystko atakuje od razu, zrzucaj w hardsuicie albo z bronią. Sprawdzaj w obu trybach sterowania. \
	1) Hiveboty strzelające i silny strzelają z dystansu (nie trafiają w siebie nawzajem), zwykły drapie; zniszczone rozpadają się w iskrach na złom. Stojące obok siebie czasem „mówią” do siebie zerami i jedynkami. \
	2) Strażnik i królowa plują neurotoksyną z dystansu, łowca i dron tną wręcz, dron i królowa sadzą obce chwasty, pokojówka tylko poleruje i sprząta krew. \
	3) Karpie atakują ławicą; ranny karp otwiera szczelinę i ucieka, po kilku sekundach bez obrażeń wraca do zdrowia. Daleki cel → szczelina w jego stronę; inne karpie wchodzą w otwartą szczelinę. Karp bez celu zjada płat mięsa. \
	4) Magikarp strzela swoim zaklęciem (losowym przy powstaniu), magikarp chaosu za każdym razem innym. Megakarp ma losowe imię, więcej życia i regeneruje się. Holokarp znika po śmierci. \
	5) Odwodnionego karpia pogłaszcz w ręce i zmocz wodą → karp przyjazny dla ciebie. \
	6) Duch przejmuje karpia, hivebota albo gałkę oczną (wskaźnik combat mode w HUD). Karp gracza: PPM / intencja rozbrajania w dal → szczelina. Hivebot i strażnik gracza: klik w daleki cel → strzał. Magikarp gracza strzela tylko w combat mode / na intencji harm. \
	7) Gałka oczna (zwykły simple animal) dalej lata i gryzie."
	items = list(
		/mob/living/basic/hivebot = 1,
		/mob/living/basic/hivebot/range = 1,
		/mob/living/basic/hivebot/rapid = 1,
		/mob/living/basic/hivebot/strong = 1,
		/mob/living/basic/alien = 1,
		/mob/living/basic/alien/drone = 1,
		/mob/living/basic/alien/sentinel = 1,
		/mob/living/basic/alien/queen = 1,
		/mob/living/basic/alien/maid = 1,
		/mob/living/basic/carp = 2,
		/mob/living/basic/carp/advanced = 1,
		/mob/living/basic/carp/mega = 1,
		/mob/living/basic/carp/magic = 1,
		/mob/living/basic/carp/magic/chaos = 1,
		/mob/living/basic/carp/holographic = 1,
		/mob/living/simple_animal/hostile/eyeball = 1,
		/obj/item/toy/plush/carpplushie/dehy_carp = 1,
		/obj/item/food/meat/slab = 3,
	)
