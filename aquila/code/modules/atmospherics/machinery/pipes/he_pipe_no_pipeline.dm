// AQUILA - rura wymiany ciepła (HE) bez sieci rur pomija cykl atmosfery zamiast runtime'u „Cannot read null.air”.
// Szablon wczytany w trakcie rundy (losowy silnik, podmiana silnika z wyboru inżynierów, ruiny) dodaje rury do
// przetwarzania już w Initialize, a sieci buduje dopiero setup_template_machinery() w pętli z CHECK_TICK. Gdy SSair
// ruszy w tej przerwie, process_atmos() rury HE woła return_air() -> parent.air na rurze bez parent. Po zbudowaniu
// sieci rura działa normalnie w następnym cyklu.

/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	if(!parent && !air_temporary)
		return
	return ..()
