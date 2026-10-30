/obj/item/ammo_box/magazine/m10mm
	name = "magazynek pistoletowy (10mm)"
	desc = "Magazynek do broni."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/fire
	name = "magazynek pistoletowy (10mm, zapalające)"
	icon_state = "9x19pI"
	desc = "Magazynek do broni. Załadowany nabojami, które podpalają cel."
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	name = "magazynek pistoletowy (10mm HP)"
	icon_state = "9x19pH"
	desc= "Magazynek do broni. Załadowany nabojami z pociskiem wydrążonym, niezwykle skutecznymi przeciw celom bez pancerza, ale prawie bezużytecznymi wobec odzieży ochronnej."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "magazynek pistoletowy (10mm AP)"
	icon_state = "9x19pA"
	desc= "Magazynek do broni. Załadowany nabojami, które przebijają pancerz, ale słabiej działają na zwykłe cele."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m45
	name = "magazynek pistoletowy (.45)"
	icon_state = "45-8"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 8

/obj/item/ammo_box/magazine/m45/update_icon()
	..()
	if (ammo_count() >= 8)
		icon_state = "45-8"
	else
		icon_state = "45-[ammo_count()]"

/obj/item/ammo_box/magazine/pistolm9mm
	name = "magazynek pistoletowy (9mm)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon()
	..()
	icon_state = "9x19p-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/m50
	name = "magazynek pistoletowy (.50ae)"
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50AE
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = 1
