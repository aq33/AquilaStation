//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "burza radiacyjna"
	desc = "Przez okolicę przechodzi chmura silnego promieniowania, która napromieniowuje każdego bez ochrony."

	telegraph_duration = 400
	telegraph_message = null

	weather_message = "<span class='userdanger'><i>Czujesz fale gorąca spływające po tobie! Znajdź schronienie!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"

	end_duration = 100
	end_message = "<span class='notice'>Powietrze zdaje się znów ochładzać.</span>"

	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle, /area/security/prison/asteroid/shielded,
	/area/security/prison/asteroid/service, /area/space/nearstation, /area/solar, /area/security/prison, /area/holodeck/prison)
	target_trait = ZTRAIT_STATION

	immunity_type = "rad"

	/// Obszar -> pętla syreny na czas tej burzy (Bee#13796)
	var/list/playlist = list()

// AQ EDIT START - burza radiacyjna z Bee#13796: syrena w obszarach, napromieniowanie 1-5% zamiast mieszania DNA
/datum/weather/rad_storm/telegraph()
	status_alarm(TRUE)

	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(istype(place, /area/maintenance))
			playlist[place] = /datum/looping_sound/rad_alert_inside
		else
			playlist[place] = /datum/looping_sound/rad_alert_outside
		CHECK_TICK

	GLOB.rad_storm_sounds += playlist
	return ..()

/datum/weather/rad_storm/weather_act(mob/living/L)
	if(!ishuman(L))
		return

	var/mob/living/carbon/human/H = L
	if(HAS_TRAIT(H, TRAIT_RADIMMUNE))
		return

	if(SSradiation.wearing_rad_protected_clothing(H))
		return

	// Bee#14487: ciała w kostnicy i krematorium są osłonięte
	for(var/atom/container = H.loc; container && !isturf(container); container = container.loc)
		if(istype(container, /obj/structure/bodycontainer))
			return

	if( HAS_TRAIT( H, TRAIT_IPCRADBRAINDAMAGE ) && prob(20) ) // NSV13 IPCs will gain brain damage instead of mutations when exposed to radiation
		var/trauma_type = pickweight( list(
			BRAIN_TRAUMA_MILD = 65,
			BRAIN_TRAUMA_SEVERE = 30,
			BRAIN_TRAUMA_SPECIAL = 5
		) )
		var/resistance = pick(
			95;TRAUMA_RESILIENCE_BASIC,
			// 30;TRAUMA_RESILIENCE_SURGERY,
			// 15;TRAUMA_RESILIENCE_LOBOTOMY,
			5;TRAUMA_RESILIENCE_MAGIC
		)
		H.gain_trauma_type( trauma_type, resistance )

		var/emote_type = pickweight( list(
			"beep" = 34,
			"buzz" = 34,
			"buzz2" = 34,
		) )
		H.emote( emote_type )

	SSradiation.irradiate(H, intensity = rand(1, 5))

/datum/weather/rad_storm/end()
	GLOB.rad_storm_sounds -= playlist
	if(..())
		return
	priority_announce("Zagrożenie promieniotwórcze minęło. Proszę powrócić na stanowiska pracy.", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
	status_alarm(FALSE)
// AQ EDIT END

/datum/weather/rad_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	if (active)
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
	else
		signal.data["command"] = "shuttle"

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)
