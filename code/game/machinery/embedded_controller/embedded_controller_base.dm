/datum/computer/file/embedded_program
	var/list/memory = list()
	var/state
	var/obj/machinery/embedded_controller/master

/datum/computer/file/embedded_program/Destroy()
	master = null
	. = ..()

/datum/computer/file/embedded_program/proc/post_signal(datum/signal/signal, comm_line)
	if(master)
		master.post_signal(signal, comm_line)
	else
		qdel(signal)

/datum/computer/file/embedded_program/proc/receive_user_command(command)

/datum/computer/file/embedded_program/proc/receive_signal(datum/signal/signal)
	return null

/datum/computer/file/embedded_program/process()
	return 0

/obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "wbudowany sterownik"
	density = FALSE

	var/on = TRUE

/obj/machinery/embedded_controller/Destroy()
	if(program)
		QDEL_NULL(program)
	. = ..()

/obj/machinery/embedded_controller/ui_interact(mob/user, datum/tgui/ui)
	if(!tgui_id)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, tgui_id, name)
		ui.open()

/// Akcje z okna trafiają do programu jako polecenia użytkownika
/obj/machinery/embedded_controller/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(program)
		program.receive_user_command(action)
		addtimer(CALLBACK(program, TYPE_PROC_REF(/datum/computer/file/embedded_program, process)), 5)
	return TRUE

/obj/machinery/embedded_controller/update_icon()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return 0

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal)
	if(istype(signal) && program)
		program.receive_signal(signal)

/obj/machinery/embedded_controller/process(delta_time)
	if(program)
		program.process(delta_time)

	update_icon()

/obj/machinery/embedded_controller/radio
	var/frequency
	var/datum/radio_frequency/radio_connection

/obj/machinery/embedded_controller/radio/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/embedded_controller/radio/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal)
	signal.transmission_method = TRANSMISSION_RADIO
	if(radio_connection)
		return radio_connection.post_signal(src, signal)
	else
		signal = null

/obj/machinery/embedded_controller/radio/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency)
