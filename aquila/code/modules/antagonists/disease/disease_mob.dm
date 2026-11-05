#define FREEMOVE_TIME 2 MINUTES

/*
A mob of type /mob/camera/disease is an overmind coordinating at least one instance of /datum/disease/advance/sentient_disease
that has infected a host. All instances in a host will be synchronized with the stats of the overmind's disease_template. Any
samples outside of a host will retain the stats they had when they left the host, but infecting a new host will cause
the new instance inside the host to be updated to the template's stats.
*/

/mob/camera/disease
	name = "Świadoma choroba"
	real_name = "Świadoma choroba"
	desc = ""
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = FALSE
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = BELOW_MOB_LAYER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_SELF|SEE_THRU
	initial_language_holder = /datum/language_holder/universal

	var/freemove = TRUE
	var/freemove_end = 0
	var/freemove_end_timerid

	var/datum/action/innate/disease_adapt/adaptation_menu_action

	var/mob/living/following_host
	var/list/disease_instances
	var/list/hosts //this list is associative, affected_mob -> disease_instance
	var/datum/disease/advance/sentient_disease/disease_template

	var/total_points = 0
	var/points = 0

	var/last_move_tick = 0
	var/move_delay = 1

	var/next_adaptation_time = 0
	var/adaptation_cooldown = 1200

	var/list/purchased_abilities
	var/list/unpurchased_abilities

/mob/camera/disease/Initialize(mapload)
	.= ..()

	disease_instances = list()
	hosts = list()

	purchased_abilities = list()
	unpurchased_abilities = list()

	disease_template = new /datum/disease/advance/sentient_disease()
	disease_template.overmind = src
	qdel(SSdisease.archive_diseases[disease_template.GetDiseaseID()])
	SSdisease.archive_diseases[disease_template.GetDiseaseID()] = disease_template //important for stuff that uses disease IDs

	var/datum/atom_hud/my_hud = GLOB.huds[DATA_HUD_SENTIENT_DISEASE]
	my_hud.add_hud_to(src)

	freemove_end = world.time + FREEMOVE_TIME
	freemove_end_timerid = addtimer(CALLBACK(src, .proc/infect_random_patient_zero), FREEMOVE_TIME, TIMER_STOPPABLE)

/mob/camera/disease/Destroy()
	. = ..()
	QDEL_NULL(adaptation_menu_action)
	disease_template = null
	for(var/V in GLOB.sentient_disease_instances)
		var/datum/disease/advance/sentient_disease/S = V
		if(S.overmind == src)
			S.overmind = null

/mob/camera/disease/Login()
	..()
	if(freemove)
		to_chat(src, "<span class='warning'>Masz [DisplayTimeText(freemove_end - world.time)] na wybór pierwszego nosiciela. Kliknij człowieka, żeby go wybrać.</span>")


/mob/camera/disease/get_stat_tab_status()
	var/list/tab_data = ..()
	if(freemove)
		tab_data["Czas na wybór nosiciela"] = GENERATE_STAT_TEXT("[round((freemove_end - world.time)/10)]s")
	else
		tab_data["Punkty adaptacji"] = GENERATE_STAT_TEXT("[points]/[total_points]")
		tab_data["Nosiciele"] = GENERATE_STAT_TEXT("[disease_instances.len]")
		var/adapt_ready = next_adaptation_time - world.time
		if(adapt_ready > 0)
			tab_data["Adaptacja gotowa za"] = GENERATE_STAT_TEXT("[round(adapt_ready/10, 0.1)]s")
	return tab_data

/mob/camera/disease/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += "<span class='notice'>[src] ma [points]/[total_points] punktów adaptacji.</span>\n"+\
		"<span class='notice'>[src] ma odblokowane:</span>"
		for(var/datum/disease_ability/ability in purchased_abilities)
			. += "<span class='notice'>[ability.name]</span>"

/mob/camera/disease/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	return

/mob/camera/disease/Move(NewLoc, Dir = 0)
	if(freemove)
		forceMove(NewLoc)
	else
		if(world.time > (last_move_tick + move_delay))
			follow_next(Dir & NORTHWEST)
			last_move_tick = world.time

/mob/camera/disease/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	var/atom/movable/to_follow = speaker
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker
		to_follow = V.source
	var/link
	if(to_follow in hosts)
		link = FOLLOW_LINK(src, to_follow)
	else
		link = ""
	// Recompose the message, because it's scrambled by default
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
	to_chat(src, "[link] [message]")


/mob/camera/disease/mind_initialize()
	. = ..()
	if(!mind.has_antag_datum(/datum/antagonist/disease))
		mind.add_antag_datum(/datum/antagonist/disease)
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/camera/disease/proc/pick_name()
	var/static/list/taken_names
	if(!taken_names)
		taken_names = list("Unknown" = TRUE)
		for(var/T in (subtypesof(/datum/disease) - /datum/disease/advance))
			var/datum/disease/D = T
			taken_names[initial(D.name)] = TRUE
	var/set_name
	while(!set_name)
		var/input = sanitize_name(stripped_input(src, "Wybierz nazwę swojej choroby", "Wybór nazwy", "", MAX_NAME_LEN))
		if(!input)
			set_name = "Świadomy wirus"
			break
		if(taken_names[input])
			to_chat(src, "<span class='notice'>Nie możesz użyć nazwy tak znanej choroby!</span>")
		else
			set_name = input
	real_name = "[set_name] (świadoma choroba)"
	name = "[set_name] (świadoma choroba)"
	disease_template.AssignName(set_name)
	var/datum/antagonist/disease/A = mind.has_antag_datum(/datum/antagonist/disease)
	if(A)
		A.disease_name = set_name

/mob/camera/disease/proc/infect_random_patient_zero(del_on_fail = TRUE)
	if(!freemove)
		return FALSE
	var/list/possible_hosts = list()
	var/list/afk_possible_hosts = list()
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		var/turf/T = get_turf(H)
		if((H.stat != DEAD) && T && is_station_level(T.z) && H.CanContractDisease(disease_template))
			if(H.client && !H.client.is_afk())
				possible_hosts += H
			else
				afk_possible_hosts += H

	shuffle_inplace(possible_hosts)
	shuffle_inplace(afk_possible_hosts)
	possible_hosts += afk_possible_hosts //ideally we want a not-afk person, but we will settle for an afk one if there are no others (mostly for testing)

	while(possible_hosts.len)
		var/mob/living/carbon/human/target = possible_hosts[1]
		if(force_infect(target))
			return TRUE
		possible_hosts.Cut(1, 2)

	if(del_on_fail)
		to_chat(src, "<span class='userdanger'>Nie było nosicieli, których twoja choroba mogłaby zarazić.</span>")
		qdel(src)
	return FALSE

/mob/camera/disease/proc/force_infect(mob/living/L)
	var/datum/disease/advance/sentient_disease/V = disease_template.Copy()
	var/result = L.ForceContractDisease(V, FALSE, TRUE)
	if(result && freemove)
		end_freemove()
	return result

/mob/camera/disease/proc/end_freemove()
	if(!freemove)
		return
	freemove = FALSE
	move_on_shuttle = TRUE
	adaptation_menu_action = new /datum/action/innate/disease_adapt()
	adaptation_menu_action.Grant(src)
	for(var/V in GLOB.disease_ability_singletons)
		unpurchased_abilities[V] = TRUE
		var/datum/disease_ability/A = V
		if(A.start_with && A.CanBuy(src))
			A.Buy(src, TRUE, FALSE)
	if(freemove_end_timerid)
		deltimer(freemove_end_timerid)
	sight = SEE_SELF

/mob/camera/disease/proc/add_infection(datum/disease/advance/sentient_disease/V)
	disease_instances += V
	hosts[V.affected_mob] = V
	total_points = max(total_points, disease_instances.len)
	points += 1

	var/image/holder = V.affected_mob.hud_list[SENTIENT_DISEASE_HUD]
	var/mutable_appearance/MA = new /mutable_appearance(holder)
	MA.icon_state = "virus_infected"
	MA.layer = BELOW_MOB_LAYER
	MA.color = COLOR_GREEN_GRAY
	MA.alpha = 200
	holder.appearance = MA
	var/datum/atom_hud/my_hud = GLOB.huds[DATA_HUD_SENTIENT_DISEASE]
	my_hud.add_to_hud(V.affected_mob)

	to_chat(src, "<span class='notice'>Zarażono nowego nosiciela: <b>[V.affected_mob.real_name]</b>.</span>")

	if(!following_host)
		set_following(V.affected_mob)
	refresh_adaptation_menu()

/mob/camera/disease/proc/remove_infection(datum/disease/advance/sentient_disease/V)
	if(QDELETED(src))
		disease_instances -= V
		hosts -= V.affected_mob
	else
		to_chat(src, "<span class='notice'>Jeden z twoich nosicieli, <b>[V.affected_mob.real_name]</b>, pozbył się twojej infekcji.</span>")

		var/datum/atom_hud/my_hud = GLOB.huds[DATA_HUD_SENTIENT_DISEASE]
		my_hud.remove_from_hud(V.affected_mob)

		if(following_host == V.affected_mob)
			follow_next()

		disease_instances -= V
		hosts -= V.affected_mob

		if(!disease_instances.len)
			to_chat(src, "<span class='userdanger'>Ostatnia cząstka twojej infekcji zniknęła.</span>")
			set_following(null)
			qdel(src)
		refresh_adaptation_menu()

/mob/camera/disease/proc/set_following(mob/living/L)
	if(following_host)
		UnregisterSignal(following_host, COMSIG_MOVABLE_MOVED)
	RegisterSignal(L, COMSIG_MOVABLE_MOVED, .proc/follow_mob)
	following_host = L
	follow_mob()

/mob/camera/disease/proc/follow_next(reverse = FALSE)
	var/index = hosts.Find(following_host)
	if(index)
		if(reverse)
			index = index == 1 ? hosts.len : index - 1
		else
			index = index == hosts.len ? 1 : index + 1
		set_following(hosts[index])

/mob/camera/disease/proc/follow_mob(datum/source, newloc, dir)
	SIGNAL_HANDLER

	var/turf/T = get_turf(following_host)
	if(T)
		forceMove(T)

/mob/camera/disease/DblClickOn(var/atom/A, params)
	if(hosts[A])
		set_following(A)
	else
		..()

/mob/camera/disease/ClickOn(var/atom/A, params)
	if(freemove && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(alert(src, "Wybrać [H.name] jako pierwszego nosiciela?", "Wybór nosiciela", "Tak", "Nie") != "Tak")
			return
		if(!freemove)
			return
		if(QDELETED(H) || !force_infect(H))
			to_chat(src, "<span class='warning'>[H ? H.name : "Nosiciela"] nie da się zarazić.</span>")
	else
		..()

/mob/camera/disease/proc/adapt_cooldown()
	to_chat(src, "<span class='notice'>Zmieniasz swoją strukturę genetyczną. Kolejna adaptacja będzie możliwa za [DisplayTimeText(adaptation_cooldown)].</span>")
	next_adaptation_time = world.time + adaptation_cooldown
	addtimer(CALLBACK(src, .proc/notify_adapt_ready), adaptation_cooldown)

/mob/camera/disease/proc/notify_adapt_ready()
	to_chat(src, "<span class='notice'>Możesz znów się adaptować.</span>")
	refresh_adaptation_menu()

/mob/camera/disease/proc/refresh_adaptation_menu()
	SStgui.update_uis(src)

/mob/camera/disease/proc/adaptation_menu()
	if(!disease_template)
		return
	ui_interact(src)

/mob/camera/disease/ui_state(mob/user)
	return GLOB.always_state

/mob/camera/disease/ui_status(mob/user, datum/ui_state/state)
	if(user != src)
		return UI_CLOSE
	return ..()

/mob/camera/disease/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SentientDiseaseMenu", "Menu adaptacji")
		ui.open()

/mob/camera/disease/ui_static_data(mob/user)
	var/list/data = list()
	var/list/abilities = list()
	for(var/datum/disease_ability/ability as anything in GLOB.disease_ability_singletons)
		abilities += list(list(
			"ref" = REF(ability),
			"name" = ability.name,
			"cost" = ability.cost,
			"required_total_points" = ability.required_total_points,
			"category" = ability.category,
			"short_desc" = ability.short_desc,
			"long_desc" = ability.long_desc,
			"stat_block" = ability.stat_block,
			"threshold_block" = ability.threshold_block,
		))
	data["abilities"] = abilities
	return data

/mob/camera/disease/ui_data(mob/user)
	var/list/data = list()
	var/datum/disease/advance/sentient_disease/DT = disease_template
	data["resistance"] = DT?.resistance
	data["stealth"] = DT?.stealth
	data["stage_rate"] = DT?.stage_rate
	data["transmission"] = DT?.transmission
	data["cure_text"] = DT?.cure_text
	data["points"] = points
	data["total_points"] = total_points
	var/list/ability_states = list()
	for(var/datum/disease_ability/ability as anything in GLOB.disease_ability_singletons)
		var/purchased = !unpurchased_abilities[ability]
		ability_states[REF(ability)] = list(
			"purchased" = purchased,
			"can_act" = purchased ? ability.CanRefund(src) : ability.CanBuy(src),
		)
	data["ability_states"] = ability_states
	var/list/host_list = list()
	for(var/mob/living/L as anything in hosts)
		host_list += list(list(
			"ref" = REF(L),
			"name" = L.real_name,
			"following" = (L == following_host),
		))
	data["hosts"] = host_list
	return data

/mob/camera/disease/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(usr != src)
		return
	switch(action)
		if("follow_instance")
			var/mob/living/L = locate(params["ref"]) in hosts
			if(L)
				set_following(L)
			return TRUE
		if("buy_ability")
			var/datum/disease_ability/A = locate(params["ref"]) in unpurchased_abilities
			if(!istype(A))
				return
			if(A.CanBuy(src))
				A.Buy(src)
			return TRUE
		if("refund_ability")
			var/datum/disease_ability/A = locate(params["ref"]) in purchased_abilities
			if(!istype(A))
				return
			if(A.CanRefund(src))
				A.Refund(src)
			return TRUE


/datum/action/innate/disease_adapt
	name = "Menu adaptacji"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "disease_menu"

/datum/action/innate/disease_adapt/Activate()
	var/mob/camera/disease/D = owner
	D.adaptation_menu()

#undef FREEMOVE_TIME
