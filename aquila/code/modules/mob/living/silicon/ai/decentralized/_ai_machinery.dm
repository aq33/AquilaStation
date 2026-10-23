// Port zdecentralizowanego AI: Monkestation/Monkestation2.0#11862 (oryginał: Yogstation)

#define AI_MACHINE_TOO_HOT "Za wysoka temperatura otoczenia"
#define AI_MACHINE_NO_MOLES "Brak atmosfery w otoczeniu"
#define AI_MACHINE_NO_NETWORK "Brak połączenia z siecią (kabel sieciowy pod maszyną)"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE
	///Sieć ethernet, do której maszyna jest podłączona kablem na swoim kafelku (ustawia rebuild_ai_networks())
	var/datum/ai_network/network
	///Temperature of the machine itself, this will share with air in the enviroment
	var/core_temp = T0C - 80

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	GLOB.ai_machines += src
	queue_ai_network_rebuild()

/obj/machinery/ai/Destroy()
	SSair.stop_processing_machine(src)
	GLOB.ai_machines -= src
	network?.nodes -= src
	network = null
	queue_ai_network_rebuild()
	return ..()

///System zasobów sieci, do której jesteśmy podłączeni
/obj/machinery/ai/proc/get_os()
	RETURN_TYPE(/datum/ai_os)
	flush_ai_network_rebuild()
	return network?.resources

/obj/machinery/ai/setAnchored(anchorvalue)
	. = ..()
	queue_ai_network_rebuild()

/obj/machinery/ai/Moved(atom/OldLoc, Dir)
	. = ..()
	queue_ai_network_rebuild()

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
	var/datum/ai_os/os_using = get_os()
	if(!os_using)
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

	var/datum/ai_os/os_using = get_os()
	if(!os_using)
		return AI_MACHINE_NO_NETWORK
	if(core_temp > os_using.get_temp_limit())
		return AI_MACHINE_TOO_HOT

#undef AI_MACHINE_TOO_HOT
#undef AI_MACHINE_NO_MOLES
#undef AI_MACHINE_NO_NETWORK
