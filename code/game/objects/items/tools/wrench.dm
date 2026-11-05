/obj/item/wrench
	name = "klucz nastawny"
	desc = "Klucz do typowych zastosowań. Znajdziesz go w swojej ręce."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	materials = list(/datum/material/iron=150)
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'
	attack_verb = list("grzmoci", "okłada", "tłucze", "wali")
	tool_behaviour = TOOL_WRENCH
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0, "bleed" = 0)

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zatłukuje się na śmierć [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/wrench/brass
	name = "mosiężny klucz"
	desc = "Mosiężny klucz. W dotyku jest lekko ciepły."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "wrench_brass"
	toolspeed = 0.5

/obj/item/wrench/abductor
	name = "obcy klucz"
	desc = "Spolaryzowany klucz. Obraca wszystko, co znajdzie się między jego szczękami."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1

/obj/item/wrench/medical
	name = "klucz medyczny"
	desc = "Klucz medyczny do typowych (medycznych?) zastosowań. Znajdziesz go w swojej ręce."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	attack_verb = list("leczy", "leczy", "stuka", "szturcha", "analizuje") //"cobbyed"
	///var to hold the name of the person who suicided
	var/suicider

/obj/item/wrench/medical/examine(mob/user)
	. = ..()
	if(suicider)
		. += "<span class='notice'>Z jakiegoś powodu przypomina ci [suicider].</span>"

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] modli się do medycznego klucza, by zabrał jego duszę. Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	// TODO Make them glow with the power of the M E D I C A L W R E N C H
	// during their ascension

	// Stun stops them from wandering off
	user.Stun(100, ignore_canstun = TRUE)
	playsound(loc, 'sound/effects/pray.ogg', 50, 1, -1)

	// Let the sound effect finish playing
	add_fingerprint(user)
	sleep(20)
	if(!user)
		return
	for(var/obj/item/W in user)
		user.dropItemToGround(W)
	suicider = user.real_name
	user.dust()
	return OXYLOSS

/obj/item/wrench/cyborg
	name = "klucz hydrauliczny"
	desc = "Zaawansowany klucz robotyczny napędzany wewnętrzną hydrauliką. Dwa razy szybszy od wersji ręcznej."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wrench_cyborg"
	toolspeed = 0.5
