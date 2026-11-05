/*
	Common ancestor for plant machines that use the terminal control stuff
	AQUILA - maszyna działa też sama: klik otwiera jej okno, terminal jest tylko skrótem do wszystkich maszyn naraz
*/
/obj/machinery/plant_machine
	///Reference to the UI accesor
	var/obj/machinery/computer/plant_machine_controller/controller

/obj/machinery/plant_machine/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	. = ..()
	if(controller?.Adjacent(neighbor))
		return TRUE

/obj/machinery/plant_machine/ui_status(mob/user)
	if(controller?.Adjacent(user))
		return UI_INTERACTIVE
	return ..()

/obj/machinery/plant_machine/ui_act(action, params)
	if(..() && (!isliving(usr) || !(in_range(src, usr) || (controller && in_range(controller, usr)))))
		return TRUE
	if(isobserver(usr))
		return TRUE

/obj/machinery/plant_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	ui_interact(user)

/obj/machinery/plant_machine/proc/encrypt_ref(ref_string)
	return "0x[copytext(md5(ref_string), 1, 8)]"
