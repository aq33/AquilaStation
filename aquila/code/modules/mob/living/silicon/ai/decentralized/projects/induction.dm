// induction.dm, lights_control.dm i self_defense.dm z Monke

/datum/ai_project/induction_basic
	name = "Podstawy indukcji bluespace"
	description = "Wymagane do dalszych badań indukcji, np. zdalnego ładowania cyborgów i APC."
	research_cost = 1500
	ram_required = 0
	can_be_run = FALSE
	category = AI_PROJECT_INDUCTION

/datum/ai_project/induction_cyborg
	name = "Indukcja bluespace - cyborgi"
	description = "Pozwala naładować widocznego cyborga o 33%."
	research_cost = 2500
	ram_required = 0
	research_requirements = list(/datum/ai_project/induction_basic)
	category = AI_PROJECT_INDUCTION
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/project/charge_borg_or_apc
	ability_recharge_cost = 1500

/datum/ai_project/induction_cyborg/finish()
	var/datum/action/innate/ai/ranged/project/charge_borg_or_apc/ability = add_ability(/datum/action/innate/ai/ranged/project/charge_borg_or_apc)
	ability.works_on_borgs = TRUE
	ability.update_name()

/datum/ai_project/induction_apc
	name = "Indukcja bluespace - APC"
	description = "Pozwala naładować widoczne APC o 33%."
	research_cost = 2500
	ram_required = 0
	research_requirements = list(/datum/ai_project/induction_basic)
	category = AI_PROJECT_INDUCTION
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/project/charge_borg_or_apc
	ability_recharge_cost = 1500

/datum/ai_project/induction_apc/finish()
	var/datum/action/innate/ai/ranged/project/charge_borg_or_apc/ability = add_ability(/datum/action/innate/ai/ranged/project/charge_borg_or_apc)
	ability.works_on_apcs = TRUE
	ability.update_name()

/datum/action/innate/ai/ranged/project/charge_borg_or_apc
	name = "Ładowanie indukcyjne"
	desc = "Ładuje cyborga albo APC w zasięgu kamer o 33%."
	button_icon_state = "electrified"
	icon_icon = 'aquila/icons/mob/ai_servers_ui.dmi'
	uses = 1
	linked_ability_type = /obj/effect/proc_holder/ranged_ai/charge_borg_or_apc
	var/works_on_borgs = FALSE
	var/works_on_apcs = FALSE

/datum/action/innate/ai/ranged/project/charge_borg_or_apc/proc/update_name()
	if(works_on_borgs && works_on_apcs)
		name = "Ładowanie cyborga/APC"
		desc = "Kliknij cyborga albo APC, żeby naładować go o 33%."
	else if(works_on_borgs)
		name = "Ładowanie cyborga"
		desc = "Kliknij cyborga, żeby naładować go o 33%."
	else if(works_on_apcs)
		name = "Ładowanie APC"
		desc = "Kliknij APC, żeby naładować je o 33%."
	UpdateButtonIcon()

/datum/action/innate/ai/ranged/project/charge_borg_or_apc/proc/charge_borg_or_apc(atom/target)
	if(!target || QDELETED(target))
		return FALSE
	if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		if(!R.cell)
			to_chat(owner, span_warning("[R] nie ma ogniwa do naładowania!"))
			return FALSE
		if(R.cell.charge >= R.cell.maxcharge)
			to_chat(owner, span_warning("Ogniwo [R] jest już pełne!"))
			return FALSE
		log_game("[key_name(owner)] charged [R.name] via AI induction.")
		R.cell.give(R.cell.maxcharge * 0.33)
		return TRUE
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/APC = target
		if(!APC.cell)
			to_chat(owner, span_warning("APC nie ma ogniwa do naładowania!"))
			return FALSE
		if(APC.cell.charge >= APC.cell.maxcharge)
			to_chat(owner, span_warning("APC jest już w pełni naładowane!"))
			return FALSE
		log_game("[key_name(owner)] charged [APC.name] at [AREACOORD(APC)] via AI induction.")
		APC.cell.give(APC.cell.maxcharge * 0.33)
		return TRUE
	return FALSE

/obj/effect/proc_holder/ranged_ai/charge_borg_or_apc
	active = FALSE
	enable_text = span_notice("Przygotowujesz cewki indukcyjne bluespace. Kliknij cyborga albo APC, żeby naładować jego ogniwo o 33%.")
	disable_text = span_notice("Wyłączasz cewki indukcyjne.")

/obj/effect/proc_holder/ranged_ai/charge_borg_or_apc/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	var/datum/action/innate/ai/ranged/project/charge_borg_or_apc/action = attached_action
	if(ranged_ability_user.incapacitated() || !istype(action))
		remove_ranged_ability()
		return
	if(!iscyborg(target) && !istype(target, /obj/machinery/power/apc))
		to_chat(ranged_ability_user, span_warning("Możesz ładować tylko cyborgi i APC!"))
		return
	if(!action.works_on_borgs && iscyborg(target))
		to_chat(ranged_ability_user, span_warning("Możesz ładować tylko APC!"))
		return
	if(!action.works_on_apcs && istype(target, /obj/machinery/power/apc))
		to_chat(ranged_ability_user, span_warning("Możesz ładować tylko cyborgi!"))
		return
	if(action.uses <= 0)
		to_chat(ranged_ability_user, span_warning("Brak ładunków! Naładuj je cyklami CPU w panelu SI."))
		remove_ranged_ability()
		return
	ranged_ability_user.playsound_local(ranged_ability_user, "sparks", 50, FALSE)
	if(action.charge_borg_or_apc(target))
		action.adjust_uses(-1)
		do_sparks(3, FALSE, target)
		to_chat(ranged_ability_user, span_notice("Ładujesz [target]."))
		target.audible_message(span_userdanger("Słyszysz kojący elektryczny szum z [target]!"))
		remove_ranged_ability()
	return TRUE

/datum/ai_project/lights_control
	name = "Sterowanie światłem"
	description = "Przejęcie przestarzałego punktu IoT pozwala zmieniać tryb oświetlenia w pomieszczeniu, na które patrzysz."
	research_cost = 1000
	ram_required = 0
	category = AI_PROJECT_MISC

/datum/ai_project/lights_control/run_project(force_run)
	. = ..()
	if(.)
		add_ability(/datum/action/innate/ai/project/lights_control)

/datum/ai_project/lights_control/stop()
	remove_ability(/datum/action/innate/ai/project/lights_control)
	return ..()

/datum/action/innate/ai/project/lights_control
	name = "Sterowanie światłem"
	desc = "Zmienia tryb oświetlenia w obszarze, na który patrzysz."
	button_icon_state = "emergency_lights"
	uses = null
	auto_use_uses = FALSE

/datum/action/innate/ai/project/lights_control/Activate()
	var/chosen_color = "#FFFFFF"
	var/mode = tgui_input_list(owner_AI, "Jaki tryb ustawić?", "Sterowanie światłem", list("Domyślny", "Ultrafiolet", "Przygaszony", "Czerwony", "Ciepły", "WŁASNY"))
	if(!mode)
		return
	if(mode == "WŁASNY")
		chosen_color = tgui_color_picker(owner_AI, "Wybierz kolor", "[src]", chosen_color)
		if(!chosen_color)
			return
	var/area/area_to_control = get_area(owner_AI.eyeobj)
	var/turf/eye_turf = get_turf(owner_AI.eyeobj)
	if(!area_to_control || !eye_turf || !is_station_level(eye_turf.z))
		to_chat(owner_AI, span_warning("Nie mamy dostępu do oświetlenia w tym miejscu!"))
		return
	for(var/obj/machinery/light/controlled_light in area_to_control)
		switch(mode)
			if("Domyślny")
				controlled_light.bulb_colour = initial(controlled_light.bulb_colour)
			if("Ultrafiolet")
				controlled_light.bulb_colour = "#A700FF"
			if("Czerwony")
				controlled_light.bulb_colour = "#FF3232"
			if("Ciepły")
				controlled_light.bulb_colour = "#fae5c1"
			if("WŁASNY")
				controlled_light.bulb_colour = chosen_color
		if(mode == "Przygaszony")
			controlled_light.bulb_power = 0.6
		else
			controlled_light.bulb_power = initial(controlled_light.bulb_power)
		controlled_light.update()

/datum/ai_project/shock_defense
	name = "Obrona porażeniem"
	description = "Pozwala porazić prądem każdego w promieniu 2 kafelków od twoich rdzeni danych."
	research_cost = 3000
	ram_required = 0
	research_requirements = list(/datum/ai_project/induction_basic)
	can_be_run = FALSE
	category = AI_PROJECT_INDUCTION
	ability_path = /datum/action/innate/ai/project/shock_defense
	ability_recharge_cost = 2000

/datum/ai_project/shock_defense/finish()
	add_ability(/datum/action/innate/ai/project/shock_defense)

/datum/action/innate/ai/project/shock_defense
	name = "Obrona porażeniem"
	desc = "Razi prądem każdego w promieniu 2 kafelków od twoich rdzeni danych."
	button_icon_state = "emergency_lights"
	uses = 2

/datum/action/innate/ai/project/shock_defense/Activate()
	if(!isaicore(owner_AI.loc))
		to_chat(owner, span_warning("Musisz być w rdzeniu danych!"))
		adjust_uses(1, TRUE)
		return
	var/turf/ai_location_turf = get_turf(owner_AI)
	message_admins("[ADMIN_LOOKUPFLW(owner_AI)] used AI shock defense.")
	log_game("[key_name(owner_AI)] used AI shock defense at [AREACOORD(ai_location_turf)].")
	for(var/obj/machinery/ai/data_core/core as anything in GLOB.data_cores["[ai_location_turf.z]"])
		tesla_zap(core, 2, 8000, TESLA_MOB_DAMAGE | TESLA_MOB_STUN)
		core.use_power(core.idle_power_usage)
