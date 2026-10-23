/datum/ai_project/security_hud
	name = "Zaawansowany HUD ochrony"
	description = "Eksperymentalne pasywne czujniki dalekiego zasięgu wykrywają implanty, np. implanty lojalności i namierzające."
	research_cost = 1250
	ram_required = 2
	category = AI_PROJECT_HUDS

/datum/ai_project/security_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	var/was_on = ai.sensors_on
	if(was_on)
		ai.remove_sensors()
	ai.sec_hud = DATA_HUD_SECURITY_ADVANCED
	if(was_on)
		ai.add_sensors()

/datum/ai_project/security_hud/stop()
	//HUDs are weird. This has to be first so we're removed from the "advanced" HUD.
	var/was_on = ai.sensors_on
	if(was_on)
		ai.remove_sensors()
	ai.sec_hud = initial(ai.sec_hud)
	if(was_on)
		ai.add_sensors()
	return ..()

/datum/ai_project/diag_med_hud
	name = "Zaawansowany HUD medyczny i diagnostyczny"
	description = "Optymalizacja przetwarzania danych daje więcej informacji o ludziach i maszynach na HUD-ach medycznym i diagnostycznym."
	research_cost = 1000
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/diag_med_hud/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	var/was_on = ai.sensors_on
	if(was_on)
		ai.remove_sensors()
	ai.d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	ai.med_hud = DATA_HUD_MEDICAL_ADVANCED
	if(was_on)
		ai.add_sensors()

/datum/ai_project/diag_med_hud/stop()
	var/was_on = ai.sensors_on
	if(was_on)
		ai.remove_sensors()
	ai.d_hud = initial(ai.d_hud)
	ai.med_hud = initial(ai.med_hud)
	if(was_on)
		ai.add_sensors()
	return ..()

/datum/ai_project/tray_sensors
	name = "Czujniki T-Ray"
	description = "Przetwarzanie obrazu z kamer w paśmie terahercowym pokazuje rury i kable pod podłogą wokół oka kamery, jak ręczny skaner T-ray."
	research_cost = 500
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/tray_sensors/process()
	if(!ai?.client || !ai.eyeobj)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(9, ai.eyeobj))
		if(O.level != 1)
			continue
		if(O.invisibility == INVISIBILITY_MAXIMUM || HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(ai.client), 1 SECONDS)

/datum/ai_project/tray_sensors/run_project(force_run)
	. = ..()
	if(.)
		START_PROCESSING(SSprocessing, src)

/datum/ai_project/tray_sensors/stop()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/ai_project/engineeringscan
	name = "Zaawansowany skan inżynieryjny"
	description = "Analiza harmonicznych sieci energetycznej i czujników atmosfery pozwala sprawdzić prąd w kablach i atmosferę na kafelku po kliknięciu podłogi."
	research_cost = 500
	ram_required = 1
	category = AI_PROJECT_HUDS

/datum/ai_project/engineeringscan/run_project(force_run)
	. = ..()
	if(.)
		ai.canEngineeringScan = TRUE

/datum/ai_project/engineeringscan/stop()
	ai.canEngineeringScan = FALSE
	return ..()

/turf/open/attack_ai(mob/user)
	. = ..()
	if(!isAI(user))
		return
	var/mob/living/silicon/ai/ai_scanning = user
	if(!ai_scanning.canEngineeringScan)
		return
	atmosanalyzer_scan(user, src)
	for(var/obj/structure/cable/power_cable in contents)
		to_chat(user, power_cable.get_power_info())
