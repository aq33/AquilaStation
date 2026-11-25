/// AQUILA - myśliwce przeszukują wraki. Myśliwiec z ładownią podlatuje do wraku na overmapie i w oknie sterowania
/// („Przeszukaj wrak”) przez WRECK_SCAVENGE_TIME zbiera z niego fanty do ładowni. Co wypadnie, zależy od ocalałych modułów
/// wraku (ładownia: materiały, magazyn: amunicja działek, zbrojownia: broń, ambulatorium: apteczki, reaktor i silniki:
/// części), a zawsze trochę złomu. Każdy wrak ma kilka przeszukań, osobno od promów, które wyciąga magnes.

#define WRECK_SCAVENGE_TIME (15 SECONDS)
#define WRECK_SCAVENGE_RANGE 4
#define WRECK_SCAVENGE_ITEMS 2

/obj/structure/overmap/asteroid/shipbreak_wreck
	/// Ile razy myśliwce mogą jeszcze przeszukać wrak
	var/scavenge_left = 1

/obj/structure/overmap/asteroid/shipbreak_wreck/Initialize(mapload)
	. = ..()
	scavenge_left = rand(1, 2) // losowy wrak w układzie; zestrzelony okręt nadpisze to w copy_ship()

/obj/structure/overmap/asteroid/shipbreak_wreck/copy_ship(obj/structure/overmap/source)
	. = ..()
	scavenge_left = clamp(1 + round(source.mass), 2, 6)

/// Pula fantów: list(list(typ, ilość)), z ocalałych modułów wraku i złomu
/obj/structure/overmap/asteroid/shipbreak_wreck/proc/scavenge_pool()
	var/list/pool = list(
		list(/obj/item/stack/sheet/iron, 10),
		list(/obj/item/stack/rods, 10),
		list(/obj/item/stack/sheet/glass, 5),
	)
	var/list/loot_by_kind = list(
		"cargo" = list(list(/obj/item/stack/sheet/plasteel, 10), list(/obj/item/stack/sheet/mineral/titanium, 10), list(/obj/item/stack/sheet/mineral/plasma, 10), list(/obj/item/stack/sheet/mineral/gold, 5)),
		"ammo" = list(list(/obj/item/ammo_box/magazine/nsv/light_cannon, 1), list(/obj/item/ammo_box/magazine/nsv/heavy_cannon, 1)),
		"armory" = list(list(/obj/item/gun/ballistic/automatic/pistol, 1), list(/obj/item/ammo_box/magazine/m10mm, 1)),
		"medbay" = list(list(/obj/item/storage/firstaid/regular, 1), list(/obj/item/reagent_containers/hypospray/medipen, 1)),
		"reactor" = list(list(/obj/item/stack/sheet/mineral/uranium, 5), list(/obj/item/stock_parts/cell/high, 1)),
		"power" = list(list(/obj/item/stock_parts/cell/high, 1), list(/obj/item/stock_parts/capacitor/adv, 1)),
		"engine" = list(list(/obj/item/stock_parts/capacitor/adv, 1), list(/obj/item/stack/sheet/plasteel, 5)),
		"sensors" = list(list(/obj/item/stock_parts/scanning_module/adv, 1)),
		"bridge" = list(list(/obj/item/stock_parts/scanning_module/adv, 1)),
	)
	for(var/datum/ship_module/module as anything in ship_modules?.modules)
		if(module.fraction() < 0.25)
			continue // rozbity moduł nic nie zostawił
		var/list/loot = loot_by_kind[module.kind]
		if(loot)
			pool += loot
	return pool

/// Zabiera fanty do pojemnika (ładowni myśliwca); zwraca listę wyjętych przedmiotów
/obj/structure/overmap/asteroid/shipbreak_wreck/proc/scavenge_into(atom/container, count)
	. = list()
	if(scavenge_left <= 0)
		return
	scavenge_left--
	var/list/pool = scavenge_pool()
	for(var/i in 1 to count)
		var/list/entry = pick(pool)
		var/item_type = entry[1]
		if(ispath(item_type, /obj/item/stack))
			// Drugi taki sam stos łączy się z pierwszym w ładowni i znika, więc na liście zostaje tylko pierwszy
			var/obj/item/stack/stack = new item_type(container, entry[2])
			if(!QDELETED(stack))
				. += stack
		else
			. += new item_type(container)

/// Ładownia myśliwca
/obj/structure/overmap/small_craft/proc/scavenge_hold()
	return locate(/obj/item/fighter_component/secondary/utility/hold) in contents

/// Najbliższy wrak do przeszukania w zasięgu
/obj/structure/overmap/small_craft/proc/scavenge_target()
	if(!z)
		return null
	var/obj/structure/overmap/asteroid/shipbreak_wreck/best
	for(var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck in current_system?.system_contents)
		if(QDELETED(wreck) || wreck.z != z || wreck.scavenge_left <= 0)
			continue
		var/dist = overmap_dist(src, wreck)
		if(dist <= WRECK_SCAVENGE_RANGE && (!best || dist < overmap_dist(src, best)))
			best = wreck
	return best

/obj/structure/overmap/small_craft
	/// Czas rozpoczęcia przeszukiwania wraku (0: nie przeszukuje)
	var/scavenge_started = 0

/obj/structure/overmap/small_craft/ui_data(mob/user)
	. = ..()
	var/list/data = .
	data["scavenge_hold"] = !!scavenge_hold()
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = scavenge_target()
	data["scavenge_target"] = wreck ? "[wreck.name] (zostało: [wreck.scavenge_left])" : null
	data["scavenge_progress"] = scavenge_started ? min(1, (world.time - scavenge_started) / WRECK_SCAVENGE_TIME) : null

/obj/structure/overmap/small_craft/ui_act(action, params, datum/tgui/ui)
	if(action == "scavenge_wreck" && (usr == pilot || IsAdminGhost(usr)))
		start_scavenge(usr)
		return TRUE
	return ..()

/obj/structure/overmap/small_craft/proc/start_scavenge(mob/user)
	if(scavenge_started)
		to_chat(user, span_warning("Już przeszukujesz wrak."))
		return FALSE
	var/obj/item/fighter_component/secondary/utility/hold/hold = scavenge_hold()
	if(!hold)
		to_chat(user, span_warning("Bez ładowni nie ma gdzie schować fantów z wraku."))
		return FALSE
	if(length(hold.contents) >= hold.max_freight)
		to_chat(user, span_warning("Ładownia jest pełna."))
		return FALSE
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = scavenge_target()
	if(!wreck)
		to_chat(user, span_warning("W pobliżu nie ma wraku do przeszukania. Podleć bliżej (najwyżej [WRECK_SCAVENGE_RANGE] pola)."))
		return FALSE
	scavenge_started = world.time
	to_chat(user, span_notice("Przeszukujesz [wreck]. Trzymaj się blisko przez [DisplayTimeText(WRECK_SCAVENGE_TIME)]."))
	addtimer(CALLBACK(src, PROC_REF(finish_scavenge), user, WEAKREF(wreck)), WRECK_SCAVENGE_TIME)
	return TRUE

/obj/structure/overmap/small_craft/proc/finish_scavenge(mob/user, datum/weakref/wreck_ref)
	scavenge_started = 0
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = wreck_ref?.resolve()
	var/obj/item/fighter_component/secondary/utility/hold/hold = scavenge_hold()
	if(!wreck || QDELETED(wreck) || !hold || wreck.z != z || overmap_dist(src, wreck) > WRECK_SCAVENGE_RANGE)
		if(user)
			to_chat(user, span_warning("Za daleko od wraku, przeszukiwanie przerwane."))
		return FALSE
	var/space = hold.max_freight - length(hold.contents)
	var/list/found = wreck.scavenge_into(hold, min(WRECK_SCAVENGE_ITEMS, space))
	if(!length(found))
		if(user)
			to_chat(user, span_warning("Z [wreck] nie da się już nic wyciągnąć."))
		return FALSE
	var/list/names = list()
	for(var/obj/item/I as anything in found)
		names += I.name
	relay('nsv13/sound/effects/ship/mac_load.ogg')
	if(user)
		to_chat(user, span_notice("Do ładowni trafia: [english_list(names)]."))
	return TRUE

#undef WRECK_SCAVENGE_TIME
#undef WRECK_SCAVENGE_RANGE
#undef WRECK_SCAVENGE_ITEMS
