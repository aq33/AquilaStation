SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = INIT_ORDER_EVENTS
	runlevels = RUNLEVEL_GAME

	var/list/control = list()	//list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/running = list()	//list of all existing /datum/round_event
	var/list/currentrun = list()

	var/scheduled = 0			//The next world.time that a naturally occuring random event can be selected.
	var/frequency_lower = 4200	//7 minutes lower bound.
	var/frequency_upper = 6000	//10 minutes upper bound. Basically an event will happen every 7 to 10 minutes.

	var/list/holidays			//List of all holidays occuring today or null if no holidays
	var/wizardmode = FALSE

/datum/controller/subsystem/events/Initialize(time, zlevel)
	for(var/type in typesof(/datum/round_event_control))
		var/datum/round_event_control/E = new type()
		if(!E.typepath || !E.auto_add)
			continue				//don't want this one! leave it for the garbage collector
		control += E				//add it to the list of all events (controls)
	reschedule()
	getHoliday()
	return ..()


/datum/controller/subsystem/events/fire(resumed = 0)
	if(!resumed)
		checkEvent() //only check these if we aren't resuming a paused fire
		src.currentrun = running.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process(wait * 0.1)
		else
			running.Remove(thing)
		if (MC_TICK_CHECK)
			return

//checks if we should select a random event yet, and reschedules if necessary
/datum/controller/subsystem/events/proc/checkEvent()
	if(scheduled <= world.time)
		spawnEvent()
		reschedule()

//decides which world.time we should select another random event at.
/datum/controller/subsystem/events/proc/reschedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))

//selects a random event based on whether it can occur and it's 'weight'(probability)
/datum/controller/subsystem/events/proc/spawnEvent()
	set waitfor = FALSE	//for the admin prompt
	if(!CONFIG_GET(flag/allow_random_events))
		return

	var/gamemode = SSticker.mode.config_tag
	var/players_amt = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	// Only alive, non-AFK human players count towards this.

	var/sum_of_weights = 0

	//AQ EDIT - every event that meets its requirements has the same chance, see get_random_weight().
	//The star system event lists (/datum/star_system/var/possible_events) only let in their weight 0 events
	//(deadly radiation storm, radioactive sludge), which never roll anywhere else.
	var/obj/structure/overmap/mainship = SSstar_system.find_main_overmap()
	var/list/system_events = mainship?.current_system?.possible_events
	var/list/possible_events = list()
	for(var/datum/round_event_control/E in control)
		if(!E.canSpawnEvent(players_amt, gamemode))
			continue
		if(E.weight < 0)						//for round-start events etc.
			var/res = TriggerEvent(E)
			if(res == EVENT_INTERRUPTED)
				continue	//like it never happened
			if(res == EVENT_CANT_RUN)
				return
			continue
		var/event_weight = E.get_random_weight()
		if(event_weight <= 0 && (E.type in system_events))
			event_weight = 10
		if(event_weight <= 0)
			continue
		possible_events[E] = event_weight
		sum_of_weights += event_weight

	//AQ EDIT - rand(0, sum) used to land on 0 now and then and pick the first runnable event in the list, even one with weight 0
	if(sum_of_weights <= 0)
		return
	sum_of_weights = rand(1,sum_of_weights)	//reusing this variable. It now represents the 'weight' we want to select

	for(var/datum/round_event_control/E in possible_events)
		sum_of_weights -= possible_events[E]

		if(sum_of_weights <= 0)				//we've hit our goal
			if(TriggerEvent(E))
				return

/datum/controller/subsystem/events/proc/TriggerEvent(datum/round_event_control/E)
	. = E.preRunEvent()
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		E.max_occurrences = 0
	else if(. == EVENT_READY)
		E.random = TRUE
		E.runEvent()

//allows a client to trigger an event
//aka Badmin Central
// > Not in modules/admin
// REEEEEEEEE
/client/proc/forceEvent()
	set name = "Trigger Event"
	set category = "Round"

	if(!holder ||!check_rights(R_FUN))
		return

	holder.forceEvent()

/datum/admins/proc/forceEvent()
	// AQUILA EDIT - okno TGUI (ForceEvent z tg) zamiast listy linków HTML
	if(!check_rights(R_FUN))
		return
	var/datum/force_event/ui = new()
	ui.ui_interact(usr)

#define FORCE_EVENT_CATEGORY_NORMAL "Zwykłe"
#define FORCE_EVENT_CATEGORY_WIZARD "Magiczne"
#define FORCE_EVENT_CATEGORY_HOLIDAY "Świąteczne"

/// AQUILA - panel wymuszania eventów (port ForceEvent z tg)
/datum/force_event

/datum/force_event/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ForceEvent")
		ui.open()

/datum/force_event/ui_state(mob/user)
	return GLOB.admin_state

/datum/force_event/ui_close(mob/user)
	qdel(src)

/datum/force_event/ui_static_data(mob/user)
	var/list/data = list()
	var/list/events = list()
	var/list/categories_seen = list()
	for(var/datum/round_event_control/event_control as anything in SSevents.control)
		var/category = FORCE_EVENT_CATEGORY_NORMAL
		if(event_control.holidayID)
			category = FORCE_EVENT_CATEGORY_HOLIDAY
		else if(event_control.wizardevent)
			category = FORCE_EVENT_CATEGORY_WIZARD
		categories_seen[category] = TRUE
		events += list(list(
			"name" = event_control.name,
			"type" = event_control.type,
			"category" = category,
		))
	var/list/categories = list()
	var/static/list/category_icons = list(
		FORCE_EVENT_CATEGORY_NORMAL = "bolt",
		FORCE_EVENT_CATEGORY_WIZARD = "hat-wizard",
		FORCE_EVENT_CATEGORY_HOLIDAY = "calendar",
	)
	for(var/category in category_icons)
		if(categories_seen[category])
			categories += list(list("name" = category, "icon" = category_icons[category]))
	data["categories"] = categories
	data["events"] = events
	return data

/datum/force_event/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_FUN))
		return
	switch(action)
		if("forceevent")
			var/event_to_run_type = text2path(params["type"])
			if(!event_to_run_type)
				return
			var/datum/round_event_control/E = locate(event_to_run_type) in SSevents.control
			if(!E)
				return
			INVOKE_ASYNC(src, PROC_REF(run_forced_event), usr, E, !!params["announce"])
			return TRUE

/// Odpowiednik dawnego Topic forceevent: konfiguracja admina, uruchomienie i wybór ogłoszenia z okna
/datum/force_event/proc/run_forced_event(mob/user, datum/round_event_control/E, announce)
	E.admin_setup(user)
	var/datum/round_event/event = E.runEvent()
	if(event.announceWhen > 0)
		event.processing = FALSE
		event.announceChance = announce ? 100 : 0
		event.on_admin_trigger()
		event.processing = TRUE
	message_admins("[key_name_admin(user)] wywołuje event. ([E.name])")
	log_admin("[key_name(user)] has triggered an event. ([E.name])")

#undef FORCE_EVENT_CATEGORY_NORMAL
#undef FORCE_EVENT_CATEGORY_WIZARD
#undef FORCE_EVENT_CATEGORY_HOLIDAY


/*
//////////////
// HOLIDAYS //
//////////////
//Uncommenting ALLOW_HOLIDAYS in config.txt will enable holidays

//It's easy to add stuff. Just add a holiday datum in code/modules/holiday/holidays.dm
//You can then check if it's a special day in any code in the game by doing if(SSevents.holidays["Groundhog Day"])

//You can also make holiday random events easily thanks to Pete/Gia's system.
//simply make a random event normally, then assign it a holidayID string which matches the holiday's name.
//Anything with a holidayID, which isn't in the holidays list, will never occur.

//Please, Don't spam stuff up with stupid stuff (key example being april-fools Pooh/ERP/etc),
//And don't forget: CHECK YOUR CODE!!!! We don't want any zero-day bugs which happen only on holidays and never get found/fixed!

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//ALSO, MOST IMPORTANTLY: Don't add stupid stuff! Discuss bonus content with Project-Heads first please!//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

//sets up the holidays and holidays list
/datum/controller/subsystem/events/proc/getHoliday()
	if(!CONFIG_GET(flag/allow_holidays))
		return		// Holiday stuff was not enabled in the config!

	var/YY = text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	var/DDD = time2text(world.timeofday, "DDD")	// get the current weekday
	var/W = weekdayofthemonth()	// is this the first monday? second? etc.

	for(var/H in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new H()
		if(holiday.shouldCelebrate(DD, MM, YY, W, DDD))
			holiday.celebrate()
			if(!holidays)
				holidays = list()
			holidays[holiday.name] = holiday
		else
			qdel(holiday)

	if(holidays)
		holidays = shuffle(holidays)
		// regenerate station name because holiday prefixes.
		set_station_name(new_station_name())
		world.update_status()

/datum/controller/subsystem/events/proc/toggleWizardmode()
	wizardmode = !wizardmode
	message_admins("Przywołanie eventów zostaje [wizardmode ? "włączone, eventy będą się zdarzać co [SSevents.frequency_lower / 600]–[SSevents.frequency_upper / 600] min" : "wyłączone"]!")
	log_game("Summon Events was [wizardmode ? "enabled" : "disabled"]!")


/datum/controller/subsystem/events/proc/resetFrequency()
	frequency_lower = initial(frequency_lower)
	frequency_upper = initial(frequency_upper)
