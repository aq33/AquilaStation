// Porty USB z tg dla konsol i padów: monitor załogi, zaawansowana konsola kamer, teleporter,
// wyrzutnie bluespace (pad i konsola) oraz pad kwantowy.
// Nasze maszyny są starsze niż w tg, więc brakujące procki (lista celów teleportera, sprawdzenia wyrzutni)
// i sygnały dopisujemy tutaj w nadpisaniach z ..().
// Pominięte: komputer nawigacyjny promu i konsola budowy bazy - w tg mają add_usb_port = FALSE.

// ---------------------------------------------------------------------------
// Monitor załogi
// ---------------------------------------------------------------------------

/obj/machinery/computer/crew/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/medical_console_data))

/obj/item/circuit_component/medical_console_data
	display_name = "Crew Monitoring Data"
	desc = "Wypisuje stan zdrowia osób widocznych na monitorze załogi. Wynik można potem przefiltrować komponentem Select Query."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The records retrieved
	var/datum/port/output/records

	var/obj/machinery/computer/crew/attached_console

/obj/item/circuit_component/medical_console_data/populate_ports()
	records = add_output_port("Crew Monitoring Data", PORT_TYPE_TABLE)

/obj/item/circuit_component/medical_console_data/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/crew))
		attached_console = shell

/obj/item/circuit_component/medical_console_data/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/medical_console_data/get_ui_notices()
	. = ..()
	. += create_table_notices(list(
		"name",
		"job",
		"life_status",
		"suffocation",
		"toxin",
		"burn",
		"brute",
		"location",
		"health",
	))

/obj/item/circuit_component/medical_console_data/input_received(datum/port/input/port)
	if(!attached_console || !GLOB.crewmonitor)
		return

	var/turf/console_turf = get_turf(attached_console)
	if(!console_turf)
		return

	var/list/new_table = list()
	// Nasz monitor liczy dane po wirtualnym poziomie z i fizycznym z konsoli (czujniki z GLOB.suit_sensors_list)
	for(var/list/player_record as anything in GLOB.crewmonitor.update_data(attached_console.get_virtual_z_level(), console_turf.z))
		var/list/entry = list()
		entry["name"] = player_record["name"]
		entry["job"] = player_record["assignment"]
		entry["life_status"] = player_record["life_status"]
		entry["suffocation"] = player_record["oxydam"]
		entry["toxin"] = player_record["toxdam"]
		entry["burn"] = player_record["burndam"]
		entry["brute"] = player_record["brutedam"]
		entry["location"] = player_record["area"]
		// Nasz monitor nie liczy zdrowia - bierzemy je z moba, ale tylko gdy czujnik podaje obrażenia
		if(!isnull(player_record["brutedam"]))
			var/mob/living/carbon/human/tracked = locate(player_record["ref"])
			if(istype(tracked))
				entry["health"] = tracked.health
		new_table += list(entry)

	records.set_output(new_table)

// ---------------------------------------------------------------------------
// Zaawansowana konsola kamer
// ---------------------------------------------------------------------------

/obj/machinery/computer/camera_advanced
	/// Czy konsola dostaje port USB (z tg)
	var/add_usb_port = TRUE
	/// Akcje z komponentów Equipment Action podpiętego układu
	var/list/circuit_actions
	/// Czy circuity dostały już sygnał o utworzeniu oka
	var/usb_eye_announced = FALSE

// Konsola budowy bazy (tg: construction_console) i konsola projektanta promów - bez portu, jak w tg
/obj/machinery/computer/camera_advanced/base_construction
	add_usb_port = FALSE

/obj/machinery/computer/camera_advanced/shuttle_creator
	add_usb_port = FALSE

/obj/machinery/computer/camera_advanced/Initialize(mapload)
	. = ..()
	if(add_usb_port)
		AddComponent(/datum/component/usb_port, \
			list(
				/obj/item/circuit_component/advanced_camera,
				/obj/item/circuit_component/advanced_camera_intercept,
			), \
			PROC_REF(register_usb_port), \
			PROC_REF(unregister_usb_port) \
		)

/obj/machinery/computer/camera_advanced/Destroy()
	QDEL_LIST(circuit_actions)
	return ..()

/obj/machinery/computer/camera_advanced/give_eye_control(mob/user)
	if(eyeobj && !usb_eye_announced)
		usb_eye_announced = TRUE
		SEND_SIGNAL(src, COMSIG_ADVANCED_CAMERA_EYE_CREATED, eyeobj)
	. = ..()
	if(eyeobj)
		SEND_SIGNAL(eyeobj, COMSIG_REMOTE_CAMERA_ASSIGN_USER, user, null)

/obj/machinery/computer/camera_advanced/remove_eye_control(mob/living/user)
	if(user && eyeobj)
		SEND_SIGNAL(eyeobj, COMSIG_REMOTE_CAMERA_ASSIGN_USER, null, user)
	return ..()

/obj/machinery/computer/camera_advanced/GrantActions(mob/living/user)
	. = ..()
	for(var/datum/action/innate/circuit_equipment_action/circuit_action as anything in circuit_actions)
		circuit_action.Grant(user)
		actions += circuit_action

/// Equipment action component support

/obj/machinery/computer/camera_advanced/proc/register_usb_port(datum/component/usb_port/port)
	RegisterSignal(port, COMSIG_USB_PORT_REGISTER_PHYSICAL_OBJECT, PROC_REF(on_port_register_object))
	RegisterSignal(port, COMSIG_USB_PORT_UNREGISTER_PHYSICAL_OBJECT, PROC_REF(on_port_unregister_object))
	if(port.physical_object)
		on_port_register_object(port, port.physical_object)

/obj/machinery/computer/camera_advanced/proc/on_port_register_object(datum/component/usb_port/source, atom/movable/object)
	SIGNAL_HANDLER
	var/obj/item/integrated_circuit/circuit = source.attached_circuit
	if(!circuit || object == circuit)
		return
	RegisterSignal(object, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(add_circuit_action))
	RegisterSignal(object, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(remove_circuit_action))
	for(var/obj/item/circuit_component/equipment_action/action_comp in circuit.attached_components)
		add_circuit_action(null, action_comp)

/obj/machinery/computer/camera_advanced/proc/add_circuit_action(datum/_source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/circuit_equipment_action/new_action = new(src, action_comp)
	LAZYADD(circuit_actions, new_action)
	if(current_user)
		new_action.Grant(current_user)
		actions += new_action

/obj/machinery/computer/camera_advanced/proc/remove_circuit_action(datum/_source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	var/datum/action/innate/circuit_equipment_action/action = action_comp.granted_to[REF(src)]
	if(!istype(action))
		return
	LAZYREMOVE(circuit_actions, action)
	actions -= action
	qdel(action)

/obj/machinery/computer/camera_advanced/proc/on_port_unregister_object(datum/component/usb_port/source, atom/movable/object)
	SIGNAL_HANDLER
	var/obj/item/integrated_circuit/circuit = source.attached_circuit
	if(circuit)
		for(var/obj/item/circuit_component/equipment_action/action_comp in circuit.attached_components)
			remove_circuit_action(null, action_comp)
	UnregisterSignal(object, list(COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED))

/obj/machinery/computer/camera_advanced/proc/unregister_usb_port(datum/component/usb_port/port)
	if(port.physical_object)
		on_port_unregister_object(port, port.physical_object)
	UnregisterSignal(port, list(COMSIG_USB_PORT_REGISTER_PHYSICAL_OBJECT, COMSIG_USB_PORT_UNREGISTER_PHYSICAL_OBJECT))

/// Advanced camera component

/obj/item/circuit_component/advanced_camera
	display_name = "Advanced Camera Console"
	desc = "Podaje pozycję, na którą patrzy się przez konsolę."

	var/datum/port/output/eye_x
	var/datum/port/output/eye_y
	var/datum/port/output/eye_z

	var/obj/machinery/computer/camera_advanced/attached_console

/obj/item/circuit_component/advanced_camera/populate_ports()
	eye_x = add_output_port("X", PORT_TYPE_NUMBER)
	eye_y = add_output_port("Y", PORT_TYPE_NUMBER)
	eye_z = add_output_port("Z", PORT_TYPE_NUMBER)

/obj/item/circuit_component/advanced_camera/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/camera_advanced))
		attached_console = parent
		if(attached_console.eyeobj)
			register_eyeobj(attached_console.eyeobj)
		else
			RegisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED, PROC_REF(on_parent_eye_created))

/obj/item/circuit_component/advanced_camera/proc/on_parent_eye_created(datum/_source, mob/camera/ai_eye/remote/eyeobj)
	SIGNAL_HANDLER
	UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
	register_eyeobj(eyeobj)

/obj/item/circuit_component/advanced_camera/proc/register_eyeobj(mob/camera/ai_eye/remote/eyeobj)
	RegisterSignal(eyeobj, COMSIG_MOVABLE_MOVED, PROC_REF(on_eyeobj_moved))

/obj/item/circuit_component/advanced_camera/unregister_usb_parent(atom/movable/parent)
	if(attached_console)
		UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
		if(attached_console.eyeobj)
			UnregisterSignal(attached_console.eyeobj, COMSIG_MOVABLE_MOVED)
		attached_console = null
	return ..()

/obj/item/circuit_component/advanced_camera/proc/on_eyeobj_moved(atom/movable/source)
	SIGNAL_HANDLER
	var/turf/eye_turf = get_turf(source)
	if(!eye_turf)
		return
	if(!GLOB.cameranet.checkTurfVis(eye_turf))
		return
	eye_x.set_output(source.x)
	eye_y.set_output(source.y)
	eye_z.set_output(source.z)

/// Advanced camera target intercept component

/obj/item/circuit_component/advanced_camera_intercept
	display_name = "Advanced Camera Target Intercept"
	desc = "Pozwala użytkownikowi konsoli wskazać kliknięciem cel albo miejsce."

	var/datum/port/input/enabled

	var/datum/port/output/target_x
	var/datum/port/output/target_y
	var/datum/port/output/target_z

	var/datum/port/output/target_port

	var/datum/port/output/primary_click
	var/datum/port/output/secondary_click

	var/obj/machinery/computer/camera_advanced/attached_console

/obj/item/circuit_component/advanced_camera_intercept/populate_ports()
	. = ..()
	enabled = add_input_port("Enabled", PORT_TYPE_NUMBER)

	target_x = add_output_port("X", PORT_TYPE_NUMBER)
	target_y = add_output_port("Y", PORT_TYPE_NUMBER)
	target_z = add_output_port("Z", PORT_TYPE_NUMBER)

	target_port = add_output_port("Target", PORT_TYPE_ATOM)

	primary_click = add_output_port("Primary", PORT_TYPE_SIGNAL)
	secondary_click = add_output_port("Secondary", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/advanced_camera_intercept/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/computer/camera_advanced))
		attached_console = parent
		if(attached_console.eyeobj)
			register_eyeobj(attached_console.eyeobj)
		else
			RegisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED, PROC_REF(on_parent_eye_created))

/// Nasz click_intercept siedzi na kliencie, nie na mobie
/obj/item/circuit_component/advanced_camera_intercept/proc/set_intercept(mob/living/user, active)
	if(!user?.client)
		return
	if(active)
		user.client.click_intercept = src
	else if(user.client.click_intercept == src)
		user.client.click_intercept = null

/obj/item/circuit_component/advanced_camera_intercept/input_received(datum/port/input/port, list/return_values)
	if(port != enabled || !attached_console)
		return
	set_intercept(attached_console.current_user, !!enabled.value)

/obj/item/circuit_component/advanced_camera_intercept/proc/on_parent_eye_created(datum/_source, mob/camera/ai_eye/remote/eyeobj)
	SIGNAL_HANDLER
	UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
	register_eyeobj(eyeobj)

/obj/item/circuit_component/advanced_camera_intercept/proc/register_eyeobj(mob/camera/ai_eye/remote/eyeobj)
	RegisterSignal(eyeobj, COMSIG_REMOTE_CAMERA_ASSIGN_USER, PROC_REF(on_parent_assign_user))
	if(enabled.value)
		set_intercept(attached_console.current_user, TRUE)

/obj/item/circuit_component/advanced_camera_intercept/unregister_usb_parent(atom/movable/parent)
	if(attached_console)
		set_intercept(attached_console.current_user, FALSE)
		if(attached_console.eyeobj)
			UnregisterSignal(attached_console.eyeobj, COMSIG_REMOTE_CAMERA_ASSIGN_USER)
		UnregisterSignal(attached_console, COMSIG_ADVANCED_CAMERA_EYE_CREATED)
		attached_console = null
	return ..()

/obj/item/circuit_component/advanced_camera_intercept/proc/on_parent_assign_user(datum/_source, mob/living/new_user, mob/living/old_user)
	SIGNAL_HANDLER
	set_intercept(old_user, FALSE)
	if(enabled.value)
		set_intercept(new_user, TRUE)

/obj/item/circuit_component/advanced_camera_intercept/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		return
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return
	if(!GLOB.cameranet.checkTurfVis(target_turf))
		return
	if(parent?.shell && TIMER_COOLDOWN_CHECK(parent.shell, COOLDOWN_CIRCUIT_TARGET_INTERCEPT))
		return
	target_x.set_output(target.x)
	target_y.set_output(target.y)
	target_z.set_output(target.z)

	target_port.set_output(target)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		secondary_click.set_output(COMPONENT_SIGNAL)
	else
		primary_click.set_output(COMPONENT_SIGNAL)
	if(parent?.shell)
		TIMER_COOLDOWN_START(parent.shell, COOLDOWN_CIRCUIT_TARGET_INTERCEPT, 1 SECONDS)
	return TRUE

// ---------------------------------------------------------------------------
// Konsola teleportera
// ---------------------------------------------------------------------------

/obj/machinery/computer/teleporter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/teleporter_control_console))

/obj/machinery/computer/teleporter/set_target(mob/user)
	var/datum/weakref/old_target_ref = target_ref
	. = ..()
	if(target_ref != old_target_ref)
		SEND_SIGNAL(src, COMSIG_TELEPORTER_NEW_TARGET, target_ref?.resolve())

/obj/machinery/computer/teleporter/reset_regime()
	var/had_target = !!target_ref
	. = ..()
	if(had_target)
		SEND_SIGNAL(src, COMSIG_TELEPORTER_NEW_TARGET, null)

/// Ustawia cel teleportera i daje znać circuitom (z tg).
/obj/machinery/computer/teleporter/proc/set_teleport_target(atom/new_target)
	var/datum/weakref/new_target_ref = WEAKREF(new_target)
	if(target_ref == new_target_ref)
		return
	SEND_SIGNAL(src, COMSIG_TELEPORTER_NEW_TARGET, new_target)
	target_ref = new_target_ref
	ui_update()

/// Lista celów jak w set_target(): nazwa -> cel (z tg).
/obj/machinery/computer/teleporter/proc/get_targets()
	var/list/targets = list()
	var/list/area_index = list()

	if(regime_set == "Teleporter")
		for(var/obj/item/beacon/beacon in GLOB.teleportbeacons)
			if(!is_eligible(beacon))
				continue
			if(beacon.renamed)
				targets[avoid_assoc_duplicate_keys("[beacon.name] ([get_area(beacon)])", area_index)] = beacon
			else
				var/area/area = get_area(beacon)
				targets[avoid_assoc_duplicate_keys(area.name, area_index)] = beacon

		for(var/obj/item/implant/tracking/tracking_implant in GLOB.tracked_implants)
			if(!tracking_implant.imp_in || !isliving(tracking_implant.loc) || !tracking_implant.allow_teleport)
				continue
			var/mob/living/implanted = tracking_implant.loc
			if(implanted.stat == DEAD && implanted.timeofdeath + tracking_implant.lifespan_postmortem < world.time)
				continue
			if(is_eligible(tracking_implant))
				targets[avoid_assoc_duplicate_keys("[implanted.real_name] ([get_area(implanted)])", area_index)] = tracking_implant
	else if(power_station)
		for(var/obj/machinery/teleport/station/station in power_station.linked_stations)
			if(is_eligible(station) && station.teleporter_hub)
				var/area/area = get_area(station)
				targets[avoid_assoc_duplicate_keys(area.name, area_index)] = station

	return targets

/// Zasila i łączy docelową stację, jak przy ręcznym wyborze w trybie bramy.
/obj/machinery/computer/teleporter/proc/lock_in_station(obj/machinery/teleport/station/target_station)
	target_station.linked_stations |= power_station
	if(target_station.teleporter_hub)
		target_station.teleporter_hub.set_machine_stat(target_station.teleporter_hub.machine_stat & ~NOPOWER)
		target_station.teleporter_hub.update_icon()
	if(target_station.teleporter_console)
		target_station.teleporter_console.set_machine_stat(target_station.teleporter_console.machine_stat & ~NOPOWER)
		target_station.teleporter_console.update_icon()

/obj/item/circuit_component/teleporter_control_console
	display_name = "Teleporter Control Console"
	desc = "Steruje połączonym hubem i stacją teleportera."
	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/new_target
	var/datum/port/input/set_target_trigger
	var/datum/port/input/update_trigger

	var/datum/port/output/current_target
	var/datum/port/output/possible_targets
	var/datum/port/output/on_fail

	var/obj/machinery/computer/teleporter/attached_console

/obj/item/circuit_component/teleporter_control_console/populate_ports()
	new_target = add_input_port("New Target", PORT_TYPE_STRING)
	set_target_trigger = add_input_port("Set Target", PORT_TYPE_SIGNAL)
	update_trigger = add_input_port("Update Targets", PORT_TYPE_SIGNAL)

	current_target = add_output_port("Current Target", PORT_TYPE_STRING)
	possible_targets = add_output_port("Possible Targets", PORT_TYPE_LIST(PORT_TYPE_ANY))
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/teleporter_control_console/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/teleporter))
		attached_console = shell
		RegisterSignal(attached_console, COMSIG_TELEPORTER_NEW_TARGET, PROC_REF(on_teleporter_new_target))
		update_targets()

/obj/item/circuit_component/teleporter_control_console/unregister_usb_parent(atom/movable/shell)
	if(attached_console)
		UnregisterSignal(attached_console, COMSIG_TELEPORTER_NEW_TARGET)
	attached_console = null
	return ..()

/obj/item/circuit_component/teleporter_control_console/input_received(datum/port/input/port)
	if(!attached_console)
		return

	if(COMPONENT_TRIGGERED_BY(set_target_trigger, port))
		var/list/targets = attached_console.get_targets()
		var/target = targets[new_target.value]
		if(!target || attached_console.calibrating || !attached_console.check_hub_connection())
			on_fail.set_output(COMPONENT_SIGNAL)
			return

		attached_console.investigate_log("Teleport location set to [target] by circuit. [parent.get_creator()]", INVESTIGATE_TELESCI)

		// Jak w ui_act: zmiana celu rozkalibrowuje hub
		var/obj/machinery/teleport/station/power_station = attached_console.power_station
		power_station.engaged = FALSE
		power_station.teleporter_hub.calibrated = FALSE
		power_station.teleporter_hub.update_icon()

		if(istype(target, /obj/machinery/teleport/station))
			var/obj/machinery/teleport/station/station = target
			attached_console.set_teleport_target(station.teleporter_hub)
			attached_console.lock_in_station(station)
		else
			attached_console.set_teleport_target(target)
		return

	if(COMPONENT_TRIGGERED_BY(update_trigger, port))
		update_targets()

/obj/item/circuit_component/teleporter_control_console/proc/on_teleporter_new_target(datum/source, atom/new_target)
	SIGNAL_HANDLER

	if(isnull(new_target))
		current_target.set_output(null)
		return

	var/list/targets = attached_console.get_targets()
	for(var/target_name in targets)
		if(targets[target_name] == new_target)
			current_target.set_output(target_name)
			return

	// Last ditch scenario, we still need a string.
	current_target.set_output(new_target.name)

/obj/item/circuit_component/teleporter_control_console/proc/update_targets()
	var/list/target_names = list()
	for(var/target in attached_console.get_targets())
		target_names |= target

	possible_targets.set_output(target_names)

// ---------------------------------------------------------------------------
// Wyrzutnia bluespace
// ---------------------------------------------------------------------------

/obj/machinery/launchpad/Initialize(mapload)
	. = ..()
	// Wyrzutnia z teczki nie dostaje portu, jak w tg
	if(stationary)
		AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/bluespace_launchpad))

/// Zwraca powód, dla którego teleport się nie uda, albo null (z tg).
/obj/machinery/launchpad/proc/teleport_checks()
	if(QDELETED(src) || !isAvailable() || !is_operational)
		return "ERROR: Launchpad not operative. Make sure the launchpad is ready and powered."

	if(teleporting)
		return "ERROR: Launchpad busy."

	var/area/surrounding = get_area(src)
	if(is_centcom_level(z) || istype(surrounding, /area/shuttle/supply) || istype(surrounding, /area/shuttle/transport))
		return "ERROR: Launchpad not operative. Heavy area shielding makes teleporting impossible."

	return null

/obj/item/circuit_component/bluespace_launchpad
	display_name = "Bluespace Launchpad"
	desc = "Teleportuje cokolwiek do i z dowolnego miejsca na stacji. Nie używa współrzędnych GPS, tylko przesunięcia względem samej wyrzutni. Zasięg zależy od jej części."

	var/datum/port/input/x_pos
	var/datum/port/input/y_pos
	var/datum/port/input/send_trigger
	var/datum/port/input/retrieve_trigger

	var/datum/port/output/sent
	var/datum/port/output/retrieved
	var/datum/port/output/on_fail
	var/datum/port/output/why_fail

	var/obj/machinery/launchpad/attached_launchpad

/obj/item/circuit_component/bluespace_launchpad/get_ui_notices()
	. = ..()

	if(isnull(attached_launchpad))
		return

	. += create_ui_notice("Minimalny zasięg: [-attached_launchpad.range]", "orange", "minus")
	. += create_ui_notice("Maksymalny zasięg: [attached_launchpad.range]", "orange", "plus")

/obj/item/circuit_component/bluespace_launchpad/populate_ports()
	x_pos = add_input_port("X offset", PORT_TYPE_NUMBER)
	y_pos = add_input_port("Y offset", PORT_TYPE_NUMBER)
	send_trigger = add_input_port("Send", PORT_TYPE_SIGNAL)
	retrieve_trigger = add_input_port("Retrieve", PORT_TYPE_SIGNAL)

	sent = add_output_port("Sent", PORT_TYPE_SIGNAL)
	retrieved = add_output_port("Retrieved", PORT_TYPE_SIGNAL)
	why_fail = add_output_port("Fail reason", PORT_TYPE_STRING)
	on_fail = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/bluespace_launchpad/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/launchpad))
		attached_launchpad = shell

/obj/item/circuit_component/bluespace_launchpad/unregister_usb_parent(atom/movable/shell)
	attached_launchpad = null
	return ..()

/obj/item/circuit_component/bluespace_launchpad/input_received(datum/port/input/port)
	if(!attached_launchpad)
		why_fail.set_output("Not connected!")
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	if(abs(x_pos.value) > attached_launchpad.range || abs(y_pos.value) > attached_launchpad.range)
		why_fail.set_output("Out of range!")
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	attached_launchpad.set_offset(x_pos.value, y_pos.value)

	if(COMPONENT_TRIGGERED_BY(port, x_pos))
		x_pos.set_value(attached_launchpad.x_offset)
		return

	if(COMPONENT_TRIGGERED_BY(port, y_pos))
		y_pos.set_value(attached_launchpad.y_offset)
		return

	var/checks = attached_launchpad.teleport_checks()
	if(!isnull(checks))
		why_fail.set_output(checks)
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	if(COMPONENT_TRIGGERED_BY(send_trigger, port))
		attached_launchpad.investigate_log("Launchpad send triggered by circuit. [parent.get_creator()]", INVESTIGATE_TELESCI)
		INVOKE_ASYNC(attached_launchpad, TYPE_PROC_REF(/obj/machinery/launchpad, doteleport), null, TRUE)
		sent.set_output(COMPONENT_SIGNAL)

	if(COMPONENT_TRIGGERED_BY(retrieve_trigger, port))
		attached_launchpad.investigate_log("Launchpad retrieve triggered by circuit. [parent.get_creator()]", INVESTIGATE_TELESCI)
		INVOKE_ASYNC(attached_launchpad, TYPE_PROC_REF(/obj/machinery/launchpad, doteleport), null, FALSE)
		retrieved.set_output(COMPONENT_SIGNAL)

// Konsola wyrzutni

/obj/machinery/computer/launchpad/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/bluespace_launchpad/console))

/obj/item/circuit_component/bluespace_launchpad/console
	display_name = "Bluespace Launchpad Console"
	desc = "Teleportuje cokolwiek do i z dowolnego miejsca na stacji przez wyrzutnię podłączoną do konsoli. Nie używa współrzędnych GPS, tylko przesunięcia względem wyrzutni. Zasięg zależy od jej części."

	var/datum/port/input/launchpad_id

	var/obj/machinery/computer/launchpad/attached_console

/obj/item/circuit_component/bluespace_launchpad/console/populate_ports()
	launchpad_id = add_input_port("Launchpad ID", PORT_TYPE_NUMBER, trigger = null, default = 1)
	..()

/obj/item/circuit_component/bluespace_launchpad/console/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/computer/launchpad))
		attached_console = shell

/obj/item/circuit_component/bluespace_launchpad/console/unregister_usb_parent(atom/movable/shell)
	attached_console = null
	return ..()

/obj/item/circuit_component/bluespace_launchpad/console/input_received(datum/port/input/port)
	if(!attached_console || !length(attached_console.launchpads))
		why_fail.set_output("No launchpads connected!")
		on_fail.set_output(COMPONENT_SIGNAL)
		return

	if(!launchpad_id.value)
		return

	var/pad_index = round(launchpad_id.value)
	if(pad_index < 1 || pad_index > length(attached_console.launchpads))
		attached_launchpad = null
	else
		attached_launchpad = attached_console.launchpads[pad_index]

	if(QDELETED(attached_launchpad))
		attached_launchpad = null
		why_fail.set_output("Invalid launchpad selected!")
		on_fail.set_output(COMPONENT_SIGNAL)
		return
	..()

// ---------------------------------------------------------------------------
// Pad kwantowy
// ---------------------------------------------------------------------------

/obj/machinery/quantumpad/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/quantumpad))

/obj/item/circuit_component/quantumpad
	display_name = "Quantum Pad"
	desc = "Pad teleportacyjny splątany kwantowo, przerzuca obiekty na inne pady kwantowe."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/input/target_pad
	var/datum/port/output/failed

	var/obj/machinery/quantumpad/attached_pad

/obj/item/circuit_component/quantumpad/populate_ports()
	target_pad = add_input_port("Target Pad", PORT_TYPE_ATOM)
	failed = add_output_port("On Fail", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/quantumpad/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/quantumpad))
		attached_pad = shell

/obj/item/circuit_component/quantumpad/unregister_usb_parent(atom/movable/shell)
	attached_pad = null
	return ..()

/obj/item/circuit_component/quantumpad/input_received(datum/port/input/port)
	if(!attached_pad)
		return

	var/obj/machinery/quantumpad/targeted_pad = target_pad.value

	if((!attached_pad.linked_pad || QDELETED(attached_pad.linked_pad)) && !(targeted_pad && istype(targeted_pad)))
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(world.time < attached_pad.last_teleport + attached_pad.teleport_cooldown)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(attached_pad.machine_stat & NOPOWER)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(targeted_pad && istype(targeted_pad))
		if(attached_pad.teleporting || targeted_pad.teleporting)
			failed.set_output(COMPONENT_SIGNAL)
			return

		if(targeted_pad.machine_stat & NOPOWER)
			failed.set_output(COMPONENT_SIGNAL)
			return
		attached_pad.doteleport(target_pad = targeted_pad)
	else
		if(attached_pad.teleporting || attached_pad.linked_pad.teleporting)
			failed.set_output(COMPONENT_SIGNAL)
			return

		if(attached_pad.linked_pad.machine_stat & NOPOWER)
			failed.set_output(COMPONENT_SIGNAL)
			return
		attached_pad.doteleport(target_pad = attached_pad.linked_pad)
