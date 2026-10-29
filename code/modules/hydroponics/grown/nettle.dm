/obj/item/food/grown/nettle // "snack". yeah. try eating it, pussy
	seed = /obj/item/plant_seeds/preset/nettle
	name = "pokrzywa"
	desc = "Chyba <B>nie</B> warto dotykać jej gołymi rękami..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "nettle"
	bite_consumption_mod = 2
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = "fire"
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb = list("żądli")

/obj/item/food/grown/nettle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] je trochę [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (BRUTELOSS|TOXLOSS)

/obj/item/food/grown/nettle/pickup(mob/living/user)
	..()
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	if(C.gloves)
		return FALSE
	if(HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		return FALSE
	var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
	var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
	if(affecting)
		if(affecting.receive_damage(0, force))
			C.update_damage_overlays()
	to_chat(C, "<span class='userdanger'>Pokrzywa parzy twoją gołą dłoń!</span>")
	return TRUE

/obj/item/food/grown/nettle/afterattack(atom/A as mob|obj, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		to_chat(usr, "Wszystkie liście odpadły z pokrzywy od gwałtownego machania.")
		qdel(src)

/obj/item/food/grown/nettle/basic
	seed = /obj/item/plant_seeds/preset/nettle

/obj/item/food/grown/nettle/basic/Initialize(mapload)
	. = ..()
	var/potency = get_fruit_trait_power(src) * 25
	force = round((5 + potency / 5), 1)

/obj/item/food/grown/nettle/death
	name = "pokrzywa śmierci"
	desc = "Na sam widok <span class='danger'>świecącej</span> pokrzywy budzi się w tobie <span class='boldannounce'>wściekłość</span>!"
	icon_state = "deathnettle"
	bite_consumption_mod = 4 // I guess if you really wanted to
	force = 25
	throwforce = 12
	discovery_points = 300

/obj/item/food/grown/nettle/death/Initialize(mapload)
	. = ..()
	var/potency = get_fruit_trait_power(src) * 25
	force = round((5 + potency / 5), 1)
	throwforce = round((2 + potency / 10), 1)

/obj/item/food/grown/nettle/death/pickup(mob/living/carbon/user)
	if(..())
		if(prob(50))
			user.Paralyze(100)
			to_chat(user, "<span class='userdanger'>Próbując podnieść [src], zostajesz ogłuszony!</span>")

/obj/item/food/grown/nettle/death/attack(mob/living/M, mob/user)
	if(!M.can_inject(user) && user.combat_mode)
		to_chat(user, "<span class='warning'>[src] nieszkodliwie odbija się od [M]! Chroni go przed igłami!</span>")
		return FALSE
	else
		return ..()
