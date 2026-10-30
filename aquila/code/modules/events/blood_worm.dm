// AQUILA - event i midround krwawych robaków (port z tgstation#93787)

/// Wloty wentylacji na statku w dużych sieciach, żeby robak nie utknął np. w ochronie czy wirusologii
/proc/find_blood_worm_vent_spawns()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent) || !is_station_level(temp_vent.loc.z) || temp_vent.welded)
			continue
		var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
		if(!temp_vent_parent || length(temp_vent_parent.other_atmos_machines) <= 20)
			continue
		vents += temp_vent
	return vents

/// Tworzy larwę krwawego robaka przy wentylacji i daje ją graczowi
/proc/create_blood_worm(key, atom/spawn_loc, give_antag = TRUE)
	var/mob/living/simple_animal/hostile/blood_worm/hatchling/worm = new(get_turf(spawn_loc))
	var/datum/mind/player_mind = new /datum/mind(key)
	player_mind.active = TRUE
	player_mind.transfer_to(worm)
	player_mind.assigned_role = ROLE_BLOOD_WORM
	player_mind.special_role = ROLE_BLOOD_WORM
	if(give_antag)
		player_mind.add_antag_datum(/datum/antagonist/blood_worm/infestation)
	return worm

/proc/announce_blood_worms()
	priority_announce("Wykryto niezidentyfikowane formy życia wkraczające na pokład [station_name()]. Zabezpieczyć wszelkie drogi zewnętrznego dostępu, w tym kanały i wentylację.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event_control/blood_worm
	name = "Blood Worm Infestation"
	typepath = /datum/round_event/ghost_role/blood_worm
	max_occurrences = 1
	weight = 4
	min_players = 15
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/blood_worm
	minimum_required = 1
	role_name = "krwawy robak"
	fakeable = TRUE
	/// Robaki mają przybyć 7,5-12,5 minuty przed ogłoszeniem
	announceWhen = 225

/datum/round_event/ghost_role/blood_worm/setup()
	announceWhen = rand(225, 375)

/datum/round_event/ghost_role/blood_worm/announce(fake)
	announce_blood_worms()

/datum/round_event/ghost_role/blood_worm/spawn_role()
	var/list/vents = find_blood_worm_vent_spawns()
	if(!length(vents))
		message_admins("Event próbuje stworzyć krwawe robaki, ale nie ma odpowiednich wentylacji. Przerywam.")
		return MAP_ERROR
	var/list/candidates = get_candidates(ROLE_BLOOD_WORM, /datum/role_preference/midround_ghost/blood_worm, POLL_IGNORE_BLOOD_WORM)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS
	var/spawncount = rand(1, 2)
	while(spawncount > 0 && length(vents) && length(candidates))
		var/obj/vent = length(vents) >= 2 ? pick_n_take(vents) : vents[1]
		var/mob/dead/selected = pick_n_take(candidates)
		var/mob/living/simple_animal/hostile/blood_worm/worm = create_blood_worm(selected.key, vent)
		message_admins("[ADMIN_LOOKUPFLW(worm)] zostaje krwawym robakiem przez event.")
		log_game("[key_name(worm)] was spawned as a blood worm by an event.")
		spawned_mobs += worm
		spawncount--
	return SUCCESSFUL_SPAWN

/datum/dynamic_ruleset/midround/from_ghosts/blood_worms
	name = "Blood Worm Infestation"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/blood_worm/infestation
	role_preference = /datum/role_preference/midround_ghost/blood_worm
	enemy_roles = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
	)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 2
	required_applicants = 1
	weight = 2
	cost = 10
	minimum_players = 15
	repeatable = FALSE
	var/list/vents

/datum/dynamic_ruleset/midround/from_ghosts/blood_worms/execute()
	vents = find_blood_worm_vent_spawns()
	if(!length(vents))
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no valid vents.")
		return FALSE
	. = ..()
	if(.)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(announce_blood_worms)), rand(450, 750) SECONDS)

/// Antagonistę dodaje finish_setup()
/datum/dynamic_ruleset/midround/from_ghosts/blood_worms/generate_ruleset_body(mob/applicant)
	var/obj/vent = length(vents) >= 2 ? pick_n_take(vents) : vents[1]
	var/mob/living/simple_animal/hostile/blood_worm/worm = create_blood_worm(applicant.key, vent, give_antag = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(worm)] zostaje krwawym robakiem przez regułę midround.")
	log_game("DYNAMIC: [key_name(worm)] was spawned as a blood worm by the midround ruleset.")
	return worm

/// Robaki od startu: robak siedzi w żywym członku załogi i nim steruje.
/// Na starcie robaki mało robią, więc tg daje co najmniej jednego na 30 graczy.
/datum/dynamic_ruleset/roundstart/blood_worm
	name = "Blood Worms"
	role_preference = /datum/role_preference/antagonist/blood_worm
	antag_datum = /datum/antagonist/blood_worm
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_candidates = 1
	weight = 1
	cost = 15
	scaling_cost = 10
	requirements = list(101,101,101,101,40,30,20,15,10,10)
	antag_cap = list("denominator" = 29)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/blood_worm/pre_execute(population)
	. = ..()
	var/num_worms = get_antag_cap(population) * (scaled_times + 1)
	for(var/i in 1 to num_worms)
		if(!length(candidates))
			break
		var/mob/candidate = pick_n_take(candidates)
		assigned += candidate.mind
		candidate.mind.restricted_roles = restricted_roles
		candidate.mind.special_role = ROLE_BLOOD_WORM
	return TRUE

/datum/dynamic_ruleset/roundstart/blood_worm/execute()
	for(var/datum/mind/candidate as anything in assigned)
		var/mob/living/carbon/human/host = candidate.current
		// Rasy bez krwi nie nadają się na nosicieli
		if(!istype(host) || !host.get_blood_id() || (NOBLOOD in host.dna?.species?.species_traits))
			candidate.special_role = null
			continue
		var/mob/living/simple_animal/hostile/blood_worm/hatchling/worm = new(get_turf(host))
		candidate.transfer_to(worm)
		candidate.add_antag_datum(/datum/antagonist/blood_worm/infestation)
		worm.enter_host(host, silent = TRUE, gain_progress = FALSE)
	return TRUE

/datum/role_preference/midround_ghost/blood_worm
	name = "Krwawy robak"
	antag_datum = /datum/antagonist/blood_worm

/datum/role_preference/antagonist/blood_worm
	name = "Krwawy robak (od startu)"
	antag_datum = /datum/antagonist/blood_worm
