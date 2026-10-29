// Port z tg: komputer modułowy jako obudowa układu (computer.dm + computer_circuit.dm)
// Laptopy i tablety: obudowa bez flag. Konsole: obudowa na maszynie, duża, z portem USB (jak w tg).

/obj/item/modular_computer
	/// Pojemność obudowy układu tego komputera
	var/shell_capacity = SHELL_CAPACITY_MEDIUM
	/// Obudowa układu (na nas albo na maszynie konsoli). Dodaje i kasuje komponenty programów.
	var/datum/component/shell/shell

/obj/item/modular_computer/tablet/pda
	shell_capacity = SHELL_CAPACITY_SMALL

/obj/item/modular_computer/Initialize(mapload)
	. = ..()
	// Procesor konsoli dostaje obudowę od swojej maszyny
	if(physical == src && !istype(src, /obj/item/modular_computer/processor))
		add_shell_component(shell_capacity)

/obj/item/modular_computer/Destroy()
	shell = null
	return ..()

/// Dodaje obudowę układu do tego przedmiotu albo do maszyny, do której należy
/obj/item/modular_computer/proc/add_shell_component(capacity = SHELL_CAPACITY_MEDIUM, shell_flags = NONE)
	shell = physical.AddComponent(/datum/component/shell, list(new /obj/item/circuit_component/modpc), capacity, shell_flags)
	RegisterSignal(shell, COMSIG_SHELL_CIRCUIT_ATTACHED, PROC_REF(on_circuit_attached))
	RegisterSignal(shell, COMSIG_SHELL_CIRCUIT_REMOVED, PROC_REF(on_circuit_removed))
	RegisterSignal(shell, COMSIG_PARENT_QDELETING, PROC_REF(on_shell_deleted))
	sync_program_circuit_comps()

/obj/item/modular_computer/proc/on_shell_deleted(datum/source)
	SIGNAL_HANDLER
	shell = null

/obj/item/modular_computer/proc/on_circuit_attached(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(shell.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE, PROC_REF(use_energy_for_circuits))

/// Najpierw prąd z komputera, dopiero potem z ogniwa układu
/obj/item/modular_computer/proc/use_energy_for_circuits(datum/source, energy_usage_per_input)
	SIGNAL_HANDLER
	// Zużycie układu jest w jednostkach ogniwa, use_power() mnoży przez CELLRATE
	if(use_power(energy_usage_per_input / GLOB.CELLRATE))
		return COMPONENT_OVERRIDE_POWER_USAGE

/obj/item/modular_computer/proc/on_circuit_removed(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(shell.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE)

// Krzemowe tablety (borgi, SI) - bez rąk nie da się bawić układami
/obj/item/modular_computer/tablet/integrated/add_shell_component(capacity, shell_flags)
	return

/obj/item/modular_computer/turn_on(mob/user, open_ui = TRUE)
	var/was_enabled = enabled
	. = ..()
	if(. && !was_enabled && enabled)
		SEND_SIGNAL(src, COMSIG_MODULAR_COMPUTER_TURNED_ON, user)

/obj/item/modular_computer/shutdown_computer(loud = 1)
	var/was_enabled = enabled
	. = ..()
	if(was_enabled && !enabled)
		SEND_SIGNAL(src, COMSIG_MODULAR_COMPUTER_SHUT_DOWN, loud)

// Konsole: obudowa na maszynie, duża i z portem USB
/obj/machinery/modular_computer/Initialize(mapload)
	. = ..()
	cpu?.add_shell_component(SHELL_CAPACITY_LARGE, SHELL_FLAG_USB_PORT)

// Konsola przekazuje przedmioty do procesora bez ..(), więc obudowa na maszynie nie dostałaby sygnału
/obj/machinery/modular_computer/attackby(obj/item/W, mob/living/user, params)
	// ID zostaje dla czytnika kart konsoli, tak jak w laptopach i PDA
	if(cpu?.shell && !user.combat_mode && (istype(W, /obj/item/integrated_circuit) || istype(W, /obj/item/circuit_component)))
		if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
			return TRUE
	return ..()

/// Prosty komponent dla konsol, laptopów i PDA, niezależny od programów
/obj/item/circuit_component/modpc
	display_name = "Modular Computer"
	desc = "Układ do podstawowych funkcji komputera modułowego."
	var/obj/item/modular_computer/computer
	/// Włącza/wyłącza komputer
	var/datum/port/input/on_off
	/// Tekst do wydrukowania
	var/datum/port/input/print_text
	/// Drukuje po wyzwoleniu
	var/datum/port/input/print

	/// Wysyłany po włączeniu
	var/datum/port/output/is_on
	/// Wysyłany po wyłączeniu
	var/datum/port/output/is_off

	/// Latarka i jej kolor
	var/datum/port/input/lights
	var/datum/port/input/red
	var/datum/port/input/green
	var/datum/port/input/blue
	var/datum/port/input/set_color

/obj/item/circuit_component/modpc/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/modular_computer))
		computer = shell
	else if(istype(shell, /obj/machinery/modular_computer))
		var/obj/machinery/modular_computer/console = shell
		computer = console.cpu

	if(isnull(computer))
		return

	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_TURNED_ON, PROC_REF(computer_on))
	RegisterSignal(computer, COMSIG_MODULAR_COMPUTER_SHUT_DOWN, PROC_REF(computer_off))

	// Nie każdy komputer ma latarkę, a populate_ports() leci, zanim wiemy, do czego trafiliśmy
	if(computer.has_light && isnull(lights))
		lights = add_input_port("Toggle Lights", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_flashlight))
		red = add_input_port("Red", PORT_TYPE_NUMBER)
		green = add_input_port("Green", PORT_TYPE_NUMBER)
		blue = add_input_port("Blue", PORT_TYPE_NUMBER)
		set_color = add_input_port("Set Color", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_flashlight_color))

/obj/item/circuit_component/modpc/unregister_shell(atom/movable/shell)
	if(computer)
		UnregisterSignal(computer, list(COMSIG_MODULAR_COMPUTER_TURNED_ON, COMSIG_MODULAR_COMPUTER_SHUT_DOWN))
		computer = null
	return ..()

/obj/item/circuit_component/modpc/populate_ports()
	on_off = add_input_port("Turn On/Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_power))
	print_text = add_input_port("Print Text", PORT_TYPE_STRING)
	print = add_input_port("Print", PORT_TYPE_SIGNAL, trigger = PROC_REF(print_text))

	is_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	is_off = add_output_port("Shut Down", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/modpc/should_receive_input(datum/port/input/port)
	. = ..()
	if(!. || isnull(computer) || QDELETED(computer))
		return FALSE

/obj/item/circuit_component/modpc/pre_input_received(datum/port/input/port)
	if(COMPONENT_TRIGGERED_BY(print_text, port))
		print_text.set_value(html_encode(trim(print_text.value, MAX_PAPER_LENGTH)))

/obj/item/circuit_component/modpc/proc/print_text(datum/source)
	if(!computer.enabled)
		return
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	printer?.print_text(print_text.value)

/obj/item/circuit_component/modpc/proc/toggle_power(datum/source)
	if(computer.enabled)
		INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/item/modular_computer, shutdown_computer))
	else
		INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/item/modular_computer, turn_on), null, FALSE)

/obj/item/circuit_component/modpc/proc/toggle_flashlight(datum/source)
	computer.toggle_flashlight()

/obj/item/circuit_component/modpc/proc/set_flashlight_color(datum/source)
	red.set_value(clamp(red.value, 0, 255))
	blue.set_value(clamp(blue.value, 0, 255))
	green.set_value(clamp(green.value, 0, 255))
	computer.set_flashlight_color(rgb(red.value || 0, green.value || 0, blue.value || 0))

/obj/item/circuit_component/modpc/proc/computer_on(datum/source, mob/user)
	SIGNAL_HANDLER
	is_on.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/modpc/proc/computer_off(datum/source, loud)
	SIGNAL_HANDLER
	is_off.set_output(COMPONENT_SIGNAL)
