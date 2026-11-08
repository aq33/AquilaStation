// AQUILA - Su-437 Sabre jako shuttle (jak promy na Aurorze), na mechanice z shuttle_craft.dm. W hangarze stoi jego
// wnętrze (szablon shuttle'a na porcie /obj/docking_port/stationary/sabre), a jednostka overmapy czeka niewidoczna
// przy włazie w lewej gondoli: pusta ręka = wejście, przedmioty i wąż paliwowy = obsługa jednostki (tankowanie,
// części, naprawa, karta), przeciągnięcie skrzyni = ładownia. Start ze steru w kokpicie.
// Wnętrza: aquila/_maps/shuttles/sabre/ (kadłub i wyposażenie ze starego wnętrza w rezerwacji).

/area/shuttle/sabre
	name = "Su-437 Sabre"
	icon_state = "shuttle"
	lighting_colour_tube = "#e6af68"
	lighting_colour_bulb = "#e6af68"
	teleport_restriction = TELEPORT_ALLOW_NONE
	/// Sabre, do którego należy to wnętrze
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre

/// W locie wnętrze ma własny wirtualny Z jak wnętrza promów desantowych, w doku należy do poziomu gospodarza
/area/shuttle/sabre/get_virtual_z(turf/T)
	if(sabre && !sabre.shuttle_docked_at && sabre.linked_virtual_z)
		return sabre.linked_virtual_z
	return ..()

/area/shuttle/sabre/Destroy()
	sabre = null
	return ..()

/datum/map_template/shuttle/sabre
	name = "Su-437 Sabre"
	description = "Jednostka pomocnicza Su-437 Sabre, w hangarze stoi jako wnętrze."
	port_id = "sabre"
	suffix = "nanotrasen"
	can_be_bought = FALSE
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	/// Plik szablonu jako zasób wkompilowany w .rsc: deploy.sh nie kopiuje katalogu aquila/_maps na serwer
	var/sabre_map = 'aquila/_maps/shuttles/sabre/sabre_nanotrasen.dmm'

/datum/map_template/shuttle/sabre/New(path = null, rename = null, cache = FALSE, admin_load = null)
	return ..(path || sabre_map, rename, cache, admin_load)

/datum/map_template/shuttle/sabre/mining
	name = "Su-437 Sabre (górniczy)"
	suffix = "mining"
	sabre_map = 'aquila/_maps/shuttles/sabre/sabre_mining.dmm'

/obj/docking_port/mobile/sabre
	name = "Su-437 Sabre"
	id = "sabre"
	dynamic_id = TRUE
	area_type = /area/shuttle/sabre
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	/// Jaką jednostkę overmapy tworzy to wnętrze
	var/craft_type = /obj/structure/overmap/small_craft/transport/sabre/shuttle
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/craft

/obj/docking_port/mobile/sabre/mining
	craft_type = /obj/structure/overmap/small_craft/transport/sabre/shuttle/mining

/obj/docking_port/mobile/sabre/register()
	. = ..()
	if(!craft && docked)
		var/obj/structure/overmap/small_craft/transport/sabre/shuttle/new_craft = new craft_type(get_turf(src))
		new_craft.shuttle_link(src)

/obj/docking_port/mobile/sabre/Destroy(force)
	if(force && craft)
		craft.shuttle_port = null
		craft = null
	return ..()

/// Port w hangarze: na starcie rundy stawia na sobie wnętrze Sabre
/obj/docking_port/stationary/sabre
	name = "dok Sabre"
	dir = NORTH
	width = 9
	height = 9
	dwidth = 0
	dheight = 0
	roundstart_template = /datum/map_template/shuttle/sabre

/obj/docking_port/stationary/sabre/mining
	name = "dok Sabre (górniczy)"
	roundstart_template = /datum/map_template/shuttle/sabre/mining

/obj/structure/overmap/small_craft/transport/sabre/shuttle
	interior_mode = NO_INTERIOR
	possible_interior_maps = list()

/obj/structure/overmap/small_craft/transport/sabre/shuttle/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_CARGO, ACCESS_MINING, ACCESS_TRANSPORT_PILOT)

/obj/structure/overmap/small_craft/transport/sabre/shuttle/Destroy()
	for(var/area/shuttle/sabre/A in linked_areas)
		if(A.sabre == src)
			A.sabre = null
	var/obj/docking_port/mobile/sabre/port = shuttle_port
	if(istype(port) && port.craft == src)
		port.craft = null
	return ..()

/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_link(obj/docking_port/mobile/sabre/port)
	port.craft = src
	for(var/area/shuttle/sabre/A in port.shuttle_areas)
		A.sabre = src
		A.name = name
	return ..()

/// Ukryta jednostka czeka przy włazie, żeby wąż paliwowy i naprawa sięgały jej z hangaru
/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_anchor_turf()
	if(!shuttle_port)
		return
	for(var/turf/closed/indestructible/dropship/sabre_hatch/H in shuttle_port.return_turfs())
		return H

/// Wysiada się przez właz w lewej gondoli
/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_exit_turfs()
	. = list()
	if(!shuttle_port)
		return
	for(var/turf/closed/indestructible/dropship/sabre_hatch/H in shuttle_port.return_turfs())
		for(var/dir in GLOB.cardinals)
			var/turf/outside = get_step(H, dir)
			if(outside && !istype(outside.loc, /area/shuttle/sabre))
				. += outside
				break

/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_preferred_ports(obj/structure/overmap/OM)
	. = list()
	for(var/obj/docking_port/stationary/sabre/port in SSshuttle.stationary)
		. += port

/// Wejście przez właz: tak jak wejście do promu desantowego, tylko z hangaru
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_board(mob/living/user)
	if(!shuttle_docked_at)
		return FALSE
	if(!allowed(user))
		to_chat(user, span_warning("Odmowa dostępu."))
		return FALSE
	to_chat(user, span_notice("Otwierasz właz [src] i wchodzisz do środka..."))
	if(!do_after(user, 2 SECONDS, target = user))
		return FALSE
	enter(user)
	return TRUE

/obj/structure/overmap/small_craft/transport/sabre/shuttle/examine(mob/user)
	. = ..()
	. += span_notice("Paliwo: [round(get_fuel())]/[round(get_max_fuel())]. Stan kadłuba: [round(obj_integrity / max_integrity * 100)]%.")

// Obrót kadłuba: kafelki dropshipa składają obraz statku z kawałków w jednym kierunku. Shuttle przy dokowaniu
// do portu skierowanego inaczej niż szablon obraca dir każdego turfa (i kopiuje go przy przelocie), więc z dir
// liczy się obrót obrazka. Na mapach te kafelki nie mają dir, czyli SOUTH = bez obrotu.

/proc/dropship_turf_transform(turn_dir)
	var/angle = dir2angle(turn_dir) - dir2angle(SOUTH)
	return angle ? matrix(angle, MATRIX_ROTATE) : matrix()

/turf/closed/indestructible/dropship/setDir(newdir)
	. = ..()
	transform = dropship_turf_transform(dir)

/turf/open/indestructible/dropship/setDir(newdir)
	. = ..()
	transform = dropship_turf_transform(dir)

// Wrota w burcie kokpitu: wyjście na zewnątrz w doku, zablokowane w locie

/turf/closed/indestructible/dropship/entry/sabre
	desc = "Masywne wrota. W doku wychodzi się nimi na zewnątrz, w locie są zablokowane."

/turf/closed/indestructible/dropship/entry/sabre/Bumped(atom/movable/AM)
	var/area/shuttle/sabre/A = loc
	if(!istype(A) || !A.sabre || !ismob(AM))
		return
	if(A.sabre.shuttle_docked_at)
		A.sabre.shuttle_leave(AM)
	else
		to_chat(AM, span_warning("Wrota są zablokowane w trakcie lotu."))

// Właz w lewej gondoli: wejście i obsługa jednostki od strony hangaru

/turf/closed/indestructible/dropship/sabre_hatch
	name = "właz Sabre"
	desc = "Właz w gondoli Sabre. Pustą ręką się wchodzi, a tu też tankuje się jednostkę, montuje części i naprawia kadłub."

/turf/closed/indestructible/dropship/sabre_hatch/proc/get_sabre()
	var/area/shuttle/sabre/A = loc
	return istype(A) ? A.sabre : null

/turf/closed/indestructible/dropship/sabre_hatch/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(S)
		. += S.examine(user)

/turf/closed/indestructible/dropship/sabre_hatch/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(S && isliving(user))
		return S.sabre_board(user)

/turf/closed/indestructible/dropship/sabre_hatch/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

/turf/closed/indestructible/dropship/sabre_hatch/attackby(obj/item/W, mob/user, params)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(S?.shuttle_docked_at)
		return S.attackby(W, user, params)
	return ..()

/turf/closed/indestructible/dropship/sabre_hatch/MouseDrop_T(atom/movable/target, mob/user)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(!S?.shuttle_docked_at || !isliving(user) || !user.Adjacent(src))
		return ..()
	if(isliving(target))
		if(target == user)
			return S.sabre_board(user)
		return ..()
	return S.MouseDrop_T(target, user)

// Wąż paliwowy na włazie tankuje Sabre, który czeka przy nim ukryty
/obj/item/cryofuel_nozzle/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /turf/closed/indestructible/dropship/sabre_hatch))
		var/turf/closed/indestructible/dropship/sabre_hatch/hatch = target
		var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = hatch.get_sabre()
		if(S?.shuttle_docked_at)
			return ..(S, user, proximity)
	return ..()

// Ster: w doku pyta o start, potem steruje jak ster promu desantowego

/obj/machinery/computer/ship/helm/console/dropship/sabre
	name = "stanowisko pilota Sabre"

/// Ster zawsze steruje swoim Sabre, także w doku, gdzie pola wnętrza należą do okrętu gospodarza
/obj/machinery/computer/ship/helm/console/dropship/sabre/get_overmap(failsafe = FALSE)
	var/area/shuttle/sabre/A = get_area(src)
	return istype(A) ? A.sabre : null

/obj/machinery/computer/ship/helm/console/dropship/sabre/attack_hand(mob/living/user)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = has_overmap()
	if(S?.shuttle_docked_at && isliving(user))
		if(tgui_alert(user, "[S] stoi w doku. Startujemy?", name, list("Start", "Anuluj")) != "Start")
			return TRUE
		if(QDELETED(S) || !S.shuttle_docked_at || !user.Adjacent(src) || !S.shuttle_launch(user))
			return TRUE
	return ..()
