// Port z tg: komponenty układów dla programów komputerów modułowych.
// U nas są: komunikator, notatnik, radary, sygnalizator, wyświetlacz stanu, monitor NTNet (u tg WireCarp),
// monitor cyborgów. Bez nt_pay, aparatu (camera), MODsuit control i spectre meter - nie mamy tych programów.

///////////////
// Komunikator
///////////////

#define MESSENGER_CIRCUIT_MIN_COOLDOWN (5 SECONDS)
#define MESSENGER_CIRCUIT_MAX_COOLDOWN (45 SECONDS)
#define MESSENGER_CIRCUIT_CD_PER_RECIPIENT (1.5 SECONDS)
#define MESSENGER_CIRCUIT_RINGTONE_CD (1.5 SECONDS)

/datum/computer_file/program/messenger
	program_flags = PROGRAM_CIRCUITS_RUN_WHEN_CLOSED
	circuit_comp_type = /obj/item/circuit_component/mod_program/messenger

/datum/computer_file/program/messenger/receive_message(datum/signal/subspace/messaging/tablet_msg/signal)
	. = ..()
	SEND_SIGNAL(computer, COMSIG_MODULAR_PDA_MESSAGE_RECEIVED, signal, signal.data["job"], signal.data["name"])

/// Wysyła wiadomość z układu (bez użytkownika). Odpowiednik send_message().
/datum/computer_file/program/messenger/proc/circuit_send_message(obj/item/circuit_component/source, message, list/obj/item/modular_computer/targets)
	if(!sending_and_receiving || !length(targets) || !computer)
		return FALSE
	if(!computer.saved_identification || !computer.saved_job)
		return FALSE
	message = trim(message, MAX_MESSAGE_LEN)
	if(mime_mode)
		message = emoji_sanitize(message)
	message = sanitize(message)
	if(!message)
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		return FALSE

	var/turf/position = get_turf(computer)
	for(var/obj/item/jammer/jammer as anything in GLOB.active_jammers)
		var/turf/jammer_turf = get_turf(jammer)
		if(position?.z == jammer_turf.z && (get_dist(position, jammer_turf) <= jammer.range))
			return FALSE

	var/list/valid_targets = list()
	for(var/obj/item/modular_computer/comp as anything in targets)
		if(comp != computer && comp.saved_identification && comp.saved_job)
			valid_targets += comp
	if(!length(valid_targets))
		return FALSE

	var/datum/signal/subspace/messaging/tablet_msg/signal = new(computer, list(
		"name" = computer.saved_identification,
		"job" = computer.saved_job,
		"message" = html_decode(message),
		"ref" = REF(computer),
		"targets" = valid_targets,
		"emojis" = allow_emojis,
		"photo" = null,
		"automated" = FALSE,
	))
	signal.send_to_receivers()
	if(!signal.data["done"])
		return FALSE

	var/target_text = signal.format_target()
	var/list/message_data = list()
	message_data["name"] = signal.data["name"]
	message_data["job"] = signal.data["job"]
	message_data["target"] = target_text
	message_data["contents"] = html_decode(signal.data["message"])
	message_data["outgoing"] = TRUE
	message_data["ref"] = signal.data["ref"]
	message_data["photo_obj"] = null
	message_data["emojis"] = signal.data["emojis"]
	message_data["target_ref"] = length(valid_targets) == 1 ? REF(valid_targets[1]) : null
	message_data["everyone"] = FALSE
	message_data["timestamp"] = station_time_timestamp("hh:mm")

	if(allow_emojis)
		signal.data["message"] = emoji_parse(signal.data["message"])

	var/ghost_message = "<span class='name'>[message_data["name"]] </span><span class='game say'>Wiadomość PDA</span> --> <span class='name'>[target_text]</span>: <span class='message'>[signal.format_message(include_photo = TRUE)]</span>"
	for(var/mob/M in GLOB.player_list)
		if(isobserver(M) && (M.client?.prefs.chat_toggles & CHAT_GHOSTPDA))
			to_chat(M, "[FOLLOW_LINK(M, computer)] [ghost_message]")

	var/obj/item/circuit_component/component = source
	computer.log_talk(message, LOG_PDA, tag = "PDA (circuit by [component?.parent?.get_creator()]): [message_data["name"]] to [target_text]")

	if(ringer_status)
		computer.send_sound()
	last_text = world.time
	messages += list(message_data)
	return TRUE

/obj/item/circuit_component/mod_program/messenger
	associated_program = /datum/computer_file/program/messenger
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Treść ostatniej odebranej wiadomości
	var/datum/port/output/received_message
	/// Nadawca powyższej
	var/datum/port/output/sender_name
	/// Stanowisko nadawcy
	var/datum/port/output/sender_job
	/// Urządzenie, z którego przyszła wiadomość (zwykle PDA)
	var/datum/port/output/sender_device
	/// Wysyłany po odebraniu wiadomości
	var/datum/port/output/received

	/// Wiadomość do wysłania
	var/datum/port/input/message
	/// Lista PDA, do których idzie wiadomość
	var/datum/port/input/targets

	/// Odtwarza dzwonek
	var/datum/port/input/ring
	/// Ustawia dzwonek
	var/datum/port/input/set_ring

	COOLDOWN_DECLARE(ring_cd)
	COOLDOWN_DECLARE(send_cd)

/obj/item/circuit_component/mod_program/messenger/populate_ports()
	. = ..()
	received_message = add_output_port("Message", PORT_TYPE_STRING)
	sender_name = add_output_port("Sender Name", PORT_TYPE_STRING)
	sender_job = add_output_port("Sender Job", PORT_TYPE_STRING)
	sender_device = add_output_port("Sender Device", PORT_TYPE_ATOM)
	received = add_output_port("Received", PORT_TYPE_SIGNAL)

	message = add_input_port("Message", PORT_TYPE_STRING)
	targets = add_input_port("Targets", PORT_TYPE_LIST(PORT_TYPE_ATOM))

	ring = add_input_port("Play Ringtone", PORT_TYPE_SIGNAL, trigger = PROC_REF(play_ringtone))
	set_ring = add_input_port("Set Ringtone", PORT_TYPE_STRING, trigger = PROC_REF(set_ringtone))

/obj/item/circuit_component/mod_program/messenger/input_received(datum/port/port)
	if(!COOLDOWN_FINISHED(src, send_cd))
		return
	var/list/messenger_targets = list()
	for(var/datum/weakref/ref as anything in targets.value)
		var/obj/item/modular_computer/modpc = ref?.resolve()
		if(!istype(modpc))
			continue
		var/obj/item/computer_hardware/hard_drive/drive = modpc.all_components[MC_HDD]
		if(drive && (locate(/datum/computer_file/program/messenger) in drive.stored_files))
			messenger_targets |= modpc
	if(!length(messenger_targets))
		return
	COOLDOWN_START(src, send_cd, clamp(length(messenger_targets) * MESSENGER_CIRCUIT_CD_PER_RECIPIENT, MESSENGER_CIRCUIT_MIN_COOLDOWN, MESSENGER_CIRCUIT_MAX_COOLDOWN))
	// Telekomunikacja potrafi spać
	INVOKE_ASYNC(associated_program, TYPE_PROC_REF(/datum/computer_file/program/messenger, circuit_send_message), src, message.value, messenger_targets)

/obj/item/circuit_component/mod_program/messenger/on_program_registered(obj/item/modular_computer/computer)
	RegisterSignal(computer, COMSIG_MODULAR_PDA_MESSAGE_RECEIVED, PROC_REF(message_received))

/obj/item/circuit_component/mod_program/messenger/on_program_unregistered()
	if(associated_program.computer)
		UnregisterSignal(associated_program.computer, COMSIG_MODULAR_PDA_MESSAGE_RECEIVED)

/obj/item/circuit_component/mod_program/messenger/get_ui_notices()
	. = ..()
	. += create_ui_notice("Czas odnowienia na odbiorcę: [DisplayTimeText(MESSENGER_CIRCUIT_CD_PER_RECIPIENT)]", "orange", "stopwatch")
	. += create_ui_notice("Minimalny czas odnowienia: [DisplayTimeText(MESSENGER_CIRCUIT_MIN_COOLDOWN)]", "orange", "stopwatch")
	. += create_ui_notice("Maksymalny czas odnowienia: [DisplayTimeText(MESSENGER_CIRCUIT_MAX_COOLDOWN)]", "orange", "stopwatch")

/obj/item/circuit_component/mod_program/messenger/proc/message_received(datum/source, datum/signal/subspace/messaging/tablet_msg/signal, message_job, message_name)
	SIGNAL_HANDLER
	received_message.set_output(html_decode(signal.data["message"]))
	sender_name.set_output(message_name)
	sender_job.set_output(message_job)
	sender_device.set_output(isatom(signal.source) ? signal.source : null)
	received.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/messenger/proc/set_ringtone(datum/port/port)
	var/datum/computer_file/program/messenger/messenger = associated_program
	// Bez sygnału zmiany dzwonka - układ nie odblokuje uplinka
	var/new_ringtone = trim(sanitize(set_ring.value), 20)
	if(new_ringtone)
		messenger.ringtone = new_ringtone

/obj/item/circuit_component/mod_program/messenger/proc/play_ringtone(datum/port/port)
	if(!COOLDOWN_FINISHED(src, ring_cd))
		return
	COOLDOWN_START(src, ring_cd, MESSENGER_CIRCUIT_RINGTONE_CD)
	var/datum/computer_file/program/messenger/messenger = associated_program
	messenger.computer.ring(messenger.ringtone)

#undef MESSENGER_CIRCUIT_MIN_COOLDOWN
#undef MESSENGER_CIRCUIT_MAX_COOLDOWN
#undef MESSENGER_CIRCUIT_CD_PER_RECIPIENT
#undef MESSENGER_CIRCUIT_RINGTONE_CD

/////////////
// Notatnik
/////////////

/datum/computer_file/program/notepad
	circuit_comp_type = /obj/item/circuit_component/mod_program/notepad

/datum/computer_file/program/notepad/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(. && action == "UpdateNote")
		SEND_SIGNAL(src, COMSIG_COMPUTER_NOTEPAD_UPDATED, params["newnote"])

/obj/item/circuit_component/mod_program/notepad
	associated_program = /datum/computer_file/program/notepad
	/// Po odebraniu ustawia notatkę na tę wartość
	var/datum/port/input/set_text
	/// Treść notatki, wysyłana przy każdej zmianie
	var/datum/port/output/updated_text
	/// Wysyłany przy zmianie notatki
	var/datum/port/output/updated

/obj/item/circuit_component/mod_program/notepad/populate_ports()
	. = ..()
	set_text = add_input_port("Set Notes", PORT_TYPE_STRING)
	updated_text = add_output_port("Notes", PORT_TYPE_STRING)
	updated = add_output_port("Updated", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_program/notepad/on_program_registered(obj/item/modular_computer/computer)
	RegisterSignal(associated_program, COMSIG_COMPUTER_NOTEPAD_UPDATED, PROC_REF(on_note_updated))

/obj/item/circuit_component/mod_program/notepad/on_program_unregistered()
	UnregisterSignal(associated_program, COMSIG_COMPUTER_NOTEPAD_UPDATED)

/obj/item/circuit_component/mod_program/notepad/proc/on_note_updated(datum/source, new_note)
	SIGNAL_HANDLER
	updated_text.set_output(new_note)
	updated.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/notepad/input_received(datum/port/port)
	// U nas notatka siedzi w tablecie
	var/obj/item/modular_computer/tablet/tablet = associated_program.computer
	if(!istype(tablet))
		return
	tablet.note = set_text.value
	SStgui.update_uis(tablet)
	updated_text.set_output(tablet.note)
	updated.set_output(COMPONENT_SIGNAL)

//////////
// Radary
//////////

/// Cel jest poza zasięgiem
#define RADAR_NOT_TRACKABLE 0
/// Cel da się śledzić
#define RADAR_TRACKABLE 1
/// Cel da się śledzić, nawet jeśli podtyp normalnie by go odrzucił
#define RADAR_TRACKABLE_ANYWAY 2
/// Maksymalny dystans dla celów, których program normalnie nie śledzi
#define MAX_RADAR_CIRCUIT_DISTANCE 18

/datum/computer_file/program/radar/lifeline
	circuit_comp_type = /obj/item/circuit_component/mod_program/radar/medical

/datum/computer_file/program/radar/custodial_locator
	circuit_comp_type = /obj/item/circuit_component/mod_program/radar/janitor

/datum/computer_file/program/radar/fission360
	circuit_comp_type = /obj/item/circuit_component/mod_program/radar/nukie

/// Ten sam warunek poziomów co w trackable()
/datum/computer_file/program/radar/proc/circuit_z_ok(turf/here, turf/there)
	if(!here || !there)
		return FALSE
	return (there.z == here.z) || (is_station_level(here.z) && is_station_level(there.z))

/// Pyta układ, czy cel śledzić: zwraca RADAR_TRACKABLE_ANYWAY, RADAR_NOT_TRACKABLE albo null (bez zdania)
/datum/computer_file/program/radar/proc/circuit_track_verdict(atom/movable/signal)
	if(!signal || !computer)
		return
	var/turf/here = get_turf(computer)
	var/turf/there = get_turf(signal)
	if(!circuit_z_ok(here, there))
		return
	var/result = SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE, signal, there, here)
	if(result & COMPONENT_RADAR_TRACK_ANYWAY)
		return RADAR_TRACKABLE_ANYWAY
	if(result & COMPONENT_RADAR_DONT_TRACK)
		return RADAR_NOT_TRACKABLE

/// Cel ustawiony przez układ, jeśli jest
/datum/computer_file/program/radar/proc/circuit_find_atom()
	if(!computer)
		return
	var/list/atom_container = list(null)
	SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM, atom_container)
	return atom_container[1]

/datum/computer_file/program/radar/trackable(atom/movable/signal)
	. = ..()
	if(!.)
		return
	var/verdict = circuit_track_verdict(signal)
	if(!isnull(verdict))
		return verdict

/datum/computer_file/program/radar/find_atom()
	return circuit_find_atom() || ..()

/datum/computer_file/program/radar/ui_act(action, params)
	. = ..()
	if(. && action == "selecttarget")
		SEND_SIGNAL(computer, COMSIG_MODULAR_COMPUTER_RADAR_SELECTED, selected)

/datum/computer_file/program/radar/lifeline/find_atom()
	return circuit_find_atom() || ..()

// Lifeline odrzuca od razu wszystko, co nie jest człowiekiem - cele spoza listy pyta układ
/datum/computer_file/program/radar/lifeline/trackable(atom/movable/signal)
	if(signal && !ishuman(signal))
		return circuit_track_verdict(signal) == RADAR_TRACKABLE_ANYWAY ? RADAR_TRACKABLE_ANYWAY : RADAR_NOT_TRACKABLE
	return ..()

/datum/computer_file/program/radar/custodial_locator/find_atom()
	return circuit_find_atom() || ..()

/datum/computer_file/program/radar/fission360/find_atom()
	return circuit_find_atom() || ..()

/**
 * Bazowy układ radaru. Sam abstrakcyjny radar go nie ma,
 * więc podtypy muszą podać associated_program i circuit_comp_type.
 */
/obj/item/circuit_component/mod_program/radar
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Cel do śledzenia
	var/datum/port/input/target
	/// Cel wybrany w programie
	var/datum/port/output/selected_by_app
	/// Pozycja celu
	var/datum/port/output/x_pos
	var/datum/port/output/y_pos

/obj/item/circuit_component/mod_program/radar/populate_ports()
	. = ..()
	target = add_input_port("Target", PORT_TYPE_ATOM)
	selected_by_app = add_output_port("Selected From Program", PORT_TYPE_ATOM)
	x_pos = add_output_port("X", PORT_TYPE_NUMBER)
	y_pos = add_output_port("Y", PORT_TYPE_NUMBER)

/obj/item/circuit_component/mod_program/radar/on_program_registered(obj/item/modular_computer/computer)
	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE, PROC_REF(can_track))
	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM, PROC_REF(get_atom))
	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_RADAR_SELECTED, PROC_REF(on_selected))

/obj/item/circuit_component/mod_program/radar/on_program_unregistered()
	if(associated_program.computer)
		UnregisterSignal(associated_program.computer, list(
			COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE,
			COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM,
			COMSIG_MODULAR_COMPUTER_RADAR_SELECTED,
		))

/obj/item/circuit_component/mod_program/radar/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maks. zasięg dla nieobsługiwanych celów: [MAX_RADAR_CIRCUIT_DISTANCE] pól", "orange", "bullseye")

/// Ustawia cel programu na wejście i aktualizuje X/Y, jeśli cel da się śledzić
/obj/item/circuit_component/mod_program/radar/input_received(datum/port/port)
	var/datum/computer_file/program/radar/radar = associated_program
	var/atom/radar_atom = radar.find_atom()
	if(target.value != radar_atom)
		radar.selected = target.value ? REF(target.value) : null
		SStgui.update_uis(radar.computer)
	radar_atom = target.value || radar.find_atom()
	if(radar_atom && radar.trackable(radar_atom))
		var/turf/turf = get_turf(radar_atom)
		x_pos.set_output(turf.x)
		y_pos.set_output(turf.y)
	else
		x_pos.set_output(null)
		y_pos.set_output(null)

/**
 * Czy śledzić cel. Podtypy wyłączają z limitu zasięgu cele, które program normalnie śledzi
 * (np. ludzi w lifeline), żeby wejście z układu ich nie odfiltrowało.
 */
/obj/item/circuit_component/mod_program/radar/proc/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	SIGNAL_HANDLER
	if(target.value && get_dist_euclidian(computer_turf, signal_turf) > MAX_RADAR_CIRCUIT_DISTANCE)
		return COMPONENT_RADAR_DONT_TRACK
	return COMPONENT_RADAR_TRACK_ANYWAY

/// Zwraca wartość portu celu
/obj/item/circuit_component/mod_program/radar/proc/get_atom(datum/source, list/atom_container)
	SIGNAL_HANDLER
	atom_container[1] = target.value

/// Gdy cel wybrano w programie, czyści port celu, aktualizuje X/Y i podaje wybrany atom
/obj/item/circuit_component/mod_program/radar/proc/on_selected(datum/source, selected_ref)
	SIGNAL_HANDLER
	target.set_value(null)
	var/datum/computer_file/program/radar/radar = associated_program
	var/atom/selected_atom = radar.find_atom()
	selected_by_app.set_output(selected_atom)
	if(selected_atom && radar.trackable(selected_atom))
		var/turf/turf = get_turf(selected_atom)
		x_pos.set_output(turf.x)
		y_pos.set_output(turf.y)
	else
		x_pos.set_output(null)
		y_pos.set_output(null)
	trigger_output.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/radar/medical
	associated_program = /datum/computer_file/program/radar/lifeline

/obj/item/circuit_component/mod_program/radar/medical/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	if(ishuman(target.value))
		return NONE
	return ..()

/obj/item/circuit_component/mod_program/radar/janitor
	associated_program = /datum/computer_file/program/radar/custodial_locator

/obj/item/circuit_component/mod_program/radar/janitor/can_track(datum/source, atom/signal, signal_turf, computer_turf)
	if(target.value in GLOB.janitor_devices)
		return NONE
	return ..()

/obj/item/circuit_component/mod_program/radar/nukie
	associated_program = /datum/computer_file/program/radar/fission360

#undef RADAR_NOT_TRACKABLE
#undef RADAR_TRACKABLE
#undef RADAR_TRACKABLE_ANYWAY
#undef MAX_RADAR_CIRCUIT_DISTANCE

////////////////
// Sygnalizator
////////////////

/datum/computer_file/program/signaller
	program_flags = PROGRAM_CIRCUITS_RUN_WHEN_CLOSED
	circuit_comp_type = /obj/item/circuit_component/mod_program/signaler

/// Wysyła sygnał z układu. Odpowiednik signal(), z logiem na twórcę układu zamiast usr.
/datum/computer_file/program/signaller/proc/circuit_signal(obj/item/circuit_component/source)
	var/obj/item/computer_hardware/radio_card/sensor = computer?.get_modular_computer_part(MC_SIGNALLER)
	if(!sensor?.check_functionality())
		return
	if(!radio_connection)
		set_frequency(signal_frequency)
	if(!radio_connection)
		return

	var/time = time2text(world.realtime, "hh:mm:ss")
	var/turf/T = get_turf(computer)
	var/creator = "[source?.parent?.get_creator()]"
	GLOB.lastsignalers.Add("[time] <B>:</B> [creator] used [src] (circuit) @ location ([T.x],[T.y],[T.z]) <B>:</B> with frequency: [format_frequency(signal_frequency)]/[signal_code]")
	log_telecomms("[time] <B>:</B> [creator] used [src] (circuit) @ location [AREACOORD(T)] <B>:</B> with frequency: [format_frequency(signal_frequency)]/[signal_code]")

	var/datum/signal/signal = new(list("code" = signal_code))
	radio_connection.post_signal(src, signal)

/obj/item/circuit_component/mod_program/signaler
	associated_program = /datum/computer_file/program/signaller
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Częstotliwość
	var/datum/port/input/freq
	/// Kod
	var/datum/port/input/code

	COOLDOWN_DECLARE(signal_cd)

/obj/item/circuit_component/mod_program/signaler/populate_ports()
	. = ..()
	freq = add_input_port("Frequency", PORT_TYPE_NUMBER, trigger = PROC_REF(set_freq), default = FREQ_SIGNALER)
	code = add_input_port("Code", PORT_TYPE_NUMBER, trigger = PROC_REF(set_code), default = DEFAULT_SIGNALER_CODE)

/obj/item/circuit_component/mod_program/signaler/get_ui_notices()
	. = ..()
	. += create_ui_notice("Wymaga modułu sygnalizatora w komputerze", "orange", "satellite-dish")

/obj/item/circuit_component/mod_program/signaler/proc/set_freq(datum/port/port)
	var/datum/computer_file/program/signaller/signaler = associated_program
	signaler.set_frequency(sanitize_frequency(round(freq.value), TRUE))

/obj/item/circuit_component/mod_program/signaler/proc/set_code(datum/port/port)
	var/datum/computer_file/program/signaller/signaler = associated_program
	signaler.signal_code = round(clamp(code.value, 1, 100))

/obj/item/circuit_component/mod_program/signaler/input_received(datum/port/port)
	if(!COOLDOWN_FINISHED(src, signal_cd))
		return
	COOLDOWN_START(src, signal_cd, 1 SECONDS)
	INVOKE_ASYNC(associated_program, TYPE_PROC_REF(/datum/computer_file/program/signaller, circuit_signal), src)

/////////////////////
// Wyświetlacz stanu
/////////////////////

/datum/computer_file/program/status
	circuit_comp_type = /obj/item/circuit_component/mod_program/status

/// Ustawia tekst wyświetlaczy z układu. Odpowiednik SendSignal("message") z logiem na twórcę układu.
/datum/computer_file/program/status/proc/circuit_post_message(upper, lower, creator)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return
	upper_text = upper
	lower_text = lower
	var/data1 = reject_bad_text(upper_text || "", MAX_STATUS_LINE_LENGTH)
	var/data2 = reject_bad_text(lower_text || "", MAX_STATUS_LINE_LENGTH)
	var/datum/signal/status_signal = new(list("command" = "message"))
	status_signal.data["msg1"] = data1
	status_signal.data["msg2"] = data2
	message_admins("[creator] zmienia komunikat wyświetlaczy statusu na: [data1], [data2] (aplikacja wyświetlaczy statusu, układ).")
	log_game("[creator] changed the Status Message to - [data1], [data2] - From the Status Display app (circuit).")
	frequency.post_signal(computer, status_signal)

/// Ustawia obrazek wyświetlaczy z układu
/datum/computer_file/program/status/proc/circuit_post_picture(new_picture, creator)
	if(!(new_picture in GLOB.approved_status_pictures))
		return
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return
	picture = new_picture
	var/datum/signal/status_signal = new(list("command" = "alert"))
	status_signal.data["picture_state"] = picture
	log_game("[creator] changed the Status Display picture to [picture] - From the Status Display app (circuit).")
	frequency.post_signal(computer, status_signal)

/obj/item/circuit_component/mod_program/status
	associated_program = /datum/computer_file/program/status
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Górna linia wyświetlaczy po wyzwoleniu
	var/datum/port/input/upper_text
	/// Dolna linia
	var/datum/port/input/bottom_text
	/// Obrazek ustawiany na wyświetlaczach
	var/datum/port/input/option/status_display_pics

/obj/item/circuit_component/mod_program/status/populate_ports()
	. = ..()
	upper_text = add_input_port("Upper text", PORT_TYPE_STRING)
	bottom_text = add_input_port("Bottom text", PORT_TYPE_STRING)

/obj/item/circuit_component/mod_program/status/populate_options()
	status_display_pics = add_option_port("Set Status Display Picture", GLOB.approved_status_pictures, trigger = PROC_REF(set_picture))

/obj/item/circuit_component/mod_program/status/proc/set_picture(datum/port/port)
	var/datum/computer_file/program/status/status = associated_program
	INVOKE_ASYNC(status, TYPE_PROC_REF(/datum/computer_file/program/status, circuit_post_picture), status_display_pics.value, parent.get_creator())

/obj/item/circuit_component/mod_program/status/input_received(datum/port/port)
	var/datum/computer_file/program/status/status = associated_program
	INVOKE_ASYNC(status, TYPE_PROC_REF(/datum/computer_file/program/status, circuit_post_message), upper_text.value, bottom_text.value, parent.get_creator())

///////////////////////////////////
// Monitor NTNet (u tg WireCarp)
///////////////////////////////////

/datum/computer_file/program/ntnetmonitor
	circuit_comp_type = /obj/item/circuit_component/mod_program/ntnetmonitor

/obj/item/circuit_component/mod_program/ntnetmonitor
	associated_program = /datum/computer_file/program/ntnetmonitor
	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL
	/// Przekaźnik NTNet albo PDA, na którym działają wyzwalacze
	var/datum/port/input/target
	/// Przełącza system wykrywania włamań
	var/datum/port/input/toggle_ids
	/// Włącza/wyłącza wskazany przekaźnik NTNet
	var/datum/port/input/toggle_relay
	/// Czyści dzienniki NTNet
	var/datum/port/input/purge_logs
	/// Przełącza tryb mima wskazanego PDA
	var/datum/port/input/toggle_mime_mode
	/// Lista wszystkich PDA z komunikatorem, po wyzwoleniu "Get PDAs"
	var/datum/port/output/all_messengers
	var/datum/port/input/get_pdas

/obj/item/circuit_component/mod_program/ntnetmonitor/populate_ports()
	. = ..()
	target = add_input_port("Target Messenger/Relay", PORT_TYPE_ATOM)
	toggle_ids = add_input_port("Toggle IDS Status", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_ids))
	toggle_relay = add_input_port("Toggle NTnet Relay", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_relay))
	purge_logs = add_input_port("Purge Logs", PORT_TYPE_SIGNAL, trigger = PROC_REF(purge_logs))
	toggle_mime_mode = add_input_port("Toggle Mime Mode", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_mime))
	get_pdas = add_input_port("Get PDAs", PORT_TYPE_SIGNAL, trigger = PROC_REF(get_pdas))
	all_messengers = add_output_port("List of PDAs", PORT_TYPE_LIST(PORT_TYPE_ATOM))

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/get_pdas(datum/port/port)
	var/list/computers_with_messenger = list()
	for(var/obj/item/modular_computer/messenger as anything in GLOB.TabletMessengers)
		computers_with_messenger |= WEAKREF(messenger)
	all_messengers.set_output(computers_with_messenger)
	trigger_output.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/toggle_ids(datum/port/port)
	SSnetworks.station_network?.toggleIDS()
	trigger_output.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/toggle_relay(datum/port/port)
	var/obj/machinery/ntnet_relay/target_relay = target.value
	if(!istype(target_relay))
		return
	target_relay.set_relay_enabled(!target_relay.relay_enabled)
	trigger_output.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/purge_logs(datum/port/port)
	if(SSnetworks.station_network)
		SSnetworks.purge_logs()
	trigger_output.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_program/ntnetmonitor/proc/toggle_mime(datum/port/port)
	var/obj/item/modular_computer/computer = target.value
	if(!istype(computer))
		return
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	var/datum/computer_file/program/messenger/target_messenger = drive && (locate(/datum/computer_file/program/messenger) in drive.stored_files)
	if(isnull(target_messenger))
		return
	target_messenger.mime_mode = !target_messenger.mime_mode
	trigger_output.set_output(COMPONENT_SIGNAL)

///////////////////////
// Monitor cyborgów
///////////////////////

/datum/computer_file/program/borg_monitor
	circuit_comp_type = /obj/item/circuit_component/mod_program/borg_monitor

/datum/computer_file/program/borg_monitor/syndicate
	circuit_comp_type = /obj/item/circuit_component/mod_program/borg_monitor/syndie

/// Wiadomość do cyborga z układu. Odpowiednik "messagebot" z ui_act().
/datum/computer_file/program/borg_monitor/proc/circuit_message_borg(mob/living/silicon/robot/R, message, creator)
	if(!istype(R) || !computer || R.stat == DEAD)
		return FALSE
	if(!evaluate_borg(R, computer.get_overmap()))
		return FALSE
	var/sender_name = get_id_name()
	if(!sender_name)
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		return FALSE
	computer.send_sound()
	to_chat(R, "<br><br><span class='notice'>Wiadomość od [sender_name] – \"[message]\"</span><br>")
	SEND_SOUND(R, 'sound/machines/twobeep_high.ogg')
	if(R.connected_ai)
		to_chat(R.connected_ai, "<br><br><span class='notice'>Wiadomość od [sender_name] do [R] – \"[message]\"</span><br>")
		SEND_SOUND(R.connected_ai, 'sound/machines/twobeep_high.ogg')
	R.logevent("Wiadomość od [sender_name] – \"[message]\"")
	computer.log_talk(message, LOG_PDA, tag = "Cyborg Monitor Program (circuit by [creator]): ID name \"[sender_name]\" to [R]")
	return TRUE

/obj/item/circuit_component/mod_program/borg_monitor
	associated_program = /datum/computer_file/program/borg_monitor
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Cyborg, do którego piszemy
	var/datum/port/input/target_robot
	/// Treść wiadomości
	var/datum/port/input/set_message

/obj/item/circuit_component/mod_program/borg_monitor/populate_ports()
	. = ..()
	target_robot = add_input_port("Receiver", PORT_TYPE_ATOM)
	set_message = add_input_port("Set Message", PORT_TYPE_STRING, trigger = PROC_REF(sanitize_borg_message))

/obj/item/circuit_component/mod_program/borg_monitor/proc/sanitize_borg_message(datum/port/port)
	set_message.set_value(trim(html_encode(set_message.value), MAX_MESSAGE_LEN))

/obj/item/circuit_component/mod_program/borg_monitor/input_received(datum/port/port)
	if(!length(set_message.value) || !iscyborg(target_robot.value))
		return
	var/datum/computer_file/program/borg_monitor/monitor = associated_program
	INVOKE_ASYNC(monitor, TYPE_PROC_REF(/datum/computer_file/program/borg_monitor, circuit_message_borg), target_robot.value, set_message.value, parent.get_creator())

/obj/item/circuit_component/mod_program/borg_monitor/syndie
	associated_program = /datum/computer_file/program/borg_monitor/syndicate
