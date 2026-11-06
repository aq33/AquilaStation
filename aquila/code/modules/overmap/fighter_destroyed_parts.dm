// AQ - zniszczony pancerz albo osłona kokpitu nie przyjmuje dalej obrażeń.
// Wybuch na polu myśliwca trafia też w części w jego wnętrzu (SSexplosions bierze GetAllContents),
// więc osłona albo pancerz potrafią się zniszczyć przed samym myśliwcem. Slot dalej wskazywał
// usuniętą część i small_craft/take_damage zadawał jej obrażenia („taking damage after deletion”).
// Czyścimy tylko te dwa sloty, z których korzysta take_damage: get_slot zostaje bez zmian, bo wiele
// miejsc w nsv13/ zakłada, że np. komputer dokowania nigdy nie jest null.

/obj/structure/overmap/small_craft/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, nsv_damagesound = TRUE)
	if(loadout)
		for(var/slot in list(HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_CANOPY))
			var/obj/item/fighter_component/part = loadout.hardpoint_slots[slot]
			if(part && QDELETED(part))
				loadout.hardpoint_slots[slot] = null
	return ..()
