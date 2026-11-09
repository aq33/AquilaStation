/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 1
	weight = 10
	can_malf_fake_alert = TRUE

/datum/round_event/radiation_storm
	/// Pętle syreny dla fałszywego alarmu: obszar -> typ pętli (Bee#13796)
	var/list/playlist = list()

/datum/round_event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen	= 1

/datum/round_event/radiation_storm/announce(fake)
	priority_announce("Wysokie poziomy radiacji wykryte w pobliżu stacji. Prosimy udać się do tuneli serwisowych.", "Alarm: Anomalia", ANNOUNCER_RADIATION)

	// AQ EDIT START - Bee#13796: prawdziwy alarm obsługuje pogoda, fałszywy sam włącza wyświetlacze i syrenę
	if(!fake)
		return ..()

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(frequency)
		var/datum/signal/signal = new
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
		var/atom/movable/virtualspeaker/virt = new(null)
		frequency.post_signal(virt, signal)

	var/list/eligible_areas = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to length(eligible_areas))
		var/area/place = eligible_areas[i]
		if(istype(place, /area/maintenance))
			playlist[place] = /datum/looping_sound/rad_alert_inside
		else
			playlist[place] = /datum/looping_sound/rad_alert_outside
		CHECK_TICK

	GLOB.rad_storm_sounds += playlist
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(/datum/weather/rad_storm))
	addtimer(CALLBACK(src, PROC_REF(cleanup_fake_alert)), 40 SECONDS)
	return ..()

/// Sprząta syrenę i wyświetlacze po fałszywym alarmie
/datum/round_event/radiation_storm/proc/cleanup_fake_alert()
	GLOB.rad_storm_sounds -= playlist
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(/datum/weather/rad_storm))

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(frequency)
		var/datum/signal/signal = new
		signal.data["command"] = "shuttle"
		var/atom/movable/virtualspeaker/virt = new(null)
		frequency.post_signal(virt, signal)
	// AQ EDIT END

/datum/round_event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
