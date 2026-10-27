/datum/AI_Module/proc/can_use(mob/living/silicon/ai/AI)
	return TRUE

/datum/AI_Module/large/nuke_station/can_use(mob/living/silicon/ai/AI)
	return !AI.mind?.has_antag_datum(/datum/antagonist/hijacked_ai)

/datum/AI_Module/large/place_cyborg_transformer/can_use(mob/living/silicon/ai/AI)
	return !AI.mind?.has_antag_datum(/datum/antagonist/hijacked_ai)

// Moduły, których dana SI nie może kupić, nie pojawiają się w sklepie
/datum/module_picker/ui_static_data(mob/user)
	. = ..()
	if(!isAI(user))
		return
	var/list/blocked_names = list()
	for(var/datum/AI_Module/module as anything in possible_modules)
		if(!module.can_use(user))
			blocked_names += module.module_name
	if(!length(blocked_names))
		return
	var/list/allowed = list()
	for(var/list/module_data as anything in .["modules"])
		if(!(module_data["name"] in blocked_names))
			allowed += list(module_data)
	.["modules"] = allowed

/datum/module_picker/purchase_module(mob/living/silicon/ai/A, datum/AI_Module/AM)
	if(istype(A) && istype(AM) && !AM.can_use(A))
		to_chat(A, span_warning("Ten moduł jest dla ciebie niedostępny."))
		return
	return ..()
