// Wybór misji przez kapitana: tryb overmapy losuje trzy misje zamiast jednej, a kapitan wybiera jedną
// w konsoli łączności (zakładka „Status misji”). Wybór wisi do pierwszego skoku FTL; jeśli kapitan nie zdąży,
// przy skoku zostaje pierwsza wylosowana. Na starcie rundy setup_overmap_mode() działa jak zwykle (statek),
// wstrzymane jest tworzenie celów, przypomnienia i odprawa; po wyborze cele powstają bez ponownego skoku statku.

/// Ile misji dostaje kapitan do wyboru
#define MISSION_CHOICE_COUNT 3
// Kopie definicji z overmap_mode.dm, które są tam #undef na końcu pliku
#define REMINDER_OBJECTIVES 0
#define REMINDER_COMBAT_RESET 1
#define REMINDER_COMBAT_DELAY 2
#define REMINDER_OVERRIDE 3

/datum/controller/subsystem/overmap_mode
	/// Typy misji (/datum/overmap_gamemode) do wyboru przez kapitana; pierwszy to wylosowany tryb
	var/list/mission_choices
	/// TRUE, póki kapitan może jeszcze wybrać misję
	var/mission_choice_pending = FALSE
	/// Odprawa przyszła w trakcie wyboru i czeka na jego koniec
	var/mission_briefing_waiting = FALSE

/// Polskie nazwy misji w konsoli (config_tag => nazwa)
GLOBAL_LIST_INIT(mission_choice_names, list(
	"patrol" = "Patrol",
	"courier" = "Kurier",
	"boarding" = "Abordaż",
	"station_boarding" = "Abordaż stacji",
	"shakedown" = "Rejs próbny",
	"conquest" = "Podbój galaktyki",
	"armada" = "Armada",
	"hardmode" = "Szturm na Dolos",
))

/datum/controller/subsystem/overmap_mode/Initialize(start_timeofday)
	. = ..()
	roll_mission_choices()

/// Losuje (z wagami) dwie inne misje do wyboru obok już wybranego trybu
/datum/controller/subsystem/overmap_mode/proc/roll_mission_choices()
	mission_choices = null
	if(!mode || forced_mode)
		return
	var/list/probabilities = config.Get(/datum/config_entry/keyed_list/omode_probability)
	var/list/weights = list()
	for(var/datum/overmap_gamemode/mode_type as anything in mode_cache)
		if(mode_type == mode.type)
			continue
		var/config_tag = initial(mode_type.config_tag)
		var/weight = (config_tag in probabilities) ? probabilities[config_tag] : initial(mode_type.selection_weight)
		if(weight > 0)
			weights[mode_type] = weight
	var/list/choices = list(mode.type)
	while(length(choices) < MISSION_CHOICE_COUNT && length(weights))
		var/picked = pickweight(weights)
		choices += picked
		weights -= picked
	if(length(choices) > 1)
		mission_choices = choices

/datum/controller/subsystem/overmap_mode/setup_overmap_mode()
	// Krótka odprawa (np. tryb debugowania kuriera) oznacza test, wtedy bez wyboru
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(mode_initialised || forced_mode || length(mission_choices) < 2 || announce_delay < 1 MINUTES || !main_ship)
		return ..()
	mission_choice_pending = TRUE
	. = ..()
	RegisterSignal(main_ship, COMSIG_SHIP_DEPARTED, PROC_REF(on_first_jump))

/// Statek wszedł w pierwszy skok FTL: bez wyboru kapitana zostaje pierwsza misja
/datum/controller/subsystem/overmap_mode/proc/on_first_jump(obj/structure/overmap/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_SHIP_DEPARTED)
	INVOKE_ASYNC(src, PROC_REF(finish_mission_choice))

/// Tryb wymuszony przez admina albo głosowanie na hardmode kończy wybór misji
/datum/controller/subsystem/overmap_mode/force_mode(new_mode)
	mission_choices = null
	if(mission_choice_pending)
		mission_choice_pending = FALSE
		mission_briefing_waiting = FALSE
		stop_waiting_for_jump()
	return ..()

/datum/controller/subsystem/overmap_mode/proc/stop_waiting_for_jump()
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(main_ship)
		UnregisterSignal(main_ship, COMSIG_SHIP_DEPARTED)

/datum/controller/subsystem/overmap_mode/instance_objectives()
	if(mission_choice_pending)
		return
	return ..()

/datum/controller/subsystem/overmap_mode/fire()
	if(mission_choice_pending)
		return
	return ..()

/datum/controller/subsystem/overmap_mode/announce_objectives()
	if(mission_choice_pending)
		// Odprawa poczeka na wybór; załoga dostaje tylko przypomnienie o wyborze
		if(!mission_briefing_waiting)
			mission_briefing_waiting = TRUE
			minor_announce("Dowództwo floty przydzieliło [length(mission_choices)] misje do wyboru. Kapitan wybiera jedną w konsoli łączności (Status misji). Bez wyboru pierwsza misja zostanie przyjęta przy pierwszym skoku FTL.", "Dowództwo floty")
		return
	return ..()

/datum/overmap_gamemode/check_completion()
	if(SSovermap_mode.mission_choice_pending)
		return
	return ..()

/// Kończy wybór: chosen_type to wybrana misja (null = zostaje wylosowana), chooser to kapitan
/datum/controller/subsystem/overmap_mode/proc/finish_mission_choice(chosen_type, mob/chooser)
	if(!mission_choice_pending)
		return
	mission_choice_pending = FALSE
	stop_waiting_for_jump()
	if(chosen_type && chosen_type != mode.type && (chosen_type in mission_choices))
		var/datum/overmap_gamemode/old_mode = mode
		mode = new chosen_type()
		build_mode_objectives()
		apply_reminder_settings()
		qdel(old_mode)
		var/datum/overmap_gamemode/chosen = mode
		message_admins("[chooser ? ADMIN_LOOKUPFLW(chooser) : "Ktoś"] wybrał misję overmapy [chosen.name] w konsoli łączności.")
		log_game("[chooser ? key_name(chooser) : "Someone"] picked the overmap mission [chosen.name].")
	if(chooser)
		minor_announce("Kapitan [chooser.real_name] przyjął misję: [mission_choice_name(mode.type)]. Szczegóły w odprawie.", "Dowództwo floty")
	else
		minor_announce("Pierwszy skok bez decyzji kapitana: przyjęto misję [mission_choice_name(mode.type)]. Szczegóły w odprawie.", "Dowództwo floty")
	next_objective_reminder = world.time + mode.objective_reminder_interval
	instance_objectives()
	// Odprawa, która czekała na wybór (przed jej czasem przyjdzie sama z timera start_reminder())
	if(mission_briefing_waiting)
		mission_briefing_waiting = FALSE
		announce_objectives()

/// Cele nowej misji, tak samo jak w setup_overmap_mode()
/datum/controller/subsystem/overmap_mode/proc/build_mode_objectives()
	mode.objectives += mode.fixed_objectives
	if(mode.random_objective_amount)
		var/list/select_objectives = mode.random_objectives.Copy()
		for(var/datum/overmap_objective/objective as anything in mode.random_objectives)
			if(player_check < initial(objective.required_players))
				select_objectives -= objective
			if((initial(objective.maximum_players) > 0) && (player_check > initial(objective.maximum_players)))
				select_objectives -= objective
		for(var/i in 1 to mode.random_objective_amount)
			if(!length(select_objectives))
				break
			mode.objectives += pick_n_take(select_objectives)
	var/list/objective_pool = list()
	for(var/objective_type in mode.objectives)
		objective_pool += new objective_type()
	mode.objectives = objective_pool
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(main_ship && mode.starting_faction)
		main_ship.faction = mode.starting_faction

/// Ustawienia przypomnień nowej misji, tak samo jak w setup_overmap_mode()
/datum/controller/subsystem/overmap_mode/proc/apply_reminder_settings()
	objective_resets_reminder = FALSE
	combat_resets_reminder = FALSE
	combat_delays_reminder = FALSE
	objective_reminder_override = FALSE
	switch(mode.objective_reminder_setting)
		if(REMINDER_OBJECTIVES)
			objective_resets_reminder = TRUE
		if(REMINDER_COMBAT_RESET)
			combat_resets_reminder = TRUE
		if(REMINDER_COMBAT_DELAY)
			combat_delays_reminder = TRUE
			combat_delay_amount = mode.combat_delay
		if(REMINDER_OVERRIDE)
			objective_reminder_override = TRUE
	next_objective_reminder = world.time + mode.objective_reminder_interval

/proc/mission_choice_name(datum/overmap_gamemode/mode_type)
	return GLOB.mission_choice_names[initial(mode_type.config_tag)] || initial(mode_type.name)

// Konsola łączności

/obj/machinery/computer/communications/ui_data(mob/user)
	. = ..()
	if(!SSovermap_mode.mission_choice_pending || !.["authenticated"])
		return
	var/list/choices = list()
	for(var/datum/overmap_gamemode/mode_type as anything in SSovermap_mode.mission_choices)
		choices += list(list(
			"id" = "[mode_type]",
			"name" = mission_choice_name(mode_type),
			"brief" = initial(mode_type.brief),
		))
	.["mission_choices"] = choices
	.["can_choose_mission"] = authenticated_as_non_silicon_captain(user)

/obj/machinery/computer/communications/ui_act(action, list/params)
	. = ..()
	if(. || action != "chooseMission")
		return
	if(!SSovermap_mode.mission_choice_pending || !authenticated_as_non_silicon_captain(usr))
		return
	var/chosen_type = text2path(params["id"])
	if(!(chosen_type in SSovermap_mode.mission_choices))
		return
	SSovermap_mode.finish_mission_choice(chosen_type, usr)
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	return TRUE

#undef MISSION_CHOICE_COUNT
#undef REMINDER_OBJECTIVES
#undef REMINDER_COMBAT_RESET
#undef REMINDER_COMBAT_DELAY
#undef REMINDER_OVERRIDE
