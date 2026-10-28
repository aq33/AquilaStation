// Verby adminów z wiremoda tg (tam przez makro ADMIN_VERB, którego nie mamy).
/world/AVerbsAdmin()
	. = ..()
	. += /client/proc/view_all_circuits

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/load_circuit
