/obj/item/circuit_component/list_literal/wirenet_send
	display_name = "Wirenet Transmitter List Literal"
	desc = "Creates a list literal data package and sends it through the connected cable network. If Encryption Key is set then transmitted data will be only picked up by receivers with the same Encryption Key."
	category = "Utility"

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove",
	)

	/// Powernet reference provided by the circuit_component_wirenet_connection component
	var/datum/powernet/connected_powernet

	/// Encryption key
	var/datum/port/input/enc_key

/obj/item/circuit_component/list_literal/wirenet_send/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/circuit_component_wirenet_connection,\
		connection_callback = CALLBACK(src, PROC_REF(on_powernet_connection)),\
		disconnection_callback = CALLBACK(src, PROC_REF(on_powernet_disconnection)),\
	)

/obj/item/circuit_component/list_literal/wirenet_send/Destroy()
	. = ..()
	connected_powernet = null

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_powernet_connection(datum/powernet/new_powernet)
	connected_powernet = new_powernet

/obj/item/circuit_component/list_literal/wirenet_send/proc/on_powernet_disconnection(datum/powernet/old_powernet)
	connected_powernet = null

/obj/item/circuit_component/list_literal/wirenet_send/populate_ports()
	. = ..()
	enc_key = add_input_port("Encryption Key", PORT_TYPE_STRING)

/obj/item/circuit_component/list_literal/wirenet_send/input_received(datum/port/input/port)
	connected_powernet?.data_transmission(list_output.value, enc_key.value, WEAKREF(list_output))
