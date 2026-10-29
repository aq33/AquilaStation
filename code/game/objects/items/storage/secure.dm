/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "bezpieczny schowek"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/open = FALSE
	var/can_hack_open = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	desc = "To nie powinno istnieć. Jeśli istnieje, zgłoś błąd."

/obj/item/storage/secure/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 14

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(can_hack_open)
		. += "Panel serwisowy jest obecnie <b>[open ? "odkręcony" : "przykręcony"]</b>."

/obj/item/storage/secure/attackby(obj/item/W, mob/user, params)
	if(can_hack_open && SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
		if (W.tool_behaviour == TOOL_SCREWDRIVER)
			if (W.use_tool(src, user, 20))
				open = !open
				to_chat(user, "<span class='notice'>[open ? "Otwierasz" : "Zamykasz"] panel serwisowy.</span>")
			return
		if (W.tool_behaviour == TOOL_WIRECUTTER)
			to_chat(user, "<span class='danger'>[src] jest chroniony przed takim majstrowaniem, ale przewody pamięci wewnętrznej wciąż można <b>pobudzić impulsem</b>.</span>")
			return
		if ((W.tool_behaviour == TOOL_MULTITOOL))
			if(l_hacking)
				to_chat(user, "<span class='danger'>Ten sejf jest już hakowany.</span>")
				return
			if(open)
				to_chat(user, "<span class='danger'>Próba resetu pamięci wewnętrznej, proszę czekać.</span>")
				l_hacking = TRUE
				if (W.use_tool(src, user, 400))
					to_chat(user, "<span class='danger'>Zresetowano pamięć wewnętrzną - zamek został zwolniony.</span>")
					l_set = FALSE

				l_hacking = FALSE
				return
			to_chat(user, "<span class='notice'>Zanim pobudzisz przewody impulsem, musisz <b>odkręcić</b> panel serwisowy.</span>")
			return

	// -> storage/attackby() what with handle insertion, etc
	return ..()

/obj/item/storage/secure/attack_self(mob/user)
	ui_interact(user)

// AQUILA: zamek szyfrowy w TGUI (okno LockedSafe z tg) zamiast starego HTML
/obj/item/storage/secure/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LockedSafe", name)
		ui.open()

/obj/item/storage/secure/ui_data(mob/user)
	var/list/data = list()
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	data["locked"] = !!locked
	data["lock_code"] = !!l_set
	data["memory_error"] = !!l_setshort
	if(code == "ERROR")
		data["input_code"] = "BŁĄD"
	else if(!locked && l_set)
		data["input_code"] = "*****"
	else
		data["input_code"] = code || ""
	return data

/obj/item/storage/secure/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "keypad")
		return
	if(usr.stat || usr.restrained() || get_dist(src, usr) > 1)
		return
	var/digit = params["digit"]
	playsound(src, "terminal_type", 50, FALSE)
	switch(digit)
		if("E")
			if(!l_set && length(code) == 5 && !l_setshort && code != "ERROR")
				l_code = code
				l_set = TRUE
				code = null
			else if(l_set && code == l_code)
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)
				cut_overlays()
				add_overlay(icon_opened)
				code = null
			else
				code = "ERROR"
		if("C")
			if(l_setshort)
				return
			if(!l_set) // bez kodu tylko kasujemy wpis
				code = null
				return TRUE
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)
			cut_overlays()
			code = null
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_HIDE_FROM, usr)
		if("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
			if(code == "ERROR")
				code = null
			code += digit
			if(length(code) > 5)
				code = "ERROR"
		else
			return
	add_fingerprint(usr)
	return TRUE


// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "zabezpieczona aktówka"
	icon = 'icons/obj/storage.dmi'
	icon_state = "sec-case"
	item_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/case_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/case_righthand.dmi'
	desc = "Duża aktówka z cyfrowym zamkiem."
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("grzmoci", "okłada", "tłucze", "młóci", "wali")

/obj/item/storage/secure/briefcase/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/briefcase/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 21
	STR.max_w_class = WEIGHT_CLASS_NORMAL

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/PopulateContents()
	..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	for(var/i = 0, i < STR.max_items - 2, i++)
		new /obj/item/stack/spacecash/c1000(src)


// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "zabezpieczony sejf"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	desc = "Świetnie chroni rzeczy przed lepkimi łapami."
	force = 8
	layer = ABOVE_WINDOW_LAYER
	w_class = WEIGHT_CLASS_GIGANTIC
	anchored = TRUE
	density = FALSE

/obj/item/storage/secure/safe/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.cant_hold = typecacheof(list(/obj/item/storage/secure/briefcase))
	STR.max_w_class = 8						//??

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	return attack_self(user)

/obj/item/storage/secure/safe/HoS
	name = "sejf Komendanta"

/**
 * This safe is meant to be damn robust. To break in, you're supposed to get creative, or use acid or an explosion.
 *
 * This makes the safe still possible to break in for someone who is prepared and capable enough, either through
 * chemistry, botany or whatever else.
 *
 * The safe is also weak to explosions, so spending some early TC could allow an antag to blow it upen if they can
 * get access to it.
 */
/obj/item/storage/secure/safe/caps_spare
	name = "sejf z zapasowym identyfikatorem kapitana"
	desc = "W razie zagrożenia nie zbijać szyby. Wszyscy Kapitanowie i p.o. Kapitana dostają kody do tego sejfu. \
Jest zrobiony z tego samego materiału co czarna skrzynka stacji i wytrzymuje każdą konwencjonalną broń. \
Widać na nim niewielką korozję powierzchniową. Nie wygląda, jakby wytrzymał porządny wybuch."
	can_hack_open = FALSE
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 70, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 70);
	max_integrity = 300
	color = "#ffdd33"

/obj/item/storage/secure/safe/caps_spare/Initialize(mapload)
	. = ..()
	l_code = SSjob.spare_id_safe_code
	l_set = TRUE
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/storage/secure/safe/caps_spare/PopulateContents()
	new /obj/item/card/id/captains_spare(src)

/obj/item/storage/secure/safe/caps_spare/rust_heretic_act(rust_strength) // AQUILA - siła rdzy z tg
	take_damage(damage_amount = 100, damage_type = BRUTE, damage_flag = "melee", armour_penetration = 100)
	return TRUE
