// Porty USB z tg dla atmosu i urządzeń ściennych: alarm powietrza, pompy, licznik, alarm pożarowy,
// włącznik światła, wyświetlacz statusu i czytnik funkcji życiowych.
// Nasze maszyny przełączają stan wprost (`on = !on` w wielu miejscach), więc sygnały wysyłamy
// z nadpisań procków odświeżających ikonę, a komponenty odrzucają powtórzenia.

// Tryby alarmu powietrza (w airalarm.dm są #undef na końcu pliku)
#define AQ_AALARM_MODE_SCRUBBING 1
#define AQ_AALARM_MODE_VENTING 2
#define AQ_AALARM_MODE_PANIC 3
#define AQ_AALARM_MODE_REPLACEMENT 4
#define AQ_AALARM_MODE_OFF 5
#define AQ_AALARM_MODE_SIPHON 7
#define AQ_AALARM_MODE_CONTAMINATED 8
#define AQ_AALARM_MODE_REFILL 9

// Bity kontroli ciśnienia wentylacji (EXT_BOUND/INT_BOUND z vent_pump.dm)
#define AQ_VENT_EXT_BOUND 1
#define AQ_VENT_INT_BOUND 2
#define AQ_VENT_MAX_PRESSURE (ONE_ATMOSPHERE * 50)

/// Zwraca listę id_tag urządzeń z listy obszaru (air_vent_names/air_scrub_names)
/proc/aq_circuit_id_tags(list/names)
	var/list/tags = list()
	for(var/id_tag in names)
		tags += id_tag
	return tags

// ============================================================================
// Alarm powietrza
// ============================================================================

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/air_alarm_general,
		/obj/item/circuit_component/air_alarm,
		/obj/item/circuit_component/air_alarm_scrubbers,
		/obj/item/circuit_component/air_alarm_vents,
	))

/obj/machinery/airalarm/apply_mode(atom/signal_source)
	. = ..()
	SEND_SIGNAL(src, COMSIG_AIRALARM_UPDATE_MODE, signal_source)

/obj/machinery/airalarm/post_alert(alert_level)
	. = ..()
	SEND_SIGNAL(src, COMSIG_AIRALARM_ALERT_POSTED, alert_level)

/// Wysyła rozkaz do urządzenia, jeśli należy do obszaru alarmu i słucha na jego częstotliwości
/obj/machinery/airalarm/proc/circuit_send_to_device(id_tag, list/command, atom/user, scrubber = FALSE)
	var/area/our_area = get_area(src)
	if(!our_area || !id_tag)
		return FALSE
	var/list/names = scrubber ? our_area.air_scrub_names : our_area.air_vent_names
	if(!(id_tag in names))
		return FALSE
	return send_signal(id_tag, command, user)

/// Ostatni znany stan urządzenia (z jego rozgłoszenia)
/obj/machinery/airalarm/proc/circuit_device_info(id_tag, scrubber = FALSE)
	var/area/our_area = get_area(src)
	if(!our_area || !id_tag)
		return null
	var/list/info = scrubber ? our_area.air_scrub_info[id_tag] : our_area.air_vent_info[id_tag]
	if(!info || info["frequency"] != frequency)
		return null
	return info

/obj/item/circuit_component/air_alarm_general
	display_name = "Air Alarm"
	desc = "Podaje podstawowe informacje zapisane przez alarm powietrza i pozwala zmienić jego tryb."

	var/obj/machinery/airalarm/connected_alarm

	/// Włącza alarm atmosferyczny
	var/datum/port/input/enable_fire_alarm
	/// Wyłącza alarm atmosferyczny
	var/datum/port/input/disable_fire_alarm

	/// Tryb do ustawienia
	var/datum/port/input/option/mode
	/// Ustawia tryb
	var/datum/port/input/set_mode

	/// Czy alarm jest włączony
	var/datum/port/output/fire_alarm_enabled
	/// Obecny tryb
	var/datum/port/output/current_mode

	var/static/list/options_map = list(
		"Filtering" = AQ_AALARM_MODE_SCRUBBING,
		"Contaminated" = AQ_AALARM_MODE_CONTAMINATED,
		"Draught" = AQ_AALARM_MODE_VENTING,
		"Refill" = AQ_AALARM_MODE_REFILL,
		"Cycle" = AQ_AALARM_MODE_REPLACEMENT,
		"Siphon" = AQ_AALARM_MODE_SIPHON,
		"Panic Siphon" = AQ_AALARM_MODE_PANIC,
		"Off" = AQ_AALARM_MODE_OFF,
	)

/obj/item/circuit_component/air_alarm_general/populate_options()
	mode = add_option_port("Mode", options_map, order = 1)

/obj/item/circuit_component/air_alarm_general/populate_ports()
	set_mode = add_input_port("Set Mode", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_mode))
	enable_fire_alarm = add_input_port("Enable Alarm", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_alarm))
	disable_fire_alarm = add_input_port("Disable Alarm", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_alarm))

	fire_alarm_enabled = add_output_port("Alarm Enabled", PORT_TYPE_NUMBER)
	current_mode = add_output_port("Current Mode", PORT_TYPE_STRING)

/obj/item/circuit_component/air_alarm_general/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		RegisterSignal(shell, COMSIG_AIRALARM_UPDATE_MODE, PROC_REF(on_mode_updated))
		RegisterSignal(shell, COMSIG_AIRALARM_ALERT_POSTED, PROC_REF(on_alert_posted))
		current_mode.set_value(mode_name(connected_alarm.mode))
		var/area/alarm_area = get_area(connected_alarm)
		fire_alarm_enabled.set_value(alarm_area?.atmosalm ? TRUE : FALSE)

/obj/item/circuit_component/air_alarm_general/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	UnregisterSignal(shell, list(COMSIG_AIRALARM_UPDATE_MODE, COMSIG_AIRALARM_ALERT_POSTED))
	return ..()

/obj/item/circuit_component/air_alarm_general/proc/mode_name(mode_value)
	for(var/name in options_map)
		if(options_map[name] == mode_value)
			return name
	return "Flood"

/obj/item/circuit_component/air_alarm_general/proc/on_mode_updated(obj/machinery/airalarm/alarm, atom/signal_source)
	SIGNAL_HANDLER
	current_mode.set_value(mode_name(alarm.mode))

/obj/item/circuit_component/air_alarm_general/proc/on_alert_posted(obj/machinery/airalarm/alarm, alert_level)
	SIGNAL_HANDLER
	fire_alarm_enabled.set_output(alert_level > 0 ? TRUE : FALSE)

/obj/item/circuit_component/air_alarm_general/proc/trigger_alarm(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked || connected_alarm.buildstage != 2)
		return

	var/area/alarm_area = get_area(connected_alarm)
	if(!alarm_area)
		return
	if(port == enable_fire_alarm)
		if(alarm_area.atmosalert(TRUE, connected_alarm))
			connected_alarm.post_alert(2)
	else
		if(alarm_area.atmosalert(FALSE, connected_alarm))
			connected_alarm.post_alert(0)
	connected_alarm.update_icon()

/obj/item/circuit_component/air_alarm_general/proc/set_mode(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked || connected_alarm.buildstage != 2)
		return

	if(!mode.value || !(mode.value in options_map))
		return

	connected_alarm.mode = options_map[mode.value]
	connected_alarm.investigate_log("was turned to [connected_alarm.get_mode_name(connected_alarm.mode)] mode by [parent.get_creator()]", INVESTIGATE_ATMOS)
	connected_alarm.apply_mode(connected_alarm)
	connected_alarm.update_icon()
	connected_alarm.ui_update()

/obj/item/circuit_component/air_alarm
	display_name = "Air Alarm Core Control"
	desc = "Steruje progami gazów i temperatury w pomieszczeniu oraz odczytuje stan powietrza."

	var/datum/port/input/option/air_alarm_options

	var/datum/port/input/min_2
	var/datum/port/input/min_1
	var/datum/port/input/max_1
	var/datum/port/input/max_2

	var/datum/port/input/set_data
	var/datum/port/input/request_data

	var/datum/port/output/pressure
	var/datum/port/output/temperature
	var/datum/port/output/gas_amount
	var/datum/port/output/update_received

	var/obj/machinery/airalarm/connected_alarm
	var/list/options_map

	ui_buttons = list(
		"plus" = "add_new_component"
	)

	var/list/alarm_duplicates = list()
	var/max_alarm_duplicates = 20

/obj/item/circuit_component/air_alarm/ui_perform_action(mob/user, action)
	if(length(alarm_duplicates) >= max_alarm_duplicates)
		return

	if(action == "add_new_component")
		var/obj/item/circuit_component/air_alarm/component = new /obj/item/circuit_component/air_alarm/duplicate(parent)
		parent.add_component(component)
		RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_duplicate_removed))
		component.connected_alarm = connected_alarm
		alarm_duplicates += component

/obj/item/circuit_component/air_alarm/proc/on_duplicate_removed(datum/source)
	SIGNAL_HANDLER
	alarm_duplicates -= source

/obj/item/circuit_component/air_alarm/populate_ports()
	min_2 = add_input_port("Hazard Minimum", PORT_TYPE_NUMBER, trigger = null)
	min_1 = add_input_port("Warning Minimum", PORT_TYPE_NUMBER, trigger = null)
	max_1 = add_input_port("Warning Maximum", PORT_TYPE_NUMBER, trigger = null)
	max_2 = add_input_port("Hazard Maximum", PORT_TYPE_NUMBER, trigger = null)
	set_data = add_input_port("Set Limits", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_limits))
	request_data = add_input_port("Request Data", PORT_TYPE_SIGNAL)

	pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)
	gas_amount = add_output_port("Chosen Gas Amount", PORT_TYPE_NUMBER)
	update_received = add_output_port("Update Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/air_alarm/populate_options()
	var/static/list/component_options

	if(!component_options)
		component_options = list(
			"Pressure" = "pressure",
			"Temperature" = "temperature"
		)
		for(var/gas_id in GLOB.gas_data.ids)
			component_options[GLOB.gas_data.names[gas_id]] = gas_id

	air_alarm_options = add_option_port("Air Alarm Options", component_options)
	options_map = component_options

/obj/item/circuit_component/air_alarm/duplicate
	display_name = "Air Alarm Control"

	circuit_size = 0
	ui_buttons = list()

/obj/item/circuit_component/air_alarm/duplicate/removed_from(obj/item/integrated_circuit/removed_from)
	if(!QDELING(src))
		qdel(src)
	return ..()

/obj/item/circuit_component/air_alarm/duplicate/Destroy()
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm/removed_from(obj/item/integrated_circuit/removed_from)
	QDEL_LIST(alarm_duplicates)
	return ..()

/obj/item/circuit_component/air_alarm/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		for(var/obj/item/circuit_component/air_alarm/alarm as anything in alarm_duplicates)
			alarm.connected_alarm = connected_alarm

/obj/item/circuit_component/air_alarm/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	for(var/obj/item/circuit_component/air_alarm/alarm as anything in alarm_duplicates)
		alarm.connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm/proc/set_limits()
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked)
		return

	var/current_option = air_alarm_options.value
	if(!current_option)
		return

	var/datum/tlv/settings = connected_alarm.TLV[options_map[current_option]]
	if(!settings)
		return
	if(min_2.value != null)
		settings.min2 = min_2.value
	if(min_1.value != null)
		settings.min1 = min_1.value
	if(max_1.value != null)
		settings.max1 = max_1.value
	if(max_2.value != null)
		settings.max2 = max_2.value
	connected_alarm.investigate_log("thresholds for [current_option] were set by [parent.get_creator()]", INVESTIGATE_ATMOS)
	connected_alarm.ui_update()

/obj/item/circuit_component/air_alarm/input_received(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/turf/alarm_turf = get_turf(connected_alarm)
	var/datum/gas_mixture/environment = alarm_turf?.return_air()
	if(!environment)
		return

	var/current_option = options_map[air_alarm_options.value]
	pressure.set_output(round(environment.return_pressure()))
	temperature.set_output(round(environment.return_temperature()))
	if(current_option && current_option != "pressure" && current_option != "temperature")
		gas_amount.set_output(round(environment.get_moles(current_option)))

	update_received.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/air_alarm_scrubbers
	display_name = "Air Alarm Scrubber Core Control"
	desc = "Steruje scrubberami w pomieszczeniu alarmu powietrza."

	var/datum/port/input/option/scrubbers

	var/datum/port/input/enable
	var/datum/port/input/disable
	var/datum/port/input/enable_siphon
	var/datum/port/input/disable_siphon
	var/datum/port/input/enable_extended_range
	var/datum/port/input/disable_extended_range
	/// Gazy do filtrowania (id gazów)
	var/datum/port/input/gas_filter
	var/datum/port/input/set_gas_filter
	var/datum/port/input/request_update

	var/datum/port/output/enabled
	var/datum/port/output/is_siphoning
	/// Filtrowane gazy
	var/datum/port/output/filtering
	var/datum/port/output/update_received

	var/obj/machinery/airalarm/connected_alarm

	ui_buttons = list(
		"plus" = "add_new_component"
	)

	var/max_scrubber_duplicates = 20
	var/list/scrubber_duplicates = list()

/obj/item/circuit_component/air_alarm_scrubbers/ui_perform_action(mob/user, action)
	if(length(scrubber_duplicates) >= max_scrubber_duplicates)
		return

	if(action == "add_new_component")
		var/obj/item/circuit_component/air_alarm_scrubbers/component = new /obj/item/circuit_component/air_alarm_scrubbers/duplicate(parent)
		parent.add_component(component)
		RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_duplicate_removed))
		component.connected_alarm = connected_alarm
		component.refresh_options()
		scrubber_duplicates += component

/obj/item/circuit_component/air_alarm_scrubbers/proc/on_duplicate_removed(datum/source)
	SIGNAL_HANDLER
	scrubber_duplicates -= source

/obj/item/circuit_component/air_alarm_scrubbers/proc/refresh_options()
	var/area/alarm_area = connected_alarm ? get_area(connected_alarm) : null
	scrubbers.possible_options = alarm_area ? aq_circuit_id_tags(alarm_area.air_scrub_names) : null

/obj/item/circuit_component/air_alarm_scrubbers/populate_options()
	scrubbers = add_option_port("Scrubber", null)

/obj/item/circuit_component/air_alarm_scrubbers/populate_ports()
	gas_filter = add_input_port("Gas To Filter", PORT_TYPE_LIST(PORT_TYPE_STRING), trigger = null)
	set_gas_filter = add_input_port("Set Filter", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_gas_to_filter))
	enable_extended_range = add_input_port("Enable Extra Range", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_range))
	disable_extended_range = add_input_port("Disable Extra Range", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_range))
	enable_siphon = add_input_port("Enable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	disable_siphon = add_input_port("Disable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	enable = add_input_port("Enable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_scrubber))
	disable = add_input_port("Disable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_scrubber))
	request_update = add_input_port("Request Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(update_data))

	enabled = add_output_port("Enabled", PORT_TYPE_BOOLEAN)
	is_siphoning = add_output_port("Siphoning", PORT_TYPE_BOOLEAN)
	filtering = add_output_port("Filtered Gases", PORT_TYPE_LIST(PORT_TYPE_STRING))
	update_received = add_output_port("Update Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/air_alarm_scrubbers/duplicate
	display_name = "Air Alarm Scrubber Control"
	circuit_size = 0
	ui_buttons = list()

/obj/item/circuit_component/air_alarm_scrubbers/duplicate/Destroy()
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/duplicate/removed_from(obj/item/integrated_circuit/removed_from)
	if(!QDELING(src))
		qdel(src)
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/removed_from(obj/item/integrated_circuit/removed_from)
	QDEL_LIST(scrubber_duplicates)
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		refresh_options()
		for(var/obj/item/circuit_component/air_alarm_scrubbers/scrubber as anything in scrubber_duplicates)
			scrubber.connected_alarm = connected_alarm
			scrubber.refresh_options()

/obj/item/circuit_component/air_alarm_scrubbers/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	scrubbers.possible_options = null
	for(var/obj/item/circuit_component/air_alarm_scrubbers/scrubber as anything in scrubber_duplicates)
		scrubber.connected_alarm = null
		scrubber.scrubbers.possible_options = null
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/get_ui_notices()
	. = ..()
	. += create_table_notices(GLOB.gas_data.ids, column_name = "Gas", column_name_plural = "Gases")

/obj/item/circuit_component/air_alarm_scrubbers/proc/can_control()
	return connected_alarm && !connected_alarm.locked && connected_alarm.buildstage == 2

/obj/item/circuit_component/air_alarm_scrubbers/proc/set_gas_to_filter(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return

	var/list/valid_filters = list()
	for(var/info in gas_filter.value)
		if(info in GLOB.gas_data.ids)
			valid_filters |= info

	connected_alarm.circuit_send_to_device(scrubbers.value, list("set_filters" = valid_filters), parent.get_creator(), scrubber = TRUE)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_scrubber(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	connected_alarm.circuit_send_to_device(scrubbers.value, list("power" = (port == enable) ? 1 : 0), parent.get_creator(), scrubber = TRUE)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_range(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	connected_alarm.circuit_send_to_device(scrubbers.value, list("widenet" = (port == enable_extended_range) ? 1 : 0), parent.get_creator(), scrubber = TRUE)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_siphon(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	connected_alarm.circuit_send_to_device(scrubbers.value, list("scrubbing" = (port == enable_siphon) ? 0 : 1), parent.get_creator(), scrubber = TRUE)

/obj/item/circuit_component/air_alarm_scrubbers/proc/update_data()
	CIRCUIT_TRIGGER
	if(!can_control())
		return

	var/list/info = connected_alarm.circuit_device_info(scrubbers.value, scrubber = TRUE)
	if(!info)
		return

	enabled.set_value(info["power"] ? TRUE : FALSE)
	is_siphoning.set_value(info["scrubbing"] ? FALSE : TRUE)

	var/list/filtered = list()
	for(var/list/gas_info as anything in info["filter_types"])
		if(gas_info["enabled"])
			filtered += gas_info["gas_id"]
	filtering.set_value(filtered)

	update_received.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/air_alarm_vents
	display_name = "Air Alarm Vent Core Control"
	desc = "Steruje wentylacją w pomieszczeniu alarmu powietrza."

	var/datum/port/input/option/vents

	var/datum/port/input/enable
	var/datum/port/input/disable
	var/datum/port/input/enable_siphon
	var/datum/port/input/disable_siphon
	var/datum/port/input/enable_external
	var/datum/port/input/disable_external
	var/datum/port/input/external_pressure
	var/datum/port/input/enable_internal
	var/datum/port/input/disable_internal
	var/datum/port/input/internal_pressure
	var/datum/port/input/request_update

	var/datum/port/output/enabled
	var/datum/port/output/is_siphoning
	var/datum/port/output/internal_on
	var/datum/port/output/external_on
	var/datum/port/output/current_external_pressure
	var/datum/port/output/current_internal_pressure
	var/datum/port/output/update_received

	var/obj/machinery/airalarm/connected_alarm

	ui_buttons = list(
		"plus" = "add_new_component"
	)

	var/max_vent_duplicates = 20
	var/list/vent_duplicates = list()

/obj/item/circuit_component/air_alarm_vents/ui_perform_action(mob/user, action)
	if(length(vent_duplicates) >= max_vent_duplicates)
		return

	if(action == "add_new_component")
		var/obj/item/circuit_component/air_alarm_vents/component = new /obj/item/circuit_component/air_alarm_vents/duplicate(parent)
		parent.add_component(component)
		RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_duplicate_removed))
		vent_duplicates += component
		component.connected_alarm = connected_alarm
		component.refresh_options()

/obj/item/circuit_component/air_alarm_vents/proc/on_duplicate_removed(datum/source)
	SIGNAL_HANDLER
	vent_duplicates -= source

/obj/item/circuit_component/air_alarm_vents/proc/refresh_options()
	var/area/alarm_area = connected_alarm ? get_area(connected_alarm) : null
	vents.possible_options = alarm_area ? aq_circuit_id_tags(alarm_area.air_vent_names) : null

/obj/item/circuit_component/air_alarm_vents/populate_options()
	vents = add_option_port("Vent", null)

/obj/item/circuit_component/air_alarm_vents/populate_ports()
	external_pressure = add_input_port("External Pressure", PORT_TYPE_NUMBER, trigger = PROC_REF(set_external_pressure))
	internal_pressure = add_input_port("Internal Pressure", PORT_TYPE_NUMBER, trigger = PROC_REF(set_internal_pressure))

	enable_external = add_input_port("Enable External", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_external))
	disable_external = add_input_port("Disable External", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_external))
	enable_internal = add_input_port("Enable Internal", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_internal))
	disable_internal = add_input_port("Disable Internal", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_internal))

	enable_siphon = add_input_port("Enable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	disable_siphon = add_input_port("Disable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	enable = add_input_port("Enable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_vent))
	disable = add_input_port("Disable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_vent))
	request_update = add_input_port("Request Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(update_data))

	enabled = add_output_port("Enabled", PORT_TYPE_BOOLEAN)
	is_siphoning = add_output_port("Siphoning", PORT_TYPE_BOOLEAN)
	external_on = add_output_port("External On", PORT_TYPE_BOOLEAN)
	internal_on = add_output_port("Internal On", PORT_TYPE_BOOLEAN)
	current_external_pressure = add_output_port("External Pressure", PORT_TYPE_NUMBER)
	current_internal_pressure = add_output_port("Internal Pressure", PORT_TYPE_NUMBER)
	update_received = add_output_port("Update Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/air_alarm_vents/duplicate
	display_name = "Air Alarm Vent Control"

	circuit_size = 0
	ui_buttons = list()

/obj/item/circuit_component/air_alarm_vents/duplicate/removed_from(obj/item/integrated_circuit/removed_from)
	if(!QDELING(src))
		qdel(src)
	return ..()

/obj/item/circuit_component/air_alarm_vents/duplicate/Destroy()
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm_vents/removed_from(obj/item/integrated_circuit/removed_from)
	QDEL_LIST(vent_duplicates)
	return ..()

/obj/item/circuit_component/air_alarm_vents/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		refresh_options()
		for(var/obj/item/circuit_component/air_alarm_vents/vent as anything in vent_duplicates)
			vent.connected_alarm = connected_alarm
			vent.refresh_options()

/obj/item/circuit_component/air_alarm_vents/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	vents.possible_options = null
	for(var/obj/item/circuit_component/air_alarm_vents/vent as anything in vent_duplicates)
		vent.connected_alarm = null
		vent.vents.possible_options = null
	return ..()

/obj/item/circuit_component/air_alarm_vents/proc/can_control()
	return connected_alarm && !connected_alarm.locked && connected_alarm.buildstage == 2

/obj/item/circuit_component/air_alarm_vents/proc/send_command(list/command)
	return connected_alarm.circuit_send_to_device(vents.value, command, parent.get_creator())

/// Zmienia jeden bit kontroli ciśnienia na podstawie ostatniego znanego stanu wentylacji
/obj/item/circuit_component/air_alarm_vents/proc/set_check_bit(bit, enable_bit)
	var/list/info = connected_alarm.circuit_device_info(vents.value)
	if(!info)
		return
	var/checks = text2num("[info["checks"]]") || 0
	if(enable_bit)
		checks |= bit
	else
		checks &= ~bit
	send_command(list("checks" = checks))

/obj/item/circuit_component/air_alarm_vents/proc/toggle_vent(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	send_command(list("power" = (port == enable) ? 1 : 0))

/obj/item/circuit_component/air_alarm_vents/proc/toggle_external(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	set_check_bit(AQ_VENT_EXT_BOUND, port == enable_external)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_internal(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	set_check_bit(AQ_VENT_INT_BOUND, port == enable_internal)

/obj/item/circuit_component/air_alarm_vents/proc/set_internal_pressure(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control() || isnull(internal_pressure.value))
		return
	send_command(list("set_internal_pressure" = clamp(internal_pressure.value, 0, AQ_VENT_MAX_PRESSURE)))

/obj/item/circuit_component/air_alarm_vents/proc/set_external_pressure(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control() || isnull(external_pressure.value))
		return
	send_command(list("set_external_pressure" = clamp(external_pressure.value, 0, AQ_VENT_MAX_PRESSURE)))

/obj/item/circuit_component/air_alarm_vents/proc/toggle_siphon(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!can_control())
		return
	// 0 = wysysanie, 1 = wypuszczanie (SIPHONING/RELEASING z vent_pump.dm)
	send_command(list("direction" = (port == enable_siphon) ? 0 : 1))

/obj/item/circuit_component/air_alarm_vents/proc/update_data()
	CIRCUIT_TRIGGER
	if(!can_control())
		return

	var/list/info = connected_alarm.circuit_device_info(vents.value)
	if(!info)
		return

	var/checks = text2num("[info["checks"]]") || 0
	enabled.set_value(info["power"] ? TRUE : FALSE)
	is_siphoning.set_value(info["direction"] == "siphon")
	internal_on.set_value((checks & AQ_VENT_INT_BOUND) ? TRUE : FALSE)
	current_internal_pressure.set_value(info["internal"])
	external_on.set_value((checks & AQ_VENT_EXT_BOUND) ? TRUE : FALSE)
	current_external_pressure.set_value(info["external"])
	update_received.set_output(COMPONENT_SIGNAL)

// ============================================================================
// Pompa ciśnieniowa i objętościowa
// ============================================================================

/obj/machinery/atmospherics/components/binary/pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/atmos_pump))

// Pompy przełączają `on` wprost w wielu miejscach, a każde kończy się odświeżeniem ikony
/obj/machinery/atmospherics/components/binary/pump/update_icon_nopipes()
	. = ..()
	SEND_SIGNAL(src, COMSIG_ATMOS_MACHINE_SET_ON, on)

/obj/machinery/atmospherics/components/binary/volume_pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/atmos_volume_pump))

/obj/machinery/atmospherics/components/binary/volume_pump/update_icon_nopipes()
	. = ..()
	SEND_SIGNAL(src, COMSIG_ATMOS_MACHINE_SET_ON, on)

/obj/item/circuit_component/atmos_pump
	display_name = "Atmospheric Binary Pump"
	desc = "Interfejs do sterowania pompą ciśnieniową."

	///Ustawia docelowe ciśnienie pompy
	var/datum/port/input/pressure_value
	///Włącza pompę
	var/datum/port/input/on
	///Wyłącza pompę
	var/datum/port/input/off
	///Odczytuje ciśnienie i temperaturę na portach pompy
	var/datum/port/input/request_data

	var/datum/port/output/input_pressure
	var/datum/port/output/output_pressure
	var/datum/port/output/input_temperature
	var/datum/port/output/output_temperature

	///Czy pompa pracuje
	var/datum/port/output/is_active
	var/datum/port/output/turned_on
	var/datum/port/output/turned_off

	var/obj/machinery/atmospherics/components/binary/pump/connected_pump

/obj/item/circuit_component/atmos_pump/populate_ports()
	pressure_value = add_input_port("New Pressure", PORT_TYPE_NUMBER, trigger = PROC_REF(set_pump_pressure))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	input_pressure = add_output_port("Input Pressure", PORT_TYPE_NUMBER)
	output_pressure = add_output_port("Output Pressure", PORT_TYPE_NUMBER)
	input_temperature = add_output_port("Input Temperature", PORT_TYPE_NUMBER)
	output_temperature = add_output_port("Output Temperature", PORT_TYPE_NUMBER)

	is_active = add_output_port("Active", PORT_TYPE_BOOLEAN)
	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/atmos_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/binary/pump))
		connected_pump = shell
		is_active.set_value(connected_pump.on ? TRUE : FALSE)
		RegisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/atmos_pump/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ATMOS_MACHINE_SET_ON)
	connected_pump = null
	return ..()

/obj/item/circuit_component/atmos_pump/pre_input_received(datum/port/input/port)
	pressure_value.set_value(clamp(pressure_value.value, 0, MAX_OUTPUT_PRESSURE))

/obj/item/circuit_component/atmos_pump/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	active = active ? TRUE : FALSE
	if(active == is_active.value)
		return
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/atmos_pump/proc/set_pump_pressure()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.target_pressure = pressure_value.value
	connected_pump.investigate_log("was set to [connected_pump.target_pressure] kPa by [parent.get_creator()]", INVESTIGATE_ATMOS)
	connected_pump.ui_update()

/obj/item/circuit_component/atmos_pump/proc/set_pump_on()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(TRUE)
	connected_pump.ui_update()

/obj/item/circuit_component/atmos_pump/proc/set_pump_off()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(FALSE)
	connected_pump.ui_update()

/obj/item/circuit_component/atmos_pump/proc/request_pump_data()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	var/datum/gas_mixture/air_input = connected_pump.airs[1]
	var/datum/gas_mixture/air_output = connected_pump.airs[2]
	input_pressure.set_output(air_input.return_pressure())
	output_pressure.set_output(air_output.return_pressure())
	input_temperature.set_output(air_input.return_temperature())
	output_temperature.set_output(air_output.return_temperature())

/obj/item/circuit_component/atmos_volume_pump
	display_name = "Atmospheric Volume Pump"
	desc = "Interfejs do sterowania pompą objętościową."

	///Ustawia przepływ pompy
	var/datum/port/input/transfer_rate
	var/datum/port/input/on
	var/datum/port/input/off
	var/datum/port/input/request_data

	var/datum/port/output/input_pressure
	var/datum/port/output/output_pressure
	var/datum/port/output/input_temperature
	var/datum/port/output/output_temperature

	var/datum/port/output/is_active
	var/datum/port/output/turned_on
	var/datum/port/output/turned_off

	var/obj/machinery/atmospherics/components/binary/volume_pump/connected_pump

/obj/item/circuit_component/atmos_volume_pump/populate_ports()
	transfer_rate = add_input_port("New Transfer Rate", PORT_TYPE_NUMBER, trigger = PROC_REF(set_transfer_rate))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	input_pressure = add_output_port("Input Pressure", PORT_TYPE_NUMBER)
	output_pressure = add_output_port("Output Pressure", PORT_TYPE_NUMBER)
	input_temperature = add_output_port("Input Temperature", PORT_TYPE_NUMBER)
	output_temperature = add_output_port("Output Temperature", PORT_TYPE_NUMBER)

	is_active = add_output_port("Active", PORT_TYPE_BOOLEAN)
	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/atmos_volume_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/binary/volume_pump))
		connected_pump = shell
		is_active.set_value(connected_pump.on ? TRUE : FALSE)
		RegisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/atmos_volume_pump/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_ATMOS_MACHINE_SET_ON)
	connected_pump = null
	return ..()

/obj/item/circuit_component/atmos_volume_pump/pre_input_received(datum/port/input/port)
	transfer_rate.set_value(clamp(transfer_rate.value, 0, MAX_TRANSFER_RATE))

/obj/item/circuit_component/atmos_volume_pump/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	active = active ? TRUE : FALSE
	if(active == is_active.value)
		return
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/atmos_volume_pump/proc/set_transfer_rate()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.transfer_rate = transfer_rate.value
	connected_pump.investigate_log("was set to [connected_pump.transfer_rate] L/s by [parent.get_creator()]", INVESTIGATE_ATMOS)
	connected_pump.ui_update()

/obj/item/circuit_component/atmos_volume_pump/proc/set_pump_on()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(TRUE)
	connected_pump.ui_update()

/obj/item/circuit_component/atmos_volume_pump/proc/set_pump_off()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(FALSE)
	connected_pump.ui_update()

/obj/item/circuit_component/atmos_volume_pump/proc/request_pump_data()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	var/datum/gas_mixture/air_input = connected_pump.airs[1]
	var/datum/gas_mixture/air_output = connected_pump.airs[2]
	input_pressure.set_output(air_input.return_pressure())
	output_pressure.set_output(air_output.return_pressure())
	input_temperature.set_output(air_input.return_temperature())
	output_temperature.set_output(air_output.return_temperature())

// ============================================================================
// Licznik gazu
// ============================================================================

/obj/machinery/meter/Initialize(mapload, new_piping_layer)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/atmos_meter))

/obj/item/circuit_component/atmos_meter
	display_name = "Atmospheric Meter"
	desc = "Odczytuje ciśnienie i temperaturę w sieci rur."

	var/datum/port/input/request_data

	var/datum/port/output/pressure
	var/datum/port/output/temperature

	var/obj/machinery/meter/connected_meter

/obj/item/circuit_component/atmos_meter/populate_ports()
	request_data = add_input_port("Request Meter Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_meter_data))

	pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)

/obj/item/circuit_component/atmos_meter/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/meter))
		connected_meter = shell

/obj/item/circuit_component/atmos_meter/unregister_usb_parent(atom/movable/shell)
	connected_meter = null
	return ..()

/obj/item/circuit_component/atmos_meter/proc/request_meter_data()
	CIRCUIT_TRIGGER
	if(!connected_meter?.target)
		return
	var/datum/gas_mixture/environment = connected_meter.target.return_air()
	if(!environment)
		return
	pressure.set_output(environment.return_pressure())
	temperature.set_output(environment.return_temperature())

// ============================================================================
// Alarm pożarowy
// ============================================================================

/obj/machinery/firealarm
	/// Ostatni stan alarmu obszaru zgłoszony circuitom
	var/circuit_fire_state = FALSE

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/firealarm))

// Obszar odświeża ikony wszystkich swoich alarmów przy włączeniu i resecie, więc tu łapiemy każdą zmianę
/obj/machinery/firealarm/update_overlays()
	. = ..()
	var/area/our_area = get_area(src)
	var/fire_now = our_area?.fire ? TRUE : FALSE
	if(fire_now == circuit_fire_state)
		return
	circuit_fire_state = fire_now
	SEND_SIGNAL(src, fire_now ? COMSIG_FIREALARM_ON_TRIGGER : COMSIG_FIREALARM_ON_RESET)

/obj/item/circuit_component/firealarm
	display_name = "Fire Alarm"
	desc = "Pozwala sterować alarmem pożarowym."

	var/datum/port/input/alarm_trigger
	var/datum/port/input/reset_trigger

	/// Czy alarm jest włączony (0 lub 1)
	var/datum/port/output/is_on
	var/datum/port/output/triggered
	var/datum/port/output/reset

	var/obj/machinery/firealarm/attached_alarm

/obj/item/circuit_component/firealarm/populate_ports()
	alarm_trigger = add_input_port("Set", PORT_TYPE_SIGNAL)
	reset_trigger = add_input_port("Reset", PORT_TYPE_SIGNAL)

	is_on = add_output_port("Is On", PORT_TYPE_BOOLEAN)
	triggered = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	reset = add_output_port("Reset", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/firealarm/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/firealarm))
		attached_alarm = shell
		is_on.set_value(attached_alarm.circuit_fire_state)
		RegisterSignal(shell, COMSIG_FIREALARM_ON_TRIGGER, PROC_REF(on_firealarm_triggered))
		RegisterSignal(shell, COMSIG_FIREALARM_ON_RESET, PROC_REF(on_firealarm_reset))

/obj/item/circuit_component/firealarm/unregister_usb_parent(atom/movable/shell)
	attached_alarm = null
	UnregisterSignal(shell, list(COMSIG_FIREALARM_ON_TRIGGER, COMSIG_FIREALARM_ON_RESET))
	return ..()

/obj/item/circuit_component/firealarm/proc/on_firealarm_triggered(datum/source)
	SIGNAL_HANDLER
	is_on.set_output(1)
	triggered.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/firealarm/proc/on_firealarm_reset(datum/source)
	SIGNAL_HANDLER
	is_on.set_output(0)
	reset.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/firealarm/input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(alarm_trigger, port))
		attached_alarm?.alarm()

	if(COMPONENT_TRIGGERED_BY(reset_trigger, port))
		attached_alarm?.reset()

// ============================================================================
// Włącznik światła
// ============================================================================

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/light_switch))

// Każde przełączenie (ręką, przez AI moba) kończy się odświeżeniem ikon włączników w obszarze
/obj/machinery/light_switch/update_icon()
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIGHT_SWITCH_SET, area?.lightswitch)

/// Ustawia światła obszaru włącznika (z tg)
/obj/machinery/light_switch/proc/set_lights(status)
	if(!area || area.lightswitch == status)
		return
	area.lightswitch = status
	area.update_icon()
	for(var/obj/machinery/light_switch/light_switch in area)
		light_switch.update_icon()
	area.power_change()

/obj/item/circuit_component/light_switch
	display_name = "Light Switch"
	desc = "Pozwala sterować światłami w obszarze."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///Czy po wyzwoleniu światła mają być włączone
	var/datum/port/input/on_setting
	///Czy światła są włączone
	var/datum/port/output/is_on

	var/obj/machinery/light_switch/attached_switch

/obj/item/circuit_component/light_switch/populate_ports()
	on_setting = add_input_port("On", PORT_TYPE_BOOLEAN)
	is_on = add_output_port("Is On", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/light_switch/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/light_switch))
		attached_switch = shell
		is_on.set_value(attached_switch.area?.lightswitch ? TRUE : FALSE)
		RegisterSignal(shell, COMSIG_LIGHT_SWITCH_SET, PROC_REF(on_light_switch_set))

/obj/item/circuit_component/light_switch/unregister_usb_parent(atom/movable/shell)
	attached_switch = null
	UnregisterSignal(shell, COMSIG_LIGHT_SWITCH_SET)
	return ..()

/obj/item/circuit_component/light_switch/proc/on_light_switch_set(datum/source, status)
	SIGNAL_HANDLER
	status = status ? TRUE : FALSE
	if(status == is_on.value)
		return
	is_on.set_output(status)

/obj/item/circuit_component/light_switch/input_received(datum/port/input/port)
	attached_switch?.set_lights(on_setting.value ? TRUE : FALSE)

// ============================================================================
// Wyświetlacz statusu (tylko evac, jak w tg: tylko on obsługuje rozkazy przez receive_signal)
// ============================================================================

/obj/machinery/status_display/evac/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/status_display))

/obj/item/circuit_component/status_display
	display_name = "Status Display"
	desc = "Wyświetla tekst i obrazki na wyświetlaczu statusu."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/command
	var/datum/port/input/option/picture
	var/datum/port/input/message1
	var/datum/port/input/message2

	var/obj/machinery/status_display/evac/connected_display

	var/list/command_map
	var/list/picture_map

/obj/item/circuit_component/status_display/populate_ports()
	message1 = add_input_port("Message 1", PORT_TYPE_STRING)
	message2 = add_input_port("Message 2", PORT_TYPE_STRING)

/obj/item/circuit_component/status_display/populate_options()
	var/static/list/command_options = list(
		"Blank" = "blank",
		"Shuttle" = "shuttle",
		"Message" = "message",
		"Alert" = "alert"
	)

	// Tylko stany, które mamy w icons/obj/status_display.dmi (bez alarmów delta/niebieski/zielony)
	var/static/list/picture_options = list(
		"Default" = "default",
		"Red Alert" = "redalert",
		"Biohazard" = "biohazard",
		"Lockdown" = "lockdown",
		"Radiation" = "radiation",
		"Happy" = "ai_happy",
		"Neutral" = "ai_neutral",
		"Very Happy" = "ai_veryhappy",
		"Sad" = "ai_sad",
		"Unsure" = "ai_unsure",
		"Confused" = "ai_confused",
		"Surprised" = "ai_surprised",
		"BSOD" = "ai_bsod"
	)

	command = add_option_port("Command", command_options)
	command_map = command_options

	picture = add_option_port("Picture", picture_options)
	picture_map = picture_options

/obj/item/circuit_component/status_display/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/status_display/evac))
		connected_display = shell

/obj/item/circuit_component/status_display/unregister_usb_parent(atom/movable/shell)
	connected_display = null
	return ..()

/obj/item/circuit_component/status_display/input_received(datum/port/input/port)
	if(!connected_display)
		return

	var/command_value = command_map[command.value]
	var/datum/signal/status_signal = new(list("command" = command_value))
	switch(command_value)
		if("message")
			status_signal.data["top_text"] = message1.value
			status_signal.data["bottom_text"] = message2.value
		if("alert")
			status_signal.data["picture_state"] = picture_map[picture.value]

	connected_display.receive_signal(status_signal)

// ============================================================================
// Czytnik funkcji życiowych
// ============================================================================

/obj/machinery/vitals_reader/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/vitals_monitor))

/obj/machinery/vitals_reader
	/// Trwa zmiana pacjenta, unset_patient() nie zgłasza wtedy osobnej zmiany
	var/circuit_changing_patient = FALSE

/obj/machinery/vitals_reader/set_patient(mob/living/new_patient)
	var/mob/living/old_patient = patient
	circuit_changing_patient = TRUE
	. = ..()
	circuit_changing_patient = FALSE
	if(patient != old_patient)
		SEND_SIGNAL(src, COMSIG_VITALS_SET_PATIENT, old_patient, patient)

/obj/machinery/vitals_reader/unset_patient(datum/source)
	var/mob/living/old_patient = patient
	. = ..()
	if(old_patient && isnull(patient) && !circuit_changing_patient)
		SEND_SIGNAL(src, COMSIG_VITALS_SET_PATIENT, old_patient, null)

/obj/item/circuit_component/vitals_monitor
	display_name = "Vitals Monitor"
	desc = "Odczytuje stan pacjenta z monitora funkcji życiowych."

	var/obj/machinery/vitals_reader/linked_monitor

	/// Odstęp między odczytami
	var/read_cooldown_period = 4 SECONDS
	COOLDOWN_DECLARE(read_cooldown)

	var/datum/port/output/status_updated
	var/datum/port/output/patient_changed

	var/datum/port/output/patient_entity
	/// Szanse na defibrylację
	var/datum/port/output/defib_state

	var/datum/port/output/patient_brute_damage
	var/datum/port/output/patient_burn_damage
	var/datum/port/output/patient_oxy_loss
	var/datum/port/output/patient_tox_loss
	var/datum/port/output/patient_overall_health
	var/datum/port/output/patient_brain_damage
	var/datum/port/output/patient_blood_level

/obj/item/circuit_component/vitals_monitor/Destroy()
	STOP_PROCESSING(SSclock_component, src)
	return ..()

/obj/item/circuit_component/vitals_monitor/populate_ports()
	status_updated = add_output_port("Status Updated", PORT_TYPE_SIGNAL)
	patient_changed = add_output_port("Patient Changed", PORT_TYPE_SIGNAL)

	patient_entity = add_output_port("Patient", PORT_TYPE_ATOM)
	defib_state = add_output_port("Defib Status", PORT_TYPE_STRING)

	patient_overall_health = add_output_port("Overall Health", PORT_TYPE_NUMBER)
	patient_brute_damage = add_output_port("Brute Damage", PORT_TYPE_NUMBER)
	patient_burn_damage = add_output_port("Burn Damage", PORT_TYPE_NUMBER)
	patient_oxy_loss = add_output_port("Suffocation Damage", PORT_TYPE_NUMBER)
	patient_tox_loss = add_output_port("Toxin Damage", PORT_TYPE_NUMBER)
	patient_brain_damage = add_output_port("Brain Damage", PORT_TYPE_NUMBER)
	patient_blood_level = add_output_port("Blood Level", PORT_TYPE_NUMBER)

/obj/item/circuit_component/vitals_monitor/register_usb_parent(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/machinery/vitals_reader))
		return
	linked_monitor = shell
	RegisterSignal(shell, COMSIG_VITALS_SET_PATIENT, PROC_REF(handle_patient_change))
	if(!isnull(linked_monitor.patient))
		patient_entity.set_value(linked_monitor.patient)
		START_PROCESSING(SSclock_component, src)

/obj/item/circuit_component/vitals_monitor/unregister_usb_parent(atom/movable/shell)
	. = ..()
	linked_monitor = null
	UnregisterSignal(shell, COMSIG_VITALS_SET_PATIENT)
	STOP_PROCESSING(SSclock_component, src)

/obj/item/circuit_component/vitals_monitor/get_ui_notices()
	. = ..()
	. += create_ui_notice("Opóźnienie pierwszego odczytu: [DisplayTimeText(1 SECONDS)]", "orange", "clock")
	. += create_ui_notice("Odstęp odczytów: [DisplayTimeText(read_cooldown_period)]", "orange", "clock")

/obj/item/circuit_component/vitals_monitor/proc/handle_patient_change(datum/source, mob/living/old_patient, mob/living/new_patient)
	SIGNAL_HANDLER
	if(isnull(new_patient))
		STOP_PROCESSING(SSclock_component, src)
	else
		START_PROCESSING(SSclock_component, src)
	patient_entity.set_output(new_patient)
	patient_changed.set_output(COMPONENT_SIGNAL)
	COOLDOWN_START(src, read_cooldown, 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delayed_reading)), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/// Odczyt z losowym błędem, gdy monitor jest po EMP albo zemagowany
/obj/item/circuit_component/vitals_monitor/proc/patient_value(value)
	if((linked_monitor.machine_stat & EMPED) || (linked_monitor.obj_flags & EMAGGED))
		value *= rand(0, 100) * 0.01
	return round(value, DAMAGE_PRECISION)

/obj/item/circuit_component/vitals_monitor/process(delta_time)
	if(isnull(linked_monitor?.patient))
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, read_cooldown))
		return
	update_output_stats()

/obj/item/circuit_component/vitals_monitor/proc/delayed_reading()
	if(isnull(linked_monitor?.patient))
		return
	update_output_stats()

/obj/item/circuit_component/vitals_monitor/proc/update_output_stats()
	COOLDOWN_START(src, read_cooldown, read_cooldown_period)
	status_updated.set_output(COMPONENT_SIGNAL)

	var/mob/living/patient = linked_monitor.patient
	patient_overall_health.set_output(patient_value(patient.health))
	patient_brute_damage.set_output(patient_value(patient.getBruteLoss()))
	patient_burn_damage.set_output(patient_value(patient.getFireLoss()))
	patient_oxy_loss.set_output(patient_value(patient.getOxyLoss()))
	patient_tox_loss.set_output(patient_value(patient.getToxLoss()))
	patient_brain_damage.set_output(patient_value(patient.getOrganLoss(ORGAN_SLOT_BRAIN)))
	patient_blood_level.set_output(patient_value(patient.blood_volume))
	defib_state.set_output(get_defib_state(patient))

/// Odpowiednik stanów DEFIB_FAIL_* z tg, liczony jak nasze is_defib_possible()
/obj/item/circuit_component/vitals_monitor/proc/get_defib_state(mob/living/patient)
	if(!iscarbon(patient))
		return "Possible"
	var/mob/living/carbon/carbon_patient = patient
	if(carbon_patient.suiciding || carbon_patient.ishellbound())
		return "Impossible"
	if(HAS_TRAIT(carbon_patient, TRAIT_HUSK))
		return "Husked"
	if((carbon_patient.getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE) || (carbon_patient.getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE))
		return "Damaged"
	var/obj/item/organ/heart/heart = carbon_patient.getorgan(/obj/item/organ/heart)
	if(!heart || (heart.organ_flags & ORGAN_FAILING))
		return "Heart Failure"
	var/obj/item/organ/brain/brain = carbon_patient.getorgan(/obj/item/organ/brain)
	if(QDELETED(brain) || brain.brain_death || (brain.organ_flags & ORGAN_FAILING))
		return "Brain Failure"
	if(brain.suicided)
		return "Impossible"
	return "Possible"

#undef AQ_AALARM_MODE_SCRUBBING
#undef AQ_AALARM_MODE_VENTING
#undef AQ_AALARM_MODE_PANIC
#undef AQ_AALARM_MODE_REPLACEMENT
#undef AQ_AALARM_MODE_OFF
#undef AQ_AALARM_MODE_SIPHON
#undef AQ_AALARM_MODE_CONTAMINATED
#undef AQ_AALARM_MODE_REFILL
#undef AQ_VENT_EXT_BOUND
#undef AQ_VENT_INT_BOUND
#undef AQ_VENT_MAX_PRESSURE
