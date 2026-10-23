/datum/heretic_knowledge/armor
	name = "Armorer's Ritual"
	desc = "Stwórz komplet Zbroi Eldritch. \
		Zbroja Eldritch daje świetną ochronę, a z naciągniętym kapturem działa też jako skupienie."
	transmute_text = "Transmutuj stół (albo strój wierzchni) i maskę."
	gain_text = "Rdzawe Wzgórza hojnie przyjęły Kowala. A Kowal \
		odwdzięczył się im tym samym."

	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
	)
	abstract_type = /datum/heretic_knowledge/armor
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 1

/datum/heretic_knowledge/armor/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(!heretic_datum)
		return
	SEND_SIGNAL(heretic_datum, COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST)
	heretic_datum.gain_knowledge(/datum/heretic_knowledge/knowledge_ritual)
