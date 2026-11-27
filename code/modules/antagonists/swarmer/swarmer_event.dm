/datum/round_event_control/spawn_swarmer
	name = "Spawn Swarmer Shell"
	typepath = /datum/round_event/spawn_swarmer
	weight = 7
	max_occurrences = 1 //Only once okay fam
	earliest_start = 30 MINUTES
	min_players = 15
	dynamic_should_hijack = TRUE


/datum/round_event/spawn_swarmer

/datum/round_event/spawn_swarmer/start()
	if(find_swarmer())
		return 0
	// AQ EDIT START - our ships have no gateway: the shell turns up in maintenance or cargo (aquila/code/modules/antagonists/swarmer/swarmer_event.dm)
	var/obj/effect/mob_spawn/swarmer/shell = spawn_shell()
	if(!shell)
		return 0
	if(prob(25)) //25% chance to announce it to the crew
		announce_shell(shell)
	// AQ EDIT END

/datum/round_event/spawn_swarmer/proc/find_swarmer()
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(istype(L, /mob/living/simple_animal/hostile/swarmer) && L.client) //If there is a swarmer with an active client, we've found our swarmer
			return 1
	return 0
