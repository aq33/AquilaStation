/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	opacity = 0
	density = FALSE
	layer = SIGN_LAYER
	max_integrity = 100
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 0, "bleed" = 0)
	var/buildable_sign = 1 //unwrenchable and modifiable
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE

/obj/structure/sign/basic
	name = "pusty znak"
	desc = "Jak znaki mogą być prawdziwe, skoro nasze oczy nie są prawdziwe?"
	icon_state = "backing"

/obj/structure/sign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, 1)

/obj/structure/sign/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && buildable_sign)
		user.visible_message("<span class='notice'>[user] zaczyna zdejmować [src]...</span>", \
							 "<span class='notice'>Zaczynasz odczepiać [src].</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 40))
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] odczepia [src].</span>", \
								 "<span class='notice'>Odczepiasz [src].</span>")
			var/obj/item/sign_backing/SB = new (get_turf(user))
			SB.icon_state = icon_state
			SB.sign_path = type
			SB.setDir(dir)
			qdel(src)
		return
	else if(istype(I, /obj/item/pen) && buildable_sign)
		var/list/sign_types = list("Obszar zabezpieczony", "Zagrożenie biologiczne", "Wysokie napięcie", "Promieniowanie", "Próżnia", "Utylizacja: do przestrzeni kosmicznej", "Niebezpieczeństwo: ogień", "Zakaz palenia", "Ambulatorium", "Nauka", "Chemia", \
		"Hydroponika", "Ksenobiologia")
		var/obj/structure/sign/sign_type
		switch(input(user, "Wybierz rodzaj znaku.", "Dostosowanie znaku") as null|anything in sortList(sign_types))
			if("Blank")
				sign_type = /obj/structure/sign/basic
			if("Obszar zabezpieczony")
				sign_type = /obj/structure/sign/warning/securearea
			if("Zagrożenie biologiczne")
				sign_type = /obj/structure/sign/warning/biohazard
			if("Wysokie napięcie")
				sign_type = /obj/structure/sign/warning/electricshock
			if("Promieniowanie")
				sign_type = /obj/structure/sign/warning/radiation
			if("Próżnia")
				sign_type = /obj/structure/sign/warning/vacuum
			if("Utylizacja: do przestrzeni kosmicznej")
				sign_type = /obj/structure/sign/warning/deathsposal
			if("Niebezpieczeństwo: ogień")
				sign_type = /obj/structure/sign/warning/fire
			if("Zakaz palenia")
				sign_type = /obj/structure/sign/warning/nosmoking/circle
			if("Ambulatorium")
				sign_type = /obj/structure/sign/departments/medbay/alt
			if("Nauka")
				sign_type = /obj/structure/sign/departments/science
			if("Chemia")
				sign_type = /obj/structure/sign/departments/chemistry
			if("Hydroponika")
				sign_type = /obj/structure/sign/departments/botany
			if("Ksenobiologia")
				sign_type = /obj/structure/sign/departments/xenobio

		//Make sure user is adjacent still
		if(!Adjacent(user))
			return

		if(!sign_type)
			return

		//It's import to clone the pixel layout information
		//Otherwise signs revert to being on the turf and
		//move jarringly
		var/obj/structure/sign/newsign = new sign_type(get_turf(src))
		newsign.pixel_x = pixel_x
		newsign.pixel_y = pixel_y
		qdel(src)
	else
		return ..()

/obj/item/sign_backing
	name = "podkład znaku"
	desc = "Znak z klejącym podkładem."
	icon = 'icons/obj/decals.dmi'
	icon_state = "backing"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	var/sign_path = /obj/structure/sign/basic //the type of sign that will be created when placed on a turf

/obj/item/sign_backing/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] przymocowuje [src] do [T].</span>", \
							 "<span class='notice'>Przymocowujesz znak do [T].</span>")
		playsound(T, 'sound/items/deconstruct.ogg', 50, 1)
		var/obj/structure/sign/S = new sign_path(T)
		S.setDir(dir)
		qdel(src)

/obj/item/sign_backing/Move(atom/new_loc, direct = 0)
	// pulling, throwing, or conveying a sign backing does not rotate it
	var/old_dir = dir
	. = ..()
	setDir(old_dir)

/obj/item/sign_backing/attack_self(mob/user)
	. = ..()
	setDir(turn(dir, 90))

/obj/structure/sign/nanotrasen
	name = "\improper logo Nanotrasen"
	desc = "Znak z logo Nanotrasen. Chwała Nanotrasen!"
	icon_state = "nanotrasen"

/obj/structure/sign/logo
	name = "\improper logo Nanotrasen"
	desc = "Korporacyjne logo Nanotrasen."
	icon_state = "nanotrasen_sign1"
