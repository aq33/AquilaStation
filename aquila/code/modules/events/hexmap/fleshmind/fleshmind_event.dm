// AQUILA - Umysł z ciała: na okręcie wykiełkowuje biomechaniczny rój, który rozrasta się przewodami, przejmuje maszyny
// i wytwarza potwory, a kieruje nim kapłan przewodów, rola ducha (port z Bubberstation/Bubberstation
// modular_zubbers/code/modules/events/major/fleshmind_event.dm)
// Bubberstation rolls it as a major storyteller event (35 players, 60 minutes); ours sits in the antags pool of the
// gravitational anomaly hex (decision of the user) and rolls only from there. The poll takes ghosts with the wire priest
// preference, its ban and the living hours of the antagonist and moves on to the next candidate if one left; the chosen
// ghost becomes the eye that picks the core spot. Without a candidate the core sprouts alone in the maintenance tunnels
// (as Bubberstation's fallback_spawn()). The crew hears of it only once the core survived FLESHMIND_ANNOUNCE_DELAY.

/datum/round_event_control/aquila_hex_fleshmind
	name = "Umysł z ciała"
	typepath = /datum/round_event/ghost_role/aquila_hex_fleshmind
	weight = 4
	min_players = 20
	max_occurrences = 1
	earliest_start = 40 MINUTES

/datum/round_event/ghost_role/aquila_hex_fleshmind
	minimum_required = 1
	role_name = "Kapłan przewodów"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_hex_fleshmind/spawn_role()
	var/list/candidates = aquila_hex_poll_ghost_role(src, list(ROLE_WIRE_PRIEST, BAN_ROLE_ALL_ANTAGONISTS), /datum/role_preference/midround_ghost/fleshmind_wire_priest, FLESHMIND_PRIEST_LIVING_HOURS)
	var/player_key = aquila_hex_take_candidate_key(candidates)
	if(!player_key)
		var/obj/structure/fleshmind/structure/core/lone_core = sprout_lone_core()
		if(!lone_core)
			return MAP_ERROR
		spawned_mobs += lone_core
		return SUCCESSFUL_SPAWN
	var/turf/eye_turf = fleshmind_find_core_turf() || aquila_hex_maint_turf()
	if(!eye_turf)
		return MAP_ERROR
	var/mob/camera/fleshmind_eye/eye = make_eye(eye_turf, player_key)
	if(!eye)
		return NOT_ENOUGH_PLAYERS
	message_admins("[ADMIN_LOOKUPFLW(eye)] zostaje okiem kapłana przewodów.")
	log_game("[key_name(eye)] was spawned as a wire priest eye by an event at [AREACOORD(eye_turf)].")
	spawned_mobs += eye
	return SUCCESSFUL_SPAWN

/// Oko kapłana na polu eye_turf; z kluczem gracza dostaje jego umysł. Bez klucza (test) samo oko.
/datum/round_event/ghost_role/aquila_hex_fleshmind/proc/make_eye(turf/eye_turf, player_key)
	if(!isturf(eye_turf))
		return null
	var/mob/camera/fleshmind_eye/eye = new(eye_turf)
	if(!player_key)
		return eye
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	player_mind.transfer_to(eye)
	player_mind.special_role = ROLE_WIRE_PRIEST
	return eye

/// Bez kapłana rdzeń wyrasta sam w tunelach technicznych
/datum/round_event/ghost_role/aquila_hex_fleshmind/proc/sprout_lone_core()
	var/turf/spawn_turf = fleshmind_find_core_turf()
	if(!spawn_turf)
		log_game("Fleshmind: no free maintenance turf for the core, cancelling the event.")
		return null
	message_admins("Umysł z ciała: nikt nie zgłosił się na kapłana, rdzeń wykiełkował sam w [ADMIN_VERBOSEJMP(spawn_turf)].")
	log_game("Fleshmind core sprouted without a wire priest at [AREACOORD(spawn_turf)].")
	return new /obj/structure/fleshmind/structure/core(spawn_turf)
