// AQUILA - misja overmapy „Opuszczona stacja”. W systemie sektora 2 dryfuje opuszczona stacja, której wnętrze buduje generator losowych ruin
// z supercruise Bee (BeeStation/BeeStation-Hornet#4543) na osobnym poziomie Z. Na ruinie czeka jeden z celów
// eksploracji Bee (/datum/orbital_objective). Załoga dolatuje promem desantowym albo myśliwcem z napędem FTL i komputerem dokowania
// (docking_act wymaga FTL po jednej ze stron, tak samo jak przy abordażu stacji).
// Mapa orbitalna supercruise zostaje wyłączona: z Bee bierzemy tylko generator i cele.

// Kopie definicji z overmap_mode.dm, które są tam #undef na końcu pliku
#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2
#define REMINDER_COMBAT_DELAY 2

/datum/overmap_gamemode/derelict_ruin
	name = "Opuszczona stacja"
	config_tag = "derelict"
	desc = "Tryb opuszczonej stacji – dolecieć do opuszczonej stacji z losowym wnętrzem i wykonać na niej cel eksploracji"
	brief = "Czujniki dalekiego zasięgu namierzyły dryfującą, opuszczoną stację. Dolećcie do niej promem desantowym albo myśliwcem z napędem FTL i komputerem dokowania, przeszukajcie ją i wykonajcie zadanie podane w odprawie."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = REMINDER_COMBAT_DELAY // Combat can postpone, but it's not the goal
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 5
	fixed_objectives = list(/datum/overmap_objective/derelict_ruin)

/obj/structure/overmap/derelict_ruin
	name = "opuszczona stacja"
	desc = "Martwa, dryfująca placówka. Czujniki nie wykrywają łączności, tylko słabe ślady zasilania."
	icon = 'nsv13/icons/overmap/smallstation.dmi'
	icon_state = "outpost"
	color = "#8c8c8c"
	mass = MASS_MEDIUM // Większa od myśliwców i promów, więc mogą do niej dokować
	obj_integrity = 1000
	max_integrity = 1000
	armor = list("overmap_light" = 100, "overmap_medium" = 100, "overmap_heavy" = 100)
	overmap_deletion_traits = NONE
	weapon_addition_allowed = FALSE
	brakes = TRUE
	block_deletion = TRUE
	essential = TRUE
	faction = "unaligned"

/obj/structure/overmap/derelict_ruin/apply_weapons()
	return

/obj/structure/overmap/derelict_ruin/start_piloting(mob/living/carbon/user, position)
	. = ..()
	stop_piloting(user)

/datum/overmap_objective/derelict_ruin
	name = "Opuszczona stacja"
	desc = "Dolecieć do opuszczonej stacji z losowym wnętrzem i wykonać na niej cel eksploracji."
	brief = "Dolećcie do opuszczonej stacji i wykonajcie zadanie na jej pokładzie."
	var/datum/star_system/target_system
	var/obj/structure/overmap/derelict_ruin/target_derelict
	/// Cel eksploracji Bee, który czeka na ruinie
	var/datum/orbital_objective/ruin_objective
	/// Poziom Z z ruiną
	var/ruin_z
	/// Generator skończył budować ruinę
	var/ruin_generated = FALSE
	var/static/list/ruin_objective_types = list(
		/datum/orbital_objective/recover_blackbox,
		/datum/orbital_objective/artifact,
		/datum/orbital_objective/nuclear_bomb,
		/datum/orbital_objective/vip_recovery,
		/datum/orbital_objective/assassination,
	)

/datum/overmap_objective/derelict_ruin/New(datum/star_system/passed_input, forced_objective_type)
	. = ..()
	if(passed_input) //Let us select a system in the gamemode controller
		target_system = passed_input
	if(!target_system && SSstar_system.initialized)
		target_system = pick_derelict_system()
	var/objective_type = forced_objective_type || pick(ruin_objective_types)
	ruin_objective = new objective_type()
	ruin_objective.linked_mission = src
	ruin_objective.generate_payout()

/datum/overmap_objective/derelict_ruin/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(ruin_objective)
		ruin_objective.linked_mission = null
		QDEL_NULL(ruin_objective)
	target_derelict = null
	target_system = null
	return ..()

/// Te same zasady co przy abordażu stacji: sektor 2, bez Rubikonu, czarnej dziury i systemu startowego
/datum/overmap_objective/derelict_ruin/proc/pick_derelict_system()
	var/list/candidates = list()
	var/datum/star_system/start_system = SSovermap_mode.mode ? SSstar_system.system_by_id(SSovermap_mode.mode.starting_system) : null
	for(var/datum/star_system/S in SSstar_system.neutral_zone_systems)
		if(S.hidden || (S.sector != 2) || S.name == "Rubicon" || S.has_anomaly_type(/obj/effect/overmap_anomaly/singularity))
			continue
		if(S == start_system)
			continue
		candidates += S
	if(length(candidates))
		return pick(candidates)

/datum/overmap_objective/derelict_ruin/instance()
	. = ..()
	if(!target_system)
		message_admins("Cel [name] nie znajduje układu docelowego, oznaczam go jako wykonany.")
		status = STATUS_COMPLETED
		return
	target_derelict = instance_overmap(/obj/structure/overmap/derelict_ruin)
	target_derelict.name = "opuszczona stacja [ruin_objective.station_name]"
	target_system.add_ship(target_derelict)
	target_system.objective_sector = TRUE
	ruin_objective.on_assign(null)
	// Jedno zdanie-szablon na cel (system i nagroda w środku), żeby tłumacz nie musiał rozbierać szablonu w szablonie
	brief = ruin_objective.get_text()
	INVOKE_ASYNC(src, PROC_REF(generate_ruin))
	START_PROCESSING(SSprocessing, src)
	update_reminder_interval()

/// Buduje ruinę na nowym poziomie Z i łączy go ze stacją na overmapie
/datum/overmap_objective/derelict_ruin/proc/generate_ruin()
	// Jak add_new_initialized_zlevel, ale z poziomem, który dostaliśmy: inicjalizacja atomów może oddać czas
	// i w tym czasie ktoś inny doda poziom, więc world.maxz nie musi już być nasz
	var/datum/space_level/level = SSmapping.add_new_zlevel("Opuszczona stacja [target_derelict ? target_derelict.name : ruin_objective.station_name]", ZTRAITS_BOARDABLE_SHIP)
	ruin_z = level.z_value
	SSatoms.InitializeAtoms(block(locate(1, 1, ruin_z), locate(world.maxx, world.maxy, ruin_z)))
	SSmapping.setup_map_transitions(level)
	if(target_derelict)
		var/datum/space_level/SL = SSmapping.get_level(ruin_z)
		SL.linked_overmap = target_derelict
		target_derelict.occupying_levels += SL
		// Myśliwiec po dokowaniu pojawia się w kosmosie obok ruiny, nie w jej środku
		target_derelict.docking_points = list(get_turf(locate(round(world.maxx * 0.25), round(world.maxy / 2), ruin_z)))
	log_game("Derelict mission ruin generating on Z level [ruin_z] ([ruin_objective.type])")
	var/border_x = max(10, round(world.maxx / 2) - 28)
	var/border_y = max(10, round(world.maxy / 2) - 28)
	generate_space_ruin(round(world.maxx / 2), round(world.maxy / 2), ruin_z, border_x, border_y, ruin_objective)
	ruin_generated = TRUE
	message_admins("Misja [name]: wnętrze stacji gotowe na poziomie Z [ruin_z] (cel: [ruin_objective.name]).")

/datum/overmap_objective/derelict_ruin/process(delta_time)
	if(status != STATUS_INPROGRESS)
		return PROCESS_KILL
	check_completion()

/datum/overmap_objective/derelict_ruin/check_completion()
	if(status != STATUS_INPROGRESS || !ruin_objective)
		return
	// Część celów Bee sama zalicza się w check_failed(), więc najpierw sprawdzamy porażkę, a potem wykonanie
	var/failed = ruin_generated && ruin_objective.check_failed()
	if(ruin_objective.completed)
		status = STATUS_COMPLETED
	else if(failed)
		status = STATUS_FAILED
		priority_announce("Cel misji na stacji [target_derelict?.name] jest już nie do wykonania.", "Dowództwo floty")

/// Cel Bee został wykonany: zaliczamy misję od razu, bez czekania na okresowe sprawdzenie
/datum/overmap_objective/derelict_ruin/proc/ruin_objective_completed()
	if(status != STATUS_INPROGRESS)
		return
	status = STATUS_COMPLETED
	SSovermap_mode.update_reminder(objective = TRUE)
	if(SSovermap_mode.mode)
		INVOKE_ASYNC(SSovermap_mode.mode, TYPE_PROC_REF(/datum/overmap_gamemode, check_completion))

/// Odstęp przypomnień jak przy abordażu stacji: liczony z czasu lotu do opuszczonej stacji
/datum/overmap_objective/derelict_ruin/proc/update_reminder_interval()
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(!OM?.ftl_drive || !SSovermap_mode.mode)
		return
	var/list/fastest_route = find_route(OM.current_system || SSstar_system.system_by_id(SSovermap_mode.mode.starting_system), target_system, wormholes_allowed = FALSE)
	if(!islist(fastest_route))
		fastest_route = list()
	var/distance = 0
	for(var/i = 2; i <= length(fastest_route); i++)
		var/datum/star_system/start = fastest_route[i-1]
		var/datum/star_system/finish = fastest_route[i]
		distance += start.dist(finish)
	var/travel_time = (distance / (OM.ftl_drive.get_jump_speed() * 10)) SECONDS // Time spent flying
	travel_time += 2 MINUTES * length(fastest_route) // Time spent spooling FTL drive
	travel_time += 20 MINUTES // Time spent searching the derelict
	travel_time *= 1.2 // Time spent lolligagging
	SSovermap_mode.mode.objective_reminder_interval = max((travel_time / 5), SSovermap_mode.mode.objective_reminder_interval)

// Cele eksploracji Bee podpięte pod misję overmapy

/datum/orbital_objective
	/// AQUILA - misja „Opuszczona stacja”, do której należy ten cel (null = cel z mapy orbitalnej supercruise)
	var/datum/overmap_objective/derelict_ruin/linked_mission

/datum/orbital_objective/complete_objective()
	if(!linked_mission)
		return ..()
	if(completed)
		return
	completed = TRUE
	SSeconomy.distribute_funds(payout)
	priority_announce("Cel misji na opuszczonej stacji wykonany. [payout] kr rozdzielono między budżety działów.", "Dowództwo floty", SSstation.announcer.get_rand_report_sound())
	linked_mission.ruin_objective_completed()

// Bomba do likwidacji leży na stacji obok dysku, a nie na mostku: do stacji dolatuje się myśliwcem, a bomby nie da się nim przewieźć
/datum/orbital_objective/nuclear_bomb/on_assign(obj/machinery/computer/objective/objective_computer)
	if(!linked_mission)
		return ..()

/datum/orbital_objective/nuclear_bomb/generate_objective_stuff(turf/chosen_turf)
	if(linked_mission && !nuclear_bomb)
		var/list/bomb_turfs = list()
		for(var/turf/open/floor/F in RANGE_TURFS(25, chosen_turf))
			if(get_dist(F, chosen_turf) < 8 || (locate(/obj/structure) in F))
				continue
			bomb_turfs += F
		nuclear_bomb = new /obj/machinery/nuclearbomb/decomission(length(bomb_turfs) ? pick(bomb_turfs) : chosen_turf)
	return ..()

/datum/orbital_objective/nuclear_bomb/get_text()
	if(!linked_mission)
		return ..()
	return "Posterunek [station_name] wymaga natychmiastowej likwidacji, by zapobiec wyciekowi informacji do kosmicznej prasy. Na pokładzie stacji leży przestarzały ładunek jądrowy i dysk uwierzytelniania do niego. Znajdźcie oba, uzbrójcie ładunek kodem z raportu Centrali i uciekajcie ze stacji przed wybuchem. Stacja dryfuje w systemie [linked_mission.target_system]. Nagroda: [payout] kr."

/datum/orbital_objective/nuclear_bomb/check_failed()
	if(!linked_mission)
		return ..()
	// Bez nadajnika z mapy orbitalnej: cel przepada tylko po utracie bomby albo dysku
	if(!generated)
		return FALSE
	return QDELETED(nuclear_bomb) || QDELETED(nuclear_disk)

/datum/orbital_objective/vip_recovery/get_text()
	if(!linked_mission)
		return ..()
	return "Na [station_name] znajduje się ktoś szczególnie dla nas interesujący. Musimy go natychmiast ewakuować. VIP może być wrogo nastawiony, więc zabierzcie ze sobą ochronę. Aby wykonać cel, dowieźcie go żywego i przytomnego na pokład statku. Stacja dryfuje w systemie [linked_mission.target_system]. Nagroda: [payout] kr."

/datum/orbital_objective/assassination/get_text()
	if(!linked_mission)
		return ..()
	return "Zlokalizowaliśmy wrogiego agenta, który utknął na [station_name]. Wyślijcie zespół i wyeliminujcie cel. Według wywiadu cel jest uzbrojony i niebezpieczny, dlatego zabierzcie ze sobą ochronę. Stacja dryfuje w systemie [linked_mission.target_system]. Nagroda: [payout] kr."

/datum/orbital_objective/artifact/get_text()
	if(!linked_mission)
		return ..()
	return "Posterunek [station_name] to placówka badawcza z niezwykle potężnym obcym artefaktem na pokładzie. Odzyskajcie artefakt i dowieźcie go na pokład statku. Uważajcie na jego strażników. Stacja dryfuje w systemie [linked_mission.target_system]. Nagroda: [payout] kr."

/datum/orbital_objective/recover_blackbox/get_text()
	if(!linked_mission)
		return ..()
	return "Posterunek [station_name] niedawno zamilkł i nie odpowiada na nasze próby kontaktu. Odzyskajcie czarną skrzynkę stacji i użyjcie jej w dłoni na mostku statku. Stacja dryfuje w systemie [linked_mission.target_system]. Nagroda: [payout] kr."

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef REMINDER_COMBAT_DELAY
