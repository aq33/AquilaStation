// AQUILA - Duch dawnych honków: duch gracza wraca z tunelu czasoprzestrzennego jako żywa kałuża smaru, która smaruje podłogę, po której pełznie (port z Monkestation/MonkeStation monkestation/code/modules/antagonists/living_lube/living_lube_event.dm)
// Monkestation polls ghosts and puts one into its living lube clown mob on a xeno spawn (or at the late join spawn),
// with the Clown job for Voice of God and a small "Ghost of Honks Past" antagonist datum. Ours puts the ghost into our
// basic living lube (/mob/living/basic/clown/lube, which leaves lube where it crawls) on a safe xeno spawn or a free
// maintenance turf, with a small antagonist datum of ours (one objective: make the crew slip, without killing); no
// Clown job (our Voice of God does not check it). We have no role preference of its own, so the poll takes ghosts with
// the preference of our other comic ghost role (the bingle) and checks the antagonist and ghost role bans and the switch.

/datum/round_event_control/aquila_hex_living_lube
	name = "Duch dawnych honków"
	typepath = /datum/round_event/ghost_role/aquila_hex_living_lube
	weight = 2
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/ghost_role/aquila_hex_living_lube
	minimum_required = 1
	role_name = "Duch dawnych honków"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_hex_living_lube/spawn_role()
	var/list/candidates = aquila_hex_poll_ghost_role(src, list(BAN_ROLE_ALL_ANTAGONISTS, BAN_ROLE_ALL_GHOST), /datum/role_preference/midround_ghost/bingle)
	var/player_key = aquila_hex_take_candidate_key(candidates)
	if(!player_key) // nikt się nie zgłosił albo zgłoszeni wyszli w trakcie ankiety
		return NOT_ENOUGH_PLAYERS
	var/turf/spot = find_spawn()
	if(!spot)
		return MAP_ERROR
	var/mob/living/basic/clown/lube/lube = make_lube(spot, player_key)
	if(!lube)
		return NOT_ENOUGH_PLAYERS
	message_admins("[ADMIN_LOOKUPFLW(lube)] zostaje Duchem dawnych honków w [ADMIN_VERBOSEJMP(spot)].")
	log_game("[key_name(lube)] was spawned as the Ghost of Honks Past by an event at [AREACOORD(spot)].")
	spawned_mobs += lube
	return SUCCESSFUL_SPAWN

/// Bezpieczny punkt pojawiania się obcych na statku, a gdy go nie ma, wolne pole w tunelach technicznych
/datum/round_event/ghost_role/aquila_hex_living_lube/proc/find_spawn()
	var/list/safe_spawns = list()
	for(var/turf/T in GLOB.xeno_spawn)
		if(is_station_level(T.z) && aquila_hex_free_safe_turf(T))
			safe_spawns += T
	if(length(safe_spawns))
		return pick(safe_spawns)
	return aquila_hex_maint_turf()

/// Żywy smar na spot; z kluczem gracza dostaje jego umysł i antagonistę. Bez klucza (test) sam mob.
/datum/round_event/ghost_role/aquila_hex_living_lube/proc/make_lube(turf/spot, player_key)
	if(!isturf(spot))
		return null
	var/mob/living/basic/clown/lube/lube = new(spot)
	playsound(lube, 'sound/items/bikehorn.ogg', 50, TRUE)
	lube.visible_message("<span class='warning'>Z kratki w podłodze wylewa się kałuża smaru, która cicho trąbi.</span>")
	if(!player_key)
		return lube
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	player_mind.transfer_to(lube)
	player_mind.special_role = "Ghost of Honks Past"
	player_mind.add_antag_datum(/datum/antagonist/aquila_hex_living_lube)
	return lube

/datum/antagonist/aquila_hex_living_lube
	name = "Duch dawnych honków"
	roundend_category = "duchy dawnych honków"
	antagpanel_category = "Other"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/aquila_hex_living_lube/on_gain()
	var/datum/objective/slip = new
	slip.owner = owner
	slip.explanation_text = "Niech załoga się ślizga. Smaruj korytarze, wywracaj ludzi i trąb, ale nikogo nie zabijaj: klaun nigdy nie zabija, klaun tylko upokarza."
	slip.completed = TRUE
	objectives += slip
	return ..()

/datum/antagonist/aquila_hex_living_lube/greet()
	to_chat(owner.current, "<span class='big bold'>Jesteś Duchem dawnych honków!</span>")
	to_chat(owner.current, "<span class='notice'>Tunel czasoprzestrzenny wypluł cię na okręt Nanotrasen jako żywą kałużę smaru. \
		Wszędzie, gdzie pełzniesz, zostaje śliska plama. Pamiętaj o dawnych klaunach i niech nikt nie przejdzie suchą nogą.</span>")
	owner.announce_objectives()
