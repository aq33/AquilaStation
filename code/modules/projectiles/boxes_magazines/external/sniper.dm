/obj/item/ammo_box/magazine/sniper_rounds
	name = "naboje snajperskie (.50)"
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/p50
	max_ammo = 6
	caliber = ".50"

/obj/item/ammo_box/magazine/sniper_rounds/update_icon()
	..()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = "naboje snajperskie (Zzzzz)"
	desc = "Nasenne naboje snajperskie na szczęśliwe dni i martwo ciche noce..."
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/p50/soporific
	max_ammo = 3
	caliber = ".50"

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "naboje snajperskie (penetrujące)"
	desc = "Niezwykle potężny nabój, który przechodzi na wylot przez osłonę i każdego, kto miał pecha za nią stać."
	ammo_type = /obj/item/ammo_casing/p50/penetrator
	max_ammo = 5
