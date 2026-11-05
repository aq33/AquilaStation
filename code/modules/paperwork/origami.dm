/obj/item/origami
	name = "origami"
	desc = "Papier złożony tak, by przypominał... coś."
	icon = 'nsv13/icons/obj/bureaucracy.dmi'
	icon_state = "scrap"
	throw_range = 1
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/obj/item/paper/internalPaper

/obj/item/origami/Initialize(mapload, obj/item/paper/newPaper)
	. = ..()
	pixel_y = base_pixel_y + rand(-8, 8)
	pixel_x = base_pixel_x + rand(-9, 9)
	if(newPaper)
		internalPaper = newPaper
		flags_1 = newPaper.flags_1
		color = newPaper.color
		newPaper.forceMove(src)
	else
		internalPaper = new(src)
	update_icon()

/obj/item/origami/handle_atom_del(atom/A)
	if(A == internalPaper)
		internalPaper = null
		if(!QDELETED(src))
			qdel(src)
	return ..()

/obj/item/origami/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if (AM == internalPaper)
		internalPaper = null
		if(!QDELETED(src))
			qdel(src)

/obj/item/origami/Destroy()
	QDEL_NULL(internalPaper)
	return ..()

/obj/item/origami/update_icon()
	cut_overlays()
	var/list/stamped = internalPaper.stamp_cache
	if(stamped)
		for(var/S in stamped)
			add_overlay("paper_[S]")

/obj/item/origami/attack_self(mob/user)
	to_chat(user, "<span class='notice'>Rozkładasz [src].</span>")
	var/obj/item/paper/internal_paper_tmp = internalPaper
	internal_paper_tmp.forceMove(loc)
	internalPaper = null
	qdel(src)
	user.put_in_hands(internal_paper_tmp)

/obj/item/origami/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, "<span class='notice'>Musisz rozłożyć [src], zanim go zmienisz.</span>")
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on origami
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()

	else if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] przypadkowo się podpala!</span>", \
				"<span class='userdanger'>Chybiasz [src] i przypadkowo się podpalasz!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return
		user.dropItemToGround(src)
		user.visible_message("<span class='danger'>[user] podpala [src] za pomocą [P]!</span>", "<span class='danger'>Podpalasz [src]!</span>")
		fire_act()

	add_fingerprint(user)

/obj/item/origami/papercrane
	name = "papierowy żuraw"
	desc = "Papier złożony w kształt majestatycznego żurawia."
	icon_state = "papercrane"

/obj/item/origami/paperboat
	name = "papierowa łódka"
	desc = "Papier złożony w kształt małej łódki."
	icon_state = "paperboat"

/obj/item/origami/paperfrog
	name = "papierowa żaba"
	desc = "Papier złożony w kształt żaby."
	icon_state = "paperfrog"

/obj/item/origami/papersyndicate
	name = "papierowe S"
	desc = "Papier złożony w literę S. Czyżby to robota agenta Syndykatu?"
	icon_state = "papersyndicate"

/obj/item/paper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-klik na [src], by złożyć go w origami.</span>"

/obj/item/paper/AltClick(mob/living/user, obj/item/I)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return

	var/list/radial_list = list(
		"Papierowy samolot" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperplane"),
		"Papierowy żuraw" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "papercrane"),
		"Papierowa żaba" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperfrog"),
		"Papierowa łódka" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperboat")
	)

	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(origami_action)
		//Origami Master
		radial_list["Papierowy samolot Syndykatu"] = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperplanesyndicate")
		radial_list["Papierowe S"] = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "papersyndicate")

	var/origami_selected = show_radial_menu(user, src, radial_list, require_near = TRUE, tooltips = TRUE)
	if(!origami_selected || !user || user.stat)
		return

	var/origami_type = origami_nametotype(origami_selected)
	if(!origami_type)
		return
	user.temporarilyRemoveItemFromInventory(src)
	I = new origami_type(user, src)
	to_chat(user, "<span class='notice'>Składasz [src] w kształt: [I.name]!</span>")
	user.put_in_hands(I)

//God I wish radial menu just took types. It would clean up rcd code too.
/proc/origami_nametotype(name)
	switch(name)
		if("Papierowy samolot") return /obj/item/origami/paperplane
		if("Papierowy żuraw") return /obj/item/origami/papercrane
		if("Papierowa żaba") return /obj/item/origami/paperfrog
		if("Papierowa łódka") return /obj/item/origami/paperboat
		if("Papierowy samolot Syndykatu") return /obj/item/origami/paperplane/syndicate
		if("Papierowe S") return /obj/item/origami/papersyndicate
