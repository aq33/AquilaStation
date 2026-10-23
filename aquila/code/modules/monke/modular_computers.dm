// Programy PDA z Monkestation (monkestation/code/modules/modular_computers).
// Lifeline: lista załogi z odległością, kierunkiem i obszarem (okno NtosLifeline) zamiast mapy radaru.
// Śledzenie wybranej osoby (strzałka na ikonie programu) zostaje z naszego radaru.

#define LIFELINE_UPDATE_PERIOD (3 SECONDS)

/datum/computer_file/program/radar/lifeline
	tgui_id = "NtosLifeline"
	/// Ostatnio zbudowana lista czujników
	var/list/sensors_cache
	var/last_sensor_update = 0

/datum/computer_file/program/radar/lifeline/ui_data(mob/user)
	return list(
		"selected" = selected,
		"sensors" = build_sensor_list(),
	)

/datum/computer_file/program/radar/lifeline/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "select")
		selected = params["ref"]
		return TRUE

/// Lista osób z czujnikami na pełnym śledzeniu, z odległością i kierunkiem od komputera
/datum/computer_file/program/radar/lifeline/proc/build_sensor_list()
	if(sensors_cache && world.time < last_sensor_update + LIFELINE_UPDATE_PERIOD)
		return sensors_cache
	last_sensor_update = world.time
	sensors_cache = list()
	var/turf/here = get_turf(computer)
	if(!here)
		return sensors_cache
	for(var/mob/living/carbon/human/humanoid in GLOB.carbon_list)
		if(!trackable(humanoid))
			continue
		var/turf/there = get_turf(humanoid)
		var/list/crewinfo = list(
			"ref" = REF(humanoid),
			"name" = "Nieznany",
			"assignment" = "Nieznana",
			"ijob" = 81, // UNKNOWN_JOB_ID z crew.dm
			"area" = get_area_name(humanoid, TRUE),
			"dist" = -1,
			"degrees" = 0,
			"zdiff" = 0,
		)
		if(there.z == here.z)
			crewinfo["dist"] = max(get_dist(here, there), 0)
			crewinfo["degrees"] = round(get_angle(here, there))
		var/obj/item/card/id/id_card = humanoid.wear_id?.GetID()
		if(id_card)
			crewinfo["name"] = id_card.registered_name || "Nieznany"
			crewinfo["assignment"] = id_card.assignment || "Nieznana"
			var/job_id = GLOB.crewmonitor.jobs[id_card.hud_state]
			if(!isnull(job_id))
				crewinfo["ijob"] = job_id
		sensors_cache += list(crewinfo)
	return sensors_cache

#undef LIFELINE_UPDATE_PERIOD

// Manifest załogi w PDA odświeża się, gdy ktoś dołączy w trakcie rundy
/datum/computer_file/program/crew_manifest/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(on_crewmember_joined))

/datum/computer_file/program/crew_manifest/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/datum/computer_file/program/crew_manifest/proc/on_crewmember_joined()
	SIGNAL_HANDLER
	// Okno NTOS należy do komputera, a dane statyczne programu doklejane są w jego ui_static_data()
	if(!computer || computer.active_program != src)
		return
	for(var/datum/tgui/ui in SStgui.open_uis_by_src[REF(computer)])
		computer.update_static_data(ui.user, ui)
