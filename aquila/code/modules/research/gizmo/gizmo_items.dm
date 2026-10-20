/// A handheld gizmo, with some different activation modes
/obj/item/gizmo
	name = "gizmo"
	desc = "Fligguje giggola, kiedy jego piec jest gorący w urządzeniu."
	icon = 'aquila/icons/obj/science/gizmos.dmi'
	icon_state = "gizmo_item_1"

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Possible icon states
	var/list/icon_states = list("gizmo_item_1")
	/// Reference to the gizmo master controller that handles all the other gizmo stuff
	var/datum/gizmo_controller/controller = /datum/gizmo_controller/item

/obj/item/gizmo/Initialize(mapload)
	. = ..()

	if(icon_states)
		base_icon_state = pick(icon_states)
		icon_state = base_icon_state

	controller = new controller(src)
	controller.generate_interfaces(src)

/obj/item/gizmo/examine(mob/user)
	. = ..()
	. += span_notice("Ma odsłonięty pęk kabli. Multitool albo kombinerki pozwolą się do nich dobrać.")

// AQUILA: w tg kable otwiera item_interaction, u nas attackby
/obj/item/gizmo/attackby(obj/item/I, mob/living/user, params)
	if(is_wire_tool(I))
		add_fingerprint(user)
		attempt_wire_interaction(user)
		return TRUE
	return ..()
