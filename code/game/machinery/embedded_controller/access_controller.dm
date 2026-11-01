#define CLOSING			1
#define OPENING			2
#define CYCLE			3
#define CYCLE_EXTERIOR	4
#define CYCLE_INTERIOR	5

/obj/machinery/doorButtons
	power_channel = AREA_USAGE_ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/idSelf

/obj/machinery/doorButtons/attackby(obj/O, mob/user)
	return attack_hand(user)

/obj/machinery/doorButtons/proc/findObjsByTag()
	return

/obj/machinery/doorButtons/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/doorButtons/LateInitialize()
	findObjsByTag()

/obj/machinery/doorButtons/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	req_access = list()
	req_one_access = list()
	playsound(src, "sparks", 100, 1)
	to_chat(user, "<span class='warning'>Zwierasz kontroler dostępu.</span>")

/obj/machinery/doorButtons/proc/removeMe()


/obj/machinery/doorButtons/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "przycisk dostępu"
	desc = "Przycisk służący wyłącznie do otwierania śluzy."
	var/idDoor
	var/obj/machinery/door/airlock/door
	var/obj/machinery/doorButtons/airlock_controller/controller
	var/busy

/obj/machinery/doorButtons/access_button/findObjsByTag()
	for(var/obj/machinery/doorButtons/airlock_controller/A in GLOB.machines)
		if(A.idSelf == idSelf)
			controller = A
			break
	for(var/obj/machinery/door/airlock/I in GLOB.machines)
		if(I.id_tag == idDoor)
			door = I
			break

/obj/machinery/doorButtons/access_button/interact(mob/user)
	if(busy)
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu.</span>")
		return
	if(controller && !controller.busy && door)
		if(controller.machine_stat & NOPOWER)
			return
		busy = TRUE
		update_icon()
		if(door.density)
			if(!controller.exteriorAirlock || !controller.interiorAirlock)
				controller.onlyOpen(door)
			else
				if(controller.exteriorAirlock.density && controller.interiorAirlock.density)
					controller.onlyOpen(door)
				else
					controller.cycleClose(door)
		else
			controller.onlyClose(door)
		sleep(20)
		busy = FALSE
		update_icon()

/obj/machinery/doorButtons/access_button/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "access_button_off"
	else
		if(busy)
			icon_state = "access_button_cycle"
		else
			icon_state = "access_button_standby"

/obj/machinery/doorButtons/access_button/power_change()
	..()
	update_icon()

/obj/machinery/doorButtons/access_button/removeMe(obj/O)
	if(O == door)
		door = null



/obj/machinery/doorButtons/airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_standby"
	name = "konsola dostępu"
	desc = "Mała konsola, która przełącza otwieranie między dwiema śluzami."
	var/obj/machinery/door/airlock/interiorAirlock
	var/obj/machinery/door/airlock/exteriorAirlock
	var/idInterior
	var/idExterior
	var/busy
	var/lostPower

/obj/machinery/doorButtons/airlock_controller/removeMe(obj/O)
	if(O == interiorAirlock)
		interiorAirlock = null
	else if(O == exteriorAirlock)
		exteriorAirlock = null

/obj/machinery/doorButtons/airlock_controller/Destroy()
	for(var/obj/machinery/doorButtons/access_button/A in GLOB.machines)
		if(A.controller == src)
			A.controller = null
	return ..()

/obj/machinery/doorButtons/airlock_controller/ui_act(action, list/params)
	. = ..()
	if(. || busy)
		return TRUE
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Odmowa dostępu.</span>")
		return TRUE
	if(isnull(params["requested_door"]))
		return TRUE

	var/obj/machinery/door/airlock/requested_door
	var/obj/machinery/door/airlock/opposite_door
	if(interiorAirlock && REF(interiorAirlock) == params["requested_door"])
		requested_door = interiorAirlock
		opposite_door = exteriorAirlock
	else if(exteriorAirlock && REF(exteriorAirlock) == params["requested_door"])
		requested_door = exteriorAirlock
		opposite_door = interiorAirlock
	else
		return TRUE

	switch(action)
		if("open")
			if(opposite_door && !opposite_door.density)
				cycleClose(requested_door)
			else
				onlyOpen(requested_door)
		if("close")
			onlyClose(requested_door)
	return TRUE

/obj/machinery/doorButtons/airlock_controller/proc/onlyOpen(obj/machinery/door/airlock/A)
	if(A)
		busy = CLOSING
		update_icon()
		openDoor(A)

/obj/machinery/doorButtons/airlock_controller/proc/onlyClose(obj/machinery/door/airlock/A)
	if(A)
		busy = CLOSING
		closeDoor(A)

/obj/machinery/doorButtons/airlock_controller/proc/closeDoor(obj/machinery/door/airlock/A)
	if(A.density)
		goIdle()
		return FALSE
	update_icon()
	A.safe = FALSE //Door crushies, manual door after all. Set every time in case someone changed it, safe doors can end up waiting forever.
	A.unbolt()
	if(A.close())
		if(machine_stat & NOPOWER || lostPower || !A || QDELETED(A))
			goIdle(TRUE)
			return FALSE
		A.bolt()
		goIdle(TRUE)
		return TRUE
	goIdle(TRUE)
	return FALSE

/obj/machinery/doorButtons/airlock_controller/proc/cycleClose(obj/machinery/door/airlock/A)
	if(!A || !exteriorAirlock || !interiorAirlock)
		return
	if(exteriorAirlock.density == interiorAirlock.density || !A.density)
		return
	busy = CYCLE
	update_icon()
	if(A == interiorAirlock)
		if(closeDoor(exteriorAirlock))
			busy = CYCLE_INTERIOR
	else
		if(closeDoor(interiorAirlock))
			busy = CYCLE_EXTERIOR

/obj/machinery/doorButtons/airlock_controller/proc/cycleOpen(obj/machinery/door/airlock/A)
	if(!A)
		goIdle(TRUE)
	if(A == exteriorAirlock)
		if(interiorAirlock)
			if(!interiorAirlock.density || !interiorAirlock.locked)
				return
	else
		if(exteriorAirlock)
			if(!exteriorAirlock.density || !exteriorAirlock.locked)
				return
	if(busy != OPENING)
		busy = OPENING
		openDoor(A)

/obj/machinery/doorButtons/airlock_controller/proc/openDoor(obj/machinery/door/airlock/A)
	if(exteriorAirlock && interiorAirlock && (!exteriorAirlock.density || !interiorAirlock.density))
		goIdle(TRUE)
		return
	A.unbolt()
	spawn()
		if(A && A.open())
			if(machine_stat | (NOPOWER) && !lostPower && A && !QDELETED(A))
				A.bolt()
		goIdle(TRUE)

/obj/machinery/doorButtons/airlock_controller/proc/goIdle(update)
	lostPower = FALSE
	busy = FALSE
	if(update)
		update_icon()
	SStgui.update_uis(src)

/obj/machinery/doorButtons/airlock_controller/process()
	if(machine_stat & NOPOWER)
		return
	if(busy == CYCLE_EXTERIOR)
		cycleOpen(exteriorAirlock)
	else if(busy == CYCLE_INTERIOR)
		cycleOpen(interiorAirlock)

/obj/machinery/doorButtons/airlock_controller/power_change()
	..()
	if(machine_stat & NOPOWER)
		lostPower = TRUE
	else
		if(!busy)
			lostPower = FALSE
	update_icon()

/obj/machinery/doorButtons/airlock_controller/findObjsByTag()
	for(var/obj/machinery/door/airlock/A in GLOB.machines)
		if(A.id_tag == idInterior)
			interiorAirlock = A
		else if(A.id_tag == idExterior)
			exteriorAirlock = A

/obj/machinery/doorButtons/airlock_controller/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "access_control_off"
		return
	if(busy || lostPower)
		icon_state = "access_control_process"
	else
		icon_state = "access_control_standby"

/obj/machinery/doorButtons/airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockButtonController", name)
		ui.open()

/obj/machinery/doorButtons/airlock_controller/ui_data(mob/user)
	var/list/data = list()
	data["interior_door"] = interiorAirlock ? REF(interiorAirlock) : null
	data["exterior_door"] = exteriorAirlock ? REF(exteriorAirlock) : null
	data["busy"] = busy || lostPower
	data["interior_door_closed"] = interiorAirlock?.density
	data["exterior_door_closed"] = exteriorAirlock?.density
	return data

#undef CLOSING
#undef OPENING
#undef CYCLE
#undef CYCLE_EXTERIOR
#undef CYCLE_INTERIOR
