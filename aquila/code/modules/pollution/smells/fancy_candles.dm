// AQUILA - Dym i zapachy, port z Monkestation 2.0. Nasze świece to /obj/item/candle, nie flara jak w tg.
/obj/item/candle/vanilla
	name = "świeca waniliowa"
	desc = "Zapachowa świeca. Pachnie wanilią, kiedy się pali."
	scented_type = /datum/pollutant/fragrance/vanilla

/obj/item/candle/pear
	name = "świeca gruszkowa"
	desc = "Zapachowa świeca. Pachnie gruszką, kiedy się pali."
	scented_type = /datum/pollutant/fragrance/pear

/obj/item/candle/amber
	name = "świeca bursztynowa"
	desc = "Zapachowa świeca. Pachnie słodko i pudrowo, kiedy się pali."
	scented_type = /datum/pollutant/fragrance/amber

/obj/item/candle/jasmine
	name = "świeca jaśminowa"
	desc = "Zapachowa świeca. Pachnie jaśminem, kiedy się pali."
	scented_type = /datum/pollutant/fragrance/jasmine

/obj/item/candle/mint
	name = "świeca miętowa"
	desc = "Zapachowa świeca. Pachnie miętą, kiedy się pali."
	scented_type = /datum/pollutant/fragrance/mint

/obj/item/storage/fancy/candle_box/vanilla
	name = "paczka świec waniliowych"
	desc = "Paczka zapachowych świec."
	spawn_type = /obj/item/candle/vanilla

/obj/item/storage/fancy/candle_box/pear
	name = "paczka świec gruszkowych"
	desc = "Paczka zapachowych świec."
	spawn_type = /obj/item/candle/pear

/obj/item/storage/fancy/candle_box/amber
	name = "paczka świec bursztynowych"
	desc = "Paczka zapachowych świec."
	spawn_type = /obj/item/candle/amber

/obj/item/storage/fancy/candle_box/jasmine
	name = "paczka świec jaśminowych"
	desc = "Paczka zapachowych świec."
	spawn_type = /obj/item/candle/jasmine

/obj/item/storage/fancy/candle_box/mint
	name = "paczka świec miętowych"
	desc = "Paczka zapachowych świec."
	spawn_type = /obj/item/candle/mint

/// One of each scent, for vendors
/obj/item/storage/fancy/candle_box/scented
	name = "paczka świec zapachowych"
	desc = "Pięć zapachowych świec, każda pachnie inaczej."

/obj/item/storage/fancy/candle_box/scented/PopulateContents()
	new /obj/item/candle/vanilla(src)
	new /obj/item/candle/pear(src)
	new /obj/item/candle/amber(src)
	new /obj/item/candle/jasmine(src)
	new /obj/item/candle/mint(src)

/obj/item/storage/box/perfume/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10

/obj/structure/closet/jcloset/PopulateContents()
	..()
	new /obj/item/air_refresher(src)
	new /obj/item/air_refresher(src)

/datum/supply_pack/service/pollution_scrubber
	name = "Oczyszczacz powietrza"
	desc = "Przenośny oczyszczacz, który filtruje dym i zapachy z pomieszczenia. Przykręć go kluczem i włącz. Dorzucamy dwa odświeżacze powietrza."
	cost = 1200
	access_budget = ACCESS_JANITOR
	contains = list(/obj/machinery/pollution_scrubber,
					/obj/item/air_refresher,
					/obj/item/air_refresher)
	crate_name = "skrzynia z oczyszczaczem powietrza"
	crate_type = /obj/structure/closet/crate/large
