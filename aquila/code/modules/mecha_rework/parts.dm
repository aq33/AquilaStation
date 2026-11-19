// AQUILA - wymiana części magazynowych w złożonym mechu (kondensator, moduł skanujący, ogniwo, płyta pancerza).
// Rdzeń pozwala włożyć część tylko do pustego gniazda (wyjęcie przez okno serwisowe). Tu przy otwartej klapie
// nowa część od razu zastępuje starą, a stara trafia do ręki. Płyta pancerza to nowa część: dokłada ochronę
// według klasy, wkłada się ją przy otwartej klapie, wyjmuje kluczem.

/obj/item/mecha_parts/aq_armor_plating
	name = "płyta pancerza egzoszkieletu"
	desc = "Dodatkowa płyta przykręcana do kadłuba złożonego mecha. Wkłada się ją przy otwartej klapie serwisowej, zdejmuje kluczem."
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "gygax_armor"
	w_class = WEIGHT_CLASS_BULKY
	/// Klasa płyty (1-3)
	var/rating = 1
	/// Ile ochrony dokłada
	var/list/bonus = list("melee" = 5, "bullet" = 5, "laser" = 0)
	/// Ile wolniej idzie mech (dodawane do step_in)
	var/plate_slowdown = 0

/obj/item/mecha_parts/aq_armor_plating/try_attach_part(mob/user, obj/mecha/M)
	return M.aq_install_plating(src, user)

/obj/item/mecha_parts/aq_armor_plating/reinforced
	name = "wzmocniona płyta pancerza egzoszkieletu"
	desc = "Plastalowa płyta dla mechów. Lepiej chroni, ale mech jest odrobinę wolniejszy. Wkłada się ją przy otwartej klapie serwisowej, zdejmuje kluczem."
	icon_state = "durand_armor"
	rating = 2
	bonus = list("melee" = 10, "bullet" = 10, "laser" = 5)
	plate_slowdown = 0.5

/obj/item/mecha_parts/aq_armor_plating/composite
	name = "kompozytowa płyta pancerza egzoszkieletu"
	desc = "Wielowarstwowa płyta z wkładem ablacyjnym. Chroni przed kulami i laserami, ale jest ciężka. Wkłada się ją przy otwartej klapie serwisowej, zdejmuje kluczem."
	icon_state = "phazon_armor"
	rating = 3
	bonus = list("melee" = 15, "bullet" = 15, "laser" = 15)
	plate_slowdown = 1

/obj/mecha
	/// Zamontowana płyta pancerza (wymienna część)
	var/obj/item/mecha_parts/aq_armor_plating/aq_plating

/obj/mecha/proc/aq_install_plating(obj/item/mecha_parts/aq_armor_plating/plate, mob/user)
	if(construction_state != MECHA_OPEN_HATCH)
		to_chat(user, "<span class='warning'>Najpierw otwórz klapę serwisową [src].</span>")
		return FALSE
	var/obj/item/mecha_parts/aq_armor_plating/old = aq_plating
	if(user && !user.transferItemToLoc(plate, src))
		return FALSE
	if(!user)
		plate.forceMove(src)
	if(old)
		aq_remove_plating(user)
	aq_plating = plate
	armor = armor.modifyRating(melee = plate.bonus["melee"], bullet = plate.bonus["bullet"], laser = plate.bonus["laser"])
	step_in += plate.plate_slowdown
	if(user)
		to_chat(user, "<span class='notice'>Przykręcasz [plate] do [src].</span>")
		playsound(src, 'sound/items/ratchet.ogg', 50, TRUE)
	log_message("[plate] installed.", LOG_MECHA)
	return TRUE

/obj/mecha/proc/aq_remove_plating(mob/user)
	if(!aq_plating)
		return
	var/obj/item/mecha_parts/aq_armor_plating/plate = aq_plating
	aq_plating = null
	armor = armor.modifyRating(melee = -plate.bonus["melee"], bullet = -plate.bonus["bullet"], laser = -plate.bonus["laser"])
	step_in -= plate.plate_slowdown
	plate.forceMove(drop_location())
	if(user)
		user.put_in_hands(plate)
		to_chat(user, "<span class='notice'>Odkręcasz [plate] od [src].</span>")
	log_message("[plate] removed.", LOG_MECHA)

/obj/mecha/Exited(atom/movable/M, atom/newloc)
	if(M == aq_plating)
		aq_plating = null
		var/obj/item/mecha_parts/aq_armor_plating/plate = M
		armor = armor.modifyRating(melee = -plate.bonus["melee"], bullet = -plate.bonus["bullet"], laser = -plate.bonus["laser"])
		step_in -= plate.plate_slowdown
	return ..()

/obj/mecha/Destroy()
	QDEL_NULL(aq_plating)
	return ..()

/obj/mecha/wrench_act(mob/living/user, obj/item/I)
	if(construction_state == MECHA_OPEN_HATCH && aq_plating)
		I.play_tool_sound(src)
		aq_remove_plating(user)
		return TRUE
	return ..()

/// Wymiana części przy otwartej klapie: stara część do ręki, nowa w jej miejsce
/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(construction_state == MECHA_OPEN_HATCH && istype(W, /obj/item/stock_parts))
		var/obj/item/stock_parts/old
		if(istype(W, /obj/item/stock_parts/cell))
			old = cell
		else if(istype(W, /obj/item/stock_parts/scanning_module))
			old = scanmod
		else if(istype(W, /obj/item/stock_parts/capacitor))
			old = capacitor
		if(old)
			old.forceMove(drop_location()) // Exited() w rdzeniu czyści zmienną i przelicza wartości
			user.put_in_hands(old)
			to_chat(user, "<span class='notice'>Wyjmujesz [old].</span>")
	return ..()
