/obj/item/documents
	name = "tajne dokumenty"
	desc = "Dokumenty „ściśle tajne”."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	pressure_resistance = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/documents/nanotrasen
	desc = "„Ściśle tajne” dokumenty Nanotrasen, pełne skomplikowanych diagramów oraz list nazwisk, dat i współrzędnych."
	icon_state = "docs_verified"

/obj/item/documents/syndicate
	desc = "„Ściśle tajne” dokumenty z poufnymi danymi wywiadowczymi o operacjach Syndykatu."

/obj/item/documents/syndicate/red
	name = "czerwone tajne dokumenty"
	desc = "„Ściśle tajne” dokumenty z poufnymi danymi wywiadowczymi o operacjach Syndykatu. Ich autentyczność potwierdza czerwona pieczęć lakowa."
	icon_state = "docs_red"

/obj/item/documents/syndicate/blue
	name = "niebieskie tajne dokumenty"
	desc = "„Ściśle tajne” dokumenty z poufnymi danymi wywiadowczymi o operacjach Syndykatu. Ich autentyczność potwierdza niebieska pieczęć lakowa."
	icon_state = "docs_blue"

/obj/item/documents/syndicate/mining
	desc = "„Ściśle tajne” dokumenty opisujące operacje wydobycia plazmy prowadzone przez Syndykat."

/obj/item/documents/photocopy
	desc = "Kopia jakichś ściśle tajnych dokumentów. Nikt nie zauważy, że to nie oryginały... prawda?"
	var/forgedseal = 0
	var/copy_type = null

/obj/item/documents/photocopy/Initialize(mapload, obj/item/documents/copy=null)
	. = ..()
	if(copy)
		copy_type = copy.type
		if(istype(copy, /obj/item/documents/photocopy)) // Copy Of A Copy Of A Copy
			var/obj/item/documents/photocopy/C = copy
			copy_type = C.copy_type

/obj/item/documents/photocopy/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/toy/crayon/red) || istype(O, /obj/item/toy/crayon/blue))
		if (forgedseal)
			to_chat(user, "<span class='warning'>Już podrobiłeś pieczęć na [src]!</span>")
		else
			var/obj/item/toy/crayon/C = O
			name = "[C.crayon_color == "red" ? "czerwone" : "niebieskie"] tajne dokumenty"
			icon_state = "docs_[C.crayon_color]"
			forgedseal = C.crayon_color
			to_chat(user, "<span class='notice'>Podrabiasz oficjalną pieczęć kredką ([C.crayon_color == "red" ? "czerwoną" : "niebieską"]). Nikt nie zauważy... prawda?</span>")
			update_icon()
