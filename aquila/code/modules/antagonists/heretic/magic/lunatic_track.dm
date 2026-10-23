/datum/action/cooldown/lunatic_track
	name = "Moonlight Echo"
	desc = "Wskazuje, gdzie jest twój przewodnik."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_smile"
	cooldown_time = 4 SECONDS

/datum/action/cooldown/lunatic_track/Grant(mob/granted)
	if(!IS_LUNATIC(granted))
		return
	return ..()

// AQUILA - nasze /datum/action/cooldown nie ma Activate(); logika w Trigger()
/datum/action/cooldown/lunatic_track/Trigger()
	if(!..())
		return FALSE
	if(owner.stat != CONSCIOUS)
		return FALSE
	var/datum/antagonist/lunatic/lunatic_datum = IS_LUNATIC(owner)
	if(!lunatic_datum)
		return FALSE
	var/mob/living/carbon/human/ascended_heretic = lunatic_datum.ascended_body
	if(!(ascended_heretic))
		owner.balloon_alert(owner, "okrutny los, twojego mistrza już nie ma...")
		next_use_time = world.time + 1 SECONDS
		return FALSE
	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	owner.balloon_alert(owner, get_balloon_message(ascended_heretic))

	if(ascended_heretic.stat == DEAD)
		to_chat(owner, span_mansus("[ascended_heretic] nie żyje. Płacz, bo kłamstwo zadało cios."))

	StartCooldown()
	return TRUE


/// Gets the balloon message for the heretic we are tracking.
/datum/action/cooldown/lunatic_track/proc/get_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = generate_balloon_message(tracked_mob)
	if(tracked_mob.stat == DEAD)
		balloon_message = "nie żyje, " + balloon_message

	return balloon_message

/// Create the text for the balloon message
/datum/action/cooldown/lunatic_track/proc/generate_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = "błąd!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	var/dist = get_dist(our_turf, their_turf)
	// AQUILA - kierunki po polsku
	var/static/list/polish_dirs = list(
		"[NORTH]" = "na północ",
		"[SOUTH]" = "na południe",
		"[EAST]" = "na wschód",
		"[WEST]" = "na zachód",
		"[NORTHEAST]" = "na północny wschód",
		"[NORTHWEST]" = "na północny zachód",
		"[SOUTHEAST]" = "na południowy wschód",
		"[SOUTHWEST]" = "na południowy zachód",
	)
	var/dir_text = polish_dirs["[get_dir(our_turf, their_turf)]"] || "tutaj"

	switch(dist)
		if(0 to 15)
			balloon_message = "bardzo blisko, [dir_text]!"
		if(16 to 31)
			balloon_message = "blisko, [dir_text]!"
		if(32 to 127)
			balloon_message = "daleko, [dir_text]!"
		else
			balloon_message = "bardzo daleko!"

	// Early returns here if we don't need to tell them the z-levels
	if(our_z == their_z)
		return balloon_message

	if(is_mining_level(their_z))
		balloon_message = "w strefie górniczej!"
		return balloon_message

	// AQUILA - u nas nie ma poziomów „secret”
	if(is_away_level(their_z))
		balloon_message = "za bramą!"
		return balloon_message

	// We already checked if they are on lavaland or gateway, so if they arent there or on the station we can early return
	if(!is_station_level(their_z))
		balloon_message = "na innym planie!"
		return balloon_message

	// They must be on station because we have checked every other z-level, and since we arent on station we should go there
	if(!is_station_level(our_z))
		balloon_message = "na stacji!"
		return balloon_message

	if(our_z > their_z)
		balloon_message = "pod tobą!"
		return balloon_message

	if(our_z < their_z)
		balloon_message = "nad tobą!"
		return balloon_message

	return balloon_message
