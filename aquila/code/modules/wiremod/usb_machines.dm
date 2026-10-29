// Porty USB w maszynach, które tg ma u siebie w plikach maszyn: emiter, termomaszyna i pompa temperatury.
// Sygnały o włączeniu i strzale wysyłamy z nadpisań, bo nasze maszyny przełączają `on`/`active` wprost.

/obj/machinery/power/emitter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/emitter))

/obj/machinery/power/emitter/interact(mob/user)
	var/was_active = active
	. = ..()
	if(active != was_active)
		SEND_SIGNAL(src, COMSIG_EMITTER_MACHINE_SET_ON, active)

/obj/machinery/power/emitter/process(delta_time)
	var/was_active = active
	. = ..()
	if(active != was_active)
		SEND_SIGNAL(src, COMSIG_EMITTER_MACHINE_SET_ON, active)

/obj/machinery/power/emitter/fire_beam(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_EMITTER_MACHINE_ON_FIRE)

/// Włącza lub wyłącza maszynę atmosu i daje znać circuitom (z tg).
/obj/machinery/atmospherics/components/proc/set_on(active)
	if(on == active)
		return
	on = active
	SEND_SIGNAL(src, COMSIG_ATMOS_MACHINE_SET_ON, on)
	update_icon()

/obj/machinery/atmospherics/components/unary/thermomachine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/thermomachine))

/obj/machinery/atmospherics/components/unary/thermomachine/set_on(active)
	. = ..()
	use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, params)
	var/was_on = on
	. = ..()
	if(on != was_on)
		SEND_SIGNAL(src, COMSIG_ATMOS_MACHINE_SET_ON, on)

/obj/machinery/atmospherics/components/binary/temperature_pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/atmos_temperature_pump))

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_act(action, params)
	var/was_on = on
	. = ..()
	if(on != was_on)
		SEND_SIGNAL(src, COMSIG_ATMOS_MACHINE_SET_ON, on)
