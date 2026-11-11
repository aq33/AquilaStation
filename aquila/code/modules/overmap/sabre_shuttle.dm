// AQUILA - Su-437 Sabre jako shuttle (jak promy na Aurorze), na mechanice z shuttle_craft.dm. W hangarze stoi jego
// wnętrze (szablon shuttle'a na porcie /obj/docking_port/stationary/sabre), a jednostka overmapy czeka niewidoczna
// przy włazie w lewej gondoli: pusta ręka = wejście, przedmioty = obsługa jednostki (części, naprawa, karta),
// przeciągnięcie skrzyni = ładownia. Start ze steru w kokpicie. Paliwo: plazma z kanistra w ładowni (niżej).
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
	/// Kto właśnie wchodzi przez właz albo wrota (przytrzymany klawisz ruchu wchodzi we wrota co krok: jeden pasek naraz)
	var/list/boarding_mobs

/obj/structure/overmap/small_craft/transport/sabre/shuttle/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_CARGO, ACCESS_MINING, ACCESS_TRANSPORT_PILOT)

/obj/structure/overmap/small_craft/transport/sabre/shuttle/Destroy()
	boarding_mobs = null
	for(var/area/shuttle/sabre/A in linked_areas)
		if(A.sabre == src)
			A.sabre = null
	var/obj/docking_port/mobile/sabre/port = shuttle_port
	if(istype(port) && port.craft == src)
		port.craft = null
	return ..()

/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_link(obj/docking_port/mobile/sabre/port)
	port.craft = src
	fuel_heaters = null
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

/// Porty Sabre bez portów domowych innych istniejących Sabre (te czekają na swój prom)
/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_preferred_ports(obj/structure/overmap/OM)
	. = list()
	var/list/other_homes = list()
	for(var/obj/docking_port/mobile/sabre/interior in SSshuttle.mobile)
		if(interior.craft && interior.craft != src && interior.craft.shuttle_home_port)
			other_homes[interior.craft.shuttle_home_port] = TRUE
	for(var/obj/docking_port/stationary/sabre/port in SSshuttle.stationary)
		if(!other_homes[port])
			. += port

/// Wejście przez właz albo wrota kokpitu (via_doors) ze skrzydła: tak jak wejście do promu desantowego, tylko z hangaru
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_board(mob/living/user, via_doors = FALSE)
	if(!shuttle_docked_at)
		if(via_doors)
			to_chat(user, span_warning("Wrota są zablokowane w trakcie lotu."))
		return FALSE
	if(!allowed(user))
		to_chat(user, span_warning("Odmowa dostępu."))
		return FALSE
	if(LAZYACCESS(boarding_mobs, user))
		return FALSE
	if(via_doors)
		to_chat(user, span_notice("Otwierasz wrota [src] i wchodzisz do środka..."))
	else
		to_chat(user, span_notice("Otwierasz właz [src] i wchodzisz do środka..."))
	LAZYSET(boarding_mobs, user, TRUE)
	var/success = do_after(user, 2 SECONDS, target = user)
	LAZYREMOVE(boarding_mobs, user)
	// Przez te 2 sekundy Sabre mógł wystartować albo zostać zniszczony
	if(!success || QDELETED(src) || !shuttle_docked_at || QDELETED(user))
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

// Bez ..(): /atom/setDir wysyła COMSIG_ATOM_DIR_CHANGE, na który element dekalu sam obraca dekal, a transform
// kafelka obraca też jego nakładki, więc paski na podłodze obróciłyby się dwa razy (LEGACY_OVERRIDES.md)
/turf/closed/indestructible/dropship/setDir(newdir)
	dir = newdir
	transform = dropship_turf_transform(dir)

/turf/open/indestructible/dropship/setDir(newdir)
	dir = newdir
	transform = dropship_turf_transform(dir)

// Skrzydła (boczne gondole) to podłoga: można po nich podejść do wrót kokpitu i kliknięciem wejść do środka

/turf/open/indestructible/dropship/sabre_wing
	name = "skrzydło Sabre"
	desc = "Gondola Sabre. Można po niej przejść do wrót kokpitu."
	icon = 'nsv13/icons/turf/dropship.dmi'
	initial_gas_mix = AIRLESS_ATMOS

/// Ktoś stoi na skrzydle: w locie zostałby w kosmosie przy parkingu, więc start czeka, aż zejdzie
/obj/structure/overmap/small_craft/transport/sabre/shuttle/shuttle_can_launch(mob/user)
	for(var/turf/open/indestructible/dropship/sabre_wing/wing in shuttle_port?.return_turfs())
		if(locate(/mob/living) in wing)
			to_chat(user, span_warning("Na skrzydle [src] ktoś stoi. Start po zejściu."))
			return FALSE
	return ..()

// Wrota w burcie kokpitu: wyjście na zewnątrz w doku, zablokowane w locie

/turf/closed/indestructible/dropship/entry/sabre
	desc = "Masywne wrota. W doku wychodzi się nimi na zewnątrz, w locie są zablokowane."

/turf/closed/indestructible/dropship/entry/sabre/Bumped(atom/movable/AM)
	var/area/shuttle/sabre/A = loc
	if(!istype(A) || !A.sabre || !ismob(AM))
		return
	// Ze skrzydła wrota prowadzą do środka (jak kliknięcie), a nie wyrzucają na zewnątrz
	if(istype(get_turf(AM), /turf/open/indestructible/dropship/sabre_wing))
		if(isliving(AM))
			INVOKE_ASYNC(A.sabre, TYPE_PROC_REF(/obj/structure/overmap/small_craft/transport/sabre/shuttle, sabre_board), AM, TRUE)
		return
	if(A.sabre.shuttle_docked_at)
		if(!A.sabre.shuttle_leave(AM))
			to_chat(AM, span_warning("Wyjście z [A.sabre] jest zablokowane."))
	else
		to_chat(AM, span_warning("Wrota są zablokowane w trakcie lotu."))

/// Kliknięcie we wrota: ze skrzydła wejście do środka, od środka wyjście na zewnątrz (jak wejście we wrota)
/turf/closed/indestructible/dropship/entry/sabre/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/area/shuttle/sabre/A = loc
	if(!istype(A) || !A.sabre || !isliving(user))
		return
	if(istype(get_turf(user), /turf/open/indestructible/dropship/sabre_wing))
		return A.sabre.sabre_board(user, TRUE)
	if(get_area(user) != A)
		return
	if(!A.sabre.shuttle_docked_at)
		to_chat(user, span_warning("Wrota są zablokowane w trakcie lotu."))
	else if(!A.sabre.shuttle_leave(user))
		to_chat(user, span_warning("Wyjście z [A.sabre] jest zablokowane."))
	return TRUE

/turf/closed/indestructible/dropship/entry/sabre/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

// Właz w lewej gondoli: wejście i obsługa jednostki od strony hangaru

/turf/closed/indestructible/dropship/sabre_hatch
	name = "właz Sabre"
	desc = "Właz w gondoli Sabre. Pustą ręką się wchodzi, a tu też montuje się części i naprawia kadłub. Paliwo (plazmę) wlewa się kanistrem w ładowni."

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

// Paliwo: plazma w podgrzewaczach we wnętrzu, jak w promach zbudowanych Wyznacznikiem. W ładowni stoi złącze
// z podgrzewaczem: przykręcony kanister plazmy napełnia podgrzewacz. Zbiornik paliwa z wyposażenia jednostki
// wyznacza tylko pojemność (wskaźnik i tankowanie w locie); myśliwce dalej latają na kriopaliwie.

/// Jednostki paliwa Sabre z jednego mola gazu w podgrzewaczu (kanister plazmy napełnia prawie cały zbiornik)
#define SABRE_FUEL_PER_MOLE 2

/obj/structure/overmap/small_craft/transport/sabre/shuttle
	/// Podgrzewacze we wnętrzu, z których leci paliwo
	var/list/fuel_heaters
	/// Kiedy znów przeszukać wnętrze (dobudowany podgrzewacz)
	var/fuel_heaters_refresh = 0

/// Podgrzewacze we wnętrzu, które dają paliwo (zamknięty panel, przykręcone), jak w consume_fuel() promów zbudowanych
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/get_fuel_heaters()
	if(world.time >= fuel_heaters_refresh)
		fuel_heaters = null
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/H as anything in fuel_heaters)
		if(QDELETED(H))
			fuel_heaters = null
			break
	if(!length(fuel_heaters))
		fuel_heaters = list()
		fuel_heaters_refresh = world.time + 5 SECONDS
		for(var/area/shuttle/sabre/A in linked_areas)
			for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/H in A)
				fuel_heaters += H
	. = list()
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/H as anything in fuel_heaters)
		if(H.anchored && !H.panel_open)
			. += H

/obj/structure/overmap/small_craft/transport/sabre/shuttle/get_fuel()
	var/moles = 0
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/H as anything in get_fuel_heaters())
		var/datum/gas_mixture/air_contents = H.airs[1]
		moles += air_contents.total_moles()
	return min(moles * SABRE_FUEL_PER_MOLE, get_max_fuel())

/// Ustawia paliwo w podgrzewaczach (plazma), rozdzielone po równo
/obj/structure/overmap/small_craft/transport/sabre/shuttle/set_fuel(amount)
	var/list/heaters = get_fuel_heaters()
	if(!length(heaters))
		return FALSE
	amount = max(amount, 0)
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/H as anything in heaters)
		var/datum/gas_mixture/air_contents = H.airs[1]
		air_contents.clear()
		air_contents.set_moles(GAS_PLASMA, amount / SABRE_FUEL_PER_MOLE / length(heaters))
		air_contents.set_temperature(T20C)
		H.update_parents()
	return amount

/obj/structure/overmap/small_craft/transport/sabre/shuttle/use_fuel(force = FALSE)
	if(!engines_active() && !force)
		return FALSE
	var/fuel_consumption = 0.5 * (loadout.get_slot(HARDPOINT_SLOT_ENGINE)?.tier)
	var/amount = user_thrust_dir ? fuel_consumption + 0.25 : fuel_consumption
	var/list/heaters = get_fuel_heaters()
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/H as anything in heaters)
		H.consumeFuel(amount / SABRE_FUEL_PER_MOLE / length(heaters))
	if(get_fuel() >= amount)
		return TRUE
	set_master_caution(TRUE)
	return FALSE

/obj/structure/overmap/small_craft/transport/sabre/shuttle/empty_fuel_tank()
	set_fuel(0)

/// Podgrzewacz paliwa Sabre: ten sam co w promach zbudowanych, na start z odrobiną plazmy. Wpuszczony w podłogę
/// ładowni (da się przejść, a w górniczym stoi na nim skrzynia na rudę), bo wnętrze nie ma wolnego pola.
/obj/machinery/atmospherics/components/unary/shuttle/heater/sabre
	name = "podgrzewacz paliwa Sabre"
	desc = "Trzyma plazmę, na której lata Sabre. Napełnia się go kanistrem plazmy przykręconym do złącza obok."
	density = FALSE
	layer = LOW_OBJ_LAYER

/obj/machinery/atmospherics/components/unary/shuttle/heater/sabre/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_PLASMA, rand(250, 500))

// Wąż kriopaliwa nie tankuje Sabre: paliwem jest plazma z kanistra w ładowni
/obj/item/cryofuel_nozzle/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /turf/closed/indestructible/dropship/sabre_hatch))
		to_chat(user, span_warning("Sabre lata na plazmie: przykręć kanister plazmy do złącza paliwa w jego ładowni."))
		return
	return ..()

// Tankowanie w locie z Sabre albo do Sabre: paliwo przez get_fuel()/set_fuel(), bo plazmy nie da się przelać
// do zbiornika kriopaliwa myśliwca i odwrotnie (jednostki paliwa liczą się tak samo)
/obj/item/fighter_component/primary/utility/refuel/transfer_fuel(obj/structure/overmap/small_craft/us, obj/structure/overmap/small_craft/them)
	if(!istype(us, /obj/structure/overmap/small_craft/transport/sabre/shuttle) && !istype(them, /obj/structure/overmap/small_craft/transport/sabre/shuttle))
		return ..()
	var/transfer_amount = clamp(them.get_max_fuel() - them.get_fuel(), 0, fuel_transfer_rate)
	if(transfer_amount <= 0)
		return span_notice("Jednostka docelowa jest w pełni zatankowana.")
	if(us.get_fuel() <= minimum_fuel_to_keep)
		return span_warning("Poziom paliwa poniżej minimalnego bezpiecznego poziomu transferu.")
	var/their_fuel = them.get_fuel()
	if(!them.set_fuel(their_fuel + transfer_amount))
		return span_warning("Jednostka docelowa nie przyjmuje paliwa z węża.")
	us.set_fuel(us.get_fuel() - transfer_amount)
	us.relay('nsv13/sound/effects/fighters/refuel.ogg')
	them.relay('nsv13/sound/effects/fighters/refuel.ogg')

#undef SABRE_FUEL_PER_MOLE

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
