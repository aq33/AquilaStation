/// Science object that behaves similairly to to strange objects/relics, but is activated by cracking wire sequences and other functions
/obj/machinery/gizmo
	name = "gizmo"
	desc = "Robi funkcję, kiedy przyłożysz dżygacz do drugiego końca tej rzeczy."
	icon_state = "gizmo_1"
	icon = 'aquila/icons/obj/science/gizmos.dmi'

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

	panel_open = TRUE
	density = TRUE
	anchored = FALSE
	// AQUILA: gizmo nie pobiera prądu i nie musi być przetwarzane przez SSmachines
	use_power = NO_POWER_USE
	processing_flags = NONE

	/// Possible icon states to pick from
	var/list/icon_states = list("gizmo_0", "gizmo_1", "gizmo_2", "gizmo_3", "gizmo_4")
	/// Reference to the gizmo. We dont actually need to track this for anything but ease of vv
	var/datum/gizmo_controller/controller = /datum/gizmo_controller
	/// Possible names to pick from to keep things confusing
	var/list/possible_names = list(
		"gizmo", "jigger", "doohickey", "particle inverter", "polarity superplexer", "flitcher poster", "natty gonk", "quantum quantum",
		"entropy nilum", "tachyon streamer", "doing device", "task operator", "interface responder", "kinetic observer", "turbo encabulator",
		"statistic responder", "possibility matrix", "toety aaier", "phase anchor",
	)

/obj/machinery/gizmo/Initialize(mapload)
	. = ..()

	name = pick(possible_names)

	if(icon_states)
		base_icon_state = pick(icon_states)
		icon_state = base_icon_state

	controller = new controller(src)
	controller.generate_interfaces(src)

	RegisterSignal(src, COMSIG_GIZMO_START_MOVING, PROC_REF(start_moving))
	RegisterSignal(src, COMSIG_GIZMO_STOP_MOVING, PROC_REF(stop_moving))

/obj/machinery/gizmo/examine(mob/user)
	. = ..()
	. += span_notice("Panel jest otwarty, a w środku plącze się pęk dziwnych kabli. Multitool albo kombinerki pozwolą się do nich dobrać.")

// AQUILA: w tg item_interaction, u nas attackby (multitool i kombinerki dochodzą tu, bo nie mamy dla nich *_act)
/obj/machinery/gizmo/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)

	if(is_wire_tool(I))
		attempt_wire_interaction(user)
		return TRUE
	return ..()

/obj/machinery/gizmo/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE

/obj/machinery/gizmo/proc/start_moving(datum/source, datum/gizpulse/pulse)
	SIGNAL_HANDLER

	on_start_moving(pulse)

/obj/machinery/gizmo/proc/stop_moving(datum/source, datum/gizpulse/pulse)
	SIGNAL_HANDLER

	on_stop_moving(pulse)

/obj/machinery/gizmo/proc/on_start_moving(datum/gizpulse/pulse)
	return

/obj/machinery/gizmo/proc/on_stop_moving(datum/gizpulse/pulse)
	return

/// Gizmo that comes with a gizmo interface to start moving
/obj/machinery/gizmo/beyblade
	icon_state = "beyblade"
	icon_states = list("beyblade")

	controller = /datum/gizmo_controller/beyblade

	/// Are we currently moving?
	var/moving = FALSE

/obj/machinery/gizmo/beyblade/update_icon_state()
	. = ..()

	if(base_icon_state)
		icon_state = base_icon_state + (moving ? "_spinning" : "")

/obj/machinery/gizmo/beyblade/on_start_moving(datum/gizpulse/pulse)
	density = TRUE

	moving = TRUE
	update_appearance(UPDATE_ICON)

/obj/machinery/gizmo/beyblade/on_stop_moving(datum/gizpulse/pulse)
	density = FALSE

	moving = FALSE
	update_appearance(UPDATE_ICON)

/// A gizmo with some sort of "on" state. Really only for visuals
/obj/machinery/gizmo/toggle
	controller = /datum/gizmo_controller/toggle

	icon_state = "gizmo_active_1"
	icon_states = list("gizmo_active_0", "gizmo_active_1", "gizmo_active_2", "gizmo_active_3", "gizmo_active_4", "gizmo_active_5")

	var/on_state = FALSE

/obj/machinery/gizmo/toggle/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_GIZMO_ON_STATE, PROC_REF(on_state))
	RegisterSignal(src, COMSIG_GIZMO_OFF_STATE, PROC_REF(off_state))

/obj/machinery/gizmo/toggle/update_icon_state()
	. = ..()

	if(base_icon_state)
		icon_state = base_icon_state + (on_state ? "_on" : "")

/obj/machinery/gizmo/toggle/tucker_tubes
	icon_states = list("gizmo_active_0")
	icon_state = "gizmo_active_0" //for the mapping icon
	anchored = TRUE

/obj/machinery/gizmo/toggle/proc/on_state(datum/source)
	SIGNAL_HANDLER

	on_state = TRUE
	update_appearance(UPDATE_ICON)

/obj/machinery/gizmo/toggle/proc/off_state(datum/source)
	SIGNAL_HANDLER

	on_state = FALSE
	update_appearance(UPDATE_ICON)

/// A gizmo with a voice activated interface
/obj/machinery/gizmo/voice
	controller = /datum/gizmo_controller/voice

/obj/machinery/gizmo/cursed
	controller = /datum/gizmo_controller/cursed
