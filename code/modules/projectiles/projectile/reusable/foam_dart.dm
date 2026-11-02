/obj/item/projectile/bullet/reusable/foam_dart
	bleed_force = 0
	name = "piankowa strzałka"
	desc = "Mam nadzieję, że nosisz ochronę oczu."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	nodamage = TRUE
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	martial_arts_no_deflect = TRUE
	var/modified = FALSE
	var/obj/item/pen/pen = null

/obj/item/projectile/bullet/reusable/foam_dart/handle_drop()
	if(dropped)
		return
	var/turf/T = get_turf(src)
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newcasing = new ammo_type(T)
	newcasing.modified = modified
	var/obj/item/projectile/bullet/reusable/foam_dart/newdart = newcasing.BB
	newdart.modified = modified
	if(modified)
		newdart.damage = 5
		newdart.nodamage = FALSE
	newdart.damage_type = damage_type
	if(pen)
		newdart.pen = pen
		pen.forceMove(newdart)
		pen = null
	newdart.update_icon()


/obj/item/projectile/bullet/reusable/foam_dart/Destroy()
	pen = null
	return ..()

/obj/item/projectile/bullet/reusable/foam_dart/riot
	name = "prewencyjna piankowa strzałka"
	icon_state = "foamdart_riot_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	nodamage = FALSE
	stamina = 25
	martial_arts_no_deflect = FALSE
