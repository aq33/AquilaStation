/datum/test_chamber_kit/pr_481
	name = "Ochrona w barwach Policji (dziś Żandarmeria, zob. pr_550)"
	pr = "aq33/AquilaStation#481"
	description = "Zestaw: szafki ochrony, SecDrobe (w komorze wszystko za darmo), śluza security, tablety, ubrania Aspiranta i lekarza więziennego, czapki z arkusza, pościel HoS-a, płytki dywanu i dekale podłogi. Leżą też zapasowa karta kapitana (dostęp do szafek), emag i śrubokręt. \
	1) Otwórz kartą kolejno szafki: sec, warden, HoS, zbrojownię, tac (lethalshots), bio, a także walizkę na strzelby → oczekiwane: wszystkie mają zielone ikony Żandarmerii (zamknięte, otwarte, zablokowane); szafka tac jest czerwona jak w arkuszu, reszta bez granatu. \
	2) Szafka HoS i Wardena: przejrzyj zawartość → oczekiwane: brak skórzanej kurtki HoS, czerwonych supergarsów, białego i paradnego munduru damskiego oraz beretu korporacyjnego u Wardena (negatyw: te rzeczy nie występują w żadnej szafce). \
	3) SecDrobe (klik, zakładka ubrań) → oczekiwane: zielona obudowa i zielone światło; w ofercie są mundury Żandarmerii, czapki z arkusza (alt, bandana, furażerka), a NIE ma czerwonej bandany, czerwonej opaski, czerwonego krawata, khaki, blueshirta, mallcopa, munduru i beretu korporacyjnego, a emagowanie nie odsłania starego płaszcza zimowego (negatyw: kontrabanda pusta). \
	4) Śluza security: dotknij śrubokrętem (otwórz panel) i emagiem → oczekiwane: drzwi zielone, żółte pasy ostrzegawcze zostają, otwarty panel i animacja otwarcia w zieleni z czerwonymi akcentami. \
	5) Załóż na siebie mundur Aspiranta z opaską (opaskę przypnij do munduru) → oczekiwane: mundur wygląda jak mundur Żandarma, a nie mallcop, opaska jest zielona (na postaci i w ekwipunku). \
	6) Załóż każdą czapkę (alt, Naczelnika, bandana, furażerka, oficerska) oraz czapkę, fartuch, kamizelkę i mundur lekarza więziennego → oczekiwane: wszystkie widać na postaci (wcześniej znikały), lekarz ma zieleń zamiast dawnego granatu. \
	7) Tablety ochrony/HoS: ikony i kolory zielone. Pościel HoS-a na szyję → oczekiwane: widoczny sprite noszony. \
	8) Płytki dywanu Żandarmerii połóż obok siebie → oczekiwane: łączą się w jeden wzór; dekale na podłodze (cztery pola obok) są zielone."
	items = list(
		/obj/structure/closet/secure_closet/security = 1,
		/obj/structure/closet/secure_closet/warden = 1,
		/obj/structure/closet/secure_closet/hos = 1,
		/obj/structure/closet/secure_closet/armory1 = 1,
		/obj/structure/closet/secure_closet/lethalshots = 1,
		/obj/structure/closet/l3closet/security = 1,
		/obj/structure/guncase/shotgun = 1,
		/obj/machinery/vending/wardrobe/sec_wardrobe = 1,
		/obj/machinery/door/airlock/security = 1,
		/obj/item/modular_computer/tablet/pda/security = 1,
		/obj/item/modular_computer/tablet/pda/heads/head_of_security = 1,
		/obj/item/clothing/under/rank/security/officer/mallcop/deputy = 1,
		/obj/item/clothing/accessory/armband/deputy = 1,
		/obj/item/clothing/head/soft/sec/brig_physician = 1,
		/obj/item/clothing/suit/toggle/labcoat/brig_physician = 1,
		/obj/item/clothing/suit/hazardvest/brig_physician = 1,
		/obj/item/clothing/under/rank/brig_physician = 1,
		/obj/item/clothing/head/soft/sec/alt = 1,
		/obj/item/clothing/head/soft/sec/warden = 1,
		/obj/item/clothing/head/beret/sec/bandana = 1,
		/obj/item/clothing/head/beret/sec/officercap = 1,
		/obj/item/clothing/head/beret/sec/garrison = 1,
		/obj/item/bedsheet/hos = 1,
		/obj/item/stack/tile/carpet/police/fifty = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/card/emag = 1,
		/obj/item/screwdriver = 1,
	)

/// Naklejki rozkładają się na podłogę i same znikają, więc nie idą przez items (test liczy obiekty)
/datum/test_chamber_kit/pr_481/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/decals = list(
		/obj/effect/turf_decal/tile/ship/police,
		/obj/effect/turf_decal/tile/ship/half/police,
		/obj/effect/turf_decal/tile/ship/full/police,
		/obj/effect/turf_decal/trimline/police/line,
	)
	for(var/i in 1 to min(length(decals), length(turfs)))
		var/decal_type = decals[i]
		new decal_type(turfs[i])
	// SecDrobe w komorze nie ma sprzedawać za kredyty
	for(var/obj/machinery/vending/wardrobe/sec_wardrobe/drobe in spawned)
		drobe.onstation = FALSE
