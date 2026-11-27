// AQUILA - Skażone pomieszczenie: w pustym pomieszczeniu okrętu pojawiają się plamy krwi i wymiocin zarażające przeziębieniem albo grypą (port z CHOMPStation2 modular_chomp/code/modules/event/infectedroom.dm)
// As in CHOMP: up to 10 tries to find an unoccupied ship area (crew quarters, medbay, maintenance, holodeck, engine
// rooms, construction and shuttles excluded), 5-10 contaminated decals on its free floors and a level 7 biohazard
// warning naming the area 1-5 minutes later (CHOMP waits up to 50 minutes). CHOMP uses the virus of its outbreak event
// and also spawns macrophage mobs; we have neither, so the decals carry a mild, curable disease (common cold or flu,
// both cured with spaceacillin) through the infective component and there are only blood and vomit stains. Cleaning
// a stain removes the infection.

/datum/round_event_control/aquila_hex_disease_outbreak_floor
	name = "Skażone pomieszczenie"
	typepath = /datum/round_event/aquila_hex_disease_outbreak_floor
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_disease_outbreak_floor
	fakeable = FALSE
	startWhen = 1
	/// Contaminated area
	var/area/target_area
	/// The disease the stains carry
	var/datum/disease/chosen_disease
	/// How many stains were left
	var/stains = 0

/datum/round_event/aquila_hex_disease_outbreak_floor/setup()
	announceWhen = rand(30, 150)
	endWhen = announceWhen
	var/disease_type = pick(/datum/disease/cold, /datum/disease/flu)
	chosen_disease = new disease_type()

/datum/round_event/aquila_hex_disease_outbreak_floor/Destroy()
	chosen_disease = null // the stains keep their own reference
	return ..()

/datum/round_event/aquila_hex_disease_outbreak_floor/start()
	var/static/list/excluded_areas = typecacheof(list(
		/area/shuttle,
		/area/crew_quarters,
		/area/holodeck,
		/area/construction,
		/area/engine,
		/area/maintenance,
		/area/medical,
		/area/science/test_area,
		/area/solar,
	))
	var/list/area_types = GLOB.the_station_areas.Copy()
	var/list/target_turfs
	for(var/i in 1 to 10)
		if(!length(area_types))
			break
		var/area_type = pick_n_take(area_types)
		if(excluded_areas[area_type])
			continue
		var/area/candidate = GLOB.areas_by_type[area_type]
		if(!candidate || aquila_hex_area_occupied(candidate))
			continue
		var/list/turfs = list()
		for(var/turf/open/floor/floor in get_area_turfs(area_type))
			if(is_station_level(floor.z) && !is_blocked_turf(floor))
				turfs += floor
		if(!length(turfs))
			continue
		target_area = candidate
		target_turfs = turfs
		break
	if(!target_area)
		log_game("Infected Room: no unoccupied ship area with free floors, cancelling the event.")
		return kill()
	contaminate(target_turfs, rand(5, 10))
	log_game("Infected Room: [stains] stain(s) with [chosen_disease.name] in [target_area].")
	message_admins("Skażone pomieszczenie: [stains] plam z chorobą [chosen_disease.name] w [target_area.name].")

/// Leaves up to count infective stains on the turfs. Returns the stains
/datum/round_event/aquila_hex_disease_outbreak_floor/proc/contaminate(list/turfs, count)
	. = list()
	turfs = turfs.Copy()
	for(var/i in 1 to count)
		if(!length(turfs))
			break
		var/turf/stain_turf = pick_n_take(turfs)
		var/stain_type = prob(40) ? /obj/effect/decal/cleanable/blood : /obj/effect/decal/cleanable/vomit
		var/obj/effect/decal/cleanable/stain = new stain_type(stain_turf)
		if(QDELETED(stain)) // merged into a stain already there
			stain = locate(stain_type) in stain_turf
			if(!stain)
				continue
		stain.AddComponent(/datum/component/infective, list(chosen_disease))
		. += stain
		stains++

/datum/round_event/aquila_hex_disease_outbreak_floor/announce(fake)
	if(!target_area && !fake)
		return
	var/area_name = target_area ? target_area.name : get_area_name(GLOB.areas_by_type[pick(GLOB.the_station_areas)])
	priority_announce("Potwierdzono zagrożenie biologiczne 7. stopnia na pokładzie okrętu. Źródło skażenia: [area_name]. Cała załoga ma opanować ognisko choroby.", "Skażenie biologiczne: [area_name]", ANNOUNCER_OUTBREAK7)
