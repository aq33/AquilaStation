/// Duży ekran, na którym SI pokazuje swój wizerunek. Sama SI mieszka w rdzeniu danych i nie jest widoczna.
/obj/machinery/ai_core_display
	name = "ekran rdzenia SI"
	desc = "Duży ekran, na którym SI pokazuje wybrany przez siebie wizerunek. UWAGA: tylko do wyświetlania, nie może przechowywać SI."
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai-empty"
	circuit = /obj/item/circuitboard/machine/ai_core_display
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	max_integrity = 200

	///If this is set, this will be the emotion the display uses, and it will not be able to be edited by an AI. Used for map VV edits.
	var/custom_emotion
	///The AI that controls the core display, it changes emotions as they do.
	var/mob/living/silicon/ai/connected_ai

/obj/machinery/ai_core_display/Initialize(mapload)
	. = ..()
	if(custom_emotion)
		update_icon()
		return

	RegisterSignal(SSdcs, COMSIG_GLOB_AI_CREATED, PROC_REF(on_ai_creation))

	//check if there's only 1 AI, we'll assign ourselves to them (if we are on their z-level) if so.
	if(length(GLOB.ai_list) != 1)
		return
	var/mob/living/silicon/ai/living_ai = GLOB.ai_list[1]
	if(!ai_nearby(living_ai))
		return
	assign_ai(living_ai)

/obj/machinery/ai_core_display/Destroy()
	assign_ai(null)
	return ..()

/obj/machinery/ai_core_display/examine(mob/user)
	. = ..()
	if(connected_ai)
		. += span_notice("Wyświetla: [connected_ai.name].")

/obj/machinery/ai_core_display/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 4 SECONDS)
	return TRUE

/obj/machinery/ai_core_display/screwdriver_act(mob/living/user, obj/item/I)
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	return TRUE

/obj/machinery/ai_core_display/crowbar_act(mob/living/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

#define DISPLAY_REQUEST_TAKEOVER "Przejmij siłą"
#define DISPLAY_REQUEST_NICELY "Poproś"
#define DISPLAY_REQUEST_CANCEL "Anuluj"

/obj/machinery/ai_core_display/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	if(isnull(connected_ai))
		assign_ai(user)
	if(user == connected_ai)
		user.pick_icon()
		return
	if(!ai_nearby(user))
		to_chat(user, span_warning("Ten ekran jest w innej sieci!"))
		return
	var/request_prompt = tgui_alert(user, "Ten ekran należy do innej SI. Możesz poprosić, żeby go oddała, albo przejąć go siłą, jeśli masz więcej CPU.",
		"Ekran rdzenia SI", list(DISPLAY_REQUEST_TAKEOVER, DISPLAY_REQUEST_NICELY, DISPLAY_REQUEST_CANCEL))
	switch(request_prompt)
		if(DISPLAY_REQUEST_TAKEOVER)
			hostile_takeover(user)
		if(DISPLAY_REQUEST_NICELY)
			if(!connected_ai)
				assign_ai(user)
				return
			if(tgui_alert(connected_ai, "[user.name] prosi o przekazanie ekranu rdzenia w [get_area_name(src, TRUE)].", "Ekran rdzenia SI", list("Zgoda", "Odmowa"), 15 SECONDS) != "Zgoda")
				to_chat(user, span_notice("[connected_ai.name] odmawia. Nadal możesz spróbować przejąć ekran <a href='byond://?src=[REF(src)];AI_taking_over=[REF(user)]'>siłą</a>, jeśli masz więcej CPU niż [connected_ai.name]."))
				return
			assign_ai(user)

#undef DISPLAY_REQUEST_TAKEOVER
#undef DISPLAY_REQUEST_NICELY
#undef DISPLAY_REQUEST_CANCEL

/obj/machinery/ai_core_display/Topic(href, href_list)
	. = ..()
	if(href_list["AI_taking_over"])
		var/mob/living/silicon/ai/usurper = locate(href_list["AI_taking_over"]) in GLOB.ai_list
		if(!istype(usurper) || usr != usurper)
			return
		hostile_takeover(usurper)

/obj/machinery/ai_core_display/proc/hostile_takeover(mob/living/silicon/ai/usurper)
	if(!connected_ai)
		assign_ai(usurper)
		return
	var/datum/ai_os/usurper_os = usurper.get_ai_os()
	var/datum/ai_os/connected_os = connected_ai.get_ai_os()
	if(usurper_os && usurper_os.cpu_assigned[usurper] > (connected_os?.cpu_assigned[connected_ai] || 0))
		to_chat(connected_ai, span_warning("[usurper] przejmuje ekran rdzenia w [get_area_name(src, TRUE)]!"))
		assign_ai(usurper)
	else
		to_chat(usurper, span_warning("Masz za mało CPU!"))
		to_chat(connected_ai, span_warning("[usurper] próbuje przejąć ekran rdzenia w [get_area_name(src, TRUE)], ale ma za mało CPU!"))

/obj/machinery/ai_core_display/power_change()
	. = ..()
	update_icon()

/obj/machinery/ai_core_display/update_icon_state()
	if(machine_stat & (NOPOWER|BROKEN))
		icon = initial(icon)
		icon_state = initial(icon_state)
		return ..()
	if(custom_emotion)
		icon = initial(icon)
		icon_state = custom_emotion
	else if(connected_ai)
		icon = connected_ai.icon
		icon_state = connected_ai.stat == DEAD ? "ai_dead" : connected_ai.icon_state
	else
		icon = initial(icon)
		icon_state = initial(icon_state)
	return ..()

/obj/machinery/ai_core_display/proc/assign_ai(mob/living/silicon/ai/new_ai)
	if(connected_ai == new_ai)
		return
	if(connected_ai)
		UnregisterSignal(connected_ai, list(COMSIG_PARENT_QDELETING, COMSIG_AI_ICON_CHANGE, COMSIG_MOB_DEATH))
	connected_ai = new_ai
	if(connected_ai)
		RegisterSignal(connected_ai, COMSIG_PARENT_QDELETING, PROC_REF(on_ai_deleting))
		RegisterSignal(connected_ai, list(COMSIG_AI_ICON_CHANGE, COMSIG_MOB_DEATH), PROC_REF(on_ai_screen_change))
	update_icon()

///Called when the first AI of the round is created, as we get automatically assigned to it.
/obj/machinery/ai_core_display/proc/on_ai_creation(datum/source, mob/living/silicon/ai/new_ai)
	SIGNAL_HANDLER
	if(connected_ai || custom_emotion)
		return
	addtimer(CALLBACK(src, PROC_REF(try_assign_new_ai), new_ai), 1)

/obj/machinery/ai_core_display/proc/try_assign_new_ai(mob/living/silicon/ai/new_ai)
	if(connected_ai || QDELETED(new_ai))
		return
	//Not on our level, we don't care.
	if(!ai_nearby(new_ai))
		return
	assign_ai(new_ai)

///Czy SI siedzi w rdzeniu danych na naszym poziomie (ekran nie jest częścią sieci ethernet)
/obj/machinery/ai_core_display/proc/ai_nearby(mob/living/silicon/ai/target_ai)
	var/turf/our_turf = get_turf(src)
	if(!our_turf || !target_ai)
		return FALSE
	var/obj/machinery/ai/data_core/core = isaicore(target_ai.loc) ? target_ai.loc : target_ai.last_used_data_core
	return core && (core in GLOB.data_cores["[our_turf.z]"])

///Called when our assigned AI is being deleted.
/obj/machinery/ai_core_display/proc/on_ai_deleting(datum/source)
	SIGNAL_HANDLER
	assign_ai(null)

///Called when an AI we're registered to changes their screen
/obj/machinery/ai_core_display/proc/on_ai_screen_change(datum/source)
	SIGNAL_HANDLER
	update_icon()
