// AQUILA - rury bez zbudowanej sieci.
// Szablon wczytany w trakcie rundy (podmiana silnika, losowe pokoje) dodaje rury i mierniki do SSair, zanim zbuduje
// sieci rur. Bazowe return_air() czytało wtedy parent.air z null (runtime co tick, np. w miernikach przepływu).
/obj/machinery/atmospherics/pipe/return_air()
	if(!parent && !air_temporary)
		return null
	return ..()

// process() rury wymiany ciepła ma już osłonę na brak sieci, process_atmos() jej nie miał.
// Rozbierana sieć zostawia rurom air_temporary, ale bazowa procka i tak woła wtedy parent.temperature_interact().
/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	if(!parent)
		return
	return ..()
