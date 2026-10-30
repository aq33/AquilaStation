/datum/bounty/item/slime
	reward = 3000

/datum/bounty/item/slime/New()
	..()
	description = "Główny naukowiec Nanotrasen poluje na rzadki i egzotyczny [lowertext(name)]. Za jego znalezienie wyznaczono nagrodę."
	reward += rand(0, 4) * 500

/datum/bounty/item/slime/green
	name = "Zielony ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/green)

/datum/bounty/item/slime/pink
	name = "Różowy ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/pink)

/datum/bounty/item/slime/gold
	name = "Złoty ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/gold)

/datum/bounty/item/slime/oil
	name = "Naftowy ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/oil)

/datum/bounty/item/slime/black
	name = "Czarny ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/black)

/datum/bounty/item/slime/lightpink
	name = "Jasnoróżowy ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/lightpink)

/datum/bounty/item/slime/adamantine
	name = "Adamantytowy ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/adamantine)

/datum/bounty/item/slime/rainbow
	name = "Tęczowy ekstrakt szlamu"
	wanted_types = list(/obj/item/slime_extract/rainbow)
