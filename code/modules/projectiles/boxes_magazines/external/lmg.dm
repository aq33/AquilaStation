/obj/item/ammo_box/magazine/mm712x82
	name = "magazynek skrzynkowy (7.12x82mm)"
	icon_state = "a762-50"
	ammo_type = /obj/item/ammo_casing/mm712x82
	caliber = "mm71282"
	max_ammo = 50

/obj/item/ammo_box/magazine/mm712x82/hollow
	name = "magazynek skrzynkowy (7.12x82mm HP)"
	ammo_type = /obj/item/ammo_casing/mm712x82/hollow

/obj/item/ammo_box/magazine/mm712x82/ap
	name = "magazynek skrzynkowy (7.12x82mm AP)"
	ammo_type = /obj/item/ammo_casing/mm712x82/ap

/obj/item/ammo_box/magazine/mm712x82/incen
	name = "magazynek skrzynkowy (7.12x82mm, zapalające)"
	ammo_type = /obj/item/ammo_casing/mm712x82/incen

/obj/item/ammo_box/magazine/mm712x82/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/mm712x82/match
	name = "magazynek skrzynkowy (7.12x82mm, wyczynowe)"
	ammo_type = /obj/item/ammo_casing/mm712x82/match
