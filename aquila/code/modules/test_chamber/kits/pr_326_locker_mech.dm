// aq33/AquilaStation#326 - GR-3YT1.DE Locker Exosuit i Improvised Laser Rifle (port aq33/tgstation#480)

/datum/test_chamber_kit/pr_326
	name = "PR 326: locker mech - gotowy"
	pr = "aq33/AquilaStation#326"
	description = "Gotowy locker mech i jego trzy makeshift narzędzia. Załóż max 2 narzędzia (trzecie ma odmówić - max_equip 2). Wejście trwa 6 s. \
	Clampem podnieś skrzynię (cargo max 5), spróbuj podważyć śluzę - makeshift clamp ma odmówić. Wiertło i laser mają działać. Zniszczony mech wyrzuca ładunek. \
	Improvised Laser Rifle: postrzelaj."
	items = list(
		/obj/mecha/working/lockermech = 1,
		/obj/item/mecha_parts/mecha_equipment/drill/makeshift = 1,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift = 1,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift = 1,
		/obj/item/gun/energy/laser/makeshiftlasrifle = 1,
		/obj/structure/closet/crate = 2,
		/obj/machinery/door/airlock = 1,
	)

/datum/test_chamber_kit/pr_326_crafting
	name = "PR 326: locker mech - crafting"
	pr = "aq33/AquilaStation#326"
	description = "Materiały do zrobienia mecha i narzędzi w menu craftingu (zakładka mechów/broni): mech, wiertło (skrzynka + śrubokręt), clamp (krzesło), \
	laser mecha (wymaga Improvised Laser Rifle). Sprawdź, czy przepisy są widoczne i dają właściwe przedmioty."
	items = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/flashlight = 1,
		/obj/item/extinguisher = 1,
		/obj/item/storage/toolbox/mechanical = 2,
		/obj/item/electronics/airlock = 1,
		/obj/item/stack/package_wrap = 1,
		/obj/item/chair = 1,
		/obj/item/gun/energy/laser/makeshiftlasrifle = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/wrench = 1,
		/obj/item/wirecutters = 1,
		/obj/item/screwdriver = 1,
	)
