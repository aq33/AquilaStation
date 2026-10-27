GLOBAL_DATUM_INIT(eclipse, /datum/eclipse_manager, new)

/datum/eclipse_manager
	var/eclipse_start_time = 0
	var/eclipse_end_time = 0
	var/eclipse_duration = 0
	var/eclipse_problem_announcement //set on eclipse_start()

	//light dimming
	var/light_reduction = 0.5

	var/timestopped	//sigh

	var/delay_first_announcement = 10 SECONDS	//time after the eclipse starts before it gets announced
	var/delay_end_announcement = 5 SECONDS		//time after the eclipse end before an announcement confirms it has ended
	var/delay_problem_announcement = 3 MINUTES	//how long after the eclipse's supposed end will the crew be warned (in case the cult is extending the eclipse's duration)

	var/problem_announcement = FALSE
	var/eclipse_finished = FALSE

/proc/eclipse_trigger_cult()
	if (!GLOB.eclipse)
		return
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult)
		return
	if (GLOB.eclipse.eclipse_start_time)//only one eclipse per round
		return
	GLOB.eclipse.eclipse_start(cult.eclipse_window)

/proc/eclipse_trigger_random()
	if (!GLOB.eclipse || GLOB.eclipse.eclipse_start_time)
		return
	GLOB.eclipse.eclipse_start(rand(12 MINUTES, 20 MINUTES))

/datum/eclipse_manager/proc/eclipse_start(duration)
	eclipse_start_time = world.time
	eclipse_duration = duration
	eclipse_end_time = eclipse_start_time + eclipse_duration
	eclipse_problem_announcement = eclipse_end_time + delay_problem_announcement
	SSshuttle.registerHostileEnvironment(src)
	INVOKE_ASYNC(SShell_universe, TYPE_PROC_REF(/datum/controller/subsystem/hell_universe, start_hell))

	START_PROCESSING(SSobj, src)

	for (var/mob/M in GLOB.player_list)
		M.playsound_local(get_turf(M), 'aquila/sound/bloodcult/vg/effects/wind/wind_5_1.ogg', 100, 0)

	addtimer(CALLBACK(src, PROC_REF(announce_start)), delay_first_announcement)

/datum/eclipse_manager/proc/announce_start()
	priority_announce("Jakiś księżyc przesuwa się przed waszą gwiazdą i zasłania jej światło. Spadła nie tylko produkcja energii słonecznej - wykryto też anomalne zaburzenia pola elektromagnetycznego, przez które światło na czas zaćmienia nie sięga tak daleko jak zwykle.", "Alarm: zaćmienie gwiazdy")

/datum/eclipse_manager/process()
	if (world.time < eclipse_end_time)
		return

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult || (!cult.tear_ritual && !cult.bloodstone))
		eclipse_end()
	else if (!cult.overtime_announcement)
		cult.overtime_announcement = TRUE
		cult.message_members(span_cult("Zaćmienie wchodzi w dogrywkę. Choć jego czas minął, Nar'Sie nie pozwoli mu się skończyć, dopóki działa runa Rozdarcia Rzeczywistości albo stoi Krwawy Kamień."))
	else if (!problem_announcement && (world.time >= eclipse_problem_announcement))
		problem_announcement = TRUE
		if (cult.stage == BLOODCULT_STAGE_READY)//no point warning the crew if the cult has already made itself known
			priority_announce("Zaćmienie trwa dłużej, niż przewidywano. Wygląda na to, że księżyc zmienił trajektorię, i nie wiadomo, jak długo potrwa ta anomalia. Centrala zaleca załodze przeszukanie statku pod kątem działalności okultystycznej, która może być źródłem zjawiska. Znalezione runy okultystyczne należy zetrzeć solą, a jeszcze lepiej - solą święconą.", "Zaćmienie pochodzenia okultystycznego?")

/datum/eclipse_manager/proc/eclipse_end()
	STOP_PROCESSING(SSobj, src)
	if (eclipse_finished)
		return
	eclipse_finished = TRUE
	SSshuttle.clearHostileEnvironment(src)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult?.stage == BLOODCULT_STAGE_NARSIE)//hell stays
		return

	INVOKE_ASYNC(SShell_universe, TYPE_PROC_REF(/datum/controller/subsystem/hell_universe, stop_hell))
	addtimer(CALLBACK(src, PROC_REF(announce_end)), delay_end_announcement)

/datum/eclipse_manager/proc/announce_end()
	priority_announce("Księżyc całkowicie odsłonił gwiazdę. Anomalne zachowanie pola elektromagnetycznego ustało.", "Koniec zaćmienia")
