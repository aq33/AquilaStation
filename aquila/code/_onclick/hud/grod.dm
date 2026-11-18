// Górne dłonie Groda (port BeeStation/BeeStation-Hornet#7202): dwie kieszenie w HUD-zie nad rękami.
// Klik pustą kieszenią z rzeczą w aktywnej ręce chowa ją do górnej dłoni (najwyżej GROD_POCKET_MAX_WEIGHT),
// klik pustą ręką wyjmuje. Rzeczy w górnych dłoniach są w zawartości moba, więc nie ma ich w zwykłych slotach.

/// Kieszeń nad ręką: 1 lewa, 2 prawa (rząd nad przyciskiem zamiany rąk)
/proc/ui_grod_pocket_position(index)
	return "CENTER[index == 1 ? "-1" : ""]:16,SOUTH+2:5"

/datum/hud/human/grod/New(mob/living/carbon/human/owner)
	..()
	for(var/index in 1 to 2)
		var/atom/movable/screen/grod_pocket/pocket = new
		pocket.index = index
		pocket.icon = ui_style
		pocket.screen_loc = ui_grod_pocket_position(index)
		pocket.hud = src
		static_inventory += pocket
		pocket.update_contents(owner)

/atom/movable/screen/grod_pocket
	name = "górna dłoń"
	icon_state = "pocket"
	/// 1 lewa, 2 prawa
	var/index = 1
	var/mutable_appearance/item_overlay

/atom/movable/screen/grod_pocket/Click(location, control, params)
	var/mob/living/carbon/human/user = usr
	if(!istype(user) || user.incapacitated())
		return
	var/datum/component/grod_pockets/pockets = user.GetComponent(/datum/component/grod_pockets)
	pockets?.use_pocket(index, user.get_active_held_item())

/// Pokazuje rzecz schowaną w tej dłoni
/atom/movable/screen/grod_pocket/proc/update_contents(mob/living/owner)
	cut_overlay(item_overlay)
	item_overlay = null
	var/datum/component/grod_pockets/pockets = owner?.GetComponent(/datum/component/grod_pockets)
	var/obj/item/held = pockets?.item_slots[index]
	name = held ? "górna dłoń: [held.name]" : "górna dłoń"
	if(held)
		item_overlay = mutable_appearance(held.icon, held.icon_state)
		add_overlay(item_overlay)

/// Dwie górne dłonie Groda. Zmiana typu HUD-u: przy następnym utworzeniu HUD-u (wejście do gry) albo od razu, gdy gracz już gra.
/datum/component/grod_pockets
	/// Rzeczy w lewej i prawej górnej dłoni
	var/list/item_slots = list(null, null)
	/// HUD rasy przed Grodem
	var/old_hud_type

/datum/component/grod_pockets/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = parent
	old_hud_type = H.hud_type
	H.hud_type = /datum/hud/human/grod
	refresh_hud()
	RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(drop_all))

/datum/component/grod_pockets/Destroy(force)
	var/mob/living/carbon/human/H = parent
	drop_all()
	if(istype(H))
		UnregisterSignal(H, COMSIG_LIVING_DEATH)
		H.hud_type = old_hud_type || /datum/hud/human
		refresh_hud()
	return ..()

/datum/component/grod_pockets/proc/refresh_hud()
	var/mob/living/carbon/human/H = parent
	if(!H.client || !H.hud_used)
		return
	var/version = H.hud_used.hud_version
	QDEL_NULL(H.hud_used)
	H.create_mob_hud()
	H.hud_used?.show_hud(version)

/// Chowa rzecz z ręki do pustej górnej dłoni albo wyjmuje ją do pustej ręki
/datum/component/grod_pockets/proc/use_pocket(index, obj/item/I)
	var/mob/living/carbon/human/H = parent
	var/obj/item/stored = item_slots[index]
	if(I)
		if(stored)
			to_chat(H, "<span class='warning'>Ta górna dłoń już coś trzyma.</span>")
			return
		if(I.w_class > GROD_POCKET_MAX_WEIGHT)
			to_chat(H, "<span class='warning'>[I] jest za duży dla górnej dłoni.</span>")
			return
		if(!H.temporarilyRemoveItemFromInventory(I))
			return
		I.forceMove(H)
		item_slots[index] = I
		RegisterSignal(I, COMSIG_MOVABLE_MOVED, PROC_REF(item_moved))
		to_chat(H, "<span class='notice'>Chowasz [I] do górnej dłoni.</span>")
	else if(stored)
		release(index)
		H.put_in_active_hand(stored)
	update_screen()

/datum/component/grod_pockets/proc/release(index)
	var/obj/item/stored = item_slots[index]
	item_slots[index] = null
	if(stored)
		UnregisterSignal(stored, COMSIG_MOVABLE_MOVED)

/// Rzecz wyjęta inaczej (np. zniszczona albo przeniesiona przez kod) przestaje być w dłoni
/datum/component/grod_pockets/proc/item_moved(obj/item/source)
	SIGNAL_HANDLER
	if(source.loc == parent)
		return
	var/index = item_slots.Find(source)
	if(index)
		release(index)
		update_screen()

/// Po śmierci górne dłonie puszczają rzeczy na podłogę
/datum/component/grod_pockets/proc/drop_all()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = parent
	for(var/index in 1 to length(item_slots))
		var/obj/item/stored = item_slots[index]
		if(!stored)
			continue
		release(index)
		if(istype(H))
			stored.forceMove(H.drop_location())
	update_screen()

/datum/component/grod_pockets/proc/update_screen()
	var/mob/living/carbon/human/H = parent
	if(!istype(H) || !H.hud_used)
		return
	for(var/atom/movable/screen/grod_pocket/pocket in H.hud_used.static_inventory)
		pocket.update_contents(H)
