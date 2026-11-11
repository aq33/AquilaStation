// Sprzęt złomiarzy: reklamator (czasowa rozbiórka maszyn, struktur i ścian), nadajnik i teleporter, który leci tylko do nadajnika.

/obj/item/salvage_reclaimer
	name = "reklamator"
	desc = "Ciężki łom z silnikiem, odkręcarką i palnikiem. Rozbiera maszyny na płytki i części, a ściany na blachy. Działa wolno i głośno."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar_large"
	item_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	color = "#d9a441"
	force = 12
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 0.7
	usesound = 'sound/items/crowbar.ogg'
	attack_verb = list("uderza", "wali", "grzmoci")
	custom_materials = list(/datum/material/iron = 8000)

/obj/item/salvage_reclaimer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kliknij maszynę, strukturę albo ścianę poza trybem walki, żeby ją rozebrać. Maszyny: ok. 10 s, komputery 6 s, struktury 3 s, ściany 8 s (wzmocnione 16 s).</span>"

/obj/item/salvage_reclaimer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(user))
		return
	var/mob/living/L = user
	if(L.combat_mode)
		return
	var/duration = salvage_time(target)
	if(!duration)
		return
	. = TRUE
	user.visible_message("<span class='warning'>[user] zaczyna rozbierać [target] reklamatorem!</span>", "<span class='notice'>Zaczynasz rozbierać [target].</span>")
	playsound(target, 'sound/items/ratchet.ogg', 50, TRUE)
	if(!do_after(user, duration, target))
		return
	if(QDELETED(target) || !salvage_time(target))
		return
	playsound(target, 'sound/items/deconstruct.ogg', 50, TRUE)
	log_game("[key_name(user)] salvaged [target] ([target.type]) at [AREACOORD(target)]")
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		W.dismantle_wall()
		return
	var/obj/O = target
	O.deconstruct(TRUE)

/// Czas rozbiórki celu albo 0, jeśli reklamator go nie ruszy
/obj/item/salvage_reclaimer/proc/salvage_time(atom/target)
	if(iswallturf(target))
		if(istype(target, /turf/closed/wall/r_wall))
			return 16 SECONDS
		return 8 SECONDS
	if(!isobj(target))
		return 0
	var/obj/O = target
	if((O.resistance_flags & INDESTRUCTIBLE) || (O.flags_1 & NODECONSTRUCT_1) || !O.anchored)
		return 0
	// Rury i maszyny atmosferyczne (także reaktor) zostają: rozbiórka zabiłaby załogę, a nie dała złomu
	if(istype(O, /obj/machinery/atmospherics) || istype(O, /obj/machinery/nuclearbomb) || istype(O, /obj/machinery/dominator))
		return 0
	if(istype(O, /obj/machinery/computer))
		return 6 SECONDS
	if(istype(O, /obj/machinery))
		return 10 SECONDS
	if(istype(O, /obj/structure))
		return 3 SECONDS
	return 0

///////////////////
// Nadajnik
///////////////////

/// Rozstawione nadajniki złomiarzy
GLOBAL_LIST_EMPTY(salvage_beacons)

/obj/item/salvage_beacon
	name = "nadajnik złomiarzy"
	desc = "Składany nadajnik. Rozstawiony na pokładzie okrętu daje teleporterowi złomiarzy punkt docelowy."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/salvage_beacon/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T || !is_station_level(T.z) || isspaceturf(T))
		to_chat(user, "<span class='warning'>Nadajnik trzeba rozstawić na pokładzie okrętu.</span>")
		return
	if(!do_after(user, 3 SECONDS, T))
		return
	new /obj/structure/salvage_beacon(T)
	to_chat(user, "<span class='notice'>Rozstawiasz nadajnik. Teleporter na statku może teraz przerzucać tu ludzi i złom.</span>")
	qdel(src)

/obj/structure/salvage_beacon
	name = "nadajnik złomiarzy"
	desc = "Pikający nadajnik na trójnogu. Ktoś go tu postawił, żeby się do okrętu teleportować."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	anchored = TRUE
	density = FALSE
	max_integrity = 60
	/// Do kiedy nadajnik się ładuje po teleportacji powrotnej
	var/next_use = 0

/obj/structure/salvage_beacon/Initialize(mapload)
	. = ..()
	GLOB.salvage_beacons += src
	GLOB.poi_list |= src

/obj/structure/salvage_beacon/Destroy()
	GLOB.salvage_beacons -= src
	GLOB.poi_list -= src
	return ..()

/obj/structure/salvage_beacon/examine(mob/user)
	. = ..()
	if(user.mind?.has_antag_datum(/datum/antagonist/pirate/salvager))
		. += "<span class='notice'>Użyj nadajnika, żeby wrócić teleportem na statek razem z tym, co ciągniesz.</span>"

/obj/structure/salvage_beacon/attack_hand(mob/living/user)
	if(!user.mind?.has_antag_datum(/datum/antagonist/pirate/salvager))
		return ..()
	if(world.time < next_use)
		to_chat(user, "<span class='warning'>Nadajnik jeszcze się ładuje.</span>")
		return
	var/obj/machinery/salvage_teleporter/pad = locate() in GLOB.machines
	if(!pad)
		to_chat(user, "<span class='warning'>Nadajnik nie łapie teleportera statku.</span>")
		return
	to_chat(user, "<span class='notice'>Nadajnik łączy się z teleporterem statku...</span>")
	if(!do_after(user, 3 SECONDS, src))
		return
	next_use = world.time + 10 SECONDS
	salvage_teleport(user, get_turf(pad))

/// Przerzuca `user` i to, co ciągnie, na `destination`
/proc/salvage_teleport(mob/living/user, turf/destination)
	var/atom/movable/pulled = user.pulling
	do_teleport(user, destination, channel = TELEPORT_CHANNEL_BLUESPACE)
	if(pulled && !pulled.anchored)
		do_teleport(pulled, destination, channel = TELEPORT_CHANNEL_BLUESPACE)
		user.start_pulling(pulled)

///////////////////
// Teleporter na statku
///////////////////

/obj/machinery/salvage_teleporter
	name = "teleporter złomiarzy"
	desc = "Zdezelowana platforma teleportacyjna. Leci tylko do nadajników złomiarzy."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	anchored = TRUE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/salvage_teleporter/interact(mob/living/user)
	if(!istype(user) || !user.mind?.has_antag_datum(/datum/antagonist/pirate/salvager))
		to_chat(user, "<span class='warning'>Panel jest zablokowany.</span>")
		return
	var/list/beacons = list()
	for(var/obj/structure/salvage_beacon/B as anything in GLOB.salvage_beacons)
		beacons["[get_area_name(B)] ([B.x], [B.y])"] = B
	if(!length(beacons))
		to_chat(user, "<span class='warning'>Nie ma rozstawionego nadajnika. Rozstaw go na pokładzie okrętu albo dolećcie promem.</span>")
		return
	var/choice = length(beacons) == 1 ? beacons[1] : tgui_input_list(user, "Do którego nadajnika?", "Teleporter złomiarzy", beacons)
	var/obj/structure/salvage_beacon/target = beacons[choice]
	if(!target || get_dist(user, src) > 1)
		return
	to_chat(user, "<span class='notice'>Stań na platformie. Teleport za 3 sekundy...</span>")
	flick("lpad-beam", src)
	if(!do_after(user, 3 SECONDS, src) || QDELETED(target))
		return
	salvage_teleport(user, get_turf(target))
