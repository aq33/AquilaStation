/obj/item/crowbar
	name = "kieszonkowy łom"
	desc = "Mały łom. To poręczne narzędzie przydaje się do wielu rzeczy, na przykład do podważania płytek podłogowych albo otwierania drzwi bez zasilania."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=50)

	attack_verb = list("atakuje", "grzmoci", "okłada", "tłucze", "wali")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0, "bleed" = 0)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'

/obj/item/crowbar/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zatłukuje się na śmierć [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/brass
	name = "mosiężny łom"
	desc = "Mosiężny łom. W dotyku jest lekko ciepły."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "crowbar_brass"
	toolspeed = 0.5

/obj/item/crowbar/abductor
	name = "obcy łom"
	desc = "Łom z twardego światła. Wygląda, jakby podważał sam, bez żadnego wysiłku."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1


/obj/item/crowbar/large
	name = "łom"
	desc = "To duży łom. Nie mieści się w kieszeniach, bo jest duży."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	materials = list(/datum/material/iron=70)
	icon_state = "crowbar_large"
	item_state = "crowbar"
	toolspeed = 0.7

/obj/item/crowbar/cyborg
	name = "hydrauliczny łom"
	desc = "Hydrauliczne narzędzie do podważania, proste, ale mocne."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5
