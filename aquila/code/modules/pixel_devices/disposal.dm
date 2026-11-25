// Okno bloku utylizacyjnego w formie urządzenia (port pomysłu polonium14/polonium-station#1299).
// Dźwignię spłukiwania można pociągnąć myszką albo kliknąć, lampki pokazują ładowanie, gotowość
// i zawartość, wskaźnik ciśnienia jest pod spodem. Kliknięcie otworu wkłada przedmiot z ręki,
// pustą ręką wyjmuje ostatnio włożoną rzecz. Stworzenia zostają w środku. Bloku pocztowego u nas nie ma.

// Pełne nadpisanie (wpis w LEGACY_OVERRIDES.md): okno "DisposalUnit" z core zastępuje okno urządzenia
/obj/machinery/disposal/bin/ui_interact(mob/user, datum/tgui/ui)
	if(machine_stat & BROKEN)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisposalDevice")
		ui.open()
		ui.set_autoupdate(TRUE) // ciśnienie

/obj/machinery/disposal/bin/ui_data(mob/user)
	var/list/data = ..()
	var/list/items = list()
	var/creatures = 0
	var/big = FALSE
	for(var/atom/movable/thing in src)
		if(isliving(thing))
			var/mob/living/creature = thing
			creatures++
			if(creature.mob_size >= MOB_SIZE_HUMAN)
				big = TRUE
			continue
		if(!isitem(thing))
			continue
		items += list(list(
			"ref" = REF(thing),
			"name" = capitalize(format_text(thing.name)),
			"icon" = pixel_device_icon(thing),
		))
	data["items"] = items
	data["creatures"] = creatures
	data["big_creature"] = big
	data["flushing"] = flushing
	data["powered"] = !(machine_stat & NOPOWER)
	var/obj/item/held = user.get_active_held_item()
	data["holding"] = held && !(held.item_flags & ABSTRACT) ? capitalize(format_text(held.name)) : null
	return data

/obj/machinery/disposal/bin/ui_act(action, params)
	if(action != "mouth")
		return ..()
	if(..())
		return
	return aq_mouth(usr)

/// Kliknięcie otworu: przedmiot z ręki do środka, pustą ręką ostatni włożony przedmiot z powrotem.
/// Stworzeń nie da się tak wyciągnąć, gracz dostaje tylko podpowiedź.
/obj/machinery/disposal/bin/proc/aq_mouth(mob/living/user)
	if(!isliving(user) || issilicon(user) || !user.Adjacent(src) || flushing)
		return FALSE
	var/obj/item/held = user.get_active_held_item()
	if(held)
		// Jak użycie przedmiotu na bloku, ale niezależnie od trybu walki
		if((held.item_flags & ABSTRACT) || !user.temporarilyRemoveItemFromInventory(held))
			return FALSE
		place_item_in_disposal(held, user)
		update_icon()
		return TRUE
	var/obj/item/last_item
	for(var/obj/item/thing in src)
		last_item = thing
	if(!last_item)
		var/mob/living/creature = locate() in src
		if(creature)
			var/hint = creature.mob_size >= MOB_SIZE_HUMAN ? "W środku jest coś dużego." : "Coś się tam rusza."
			to_chat(user, "<span class='notice'>[hint]</span>")
		return FALSE
	user.put_in_hands(last_item)
	user.visible_message("<span class='notice'>[user] wyjmuje [last_item] z [src].</span>", "<span class='notice'>Wyjmujesz [last_item] z [src].</span>")
	update_icon()
	return TRUE
