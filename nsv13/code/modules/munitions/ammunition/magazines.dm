/obj/item/ammo_box/magazine/nsv
	name = "zwykła amunicja"
	desc = "Magazynek do przesadnie zwyczajnej broni okrętowej. Pewnie nie powinno go tu być."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 300
	var/overlay_name = "pdc_overlay"
	var/overlay_frames = 17	//how many frames are in the "animation" of the ammo overlay
	var/last_frame //what the last frame was

/obj/item/ammo_box/magazine/nsv/forceMove()
	..()
	update_icon()//update icon when removed from a machine

/obj/item/ammo_box/magazine/nsv/update_icon()
	if (isobj(loc)) //don't update if it's in an object
		if (!(istype(loc, /obj/item/storage)||istype(loc, /obj/item/clothing)))//unless it's a backpack or something
			return FALSE
	var/count = length(stored_ammo) //faster than ammo_count()
	if (!count)
		icon_state = "[initial(icon_state)]_empty"
		cut_overlays()
		last_frame = null
		return FALSE
	icon_state = "[initial(icon_state)]"
	if (count >= max_ammo)
		cut_overlays()
		last_frame = null
		return FALSE

	var/new_frame = round(overlay_frames * (count/max_ammo) + 1)
	if (new_frame == last_frame)
		return FALSE
	last_frame = new_frame
	cut_overlays()

	if (count >= max_ammo)
		return FALSE

	add_overlay(icon("[icon]","[overlay_name]",frame = new_frame))
	return TRUE

/obj/item/ammo_box/magazine/nsv/examine(mob/user)
	. = ..()
	. += "<span class ='notice'>Zostało naboi: [ammo_count()].</span>"

/obj/item/ammo_box/magazine/nsv/pdc
	name = "amunicja do działka obrony punktowej (30.12x82 mm)"
	desc = "Skrzynka pocisków PDC do stanowisk obrony punktowej okrętu. Zwykle służą do zestrzeliwania nadlatujących rakiet i wspierają duże okręty w walce na bliski dystans."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "pdc"
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"
	max_ammo = 300

/obj/item/ammo_box/magazine/internal/boltaction/pdc
	max_ammo = 3
	ammo_type = /obj/item/ammo_casing/pdc
	caliber = "mm30.12"

/obj/item/ammo_casing/pdc
	name = "łuska 30.12x82 mm"
	desc = "Łuska naboju 30.12x82 mm."
	projectile_type = /obj/item/projectile/bullet/pdc_round
	caliber = "mm30.12"

/obj/item/ammo_casing/pdc/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, spread_mult, atom/fired_from)
	if(istype(fired_from, /obj/item/gun/ballistic/rifle/boltaction/pdc)) // Overrides the damage for pdcrifle because overmap pdc only deals 15 dmg
		BB.damage = 50
	. = ..()

/obj/item/ammo_box/magazine/nsv/flak
	name = "pociski flak 40 mm"
	icon_state = "flak"
	ammo_type = /obj/item/ammo_casing/flak
	caliber = "mm40"
	max_ammo = 150

/obj/item/ammo_casing/flak
	name = "łuska pocisku flak 40 mm"
	desc = "Łuska naboju 40 mm."
	projectile_type = /obj/item/projectile/bullet/flak
	caliber = "mm40"

/obj/item/ammo_box/magazine/nsv/anti_air
	name = "pociski do wieżyczki przeciwlotniczej" // Just going to rename the current box to avoid a bunch of map changes, or creating duplicate code for a rename
	ammo_type = /obj/item/ammo_casing/anti_air
	caliber = "mm50pdc"
	max_ammo = 300
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_casing/anti_air
	name = "łuska 50 mm"
	desc = "Łuska naboju 50 mm."
	projectile_type = /obj/item/projectile/bullet/aa_round
	caliber = "mm50pdc"
