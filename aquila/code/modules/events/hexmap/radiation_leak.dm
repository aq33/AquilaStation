// AQUILA - Wyciek promieniowania: jedna maszyna na okręcie promieniuje i dymi radioaktywną mgłą, inżynier zatyka wyciek narzędziami (port z tgstation code/modules/events/radiation_leak.dm)
// As in tg: a dense powered machine (or a vent/scrubber) near a random spot of the ship leaks for about 5 minutes, puffs
// polonium and mutagen smoke three times and examining it tells which 1-3 tools stop the leak (30 s of work each try).
// We have no radioactive_emitter component, so the event itself sends a radiation pulse from the machine every event tick
// (2 s, range 5, through walls of medium insulation like the tg emitter). tg picks the machine near generic event
// spawn landmarks, which our ship maps do not have, so the search starts from random ship turfs instead.

/// Event ticks (2 s) the leak lasts
#define RADIATION_LEAK_DURATION 150

/datum/round_event_control/aquila_hex_radiation_leak
	name = "Wyciek promieniowania"
	typepath = /datum/round_event/aquila_hex_radiation_leak
	weight = 10
	min_players = 3
	max_occurrences = 3
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_radiation_leak
	startWhen = 1
	announceWhen = 10
	endWhen = RADIATION_LEAK_DURATION
	/// The leaking machine
	var/obj/machinery/leaking_machine
	/// Polish description of each repair method -> the tool it needs
	var/list/fix_methods
	/// Signals registered on the machine for the repair tools
	var/list/tool_signals

/datum/round_event/aquila_hex_radiation_leak/setup()
	for(var/i in 1 to 10)
		var/turf/spot = aquila_hex_random_ship_turf()
		if(!spot)
			return
		for(var/obj/machinery/machine in range(3, spot))
			if(can_leak(machine))
				leaking_machine = machine
				return

/// tg's filter: powered, dense (or a vent/scrubber), visible, not under the floor
/datum/round_event/aquila_hex_radiation_leak/proc/can_leak(obj/machinery/machine)
	if(QDELETED(machine) || machine.use_power == NO_POWER_USE || !isturf(machine.loc))
		return FALSE
	if(!machine.density && !istype(machine, /obj/machinery/atmospherics/components/unary))
		return FALSE
	if(machine.invisibility || !machine.alpha || !machine.mouse_opacity || machine.IsObscured())
		return FALSE
	return TRUE

/datum/round_event/aquila_hex_radiation_leak/announce(fake)
	var/area/location
	if(fake)
		location = GLOB.areas_by_type[pick(GLOB.the_station_areas)]
	else if(leaking_machine)
		location = get_area(leaking_machine)
	else
		return
	priority_announce("W obszarze [location ? location.name : "nieznanym"] wykryto wyciek promieniowania. Załoga ma opuścić ten obszar. Nasi [pick("mechanicy", "inżynierowie", "naukowcy", "stażyści", "czujnicy")] twierdzą, że winna jest jedna z maszyn: naprawcie ją jak najszybciej, żeby zatrzymać wyciek.", "Dział Inżynierii Centrali")

/datum/round_event/aquila_hex_radiation_leak/start()
	if(QDELETED(leaking_machine))
		leaking_machine = null
		log_game("Radiation Leak: no machine to leak from, cancelling the event.")
		return kill()
	start_leak(leaking_machine)
	announce_to_ghosts(leaking_machine)
	log_game("Radiation Leak started at [leaking_machine] in [AREACOORD(leaking_machine)].")

/// Makes the machine leak: repair methods, examine hint, tool signals and the first puff of smoke
/datum/round_event/aquila_hex_radiation_leak/proc/start_leak(obj/machinery/machine)
	leaking_machine = machine
	var/list/all_methods = list(
		"dokręcając kilka zaworów" = TOOL_WRENCH,
		"dokręcając śruby mocujące" = TOOL_WRENCH,
		"podważając łomem panel" = TOOL_CROWBAR,
		"przykręcając kilka wkrętów" = TOOL_SCREWDRIVER,
		"sprawdzając [pick("przewody", "obwody")] multitoolem" = TOOL_MULTITOOL,
		"zaspawając szczelinę w obudowie" = TOOL_WELDER,
		"analizując odczyty analizatorem" = TOOL_ANALYZER,
		"przecinając nadmiarowe przewody" = TOOL_WIRECUTTER,
	)
	var/list/method_names = assoc_to_keys(all_methods)
	fix_methods = list()
	for(var/i in 1 to rand(1, 3))
		var/method = pick_n_take(method_names)
		fix_methods[method] = all_methods[method]
	tool_signals = list()
	for(var/method in fix_methods)
		tool_signals |= COMSIG_ATOM_TOOL_ACT(fix_methods[method])
	RegisterSignal(machine, tool_signals, PROC_REF(on_machine_tooled))
	RegisterSignal(machine, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(machine, COMSIG_PARENT_QDELETING, PROC_REF(on_machine_deleted))
	machine.visible_message("<span class='danger'>Z [machine] zaczyna się sączyć ohydny zielony dym!</span>")
	puff_smoke(machine)

/datum/round_event/aquila_hex_radiation_leak/tick()
	if(QDELETED(leaking_machine))
		return
	radiation_pulse(leaking_machine, max_range = 5, threshold = RAD_MEDIUM_INSULATION)
	if(activeFor % round(RADIATION_LEAK_DURATION / 3) == 0)
		puff_smoke(leaking_machine)

/datum/round_event/aquila_hex_radiation_leak/end()
	if(!leaking_machine)
		return
	leaking_machine.visible_message("<span class='notice'>Zielony dym wydobywający się z [leaking_machine] rozwiewa się.</span>")
	stop_leak()

/datum/round_event/aquila_hex_radiation_leak/kill()
	stop_leak()
	return ..()

/datum/round_event/aquila_hex_radiation_leak/Destroy()
	stop_leak()
	return ..()

/// Removes the signals from the machine and forgets it
/datum/round_event/aquila_hex_radiation_leak/proc/stop_leak()
	if(leaking_machine)
		UnregisterSignal(leaking_machine, tool_signals + list(COMSIG_PARENT_EXAMINE, COMSIG_PARENT_QDELETING))
	leaking_machine = null
	tool_signals = null

/// Polonium and mutagen smoke around the machine, like tg
/datum/round_event/aquila_hex_radiation_leak/proc/puff_smoke(atom/where)
	var/turf/smoke_turf = get_turf(where)
	if(!smoke_turf)
		return
	var/datum/reagents/smoke_reagents = new(20)
	smoke_reagents.add_reagent(/datum/reagent/toxin/polonium, 10)
	smoke_reagents.add_reagent(/datum/reagent/toxin/mutagen, 10)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(smoke_reagents, 2, smoke_turf, silent = TRUE)
	smoke.start()
	qdel(smoke_reagents)
	playsound(smoke_turf, 'sound/effects/smoke.ogg', 50, TRUE)

/datum/round_event/aquila_hex_radiation_leak/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='green'><i>Sączy się z tego zielony dym... Wyciek zatrzymasz chyba, [english_list(fix_methods, and_text = " albo ")].</i></span>"

/datum/round_event/aquila_hex_radiation_leak/proc/on_machine_deleted(datum/source)
	SIGNAL_HANDLER
	stop_leak()
	kill()

/datum/round_event/aquila_hex_radiation_leak/proc/on_machine_tooled(obj/machinery/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_fix), source, user, tool)
	return COMPONENT_BLOCK_TOOL_ATTACK

/// 30 s of work with the right tool stops the leak and ends the event
/datum/round_event/aquila_hex_radiation_leak/proc/try_fix(obj/machinery/source, mob/living/user, obj/item/tool)
	source.balloon_alert(user, "naprawiasz wyciek...")
	if(!tool.use_tool(source, user, 30 SECONDS, amount = (tool.tool_behaviour == TOOL_WELDER ? 2 : 0), volume = 50))
		source.balloon_alert(user, "przerwano!")
		return
	if(source != leaking_machine)
		return
	source.balloon_alert(user, "wyciek zatrzymany")
	finish_repair()

/// The leak was fixed: the smoke stops and the event ends early
/datum/round_event/aquila_hex_radiation_leak/proc/finish_repair()
	if(!leaking_machine)
		return
	leaking_machine.visible_message("<span class='notice'>Zielony dym wydobywający się z [leaking_machine] rozwiewa się.</span>")
	log_game("Radiation Leak was repaired at [AREACOORD(leaking_machine)].")
	stop_leak()
	processing = FALSE
	kill()

#undef RADIATION_LEAK_DURATION
