// Skaner kontrabandy N-spect (port tg `code/game/objects/items/inspector.dm`).

/// Ile energii zużywa jeden skan.
#define INSPECTOR_SCAN_COST 5

/obj/item/inspector
	name = "\improper skaner N-spect"
	desc = "Standardowe urządzenie inspekcyjne Centrali. Precyzyjnie sprawdza, czy przedmiot albo jego zawartość jest kontrabandą."
	icon = 'aquila/icons/obj/sec_med/sec_med.dmi'
	icon_state = "inspector"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 460, /datum/material/uranium = 2000, /datum/material/gold = 1000)
	/// Ogniwo zasilające skaner. Ścieżka zostaje zamieniona na obiekt w Initialize.
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/crap
	/// Czy klapka ogniwa jest otwarta.
	var/cell_cover_open = FALSE
	/// Czy skaner działa poprawnie. Jeśli nie, wynik jest odwrócony.
	var/scans_correctly = TRUE

/obj/item/inspector/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

/obj/item/inspector/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null

/obj/item/inspector/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/inspector/get_cell()
	return cell

/obj/item/inspector/crowbar_act(mob/living/user, obj/item/tool)
	cell_cover_open = !cell_cover_open
	balloon_alert(user, cell_cover_open ? "klapka otwarta" : "klapka zamknięta")
	return TRUE

/obj/item/inspector/attackby(obj/item/I, mob/living/user, params)
	if(cell_cover_open && istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>W [src] jest już ogniwo.</span>")
			return TRUE
		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, "<span class='notice'>Wkładasz [cell] do [src].</span>")
		return TRUE
	return ..()

/obj/item/inspector/CtrlClick(mob/user)
	if(!cell_cover_open || !cell || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	user.visible_message("<span class='notice'>[user] wyjmuje [cell] z [src].</span>", \
		"<span class='notice'>Wyjmujesz [cell].</span>")
	cell.add_fingerprint(user)
	user.put_in_hands(cell)
	cell = null

/obj/item/inspector/examine(mob/user)
	. = ..()
	. += "<span class='info'>Użyj na przedmiocie albo skrzyni, by sprawdzić, czy jest lub zawiera kontrabandę.</span>"
	if(!cell_cover_open)
		. += "<span class='notice'>Klapka ogniwa jest zamknięta. Można ją <b>podważyć</b> łomem.</span>"
		return
	. += "<span class='notice'>Klapka ogniwa jest otwarta. Można ją zamknąć <b>łomem</b>.</span>"
	if(!cell)
		. += "<span class='notice'>Gniazdo ogniwa jest puste.</span>"
	else
		. += "<span class='notice'>[capitalize(cell.name)] siedzi w gnieździe. Ctrl+klik pustą ręką, by je wyjąć.</span>"

// pre_attack, a nie afterattack: inaczej plecak i skrzynia wciągnęłyby skaner do środka zamiast go zeskanować.
/obj/item/inspector/pre_attack(atom/A, mob/living/user, params)
	if(!isitem(A) && !istype(A, /obj/structure/closet))
		return ..()
	if(!user.Adjacent(A))
		return ..()
	if(cell_cover_open)
		balloon_alert(user, "najpierw zamknij klapkę!")
		return FALSE
	if(!cell || !cell.use(INSPECTOR_SCAN_COST))
		balloon_alert(user, "sprawdź ogniwo!")
		return FALSE
	if(contraband_scan(A))
		playsound(src, 'sound/machines/uplinkerror.ogg', 40)
		balloon_alert(user, "wykryto kontrabandę!")
	else
		playsound(src, 'sound/machines/ping.ogg', 20)
		balloon_alert(user, "czysto")
	return FALSE

/// Zwraca TRUE, jeśli skaner pokaże „wykryto kontrabandę”. Wadliwy skaner odwraca wynik.
/obj/item/inspector/proc/contraband_scan(atom/scanned)
	return scanned.contains_contraband() == scans_correctly

/// Żartobliwa wersja z odwróconym wynikiem.
/obj/item/inspector/faulty
	scans_correctly = FALSE

/datum/design/inspector
	name = "Skaner N-spect"
	desc = "Skaner kontrabandy Centrali. Zasilany ogniwem."
	id = "inspector"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 460, /datum/material/uranium = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/inspector
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/techweb_node/sec_basic/New()
	. = ..()
	design_ids += "inspector"

#undef INSPECTOR_SCAN_COST
