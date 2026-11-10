// Znaczniki rozkazów: tędy, atak, obrona, odwrót, zbiórka, cel (laser). Stawia je dowódca drużyny
// (akcja + kliknięcie w widoczne pole albo klik na mapie w pagerze) i XO (mapa w konsoli).
// Widać je w świecie tylko członkom drużyny, a na mapie taktycznej w pagerze i w konsoli.
// Sprite'y: atak, obrona, odwrót i zbiórka z TGMC (icons/effects/orders.dmi), cel (gwiazdka) dorysowany w ich stylu,
// „Tędy” dorysowane ze strzałki zbiórki TGMC (CC BY-SA 3.0); ikony akcji z TGMC (icons/mob/actions.dmi).

/// Polska nazwa znacznika
/proc/squad_marker_pl(marker_type)
	switch(marker_type)
		if(SQUAD_MARKER_MOVE)
			return "Tędy"
		if(SQUAD_MARKER_ATTACK)
			return "Atak"
		if(SQUAD_MARKER_DEFEND)
			return "Obrona"
		if(SQUAD_MARKER_RETREAT)
			return "Odwrót"
		if(SQUAD_MARKER_RALLY)
			return "Zbiórka"
		if(SQUAD_MARKER_TARGET)
			return "Cel"
	return marker_type

/// Zdanie do komunikatu na ekranie
/proc/squad_marker_order_text(marker_type, area_name)
	switch(marker_type)
		if(SQUAD_MARKER_MOVE)
			return "Ruch: [area_name]."
		if(SQUAD_MARKER_ATTACK)
			return "Atakować: [area_name]!"
		if(SQUAD_MARKER_DEFEND)
			return "Bronić pozycji: [area_name]."
		if(SQUAD_MARKER_RETREAT)
			return "Odwrót do: [area_name]!"
		if(SQUAD_MARKER_RALLY)
			return "Zbiórka: [area_name]."
		if(SQUAD_MARKER_TARGET)
			return "Cel oznaczony: [area_name]."
	return area_name

/datum/aq_squad_marker
	var/marker_type
	var/datum/squad/squad
	var/turf/target_turf
	var/placer_name
	var/expires_at
	var/image/marker_image
	/// Klienci, którym dodano obrazek (żeby zdjąć go też po wylogowaniu czy przejściu w ducha)
	var/list/client/viewers = list()
	var/timer_id

/datum/aq_squad_marker/New(datum/squad/squad, marker_type, turf/target_turf, placer_name, arrow_dir)
	src.squad = squad
	src.marker_type = marker_type
	src.target_turf = target_turf
	src.placer_name = placer_name
	expires_at = world.time + SQUAD_MARKER_DURATION
	marker_image = image('aquila/icons/squads/markers.dmi', target_turf, "marker_[marker_type]", ABOVE_LIGHTING_LAYER)
	marker_image.plane = ABOVE_LIGHTING_PLANE
	marker_image.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	if(arrow_dir && marker_type == SQUAD_MARKER_MOVE)
		marker_image.dir = arrow_dir
	var/image/label = image(loc = target_turf)
	label.maptext = MAPTEXT("<span style='text-align:center;color:[squad.colour]'>[squad.name]: [squad_marker_pl(marker_type)]</span>")
	label.maptext_width = 96
	label.maptext_x = -32
	label.maptext_y = 30
	label.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	marker_image.overlays += label
	timer_id = addtimer(CALLBACK(src, PROC_REF(expire)), SQUAD_MARKER_DURATION, TIMER_STOPPABLE)

/datum/aq_squad_marker/Destroy()
	if(timer_id)
		deltimer(timer_id)
	for(var/client/viewer as anything in viewers)
		viewer?.images -= marker_image
	viewers.Cut()
	if(squad?.aq_markers?[marker_type] == src)
		squad.aq_markers -= marker_type
	squad = null
	target_turf = null
	marker_image = null
	return ..()

/datum/aq_squad_marker/proc/expire()
	timer_id = null
	qdel(src)

/datum/aq_squad_marker/proc/show_to(mob/viewer)
	var/client/viewer_client = viewer?.client
	if(!viewer_client)
		return
	// Login() czyści client.images, więc obrazek dokładamy od nowa także klientom już z listy (bez duplikatu)
	viewer_client.images -= marker_image
	viewer_client.images += marker_image
	viewers |= viewer_client

/datum/aq_squad_marker/proc/hide_from(mob/viewer)
	var/client/viewer_client = viewer?.client
	if(!viewer_client)
		return
	viewer_client.images -= marker_image
	viewers -= viewer_client

/datum/squad
	/// Aktywne znaczniki: typ -> /datum/aq_squad_marker (jeden na typ)
	var/list/aq_markers

/datum/squad/proc/aq_add_marker_images(mob/living/carbon/human/member)
	for(var/marker_type in aq_markers)
		var/datum/aq_squad_marker/marker = aq_markers[marker_type]
		marker.show_to(member)

/datum/squad/proc/aq_remove_marker_images(mob/living/carbon/human/member)
	for(var/marker_type in aq_markers)
		var/datum/aq_squad_marker/marker = aq_markers[marker_type]
		marker.hide_from(member)

/// Stawia znacznik (zastępuje poprzedni tego typu). Zwraca znacznik albo null.
/datum/squad/proc/aq_place_marker(mob/living/placer, turf/target_turf, marker_type, from_console = FALSE)
	if(!placer || !istype(target_turf) || !(marker_type in SQUAD_MARKER_TYPES))
		return null
	if(world.time < placer.aq_next_squad_marker)
		to_chat(placer, "<span class='warning'>Za szybko. Odczekaj chwilę przed kolejnym znacznikiem.</span>")
		return null
	placer.aq_next_squad_marker = world.time + SQUAD_MARKER_COOLDOWN
	var/turf/arrow_from = from_console ? get_turf(leader) : get_turf(placer)
	var/arrow_dir = (arrow_from && arrow_from.z == target_turf.z && arrow_from != target_turf) ? get_dir(arrow_from, target_turf) : null
	var/datum/aq_squad_marker/old_marker = aq_markers?[marker_type]
	if(old_marker)
		qdel(old_marker)
	var/datum/aq_squad_marker/marker = new(src, marker_type, target_turf, placer.real_name, arrow_dir)
	LAZYSET(aq_markers, marker_type, marker)
	for(var/mob/living/carbon/human/member as anything in members)
		marker.show_to(member)
	var/area/target_area = get_area(target_turf)
	var/area_name = target_area ? format_text(target_area.name) : "nieznany obszar"
	var/sector = aq_squad_sector(target_turf)
	if(sector)
		area_name = "[area_name] ([sector])"
	log_game("[key_name(placer)] placed a [marker_type] marker for squad [name] at [AREACOORD(target_turf)]")
	aq_squad_screen_alert(squad_marker_order_text(marker_type, area_name), "[squad_marker_pl(marker_type)] - [placer.real_name]", placer, 4 SECONDS)
	aq_log_message(placer.real_name, squad_marker_order_text(marker_type, area_name), "marker")
	return marker

/datum/squad/proc/aq_clear_marker(marker_type)
	var/datum/aq_squad_marker/marker = aq_markers?[marker_type]
	if(marker)
		qdel(marker)
		return TRUE
	return FALSE

// Akcja dowódcy: wybór znacznika z menu, potem kliknięcie w pole na ekranie
/datum/action/innate/aq_squad_marker
	name = "Znacznik taktyczny"
	desc = "Wybierz rozkaz (tędy, atak, obrona, odwrót, zbiórka, cel) i kliknij pole. Znacznik zobaczy cała drużyna, także na mapie w pagerze."
	icon_icon = 'aquila/icons/squads/actions.dmi'
	button_icon_state = "marker"
	/// Wybrany typ, gdy czekamy na kliknięcie
	var/pending_type

/datum/action/innate/aq_squad_marker/Trigger()
	var/datum/squad/squad = target
	var/mob/living/carbon/human/user = owner
	if(!istype(squad) || !istype(user) || user.stat != CONSCIOUS)
		return FALSE
	if(pending_type)
		aq_stop_targeting(user)
		to_chat(user, "<span class='notice'>Anulujesz stawianie znacznika.</span>")
		return TRUE
	if(squad.leader != user)
		return FALSE
	if(!user.aq_has_squad_pager())
		to_chat(user, "<span class='warning'>Potrzebujesz pagera drużyny, żeby stawiać znaczniki.</span>")
		return FALSE
	var/list/choices = list()
	var/list/choice_to_type = list()
	for(var/marker_type in SQUAD_MARKER_TYPES)
		var/label = squad_marker_pl(marker_type)
		choices[label] = image('aquila/icons/squads/markers.dmi', "marker_[marker_type]")
		choice_to_type[label] = marker_type
	var/picked = show_radial_menu(user, user, choices, tooltips = TRUE)
	if(!picked || QDELETED(src) || squad.leader != user)
		return FALSE
	pending_type = choice_to_type[picked]
	user.click_intercept = src
	to_chat(user, "<span class='notice'>Kliknij pole, na którym ma stanąć znacznik „[picked]”. Ponowne użycie akcji anuluje.</span>")
	return TRUE

/datum/action/innate/aq_squad_marker/proc/aq_stop_targeting(mob/living/user)
	pending_type = null
	if(user?.click_intercept == src)
		user.click_intercept = null

/datum/action/innate/aq_squad_marker/proc/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	var/datum/squad/squad = target
	if(!pending_type || !istype(squad) || squad.leader != clicker || clicker.stat != CONSCIOUS)
		aq_stop_targeting(clicker)
		return FALSE
	var/turf/target_turf = get_turf(click_target)
	if(!target_turf || !(target_turf in view(clicker.client?.view || world.view, clicker)))
		to_chat(clicker, "<span class='warning'>Możesz oznaczyć tylko pole, które widzisz.</span>")
		return TRUE
	var/marker_type = pending_type
	aq_stop_targeting(clicker)
	squad.aq_place_marker(clicker, target_turf, marker_type)
	return TRUE

/datum/action/innate/aq_squad_marker/Remove(mob/M)
	aq_stop_targeting(M)
	return ..()
