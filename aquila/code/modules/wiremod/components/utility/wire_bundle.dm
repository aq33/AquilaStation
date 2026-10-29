// Wiązka przewodów (tg code/modules/wiremod/components/utility/wire_bundle.dm i code/datums/wires/wire_bundle_component.dm).
// Daje obudowie bez własnych przewodów zestaw przewodów, do których można podpiąć zespoły (sygnalizator, czujnik itp.).
// U nas nie ma COMSIG_PULSE_WIRE, item_interaction ani set_wires, więc sygnał wysyłają nasze przewody z on_pulse(),
// a przewody otwiera się prawym kliknięciem narzędziem (COMSIG_PARENT_ATTACKBY_SECONDARY).

#define CAPACITY_PER_WIRE 10

/datum/wires/wire_bundle_component
	holder_type = /atom //Anything that can have a shell component, really.
	randomize = TRUE

/datum/wires/wire_bundle_component/New(atom/holder)
	var/datum/component/shell/shell_comp = holder.GetComponent(/datum/component/shell)
	if(!istype(shell_comp))
		CRASH("Holder does not have a shell component!")
	var/wire_count = clamp(round(shell_comp.capacity / CAPACITY_PER_WIRE, 1), 1, MAX_WIRE_COUNT)
	for(var/index in 1 to wire_count)
		wires += "Port [index]"
	..()

/datum/wires/wire_bundle_component/on_pulse(wire, user)
	SEND_SIGNAL(src, COMSIG_PULSE_WIRE, wire, user)

/datum/wires/wire_bundle_component/attach_assembly(color, obj/item/assembly/S)
	// Obudowa-zespół w wiązce innej obudowy dawałaby pętle układów (w tg COMSIG_ASSEMBLY_PRE_ATTACH)
	if(istype(S, /obj/item/assembly/wiremod))
		var/datum/component/shell/holder_shell = holder?.GetComponent(/datum/component/shell)
		var/datum/component/shell/assembly_shell = S.GetComponent(/datum/component/shell)
		if(!holder_shell?.attached_circuit?.admin_only && !assembly_shell?.attached_circuit?.admin_only)
			return
	return ..()

/datum/wires/wire_bundle_component/ui_data(mob/user)
	proper_name = holder.name
	. = ..()
	// Let's not make wiring up this stuff confusing - just give them what wires correspond to what ports.
	for(var/list/wire_data as anything in .["wires"])
		wire_data["wire"] = get_wire(wire_data["color"])

/datum/wires/wire_bundle_component/ui_host(mob/user)
	return holder.ui_host(user)

#undef CAPACITY_PER_WIRE

/obj/item/circuit_component/wire_bundle
	display_name = "Wiązka przewodów"
	desc = "Wiązka odsłoniętych przewodów, do których można podpiąć zespoły. Porty pojawią się dopiero po włożeniu układu do obudowy."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_REFUSE_MODULE

	var/datum/wires/wire_bundle_component/tracked_wires

	var/list/wire_input_ports = list()
	var/list/wire_output_ports = list()

/obj/item/circuit_component/wire_bundle/get_ui_notices()
	. = ..()
	. += create_ui_notice("Liczba portów zależy od pojemności obudowy.", "orange", "plug")
	. += create_ui_notice("Maks. liczba portów: [MAX_WIRE_COUNT]", "orange", "plug")
	. += create_ui_notice("Nie działa w obudowie-zespole.", "red", "plug-circle-xmark")
	. += create_ui_notice("Przewody otwiera się prawym kliknięciem kombinerkami, multitoolem lub zespołem.", "orange", "info")

/obj/item/circuit_component/wire_bundle/register_shell(atom/movable/shell)
	. = ..()
	if(isassembly(shell) && !parent.admin_only)
		return
	if(shell.wires) // Don't add wires to shells that already have some.
		return
	tracked_wires = new(shell)
	shell.wires = tracked_wires
	for(var/wire in tracked_wires.wires)
		wire_input_ports[add_input_port("Pulse [wire]", PORT_TYPE_SIGNAL)] = wire
		wire_output_ports[wire] = add_output_port("[wire] Pulsed", PORT_TYPE_SIGNAL)
	RegisterSignal(tracked_wires, COMSIG_PULSE_WIRE, PROC_REF(on_pulse_wire))
	RegisterSignal(shell, COMSIG_PARENT_ATTACKBY_SECONDARY, PROC_REF(on_shell_secondary_interaction))

/obj/item/circuit_component/wire_bundle/unregister_shell(atom/movable/shell)
	. = ..()
	if(!tracked_wires || shell.wires != tracked_wires)
		return
	UnregisterSignal(shell, COMSIG_PARENT_ATTACKBY_SECONDARY)
	for(var/color in tracked_wires.colors)
		var/obj/item/assembly/assembly = tracked_wires.detach_assembly(color)
		if(assembly)
			assembly.forceMove(drop_location())
	shell.wires = null
	QDEL_NULL(tracked_wires)
	for(var/datum/port/input/in_port in wire_input_ports)
		remove_input_port(in_port)
	for(var/wire in wire_output_ports)
		var/datum/port/output/out_port = wire_output_ports[wire]
		remove_output_port(out_port)
	wire_input_ports.Cut()
	wire_output_ports.Cut()

/obj/item/circuit_component/wire_bundle/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	if(!.)
		return
	if(HAS_TRAIT(added_to, TRAIT_COMPONENT_WIRE_BUNDLE))
		return FALSE
	ADD_TRAIT(added_to, TRAIT_COMPONENT_WIRE_BUNDLE, REF(src))

/obj/item/circuit_component/wire_bundle/removed_from(obj/item/integrated_circuit/removed_from)
	REMOVE_TRAIT(removed_from, TRAIT_COMPONENT_WIRE_BUNDLE, REF(src))
	return ..()

/obj/item/circuit_component/wire_bundle/input_received(datum/port/input/port)
	. = ..()
	if(!port || !tracked_wires)
		return
	var/wire = wire_input_ports[port]
	if(!wire)
		return
	if(tracked_wires.is_cut(wire))
		return
	var/color = tracked_wires.get_color_of_wire(wire)
	var/obj/item/assembly/attached = tracked_wires.get_attached(color)
	if(attached)
		INVOKE_ASYNC(attached, TYPE_PROC_REF(/obj/item/assembly, activate))

/obj/item/circuit_component/wire_bundle/proc/on_pulse_wire(source, wire)
	SIGNAL_HANDLER
	if(tracked_wires.is_cut(wire))
		return
	var/datum/port/output/port = wire_output_ports[wire]
	if(!istype(port))
		return
	port.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/wire_bundle/proc/can_access_wires(atom/source)
	if(ismachinery(source))
		var/obj/machinery/machine = source
		return machine.panel_open
	return TRUE

/obj/item/circuit_component/wire_bundle/proc/on_shell_secondary_interaction(atom/source, obj/item/tool, mob/user, params)
	SIGNAL_HANDLER
	if(!is_wire_tool(tool))
		return
	if(!can_access_wires(source))
		return
	var/datum/component/shell/shell_comp = source.GetComponent(/datum/component/shell)
	if(shell_comp?.locked)
		source.balloon_alert(user, "zablokowane!")
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(source, TYPE_PROC_REF(/atom, attempt_wire_interaction), user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
