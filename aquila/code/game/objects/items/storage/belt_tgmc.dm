// Pasy amunicyjne z TGMC (tgstation/TerraGov-Marine-Corps, code/game/objects/items/storage/belt.dm).
// Sprite'y z TGMC (icons/obj/clothing/belts.dmi, icons/mob/clothing/belt.dmi), licencja CC BY-NC-SA 3.0.
// TGMC ma własny /datum/storage i magazynki /obj/item/ammo_magazine: pojemność przepisana na nasz komponent schowka,
// a listy can_hold na nasze magazynki, naboje i pudełka amunicji. Bez wersji wypełnionych magazynkami TGMC.

/// Wspólne dla pasów z TGMC: ikony z aquila/
/obj/item/storage/belt/aq_tgmc
	icon = 'aquila/icons/obj/clothing/belts_tgmc.dmi'
	worn_icon = 'aquila/icons/mob/clothing/belt_tgmc.dmi'
	item_state = "security"

/// Pas na magazynki, noże, flary i granaty (M276 i jego odmiany)
/obj/item/storage/belt/aq_tgmc/ammo
	name = "pas amunicyjny M276"
	desc = "Standardowe oporządzenie piechoty: modułowy pas z klamrami i ładownicami. Ta wersja służy do noszenia dużej ilości amunicji."
	icon_state = "marinebelt"
	worn_icon_state = "marinebelt"

/obj/item/storage/belt/aq_tgmc/ammo/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 18
	STR.can_hold = typecacheof(list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/kitchen/knife/combat,
		/obj/item/flashlight/flare,
		/obj/item/grenade,
	))
	// pociski dział okrętowych to też ammo_box/magazine
	STR.cant_hold = typecacheof(list(/obj/item/ammo_box/magazine/nsv))

/obj/item/storage/belt/aq_tgmc/ammo/upp
	name = "pas amunicyjny Typ 41"
	desc = "Oporządzenie z ładownicami na magazynki. Mimo innego kroju ładownice są na tyle uniwersalne, że mieszczą to samo co M276."
	icon_state = "upp_belt"
	worn_icon_state = "upp_belt"

/obj/item/storage/belt/aq_tgmc/ammo/som
	name = "pas amunicyjny S18"
	desc = "Pas wywodzący się z M276 i starego wyposażenia ochrony kolonii."
	icon_state = "som_belt"
	worn_icon_state = "som_belt"

/obj/item/storage/belt/aq_tgmc/ammo/icc
	name = "pas amunicyjny Modello/120"
	desc = "Pas zaprojektowany do noszenia amunicji, uszyty z płowego włókna syntetycznego."
	icon_state = "icc_belt"
	worn_icon_state = "icc_belt"

/// Pas z pętlami na naboje do strzelby; napełnia się z pudełka nabojów
/obj/item/storage/belt/aq_tgmc/shotgun
	name = "pas na naboje do strzelby"
	desc = "Pas amunicyjny z pętlami na naboje do strzelby. Kliknij nim pudełko z nabojami, by przełożyć je do pasa."
	icon_state = "shotgunbelt"
	worn_icon_state = "shotgunbelt"
	item_state = "bandolier"

/obj/item/storage/belt/aq_tgmc/shotgun/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 14
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 28
	STR.display_numerical_stacking = TRUE
	STR.can_hold = typecacheof(list(
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box/shotgun_lethal,
	))

/obj/item/storage/belt/aq_tgmc/shotgun/icc
	name = "pas na naboje Modello/121"
	desc = "Pas amunicyjny z pętlami na naboje do strzelby, uszyty z płowego włókna syntetycznego. Kliknij nim pudełko z nabojami, by przełożyć je do pasa."
	icon_state = "shotgunbelt_icc"
	worn_icon_state = "shotgunbelt_icc"

// Jak w TGMC: kliknięcie pasem w pudełko z nabojami (albo pudełkiem w pas) przekłada naboje do pasa
/obj/item/storage/belt/aq_tgmc/shotgun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/box) || (istype(I, /obj/item/ammo_box) && !istype(I, /obj/item/ammo_box/shotgun_lethal)))
		refill_from(I, user)
		return
	return ..()

/obj/item/storage/belt/aq_tgmc/shotgun/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(istype(target, /obj/item/storage/box) || (istype(target, /obj/item/ammo_box) && !istype(target, /obj/item/ammo_box/shotgun_lethal)))
		refill_from(target, user)

/// Przekłada naboje do strzelby z pudełka do pasa; zwraca liczbę przełożonych
/obj/item/storage/belt/aq_tgmc/shotgun/proc/refill_from(obj/item/source, mob/user)
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
	if(!do_after(user, 1.5 SECONDS, source))
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

/// Pas na granaty (M276 w wersji na granaty)
/obj/item/storage/belt/aq_tgmc/grenade
	name = "pas na granaty M276"
	desc = "Standardowe oporządzenie piechoty: modułowy pas z klamrami. Ta wersja służy do noszenia dużej liczby granatów."
	icon_state = "grenadebelt"
	worn_icon_state = "grenadebelt"

/obj/item/storage/belt/aq_tgmc/grenade/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 9
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 27
	STR.can_hold = typecacheof(list(/obj/item/grenade))

/// Mała sakwa na pas na cokolwiek
/obj/item/storage/belt/aq_tgmc/sparepouch
	name = "sakwa G8"
	desc = "Mała, lekka sakwa przypinana do pasa. Daje trochę miejsca na drobny sprzęt albo duże magazynki."
	icon_state = "sparepouch"
	worn_icon_state = "sparepouch"

/obj/item/storage/belt/aq_tgmc/sparepouch/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 9
