/obj/item/ammo_box/magazine/nsv/light_cannon
	name = "amunicja do lekkiego działka"
	desc = "Skrzynka amunicji 20x102 mm do lekkiego działka myśliwca."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "light"
	ammo_type = /obj/item/ammo_casing/light_cannon
	caliber = "mm20"
	max_ammo = 500
	
/obj/item/ammo_box/magazine/nsv/heavy_cannon
	name = "amunicja do ciężkiego działka"
	desc = "Skrzynka amunicji 30x173 mm do ciężkiego działka myśliwca."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "heavy"
	ammo_type = /obj/item/ammo_casing/heavy_cannon
	caliber = "mm30"
	max_ammo = 400

/obj/item/ammo_casing/light_cannon
	name = "łuska 20x102 mm"
	desc = "Łuska naboju 20x102 mm."
	caliber = "mm20"
	projectile_type = /obj/item/projectile/bullet/light_cannon_round

/obj/item/ammo_casing/heavy_cannon
	name = "łuska 30x173 mm"
	desc = "Łuska naboju 30x173 mm."
	caliber = "mm30"
	projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
