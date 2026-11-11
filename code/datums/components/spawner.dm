/datum/component/spawner
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_time = 300 //30 seconds default
	var/list/spawned_mobs = list()
	var/spawn_delay = 0
	var/max_mobs = 5
	var/spawn_text = "wyłania się z"
	var/list/faction = list("mining")



/datum/component/spawner/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_faction)
		faction=_faction
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(stop_spawning))
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()


/datum/component/spawner/proc/stop_spawning(force)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/simple_animal/L in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	spawned_mobs = null

/datum/component/spawner/proc/try_spawn_mob()
	var/atom/P = parent
	if(spawned_mobs.len >= max_mobs)
		return 0
	if(spawn_delay > world.time)
		return 0
	spawn_delay = world.time + spawn_time
	var/chosen_mob_type = pick(mob_types)
	// AQ EDIT START - basic moby: spawner tworzy też basic moby (agenci Syndykatu), które nie mają `nest`
	var/mob/living/L = new chosen_mob_type(P.loc)
	L.flags_1 |= (P.flags_1 & ADMIN_SPAWNED_1)
	spawned_mobs += L
	if(isanimal(L))
		var/mob/living/simple_animal/simple_mob = L
		simple_mob.nest = src
	else
		RegisterSignal(L, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(forget_spawned_mob))
	// AQ EDIT END
	L.faction = src.faction
	P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")

// AQ EDIT START - basic moby: martwy lub usunięty basic mob zwalnia miejsce jak simple animal przez `nest`
/datum/component/spawner/proc/forget_spawned_mob(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))
	if(spawned_mobs) // null after stop_spawning()
		spawned_mobs -= source
// AQ EDIT END
