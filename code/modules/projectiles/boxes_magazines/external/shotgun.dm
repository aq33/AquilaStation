/obj/item/ammo_box/magazine/m12g
	name = "magazynek do strzelby (12g, śrut)"
	desc = "Magazynek bębnowy."
	icon_state = "m12gb"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[CEILING(ammo_count(FALSE)/8, 1)*8]"

/obj/item/ammo_box/magazine/m12g/stun
	name = "magazynek do strzelby (12g, breneki paraliżujące)"
	icon_state = "m12gs"
	ammo_type = /obj/item/ammo_casing/shotgun/stunslug

/obj/item/ammo_box/magazine/m12g/slug
	name = "magazynek do strzelby (12g, breneki)"
	icon_state = "m12gb"    //this may need an unique sprite
	ammo_type = /obj/item/ammo_casing/shotgun

/obj/item/ammo_box/magazine/m12g/dragon
	name = "magazynek do strzelby (12g, smoczy oddech)"
	icon_state = "m12gf"
	ammo_type = /obj/item/ammo_casing/shotgun/dragonsbreath

/obj/item/ammo_box/magazine/m12g/bioterror
	name = "magazynek do strzelby (12g, bioterror)"
	icon_state = "m12gt"
	ammo_type = /obj/item/ammo_casing/shotgun/dart/bioterror

/obj/item/ammo_box/magazine/m12g/meteor
	name = "magazynek do strzelby (12g, naboje meteorytowe)"
	icon_state = "m12gbc"
	ammo_type = /obj/item/ammo_casing/shotgun/meteorslug

/obj/item/ammo_box/magazine/m12g/breacher
	name = "magazynek do strzelby (12g, breneki wyważające)"
	icon_state = "m12gt" 	//this may need an unique sprite
	ammo_type = /obj/item/ammo_casing/shotgun/breacher
