// AQ - zniszczona część myśliwca nie zostaje w slocie.
// Wybuch na polu myśliwca trafia też w części w jego wnętrzu (SSexplosions bierze GetAllContents),
// więc osłona albo pancerz potrafią się zniszczyć przed samym myśliwcem. Slot dalej wskazywał
// usuniętą część i small_craft/take_damage zadawał jej obrażenia („taking damage after deletion”).

/datum/component/ship_loadout/get_slot(slot)
	var/obj/item/fighter_component/component = ..()
	if(component && QDELETED(component))
		hardpoint_slots[slot] = null
		return null
	return component
