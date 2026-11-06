/////////////////////////////////////////////////////////////
// AIR SENSOR (found in gas tanks)
/////////////////////////////////////////////////////////////

/obj/machinery/air_sensor
	name = "czujnik gazu"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	var/on = TRUE

	var/frequency = FREQ_ATMOS_STORAGE
	var/datum/radio_frequency/radio_connection

/obj/machinery/air_sensor/atmos/toxin_tank
	name = "czujnik gazu zbiornika plazmy"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_TOX
/obj/machinery/air_sensor/atmos/toxins_mixing_tank
	name = "czujnik gazu mieszalni toksyn"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB
/obj/machinery/air_sensor/atmos/oxygen_tank
	name = "czujnik gazu zbiornika tlenu"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_O2
/obj/machinery/air_sensor/atmos/nitrogen_tank
	name = "czujnik gazu zbiornika azotu"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_N2
/obj/machinery/air_sensor/atmos/mix_tank
	name = "czujnik gazu zbiornika mieszanki"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_MIX
/obj/machinery/air_sensor/atmos/nitrous_tank
	name = "czujnik gazu zbiornika podtlenku azotu"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_N2O
/obj/machinery/air_sensor/atmos/air_tank
	name = "czujnik gazu zbiornika mieszanki powietrza"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_AIR
/obj/machinery/air_sensor/atmos/carbon_tank
	name = "czujnik gazu zbiornika dwutlenku węgla"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_CO2
/obj/machinery/air_sensor/atmos/incinerator_tank
	name = "czujnik gazu komory spalarni"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_INCINERATOR
/obj/machinery/air_sensor/atmos/sm_core
	name = "czujnik gazu supermaterii"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_SM

/obj/machinery/air_sensor/update_icon()
	icon_state = "gsensor[on]"

/obj/machinery/air_sensor/process_atmos()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()

		var/datum/signal/signal = new(list(
			"sigtype" = "status",
			"id_tag" = id_tag,
			"timestamp" = world.time,
			"pressure" = air_sample.return_pressure(),
			"temperature" = air_sample.return_temperature(),
			"gases" = list()
		))
		var/total_moles = air_sample.total_moles()
		if(total_moles)
			for(var/gas_id in air_sample.get_gases())
				var/gas_name = GLOB.gas_data.names[gas_id]
				signal.data["gases"][gas_name] = air_sample.get_moles(gas_id) / total_moles * 100

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)


/obj/machinery/air_sensor/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/air_sensor/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	set_frequency(frequency)

/obj/machinery/air_sensor/Destroy()
	SSair.stop_processing_machine(src)
	SSradio.remove_object(src, frequency)
	return ..()

/////////////////////////////////////////////////////////////
// GENERAL AIR CONTROL (a.k.a atmos computer)
/////////////////////////////////////////////////////////////
GLOBAL_LIST_EMPTY(atmos_air_controllers)

/obj/machinery/computer/atmos_control
	name = "monitoring atmosferyki"
	desc = "Służy do monitorowania czujników atmosferycznych stacji."
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_control



	var/frequency = FREQ_ATMOS_STORAGE
	var/list/sensors = list(
		ATMOS_GAS_MONITOR_SENSOR_N2 = "Zbiornik azotu",
		ATMOS_GAS_MONITOR_SENSOR_O2 = "Zbiornik tlenu",
		ATMOS_GAS_MONITOR_SENSOR_CO2 = "Zbiornik dwutlenku węgla",
		ATMOS_GAS_MONITOR_SENSOR_TOX = "Zbiornik plazmy",
		ATMOS_GAS_MONITOR_SENSOR_N2O = "Zbiornik podtlenku azotu",
		ATMOS_GAS_MONITOR_SENSOR_AIR = "Zbiornik mieszanki powietrza",
		ATMOS_GAS_MONITOR_SENSOR_MIX = "Zbiornik mieszanki",
		ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION = "Pętla dystrybucyjna",
		ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE = "Pętla odpadów atmosferyki",
		ATMOS_GAS_MONITOR_SENSOR_INCINERATOR = "Komora spalarni",
		ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB = "Komora mieszania toksyn",
		ATMOS_GAS_MONITOR_SENSOR_SM = "Rdzeń supermaterii"
	)
	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/atmos_control/Initialize(mapload)
	. = ..()
	GLOB.atmos_air_controllers += src
	set_frequency(frequency)

/obj/machinery/computer/atmos_control/Destroy()
	GLOB.atmos_air_controllers -= src
	SSradio.remove_object(src, frequency)
	return ..()


/obj/machinery/computer/atmos_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/atmos_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole")
		ui.open()
		ui.set_autoupdate(TRUE) // Gas sensors

/obj/machinery/computer/atmos_control/ui_data(mob/user)
	var/data = list()

	data["sensors"] = list()
	for(var/id_tag in sensors)
		var/long_name = sensors[id_tag]
		var/list/info = sensor_information[id_tag]
		if(!info)
			continue
		data["sensors"] += list(list(
			"id_tag"		= id_tag,
			"long_name" 	= sanitize(long_name),
			"pressure"		= info["pressure"],
			"temperature"	= info["temperature"],
			"gases"			= info["gases"]
		))
	return data

/obj/machinery/computer/atmos_control/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["id_tag"]
	if(!id_tag || !sensors.Find(id_tag))
		return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/atmos_control/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/////////////////////////////////////////////////////////////
// LARGE TANK CONTROL
/////////////////////////////////////////////////////////////

/obj/machinery/computer/atmos_control/tank
	var/input_tag
	var/output_tag
	frequency = FREQ_ATMOS_STORAGE
	circuit = /obj/item/circuitboard/computer/atmos_control/tank

	var/list/input_info
	var/list/output_info




/obj/machinery/computer/atmos_control/tank/oxygen_tank
	name = "sterowanie dopływem tlenu"
	input_tag = ATMOS_GAS_MONITOR_INPUT_O2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_O2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_O2 = "Zbiornik tlenu")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank

/obj/machinery/computer/atmos_control/tank/toxin_tank
	name = "sterowanie dopływem plazmy"
	input_tag = ATMOS_GAS_MONITOR_INPUT_TOX
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_TOX
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_TOX = "Zbiornik plazmy")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/toxin_tank

/obj/machinery/computer/atmos_control/tank/air_tank
	name = "sterowanie dopływem mieszanki powietrza"
	input_tag = ATMOS_GAS_MONITOR_INPUT_AIR
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_AIR
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_AIR = "Zbiornik mieszanki powietrza")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/air_tank

/obj/machinery/computer/atmos_control/tank/mix_tank
	name = "sterowanie zbiornikiem mieszanki gazów"
	input_tag = ATMOS_GAS_MONITOR_INPUT_MIX
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_MIX
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_MIX = "Zbiornik mieszanki gazów")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/mix_tank

/obj/machinery/computer/atmos_control/tank/nitrous_tank
	name = "sterowanie dopływem podtlenku azotu"
	input_tag = ATMOS_GAS_MONITOR_INPUT_N2O
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_N2O
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_N2O = "Zbiornik podtlenku azotu")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/nitrous_tank

/obj/machinery/computer/atmos_control/tank/nitrogen_tank
	name = "sterowanie dopływem azotu"
	input_tag = ATMOS_GAS_MONITOR_INPUT_N2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_N2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_N2 = "Zbiornik azotu")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/nitrogen_tank

/obj/machinery/computer/atmos_control/tank/carbon_tank
	name = "sterowanie dopływem dwutlenku węgla"
	input_tag = ATMOS_GAS_MONITOR_INPUT_CO2
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_CO2
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_CO2 = "Zbiornik dwutlenku węgla")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/carbon_tank

/obj/machinery/computer/atmos_control/tank/incinerator
	name = "sterowanie powietrzem spalarni"
	input_tag = ATMOS_GAS_MONITOR_INPUT_INCINERATOR
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_INCINERATOR
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_INCINERATOR = "Komora spalarni")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/incinerator

/obj/machinery/computer/atmos_control/tank/sm
	name = "monitor powietrza supermaterii"
	input_tag = ATMOS_GAS_MONITOR_INPUT_SM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_SM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_SM = "Rdzeń supermaterii")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/incinerator

/obj/machinery/computer/atmos_control/tank/toxins_mixing_tank
	name = "monitor powietrza komory toksyn"
	input_tag = ATMOS_GAS_MONITOR_INPUT_TOXINS_LAB
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_TOXINS_LAB
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB = "Komora mieszania toksyn")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/incinerator

// This hacky madness is the evidence of the fact that a lot of machines were never meant to be constructable, im so sorry you had to see this
/obj/machinery/computer/atmos_control/tank/proc/reconnect(mob/user)
	var/list/IO = list()
	var/datum/radio_frequency/freq = SSradio.return_frequency(frequency)

	var/list/devices = list()
	var/list/device_refs = freq.devices["_default"]
	for(var/datum/weakref/device_ref as anything in device_refs)
		var/atom/device = device_ref.resolve()
		if(!device)
			device_refs -= device_ref
			continue
		devices += device

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		var/list/text = splittext(U.id_tag, "_")
		IO |= text[1]
	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		var/list/text = splittext(U.id, "_")
		IO |= text[1]
	if(!IO.len)
		to_chat(user, "<span class='alert'>Nie wykryto urządzeń.</span>")
		return
	var/S = input("Wybierz zestaw urządzeń: ", "Wybór", IO[1]) as anything in sortList(IO)
	if(src)
		src.input_tag = "[S]_in"
		src.output_tag = "[S]_out"
		name = "sterowanie dopływem: [uppertext(S)]"
		var/list/new_devices = freq.devices["atmosia"]
		sensors.Cut()
		for(var/obj/machinery/air_sensor/U in new_devices)
			var/list/text = splittext(U.id_tag, "_")
			if(text[1] == S)
				sensors = list("[S]_sensor" = "Zbiornik: [S]")
				break

	for(var/obj/machinery/atmospherics/components/unary/outlet_injector/U in devices)
		U.broadcast_status()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in devices)
		U.broadcast_status()

/obj/machinery/computer/atmos_control/tank/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/atmos_control/tank/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosControlConsole")
		ui.set_autoupdate(TRUE) // Gas sensors
		ui.open()

/obj/machinery/computer/atmos_control/tank/ui_data(mob/user)
	var/list/data = ..()
	data["tank"] = TRUE
	data["inputting"] = input_info ? input_info["power"] : FALSE
	data["inputRate"] = input_info ? input_info["volume_rate"] : 0
	data["maxInputRate"] = input_info ? MAX_TRANSFER_RATE : 0
	data["outputting"] = output_info ? output_info["power"] : FALSE
	data["outputPressure"] = output_info ? output_info["internal"] : 0
	data["maxOutputPressure"] = output_info ? MAX_OUTPUT_PRESSURE : 0
	return data

/obj/machinery/computer/atmos_control/tank/ui_act(action, params)
	if(..() || !radio_connection)
		return
	var/datum/signal/signal = new(list("sigtype" = "command", "user" = usr))
	switch(action)
		if("reconnect")
			reconnect(usr)
			. = TRUE
		if("input")
			signal.data += list("tag" = input_tag, "power_toggle" = TRUE)
			. = TRUE
		if("rate")
			var/target = text2num(params["rate"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_TRANSFER_RATE)
				signal.data += list("tag" = input_tag, "set_volume_rate" = target)
				. = TRUE
		if("output")
			signal.data += list("tag" = output_tag, "power_toggle" = TRUE)
			. = TRUE
		if("pressure")
			var/target = text2num(params["pressure"])
			if(!isnull(target))
				target = clamp(target, 0, MAX_OUTPUT_PRESSURE)
				signal.data += list("tag" = output_tag, "set_internal_pressure" = target)
				. = TRUE
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/computer/atmos_control/tank/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)
