// Port z tg: code/modules/wiremod/core/program_circuit.dm + obsługa komponentów programów
// (u tg w file_system/program.dm). U nas (Bee) programy leżą na dyskach: MC_HDD i dysk zawodu MC_HDD_JOB.

/datum/computer_file/program
	/// Flagi programu. U nas na razie tylko PROGRAM_CIRCUITS_RUN_WHEN_CLOSED.
	var/program_flags = NONE
	/// Komponent układu, który komputer dostaje (nieusuwalny), dopóki program jest na dysku
	var/obj/item/circuit_component/mod_program/circuit_comp_type

/datum/computer_file/program/New(obj/item/modular_computer/comp = null)
	. = ..()
	// Każdy komponent może należeć tylko do jednego typu programu (bez podtypów)
	if(circuit_comp_type && initial(circuit_comp_type.associated_program) != type)
		stack_trace("circuit comp type mismatch: [type] has circuit comp type \[[circuit_comp_type]\], while \[[circuit_comp_type]\] has associated program \[[initial(circuit_comp_type.associated_program)]\].")

/datum/computer_file/program/Destroy()
	if(circuit_comp_type && computer && !QDELETED(computer))
		computer.remove_program_circuit_comp(src)
	return ..()

/datum/computer_file/program/on_start(mob/living/user)
	. = ..()
	if(.)
		SEND_SIGNAL(src, COMSIG_COMPUTER_PROGRAM_START, user)

/datum/computer_file/program/kill_program(forced = FALSE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_COMPUTER_PROGRAM_KILL, forced)

/// Czy program jest teraz uruchomiony (aktywny albo w tle) na swoim komputerze
/datum/computer_file/program/proc/is_running_on_computer()
	if(!computer)
		return FALSE
	return computer.active_program == src || (src in computer.idle_threads)

// Dyski: dodanie/usunięcie pliku i włożenie/wyjęcie dysku dodaje albo zabiera komponent programu

/obj/item/computer_hardware/hard_drive/store_file(datum/computer_file/F)
	. = ..()
	if(!. || !istype(F, /datum/computer_file/program) || !holder)
		return
	if(src in holder.get_circuit_drives())
		holder.add_program_circuit_comp(F)

/obj/item/computer_hardware/hard_drive/remove_file(datum/computer_file/F)
	. = ..()
	if(!. || !istype(F, /datum/computer_file/program) || !holder)
		return
	if(src in holder.get_circuit_drives())
		holder.remove_program_circuit_comp(F)

/obj/item/computer_hardware/hard_drive/on_install(obj/item/modular_computer/install_into, mob/living/user)
	. = ..()
	if(!(src in install_into.get_circuit_drives()))
		return
	for(var/datum/computer_file/program/program in stored_files)
		program.computer = install_into
		install_into.add_program_circuit_comp(program)

/obj/item/computer_hardware/hard_drive/on_remove(obj/item/modular_computer/remove_from, mob/user)
	. = ..()
	drive_circuit_removed(remove_from)

// Dysk zawodu ma własne on_remove bez ..()
/obj/item/computer_hardware/hard_drive/role/on_remove(obj/item/modular_computer/remove_from, mob/user)
	. = ..()
	drive_circuit_removed(remove_from)

/obj/item/computer_hardware/hard_drive/proc/drive_circuit_removed(obj/item/modular_computer/remove_from)
	if(!remove_from)
		return
	for(var/datum/computer_file/program/program in stored_files)
		remove_from.remove_program_circuit_comp(program)

// Komputer: zarządzanie komponentami programów

/// Dyski, z których da się uruchamiać programy
/obj/item/modular_computer/proc/get_circuit_drives()
	. = list()
	if(all_components[MC_HDD])
		. += all_components[MC_HDD]
	if(all_components[MC_HDD_JOB])
		. += all_components[MC_HDD_JOB]

/// Szuka programu dokładnie tego typu (bez podtypów) na dyskach komputera
/obj/item/modular_computer/proc/find_circuit_program(program_type, datum/computer_file/program/exclude)
	for(var/obj/item/computer_hardware/hard_drive/drive as anything in get_circuit_drives())
		for(var/datum/computer_file/program/program in drive.stored_files)
			if(program.type == program_type && program != exclude)
				return program

/// Zwraca nieusuwalny komponent dokładnie podanego typu z obudowy
/obj/item/modular_computer/proc/find_program_circuit_comp(comp_type)
	if(!shell)
		return
	for(var/obj/item/circuit_component/comp as anything in shell.unremovable_circuit_components)
		if(comp.type == comp_type)
			return comp

/obj/item/modular_computer/proc/add_program_circuit_comp(datum/computer_file/program/program)
	if(isnull(program.circuit_comp_type) || isnull(shell) || QDELETED(shell))
		return
	if(find_program_circuit_comp(program.circuit_comp_type))
		return
	var/obj/item/circuit_component/mod_program/comp = new program.circuit_comp_type()
	shell.add_unremovable_circuit_component(comp)
	if(shell.attached_circuit)
		comp.forceMove(shell.attached_circuit)
		shell.attached_circuit.add_component(comp)

/obj/item/modular_computer/proc/remove_program_circuit_comp(datum/computer_file/program/program)
	if(isnull(program.circuit_comp_type) || isnull(shell) || QDELETED(shell))
		return
	var/obj/item/circuit_component/mod_program/comp = find_program_circuit_comp(program.circuit_comp_type)
	if(!comp)
		return
	// Komponent podpięty pod inną kopię tego samego programu zostaje
	if(istype(comp.associated_program) && comp.associated_program != program)
		return
	shell.unremovable_circuit_components -= comp
	UnregisterSignal(comp, COMSIG_CIRCUIT_COMPONENT_SAVE)
	qdel(comp)
	// Jeśli na drugim dysku jest taki sam program, dostaje swój komponent
	var/datum/computer_file/program/other = find_circuit_program(program.type, program)
	if(other)
		add_program_circuit_comp(other)

/// Dodaje komponenty programom, które były na dyskach, zanim powstała obudowa
/obj/item/modular_computer/proc/sync_program_circuit_comps()
	for(var/obj/item/computer_hardware/hard_drive/drive as anything in get_circuit_drives())
		for(var/datum/computer_file/program/program in drive.stored_files)
			add_program_circuit_comp(program)

/// Uruchamia program bez użytkownika. Bez aktywnego programu staje się aktywny, inaczej idzie w tło.
/obj/item/modular_computer/proc/circuit_open_program(datum/computer_file/program/program)
	if(!enabled || program.is_running_on_computer())
		return FALSE
	if(!open_program(null, program, in_background = TRUE))
		return FALSE
	if(!active_program)
		idle_threads -= program
		program.program_state = PROGRAM_STATE_ACTIVE
		active_program = program
		program.alert_pending = FALSE
		update_icon()
		SStgui.update_uis(src)
	return TRUE

/// Zamyka program bez użytkownika
/obj/item/modular_computer/proc/circuit_kill_program(datum/computer_file/program/program)
	if(active_program == program)
		kill_program(forced = FALSE)
		SStgui.update_uis(src)
		return TRUE
	if(program in idle_threads)
		idle_threads -= program
		program.kill_program(forced = FALSE)
		update_icon()
		SStgui.update_uis(src)
		return TRUE
	return FALSE

/**
 * Komponenty programów są nietypowe.
 * Program dodaje je do nieusuwalnych komponentów obudowy, gdy trafi na dysk, i kasuje, gdy z niego zniknie.
 * Nie żyją więc i nie giną razem z obudową jak zwykłe nieusuwalne komponenty.
 */
/obj/item/circuit_component/mod_program
	display_name = "Program modułowy (abstrakcyjny)"
	desc = "Abstrakcyjny komponent programu komputera modułowego. Jeśli to widzisz, zgłoś błąd."
	/**
	 * Program, z którym komponent współpracuje. Póki komponent nie jest w obudowie, to ścieżka typu.
	 * Każdy komponent może należeć tylko do jednego typu programu, bez podtypów.
	 */
	var/datum/computer_file/program/associated_program

	/// Uruchamia program, w tle, jeśli inny jest aktywny
	var/datum/port/input/start
	/// Zamyka program
	var/datum/port/input/kill
	/// Czy program jest uruchomiony
	var/datum/port/output/running

/obj/item/circuit_component/mod_program/Initialize(mapload)
	if(associated_program)
		display_name = initial(associated_program.filedesc)
		desc = initial(associated_program.extended_desc)
	return ..()

/// Komputer, którego dotyczy obudowa (u konsol to procesor w środku maszyny)
/obj/item/circuit_component/mod_program/proc/get_shell_computer(atom/movable/shell)
	if(istype(shell, /obj/item/modular_computer))
		return shell
	if(istype(shell, /obj/machinery/modular_computer))
		var/obj/machinery/modular_computer/console = shell
		return console.cpu

/// Czy komponent ma działający program
/obj/item/circuit_component/mod_program/proc/has_program()
	return istype(associated_program) && !QDELETED(associated_program) && associated_program.computer

/obj/item/circuit_component/mod_program/register_shell(atom/movable/shell)
	. = ..()
	var/obj/item/modular_computer/computer = get_shell_computer(shell)
	if(isnull(computer) || istype(associated_program))
		return
	var/datum/computer_file/program/found_program = computer.find_circuit_program(associated_program)
	// Układ został wczytany albo skopiowany, a programu nie ma - instalujemy go na dysku
	if(isnull(found_program))
		var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
		if(!drive)
			return
		found_program = new associated_program(computer)
		if(!drive.store_file(found_program))
			qdel(found_program)
			return
	associated_program = found_program
	associated_program.computer = computer
	RegisterSignal(associated_program, COMSIG_COMPUTER_PROGRAM_START, PROC_REF(on_start))
	RegisterSignal(associated_program, COMSIG_COMPUTER_PROGRAM_KILL, PROC_REF(on_kill))
	running.set_output(associated_program.is_running_on_computer())
	on_program_registered(computer)

/obj/item/circuit_component/mod_program/unregister_shell(atom/movable/shell)
	if(istype(associated_program))
		on_program_unregistered()
		UnregisterSignal(associated_program, list(COMSIG_COMPUTER_PROGRAM_START, COMSIG_COMPUTER_PROGRAM_KILL))
	associated_program = initial(associated_program)
	return ..()

/// Dla podtypów: program jest już podpięty (associated_program to instancja)
/obj/item/circuit_component/mod_program/proc/on_program_registered(obj/item/modular_computer/computer)
	return

/// Dla podtypów: program zaraz zostanie odpięty
/obj/item/circuit_component/mod_program/proc/on_program_unregistered()
	return

/obj/item/circuit_component/mod_program/populate_ports()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	start = add_input_port("Start", PORT_TYPE_SIGNAL, trigger = PROC_REF(start_prog))
	kill = add_input_port("Kill", PORT_TYPE_SIGNAL, trigger = PROC_REF(kill_prog))
	running = add_output_port("Running", PORT_TYPE_BOOLEAN)

/// Większość programów przyjmuje sygnały tylko wtedy, gdy są uruchomione (aktywne albo w tle)
/obj/item/circuit_component/mod_program/should_receive_input(datum/port/input/port)
	. = ..()
	if(!.)
		return FALSE
	if(!has_program())
		return FALSE
	if(!associated_program.computer.enabled)
		return FALSE
	if((associated_program.program_flags & PROGRAM_CIRCUITS_RUN_WHEN_CLOSED) || COMPONENT_TRIGGERED_BY(start, port))
		return TRUE
	return associated_program.is_running_on_computer()

/obj/item/circuit_component/mod_program/proc/start_prog(datum/port/input/port)
	INVOKE_ASYNC(associated_program.computer, TYPE_PROC_REF(/obj/item/modular_computer, circuit_open_program), associated_program)

/obj/item/circuit_component/mod_program/proc/on_start(datum/source, mob/living/user)
	SIGNAL_HANDLER
	running.set_output(TRUE)

/obj/item/circuit_component/mod_program/proc/kill_prog(datum/port/input/port)
	INVOKE_ASYNC(associated_program.computer, TYPE_PROC_REF(/obj/item/modular_computer, circuit_kill_program), associated_program)

/obj/item/circuit_component/mod_program/proc/on_kill(datum/source, forced)
	SIGNAL_HANDLER
	running.set_output(FALSE)

/obj/item/circuit_component/mod_program/get_ui_notices()
	. = ..()
	var/flags = istype(associated_program) ? associated_program.program_flags : (associated_program ? initial(associated_program.program_flags) : NONE)
	if(!(flags & PROGRAM_CIRCUITS_RUN_WHEN_CLOSED))
		. += create_ui_notice("Wejścia działają tylko przy uruchomionym programie", "purple")
