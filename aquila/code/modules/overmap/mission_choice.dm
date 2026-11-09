// Wybór misji przez kapitana: tryb overmapy losuje trzy misje zamiast jednej, a kapitan wybiera jedną
// w konsoli łączności (zakładka „Status misji”). Wybór wisi do pierwszego skoku FTL; jeśli kapitan nie zdąży,
// przy skoku zostaje pierwsza wylosowana. Na starcie rundy setup_overmap_mode() działa jak zwykle (statek),
// wstrzymane jest tworzenie celów, przypomnienia i odprawa; po wyborze cele powstają bez ponownego skoku statku.
// Po wykonaniu misji, gdy głosowanie wybierze dodatkowe cele, kapitan w tej samej zakładce wybiera kolejną dowolną
// misję albo atak na Rubikon. Kolejna misja działa jak zwykła (po jej wykonaniu znów jest głosowanie), Rubikon kończy
// rundę jak dotąd. Bez wyboru w EXTENSION_CHOICE_TIME dowództwo przydziela cele po staremu (Rubikon albo bilety).

/// Ile misji dostaje kapitan do wyboru
#define MISSION_CHOICE_COUNT 3
/// Identyfikator ataku na Rubikon na liście wyboru po wykonaniu misji
#define EXTENSION_RUBICON "rubicon"
/// Ile czasu kapitan ma na wybór kolejnej misji
#define EXTENSION_CHOICE_TIME 5 MINUTES
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
	/// TRUE, póki kapitan wybiera kolejną misję po wykonaniu poprzedniej
	var/extension_choice_pending = FALSE
	/// Typy misji do wyboru po wykonaniu poprzedniej, plus EXTENSION_RUBICON
	var/list/extension_choices
	/// Timer, po którym dowództwo samo przydziela cele
	var/extension_choice_timer
	/// Dowództwo przydziela cele po staremu (wywołanie z finish_extension_choice)
	var/extension_default_objectives = FALSE

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
	"derelict" = "Opuszczona stacja",
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
	var/briefing_was_waiting = FALSE
	if(mission_choice_pending)
		mission_choice_pending = FALSE
		briefing_was_waiting = mission_briefing_waiting
		mission_briefing_waiting = FALSE
		stop_waiting_for_jump()
	. = ..()
	// Odprawa czekała na wybór, a jej timer z start_reminder() już minął: bez tego nowy tryb nie miałby odprawy
	if(briefing_was_waiting && . && mode)
		announce_objectives()

/datum/controller/subsystem/overmap_mode/proc/stop_waiting_for_jump()
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(main_ship)
		UnregisterSignal(main_ship, COMSIG_SHIP_DEPARTED)

/datum/controller/subsystem/overmap_mode/instance_objectives()
	if(mission_choice_pending)
		return
	return ..()

/datum/controller/subsystem/overmap_mode/fire()
	if(mission_choice_pending || extension_choice_pending)
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
	if(SSovermap_mode.mission_choice_pending || SSovermap_mode.extension_choice_pending)
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
		build_mode_objectives(mode)
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

/// Cele nowej misji, tak samo jak w setup_overmap_mode(); set_faction = FALSE dla kolejnej misji w trakcie rundy
/datum/controller/subsystem/overmap_mode/proc/build_mode_objectives(datum/overmap_gamemode/target_mode, set_faction = TRUE)
	target_mode.objectives += target_mode.fixed_objectives
	if(target_mode.random_objective_amount)
		var/list/select_objectives = target_mode.random_objectives.Copy()
		for(var/datum/overmap_objective/objective as anything in target_mode.random_objectives)
			if(player_check < initial(objective.required_players))
				select_objectives -= objective
			if((initial(objective.maximum_players) > 0) && (player_check > initial(objective.maximum_players)))
				select_objectives -= objective
		for(var/i in 1 to target_mode.random_objective_amount)
			if(!length(select_objectives))
				break
			target_mode.objectives += pick_n_take(select_objectives)
	var/list/objective_pool = list()
	for(var/objective_type in target_mode.objectives)
		objective_pool += new objective_type()
	target_mode.objectives = objective_pool
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(set_faction && main_ship && target_mode.starting_faction)
		main_ship.faction = target_mode.starting_faction

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

// Wybór kolejnej misji po wykonaniu poprzedniej

/datum/controller/subsystem/overmap_mode/request_additional_objectives()
	if(extension_default_objectives)
		return ..()
	if(extension_choice_pending)
		return
	var/list/choices = get_extension_choices()
	if(!length(choices))
		return ..()
	for(var/datum/overmap_objective/O in mode.objectives)
		O.ignore_check = TRUE //We no longer care about checking these objective against completion
	extension_choices = choices
	extension_choice_pending = TRUE
	extension_choice_timer = addtimer(CALLBACK(src, PROC_REF(finish_extension_choice)), EXTENSION_CHOICE_TIME, TIMER_STOPPABLE)
	minor_announce("Kapitan wybiera w konsoli łączności (Status misji) kolejną misję albo atak na Rubikon. Bez wyboru w ciągu [EXTENSION_CHOICE_TIME / (1 MINUTES)] minut dowództwo samo przydzieli cele.", "Dowództwo floty")

/// Każda misja z losowania (także ta sama co przed chwilą) i atak na Rubikon, jeśli są tam wrogowie.
/// Bez trybów, których logika siedzi w samym trybie, a nie w celach (fale Armady, podbój, szturm na Dolos):
/// kolejna misja przenosi tylko cele, więc te tryby nie zadziałałyby jako kolejna misja.
/datum/controller/subsystem/overmap_mode/proc/get_extension_choices()
	var/static/list/not_extendable = typecacheof(list(
		/datum/overmap_gamemode/armada,
		/datum/overmap_gamemode/galactic_conquest,
		/datum/overmap_gamemode/hardmode,
	))
	var/list/probabilities = config.Get(/datum/config_entry/keyed_list/omode_probability)
	var/list/choices = list()
	for(var/datum/overmap_gamemode/mode_type as anything in mode_cache)
		if(not_extendable[mode_type])
			continue
		var/config_tag = initial(mode_type.config_tag)
		var/weight = (config_tag in probabilities) ? probabilities[config_tag] : initial(mode_type.selection_weight)
		if(weight > 0)
			choices += mode_type
	var/datum/star_system/rubicon = SSstar_system.system_by_id("Rubicon")
	if(length(rubicon?.enemies_in_system))
		choices += EXTENSION_RUBICON
	return choices

/// Kończy wybór kolejnej misji: choice to typ misji albo EXTENSION_RUBICON, null = dowództwo przydziela cele po staremu
/datum/controller/subsystem/overmap_mode/proc/finish_extension_choice(choice, mob/chooser)
	if(!extension_choice_pending)
		return
	extension_choice_pending = FALSE
	deltimer(extension_choice_timer)
	extension_choice_timer = null
	var/list/choices = extension_choices
	extension_choices = null
	if(!choice || !(choice in choices))
		minor_announce("Kapitan nie wybrał kolejnej misji, dowództwo przydziela cele.", "Dowództwo floty")
		extension_default_objectives = TRUE
		request_additional_objectives()
		extension_default_objectives = FALSE
		return
	var/choice_name = (choice == EXTENSION_RUBICON) ? "atak na Rubikon" : mission_choice_name(choice)
	// Poprzednia misja jest już rozliczona: jej cele znikają (nieudany cel z ignore_check blokowałby zwycięstwo
	// w nowej), a licznik wykonanych celów liczy się od nowa, żeby cele nowej misji znów obniżały zagrożenie
	highest_objective_completion = 0
	if(choice == EXTENSION_RUBICON)
		QDEL_LIST(mode.objectives)
		mode.objectives = list(new /datum/overmap_objective/clear_system/rubicon)
	else
		// Nowa misja zastępuje cały tryb, jak przy wyborze na starcie rundy: przypomnienia, ich konsekwencje i nazwa
		// są jej, a nie poprzedniej misji. Frakcja statku i trudność zostają z rundy.
		var/datum/overmap_gamemode/chosen = new choice()
		chosen.objectives = list() // Bez celu skoków z New(), statek już lata
		build_mode_objectives(chosen, set_faction = FALSE)
		chosen.difficulty = mode.difficulty
		var/datum/overmap_gamemode/old_mode = mode
		mode = chosen
		qdel(old_mode)
		// Kolejna misja liczy się jak zwykła: przypomnienia od pierwszego, a po jej wykonaniu znów jest głosowanie
		round_extended = FALSE
		objective_reminder_stacks = 0
		apply_reminder_settings()
	if(chooser)
		minor_announce("Kapitan [chooser.real_name] przyjął misję: [choice_name]. Szczegóły w odprawie.", "Dowództwo floty")
		message_admins("[ADMIN_LOOKUPFLW(chooser)] wybrał kolejną misję overmapy: [choice_name].")
		log_game("[key_name(chooser)] picked the next overmap mission: [choice].")
	instance_objectives()
	announce_objectives()
	if(choice == EXTENSION_RUBICON)
		// Tak samo jak po starym przedłużeniu: twardy limit czasu do powrotu
		combat_resets_reminder = FALSE
		combat_delays_reminder = FALSE
		mode.objective_reminder_interval = 10 MINUTES
		objective_reminder_stacks = 0
		next_objective_reminder = world.time + mode.objective_reminder_interval

// Konsola łączności

/obj/machinery/computer/communications/ui_data(mob/user)
	. = ..()
	if(!.["authenticated"])
		return
	if(SSovermap_mode.extension_choice_pending)
		var/list/next_choices = list()
		for(var/choice in SSovermap_mode.extension_choices)
			if(choice == EXTENSION_RUBICON)
				next_choices += list(list(
					"id" = EXTENSION_RUBICON,
					"name" = "Atak na Rubikon",
					"brief" = "Pokonajcie wszystkich wrogów w systemie Rubikon. Po wykonaniu statek wraca do domu.",
				))
				continue
			var/datum/overmap_gamemode/mode_type = choice
			next_choices += list(list(
				"id" = "[mode_type]",
				"name" = mission_choice_name(mode_type),
				"brief" = initial(mode_type.brief),
			))
		.["mission_choices"] = next_choices
		.["mission_choice_extension"] = TRUE
		.["can_choose_mission"] = authenticated_as_non_silicon_captain(user)
		return
	if(!SSovermap_mode.mission_choice_pending)
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
	if(!authenticated_as_non_silicon_captain(usr))
		return
	if(SSovermap_mode.extension_choice_pending)
		var/next_choice = params["id"] == EXTENSION_RUBICON ? EXTENSION_RUBICON : text2path(params["id"])
		if(!(next_choice in SSovermap_mode.extension_choices))
			return
		SSovermap_mode.finish_extension_choice(next_choice, usr)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
		return TRUE
	if(!SSovermap_mode.mission_choice_pending)
		return
	var/chosen_type = text2path(params["id"])
	if(!(chosen_type in SSovermap_mode.mission_choices))
		return
	SSovermap_mode.finish_mission_choice(chosen_type, usr)
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	return TRUE

#undef MISSION_CHOICE_COUNT
#undef EXTENSION_RUBICON
#undef EXTENSION_CHOICE_TIME
#undef REMINDER_OBJECTIVES
#undef REMINDER_COMBAT_RESET
#undef REMINDER_COMBAT_DELAY
#undef REMINDER_OVERRIDE
