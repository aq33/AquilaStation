// Pas amunicyjny M276 z TGMC (tgstation/TerraGov-Marine-Corps, code/game/objects/items/storage/belt.dm).
// Sprite'y z TGMC (icons/obj/clothing/belts.dmi, icons/mob/clothing/belt.dmi), licencja CC BY-NC-SA 3.0.
// TGMC ma własny /datum/storage i magazynki /obj/item/ammo_magazine: pojemność przepisana na nasz komponent schowka,
// a listy can_hold na nasze magazynki, naboje i pudełka amunicji. Bez wersji wypełnionych magazynkami TGMC.
// W TGMC to kilka pasów (amunicyjny, na naboje do strzelby, na granaty); u nas jeden pas łączy ich funkcje.

/// Pas na magazynki, naboje, noże, flary i granaty; napełnia się nabojami do strzelby z pudełka
/obj/item/storage/belt/aq_tgmc
	name = "pas amunicyjny M276"
	desc = "Standardowe oporządzenie piechoty: modułowy pas z klamrami i ładownicami. Mieści magazynki, naboje, granaty, nóż bojowy i flary. Kliknij nim pudełko z nabojami do strzelby, by przełożyć je do pasa."
	icon = 'aquila/icons/obj/clothing/belts_tgmc.dmi'
	worn_icon = 'aquila/icons/mob/clothing/belt_tgmc.dmi'
	icon_state = "marinebelt"
	worn_icon_state = "marinebelt"
	item_state = "security"

/obj/item/storage/belt/aq_tgmc/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 9
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 27
	STR.display_numerical_stacking = TRUE
	STR.can_hold = typecacheof(list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/kitchen/knife/combat,
		/obj/item/flashlight/flare,
		/obj/item/grenade,
	))
	// pociski dział okrętowych to też ammo_box/magazine
	STR.cant_hold = typecacheof(list(/obj/item/ammo_box/magazine/nsv))

// Jak pas na naboje w TGMC: kliknięcie pasem w pudełko z nabojami (albo pudełkiem w pas) przekłada naboje do pasa
/obj/item/storage/belt/aq_tgmc/attackby(obj/item/I, mob/user, params)
	if(is_shell_source(I))
		refill_from(I, user)
		return
	return ..()

/obj/item/storage/belt/aq_tgmc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(is_shell_source(target))
		refill_from(target, user)

/// Pudełko z nabojami do strzelby, które pas opróżnia; magazynki i szybkoładowacze pas po prostu chowa
/obj/item/storage/belt/aq_tgmc/proc/is_shell_source(atom/A)
	if(istype(A, /obj/item/storage/box))
		return !!(locate(/obj/item/ammo_casing/shotgun) in A)
	if(istype(A, /obj/item/ammo_box) && !istype(A, /obj/item/ammo_box/magazine) && !istype(A, /obj/item/ammo_box/shotgun_lethal))
		var/obj/item/ammo_box/box = A
		return !!(locate(/obj/item/ammo_casing/shotgun) in box.stored_ammo)
	return FALSE

/// Przekłada naboje do strzelby z pudełka do pasa; zwraca liczbę przełożonych
/obj/item/storage/belt/aq_tgmc/proc/refill_from(obj/item/source, mob/user)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/list/shells = list()
	if(istype(source, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = source
		for(var/obj/item/ammo_casing/shotgun/shell in box.stored_ammo)
			shells += shell
	else
		for(var/obj/item/ammo_casing/shotgun/shell in source)
			shells += shell
	if(!length(shells))
		balloon_alert(user, "brak nabojów do strzelby!")
		return 0
	if(length(contents) >= STR.max_items)
		balloon_alert(user, "pas jest pełny!")
		return 0
	balloon_alert(user, "przekładasz naboje...")
	if(!do_after(user, 1.5 SECONDS, TRUE, source))
		return 0
	var/moved = 0
	for(var/obj/item/ammo_casing/shotgun/shell as anything in shells)
		if(QDELETED(shell) || length(contents) >= STR.max_items)
			break
		if(istype(source, /obj/item/ammo_box))
			var/obj/item/ammo_box/box = source
			if(!(shell in box.stored_ammo))
				continue
			box.stored_ammo -= shell
		else if(shell.loc != source)
			continue
		if(!STR.handle_item_insertion(shell, TRUE, user))
			if(istype(source, /obj/item/ammo_box))
				var/obj/item/ammo_box/box = source
				box.stored_ammo += shell
			break
		moved++
	source.update_icon()
	if(moved)
		balloon_alert(user, "przełożono naboje: [moved]")
	return moved
