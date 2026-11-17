// AQUILA - skąd załoga bierze wędki: paczka w zaopatrzeniu, NutriMax w botanice i wędka zaawansowana w protolathe
// (węzeł „Inżynieria botaniczna”).

/datum/supply_pack/organic/fishing
	name = "Skrzynia wędkarska"
	desc = "Dwie wędki i dwie puszki robaków na przynętę. Na planetach z wodą obiad sam wskoczy na haczyk."
	cost = 1000
	contains = list(
		/obj/item/fishing_rod,
		/obj/item/fishing_rod,
		/obj/item/storage/box/fishing_worms,
		/obj/item/storage/box/fishing_worms,
	)
	crate_name = "skrzynia wędkarska"

/obj/machinery/vending/hydronutrients/New()
	products[/obj/item/fishing_rod] = 3
	products[/obj/item/storage/box/fishing_worms] = 5
	return ..()

/datum/design/fishing_rod_tech
	name = "Wędka zaawansowana"
	desc = "Wędka z kompozytu z czujnikiem brania i żyłką odporną na żar (łowienie w lawie)."
	id = "fishing_rod_tech"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plastic = 2000, /datum/material/plasma = 500)
	build_path = /obj/item/fishing_rod/tech
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/botany/New()
	. = ..()
	design_ids += "fishing_rod_tech"
