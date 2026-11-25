/// AQUILA - ekran taktyczny (plan walki na overmapie, etap E10 „konsolidacja konsol”).
/// Jedno okno z trzema trybami (Rozpoznanie, Ogień, Podgląd) zamiast osobnych okien stanowiska rozpoznania, konsoli
/// taktycznej, DRADIS mostka, monitorowania uzbrojenia i AMS. Konsole zostają na mapach i otwierają to samo okno,
/// różnią się trybem startowym i uprawnieniami: sensorami steruje tylko ten, kto stoi przy stanowisku rozpoznania
/// (na okręcie bez niego przy DRADIS mostka), strzela tylko strzelec przy konsoli taktycznej, a impuls radaru
/// i wywołanie ma też pilot przy sterze. Pozostali tylko patrzą.
/// Myśliwce i małe jednostki, DRADIS-y ładowni i górników oraz zintegrowane DRADIS-y zostają przy starych oknach.

#define TACTICAL_SCREEN_SENSORS "sensors"
#define TACTICAL_SCREEN_FIRE "fire"
#define TACTICAL_SCREEN_VIEW "view"

/// Akcje okna, które zmieniają pracę sensorów
GLOBAL_LIST_INIT(tactical_screen_sensor_actions, list(
	"designate", "set_radar_delay", "set_sensor_mode", "set_telescope", "set_radar_beam", "set_radar_aim",
	"array_toggle", "scan_planet",
))

/// Akcje okna, które zmieniają uzbrojenie i cele (oprócz akcji zaczynających się od "fc_")
GLOBAL_LIST_INIT(tactical_screen_fire_actions, list(
	"lock_designated", "toggle_gun_camera", "lock_ship", "dump_lock", "toggle_additional_weapon_info",
	"toggle_weapon_priority_modification", "change_weapon_priority",
))

/obj/machinery/computer
	/// AQUILA - okno ekranu taktycznego tej konsoli (tworzone przy pierwszym otwarciu)
	var/datum/tactical_screen/tactical_screen

/// Okręt, którego ekran taktyczny otwiera ta konsola, albo null, gdy konsola zostaje przy swoim starym oknie
/obj/machinery/computer/proc/tactical_screen_ship()
	return null

/obj/machinery/computer/ship/dradis/tactical_screen_ship()
	if(istype(src, /obj/machinery/computer/ship/dradis/minor) || istype(src, /obj/machinery/computer/ship/dradis/mining) || istype(src, /obj/machinery/computer/ship/dradis/internal))
		return null
	if(!linked || istype(linked, /obj/structure/overmap/small_craft))
		return null
	return linked

/obj/machinery/computer/ship/tactical/tactical_screen_ship()
	return uses_fire_control() ? linked : null

/obj/machinery/computer/ship/ordnance/tactical_screen_ship()
	if(!linked || istype(linked, /obj/structure/overmap/small_craft))
		return null
	return linked

/obj/machinery/computer/ams/tactical_screen_ship()
	var/obj/structure/overmap/ship = get_overmap()
	if(!ship || istype(ship, /obj/structure/overmap/small_craft))
		return null
	return ship

/// Otwiera ekran taktyczny; FALSE, gdy ta konsola go nie używa
/obj/machinery/computer/proc/open_tactical_screen(mob/user)
	if(!tactical_screen_ship())
		return FALSE
	if(!tactical_screen)
		tactical_screen = new(src)
	tactical_screen.ui_interact(user)
	return TRUE

/obj/machinery/computer/Destroy()
	QDEL_NULL(tactical_screen)
	return ..()

/obj/machinery/computer/ship/dradis/ui_interact(mob/user, datum/tgui/ui)
	if(has_overmap() && open_tactical_screen(user))
		return
	return ..()

/obj/machinery/computer/ship/dradis/sensors/ui_interact(mob/user, datum/tgui/ui)
	if(has_overmap() && open_tactical_screen(user))
		return
	return ..()

/obj/machinery/computer/ship/tactical/ui_interact(mob/user, datum/tgui/ui)
	if(open_tactical_screen(user))
		return
	return ..()

/obj/machinery/computer/ship/ordnance/ui_interact(mob/user, datum/tgui/ui)
	if(open_tactical_screen(user))
		return
	return ..()

/obj/machinery/computer/ams/ui_interact(mob/user, datum/tgui/ui)
	if(open_tactical_screen(user))
		return
	return ..()

// Fala impulsu rusza w oknie razem z impulsem, nie przy następnym odświeżeniu
/obj/machinery/computer/ship/dradis/sensors/send_radar_pulse()
	. = ..()
	if(. && tactical_screen)
		SStgui.update_uis(tactical_screen)

/// Konsola, z której okręt steruje sensorami: stanowisko rozpoznania, a bez niego DRADIS mostka
/obj/structure/overmap/proc/tactical_sensor_source()
	if(!QDELETED(sensor_console))
		return sensor_console
	if(!QDELETED(dradis) && dradis.tactical_screen_ship() == src)
		return dradis
	return null

/// Konsola taktyczna z kontrolą ognia, jeśli okręt ją ma
/obj/structure/overmap/proc/tactical_fire_source()
	if(!QDELETED(tactical) && tactical.uses_fire_control())
		return tactical
	return null

/datum/tactical_screen
	var/obj/machinery/computer/console

/datum/tactical_screen/New(obj/machinery/computer/console)
	. = ..()
	src.console = console

/datum/tactical_screen/Destroy()
	SStgui.close_uis(src)
	console = null
	return ..()

/datum/tactical_screen/ui_host(mob/user)
	return console

/datum/tactical_screen/ui_state(mob/user)
	return console.ui_state(user)

/datum/tactical_screen/ui_status(mob/user, datum/ui_state/state)
	return console.ui_status(user, state)

/datum/tactical_screen/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TacticalScreen", "Ekran taktyczny")
		ui.open()
		ui.set_autoupdate(TRUE)

/// Co user może z tej konsoli: list(sensors, fire, pulse); pulse to impuls radaru i wywołanie okrętu
/datum/tactical_screen/proc/permissions(mob/user)
	. = list(TACTICAL_SCREEN_SENSORS = FALSE, TACTICAL_SCREEN_FIRE = FALSE, "pulse" = FALSE)
	var/obj/structure/overmap/ship = console?.tactical_screen_ship()
	if(!ship || !user || (isobserver(user) && !IsAdminGhost(user)))
		return
	var/at_console = issilicon(user) || IsAdminGhost(user) || in_range(console, user)
	.[TACTICAL_SCREEN_SENSORS] = at_console && console == ship.tactical_sensor_source()
	.[TACTICAL_SCREEN_FIRE] = console == ship.tactical_fire_source() && (user == ship.gunner || IsAdminGhost(user))
	.["pulse"] = .[TACTICAL_SCREEN_SENSORS] || user == ship.pilot

/datum/tactical_screen/ui_data(mob/user)
	var/list/data = list()
	var/obj/structure/overmap/ship = console?.tactical_screen_ship()
	if(!ship)
		return data
	var/list/allowed = permissions(user)
	data["console"] = console.name
	data["can_sensors"] = allowed[TACTICAL_SCREEN_SENSORS]
	data["can_fire"] = allowed[TACTICAL_SCREEN_FIRE]
	data["can_pulse"] = allowed["pulse"]
	data["mode"] = allowed[TACTICAL_SCREEN_SENSORS] ? TACTICAL_SCREEN_SENSORS : (allowed[TACTICAL_SCREEN_FIRE] ? TACTICAL_SCREEN_FIRE : TACTICAL_SCREEN_VIEW)
	data["ship_name"] = ship.name
	data["has_station"] = !QDELETED(ship.sensor_console)
	var/obj/machinery/computer/ship/dradis/sensors = ship.tactical_sensor_source()
	if(sensors)
		var/list/sensor_data = sensors.ui_data(user)
		if(!istype(sensors, /obj/machinery/computer/ship/dradis/sensors))
			sensors.add_scope_data(sensor_data)
		sensor_data -= "ships" // blipy DRADIS: okno rysuje kontakty
		data["sensor"] = sensor_data
	var/obj/machinery/computer/ship/tactical/fire = ship.tactical_fire_source()
	if(fire)
		data["fire"] = fire.ui_data(user)
	return data

/datum/tactical_screen/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/obj/structure/overmap/ship = console?.tactical_screen_ship()
	if(!ship)
		return TRUE
	var/list/allowed = permissions(usr)
	if(action == "hail" || action == "fc_hail")
		if(!allowed["pulse"])
			return TRUE
		if(action == "fc_hail" && !istype(console, /obj/machinery/computer/ship/tactical))
			action = "hail"
			params = list("target" = params["id"])
		if(action == "hail" && !istype(console, /obj/machinery/computer/ship/dradis))
			var/obj/machinery/computer/ship/dradis/hailer = ship.tactical_sensor_source()
			hailer?.ui_act(action, params, ui, state)
			return TRUE
		console.ui_act(action, params, ui, state)
		return TRUE
	if(action == "radar_pulse")
		if(!allowed["pulse"])
			return TRUE
		var/obj/machinery/computer/ship/dradis/pulser = ship.tactical_sensor_source()
		if(pulser?.can_radar_pulse())
			pulser.send_radar_pulse()
		return TRUE
	if(action in GLOB.tactical_screen_sensor_actions)
		if(!allowed[TACTICAL_SCREEN_SENSORS])
			return TRUE
		var/obj/machinery/computer/ship/dradis/sensors = console
		if(istype(sensors, /obj/machinery/computer/ship/dradis/sensors))
			sensors.ui_act(action, params, ui, state)
			return TRUE
		// DRADIS mostka w roli stanowiska: ma tylko tryb radaru, opóźnienie impulsu i wyznaczanie celów
		switch(action)
			if("set_sensor_mode")
				sensors.sensor_mode = params["radar"] ? SENSOR_MODE_RADAR : SENSOR_MODE_PASSIVE
			if("set_radar_delay")
				var/seconds = text2num(params["seconds"])
				if(isnum_safe(seconds))
					sensors.radar_delay = clamp(round(seconds) SECONDS, MIN_RADAR_DELAY, MAX_RADAR_DELAY)
			if("designate")
				sensors.designate(locate(params["id"]), params["designation"], usr)
		return TRUE
	if(copytext(action, 1, 4) == "fc_" || (action in GLOB.tactical_screen_fire_actions))
		if(allowed[TACTICAL_SCREEN_FIRE])
			console.ui_act(action, params, ui, state)
		return TRUE
	return TRUE

#undef TACTICAL_SCREEN_SENSORS
#undef TACTICAL_SCREEN_FIRE
#undef TACTICAL_SCREEN_VIEW
