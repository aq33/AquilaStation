/obj/item/bloodcult_pamphlet
	name = "broszura kultu Nar-Sie"
	desc = "Wygląda jak kartka wyrwana z jednej z ksiąg kultystów. Nosi tytuł „Dziesięć powodów, dla których Nar-Sie może odmienić twoje życie!”."
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state ="pamphlet"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1

/obj/item/bloodcult_pamphlet/attack_self(mob/user, modifiers)
	if (IS_CULTIST(user))
		return
	var/datum/antagonist/cult/new_cultist = new /datum/antagonist/cult()
	new_cultist.cult_team = new_cultist.get_team()
	user.mind.add_antag_datum(new_cultist)

/obj/item/bloodcult_pamphlet/oneuse/attack_self(mob/user, modifiers)
	..()
	qdel(src)

/obj/item/bloodcult_pamphlet/salt_act()
	fire_act(1000, 200)
