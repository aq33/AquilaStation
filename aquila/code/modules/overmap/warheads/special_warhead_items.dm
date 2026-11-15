/// AQUILA - torpedy z głowicami specjalnymi (special_warheads.dm): głowice do budowy torpedy z części (jak głowica
/// przeciwbunkrowa czy Hellfire), projekty w protolacie amunicji za węzłem „Głowice specjalne” i paczka w zaopatrzeniu.
/// Sprite'y: zwykła torpeda i głowica w kolorze ładunku.

// Gotowe torpedy (powstają z obudowy po zamontowaniu głowicy)

/obj/item/ship_weapon/ammunition/torpedo/special_incendiary
	name = "\improper torpeda zapalająca NTP-7Z „ŻAR” 530 mm"
	desc = "Torpeda, która słabiej bije w kadłub, ale po przebiciu poszycia wpuszcza do środka celu płonącą mieszankę tlenu i plazmy."
	color = "#ff7a2a"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/special/incendiary

/obj/item/ship_weapon/ammunition/torpedo/special_chemical
	name = "\improper torpeda chemiczna NTP-7C „MIAZMAT” 530 mm"
	desc = "Torpeda, która słabiej bije w kadłub, ale po przebiciu poszycia wypuszcza w środku celu trujący dym albo pianę."
	color = "#7cff4a"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/special/chemical

/obj/item/ship_weapon/ammunition/torpedo/special_flash
	name = "\improper torpeda ogłuszająca NTP-7O „GROM” 530 mm"
	desc = "Torpeda, która słabiej bije w kadłub, ale po przebiciu poszycia odpala w środku celu potężny ładunek hukowo-błyskowy."
	color = "#ffe14a"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/special/flash

/obj/item/ship_weapon/ammunition/torpedo/special_ion
	name = "\improper torpeda jonowa NTP-7J „BURZA” 530 mm"
	desc = "Torpeda prawie bez ładunku wybuchowego. Przed trafieniem zbija tarcze celu, a w środku okrętu wywołuje impuls elektromagnetyczny, który na chwilę wyłącza trafiony moduł."
	color = "#4ac8ff"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/special/ion

/obj/item/ship_weapon/ammunition/torpedo/special_boarding
	name = "\improper torpeda desantowa NTP-7D „RÓJ” 530 mm"
	desc = "Torpeda z kilkoma złożonymi droidami abordażowymi w miejscu głowicy. Po przebiciu poszycia droidy wysypują się do środka celu i walczą po stronie Nanotrasenu."
	color = "#c04aff"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/special/boarding

// Głowice do budowy torpedy

/obj/item/ship_weapon/parts/missile/warhead/special_incendiary
	name = "głowica torpedy zapalającej NTP-7Z „ŻAR”"
	icon_state = "warhead"
	desc = "Głowica ze zbiornikami tlenu i plazmy. Po przebiciu poszycia celu wypuszcza je rozgrzane do zapłonu."
	color = "#ff7a2a"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/special_incendiary

/obj/item/ship_weapon/parts/missile/warhead/special_chemical
	name = "głowica torpedy chemicznej NTP-7C „MIAZMAT”"
	icon_state = "warhead"
	desc = "Głowica z pojemnikiem trucizny i rozpylaczem. Po przebiciu poszycia celu zasnuwa jego wnętrze trującym dymem albo pianą."
	color = "#7cff4a"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/special_chemical

/obj/item/ship_weapon/parts/missile/warhead/special_flash
	name = "głowica torpedy ogłuszającej NTP-7O „GROM”"
	icon_state = "warhead"
	desc = "Głowica z ładunkiem hukowo-błyskowym. Po przebiciu poszycia celu oślepia i ogłusza załogę w pobliżu."
	color = "#ffe14a"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/special_flash

/obj/item/ship_weapon/parts/missile/warhead/special_ion
	name = "głowica torpedy jonowej NTP-7J „BURZA”"
	icon_state = "warhead"
	desc = "Głowica z generatorem impulsu jonowego. Zbija tarcze celu, a w środku okrętu wywołuje impuls elektromagnetyczny."
	color = "#4ac8ff"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/special_ion

/obj/item/ship_weapon/parts/missile/warhead/special_boarding
	name = "kapsuła desantowa torpedy NTP-7D „RÓJ”"
	icon_state = "warhead"
	desc = "Stożek dziobowy z trzema złożonymi droidami abordażowymi. Po przebiciu poszycia celu droidy rozkładają się i atakują jego załogę."
	color = "#c04aff"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/special_boarding

// Projekty w protolacie amunicji

/datum/design/special_incendiary_warhead
	name = "Głowica torpedy zapalającej"
	desc = "Projekt głowicy, która wpuszcza do wnętrza celu płonącą mieszankę tlenu i plazmy."
	id = "special_incendiary_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/plasma = 8000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/special_incendiary
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/special_chemical_warhead
	name = "Głowica torpedy chemicznej"
	desc = "Projekt głowicy, która zasnuwa wnętrze celu trującym dymem albo pianą."
	id = "special_chemical_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/copper = 500, /datum/material/plasma = 2000, /datum/material/silver = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/special_chemical
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/special_flash_warhead
	name = "Głowica torpedy ogłuszającej"
	desc = "Projekt głowicy z ładunkiem hukowo-błyskowym."
	id = "special_flash_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/silver = 500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/special_flash
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/special_ion_warhead
	name = "Głowica torpedy jonowej"
	desc = "Projekt głowicy, która zbija tarcze i wyłącza na chwilę trafiony moduł celu."
	id = "special_ion_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/copper = 2000, /datum/material/gold = 2000, /datum/material/uranium = 2000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/special_ion
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/special_boarding_warhead
	name = "Kapsuła desantowa torpedy"
	desc = "Projekt stożka dziobowego z droidami abordażowymi."
	id = "special_boarding_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/titanium = 3000, /datum/material/gold = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/special_boarding
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/techweb_node/special_warheads
	id = "special_warheads"
	display_name = "Głowice specjalne"
	description = "Torpedy, które zamiast wielkiego wybuchu wpuszczają do wnętrza celu ogień, truciznę, huk, impuls jonowy albo droidy abordażowe."
	prereq_ids = list("advanced_torpedo_components")
	design_ids = list("special_incendiary_warhead", "special_chemical_warhead", "special_flash_warhead", "special_ion_warhead", "special_boarding_warhead")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 6000)
	export_price = 7000
	tech_tier = 4

// Paczka w zaopatrzeniu

/datum/supply_pack/munitions/special_warheads
	name = "Głowice torped specjalne"
	desc = "Po jednej głowicy torpedy zapalającej, chemicznej, ogłuszającej, jonowej i desantowej. Każdą trzeba zamontować w obudowie torpedy."
	cost = 4000
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/special_incendiary,
					/obj/item/ship_weapon/parts/missile/warhead/special_chemical,
					/obj/item/ship_weapon/parts/missile/warhead/special_flash,
					/obj/item/ship_weapon/parts/missile/warhead/special_ion,
					/obj/item/ship_weapon/parts/missile/warhead/special_boarding)
	crate_name = "skrzynia z głowicami torped specjalnych"
