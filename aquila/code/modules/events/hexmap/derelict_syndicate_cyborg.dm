// AQUILA - Porzucony szturmowy cyborg Syndykatu: duch gracza budzi się w uszkodzonym szturmowym cyborgu Syndykatu, który dryfował między minami, i leci w kosmosie do okrętu (port z space-wizards/space-station-14 Resources/Prototypes/GameRules/events.yml, DerelictSyndicateAssaultCyborgSpawn)
// SS14 spawns a ghost role derelict Syndicate assault borg in space near the station (SpaceSpawnRule) as a small antag.
// Ours uses our Syndicate assault cyborg (/mob/living/silicon/robot/modules/syndicate: Syndicate laws, ion thrusters for
// space) as a damaged derelict variant with a half-charged cell and its own greeting, put next to the hull of the ship
// (the hull spot of our ship hazard events) with a small antagonist datum of ours (one objective: harm the Nanotrasen
// ship). The poll checks the antagonist ban and the ghost role switch.

/datum/round_event_control/aquila_hex_derelict_syndicate_cyborg
	name = "Porzucony szturmowy cyborg Syndykatu"
	typepath = /datum/round_event/ghost_role/aquila_hex_derelict_syndicate_cyborg
	weight = 5
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/ghost_role/aquila_hex_derelict_syndicate_cyborg
	minimum_required = 1
	role_name = "Porzucony cyborg Syndykatu"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_hex_derelict_syndicate_cyborg/spawn_role()
	var/list/candidates = get_candidates(BAN_ROLE_ALL_ANTAGONISTS, null)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS
	var/turf/spot = aquila_hex_ship_hull_turf(pick(GLOB.cardinals))
	if(!spot)
		return MAP_ERROR
	var/mob/dead/selected = pick_n_take(candidates)
	var/mob/living/silicon/robot/modules/syndicate/aquila_hex_derelict/borg = make_cyborg(spot, selected.key)
	if(!borg)
		return NOT_ENOUGH_PLAYERS
	message_admins("[ADMIN_LOOKUPFLW(borg)] zostaje porzuconym cyborgiem Syndykatu w [ADMIN_VERBOSEJMP(spot)].")
	log_game("[key_name(borg)] was spawned as a derelict Syndicate assault cyborg by an event at [AREACOORD(spot)].")
	spawned_mobs += borg
	return SUCCESSFUL_SPAWN

/// Cyborg na spot; z kluczem gracza dostaje jego umysł i antagonistę. Bez klucza (test) sam cyborg.
/datum/round_event/ghost_role/aquila_hex_derelict_syndicate_cyborg/proc/make_cyborg(turf/spot, player_key)
	if(!isturf(spot))
		return null
	var/mob/living/silicon/robot/modules/syndicate/aquila_hex_derelict/borg = new(spot)
	if(!player_key)
		return borg
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	player_mind.transfer_to(borg)
	player_mind.special_role = "Derelict Syndicate Cyborg"
	player_mind.add_antag_datum(/datum/antagonist/aquila_hex_derelict_cyborg)
	return borg

/// Szturmowy cyborg Syndykatu, który długo dryfował w kosmosie
/mob/living/silicon/robot/modules/syndicate/aquila_hex_derelict
	playstyle_string = "<span class='big bold'>Jesteś porzuconym szturmowym cyborgiem Syndykatu!</span><br><b>Twój oddział dawno zginął na polu minowym, a ty dryfowałeś między minami, aż czujniki złapały okręt Nanotrasen. Masz uszkodzony pancerz i pół baterii, ale twoja broń nadal działa. Silniki jonowe pozwolą ci dolecieć do kadłuba. Przestrzegaj praw Syndykatu.</b>"

/mob/living/silicon/robot/modules/syndicate/aquila_hex_derelict/Initialize(mapload)
	. = ..()
	cell?.charge = cell.maxcharge * 0.5
	adjustBruteLoss(rand(20, 40))
	name = "porzucony cyborg Syndykatu"
	real_name = name

/datum/antagonist/aquila_hex_derelict_cyborg
	name = "Porzucony cyborg Syndykatu"
	roundend_category = "porzucone cyborgi Syndykatu"
	antagpanel_category = "Other"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/aquila_hex_derelict_cyborg/on_gain()
	var/datum/objective/sabotage = new
	sabotage.owner = owner
	sabotage.explanation_text = "Dokończ misję swojego oddziału: dostań się na okręt Nanotrasen i zadaj mu jak największe straty."
	sabotage.completed = TRUE
	objectives += sabotage
	return ..()

/datum/antagonist/aquila_hex_derelict_cyborg/greet()
	owner.announce_objectives()
