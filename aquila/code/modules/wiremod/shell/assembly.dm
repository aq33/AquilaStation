/**
 * # Assembly Shell
 *
 * An assembly that triggers and can be triggered by wires.
 */
/obj/item/assembly/wiremod
	name = "circuit assembly"
	desc = "Małe urządzenie elektroniczne, w którym można umieścić układ scalony."
	icon_state = "wiremod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 2.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)

// U nas zespoły nie wysyłają sygnałów o podłączeniu, więc obudowa nie bierze prądu z maszyny ani borga (jak w tg),
// tylko z własnej baterii układu.
/obj/item/assembly/wiremod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/assembly_input(),
		new /obj/item/circuit_component/assembly_output(),
	), SHELL_CAPACITY_SMALL)

/obj/item/assembly/wiremod/activate()
	. = ..()
	if(!.)
		return
	SEND_SIGNAL(src, COMSIG_ASSEMBLY_PULSED)

/obj/item/assembly/wiremod/examine(mob/user)
	. = ..()
	. += span_notice("Możesz też [secured ? "odbezpieczyć" : "zabezpieczyć"] [src], klikając prawym przyciskiem śrubokrętem, nawet z podłączonym układem scalonym.")

// This is to bypass removing the circuit with a screwdriver left-click
/obj/item/assembly/wiremod/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	screwdriver_act(user, tool)

/obj/item/circuit_component/assembly_input
	display_name = "Assembly Input"
	desc = "Wyzwala się, gdy dostanie impuls z podłączonego przewodu lub urządzenia."

	var/datum/port/output/signal

/obj/item/circuit_component/assembly_input/populate_ports()
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly_input/register_shell(atom/movable/shell)
	RegisterSignals(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF), PROC_REF(on_pulsed))

/obj/item/circuit_component/assembly_input/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF))

/obj/item/circuit_component/assembly_input/proc/on_pulsed(datum/source, mob/pulser)
	SIGNAL_HANDLER
	signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/assembly_output
	display_name = "Assembly Output"
	desc = "Po wyzwoleniu wysyła impuls do podłączonego przewodu lub urządzenia."

	var/obj/item/assembly/attached_assembly

	var/datum/port/input/signal

/obj/item/circuit_component/assembly_output/populate_ports()
	signal = add_input_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly_output/register_shell(atom/movable/shell)
	. = ..()
	if(isassembly(shell))
		attached_assembly = shell

/obj/item/circuit_component/assembly_output/unregister_shell(atom/movable/shell)
	attached_assembly = null
	return ..()

/obj/item/circuit_component/assembly_output/input_received(datum/port/input/port, list/return_values)
	attached_assembly.pulse()
