/datum/test_chamber_kit/pr_605
	name = "Rework strzelania"
	pr = "aq33/AquilaStation#605"
	description = "Zestaw: pistolet, C-20r (seria i ogień ciągły), CKM L6 (smugi co 5. nabój, przegrzanie), karabin laserowy (przegrzanie), strzelba, rewolwer z amunicją wyczynową (rykoszety), P99 z magazynkiem inteligentnym, wszystkie dodatki, zestaw konserwacji, dwie smycze drużyny; na arenie stół, barierka i krzesło biurowe. Sprawdź w obu trybach sterowania (combat mode i intencje). \
	1) Bezpiecznik: nowa broń jest zabezpieczona → strzał daje „bezpiecznik!”. Klawisz V albo akcja „Zmień Tryb Ognia” przełącza: bezpiecznik → pojedynczy → seria → ogień ciągły (licznik amunicji przy prawej kolumnie HUD-u pokazuje ikonę trybu). \
	2) Strzał przy wciśnięciu: kula wylatuje, gdy wciskasz przycisk, nie gdy go puszczasz. C-20r w ogniu ciągłym: przytrzymaj i przeciągaj mysz, seria idzie za kursorem; krótkie kliknięcie = jeden strzał. \
	3) Odrzut: długa seria się rozjeżdża, krótkie serie są celne; ekran kopie w stronę od celu (siła w ustawieniach: „Siła odrzutu ekranu”). Kursor z odbezpieczoną bronią to celownik, którego rogi rozsuwają się w ruchu, z jednej ręki i przy serii. \
	4) Celowanie: w combat mode przytrzymaj prawy przycisk (na intencjach klawisz „Celuj przez przyrządy” z ustawień) → kursor zmienia się w znak celownika (krzyż, kropka, holo albo termowizja), a widok wysuwa się w stronę kursora: przyrządy 2 kratki, celownik holograficzny 3, prosty i termowizyjny 4; bez rozmycia. Trzymając prawy, strzelaj lewym (także ogniem ciągłym); postać idzie wolniej, a broń w ręku jest wyprostowana; sam prawy przycisk nigdy nie strzela. W combat mode postać idzie tyłem i bokiem, cały czas patrząc na kursor. \
	5) Smugi i rykoszety: kule lecą półtora raza szybciej niż dawniej, a za nimi ciągnie się smuga, z CKM co piąta jest jaskrawa; strzał prawie po stycznej do ściany (od 45° od prostopadłej) czasem odbija się z iskrą i brzękiem, prosto w ścianę nigdy; wyczynowe .38 odbija się zawsze. Kule świszczą przy uchu stojącego obok i lekko nim szarpią. Trafienie w każdą ścianę, także w ściany tej komory, zostawia dziurę w miejscu trafienia i brzmi jak metal, w drewno jak drewno, w okno jak szkło. \
	6) Osłony: Ctrl+Shift+klik na stół przewraca go w stronę od ciebie; kula od frontu zwykle wbija się w stół (stół traci wytrzymałość), z boku przelatuje; zza barierki i krzesła też czasem łapie. Strzelaj z krzesła biurowego → krzesło odjeżdża do tyłu. \
	7) Stan broni: badaj broń → stan techniczny i statystyki (obrażenia, trafień do krytycznego, rozrzut, szybkostrzelność). Laser i CKM po długim ogniu: „przegrzana!”, broń nie strzela do ostygnięcia, bez rękawic parzy dłoń. Zestaw konserwacji na broń → 10 s czyszczenia. \
	8) Dodatki: dodatek na broń (bez combat mode) → zakłada się i widać go na broni (celownik leży na wierzchu broni, chwyt i laser pod lufą); drugi celownik → odmowa (negatyw); śrubokręt zdejmuje. Zestaw konserwacji leży też w zbrojowni (regał z amunicją) i w pudełku z automatu drużyny. Celownik laserowy: akcja włącza wiązkę widoczną dla innych, idzie za kursorem. \
	9) IFF: setup dopisuje cię do drużyny i daje dwie smycze; ktoś w smyczy twojej drużyny stoi między tobą a celem → kula go omija; kliknij prosto w niego → dostaje (negatyw dla IFF). \
	10) Amunicja inteligentna: P99 z magazynkiem inteligentnym, strzał w cel, który ucieka w bok → kula skręca za nim, dopóki go widzi. \
	11) Niewypał: rzadki (0,3% fabrycznej amunicji) – „niewypał! przeładuj”, przeładowanie wyrzuca nabój. \
	12) Broń statkowa (osobno, na okręcie): torpedy, PDC, railgun i MAC lecą i trafiają jak wcześniej."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/ammo_box/magazine/smgm45 = 2,
		/obj/item/gun/ballistic/automatic/l6_saw/unrestricted = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/ballistic/shotgun/riot = 1,
		/obj/item/gun/ballistic/revolver/detective = 1,
		/obj/item/ammo_box/c38/match = 2,
		/obj/item/gun/ballistic/automatic/pistol/glock/security = 1,
		/obj/item/ammo_box/magazine/glock/smart = 2,
		/obj/item/attachment/scope/simple = 1,
		/obj/item/attachment/scope/holo = 1,
		/obj/item/attachment/scope/infrared = 1,
		/obj/item/attachment/grip/vertical = 1,
		/obj/item/attachment/laser_sight = 1,
		/obj/item/gun_maintenance_kit = 1,
		/obj/item/screwdriver = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/structure/table = 1,
		/obj/structure/railing = 1,
		/obj/structure/chair/office = 1,
	)

/datum/test_chamber_kit/pr_605/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/tester = user
	var/datum/squad/squad = GLOB.squad_manager?.squads?[1]
	if(!istype(tester) || !squad)
		return
	if(tester.squad != squad)
		if(tester.squad)
			tester.squad.remove_member(tester)
		squad.add_member(tester)
	for(var/i in 1 to 2)
		var/obj/item/clothing/neck/squad/lanyard = new(center, squad)
		spawned += lanyard
	for(var/obj/item/gun/gun in spawned)
		gun.unlock()
