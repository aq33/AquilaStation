/// AQUILA - sensor console: the radar operator's station.
/// It runs the ship's sensors (listening or active radar, radar pulse) and designates targets, which every DRADIS
/// on the ship and the tactical console then show. DRADIS stays a map for everyone, without the sensor controls.
/// A ship without a sensor console (older maps, AI ships, fighters) keeps the sensor controls on its DRADIS.

#define SENSOR_DESIGNATION_PRIMARY "primary"
#define SENSOR_DESIGNATION_SECONDARY "secondary"
/// Tactical console threat bands, in tiles (the AI gun range on the rescaled overmap is 25)
#define SENSOR_THREAT_NEAR 25

/obj/structure/overmap
	/// AQUILA - the radar operator's console, if the ship has one
	var/obj/machinery/computer/ship/dradis/sensors/sensor_console
	/// AQUILA - lazy list, target => SENSOR_DESIGNATION_*: targets the radar operator passed to the bridge
	var/list/designated_targets
	/// AQUILA - lazy list, target => number: "Kontakt 3" stays "Kontakt 3" on every console of this ship
	var/list/sensor_contact_numbers
	/// AQUILA - last number handed out in sensor_contact_numbers
	var/last_sensor_contact_number = 0

/// What this ship calls target on its consoles: the real name once identified, otherwise a stable contact number
/obj/structure/overmap/proc/get_contact_label(obj/structure/overmap/target, identified)
	if(identified)
		return target.name
	return "Kontakt [get_contact_number(target)]"

/// Stable contact number of target on this ship's consoles ("K3" on the sensor console scope)
/obj/structure/overmap/proc/get_contact_number(obj/structure/overmap/target)
	. = LAZYACCESS(sensor_contact_numbers, target)
	if(!.)
		. = ++last_sensor_contact_number
		LAZYSET(sensor_contact_numbers, target, .)

/// Różnica współrzędnych na overmapie po najkrótszej drodze przez szew mapy. Overmapa zawija się z okresem
/// rozmiar - 2 × (TRANSITIONEDGE + 1), jak w overmap_dist(), a nie z okresem całego rozmiaru świata.
/proc/overmap_wrap_delta(delta, world_size)
	var/period = world_size - 2 * (TRANSITIONEDGE + 1)
	if(period <= 0)
		return delta
	delta = delta % period
	if(delta > period / 2)
		delta -= period
	else if(delta < -period / 2)
		delta += period
	return delta

/// Whether our sensors resolve target well enough to show its name and faction (same rule as the DRADIS base proc)
/obj/structure/overmap/proc/is_contact_identified(obj/structure/overmap/target, range)
	if(target.faction == faction || (target in target_painted))
		return TRUE
	var/dist = overmap_dist(src, target)
	if(dist <= target.sensor_profile)
		return TRUE
	// W czasie impulsu gracza range konsoli to zasięg impulsu, a wiązka widzi tylko w swoim wycinku:
	// poza nim kontakt rozpoznajemy jak bez impulsu (player_sensors.dm)
	if(!ai_controlled && uses_sensor_suites() && world.time < last_radar_pulse + RADAR_VISIBILITY_PENALTY)
		var/base = sensor_console ? sensor_console.base_sensor_range : SENSOR_RANGE_DEFAULT
		return dist <= max(min(range, base), get_player_lidar_range(target))
	return dist <= range

/// Drops designations of targets that are gone or no longer in our system
/obj/structure/overmap/proc/prune_designations()
	for(var/obj/structure/overmap/target as anything in designated_targets)
		if(QDELETED(target) || target.z != z)
			LAZYREMOVE(designated_targets, target)
			continue
		// Kontakt, którego sensory już nie widzą, przestaje być celem: inaczej mostek dostawał jego dokładną
		// odległość, a teleskop i wiązka dalej celowały w prawdziwy namiar
		if(!(target in target_painted) && target.is_sensor_visible(src) < SENSOR_VISIBILITY_FAINT)
			LAZYREMOVE(designated_targets, target)

/obj/structure/overmap/proc/clear_designations()
	designated_targets = null

/obj/item/circuitboard/computer/ship/sensors
	name = "stanowisko rozpoznania (płytka komputera)"
	build_path = /obj/machinery/computer/ship/dradis/sensors

/datum/design/board/sensor_console
	name = "Projekt komputera (stanowisko rozpoznania)"
	desc = "Pozwala zbudować stanowisko rozpoznania, z którego operator steruje sensorami okrętu."
	id = "sensor_console"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/sensors
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/ship_circuits/New()
	. = ..()
	design_ids += "sensor_console"

/obj/machinery/computer/ship/dradis/sensors
	name = "stanowisko rozpoznania"
	desc = "Stanowisko operatora rozpoznania. Steruje sensorami okrętu, czyli radarem dookólnym albo kierunkowym, teleskopem, podczerwienią i nasłuchem, a wybrane kontakty przekazuje jako cele na DRADIS i do konsoli taktycznej."
	icon_screen = "comm_monitor"
	circuit = /obj/item/circuitboard/computer/ship/sensors

/// "Console" variant for bridges built from the goonstation console sprites (custom_computers.dm)
/obj/machinery/computer/ship/dradis/sensors/console
	icon = 'nsv13/goonstation/icons/obj/computer.dmi'
	icon_keyboard = null

/obj/machinery/computer/ship/dradis/sensors/set_position(obj/structure/overmap/OM)
	OM.sensor_console = src
	RegisterSignal(OM, COMSIG_FTL_STATE_CHANGE, PROC_REF(on_ftl_state_change), override = TRUE)

/obj/machinery/computer/ship/dradis/sensors/proc/on_ftl_state_change()
	SIGNAL_HANDLER
	reset_dradis_contacts()
	linked?.clear_designations()

/obj/machinery/computer/ship/dradis/sensors/Destroy()
	if(linked?.sensor_console == src)
		linked.sensor_console = null
	return ..()

/obj/machinery/computer/ship/dradis/sensors/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Cele wyznaczone tutaj widać na każdym DRADIS okrętu i w konsoli taktycznej.</span>"

/obj/machinery/computer/ship/dradis/sensors/ui_interact(mob/user, datum/tgui/ui)
	if(!has_overmap())
		to_chat(user, "<span class='warning'>Nie udało się nawiązać połączenia z okrętem.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SensorConsole", "Stanowisko rozpoznania")
		ui.open()
		ui.set_autoupdate(TRUE)

/// Active radar used to pulse only while someone had the DRADIS window open; the operator's console pulses on its own
/obj/machinery/computer/ship/dradis/sensors/process(delta_time)
	. = ..()
	if(!. || !linked || sensor_mode != SENSOR_MODE_RADAR)
		return
	if(can_radar_pulse())
		send_radar_pulse()

/obj/machinery/computer/ship/dradis/sensors/ui_act(action, params)
	. = ..()
	if(. || isobserver(usr) || !linked)
		return
	switch(action)
		if("designate")
			designate(locate(params["id"]), params["designation"], usr)
			return TRUE
		if("set_radar_delay")
			var/seconds = text2num(params["seconds"])
			if(isnum_safe(seconds))
				radar_delay = clamp(round(seconds) SECONDS, MIN_RADAR_DELAY, MAX_RADAR_DELAY)
			return TRUE
		if("set_sensor_mode")
			sensor_mode = params["radar"] ? SENSOR_MODE_RADAR : SENSOR_MODE_PASSIVE
			return TRUE

/// Passes target to the bridge as a primary or secondary target; any other designation clears it.
/// There is one primary target: a new one turns the old one into a secondary.
/obj/machinery/computer/ship/dradis/sensors/proc/designate(obj/structure/overmap/target, designation, mob/user)
	if(!istype(target) || !linked || target == linked || target.z != linked.z || istype(target, /obj/structure/overmap/asteroid))
		return FALSE
	if(designation != SENSOR_DESIGNATION_PRIMARY && designation != SENSOR_DESIGNATION_SECONDARY)
		LAZYREMOVE(linked.designated_targets, target)
		return TRUE
	if(!can_see_contact(target))
		return FALSE
	if(designation == SENSOR_DESIGNATION_PRIMARY)
		for(var/obj/structure/overmap/other as anything in linked.designated_targets)
			if(linked.designated_targets[other] == SENSOR_DESIGNATION_PRIMARY)
				linked.designated_targets[other] = SENSOR_DESIGNATION_SECONDARY
	LAZYSET(linked.designated_targets, target, designation)
	var/label = linked.get_contact_label(target, linked.is_contact_identified(target, sensor_range))
	var/message = "<span class='notice'>Operator rozpoznania: [designation == SENSOR_DESIGNATION_PRIMARY ? "cel główny" : "cel drugorzędny"] [label], namiar [round(overmap_angle(linked, target))]°, [round(overmap_dist(linked, target))] pól.</span>"
	var/list/crew = list()
	crew |= linked.gunner
	crew |= linked.pilot
	crew -= null
	crew -= user
	for(var/mob/member as anything in crew)
		to_chat(member, message)
	return TRUE

/// Whether this console shows target at all (same rule as the DRADIS base proc)
/obj/machinery/computer/ship/dradis/proc/can_see_contact(obj/structure/overmap/target)
	if(!linked || QDELETED(target) || target.z != linked.z)
		return FALSE
	if((target in linked.target_painted) || target.faction == linked.faction)
		return TRUE
	if(overmap_dist(linked, target) > max(sensor_range * 2, target.sensor_profile))
		return FALSE
	return target.is_sensor_visible(linked) >= SENSOR_VISIBILITY_FAINT

/obj/machinery/computer/ship/dradis/sensors/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!linked)
		return
	data["radar_mode"] = sensor_mode == SENSOR_MODE_RADAR
	data["radar_delay"] = radar_delay / 10
	data["radar_delay_min"] = MIN_RADAR_DELAY / 10
	data["radar_delay_max"] = MAX_RADAR_DELAY / 10
	data["pulse_cooldown"] = round(max(0, linked.last_radar_pulse + radar_delay - world.time) / 10, 0.1)
	data["pulse_active"] = world.time < linked.last_radar_pulse + RADAR_VISIBILITY_PENALTY
	var/list/contacts = list()
	for(var/list/blip as anything in data["ships"])
		var/obj/structure/overmap/OM = locate(blip["id"])
		if(!istype(OM) || OM == linked || istype(OM, /obj/structure/overmap/asteroid))
			continue
		// Positions come from the blip, so the operator sees the same uncertain contact as the DRADIS map.
		// A certain contact gets its exact position and course, so the window can move it between updates.
		var/certain = !blip["uncertainty"]
		var/dx = certain ? (OM.x + OM.offset.a) - (linked.x + linked.offset.a) : blip["x"] - linked.x
		var/dy = certain ? (OM.y + OM.offset.e) - (linked.y + linked.offset.e) : blip["y"] - linked.y
		dx = overmap_wrap_delta(dx, world.maxx)
		dy = overmap_wrap_delta(dy, world.maxy)
		contacts += list(list(
			"vx" = certain ? round(OM.velocity.a - linked.velocity.a, 0.01) : 0,
			"vy" = certain ? round(OM.velocity.e - linked.velocity.e, 0.01) : 0,
			"id" = blip["id"],
			"name" = blip["name"],
			"dx" = round(dx, 0.01),
			"dy" = round(dy, 0.01),
			"uncertainty" = blip["uncertainty"] || 0,
			"hostile" = OM.faction != linked.faction,
			"identified" = linked.is_contact_identified(OM, sensor_range),
			"locking_us" = !!(LAZYFIND(OM.target_painted, linked) || (OM.ai_controlled && OM.last_target == linked)),
			"painted" = !!LAZYFIND(linked.target_painted, OM),
			"locked" = linked.target_lock == OM,
			"designation" = blip["designation"],
			"number" = linked.get_contact_number(OM),
		))
	data["contacts"] = contacts
	// Heard pulses and fire from undetected ships, drawn on the scope but not designatable
	var/list/markers = list()
	for(var/list/blip as anything in data["ships"])
		if(!blip["emission"] && !blip["ghost"])
			continue
		var/dx = blip["x"] - linked.x
		var/dy = blip["y"] - linked.y
		dx = overmap_wrap_delta(dx, world.maxx)
		dy = overmap_wrap_delta(dy, world.maxy)
		markers += list(list("dx" = dx, "dy" = dy, "emission" = blip["emission"], "ghost" = !!blip["ghost"], "opacity" = blip["opacity"]))
	data["markers"] = markers
	data["gunner"] = !!linked.gunner
	data["turn"] = round(linked.angular_velocity, 0.1)
	data["pulse_at"] = linked.last_radar_pulse
	data["objects"] = linked.get_scope_objects(sensor_range)
	data["near_range"] = SENSOR_THREAT_NEAR

/// Asteroids, wrecks and anomalies for the operator's scope: not contacts (nothing to designate), only obstacles and things to look at.
/// Asteroids and wrecks follow the same visibility as ships; anomalies show anywhere in the system, as on DRADIS.
/obj/structure/overmap/proc/get_scope_objects(display_range)
	. = list()
	if(!current_system)
		return
	for(var/atom/movable/thing as anything in current_system.system_contents)
		if(QDELETED(thing) || thing.z != z)
			continue
		var/kind
		var/name
		var/detail
		if(istype(thing, /obj/effect/overmap_anomaly))
			var/obj/effect/overmap_anomaly/anomaly = thing
			kind = "anomaly"
			name = anomaly.scanned ? anomaly.name : "anomalia"
			detail = anomaly.scanned ? "zbadana" : "niezbadana"
		else if(istype(thing, /obj/structure/overmap/asteroid))
			var/obj/structure/overmap/asteroid/rock = thing
			if(overmap_dist(src, rock) > max(display_range * 2, rock.sensor_profile) || rock.is_sensor_visible(src) < SENSOR_VISIBILITY_FAINT)
				continue
			kind = istype(rock, /obj/structure/overmap/asteroid/shipbreak_wreck) ? "wreck" : "asteroid"
			name = rock.name
			if(kind == "asteroid")
				detail = "wydobycie: poziom [rock.required_tier]"
		else
			continue
		var/dx = thing.x - x
		var/dy = thing.y - y
		dx = overmap_wrap_delta(dx, world.maxx)
		dy = overmap_wrap_delta(dy, world.maxy)
		. += list(list("id" = "\ref[thing]", "kind" = kind, "name" = name, "detail" = detail, "dx" = dx, "dy" = dy))

/// Every DRADIS on a ship with a sensor console follows the operator: its range and its contact labels.
/obj/machinery/computer/ship/dradis/ui_data(mob/user)
	var/obj/machinery/computer/ship/dradis/sensors/station = linked?.sensor_console
	var/follows_station = station && station != src
	if(follows_station)
		sensor_range = base_sensor_range // DRADIS mostka jest do latania: widzi podstawowym radarem, bez impulsów operatora
		sensor_mode = SENSOR_MODE_PASSIVE // Only the operator pulses
		linked.sensor_view_basic = TRUE
	. = ..()
	if(linked)
		linked.sensor_view_basic = FALSE
	var/list/data = .
	if(!linked)
		return
	data["sensor_station"] = follows_station
	linked.prune_designations()
	// Namiar usłyszanego radaru wroga zna tylko operator rozpoznania; DRADIS mostka go nie pokazuje
	if(follows_station)
		var/list/blips = data["ships"]
		for(var/list/blip as anything in blips.Copy())
			if(blip["emission"])
				blips -= list(blip)
	for(var/list/blip as anything in data["ships"])
		var/obj/structure/overmap/OM = locate(blip["id"])
		if(!istype(OM) || OM == linked || istype(OM, /obj/structure/overmap/asteroid) || OM.faction == linked.faction)
			continue
		if(!linked.is_contact_identified(OM, sensor_range))
			blip["name"] = linked.get_contact_label(OM, FALSE)
		var/designation = LAZYACCESS(linked.designated_targets, OM)
		if(designation)
			blip["designation"] = designation

/obj/machinery/computer/ship/dradis/ui_act(action, params)
	var/obj/machinery/computer/ship/dradis/sensors/station = linked?.sensor_console
	if(station && station != src && (action in list("radar_pulse", "sensor_mode", "radar_delay")))
		return TRUE // The sensors are run from the sensor console
	return ..()

/obj/machinery/computer/ship/tactical/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!linked)
		return
	data["sensor_station"] = !!linked.sensor_console
	data["designated_targets"] = get_designated_data()

/// What the gunner sees of the operator's targets
/obj/machinery/computer/ship/tactical/proc/get_designated_data()
	linked.prune_designations()
	var/list/designated = list()
	var/range = linked.sensor_console ? linked.sensor_console.sensor_range : SENSOR_RANGE_DEFAULT
	for(var/obj/structure/overmap/target as anything in linked.designated_targets)
		designated += list(list(
			"id" = "\ref[target]",
			"name" = linked.get_contact_label(target, linked.is_contact_identified(target, range)),
			"designation" = linked.designated_targets[target],
			"distance" = round(overmap_dist(linked, target)),
			"bearing" = round(overmap_angle(linked, target)),
			"painted" = !!LAZYFIND(linked.target_painted, target),
			"locked" = linked.target_lock == target,
		))
	return designated

/obj/machinery/computer/ship/tactical/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(. || action != "lock_designated" || !linked)
		return
	lock_designated(locate(params["id"]))
	return TRUE

/// A painted designated target becomes the fire target, any other one starts the lock-on
/obj/machinery/computer/ship/tactical/proc/lock_designated(obj/structure/overmap/target)
	if(!istype(target) || !LAZYACCESS(linked?.designated_targets, target))
		return FALSE
	if(LAZYFIND(linked.target_painted, target))
		if(linked.target_lock != target)
			linked.select_target(target)
		return TRUE
	linked.start_lockon(target)
	return TRUE

#undef SENSOR_DESIGNATION_PRIMARY
#undef SENSOR_DESIGNATION_SECONDARY
#undef SENSOR_THREAT_NEAR
