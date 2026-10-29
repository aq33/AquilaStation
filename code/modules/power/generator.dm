/obj/machinery/power/generator
	name = "generator termoelektryczny"
	desc = "Wysokosprawny generator termoelektryczny."
	icon_state = "teg"
	density = TRUE
	use_power = NO_POWER_USE

	var/obj/machinery/atmospherics/components/binary/circulator/cold_circ
	var/obj/machinery/atmospherics/components/binary/circulator/hot_circ

	var/lastgen = 0
	var/lastgenlev = -1
	var/lastcirc = "00"


/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	find_circs()
	connect_to_network()
	SSair.start_processing_machine(src) //NSV13 - Citadel auxmos
	update_icon()
	component_parts = list(new /obj/item/circuitboard/machine/generator)

/obj/machinery/power/generator/Destroy()
	kill_circs()
	SSair.stop_processing_machine(src) //NSV13 - Citadel auxmos
	return ..()

/obj/machinery/power/generator/update_icon()

	if(machine_stat & (NOPOWER|BROKEN))
		cut_overlays()
		soundloop.stop() // AQ EDIT
	else
		cut_overlays()

		var/L = min(round(lastgenlev/100000),11)
		if(L != 0)
			soundloop.start() // AQ EDIT
			add_overlay(image('icons/obj/power.dmi', "teg-op[L]"))

		if(hot_circ && cold_circ)
			add_overlay("teg-oc[lastcirc]")


#define GENRATE 800		// generator output coefficient from Q

/obj/machinery/power/generator/process_atmos()

	if(!cold_circ || !hot_circ)
		return

	if(powernet)
		var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()
		var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()

		if(cold_air && hot_air)

			var/cold_air_heat_capacity = cold_air.heat_capacity()
			var/hot_air_heat_capacity = hot_air.heat_capacity()

			var/delta_temperature = hot_air.return_temperature() - cold_air.return_temperature()


			if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
				var/efficiency = 0.65

				var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)

				var/heat = energy_transfer*(1-efficiency)
				lastgen += energy_transfer*efficiency

				hot_air.set_temperature(hot_air.return_temperature() - energy_transfer/hot_air_heat_capacity)
				cold_air.set_temperature(cold_air.return_temperature() + heat/cold_air_heat_capacity)

				//add_avail(lastgen) This is done in process now
		// update icon overlays only if displayed level has changed

		if(hot_air)
			var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1]
			hot_circ_air1.merge(hot_air)

		if(cold_air)
			var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1]
			cold_circ_air1.merge(cold_air)

		update_icon()

	var/circ = "[cold_circ && cold_circ.last_pressure_delta > 0 ? "1" : "0"][hot_circ && hot_circ.last_pressure_delta > 0 ? "1" : "0"]"
	if(circ != lastcirc)
		lastcirc = circ
		update_icon()

/obj/machinery/power/generator/process()
	//Setting this number higher just makes the change in power output slower, it doesnt actualy reduce power output cause **math**
	var/power_output = round(lastgen / 10)
	add_avail(power_output)
	lastgenlev = power_output
	lastgen -= power_output
	..()

/obj/machinery/power/generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermoElectricGenerator", name)
		ui.open()

/obj/machinery/power/generator/ui_data(mob/user)
	var/list/data = list()
	data["error_message"] = null
	if(!powernet)
		data["error_message"] = "Nie można połączyć się z siecią energetyczną!"
		return data
	if(!cold_circ && !hot_circ)
		data["error_message"] = "Nie można znaleźć żadnych części!"
		return data
	if(!cold_circ)
		data["error_message"] = "Nie można znaleźć zimnego cyrkulatora!"
		return data
	if(!hot_circ)
		data["error_message"] = "Nie można znaleźć gorącego cyrkulatora!"
		return data

	var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1]
	var/datum/gas_mixture/cold_circ_air2 = cold_circ.airs[2]
	var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1]
	var/datum/gas_mixture/hot_circ_air2 = hot_circ.airs[2]

	data["last_power_output"] = display_power(lastgenlev)

	var/list/cold_data = list()
	cold_data["temperature_inlet"] = round(cold_circ_air2.return_temperature(), 0.1)
	cold_data["temperature_outlet"] = round(cold_circ_air1.return_temperature(), 0.1)
	cold_data["pressure_inlet"] = round(cold_circ_air2.return_pressure(), 0.1)
	cold_data["pressure_outlet"] = round(cold_circ_air1.return_pressure(), 0.1)
	data["cold_data"] = list(cold_data)

	var/list/hot_data = list()
	hot_data["temperature_inlet"] = round(hot_circ_air2.return_temperature(), 0.1)
	hot_data["temperature_outlet"] = round(hot_circ_air1.return_temperature(), 0.1)
	hot_data["pressure_inlet"] = round(hot_circ_air2.return_pressure(), 0.1)
	hot_data["pressure_outlet"] = round(hot_circ_air1.return_pressure(), 0.1)
	data["hot_data"] = list(hot_data)
	return data

/obj/machinery/power/generator/power_change()
	..()
	update_icon()

/obj/machinery/power/generator/proc/find_circs()
	kill_circs()
	var/list/circs = list()
	var/obj/machinery/atmospherics/components/binary/circulator/C
	var/circpath = /obj/machinery/atmospherics/components/binary/circulator
	if(dir == NORTH || dir == SOUTH)
		C = locate(circpath) in get_step(src, EAST)
		if(C?.dir == WEST)
			circs += C

		C = locate(circpath) in get_step(src, WEST)
		if(C?.dir == EAST)
			circs += C

	else
		C = locate(circpath) in get_step(src, NORTH)
		if(C?.dir == SOUTH)
			circs += C

		C = locate(circpath) in get_step(src, SOUTH)
		if(C?.dir == NORTH)
			circs += C

	if(circs.len)
		for(C in circs)
			if(C.mode == CIRCULATOR_COLD && !cold_circ)
				cold_circ = C
				C.generator = src
			else if(C.mode == CIRCULATOR_HOT && !hot_circ)
				hot_circ = C
				C.generator = src

/obj/machinery/power/generator/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	anchored = !anchored
	I.play_tool_sound(src)
	if(!anchored)
		kill_circs()
	connect_to_network()
	to_chat(user, "<span class='notice'>[anchored?"Mocujesz":"Odmocowujesz"] [src].</span>")
	return TRUE

/obj/machinery/power/generator/multitool_act(mob/living/user, obj/item/I)
	if(!anchored)
		return
	find_circs()
	to_chat(user, "<span class='notice'>Aktualizujesz połączenia cyrkulatorów [src].</span>")
	return TRUE

/obj/machinery/power/generator/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>[panel_open?"Otwierasz":"Zamykasz"] panel [src].</span>")
	return TRUE

/obj/machinery/power/generator/crowbar_act(mob/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/power/generator/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/machinery/power/generator/on_deconstruction()
	kill_circs()

/obj/machinery/power/generator/proc/kill_circs()
	if(hot_circ)
		hot_circ.generator = null
		hot_circ = null
	if(cold_circ)
		cold_circ.generator = null
		cold_circ = null
