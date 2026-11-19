/// AQUILA - torpedy z głowicami specjalnymi (special_warheads.dm): głowice do budowy torpedy z części (jak głowica
/// przeciwbunkrowa czy Hellfire), projekty w protolacie amunicji za węzłem „Głowice specjalne” i paczka w zaopatrzeniu.
/// Głowica z visceratorami to torpeda opancerzona NSV (torpedo/viscerator), której dotąd używały tylko okręty AI Syndykatu.
/// Sprite'y: zwykła torpeda i głowica w kolorze ładunku.

// Gotowe torpedy (powstają z obudowy po zamontowaniu głowicy)

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

/obj/item/ship_weapon/ammunition/torpedo/viscerator
	name = "\improper torpeda opancerzona NTP-7V z visceratorami 530 mm"
	desc = "Opancerzona torpeda, która przebija poszycie celu i wypuszcza w jego wnętrzu rój visceratorów, oślepiając załogę błyskiem."
	color = "#c04aff"
	projectile_type = /obj/item/projectile/guided_munition/torpedo/viscerator

// Głowice do budowy torpedy

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

/obj/item/ship_weapon/parts/missile/warhead/viscerator
	name = "głowica torpedy opancerzonej NTP-7V z visceratorami"
	icon_state = "warhead"
	desc = "Opancerzony stożek dziobowy z rojem złożonych visceratorów. Po przebiciu poszycia celu visceratory rozkładają się i atakują jego załogę."
	color = "#c04aff"
	fits_type = /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing
	build_path = /obj/item/ship_weapon/ammunition/torpedo/viscerator

// Projekty w protolacie amunicji

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

/datum/design/viscerator_warhead
	name = "Głowica torpedy z visceratorami"
	desc = "Projekt opancerzonej głowicy z rojem visceratorów."
	id = "viscerator_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/titanium = 3000, /datum/material/gold = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/viscerator
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/techweb_node/special_warheads
	id = "special_warheads"
	display_name = "Głowice specjalne"
	description = "Torpedy, które zamiast wielkiego wybuchu wpuszczają do wnętrza celu truciznę, huk albo rój visceratorów."
	prereq_ids = list("advanced_torpedo_components")
	design_ids = list("special_chemical_warhead", "special_flash_warhead", "viscerator_warhead")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 6000)
	export_price = 7000
	tech_tier = 4

// Paczka w zaopatrzeniu

/datum/supply_pack/munitions/special_warheads
	name = "Głowice torped specjalne"
	desc = "Po jednej głowicy torpedy chemicznej, ogłuszającej i z visceratorami. Każdą trzeba zamontować w obudowie torpedy."
	cost = 3000
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/special_chemical,
					/obj/item/ship_weapon/parts/missile/warhead/special_flash,
					/obj/item/ship_weapon/parts/missile/warhead/viscerator)
	crate_name = "skrzynia z głowicami torped specjalnych"
