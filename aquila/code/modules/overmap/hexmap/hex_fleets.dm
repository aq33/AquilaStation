// AQUILA - floty AI na mapie hex. Decyzja floty, dokąd lecieć, zostaje jak w ai-skynet.dm (szlaki ze starmap.json,
// cele, cechy floty), ale flota nie przeskakuje do celu od razu: idzie jeden kafel na ruch (hooki AQ EDIT w move()).
// Pomiędzy układami stoi w pustych kaflach, więc widać ją w drodze i można ją tam spotkać.

/datum/fleet
	minimum_random_move_delay = HEX_FLEET_STEP_MIN
	maximum_random_move_delay = HEX_FLEET_STEP_MAX
	/// Układ, do którego flota idzie przez puste kafle
	var/datum/star_system/hex_heading

/// Flota w drodze idzie dalej do układu, który już wybrała. Zwraca cel albo null (wtedy zwykły wybór w move()).
/datum/fleet/proc/hex_continue_heading()
	if(!GLOB.hexmap?.built || !current_system)
		return
	if(hex_heading && (QDELETED(hex_heading) || hex_heading == current_system || !hex_heading_allowed(hex_heading)))
		hex_heading = null
	if(hex_heading)
		return hex_heading
	// Flota stoi w pustym kaflu bez celu (np. po bitwie): idzie do najbliższego układu z mapy
	if(istype(current_system, /datum/star_system/random/hex_empty))
		var/datum/hex/here = GLOB.hexmap.hex_of_system(current_system)
		var/datum/star_system/best
		var/best_d = INFINITY
		for(var/datum/star_system/S as anything in SSstar_system.systems)
			if(!S.hex || S.hidden || S.hex.sector != here?.sector || istype(S, /datum/star_system/random/hex_empty))
				continue
			var/d = GLOB.hexmap.distance(here, S.hex)
			if(d < best_d)
				best_d = d
				best = S
		hex_heading = best
		return best

/// Te same warunki cech floty co w move(): cel, którego flota już by nie wybrała (np. zajęty przez swoich), przestaje być celem
/datum/fleet/proc/hex_heading_allowed(datum/star_system/S)
	if(ai_is_reinforcement) // posiłki idą do sojuszniczej floty, choćby do układu swojej frakcji
		return TRUE
	switch(fleet_trait)
		if(FLEET_TRAIT_DEFENSE)
			return FALSE
		if(FLEET_TRAIT_BORDER_PATROL)
			return S.owner == alignment
		if(FLEET_TRAIT_INVASION)
			return S.alignment != alignment
		if(FLEET_TRAIT_NEUTRAL_ZONE)
			return S.owner != alignment
	return TRUE

/// Następny kafel na trasie do celu. Bez mapy albo bez trasy (np. zamknięta brama) flota skacze wprost, jak dotąd.
/datum/fleet/proc/hex_next_step(datum/star_system/target)
	if(!GLOB.hexmap?.built || !target)
		return target
	var/datum/hex/here = GLOB.hexmap.hex_of_system(current_system)
	var/datum/hex/goal = GLOB.hexmap.hex_of_system(target)
	if(!here || !goal || here == goal)
		hex_heading = null
		return target
	var/list/route = GLOB.hexmap.route(here, goal, alignment, 5000)
	if(!route)
		hex_heading = null
		return target
	var/list/full = route["full"]
	var/datum/hex/next = full[2]
	hex_heading = (next == goal) ? null : target
	if(next == goal && ai_is_reinforcement && !hide_movements) // ostrzeżenie z fleet_distress.dm przychodzi dopiero przed ostatnim krokiem
		target.warn_player_ships(is_player_ally() ? "Sojusznicze posiłki za chwilę wyjdą z nadprzestrzeni." : "Wykryto zbliżające się sygnatury napędu FTL.")
	return GLOB.hexmap.system_for(next)

/// Pusty kafel, z którego flota wyszła, oddaje układ, gdy nic w nim nie zostało
/datum/fleet/proc/hex_after_step(datum/star_system/left)
	var/datum/star_system/random/hex_empty/E = left
	if(istype(E) && !E.occupying_z)
		addtimer(CALLBACK(E, TYPE_PROC_REF(/datum/star_system/random/hex_empty, try_release)), HEX_EMPTY_CLEANUP_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Wezwanie o pomoc na mapie hex: sojusznicze floty w zasięgu FLEET_DISTRESS_HEXES kafli drogi, jako flota -> liczba kafli
/datum/fleet/proc/find_ai_distress_responders_hex()
	. = list()
	var/datum/hex/here = current_system.hex
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || !length(S.fleets))
			continue
		if(S.hex.sector == here.sector && GLOB.hexmap.distance(S.hex, here) > FLEET_DISTRESS_HEXES)
			continue
		for(var/datum/fleet/other as anything in S.fleets)
			if(!other.can_answer_ai_distress(src))
				continue
			var/hexes = 0
			if(S.hex != here)
				var/list/route = GLOB.hexmap.route(S.hex, here, other.alignment, FLEET_DISTRESS_HEXES * HEX_FTL_COST_GATE)
				if(!route || route["hexes"] > FLEET_DISTRESS_HEXES)
					continue
				hexes = route["hexes"]
			.[other] = max(1, hexes)

/// Odwrót na mapie hex: sąsiedni kafel, nie ten z okrętem gracza; najchętniej w stronę układu swojej frakcji
/datum/fleet/proc/pick_ai_retreat_hex()
	var/datum/hex/here = current_system.hex
	var/datum/hex/player_hex = SSstar_system.find_main_overmap()?.current_hex()
	var/datum/star_system/home
	var/home_d = INFINITY
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hex == here || S.hex.sector != here.sector || S.hidden)
			continue
		if(S.alignment != alignment && S.owner != alignment)
			continue
		var/d = GLOB.hexmap.distance(here, S.hex)
		if(d < home_d)
			home_d = d
			home = S
	var/list/options = list()
	for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(here))
		if(N == player_hex || GLOB.hexmap.blocks(N))
			continue
		options += N
	if(!length(options))
		return
	var/datum/hex/best = pick(options)
	if(home)
		for(var/datum/hex/N as anything in options)
			if(GLOB.hexmap.distance(N, home.hex) < GLOB.hexmap.distance(best, home.hex))
				best = N
	return GLOB.hexmap.system_for(best)
