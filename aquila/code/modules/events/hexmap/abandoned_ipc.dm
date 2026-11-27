// AQUILA - Porzucony IPC: duch gracza budzi się w tunelach technicznych jako porzucony, poobijany robot IPC z uszkodzonymi dyrektywami (port z Monkestation/Monkestation2.0 monkestation/code/modules/storytellers/converted_events/solo/ghosts/abandoned_ipc.dm i code/modules/antagonists/abandoned_ipc/abandoned_ipc_antag.dm)
// Monkestation polls ghosts with its own abandoned IPC preference, makes a human in a safe maintenance turf, turns it into
// an IPC and gives it 4-8 ion laws to follow, a special synthetic heart and an arm doorjack implant that emags airlocks.
// Ours is our IPC species with our own antagonist datum and a ghost role preference of its own (poll through our shared
// hex ghost poll: preference, the all-antagonists and ghost role bans, the ghost role switch, next candidate when the
// chosen one left). The goal is kept simple: two corrupted directives from our ion law generator and surviving the
// shift. No doorjack (an emag in an arm) and no special heart: it wakes with an old maintenance ID (tunnel access only),
// a grey jumpsuit and a small welding tool to patch itself up, a bit damaged, on a free safe maintenance floor.

/datum/round_event_control/aquila_hex_abandoned_ipc
	name = "Porzucony IPC"
	typepath = /datum/round_event/ghost_role/aquila_hex_abandoned_ipc
	weight = 5
	min_players = 10
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/ghost_role/aquila_hex_abandoned_ipc
	minimum_required = 1
	role_name = "Porzucony IPC"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_hex_abandoned_ipc/spawn_role()
	var/list/candidates = aquila_hex_poll_ghost_role(src, list(BAN_ROLE_ALL_ANTAGONISTS, BAN_ROLE_ALL_GHOST), /datum/role_preference/midround_ghost/aquila_abandoned_ipc)
	var/player_key = aquila_hex_take_candidate_key(candidates)
	if(!player_key) // nikt się nie zgłosił albo zgłoszeni wyszli w trakcie ankiety
		return NOT_ENOUGH_PLAYERS
	var/turf/spot = aquila_hex_maint_turf()
	if(!spot)
		return MAP_ERROR
	var/mob/living/carbon/human/robot = make_ipc(spot, player_key)
	if(!robot)
		return NOT_ENOUGH_PLAYERS
	message_admins("[ADMIN_LOOKUPFLW(robot)] zostaje porzuconym IPC w [ADMIN_VERBOSEJMP(spot)].")
	log_game("[key_name(robot)] was spawned as an abandoned IPC by an event at [AREACOORD(spot)].")
	spawned_mobs += robot
	return SUCCESSFUL_SPAWN

/// Porzucony IPC na spot; z kluczem gracza dostaje jego umysł i antagonistę. Bez klucza (test) samo ciało.
/datum/round_event/ghost_role/aquila_hex_abandoned_ipc/proc/make_ipc(turf/spot, player_key)
	if(!isturf(spot))
		return null
	var/mob/living/carbon/human/robot = new(spot)
	robot.set_species(/datum/species/ipc)
	robot.fully_replace_character_name(null, robot.dna.species.random_name())
	robot.equipOutfit(/datum/outfit/aquila_hex_abandoned_ipc)
	robot.adjustBruteLoss(rand(15, 30))
	if(!player_key)
		return robot
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	player_mind.transfer_to(robot)
	player_mind.assigned_role = "Porzucony IPC"
	player_mind.special_role = "Abandoned IPC"
	player_mind.add_antag_datum(/datum/antagonist/aquila_hex_abandoned_ipc)
	return robot

/datum/outfit/aquila_hex_abandoned_ipc
	name = "Abandoned IPC"
	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id/aquila_hex_abandoned_ipc
	r_pocket = /obj/item/weldingtool/mini

/// Stary identyfikator technika, z którego zostało tylko wejście do tuneli
/obj/item/card/id/aquila_hex_abandoned_ipc
	name = "porysowany identyfikator"
	desc = "Stara karta technika z wytartym nazwiskiem. Działa już tylko w drzwiach tuneli technicznych."
	assignment = "Technik (zwolniony)"
	access = list(ACCESS_MAINT_TUNNELS)

/datum/antagonist/aquila_hex_abandoned_ipc
	name = "Porzucony IPC"
	roundend_category = "porzucone IPC"
	antagpanel_category = "Other"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	/// Uszkodzone dyrektywy (prawa jonowe), których robot się trzyma
	var/list/directives = list()

/datum/antagonist/aquila_hex_abandoned_ipc/on_gain()
	for(var/i in 1 to 2)
		var/directive = generate_ion_law()
		directives += directive
		var/datum/objective/law = new
		law.owner = owner
		law.explanation_text = "Uszkodzona dyrektywa: [directive]"
		law.completed = TRUE
		objectives += law
	var/datum/objective/survive/survive = new
	survive.owner = owner
	survive.explanation_text = "Nie daj się znowu wyłączyć: przetrwaj do końca zmiany."
	objectives += survive
	return ..()

/datum/antagonist/aquila_hex_abandoned_ipc/greet()
	to_chat(owner.current, "<span class='big bold'>Jesteś porzuconym IPC!</span>")
	to_chat(owner.current, "<b>Ostatnie, co pamiętasz, to technik, który zaczął cię naprawiać i w połowie poszedł na obiad. Nie wrócił. Twoje systemy naprawcze dokończyły robotę, ale coś przestawiło ci dyrektywy. Budzisz się w tunelach technicznych okrętu Nanotrasen i trzymasz się dyrektyw, które ci zostały.</b>")
	owner.announce_objectives()

/datum/role_preference/midround_ghost/aquila_abandoned_ipc
	name = "Porzucony IPC"
	antag_datum = /datum/antagonist/aquila_hex_abandoned_ipc
