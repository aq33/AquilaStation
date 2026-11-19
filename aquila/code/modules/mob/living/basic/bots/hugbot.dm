// Przytulobot (hugbot) z NSV13 na basic bocie. Dziedziczy po medibocie przewracanie i tryb stacjonarny,
// zamiast leczenia przytula, głaszcze albo pstryka w nos smutnych członków załogi.

/mob/living/basic/bot/medbot/hugbot
	name = "\improper przytulobot"
	desc = "Mały, milutki robot. Wygląda na podekscytowanego."
	icon = 'nsv13/icons/mob/aibots.dmi'
	icon_state = "hugbot1"
	model = "Hugbot"
	bot_type = NONE
	hackables = "czujniki nacisku manipulatorów"
	work_mode = BBOT_WORKING
	zone_selected = BODY_ZONE_CHEST
	possessed_message = "Jesteś przytulobotem! Przytulaj smutnych członków załogi."
	emagged_message = "Jesteś zepsutym przytulobotem! Przytulaj tak, żeby bolało."
	healthanalyzer = null
	firstaid = null
	robot_arm = /obj/item/bodypart/r_arm/robot
	/// Od jakiej poczytalności nie przytula
	var/max_sanity = 70
	/// Różowy przewód: przytula wszystkich, bez względu na nastrój
	var/tania_mode = FALSE

/mob/living/basic/bot/medbot/hugbot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "hugbot0"
	else if(IsStun())
		icon_state = "hugbota"
	else if(mode == BBOT_WORKING)
		icon_state = "hugbots[stationary_mode + 1]"
	else
		icon_state = "hugbot[stationary_mode + 1]"

/mob/living/basic/bot/medbot/hugbot/is_valid_work_target(atom/target)
	return ishuman(target) && assess_patient(target)

/mob/living/basic/bot/medbot/hugbot/assess_patient(mob/living/carbon/human/sad)
	if(!istype(sad) || sad.stat == DEAD || HAS_TRAIT(sad, TRAIT_FAKEDEATH) || !isturf(sad.loc))
		return FALSE
	if(is_emagged() || tania_mode)
		return TRUE
	var/datum/component/mood/mood = sad.GetComponent(/datum/component/mood)
	if(!mood)
		return FALSE
	for(var/event_key in mood.mood_events)
		var/datum/mood_event/event = mood.mood_events[event_key]
		if(istype(event, /datum/mood_event/hug) || istype(event, /datum/mood_event/headpat))
			return FALSE
	if(mood.sanity_level > max_sanity)
		return FALSE
	return !sad.IsKnockdown()

/mob/living/basic/bot/medbot/hugbot/on_work_target_found(atom/target)
	set_patient(target)

/mob/living/basic/bot/medbot/hugbot/idle_chatter()
	return

/mob/living/basic/bot/medbot/hugbot/work_on_target(atom/target)
	var/mob/living/carbon/human/sad = target
	if(!istype(sad) || !assess_patient(sad))
		set_patient(null)
		return BOT_WORK_DONE
	if(get_dist(src, sad) > 1)
		return BOT_WORK_OUT_OF_REACH
	if(!shut_up)
		speak(pick(is_emagged() ? list("Nienawidzę cię.", "Nigdy nie będziesz dobry w swojej pracy.", "Jesteś okropną osobą.", "Poddaj się.", "Wszyscy cię nienawidzimy.", "Okropnie wykonujesz swoją pracę.", "Jesteś ciężarem dla okrętu.", "Spadaj.") \
			: list("Dziękuję!", "Jesteś dobrym człowiekiem.", "Kocham cię.", "Rób dalej to, w czym jesteś dobry.", "Jesteś wspaniałą osobą.", "Rób dalej to, co kochasz.", "Wszyscy cię kochamy.", "Świetnie wykonujesz swoją pracę.", "Jesteś dla nas wszystkich ważny.", "Tak trzymaj.", "Co się stało? Jestem przy tobie.", "Nie płacz.", "Uważaj na siebie!")))
	hug(sad)
	if(tania_mode || is_emagged())
		return BOT_WORK_CONTINUE
	set_patient(null)
	return BOT_WORK_DONE

/mob/living/basic/bot/medbot/hugbot/proc/hug(mob/living/carbon/human/sad)
	if(zone_selected == BODY_ZONE_PRECISE_MOUTH)
		visible_message(span_notice("[src] pstryka [sad] w nos."))
		playsound(sad, 'sound/weapons/tap.ogg', 50, FALSE)
		SEND_SIGNAL(sad, COMSIG_ADD_MOOD_EVENT, "headpat", /datum/mood_event/headpat)
	else if(check_zone(zone_selected) == BODY_ZONE_HEAD)
		visible_message(span_notice("[src] klepie [sad] po głowie, żeby poczuł się lepiej!"))
		SEND_SIGNAL(sad, COMSIG_ADD_MOOD_EVENT, "headpat", /datum/mood_event/headpat)
		var/obj/item/organ/tail/tail = sad.getorganslot(ORGAN_SLOT_TAIL)
		tail?.toggle_wag(sad)
	else
		visible_message(span_notice("[src] przytula [sad], żeby poczuł się lepiej!"))
		SEND_SIGNAL(sad, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/hug)
	playsound(sad.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	if(is_emagged())
		sad.adjustStaminaLoss(50)
		return
	sad.AdjustStun(-60)
	sad.AdjustKnockdown(-60)
	sad.AdjustUnconscious(-60)
	sad.AdjustSleeping(-100)
	sad.adjustStaminaLoss(-15)

/mob/living/basic/bot/medbot/hugbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_notice("Zwierasz czujniki nacisku manipulatorów [src]."))
	visible_message(span_danger("Ramię [src] gwałtownie drga!"))
	flick("medibot_spark", src)
	playsound(src, "sparks", 75, TRUE)

/mob/living/basic/bot/medbot/hugbot/explode()
	var/atom/drop_spot = drop_location()
	visible_message(span_boldnotice("[src] rozpada się na kawałki!"))
	do_sparks(3, TRUE, src)
	new /obj/item/storage/box/hug(drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	if(robot_arm)
		drop_part(robot_arm, drop_spot)

/mob/living/basic/bot/medbot/hugbot/get_custom_controls(mob/user)
	var/hug_mode = "hug"
	switch(zone_selected)
		if(BODY_ZONE_HEAD)
			hug_mode = "pat"
		if(BODY_ZONE_PRECISE_MOUTH)
			hug_mode = "boop"
	. = list(
		"max_sanity" = max_sanity,
		"hug_mode" = hug_mode,
		"speaker" = !shut_up,
		"stationary_mode" = stationary_mode,
	)
	if((bot_access_flags & BOT_COVER_MAINTS_OPEN) || IsAdminGhost(user))
		.["pink_wire"] = tania_mode

/mob/living/basic/bot/medbot/hugbot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("max_sanity")
			var/new_sanity = text2num(params["value"])
			if(!isnum(new_sanity))
				return FALSE
			max_sanity = clamp(round(new_sanity), SANITY_CRAZY, SANITY_GREAT)
		if("hug_mode")
			switch(zone_selected)
				if(BODY_ZONE_CHEST)
					zone_selected = BODY_ZONE_HEAD
				if(BODY_ZONE_HEAD)
					zone_selected = BODY_ZONE_PRECISE_MOUTH
				else
					zone_selected = BODY_ZONE_CHEST
		if("speaker")
			shut_up = !shut_up
		if("pink_wire")
			if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN) && !IsAdminGhost(user))
				return FALSE
			tania_mode = !tania_mode
		if("stationary_mode")
			stationary_mode = !stationary_mode
			update_appearance()
		else
			return FALSE
	return TRUE
