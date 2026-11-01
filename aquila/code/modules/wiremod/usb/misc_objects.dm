// Porty USB i obudowy circuitów w różnych obiektach, które tg ma w plikach tych obiektów:
// przełącznik taśmociągu, reflektor, procesor szlamu, syntezator i elektronika śluzy (śluza jako obudowa).

// ---------------------------------------------------------------------------
// Przełącznik taśmociągu (tg code/modules/recycling/conveyor.dm)
// ---------------------------------------------------------------------------

/obj/machinery/conveyor_switch/Initialize(mapload, newid, isoneway, isinvert)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/conveyor_switch))

/obj/item/circuit_component/conveyor_switch
	display_name = "Przełącznik taśmociągu"
	desc = "Pozwala sterować podłączonymi taśmociągami."

	/// Direction input ports.
	var/datum/port/input/stop
	var/datum/port/input/active
	var/datum/port/input/reverse
	/// The current direction of the conveyor attached to the component.
	var/datum/port/output/direction
	/// The switch this conveyor switch component is attached to.
	var/obj/machinery/conveyor_switch/attached_switch

/obj/item/circuit_component/conveyor_switch/populate_ports()
	active = add_input_port("Activate", PORT_TYPE_SIGNAL, trigger = PROC_REF(activate))
	stop = add_input_port("Stop", PORT_TYPE_SIGNAL, trigger = PROC_REF(stop))
	direction = add_output_port("Conveyor Direction", PORT_TYPE_NUMBER)

/obj/item/circuit_component/conveyor_switch/get_ui_notices()
	. = ..()
	. += create_ui_notice("Kierunek 0 oznacza zatrzymany taśmociąg, 1 pracę do przodu, a -1 pracę wstecz.", "orange", "info")

/obj/item/circuit_component/conveyor_switch/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/conveyor_switch))
		attached_switch = shell
		if(!attached_switch.oneway)
			reverse = add_input_port("Reverse", PORT_TYPE_SIGNAL, trigger = PROC_REF(reverse))

/obj/item/circuit_component/conveyor_switch/unregister_usb_parent(atom/movable/shell)
	attached_switch = null
	if(reverse)
		remove_input_port(reverse)
		reverse = null
	return ..()

/obj/item/circuit_component/conveyor_switch/proc/on_switch_changed()
	if(!attached_switch)
		return
	attached_switch.update_icon()
	attached_switch.update_linked_conveyors()
	attached_switch.update_linked_switches()
	direction.set_output(attached_switch.position)

/obj/item/circuit_component/conveyor_switch/proc/activate()
	SIGNAL_HANDLER
	if(!attached_switch)
		return
	// U nas przełącznik jednokierunkowy może mieć ustawiony kierunek wstecz (oneway = -1)
	attached_switch.position = attached_switch.oneway ? attached_switch.oneway : 1
	INVOKE_ASYNC(src, PROC_REF(on_switch_changed))

/obj/item/circuit_component/conveyor_switch/proc/stop()
	SIGNAL_HANDLER
	if(!attached_switch)
		return
	attached_switch.position = 0
	INVOKE_ASYNC(src, PROC_REF(on_switch_changed))

/obj/item/circuit_component/conveyor_switch/proc/reverse()
	SIGNAL_HANDLER
	if(!attached_switch || attached_switch.oneway)
		return
	attached_switch.position = -1
	INVOKE_ASYNC(src, PROC_REF(on_switch_changed))

// ---------------------------------------------------------------------------
// Reflektor (tg code/game/objects/structures/reflector.dm)
// ---------------------------------------------------------------------------

/obj/structure/reflector/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/reflector))

/obj/item/circuit_component/reflector
	display_name = "Reflektor"
	desc = "Pozwala ustawić kąt reflektora."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///angle the reflector will be set to at trigger unless locked
	var/datum/port/input/angle

	var/obj/structure/reflector/attached_reflector

/obj/item/circuit_component/reflector/populate_ports()
	angle = add_input_port("Angle", PORT_TYPE_NUMBER)

/obj/item/circuit_component/reflector/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/structure/reflector))
		attached_reflector = parent

/obj/item/circuit_component/reflector/unregister_usb_parent(atom/movable/parent)
	attached_reflector = null
	return ..()

/obj/item/circuit_component/reflector/input_received(datum/port/input/port)
	if(!attached_reflector || attached_reflector.admin)
		return
	attached_reflector.setAngle(SIMPLIFY_DEGREES(angle.value))

// ---------------------------------------------------------------------------
// Procesor szlamu (tg code/modules/food_and_drinks/machinery/processor.dm)
// ---------------------------------------------------------------------------

/obj/machinery/processor/slime/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/slime_processor))

/// Liczba rzeczy w środku, które da się przerobić.
/obj/machinery/processor/proc/processable_contents_count()
	. = 0
	for(var/atom/movable/thing in contents)
		if(select_recipe(thing))
			.++

/**
 * Przerabia zawartość bez użytkownika (odpowiednik `processing()` z tg, u nas to siedzi w `interact()`).
 * Śpi, więc wołać przez INVOKE_ASYNC.
 */
/obj/machinery/processor/proc/process_contents_remotely()
	if(processing || machine_stat & (NOPOWER|BROKEN))
		return FALSE
	var/total_time = 0
	for(var/atom/movable/thing in contents)
		var/datum/food_processor_process/recipe = select_recipe(thing)
		if(recipe)
			total_time += recipe.time
	if(!total_time)
		return FALSE
	processing = TRUE
	update_icon()
	visible_message(span_notice("[src] włącza się sam."))
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = (total_time / rating_speed) * 5)
	sleep(total_time / rating_speed)
	for(var/atom/movable/thing in contents)
		var/datum/food_processor_process/recipe = select_recipe(thing)
		if(!recipe)
			continue
		process_food(recipe, thing)
	pixel_x = base_pixel_x
	processing = FALSE
	update_icon()
	visible_message("[src] kończy przetwarzanie.")
	return TRUE

/obj/machinery/processor/slime/process_contents_remotely()
	. = ..()
	// Jak w interact(): szlamy, które podeszły w trakcie pracy, wciągamy dopiero teraz
	if(sbacklogged)
		for(var/mob/living/simple_animal/slime/slime in ohearers(1, src))
			if(slime.stat == DEAD)
				visible_message("[slime] zostaje wciągnięty do [src].")
				slime.forceMove(src)
		sbacklogged = FALSE

/obj/item/circuit_component/slime_processor
	display_name = "Przetwórnia szlamów"
	desc = "Pozwala uruchomić przetwarzanie i odczytać, ile rzeczy jest w procesorze."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	///Activate process
	var/datum/port/input/active
	///Amount of processor contents
	var/datum/port/output/amount

	var/obj/machinery/processor/slime/attached_processor

/obj/item/circuit_component/slime_processor/populate_ports()
	active = add_input_port("Activate", PORT_TYPE_SIGNAL, trigger = PROC_REF(activate))
	amount = add_output_port("Amount", PORT_TYPE_NUMBER)

/obj/item/circuit_component/slime_processor/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/processor/slime))
		attached_processor = parent

/obj/item/circuit_component/slime_processor/unregister_usb_parent(atom/movable/parent)
	attached_processor = null
	return ..()

/obj/item/circuit_component/slime_processor/proc/activate()
	SIGNAL_HANDLER
	input_received()
	if(!attached_processor || attached_processor.processing)
		return
	if(!attached_processor.processable_contents_count())
		return
	INVOKE_ASYNC(attached_processor, TYPE_PROC_REF(/obj/machinery/processor, process_contents_remotely))

/obj/item/circuit_component/slime_processor/input_received()
	if(!attached_processor)
		return
	amount.set_output(attached_processor.processable_contents_count())

// ---------------------------------------------------------------------------
// Syntezator (tg code/modules/instruments/piano_synth.dm)
// ---------------------------------------------------------------------------

/obj/item/instrument/piano_synth
	var/circuit_type = /obj/item/circuit_component/synth
	var/shell_capacity = SHELL_CAPACITY_SMALL

/obj/item/instrument/piano_synth/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(new circuit_type), shell_capacity)

/// Circuit może grać bez gracza: wtedy nie sprawdzamy, czy "grający" trzyma instrument.
/obj/item/instrument/piano_synth/should_stop_playing(mob/user)
	if(SEND_SIGNAL(src, COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING, user) & IGNORE_INSTRUMENT_CHECKS)
		return FALSE
	if(!ismob(user))
		return TRUE
	return ..()

/obj/item/circuit_component/synth
	display_name = "Syntezator"
	desc = "Zaawansowany elektroniczny syntezator, który potrafi udawać różne instrumenty."

	/// The song, represented in latin alphabet A to G, that'll be played when play is triggered.
	var/datum/port/input/song
	/// Starts playing the song.
	var/datum/port/input/play
	/// Stop playing the song.
	var/datum/port/input/stop
	/// How many times the song will be played.
	var/datum/port/input/repetitions
	/// The beats per minute of the song
	var/datum/port/input/beats_per_min
	/// The volume of the song
	var/datum/port/input/volume
	/// Notes with volume below this threshold will be dead
	var/datum/port/input/volume_dropoff
	/// Note shift
	var/datum/port/input/note_shift
	/// Sustain Mode
	var/datum/port/input/option/sustain_mode
	/// The value of the above
	var/datum/port/input/sustain_value
	/// If set the last held note will decay
	var/datum/port/input/note_decay
	/// The list of instruments which sound can be synthesized.
	var/datum/port/input/option/selected_instrument
	/// Whether a song is currently playing
	var/datum/port/output/is_playing
	/// Sent when a new song has started playing
	var/datum/port/output/started_playing
	/// Sent when a song has finished playing
	var/datum/port/output/stopped_playing

	/// The synthesizer this circut is attached to.
	var/obj/item/instrument/piano_synth/synth

	/// U nas tryby wybrzmiewania to liczby, w tg napisy.
	var/static/list/sustain_modes = list("Linear" = SUSTAIN_LINEAR, "Exponential" = SUSTAIN_EXPONENTIAL)

/obj/item/circuit_component/synth/populate_ports()
	song = add_input_port("Song", PORT_TYPE_LIST(PORT_TYPE_STRING), trigger = PROC_REF(import_song))
	play = add_input_port("Play", PORT_TYPE_SIGNAL, trigger = PROC_REF(start_playing))
	stop = add_input_port("Stop", PORT_TYPE_SIGNAL, trigger = PROC_REF(stop_playing))
	repetitions = add_input_port("Repetitions", PORT_TYPE_NUMBER, trigger = PROC_REF(set_repetitions))
	beats_per_min = add_input_port("BPM", PORT_TYPE_NUMBER, trigger = PROC_REF(set_bpm))
	selected_instrument = add_option_port("Selected Instrument", SSinstruments.synthesizer_instrument_ids, trigger = PROC_REF(set_instrument))
	volume = add_input_port("Volume", PORT_TYPE_NUMBER, trigger = PROC_REF(set_volume))
	volume_dropoff = add_input_port("Volume Dropoff Threshold", PORT_TYPE_NUMBER, trigger = PROC_REF(set_dropoff))
	note_shift = add_input_port("Note Shift", PORT_TYPE_NUMBER, trigger = PROC_REF(set_note_shift))
	sustain_mode = add_option_port("Note Sustain Mode", sustain_modes, trigger = PROC_REF(set_sustain_mode))
	sustain_value = add_input_port("Note Sustain Value", PORT_TYPE_NUMBER, trigger = PROC_REF(set_sustain_value))
	note_decay = add_input_port("Held Note Decay", PORT_TYPE_NUMBER, trigger = PROC_REF(set_sustain_decay))

	is_playing = add_output_port("Currently Playing", PORT_TYPE_BOOLEAN)
	started_playing = add_output_port("Started Playing", PORT_TYPE_SIGNAL)
	stopped_playing = add_output_port("Stopped Playing", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/synth/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/item/instrument/piano_synth))
		return
	synth = shell
	RegisterSignal(synth, COMSIG_SONG_START, PROC_REF(on_song_start))
	RegisterSignal(synth, COMSIG_SONG_END, PROC_REF(on_song_end))
	RegisterSignal(synth, COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING, PROC_REF(continue_if_autoplaying))

/obj/item/circuit_component/synth/unregister_shell(atom/movable/shell)
	if(synth)
		if(synth.song?.user_playing == src)
			synth.song.stop_playing()
		UnregisterSignal(synth, list(COMSIG_SONG_START, COMSIG_SONG_END, COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING))
	synth = null
	return ..()

/obj/item/circuit_component/synth/proc/start_playing(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!synth?.song)
		return
	INVOKE_ASYNC(synth.song, TYPE_PROC_REF(/datum/song, start_playing), src)

/obj/item/circuit_component/synth/proc/on_song_start(datum/source)
	SIGNAL_HANDLER
	is_playing.set_output(TRUE)
	started_playing.set_output(COMPONENT_SIGNAL)
	if(beats_per_min.value)
		synth.song.set_bpm(beats_per_min.value)

/obj/item/circuit_component/synth/proc/continue_if_autoplaying(datum/source, atom/music_player)
	SIGNAL_HANDLER
	if(music_player == src)
		return IGNORE_INSTRUMENT_CHECKS

/obj/item/circuit_component/synth/proc/stop_playing(datum/port/input/port)
	CIRCUIT_TRIGGER
	synth?.song?.stop_playing()

/obj/item/circuit_component/synth/proc/on_song_end(datum/source)
	SIGNAL_HANDLER
	is_playing.set_output(FALSE)
	stopped_playing.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/synth/proc/import_song()
	CIRCUIT_TRIGGER
	if(!synth?.song || synth.song.playing)
		return
	var/list/lines = song.value
	if(!islist(lines))
		return
	// Nasz ParseSong bierze tekst, a nie listę linii
	synth.song.ParseSong(jointext(lines, "\n"))

/obj/item/circuit_component/synth/proc/set_repetitions()
	CIRCUIT_TRIGGER
	if(!synth?.song || synth.song.playing)
		return
	synth.song.repeat = clamp(round(repetitions.value), 0, synth.song.max_repeats)

/obj/item/circuit_component/synth/proc/set_bpm()
	CIRCUIT_TRIGGER
	if(synth?.song && beats_per_min.value)
		synth.song.set_bpm(beats_per_min.value)

/obj/item/circuit_component/synth/proc/set_instrument()
	CIRCUIT_TRIGGER
	if(!synth?.song || !(selected_instrument.value in synth.song.allowed_instrument_ids))
		return
	synth.song.set_instrument(selected_instrument.value)

/obj/item/circuit_component/synth/proc/set_volume()
	CIRCUIT_TRIGGER
	synth?.song?.set_volume(volume.value)

/obj/item/circuit_component/synth/proc/set_dropoff()
	CIRCUIT_TRIGGER
	synth?.song?.set_dropoff_volume(volume_dropoff.value)

/obj/item/circuit_component/synth/proc/set_note_shift()
	CIRCUIT_TRIGGER
	if(!synth?.song)
		return
	synth.song.note_shift = clamp(note_shift.value, synth.song.note_shift_min, synth.song.note_shift_max)

/obj/item/circuit_component/synth/proc/set_sustain_mode()
	CIRCUIT_TRIGGER
	if(!synth?.song)
		return
	var/new_mode = sustain_modes[sustain_mode.value]
	if(!new_mode)
		return
	synth.song.sustain_mode = new_mode

/obj/item/circuit_component/synth/proc/set_sustain_value()
	CIRCUIT_TRIGGER
	if(!synth?.song)
		return
	switch(synth.song.sustain_mode)
		if(SUSTAIN_LINEAR)
			synth.song.set_linear_falloff_duration(sustain_value.value)
		if(SUSTAIN_EXPONENTIAL)
			synth.song.set_exponential_drop_rate(sustain_value.value)

/obj/item/circuit_component/synth/proc/set_sustain_decay()
	CIRCUIT_TRIGGER
	if(!synth?.song)
		return
	// W tg jest tu literówka (!!full_sustain_held_note), u nas bierzemy wartość z portu
	synth.song.full_sustain_held_note = !note_decay.value

// ---------------------------------------------------------------------------
// Śluza budowana jako obudowa circuitu (tg code/game/objects/structures/door_assembly.dm
// i code/game/machinery/doors/airlock_electronics.dm)
// ---------------------------------------------------------------------------

/obj/item/electronics/airlock
	/// Czy zbudowana z tą elektroniką śluza może mieć w środku układ scalony.
	var/shell = FALSE

/obj/item/electronics/airlock/ui_data()
	. = ..()
	// W RCD elektronika jest tylko ustawieniem dostępu, tam śluz z obudową nie budujemy
	if(!holder)
		.["shell"] = shell

/obj/item/electronics/airlock/ui_act(action, params)
	if(action == "set_shell")
		shell = !!params["on"]
		return TRUE
	return ..()

/// Wołane z budowy śluzy (door_assembly.dm). Robi z gotowej śluzy obudowę circuitu, jeśli tak ustawiono elektronikę.
/obj/item/electronics/airlock/proc/apply_circuit_shell(obj/machinery/door/airlock/door)
	if(!shell || !istype(door) || door.GetComponent(/datum/component/shell))
		return
	door.AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/airlock, new /obj/item/circuit_component/airlock_access_event, new /obj/item/circuit_component/remotecam/airlock), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_ALLOW_FAILURE_ACTION|SHELL_FLAG_REQUIRE_ANCHOR \
	)
