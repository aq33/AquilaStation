/datum/round_event_control/carp_migration
	name = "Carp Migration"
	typepath = /datum/round_event/carp_migration
	weight = 10
	min_players = 2
	earliest_start = 10 MINUTES
	max_occurrences = 6

/datum/round_event_control/carp_migration/New()
	. = ..()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		return
	weight *= 3
	max_occurrences *= 2
	earliest_start *= 0.5

/datum/round_event/carp_migration
	announceWhen	= 3
	startWhen = 50
	var/hasAnnounced = FALSE

/datum/round_event/carp_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/carp_migration/announce(fake)
	priority_announce("Wykryto nieznane formy życia w okolicy [station_name()], zaleca się ostrożność.", "Ostrzeżenie biologiczne", SSstation.announcer.get_rand_alert_sound())


// AQ EDIT START - basic moby: basic carp, and from tgstation the migration through the ship (a turf in a station area, then out to space)
/datum/round_event/carp_migration/start()
	var/mob/living/basic/carp/fish
	/// z level to the turfs carp spawned on it swim through, so a school moves together
	var/list/z_migration_paths = list()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(95))
			fish = new /mob/living/basic/carp(C.loc)
		else
			fish = new /mob/living/basic/carp/mega(C.loc)

			fishannounce(fish) //Prefer to announce the megacarps over the regular fishies
		var/z_level_key = "[C.z]"
		if(isnull(z_migration_paths[z_level_key]))
			z_migration_paths[z_level_key] = pick_carp_migration_points(z_level_key)
		fish.migrate_to(z_migration_paths[z_level_key])
	fishannounce(fish)

/// Two places for carp to swim to: a turf of the ship (station areas of that z level), then the space beyond it
/datum/round_event/carp_migration/proc/pick_carp_migration_points(z_level_key)
	var/list/valid_areas = list()
	for(var/area/potential_area as anything in SSmapping.areas_in_z[z_level_key])
		if(!is_type_in_list(potential_area, GLOB.the_station_areas))
			continue
		valid_areas += potential_area
	if(!length(valid_areas))
		return list()
	var/list/station_turfs = get_safe_random_station_turfs(valid_areas)
	var/turf/station_turf = length(station_turfs) ? station_turfs[1] : null
	if(!station_turf)
		return list()
	var/turf/exit_turf = get_edge_target_turf(station_turf, pick(GLOB.alldirs))
	return list(station_turf, exit_turf)
// AQ EDIT END

/datum/round_event/carp_migration/proc/fishannounce(atom/fish)
	if (!hasAnnounced)
		announce_to_ghosts(fish) //Only anounce the first fish
		hasAnnounced = TRUE
