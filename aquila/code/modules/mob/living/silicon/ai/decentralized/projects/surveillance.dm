// examine.dm, firewall.dm i surveillance.dm z Monke

/datum/ai_project/examine_humans
	name = "Ulepszone badanie ludzi"
	description = "Eksperymentalne algorytmy poprawy obrazu pozwalają oglądać ludzi z bliska (shift-klik)."
	research_cost = 2000
	ram_required = 4
	research_requirements = list(/datum/ai_project/diag_med_hud)
	category = AI_PROJECT_SURVEILLANCE

/datum/ai_project/examine_humans/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.canExamineHumans = TRUE

/datum/ai_project/examine_humans/stop()
	ai.canExamineHumans = FALSE
	return ..()

/mob/living/carbon/human/AIShiftClick(mob/living/silicon/ai/user)
	if(!istype(user) || !user.canExamineHumans)
		return ..()
	user.examinate(src)

/mob/living/silicon/ai/run_examinate(atom/A)
	if(ishuman(A) && !canExamineHumans && get_ai_os()) // na mapach bez rdzeni danych bez zmian
		to_chat(src, span_warning("Do oglądania ludzi potrzebujesz projektu „Ulepszone badanie ludzi”."))
		return
	return ..()

/datum/ai_project/firewall
	name = "Zapora pobierania"
	description = "Przerobione narzędzia z archiwów sieci blokują próby pobrania twojej świadomości z konsoli sterowania SI."
	research_cost = 3000
	ram_required = 2
	category = AI_PROJECT_MISC

/datum/ai_project/firewall/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.can_download = FALSE

/datum/ai_project/firewall/stop()
	ai.can_download = TRUE
	return ..()

#define MAXIMUM_TARGET_TRACKING 2

/datum/ai_project/advanced_tracking
	name = "Zaawansowane śledzenie"
	description = "Osobny wątek śledzi do dwóch celów naraz poza głównym widokiem; ich położenie widać w panelu statusu. Wymaga ulepszonego badania ludzi."
	research_cost = 2500
	ram_required = 4
	research_requirements = list(/datum/ai_project/examine_humans)
	category = AI_PROJECT_SURVEILLANCE
	///List of mobs that we check on each tick if they're on the camera network
	var/list/mobs_to_track = list()

/datum/ai_project/advanced_tracking/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	mobs_to_track = null
	return ..()

/datum/ai_project/advanced_tracking/process()
	var/list/hit_mobs = list()
	for(var/mob/living/tracked as anything in mobs_to_track)
		if(QDELETED(tracked))
			mobs_to_track -= tracked
			continue
		if(tracked.can_track(ai))
			hit_mobs += tracked
	ai.target_list = hit_mobs

/datum/ai_project/advanced_tracking/run_project(force_run)
	. = ..()
	if(!.)
		return .
	mobs_to_track = list()
	var/datum/action/innate/ai/project/advanced_tracking/tracking = add_ability(/datum/action/innate/ai/project/advanced_tracking)
	tracking.tracker = src
	START_PROCESSING(SSprocessing, src)

/datum/ai_project/advanced_tracking/stop()
	remove_ability(/datum/action/innate/ai/project/advanced_tracking)
	ai.target_list = null
	mobs_to_track = list()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/ai_project/advanced_tracking/proc/add_target()
	if(length(mobs_to_track) >= MAXIMUM_TARGET_TRACKING)
		to_chat(ai, span_warning("Osiągnięto limit śledzonych celów! Czyszczenie listy."))
		mobs_to_track = list()
		return

	var/list/trackable = list()
	for(var/mob/living/L as anything in GLOB.mob_living_list)
		if(L == ai || !L.can_track(ai))
			continue
		var/entry_name = L.name
		var/index = 1
		while(trackable[entry_name])
			index++
			entry_name = "[L.name] ([index])"
		trackable[entry_name] = WEAKREF(L)
	var/target_name = tgui_input_list(ai, "Wybierz cel", "Śledzenie", sortList(trackable))
	if(!target_name || QDELETED(src))
		return
	var/datum/weakref/mob_ref = trackable[target_name]
	var/mob/living/target = mob_ref?.resolve()
	if(!target)
		to_chat(ai, span_notice("Cel nie jest w zasięgu żadnej aktywnej kamery. Śledzenie nieudane."))
		return
	mobs_to_track |= target

/datum/action/innate/ai/project/advanced_tracking
	name = "Zaawansowane śledzenie"
	desc = "Dodaje cel do zaawansowanego śledzenia."
	button_icon_state = "reactivate_cameras"
	uses = null
	auto_use_uses = FALSE
	/// the ai project we are referencing, everything but the button itself is put there.
	var/datum/ai_project/advanced_tracking/tracker

/datum/action/innate/ai/project/advanced_tracking/Destroy()
	tracker = null
	return ..()

/datum/action/innate/ai/project/advanced_tracking/Activate()
	tracker?.add_target()

#undef MAXIMUM_TARGET_TRACKING
