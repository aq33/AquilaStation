// Basic moby, część 2: sarna z bitrunningu i tanie moby bez zdolności (tg 926bf40c5a)
// Spokojne zwierzęta osobno od wrogich, żeby wrogie nie zabiły ich przed testem.

/datum/test_chamber_kit/pr_625_p1
	name = "Basic moby: sarna i spokojne zwierzęta"
	pr = "aq33/AquilaStation#625"
	description = "Zestaw: 2 sarny, hulajnoga, Wojtek, 2 olbrzymie mrówki, kosmonauta, kosmiczny delfin, 3 chodzące grzyby, 2 grzyby w skrzyni, papierosy i piwo, a na skraju areny trochę trawy, woda i drzewo. Sprawdzaj w obu trybach sterowania (combat mode i stare intencje). Nie zrzucaj razem z wrogimi mobami. \
	1) Sarna: podejdź → ucieka, gdy cię widzi, i przestaje, gdy zniknie ci z oczu; uderzona ucieka też od napastnika. Zabij ją → leży w miejscu, nie odjeżdża; ciągnij martwą i żywą (żywa nie wyrywa się sama), rzeźnik ją kroi. Sama skubie trawę, pije wodę, znakuje drzewo kopytami i odpoczywa przy nim, bawi się z drugą sarną. Hulajnoga obok → sarna zamiera i się gapi kilka sekund. W bitrunningu („Polowanie na Łąkach”) trzy martwe sarny odsłaniają skrzynię. \
	2) Wojtek nie atakuje nikogo, dopóki ktoś go nie uderzy, a wtedy bije tylko tego kogoś (także z załogi). Papieros (+10 HP) i piwo (+20 HP) podane bez combat mode leczą go. \
	3) Mrówka, kosmonauta i delfin nie zaczepiają; mrówka uderzona ucieka, kosmonauta i delfin oddają (delfin męczy, zabiera wytrzymałość). Głaskana mrówka radośnie klekocze. Duch przejmuje delfina kliknięciem (wskaźnik combat mode w HUD) i gryzie kliknięciem w obu trybach sterowania. \
	4) Grzyby walczą tylko między sobą: powalony grzyb jest przeżuwany i zjadany za trzecim razem, zjadający awansuje (rośnie i mocniej gryzie); uderzony grzyb jest poobijany i nie daje awansu. Grzyb z ręki ożywia powalonego (raz na 30 s), żywy grzyb je grzyby z podłogi. Rzeźnik kroi grzyb na plastry z lekami zależnymi od poziomu. Botanika: owoc z cechą „Biozłośliwość” w wariancie chodzącym budzi się jako chodzący grzyb."
	items = list(
		/mob/living/basic/deer = 2,
		/obj/vehicle/ridden/scooter = 1,
		/mob/living/basic/bear/wojtek = 1,
		/obj/item/clothing/mask/cigarette = 2,
		/obj/item/reagent_containers/food/drinks/beer = 2,
		/mob/living/basic/ant = 2,
		/mob/living/basic/spaceman = 1,
		/mob/living/basic/dolphin = 1,
		/mob/living/basic/mushroom = 3,
	)

/datum/test_chamber_kit/pr_625_p1/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Na skraju areny trochę łąki: trzy kratki trawy, kratka wody i drzewo
	var/list/meadow = list(/turf/open/floor/grass, /turf/open/floor/grass, /turf/open/floor/grass, /turf/open/water/air)
	var/available = length(turfs)
	for(var/i in 1 to min(length(meadow), available))
		var/turf/T = turfs[available - i + 1]
		if(!istype(T, /turf/open/floor))
			continue
		T.ChangeTurf(meadow[i], flags = CHANGETURF_INHERIT_AIR)
	if(available > length(meadow))
		new /obj/structure/flora/tree/jungle/small(turfs[available - length(meadow)])
	// Grzyby w zamkniętej skrzyni, żeby chodzące grzyby nie zjadły ich same
	var/obj/structure/closet/crate/crate = new(center)
	for(var/i in 1 to 2)
		new /obj/item/food/grown/mushroom/chanterelle(crate)

/datum/test_chamber_kit/pr_625_p1_hostile
	name = "Basic moby: wrogie moby bez zdolności"
	pr = "aq33/AquilaStation#625"
	description = "Zestaw: duch, zombie, gnijące zombie, 2 szkielety, nieumarły Eskimos, templariusz, sosna, słup Festivusa, Niewierny, Kurwinox, czerwony Kurwinox, maupa, karton mleka, karton mleka sojowego, ogniwo energetyczne, łom. Wrogie moby: zrzucaj w osobnej komorze albo z bronią. \
	1) Duch oddaje tylko uderzony, lata, po śmierci zostaje ektoplazma. \
	2) Zombie gryzą (zgniłe nie rozbijają przeszkód), po śmierci zostają zwłoki zombie w ubraniu profesji. \
	3) Szkielety atakują wszystkich, ranny szkielet idzie do mleka i pije je (leczy się), mleko sojowe go parzy; po śmierci zostają kości, Eskimos zostawia włócznię i ubranie, templariusz zbroję i święty miecz. \
	4) Sosna gryzie i czasem przewraca (częściej, gdy trzymasz siekierę albo drewno), po śmierci zostawia drewno. Słup Festivusa tylko gryzie; potarty bez combat mode ładuje pobliskie ogniwa. \
	5) Niewierny tłucze lampy, przewraca, wlecze nieprzytomnych; przejęty przez gracza bez combat mode (na intencji pomocy) wyważa śluzę, w combat mode ją tłucze. \
	6) Kurwinoxy i maupa atakują wszystkich spoza swojej frakcji, nie siebie nawzajem; po śmierci martwy sprite. \
	7) Pułapki w technicznych (podstępny drań: zombie, szkielet, Niewierny, sosna, kosmonauta) wypuszczają moba od razu nastawionego na ofiarę."
	items = list(
		/mob/living/basic/ghost = 1,
		/mob/living/basic/zombie = 1,
		/mob/living/basic/zombie/rotten = 1,
		/mob/living/basic/skeleton = 2,
		/mob/living/basic/skeleton/eskimo = 1,
		/mob/living/basic/skeleton/templar = 1,
		/mob/living/basic/tree = 1,
		/mob/living/basic/tree/festivus = 1,
		/mob/living/basic/faithless = 1,
		/mob/living/basic/kurwinoxy = 1,
		/mob/living/basic/kurwinoxy/czerwony = 1,
		/mob/living/basic/clowiekmaupa = 1,
		/obj/item/reagent_containers/food/condiment/milk = 1,
		/obj/item/reagent_containers/food/condiment/soymilk = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/crowbar = 1,
	)
