// AQUILA - rura wymiany ciepła bez sieci rur nie liczy wymiany ciepła.
// Szablon wczytany w trakcie rundy (podmiana silnika, losowe pokoje) dodaje rury do SSair, zanim zbuduje ich sieć;
// process() rury ma już tę osłonę, process_atmos() czytał wtedy null.air (runtime co tick do zbudowania sieci).
// Rozbierana sieć zostawia rurom air_temporary, ale bazowa procka i tak woła wtedy parent.temperature_interact().
/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	if(!parent)
		return
	return ..()
