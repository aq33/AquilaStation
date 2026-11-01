//NEVER USE THIS IT SUX	-PETETHEGOAT
//IT SUCKS A BIT LESS -GIACOM

/obj/item/paint
	gender= PLURAL
	name = "farba"
	desc = "Służy do przemalowywania podłóg i ścian. Woźny może ją usunąć."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "paint_neutral"
	var/paint_color = "FFFFFF"
	item_state = "paintcan"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/paintleft = 10

/obj/item/paint/red
	name = "czerwona farba"
	paint_color = "C73232" //"FF0000"
	icon_state = "paint_red"

/obj/item/paint/green
	name = "zielona farba"
	paint_color = "2A9C3B" //"00FF00"
	icon_state = "paint_green"

/obj/item/paint/blue
	name = "niebieska farba"
	paint_color = "5998FF" //"0000FF"
	icon_state = "paint_blue"

/obj/item/paint/yellow
	name = "żółta farba"
	paint_color = "CFB52B" //"FFFF00"
	icon_state = "paint_yellow"

/obj/item/paint/violet
	name = "fioletowa farba"
	paint_color = "AE4CCD" //"FF00FF"
	icon_state = "paint_violet"

/obj/item/paint/black
	name = "czarna farba"
	paint_color = "333333"
	icon_state = "paint_black"

/obj/item/paint/white
	name = "biała farba"
	paint_color = "FFFFFF"
	icon_state = "paint_white"


/obj/item/paint/anycolor
	gender = PLURAL
	name = "farba adaptacyjna"
	icon_state = "paint_neutral"

/obj/item/paint/anycolor/attack_self(mob/user)
	var/t1 = input(user, "Wybierz kolor:", "[src]", null) in sortList(list( "czerwony", "niebieski", "zielony", "żółty", "fioletowy", "czarny", "biały"))
	if ((user.get_active_held_item() != src || user.stat || user.restrained()))
		return
	switch(t1)
		if("czerwony")
			paint_color = "C73232"
			icon_state = "paint_red"
		if("niebieski")
			paint_color = "5998FF"
			icon_state = "paint_blue"
		if("zielony")
			paint_color = "2A9C3B"
			icon_state = "paint_green"
		if("żółty")
			paint_color = "CFB52B"
			icon_state = "paint_yellow"
		if("fioletowy")
			paint_color = "AE4CCD"
			icon_state = "paint_violet"
		if("biały")
			paint_color = "FFFFFF"
			icon_state = "paint_white"
		if("czarny")
			paint_color = "333333"
			icon_state = "paint_black"
	add_fingerprint(user)


/obj/item/paint/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(paintleft <= 0)
		icon_state = "paint_empty"
		return
	if(!isturf(target) || isspaceturf(target))
		return
	var/newcolor = "#" + paint_color
	target.add_atom_colour(newcolor, WASHABLE_COLOUR_PRIORITY)

/obj/item/paint/paint_remover
	gender =  PLURAL
	name = "zmywacz farby"
	desc = "Służy do usuwania koloru z czegokolwiek."
	icon_state = "paint_neutral"

/obj/item/paint/paint_remover/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!isturf(target) || !isobj(target))
		return
	if(target.color != initial(target.color))
		target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
