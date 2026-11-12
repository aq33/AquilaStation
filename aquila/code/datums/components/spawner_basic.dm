// AQUILA - basic mobs from mob spawners (skeleton pit and the like): simple animals drop out of `spawned_mobs` through
// their `nest` var on death, basic mobs have none, so the spawner listens for their death and deletion (as tg does)

/datum/component/spawner/proc/on_basic_spawned_gone(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))
	if(spawned_mobs)
		spawned_mobs -= source
