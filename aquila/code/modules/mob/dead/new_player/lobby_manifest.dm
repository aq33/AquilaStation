// Port tgstation#98197: mglisty szacunek obsady w panelu statystyk lobby.
// Na podstawie preferencji prac gotowych graczy (wysoka/średnia/niska) pokazuje przedziały,
// ile osób może trafić na dane stanowisko, nie zdradzając, kto to jest.
// Zamiast podpinać się pod każdą zmianę gotowości i preferencji, liczymy co kilka sekund
// i trzymamy wynik w pamięci podręcznej, więc tick panelu tylko kopiuje gotową listę.

#define LOBBY_MANIFEST_REFRESH (5 SECONDS)

GLOBAL_DATUM_INIT(lobby_manifest, /datum/lobby_manifest, new)

/datum/lobby_manifest
	/// Gotowe wpisy panelu statystyk (tytuł => GENERATE_STAT_*)
	var/list/cached_entries
	/// Kiedy ostatnio liczyliśmy
	var/last_update = -INFINITY
	/// Ilu gotowych graczy wzięło udział w ostatnim liczeniu
	var/ready_count = 0

/// Gotowość albo preferencje prac się zmieniły, przy następnym odświeżeniu panelu liczymy od nowa
/datum/lobby_manifest/proc/invalidate()
	cached_entries = null

/// Zwraca wpisy do panelu, licząc je ponownie najwyżej co LOBBY_MANIFEST_REFRESH
/datum/lobby_manifest/proc/get_entries()
	if(!cached_entries || world.time >= last_update + LOBBY_MANIFEST_REFRESH)
		last_update = world.time
		cached_entries = build_entries()
	return cached_entries

/datum/lobby_manifest/proc/get_departments()
	var/static/list/departments
	if(departments)
		return departments
	departments = list(
		"Dowództwo" = GLOB.command_positions,
		"Ochrona" = GLOB.security_positions,
		"Amunicja" = GLOB.munitions_positions,
		"Inżynieria" = GLOB.engineering_positions,
		"Medyczny" = GLOB.medical_positions,
		"Nauka" = GLOB.science_positions,
		"Zaopatrzenie" = GLOB.supply_positions,
		"Cywile" = GLOB.civilian_positions,
		"Syntetyki" = GLOB.nonhuman_positions - JOB_NAME_PAI,
	)
	return departments

/// Sumuje preferencje gotowych graczy: wysoka = 1, średnia = 0.5, niska = 0.125
/datum/lobby_manifest/proc/score_jobs()
	var/list/job_to_score = list()
	ready_count = 0
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready != PLAYER_READY_TO_PLAY)
			continue
		var/datum/character_save/character = player.client?.prefs?.active_character
		if(!character)
			continue
		ready_count++
		var/list/prefs = character.job_preferences
		var/has_overflow = FALSE
		for(var/job_title in prefs)
			var/priority = prefs[job_title]
			if(job_title == SSjob.overflow_role)
				has_overflow = TRUE
			job_to_score[job_title] += (priority == JP_HIGH ? 1 : (priority == JP_MEDIUM ? 0.5 : 0.125))
		// Gracze, którzy bez pracy idą na asystenta, też trochę się liczą
		if(!has_overflow && character.joblessrole == BEOVERFLOW)
			job_to_score[SSjob.overflow_role] += 0.125
	return job_to_score

/datum/lobby_manifest/proc/build_entries()
	var/list/entries = list()
	entries["Możliwa obsada"] = GENERATE_STAT_TEXT("szacunek z preferencji gotowych graczy")

	var/list/job_to_score = score_jobs()
	var/player_count = length(GLOB.player_list)
	var/list/shown = list()
	var/anything = FALSE
	var/list/departments = get_departments()
	for(var/department in departments)
		var/list/rows = list()
		for(var/job_title in departments[department])
			if(shown[job_title])
				continue
			shown[job_title] = TRUE
			var/score = job_to_score[job_title]
			// Jedna czy dwie osoby z niskim priorytetem to szum, nie pokazujemy
			if(score < 0.5)
				continue
			var/datum/job/job = SSjob.GetJob(job_title)
			if(!job)
				continue
			var/is_overflow = (job_title == SSjob.overflow_role || job.spawn_positions < 0)
			var/slots = is_overflow ? CEILING(player_count * 0.15, 1) : job.spawn_positions
			if(slots <= 0)
				continue
			var/lower = clamp(FLOOR(score * 0.5, 1), 0, slots - 1)
			var/upper = clamp(CEILING(score, 1), 0, slots)
			if(upper <= 0)
				continue
			var/display = (lower == upper) ? "[upper] " : "[lower]–[upper] "
			for(var/i in 1 to slots)
				if(i <= lower)
					display += "◼"
				else if(i <= upper)
					display += "◩"
				else if(!is_overflow)
					display += "◻"
			if(is_overflow)
				display += "…"
			rows[job_title] = GENERATE_STAT_TEXT(display)
		if(!length(rows))
			continue
		anything = TRUE
		entries["[department]:"] = GENERATE_STAT_TEXT("")
		for(var/row in rows)
			entries[row] = rows[row]

	if(!ready_count)
		entries["Możliwa obsada"] = GENERATE_STAT_TEXT("nikt nie kliknął Gotowy")
	else if(!anything)
		entries["Możliwa obsada"] = GENERATE_STAT_TEXT("gotowi: [ready_count], brak pewnych obsad")
	else
		entries["Możliwa obsada"] = GENERATE_STAT_TEXT("gotowi: [ready_count]")
	return entries

/mob/dead/new_player/ui_act(action, list/params)
	. = ..()
	if(action == "ready")
		GLOB.lobby_manifest.invalidate()

/datum/preference_middleware/jobs/set_job_preference(list/params, mob/user)
	. = ..()
	GLOB.lobby_manifest.invalidate()

/datum/preference_middleware/jobs/clear_job_preferences(list/params, mob/user)
	. = ..()
	GLOB.lobby_manifest.invalidate()

/mob/dead/new_player/get_stat_tab_status()
	var/list/tab_data = ..()
	if(SSticker.HasRoundStarted())
		return tab_data
	var/list/entries = GLOB.lobby_manifest.get_entries()
	tab_data["lobby_manifest_divider"] = GENERATE_STAT_DIVIDER
	for(var/key in entries)
		tab_data[key] = entries[key]
	return tab_data

#undef LOBBY_MANIFEST_REFRESH
