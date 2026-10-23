// Port zdecentralizowanego AI: Monkestation/Monkestation2.0#11862 (oryginał: Yogstation)

#define AI_MACHINE_TOO_HOT "Za wysoka temperatura otoczenia"
#define AI_MACHINE_NO_MOLES "Brak atmosfery w otoczeniu"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE
	///Our linked ai_os
	var/datum/ai_os/linked_os
	///Temperature of the machine itself, this will share with air in the enviroment
	var/core_temp = T0C - 80

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	link_to_os()

/obj/machinery/ai/Destroy()
	SSair.stop_processing_machine(src)
	linked_os = null
	return ..()

/obj/machinery/ai/proc/link_to_os()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	linked_os = GLOB.ai_os["[our_turf.z]"]
	if(!linked_os)
		linked_os = new /datum/ai_os(src)

//Cooling happens here
/obj/machinery/ai/process_atmos()
	if((machine_stat & (BROKEN|EMPED)) || !has_power())
		return FALSE
	var/turf/T = get_turf(src)
	if(!T || isspaceturf(T))
		return FALSE
	var/datum/gas_mixture/env = T.return_air()
	if(!env?.total_moles())
		return FALSE
	// Wymiana ciepła z powietrzem jak gas_mixture/temperature_share() z tg. Nasz auxmos nie obsługuje wariantu bez drugiej mieszaniny.
	var/env_temp = env.return_temperature()
	var/delta = env_temp - core_temp
	var/env_capacity = env.heat_capacity()
	if(abs(delta) > 0.5 && env_capacity > 0)
		var/heat = AI_HEATSINK_COEFF * delta * (env_capacity * AI_HEATSINK_CAPACITY / (env_capacity + AI_HEATSINK_CAPACITY))
		env.set_temperature(max(env_temp - heat / env_capacity, TCMB))
		core_temp = max(core_temp + heat / AI_HEATSINK_CAPACITY, TCMB)
		T.air_update_turf()
	return TRUE

/obj/machinery/ai/onTransitZ(old_z, new_z)
	. = ..()
	link_to_os()

/obj/machinery/ai/proc/valid_holder()
	if(machine_stat & (BROKEN|EMPED) || !has_power())
		return FALSE

	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return FALSE
	var/total_moles = env.total_moles()
	if(isspaceturf(T) || total_moles < 10)
		return FALSE
	var/datum/ai_os/os_using = GLOB.ai_os["[T.z]"]
	if(!os_using || linked_os != os_using)
		return FALSE
	if(core_temp > os_using.get_temp_limit())
		return FALSE
	return TRUE

/obj/machinery/ai/proc/has_power()
	return !(machine_stat & NOPOWER)

/obj/machinery/ai/proc/get_holder_status()
	if((machine_stat & (BROKEN|EMPED)) || !has_power())
		return FALSE

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T?.return_air()
	if(!env)
		return AI_MACHINE_NO_MOLES
	var/total_moles = env.total_moles()
	if(isspaceturf(T) || total_moles < 10)
		return AI_MACHINE_NO_MOLES

	var/datum/ai_os/os_using = GLOB.ai_os["[T.z]"]
	if(os_using && core_temp > os_using.get_temp_limit())
		return AI_MACHINE_TOO_HOT

#undef AI_MACHINE_TOO_HOT
#undef AI_MACHINE_NO_MOLES
