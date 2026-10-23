// Drukowanie nowego kodu kontrolnego SI na konsoli komunikacyjnej (port Monkestation/Monkestation2.0#11862)

/obj/machinery/computer/communications/proc/authenticated_as_non_silicon_head(mob/user)
	if(issilicon(user))
		return FALSE
	return ACCESS_HEADS in authorize_access

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = ..()
	data["canPrintAIControlCode"] = authenticated_as_non_silicon_head(user)
	return data

/obj/machinery/computer/communications/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "printAIControlCode")
		return
	if(!authenticated_as_non_silicon_head(usr) || !COOLDOWN_FINISHED(src, important_action_cooldown))
		return
	playsound(loc, 'sound/items/poster_being_created.ogg', 100, TRUE)
	GLOB.ai_control_code = random_ai_control_code()
	new /obj/item/paper/ai_control_code(loc)
	COOLDOWN_START(src, important_action_cooldown, 60 SECONDS)
	usr.log_message("printed a new AI control code.", LOG_GAME)
	priority_announce("[usr] wydrukował(a) nowy kod kontrolny SI. Wszystkie poprzednie kody są nieważne.", "Centralne Wsparcie Techniczne")
	return TRUE
