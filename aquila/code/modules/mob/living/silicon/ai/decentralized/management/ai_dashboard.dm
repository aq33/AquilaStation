GLOBAL_LIST_INIT(ai_project_categories, list(
	AI_PROJECT_HUDS,
	AI_PROJECT_CAMERAS,
	AI_PROJECT_SURVEILLANCE,
	AI_PROJECT_INDUCTION,
	AI_PROJECT_EFFICIENCY,
	AI_PROJECT_MISC,
))

/datum/ai_dashboard
	var/mob/living/silicon/ai/owner

	//What we're currently using, not what we're being granted by the ai data core
	var/list/cpu_usage
	var/list/ram_usage
	var/free_ram = 0

	///Lazylist of all AI projects we can start.
	var/list/available_projects
	///Lazylist of all AI projects we're currently researching.
	var/list/running_projects
	///Lazylist of all AI projects we've completed.
	var/list/completed_projects

	///Should we be contributing spare CPU to generate research points?
	var/contribute_spare_cpu = TRUE
	///Are we using 50% of our spare CPU to mine bitcoin?
	var/crypto_mining = FALSE

/datum/ai_dashboard/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
		return
	owner = new_owner
	cpu_usage = list()
	ram_usage = list()

	for(var/path in subtypesof(/datum/ai_project))
		var/datum/ai_project/project = path
		if(initial(project.abstract_type) == path)
			continue
		LAZYADD(available_projects, new path(owner, src))

/datum/ai_dashboard/Destroy(force)
	for(var/datum/ai_project/project as anything in running_projects)
		project.stop()
	owner = null
	cpu_usage = null
	ram_usage = null
	QDEL_LIST(available_projects)
	QDEL_LIST(completed_projects)
	running_projects = null
	return ..()

/datum/ai_dashboard/proc/is_interactable(mob/user)
	if(user?.client?.holder)
		return TRUE
	if(user != owner || owner.incapacitated())
		return FALSE
	if(owner.control_disabled)
		to_chat(user, span_warning("Sterowanie bezprzewodowe jest wyłączone."))
		return FALSE
	return TRUE

/datum/ai_dashboard/ui_status(mob/user)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/ai_dashboard/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_dashboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiDashboard")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/ai_dashboard/ui_data(mob/user)
	var/list/data = list()

	var/datum/ai_os/owner_os = owner.get_ai_os()

	data["current_cpu"] = owner_os?.cpu_assigned[owner] || 0
	data["current_ram"] = (owner_os?.ram_assigned[owner] || 0) + free_ram

	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		total_cpu_used += cpu_usage[I]

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	data["contribute_spare_cpu"] = contribute_spare_cpu

	data["used_cpu"] = total_cpu_used
	data["used_ram"] = total_ram_used

	data["max_cpu"] = owner_os?.total_cpu || 0
	data["max_ram"] = owner_os?.total_ram || 0

	data["categories"] = GLOB.ai_project_categories
	data["available_projects"] = list()

	var/turf/current_turf = get_turf(owner)

	data["integrity"] = owner.health

	data["location_name"] = get_area_name(current_turf, TRUE)

	data["location_coords"] = "[current_turf?.x], [current_turf?.y], [current_turf?.z]"

	var/obj/machinery/ai/current_machine = owner.loc
	data["temperature"] = istype(current_machine) ? round(current_machine.core_temp, 0.1) : 0

	for(var/datum/ai_project/AP as anything in available_projects)
		var/list/requirement_names = list()
		for(var/datum/ai_project/requirement as anything in AP.research_requirements)
			requirement_names += initial(requirement.name)
		data["available_projects"] += list(list(
			"name" = AP.name,
			"description" = AP.description,
			"ram_required" = AP.ram_required,
			"available" = AP.can_research(),
			"research_cost" = AP.research_cost,
			"research_progress" = AP.research_progress,
			"assigned_cpu" = cpu_usage[AP.name] || 0,
			"research_requirements" = length(requirement_names) ? jointext(requirement_names, ", ") : null,
			"category" = AP.category,
		))

	var/list/ability_paths = list()
	data["completed_projects"] = list()
	data["chargeable_abilities"] = list()
	for(var/datum/ai_project/P as anything in completed_projects)
		data["completed_projects"] += list(list(
			"name" = P.name,
			"description" = P.description,
			"ram_required" = P.ram_required,
			"running" = P.running,
			"category" = P.category,
			"can_be_run" = P.can_be_run,
		))
		if(P.ability_path && !(P.ability_path in ability_paths)) //Check that we've not already added a thing to recharge this type of ability
			if(P.ability_recharge_cost <= 0)
				continue
			ability_paths += P.ability_path
			var/datum/action/innate/ai/the_ability = locate(P.ability_path) in owner.actions
			if(the_ability)
				data["chargeable_abilities"] += list(list(
					"assigned_cpu" = cpu_usage[P.name] || 0,
					"cost" = P.ability_recharge_cost,
					"progress" = P.ability_recharge_invested,
					"name" = the_ability.name,
					"project_name" = P.name,
					"uses" = the_ability.uses,
					"max_uses" = P.get_ability_max_uses(the_ability),
				))

	return data

/datum/ai_dashboard/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!is_interactable(usr))
		return

	switch(action)
		if("run_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!project || !has_completed_project(project.type) || !run_project(project))
				to_chat(owner, span_warning("Nie można uruchomić programu „[params["project_name"]]”."))
			else
				to_chat(owner, span_notice("Uruchamianie instancji programu [params["project_name"]]..."))
				. = TRUE
		if("stop_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(project)
				stop_project(project)
				to_chat(owner, span_notice("Instancja programu [params["project_name"]] zakończona."))
				. = TRUE
		if("allocate_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"], TRUE)
			if(!project || !set_project_cpu(project, text2num(params["amount"])))
				to_chat(owner, span_warning("Nie można przydzielić CPU do [params["project_name"]]. Brak wolnego CPU albo projekt niedostępny."))
			. = TRUE
		if("allocate_recharge_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!project || !has_completed_project(project.type))
				return
			var/datum/action/innate/ai/the_ability = locate(project.ability_path) in owner.actions
			if(!the_ability)
				return
			if(!set_project_cpu(project, text2num(params["amount"])))
				to_chat(owner, span_warning("Nie można przydzielić CPU do [params["project_name"]]. Brak wolnego CPU albo ładowanie niedostępne."))
			. = TRUE
		if("max_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"], TRUE)
			if(!project)
				to_chat(owner, span_warning("Nie można przydzielić CPU do [params["project_name"]]. Brak wolnego CPU albo projekt niedostępny."))
				return

			var/total_cpu_used = 0
			for(var/I in cpu_usage)
				if(I == project.name)
					continue
				total_cpu_used += cpu_usage[I]

			var/amount_to_add = 1 - total_cpu_used
			if(!set_project_cpu(project, amount_to_add))
				to_chat(owner, span_warning("Nie można przydzielić CPU do [params["project_name"]]. Brak wolnego CPU albo projekt niedostępny."))
			. = TRUE
		if("clear_ai_resources")
			var/datum/ai_os/owner_os = owner.get_ai_os()
			owner_os?.clear_ai_resources(owner)
			. = TRUE
		if("toggle_contribute_cpu")
			contribute_spare_cpu = !contribute_spare_cpu
			to_chat(owner, span_notice("[contribute_spare_cpu ? "Oddajesz" : "NIE oddajesz"] wolnego CPU na punkty badań SI."))
			. = TRUE

/datum/ai_dashboard/proc/get_project_by_name(project_name, only_available = FALSE)
	for(var/datum/ai_project/AP as anything in available_projects)
		if(AP.name == project_name)
			return AP
	if(!only_available)
		for(var/datum/ai_project/AP as anything in completed_projects)
			if(AP.name == project_name)
				return AP

	return FALSE

/datum/ai_dashboard/proc/set_project_cpu(datum/ai_project/project, amount)
	if(!project.can_research())
		return FALSE

	if(!isnum(amount) || amount < 0)
		return FALSE

	//what are you recharging?
	if(has_completed_project(project.type) && !project.ability_recharge_cost)
		return FALSE

	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		if(I == project.name)
			continue
		total_cpu_used += cpu_usage[I]

	if(amount > (1 - total_cpu_used))
		return FALSE
	cpu_usage[project.name] = amount
	return TRUE

/datum/ai_dashboard/proc/run_project(datum/ai_project/project)
	var/datum/ai_os/owner_os = owner.get_ai_os()
	var/current_ram = (owner_os?.ram_assigned[owner] || 0) + free_ram

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	if(current_ram - total_ram_used >= project.ram_required && project.canRun())
		if(!project.run_project())
			return FALSE
		ram_usage[project.name] += project.ram_required
		return TRUE
	return FALSE

/datum/ai_dashboard/proc/stop_project(datum/ai_project/project)
	project.stop()
	if(ram_usage[project.name])
		ram_usage[project.name] -= project.ram_required
		return project.ram_required

	return FALSE

/datum/ai_dashboard/proc/has_completed_project(project_type)
	for(var/datum/ai_project/P as anything in completed_projects)
		if(P.type == project_type)
			return TRUE
	return FALSE

/datum/ai_dashboard/proc/finish_project(datum/ai_project/project, notify_user = TRUE)
	LAZYREMOVE(available_projects, project)
	LAZYADD(completed_projects, project)
	cpu_usage[project.name] = 0
	project.finish()
	if(notify_user)
		to_chat(owner, span_notice("Ukończono projekt [project.name]. Możesz go uruchomić w panelu."))

/datum/ai_dashboard/proc/recharge_ability(datum/ai_project/project, notify_user = TRUE)
	if(!project.ability_path)
		return
	var/datum/action/innate/ai/ability = locate(project.ability_path) in owner.actions
	if(!ability)
		return
	ability.uses++
	project.ability_recharge_invested = 0
	if(ability.uses >= project.get_ability_max_uses(ability))
		cpu_usage[project.name] = 0
	ability.UpdateButtonIcon()

	if(notify_user)
		to_chat(owner, span_notice("Naładowano „[ability.name]”."))

//Stuff is handled in here per tick :)
/datum/ai_dashboard/proc/tick(seconds_per_tick)
	var/datum/ai_os/owner_os = owner.get_ai_os()
	if(isnull(owner_os))
		return

	var/current_cpu = owner_os.cpu_assigned[owner] || 0
	var/current_ram = (owner_os.ram_assigned[owner] || 0) + free_ram

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	var/reduction_of_resources = FALSE

	if(total_ram_used > current_ram)
		for(var/I in ram_usage)
			var/datum/ai_project/project = get_project_by_name(I)
			if(!ram_usage[I]) //We only stop the program if it actually has any RAM usage
				continue
			total_ram_used -= stop_project(project)
			reduction_of_resources = TRUE
			if(total_ram_used <= current_ram)
				break

	if(reduction_of_resources)
		to_chat(owner, span_warning("Brak mocy obliczeniowej. Część programów mogła zostać zatrzymana."))

	var/remaining_cpu = current_cpu
	for(var/I in cpu_usage)
		remaining_cpu -= cpu_usage[I] * current_cpu

	if(remaining_cpu > 0 && contribute_spare_cpu)
		var/points = max(round(AI_RESEARCH_PER_CPU * remaining_cpu * seconds_per_tick, 0.1), 0)

		if(crypto_mining)
			points *= 0.5
			var/bitcoin_mined = (points * 3) / (1 + 0.2 * sqrt(points))
			bitcoin_mined = clamp(bitcoin_mined, 0, MAX_AI_BITCOIN_MINED_PER_TICK)
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(D)
				D.adjust_money(round(bitcoin_mined * AI_BITCOIN_PRICE))

		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_AI = points))

	for(var/project_being_researched in cpu_usage)
		if(!cpu_usage[project_being_researched])
			continue
		var/used_cpu = round(cpu_usage[project_being_researched] * current_cpu * seconds_per_tick, 0.1)
		var/datum/ai_project/project = get_project_by_name(project_being_researched)
		if(!project)
			cpu_usage[project_being_researched] = 0
			continue
		if(has_completed_project(project.type)) //This means we're an ability recharging
			if(!project.ability_recharge_cost) //No ability, just waste the CPU
				continue
			project.invest_ability(used_cpu)
			if(project.ability_recharge_invested > project.ability_recharge_cost)
				owner.playsound_local(owner, 'sound/machines/ping.ogg', 50, 0)
				recharge_ability(project)
			continue
		project.research_progress += used_cpu
		if(project.research_progress > project.research_cost)
			owner.playsound_local(owner, 'sound/machines/ping.ogg', 50, 0)
			finish_project(project)
