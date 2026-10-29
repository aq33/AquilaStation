/obj/item/wallframe/clocktrap/delay
	name = "mechaniczny zegar"
	desc = "Mały zegar przymocowany do ściany. Po otrzymaniu sygnału wysyła sygnał wyjściowy pół sekundy później."
	icon_state = "delayer"
	result_path = /obj/structure/destructible/clockwork/trap/delay

/obj/structure/destructible/clockwork/trap/delay
	name = "mechaniczny zegar"
	desc = "Mały zegar przymocowany do ściany. Po otrzymaniu sygnału wysyła sygnał wyjściowy pół sekundy później."
	icon_state = "delayer"
	component_datum = /datum/component/clockwork_trap/delay
	unwrench_path = /obj/item/wallframe/clocktrap/delay
	max_integrity = 15
	obj_integrity = 15

/datum/component/clockwork_trap/delay
	takes_input = TRUE
	sends_input = TRUE
	var/active = FALSE

/datum/component/clockwork_trap/delay/trigger()
	if(!..())
		return
	if(active)
		return
	active = TRUE
	flick("delayer_active", parent)
	addtimer(CALLBACK(src, PROC_REF(finish)), 5)

/datum/component/clockwork_trap/delay/proc/finish()
	active = FALSE
	trigger_connected()
