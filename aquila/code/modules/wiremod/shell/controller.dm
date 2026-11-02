/**
 * # Compact Remote
 *
 * A handheld device with several buttons.
 * In game, this translates to having different signals for normal usage, alt-clicking, and ctrl-clicking when in your hand.
 */
/obj/item/controller
	name = "kontroler"
	icon = 'aquila/icons/obj/wiremod/circuits.dmi'
	icon_state = "setup_small_calc"
	item_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 3.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)

/obj/item/controller/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/controller()
	), SHELL_CAPACITY_MEDIUM)

/obj/item/circuit_component/controller
	display_name = "Kontroler"
	desc = "Odbiera sygnały z obudowy kontrolera. Użyj obudowy w ręce, aby wyzwolić sygnał wyjściowy. Alt+klik daje sygnał alternatywny, prawy klik sygnał dodatkowy."
	/// The three separate buttons that are called in attack_hand on the shell.
	var/datum/port/output/signal
	var/datum/port/output/alt
	var/datum/port/output/right

	/// The entity output
	var/datum/port/output/entity

/obj/item/circuit_component/controller/populate_ports()
	entity = add_output_port("User", PORT_TYPE_USER)
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)
	alt = add_output_port("Alternate Signal", PORT_TYPE_SIGNAL)
	right = add_output_port("Extra Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/controller/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF, PROC_REF(send_trigger))
	RegisterSignal(shell, COMSIG_CLICK_ALT, PROC_REF(send_alternate_signal))
	RegisterSignal(shell, COMSIG_ITEM_ATTACK_SELF_SECONDARY, PROC_REF(send_right_signal))

/obj/item/circuit_component/controller/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK_SELF_SECONDARY,
		COMSIG_CLICK_ALT,
	))

/obj/item/circuit_component/controller/proc/handle_trigger(atom/source, user, port_name, datum/port/output/port_signal)
	source.balloon_alert(user, "kliknięto przycisk [port_name]")
	playsound(source, "keyboard", 25, FALSE)
	entity.set_output(user)
	port_signal.set_output(COMPONENT_SIGNAL)

/**
 * Called when the shell item is used in hand
 */
/obj/item/circuit_component/controller/proc/send_trigger(atom/source, mob/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(source))
		return
	handle_trigger(source, user, "primary", signal)

/**
 * Called when the shell item is alt-clicked
 */
/obj/item/circuit_component/controller/proc/send_alternate_signal(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!user.canUseTopic(source, BE_CLOSE))
		return

	handle_trigger(source, user, "alternate", alt)
	return CLICK_ACTION_SUCCESS


/**
 * Called when the shell item is right-clicked in active hand
 */
/obj/item/circuit_component/controller/proc/send_right_signal(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!user.canUseTopic(source, BE_CLOSE))
		return

	handle_trigger(source, user, "extra", right)
	return CLICK_ACTION_SUCCESS
