/// AQUILA - fleet distress calls and fleet retreat. A fleet that is losing (heavy losses or a scared crew) near the players
/// (their system or one next to the main ship) may call for help, against players or AI enemies alike: one roll per fight (GLOB.ai_distress_chance, ai_tuning.dm).
/// The nearest allied fleet within two jumps that is not fighting itself answers and jumps in a few minutes later.
/// Players in the system hear the fleet radio (an ally clearly, an enemy as an intercepted fragment) and get a warning before the help arrives. A fleet that is still losing and has no help coming
/// spools its drives for 30 s (interdiction stops it) and jumps out together to a neighbouring system.
/// Stage 3 of the AI plan, switched with AI morale (Debug > Toggle AI morale).

/// How often a fleet looks at its own state (it is driven by its ships' morale ticks)
#define FLEET_MORALE_INTERVAL (5 SECONDS)
/// Distress call thresholds: share of the fleet lost, or average fear
#define FLEET_DISTRESS_LOSSES 0.34
#define FLEET_DISTRESS_FEAR 50
/// Retreat thresholds
#define FLEET_RETREAT_LOSSES 0.67
#define FLEET_RETREAT_FEAR 65
/// How far (in jumps) a distress call reaches
#define FLEET_DISTRESS_JUMPS 2
/// Help arrives after this, plus FLEET_DISTRESS_PER_JUMP for each jump past the first
#define FLEET_DISTRESS_DELAY_MIN (2 MINUTES)
#define FLEET_DISTRESS_DELAY_MAX (3 MINUTES)
#define FLEET_DISTRESS_PER_JUMP (1 MINUTES)
/// Players get this much warning before the help jumps in
#define FLEET_DISTRESS_WARNING (30 SECONDS)
/// Help this late counts as not coming, and the fleet may retreat after all
#define FLEET_DISTRESS_GRACE (1 MINUTES)
/// Fear taken off every ship of a fleet that knows help is on the way
#define FLEET_HELP_CALM 15
/// Drive spool before a fleet jumps out, and the retry delay when interdicted
#define FLEET_RETREAT_SPOOL (30 SECONDS)
#define FLEET_RETREAT_RETRY (15 SECONDS)

/datum/fleet
	/// AQUILA - most ships this fleet had in a loaded system, for counting losses
	var/ai_peak_ships = 0
	var/ai_next_morale_check = 0
	/// AQUILA - a distress call was sent in this fight
	var/ai_distress_sent = FALSE
	/// AQUILA - world.time the answering fleet should arrive (0 = nobody answered)
	var/ai_help_eta = 0
	/// AQUILA - this fleet is on its way to answer a call
	var/ai_answering = FALSE
	/// AQUILA - this fleet came in answer to a distress call; reinforcements never call reinforcements of their own
	var/ai_is_reinforcement = FALSE
	/// AQUILA - world.time the retreat jump happens (0 = not retreating)
	var/ai_retreat_at = 0
	/// AQUILA - the players already got the half reward for driving this fleet off
	var/ai_retreat_paid = FALSE

/// Sends a message to the bridge consoles of every player ship in this system
/datum/star_system/proc/warn_player_ships(message)
	for(var/obj/structure/overmap/OM as anything in system_contents)
		if(!istype(OM) || OM.ai_controlled || !OM.z)
			continue
		var/text = "<span class='warning'>[message]</span>"
		if(OM.tactical)
			OM.tactical.relay_sound('nsv13/sound/effects/computer/alarm_3.ogg', text)
		else if(OM.dradis)
			OM.dradis.visible_message(text)

/// Share of words lost to static in an intercepted enemy transmission
#define FLEET_TRANSMISSION_STATIC 25

/// Fleet radio heard on the players' bridges: an allied fleet comes through clear, an enemy one as a fragment of an intercepted
/// transmission with words lost to static. Numbers always get through, so the players still learn how long they have.
/datum/fleet/proc/broadcast_ai_fleet(list/ally_lines, list/enemy_lines, datum/star_system/heard_in = current_system)
	if(is_player_ally())
		heard_in.warn_player_ships("Transmisja od [name]: „[pick(ally_lines)]”")
	else
		heard_in.warn_player_ships("<i>Przechwycono fragment transmisji ([name]): „[garble_ai_transmission(pick(enemy_lines))]”</i>")

/// "… wszystkie jednostki … rozgrzać napędy, skok za 30 sekund …": some words lost to static, never the numbers
/proc/garble_ai_transmission(text)
	var/list/heard = list("…")
	for(var/word in splittext(text, " "))
		if(isnull(text2num(word)) && prob(FLEET_TRANSMISSION_STATIC))
			if(heard[length(heard)] != "…")
				heard += "…"
			continue
		heard += word
	if(heard[length(heard)] != "…")
		heard += "…"
	return jointext(heard, " ")

/// A crewed ship: not run by the AI and not an asteroid (asteroids are not AI controlled and have no faction)
/obj/structure/overmap/proc/is_crewed_ship()
	return !ai_controlled && z && !istype(src, /obj/structure/overmap/asteroid)

/// A ship not on our side and not run by the AI is in the system with us
/datum/fleet/proc/has_player_enemies()
	for(var/obj/structure/overmap/OM as anything in current_system?.system_contents)
		if(istype(OM) && OM.is_crewed_ship() && OM.faction != alignment && !federation_check(OM))
			return TRUE
	return FALSE

/// Any enemy in the system with us, players or AI (Nanotrasen fleets call for help against the Syndicate too)
/datum/fleet/proc/has_ai_fleet_enemies()
	for(var/obj/structure/overmap/OM as anything in current_system?.system_contents)
		if(istype(OM) && OM.z && OM.faction != alignment && !federation_check(OM) && !istype(OM, /obj/structure/overmap/asteroid) && !OM.essential)
			return TRUE
	return FALSE

/// Distress calls only go out where players can see them: a system with a player ship, or one next to the main ship's system
/datum/fleet/proc/is_near_players()
	for(var/obj/structure/overmap/OM as anything in current_system?.system_contents)
		if(istype(OM) && OM.is_crewed_ship())
			return TRUE
	var/datum/star_system/player_system = SSstar_system.find_main_overmap()?.current_system
	return player_system && (current_system == player_system || (current_system.name in player_system.adjacency_list))

/// list(ships in the fight, average fear, share of the fleet lost)
/datum/fleet/proc/get_ai_fleet_state()
	var/count = 0
	var/fear = 0
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(QDELETED(OM) || !OM.z || OM.mass <= MASS_TINY)
			continue
		count++
		fear += OM.ai_fear
	ai_peak_ships = max(ai_peak_ships, count)
	return list(count, count ? fear / count : 0, ai_peak_ships ? 1 - count / ai_peak_ships : 0)

/datum/fleet/proc/check_ai_fleet_morale()
	if(world.time < ai_next_morale_check || !current_system?.occupying_z)
		return
	ai_next_morale_check = world.time + FLEET_MORALE_INTERVAL
	if(ai_retreat_at)
		if(world.time >= ai_retreat_at)
			try_ai_retreat_jump()
		return
	if(!has_ai_fleet_enemies())
		ai_is_reinforcement = FALSE // walka, na którą przylecieliśmy, się skończyła: w następnej wolno wezwać pomoc
		return
	var/list/state = get_ai_fleet_state()
	var/fear = state[2]
	var/losses = state[3]
	if(wants_ai_distress_call(losses, fear) && is_near_players())
		ai_distress_sent = TRUE // One roll per fight
		if(prob(GLOB.ai_distress_chance)) // ai_tuning.dm
			send_ai_distress_call()
		else
			note_ai_fleet_event("losing, but did not call for help (roll failed)")
	var/help_coming = ai_help_eta && world.time < ai_help_eta + FLEET_DISTRESS_GRACE
	if(fleet_trait != FLEET_TRAIT_DEFENSE && !help_coming && (losses >= FLEET_RETREAT_LOSSES || fear >= FLEET_RETREAT_FEAR) && can_ai_fleet_retreat())
		start_ai_retreat()

/// Losing badly enough to call for help, once per fight, and not when we are the help ourselves
/datum/fleet/proc/wants_ai_distress_call(losses, fear)
	return !ai_distress_sent && !ai_is_reinforcement && (losses >= FLEET_DISTRESS_LOSSES || fear >= FLEET_DISTRESS_FEAR)

/// Allied fleets within FLEET_DISTRESS_JUMPS that can answer, as fleet => jumps
/datum/fleet/proc/find_ai_distress_responders()
	. = list()
	var/list/visited = list()
	visited[current_system] = 0
	var/list/queue = list(current_system)
	while(length(queue))
		var/datum/star_system/system = queue[1]
		queue.Cut(1, 2)
		var/jumps = visited[system]
		if(jumps >= FLEET_DISTRESS_JUMPS)
			continue
		for(var/system_name in system.adjacency_list)
			var/datum/star_system/next = SSstar_system.system_by_id(system_name)
			if(!next || (next in visited))
				continue
			visited[next] = jumps + 1
			queue += next
			for(var/datum/fleet/other as anything in next.fleets)
				if(other.can_answer_ai_distress(src))
					.[other] = jumps + 1

/datum/fleet/proc/can_answer_ai_distress(datum/fleet/caller_fleet)
	if(QDELETED(src) || src == caller_fleet || alignment != caller_fleet.alignment || ai_answering || ai_retreat_at)
		return FALSE
	if(fleet_trait == FLEET_TRAIT_DEFENSE || !length(all_ships))
		return FALSE // Boss fleets do not move
	// Busy with its own fight; last_encounter_time 0 means it never fought
	if(current_system.check_conflict_status() || (last_encounter_time && world.time < last_encounter_time + combat_move_delay))
		return FALSE
	return TRUE

/// On the players' side (their faction or the federation): the bridge hears an ally asking for help, not an intercepted enemy call
/datum/fleet/proc/is_player_ally()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	return main && (main.faction == alignment || federation_check(main))

/// Fleet decisions, for the logs (and the AI sandbox record)
/datum/fleet/proc/note_ai_fleet_event(text)
	log_game("[name] ([current_system]): [text]")

/datum/fleet/proc/send_ai_distress_call()
	ai_distress_sent = TRUE
	var/ally = is_player_ally()
	broadcast_ai_fleet(list(
		"Tu [name]. Ponosimy ciężkie straty, potrzebujemy natychmiastowego wsparcia!",
		"Mayday, mayday, tu [name]. Nie utrzymamy pozycji, prosimy o posiłki.",
		"Do wszystkich jednostek w zasięgu: [name] pod ostrzałem, wzywamy wsparcia.",
	), list(
		"Tu [name], jesteśmy pod ciężkim ostrzałem, potrzebne natychmiastowe wsparcie, powtarzam, natychmiastowe wsparcie",
		"wszystkie jednostki w zasięgu, kadłub nie wytrzyma długo, przyślijcie posiłki na nasze współrzędne",
		"straciliśmy osłony, wróg naciska, prosimy o pomoc każdej jednostki w sektorze",
	))
	var/list/responders = find_ai_distress_responders()
	if(!length(responders))
		note_ai_fleet_event("distress call, nobody answered")
		return
	var/datum/fleet/answering
	for(var/datum/fleet/other as anything in responders)
		if(!answering || responders[other] < responders[answering])
			answering = other
	var/jumps = responders[answering]
	var/delay = rand(FLEET_DISTRESS_DELAY_MIN, FLEET_DISTRESS_DELAY_MAX) + (jumps - 1) * FLEET_DISTRESS_PER_JUMP
	answering.ai_answering = TRUE
	ai_help_eta = world.time + delay
	var/minutes = max(1, round(delay / (1 MINUTES)))
	answering.broadcast_ai_fleet(list(
		"Tu [answering.name]. Słyszymy was, [name]. Będziemy na miejscu za około [minutes] min.",
		"[answering.name] do [name]: idziemy z pomocą, wytrzymajcie jeszcze około [minutes] min.",
	), list(
		"zrozumiałem, idziemy z pomocą, będziemy za około [minutes] min, wytrzymajcie",
		"potwierdzam odbiór, grupa wsparcia wyrusza, czas dolotu [minutes] min",
	), current_system)
	// On the answering fleet, so the warning dies with it and is skipped if it cannot come any more
	addtimer(CALLBACK(answering, TYPE_PROC_REF(/datum/fleet, warn_ai_distress_arrival), current_system, ally), max(0, delay - FLEET_DISTRESS_WARNING))
	addtimer(CALLBACK(answering, TYPE_PROC_REF(/datum/fleet, answer_ai_distress), current_system), delay)
	message_admins("[name] w systemie [current_system] wezwała pomoc. Odpowiada [answering.name] z systemu [answering.current_system] za [DisplayTimeText(delay)].")
	note_ai_fleet_event("distress call answered by [answering.name] from [answering.current_system] in [delay / 10] s")

/datum/fleet/proc/warn_ai_distress_arrival(datum/star_system/target, ally)
	if(!ai_answering || !length(all_ships) || target == current_system)
		return
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, pick(all_ships)) & (WEAK_INTERDICT|STRONG_INTERDICT))
		return // It will not get through, so there is nothing to warn about
	target.warn_player_ships(ally ? "Sojusznicze posiłki za chwilę wyjdą z nadprzestrzeni." : "Wykryto zbliżające się sygnatury napędu FTL.")

/datum/fleet/proc/answer_ai_distress(datum/star_system/target)
	ai_answering = FALSE
	if(QDELETED(src) || !target || target == current_system || !length(all_ships))
		return
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, pick(all_ships)) & (WEAK_INTERDICT|STRONG_INTERDICT))
		note_ai_fleet_event("could not answer a distress call: interdicted")
		return
	ai_is_reinforcement = TRUE
	move(target, force = TRUE)

/// The fleet can fall back: no ship of it is crewed by players (it would be dragged along, crew and all) and there is somewhere to go
/datum/fleet/proc/can_ai_fleet_retreat()
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(!QDELETED(OM) && (!OM.ai_controlled || length(OM.operators)))
			return FALSE
	return !!pick_ai_retreat_system()

/datum/fleet/proc/start_ai_retreat()
	ai_retreat_at = world.time + FLEET_RETREAT_SPOOL
	var/seconds = FLEET_RETREAT_SPOOL / 10
	broadcast_ai_fleet(list(
		"Tu [name]. Nie utrzymamy pozycji, wycofujemy się. Skok za około [seconds] s.",
		"[name] do wszystkich: przerywamy walkę i wycofujemy się z systemu. Skok za około [seconds] s.",
	), list(
		"wszystkie jednostki, przerwać atak, rozgrzać napędy, skok za [seconds] sekund",
		"wycofujemy się, powtarzam, wycofujemy się, zbiórka w punkcie skoku za [seconds] sekund",
		"zbyt duże straty, rozkaz odwrotu dla całej floty, skok za [seconds] sekund",
	))
	note_ai_fleet_event("starts a retreat")

/// Neighbouring system to fall back to: our own territory first, never where the players' main ship is
/datum/fleet/proc/pick_ai_retreat_system()
	var/datum/star_system/player_system = SSstar_system.find_main_overmap()?.current_system
	var/list/own = list()
	var/list/other = list()
	for(var/system_name in current_system.adjacency_list)
		var/datum/star_system/next = SSstar_system.system_by_id(system_name)
		if(!next || next.hidden || next == player_system)
			continue
		if(next.alignment == alignment || next.owner == alignment)
			own += next
		else
			other += next
	if(length(own))
		return pick(own)
	if(length(other))
		return pick(other)

/datum/fleet/proc/try_ai_retreat_jump()
	if(!length(all_ships))
		return
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, pick(all_ships)) & (WEAK_INTERDICT|STRONG_INTERDICT))
		ai_retreat_at = world.time + FLEET_RETREAT_RETRY
		current_system.warn_player_ships("Interdykcja blokuje skok floty [name].")
		return
	// Players boarded a ship during the spool, or the way out closed: call it off (check_ai_fleet_morale does not restart it while that holds)
	var/datum/star_system/target = can_ai_fleet_retreat() ? pick_ai_retreat_system() : null
	if(!target)
		ai_retreat_at = 0
		current_system.warn_player_ships("[name] przerywa przygotowania do skoku.")
		return
	// The players drove the fleet off: half the reward of destroying it, once per fleet
	if(has_player_enemies() && !ai_retreat_paid)
		ai_retreat_paid = TRUE
		faction = SSstar_system.faction_by_id(faction_id)
		faction?.lose_influence(round(reward / 2))
	var/datum/star_system/left = current_system
	left.warn_player_ships("[name] wykonuje skok FTL i wycofuje się z systemu.")
	message_admins("[name] wycofała się z systemu [left] do [target].")
	log_game("[name] retreated from [left] to [target]")
	ai_retreat_at = 0
	ai_distress_sent = FALSE
	ai_help_eta = 0
	ai_peak_ships = 0
	last_encounter_time = world.time
	move(target, force = TRUE)
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(QDELETED(OM))
			continue
		OM.ai_fear = 0
		OM.ai_shock = 0
		OM.ai_recent_damage = 0
		OM.stop_ai_flight()
		OM.last_target = null
	SEND_SIGNAL(src, COMSIG_FLEET_AI_RETREATED, left, target)

/// Station boarding: the counterattack is repelled when its fleet is destroyed or when it retreats (it would never come back on its own,
/// and the objective only waited for the fleet to be deleted)
/datum/overmap_objective/board_station/send_counterattack()
	. = ..()
	watch_counterattack_retreat()

/datum/overmap_objective/board_station/proc/watch_counterattack_retreat()
	if(reinforcements)
		RegisterSignal(reinforcements, COMSIG_FLEET_AI_RETREATED, PROC_REF(counterattack_retreated))

/datum/overmap_objective/board_station/proc/counterattack_retreated(datum/fleet/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_FLEET_AI_RETREATED))
	fleet_destroyed()

/obj/structure/overmap/update_ai_morale()
	. = ..()
	if(fleet && !QDELETED(fleet))
		fleet.check_ai_fleet_morale()

/// Help on the way steadies the crews
/obj/structure/overmap/get_ai_fear_target()
	. = ..()
	if(fleet?.ai_help_eta && world.time < fleet.ai_help_eta + FLEET_DISTRESS_GRACE)
		. = max(0, . - FLEET_HELP_CALM)

#undef FLEET_TRANSMISSION_STATIC
#undef FLEET_MORALE_INTERVAL
#undef FLEET_DISTRESS_LOSSES
#undef FLEET_DISTRESS_FEAR
#undef FLEET_RETREAT_LOSSES
#undef FLEET_RETREAT_FEAR
#undef FLEET_DISTRESS_JUMPS
#undef FLEET_DISTRESS_DELAY_MIN
#undef FLEET_DISTRESS_DELAY_MAX
#undef FLEET_DISTRESS_PER_JUMP
#undef FLEET_DISTRESS_WARNING
#undef FLEET_DISTRESS_GRACE
#undef FLEET_HELP_CALM
#undef FLEET_RETREAT_SPOOL
#undef FLEET_RETREAT_RETRY
