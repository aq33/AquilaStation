/datum/test_chamber_kit/pr_shipbreaking
	name = "Shipbreaking (wraki w magnesie)"
	pr = "aq33/AquilaStation#PR_SHIPBREAKING"
	description = "Na overmapie obok statku pojawił się wrak: na konsoli magnesu (górnictwo, przy klatce na asteroidy) ma być w sekcji „Wraki w zasięgu”. \
		Przyciągnij go, po 10 s ma się pojawić w klatce, porozbijany wybuchami. Rozbieraj go młotem (w obu rękach) i spawarką Rayne, która działa tylko w strefie. \
		Ściany mają dawać poszycie, dźwigary szkielet, maszyny elektronikę, plazmę i matryce, silniki rdzenie. Pasek „Zostało X% wraku” ma spadać. \
		Złom wrzuć na recykler: kredyty idą do budżetu zaopatrzenia, połowa na twoje konto. Na koniec „Wypchnij wrak”: klatka ma się wyczyścić. \
		Recykler i złom w komorze służą do szybkiego sprawdzenia wypłat."
	items = list(
		/obj/machinery/shipbreaker = 1,
		/obj/structure/closet/secure_closet/shipbreaker = 1,
		/obj/item/stack/scrap/plating = 1,
		/obj/item/stack/scrap/electronics = 1,
		/obj/item/stack/scrap/framing = 1,
		/obj/item/stack/scrap/plasma = 1,
		/obj/item/stack/scrap/core = 1,
		/obj/item/stack/scrap/crystalline_matrix = 1,
		/obj/item/clothing/suit/space/hardsuit/mining = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/clothing/mask/gas/explorer = 1,
	)

/datum/test_chamber_kit/pr_shipbreaking/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/structure/closet/secure_closet/shipbreaker/closet in spawned)
		closet.locked = FALSE
		closet.update_icon()
	if(!user)
		return
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship?.current_system)
		to_chat(user, "<span class='warning'>Nie ma głównego statku na overmapie, wrak się nie pojawi.</span>")
		return
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = new(get_turf(ship))
	ship.current_system.add_ship(wreck, get_turf(ship))
	wreck.forceMove(get_turf(ship))
	to_chat(user, "<span class='notice'>Wrak czeka obok [ship] na overmapie.</span>")
