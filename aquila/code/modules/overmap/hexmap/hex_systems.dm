// AQUILA - powiązanie układów z hexami i puste układy kafli

/datum/star_system
	/// Hex mapy strategicznej, na którym leży układ
	var/datum/hex/hex

/**
 * Układ pustego kafla: powstaje, gdy ktoś skacze na pusty hex, i znika, gdy nikogo w nim nie ma i nic w nim nie zostało.
 * Podtyp /random, więc save() go pomija, a losowania układów (misje, spawny flot) go nie widzą, bo jest ukryty.
 */
/datum/star_system/random/hex_empty
	name = "Pusty kafel"
	desc = null // bez komunikatu „Wchodzimy do…” przy każdym pustym kaflu
	alignment = "uncharted"
	owner = "uncharted"
	hidden = TRUE
	visitable = FALSE
	system_traits = STARSYSTEM_NO_ANOMALIES | STARSYSTEM_NO_ASTEROIDS | STARSYSTEM_NO_WORMHOLE

/datum/star_system/random/hex_empty/remove_ship(obj/structure/overmap/OM, turf/new_location, is_ftl_jump = TRUE)
	. = ..()
	if(!occupying_z)
		addtimer(CALLBACK(src, PROC_REF(try_release)), HEX_EMPTY_CLEANUP_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Oddaje układ, jeśli w kaflu nikogo nie ma i nic nie zostało (wraki, kapsuły zostają razem z układem)
/datum/star_system/random/hex_empty/proc/try_release()
	if(occupying_z || length(system_contents) || length(fleets) || length(enemy_queue))
		return FALSE
	for(var/obj/structure/overmap/OM as anything in SSstar_system.ships)
		var/list/info = SSstar_system.ships[OM]
		if(info["current_system"] == src || info["target_system"] == src)
			return FALSE
	if(hex?.system == src)
		hex.system = null
	hex = null
	SSstar_system.systems -= src
	qdel(src)
	return TRUE

/datum/controller/subsystem/star_system/instantiate_systems(_source_path = SSmapping.config.starmap_path)
	. = ..()
	GLOB.hexmap = new
	GLOB.hexmap.build(systems)
