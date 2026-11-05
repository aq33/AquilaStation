/**
 * Postęp etapów broni statkowej w jej oknie: przycisk etapu (I1 podawanie, I2 komorowanie, I4 przeładowanie
 * ze stojaka) nabija się paskiem, dopóki etap trwa. Broń zapamiętuje, który etap trwa, od kiedy i jak długo,
 * a okno (MunitionsComputer, HybridWeapons, PlasmaGun) dostaje postęp w ui_data i samo animuje pasek do końca.
 */

/// Krótszych etapów (np. szybkie komorowanie railguna) nie pokazujemy, pasek tylko by mignął.
#define WEAPON_CYCLE_STAGE_MIN_DELAY 5

/obj/machinery/ship_weapon
	/// Trwający etap: "feed", "unload", "chamber", "rack" albo null
	var/cycle_stage
	/// world.time początku trwającego etapu
	var/cycle_stage_start = 0
	/// Czas trwającego etapu w decysekundach
	var/cycle_stage_duration = 0
	/// Numer najnowszego etapu. Starszy, nakładający się etap (np. unload() i feed()) nie kasuje nowszego.
	var/cycle_stage_id = 0

/// Czeka delay jak sleep(), a przez ten czas okno broni pokazuje postęp etapu stage. Krótkie etapy czekają bez postępu.
/obj/machinery/ship_weapon/proc/cycle_sleep(delay, stage)
	if(!stage || delay < WEAPON_CYCLE_STAGE_MIN_DELAY)
		sleep(delay)
		return
	var/id = ++cycle_stage_id
	cycle_stage = stage
	cycle_stage_start = world.time
	cycle_stage_duration = delay
	update_cycle_stage_uis()
	sleep(delay)
	if(QDELETED(src) || id != cycle_stage_id)
		return
	cycle_stage = null
	update_cycle_stage_uis()

/// Odświeża okna, które pokazują etapy tej broni, żeby pasek ruszył od razu, a nie przy następnym autoodświeżeniu.
/// Konsola połączona multitoolem („Połącz z: …”) ma tylko SW, bez linked_computer w broni, więc szukamy po otwartych oknach.
/obj/machinery/ship_weapon/proc/update_cycle_stage_uis()
	SStgui.update_uis(src)
	var/list/consoles = list()
	for(var/datum/tgui/ui as anything in SStgui.open_uis)
		var/obj/machinery/computer/ship/munitions_computer/console = ui.src_object
		if(istype(console) && console.SW == src)
			consoles |= console
	for(var/console in consoles)
		SStgui.update_uis(console)

/// Dopisuje do danych okna trwający etap, jego postęp (0-1), pozostały czas gry (ds) i przewidywany czas rzeczywisty (ds).
/// Etap kończy się po sleep() w czasie gry, a okno animuje w czasie rzeczywistym, więc przy spowolnieniu serwera
/// przeliczamy pozostały czas średnim spowolnieniem, żeby pasek nie dochodził do końca przed etapem.
/obj/machinery/ship_weapon/proc/cycle_stage_ui_data(list/data)
	data["cycle_stage"] = cycle_stage
	if(!cycle_stage)
		return
	var/elapsed = world.time - cycle_stage_start
	data["cycle_stage_progress"] = clamp(elapsed / max(cycle_stage_duration, 1), 0, 1)
	var/time_left = max(cycle_stage_duration - elapsed, 0)
	data["cycle_stage_time_left"] = time_left
	data["cycle_stage_real_time_left"] = time_left * (1 + max(SStime_track.time_dilation_avg_fast, 0) / 100)

/obj/machinery/computer/ship/munitions_computer/ui_data(mob/user)
	. = ..()
	if(SW)
		SW.cycle_stage_ui_data(.)

/obj/machinery/ship_weapon/gauss_gun/ui_data(mob/user)
	. = ..()
	cycle_stage_ui_data(.)

/obj/machinery/ship_weapon/hybrid_rail/ui_data(mob/user)
	. = ..()
	cycle_stage_ui_data(.)

/obj/machinery/ship_weapon/plasma_caster/ui_data(mob/user)
	. = ..()
	cycle_stage_ui_data(.)

#undef WEAPON_CYCLE_STAGE_MIN_DELAY
