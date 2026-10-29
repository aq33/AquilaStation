/obj/item/quantum_keycard
	name = "kwantowa karta dostępu"
	desc = "Karta, którą można połączyć z sygnaturą cząsteczkową pada kwantowego. Inne pady kwantowe przenoszą wtedy w to miejsce zamiast do połączonego z nimi pada."
	icon = 'icons/obj/device.dmi'
	icon_state = "quantum_keycard"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/quantumpad/qpad

/obj/item/quantum_keycard/examine(mob/user)
	. = ..()
	if(qpad)
		. += "Jest obecnie połączona z padem kwantowym."
		. += "<span class='notice'>Alt-kliknij, by rozłączyć kartę.</span>"
	else
		. += "<span class='notice'>Włóż [src] do aktywnego pada kwantowego, by ją połączyć.</span>"

/obj/item/quantum_keycard/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	to_chat(user, "<span class='notice'>Zaczynasz wciskać przycisk rozłączania [src]...</span>")
	if(do_after(user, 40, target = src))
		to_chat(user, "<span class='notice'>Karta pika dwa razy i zrywa połączenie kwantowe.</span>")
		qpad = null

/obj/item/quantum_keycard/update_icon()
	if(qpad)
		icon_state = "quantum_keycard_on"
	else
		icon_state = initial(icon_state)
