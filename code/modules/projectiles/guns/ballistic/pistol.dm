/obj/item/gun/ballistic/automatic/pistol
	name = "pistolet Stieczkin"
	desc = "Mały, łatwy do ukrycia pistolet 10mm. Lufa ma gwint na tłumik."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = TRUE
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = "sound/weapons/gunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 80
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"
	bolt_wording = "slide"
	fire_rate = 3
	automatic = 0
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/locker
	desc = "Mały, łatwy do ukrycia pistolet 10mm. Lufa ma gwint na tłumik. Ten egzemplarz zardzewiał od długiego leżenia w szafce."

/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "Klasyczny pistolet .45 z magazynkiem o małej pojemności."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "Solidny pistolet .50 AE."
	icon_state = "deagle"
	force = 14
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "Pozłacany Desert Eagle, składany milion razy przez wybitnych marsjańskich rusznikarzy. Strzela amunicją .50 AE."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "Deagle marki Deagle dla operatorów operujących operacyjnie. Strzela amunicją .50 AE."
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/APS
	name = "pistolet Stieczkin APS"
	desc = "Oryginalna rosyjska wersja popularnej broni bocznej Syndykatu. Strzela amunicją 9mm."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "płaski pistolet"
	desc = "Dwuwymiarowy pistolet... co?"
	icon_state = "flatgun"

/obj/item/gun/ballistic/automatic/pistol/stickman/pickup(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>Gdy próbujesz podnieść [src], wyślizguje ci się z rąk..</span>")
	if(prob(50))
		to_chat(user, "<span class='notice'>...i znika ci z oczu! Gdzie to się, do diabła, podziało?</span>")
		qdel(src)
		user.update_icons()
	else
		to_chat(user, "<span class='notice'>...i pojawia się w polu widzenia. Uff, było blisko.</span>")
		user.dropItemToGround(src)

