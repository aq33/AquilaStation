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
			z_migration_paths[z_level_key] = pick_carp_migration_points(C.z) // aquila/.../carp/carp.dm
		fish.migrate_to(z_migration_paths[z_level_key])
	fishannounce(fish)
// AQ EDIT END

/datum/round_event/carp_migration/proc/fishannounce(atom/fish)
	if (!hasAnnounced)
		announce_to_ghosts(fish) //Only anounce the first fish
		hasAnnounced = TRUE
