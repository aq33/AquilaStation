// camera_mobility.dm, nightvision.dm i view_range.dm z Monke w jednym pliku

/datum/ai_project/camera_speed
	name = "Przyspieszenie kamer"
	description = "Zaawansowane algorytmy uczenia głębokiego przyspieszają przesuwanie widoku po kamerach."
	research_cost = 250
	ram_required = 1
	category = AI_PROJECT_CAMERAS

/datum/ai_project/camera_speed/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.acceleration = TRUE

/datum/ai_project/camera_speed/stop()
	ai.acceleration = FALSE
	return ..()

/datum/ai_project/nightvision
	name = "Noktowizja kamer"
	description = "Porównanie z wcześniejszymi nagraniami i podbicie kontrastu pozwala przybliżyć obraz w zupełnie ciemnych miejscach."
	research_cost = 2000
	ram_required = 3
	category = AI_PROJECT_CAMERAS

/datum/ai_project/nightvision/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	if(ai.lighting_alpha <= LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
		to_chat(ai, span_warning("Obraz z kamer już jest rozjaśniony; pomijam zbędne przetwarzanie."))
		return .
	ai.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	ai.sync_lighting_plane_alpha()

/datum/ai_project/nightvision/stop()
	ai.lighting_alpha = initial(ai.lighting_alpha)
	ai.sync_lighting_plane_alpha()
	return ..()

/datum/ai_project/view_range
	name = "Rozszerzona sieć kamer"
	description = "Domyślny zasięg widoku sieci kamer można poszerzyć o 3 kafelki, żeby ogarniać więcej obrazu naraz."
	research_cost = 3000
	ram_required = 6
	research_requirements = list(/datum/ai_project/camera_speed)
	category = AI_PROJECT_CAMERAS

/datum/ai_project/view_range/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	ai.view_range_boost = 3
	if(!ai.multicam_on)
		ai.client?.view_size.setTo(ai.view_range_boost)

/datum/ai_project/view_range/stop()
	ai.view_range_boost = 0
	ai.client?.view_size.resetToDefault()
	return ..()
