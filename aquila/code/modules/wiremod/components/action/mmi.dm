#define MMI_MESSAGE_COOLDOWN (0.1 SECONDS)

// MMI z tg (code/modules/wiremod/components/action/mmi.dm) w wersji na nasz kod:
// - zamiast /obj/item/brain_processor jest nasze /obj/item/mmi (pozytronowy mózg to u nas jego podtyp, więc też działa),
// - B.O.R.I.S. (/obj/item/borg/upgrade/ai) pozwala SI połączyć się z układem kliknięciem w samą obudowę.
//   Bez komponentu boris_circuit_container z tg (u nas brak COMPONENT_DUPE_SOURCES, alt appearance dla SI
//   i shuttle_move_deferred_checks), więc SI łączy się tylko klikając obudowę leżącą na widoku, nie skrzynię, w której ona jest.
//   Zerwanie połączenia po ruchu sprawdzamy przy każdym ruchu i kliknięciu SI.

/datum/action/innate/mmi_comp_disconnect
	name = "Disconnect from remote circuit"
	desc = "Przestań sterować układem scalonym."
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"
	check_flags = NONE

/datum/action/innate/mmi_comp_disconnect/Activate()
	var/obj/item/circuit_component/mmi/mmi_comp = target
	if(istype(mmi_comp))
		mmi_comp.remove_occupant()

/**
 * # Man-Machine Interface Component
 *
 * Allows an MMI to be inserted into a shell, allowing it to be linked up. Requires a shell.
 */
/obj/item/circuit_component/mmi
	display_name = "Man-Machine Interface"
	desc = "Komponent, do którego można włożyć MMI albo moduł B.O.R.I.S., by mózg lub sztuczna inteligencja mogły wysyłać sygnały."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_REFUSE_MODULE

	/// The message to send to the MMI in the shell.
	var/datum/port/input/message
	/// Sends the current MMI a message
	var/datum/port/input/send
	/// Ejects the current MMI
	var/datum/port/input/eject

	/// Called when the MMI tries moving north
	var/datum/port/output/north
	/// Called when the MMI tries moving east
	var/datum/port/output/east
	/// Called when the MMI tries moving south
	var/datum/port/output/south
	/// Called when the MMI tries moving west
	var/datum/port/output/west

	/// Returns what the MMI last clicked on.
	var/datum/port/output/clicked_atom
	/// Called when the MMI clicks.
	var/datum/port/output/attack
	/// Called when the MMI right clicks.
	var/datum/port/output/secondary_attack

	/// The current MMI/posibrain
	var/obj/item/mmi/brain

	/// The current B.O.R.I.S. module
	var/obj/item/borg/upgrade/ai/boris

	/// The brainmob or AI currently controlling to the circuit
	var/mob/living/occupant

	/// The action used to allow a connected AI to disconnect
	var/datum/action/innate/mmi_comp_disconnect/disconnect_action

	/// The shell we registered the AI click signal on
	var/atom/movable/boris_shell

	/// Maximum length of the message that can be sent to the MMI
	var/max_length = 300

	/// Cooldown for when the next message can be sent to the MMI.
	COOLDOWN_DECLARE(message_cooldown)

/obj/item/circuit_component/mmi/Initialize(mapload)
	. = ..()
	disconnect_action = new(src)

/obj/item/circuit_component/mmi/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING)
	send = add_input_port("Send Message", PORT_TYPE_SIGNAL)
	eject = add_input_port("Eject", PORT_TYPE_SIGNAL)

	north = add_output_port("North", PORT_TYPE_SIGNAL)
	east = add_output_port("East", PORT_TYPE_SIGNAL)
	south = add_output_port("South", PORT_TYPE_SIGNAL)
	west = add_output_port("West", PORT_TYPE_SIGNAL)

	attack = add_output_port("Attack", PORT_TYPE_SIGNAL)
	secondary_attack = add_output_port("Secondary Attack", PORT_TYPE_SIGNAL)
	clicked_atom = add_output_port("Target Entity", PORT_TYPE_ATOM)

/obj/item/circuit_component/mmi/Destroy()
	remove_occupant_item()
	QDEL_NULL(disconnect_action)
	return ..()

/obj/item/circuit_component/mmi/input_received(datum/port/input/port)
	if(!brain && !boris)
		return

	if(COMPONENT_TRIGGERED_BY(eject, port))
		remove_occupant_item()
	if(COMPONENT_TRIGGERED_BY(send, port))
		if(!message.value || !COOLDOWN_FINISHED(src, message_cooldown))
			return

		var/msg_str = copytext(html_encode(message.value), 1, max_length)

		if(!occupant)
			return

		if(isAI(occupant))
			to_chat(occupant, "[span_boldnotice("Wiadomość od zdalnego układu: ")][span_notice(msg_str)]")
		else
			to_chat(occupant, "<span class='bold'>Słyszysz w uchu wiadomość: </span>[msg_str]")
		COOLDOWN_START(src, message_cooldown, MMI_MESSAGE_COOLDOWN)

/obj/item/circuit_component/mmi/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_PARENT_ATTACKBY, PROC_REF(handle_attack_by))

/obj/item/circuit_component/mmi/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PARENT_ATTACKBY)
	remove_occupant_item()
	return ..()

/obj/item/circuit_component/mmi/proc/handle_attack_by(atom/movable/shell, obj/item/item, mob/living/user)
	SIGNAL_HANDLER
	var/obj/item/mmi/target_mmi
	var/mob/living/new_occupant
	var/obj/item/borg/upgrade/ai/target_boris
	if(istype(item, /obj/item/mmi))
		target_mmi = item
		if(!target_mmi.brainmob)
			shell.balloon_alert(user, "brak świadomości!")
			return COMPONENT_NO_AFTERATTACK
		new_occupant = target_mmi.brainmob
	else if(istype(item, /obj/item/borg/upgrade/ai))
		target_boris = item
	else
		return
	var/datum/component/shell/shell_comp = shell.GetComponent(/datum/component/shell)
	if(shell_comp?.locked)
		shell.balloon_alert(user, "zablokowane!")
		return COMPONENT_NO_AFTERATTACK
	if(brain || boris)
		shell.balloon_alert(user, "już jest mózg!")
		return COMPONENT_NO_AFTERATTACK
	if(!user.transferItemToLoc(item, src))
		return COMPONENT_NO_AFTERATTACK
	if(target_mmi)
		brain = target_mmi
		set_occupant(new_occupant)
	if(target_boris)
		boris = target_boris
		register_boris_circuit(shell)
	RegisterSignal(item, COMSIG_PARENT_QDELETING, PROC_REF(remove_occupant_item))
	RegisterSignal(item, COMSIG_MOVABLE_MOVED, PROC_REF(occupant_item_moved))
	return COMPONENT_NO_AFTERATTACK

/obj/item/circuit_component/mmi/proc/register_boris_circuit(atom/movable/shell)
	if(!shell)
		return
	boris_shell = shell
	RegisterSignal(shell, COMSIG_ATOM_ATTACK_AI, PROC_REF(on_ai_click))

/obj/item/circuit_component/mmi/proc/unregister_boris_circuit()
	if(!boris_shell)
		return
	UnregisterSignal(boris_shell, COMSIG_ATOM_ATTACK_AI)
	boris_shell = null

/// SI kliknęła obudowę z modułem B.O.R.I.S.
/obj/item/circuit_component/mmi/proc/on_ai_click(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	if(!boris || !isAI(user))
		return
	if(HAS_TRAIT(user, TRAIT_CONNECTED_TO_CIRCUIT))
		return
	INVOKE_ASYNC(src, PROC_REF(confirm_ai_connect), user, source)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/circuit_component/mmi/proc/occupant_item_moved(atom/movable/occupant_item)
	SIGNAL_HANDLER

	if(occupant_item.loc != src)
		remove_occupant_item(occupant_item)

/obj/item/circuit_component/mmi/proc/remove_occupant_item(obj/item/removing)
	SIGNAL_HANDLER
	if(!istype(removing))
		removing = null
	if(!removing)
		removing = brain
	if(!removing)
		removing = boris
	if(!removing)
		return
	if(removing == brain)
		brain = null
	if(removing == boris)
		boris = null
		unregister_boris_circuit()
	remove_occupant()

	UnregisterSignal(removing, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_MOVABLE_MOVED
	))
	if(removing.loc == src)
		removing.forceMove(drop_location())

/obj/item/circuit_component/mmi/proc/confirm_ai_connect(mob/living/silicon/ai/user, atom/movable/shell)
	var/confirmation = tgui_alert(user, "Połączyć się z [shell]?", "B.O.R.I.S.", list("Tak", "Nie"))
	if(confirmation != "Tak")
		return
	if(QDELETED(src) || QDELETED(user) || QDELETED(shell) || !parent?.shell || !boris)
		return
	if(!ai_can_control(user))
		return
	do_ai_connect(user, shell)

/obj/item/circuit_component/mmi/proc/do_ai_connect(mob/living/silicon/ai/user, atom/movable/shell)
	if(occupant)
		if(occupant != user)
			shell.balloon_alert(user, "zajęte!")
		return
	set_occupant(user)

/// Czy SI może dalej sterować układem (sprawna, nie w karcie, obudowa w zasięgu).
/obj/item/circuit_component/mmi/proc/ai_can_control(mob/living/silicon/ai/ai)
	if(!istype(ai) || !parent?.shell)
		return FALSE
	if(ai.control_disabled || ai.incapacitated() || ai.stat == DEAD)
		return FALSE
	return ai.can_interact_with(parent.shell)

/obj/item/circuit_component/mmi/proc/set_occupant(mob/living/new_occupant)
	new_occupant.remote_control = src
	RegisterSignal(new_occupant, COMSIG_MOB_CLICKON, PROC_REF(handle_occupant_attack))
	RegisterSignal(new_occupant, COMSIG_PARENT_QDELETING, PROC_REF(remove_occupant))
	occupant = new_occupant
	if(!isAI(new_occupant))
		return
	ADD_TRAIT(new_occupant, TRAIT_CONNECTED_TO_CIRCUIT, REF(src))
	var/mob/living/silicon/ai/ai = new_occupant
	ai.reset_perspective(src)
	RegisterSignal(ai, COMSIG_MOVABLE_MOVED, PROC_REF(remove_occupant))
	RegisterSignal(ai, COMSIG_MOB_STATCHANGE, PROC_REF(remove_occupant))
	disconnect_action.Grant(ai)
	to_chat(ai, span_notice("Nawiązano połączenie ze zdalnym układem."))

/obj/item/circuit_component/mmi/proc/remove_occupant()
	SIGNAL_HANDLER
	if(!occupant)
		return
	if(isAI(occupant))
		REMOVE_TRAIT(occupant, TRAIT_CONNECTED_TO_CIRCUIT, REF(src))
		var/mob/living/silicon/ai/ai = occupant
		disconnect_action.Remove(ai)
		UnregisterSignal(ai, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_STATCHANGE))
		ai.reset_perspective(null)
		to_chat(ai, span_notice("Rozłączono ze zdalnym układem."))
	occupant.remote_control = null
	UnregisterSignal(occupant, list(COMSIG_MOB_CLICKON, COMSIG_PARENT_QDELETING))
	occupant = null

/obj/item/circuit_component/mmi/relaymove(mob/living/user, direct)
	if(user != occupant)
		return ..()
	if(isAI(user) && !ai_can_control(user))
		remove_occupant()
		return FALSE

	if(direct & NORTH)
		north.set_output(COMPONENT_SIGNAL)
	if(direct & WEST)
		west.set_output(COMPONENT_SIGNAL)
	if(direct & EAST)
		east.set_output(COMPONENT_SIGNAL)
	if(direct & SOUTH)
		south.set_output(COMPONENT_SIGNAL)

	return TRUE

/obj/item/circuit_component/mmi/proc/handle_occupant_attack(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(isAI(source) && !ai_can_control(source))
		remove_occupant()
		return COMSIG_MOB_CANCEL_CLICKON
	if(modifiers[RIGHT_CLICK])
		clicked_atom.set_output(target)
		secondary_attack.set_output(COMPONENT_SIGNAL)
		. = COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[LEFT_CLICK] && !modifiers[SHIFT_CLICK] && !modifiers[ALT_CLICK] && !modifiers[CTRL_CLICK])
		clicked_atom.set_output(target)
		attack.set_output(COMPONENT_SIGNAL)
		. = COMSIG_MOB_CANCEL_CLICKON

/obj/item/circuit_component/mmi/add_to(obj/item/integrated_circuit/add_to)
	. = ..()
	if(HAS_TRAIT(add_to, TRAIT_COMPONENT_MMI))
		return FALSE
	ADD_TRAIT(add_to, TRAIT_COMPONENT_MMI, REF(src))

/obj/item/circuit_component/mmi/removed_from(obj/item/integrated_circuit/removed_from)
	REMOVE_TRAIT(removed_from, TRAIT_COMPONENT_MMI, REF(src))
	remove_occupant_item()
	return ..()

/// Hak z /mob/living/silicon/ai/ClickOn: SI połączona z układem klika przez układ, a nie przez kamery.
/// TRUE = kliknięcie obsłużone, reszta ClickOn się nie wykona.
/mob/living/silicon/ai/proc/circuit_click_intercept(atom/target, params)
	if(!HAS_TRAIT(src, TRAIT_CONNECTED_TO_CIRCUIT))
		return FALSE
	SEND_SIGNAL(src, COMSIG_MOB_CLICKON, target, params2list(params))
	return TRUE

/// Hak z /mob/living/silicon/ai/ClickOn przed attack_ai(): sygnał dla obudów z modułem B.O.R.I.S.
/mob/living/silicon/ai/proc/circuit_attack_ai(atom/target)
	return SEND_SIGNAL(target, COMSIG_ATOM_ATTACK_AI, src) & COMPONENT_CANCEL_ATTACK_CHAIN

#undef MMI_MESSAGE_COOLDOWN
