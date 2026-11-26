// AQUILA - stacje handlowe na mapie hex (raport/ftl_mapa_06_plan_pr.md, część F): okręty AI do eskorty i atomówki w ofercie.
// Eskorta to flota, która skacze za okrętem gracza na ten sam kafel, w kaflu trzyma się przy nim i bije jego cele.
// Najwyżej HEX_ESCORT_MAX okrętów eskorty naraz i osobno HEX_ESCORT_FIGHTERS_MAX myśliwców; eskorta nie przechodzi do
// następnej rundy.

/datum/fleet/aquila_escort
	name = "eskorta"
	fighter_types = list()
	destroyer_types = list()
	battleship_types = list()
	supply_types = list()
	alignment = "nanotrasen"
	faction_id = FACTION_ID_NT
	hide_movements = TRUE
	allow_difficulty_scaling = FALSE
	threat_elevation_allowed = FALSE
	can_reinforce = FALSE
	reward = 0
	/// Sama się nie rusza: skacze tylko razem z okrętem gracza
	fleet_trait = FLEET_TRAIT_DEFENSE
	greetings = list("Eskorta melduje gotowość. Trzymamy się was.")
	/// Okręt, który eskortujemy
	var/obj/structure/overmap/escorting

/// Floty eskorty tego okrętu
/obj/structure/overmap/proc/hex_escort_fleets()
	. = list()
	for(var/datum/fleet/aquila_escort/F in hex_all_fleets())
		if(F.escorting == src)
			. += F

/// Okręty eskorty (fighters = TRUE: same myśliwce, liczone osobno)
/obj/structure/overmap/proc/hex_escort_count(fighters = FALSE)
	. = 0
	for(var/datum/fleet/aquila_escort/F as anything in hex_escort_fleets())
		for(var/obj/structure/overmap/OM as anything in F.all_ships)
			if(!QDELETED(OM) && (OM.mass <= MASS_TINY) == !!fighters)
				.++

/// Kupiony okręt dołącza do eskorty okrętu gracza w jego układzie
/obj/structure/overmap/proc/hex_add_escort(ship_type)
	var/datum/star_system/S = current_system
	if(!S)
		return
	var/datum/fleet/aquila_escort/F
	for(var/datum/fleet/aquila_escort/existing as anything in hex_escort_fleets())
		F = existing
		break
	if(!F)
		F = new
		F.escorting = src
		F.name = "eskorta [src]"
		F.current_system = S
		S.fleets += F
		F.instantiated = TRUE
	var/obj/structure/overmap/member = new ship_type()
	F.add_ship(member, member.mass <= MASS_TINY ? "fighters" : "destroyers")
	member.defense_target = src
	if(S.occupying_z && z)
		var/turf/spot = locate(clamp(x + rand(-6, 6), 2, world.maxx - 2), clamp(y + rand(-6, 6), 2, world.maxy - 2), z)
		if(spot)
			member.forceMove(spot)
	return member

/// Okręt gracza wyszedł z nadprzestrzeni: eskorta przeskakuje za nim (hook w jump_end, hex_events.dm)
/obj/structure/overmap/proc/hex_move_escorts(datum/star_system/target)
	for(var/datum/fleet/aquila_escort/F as anything in hex_escort_fleets())
		if(F.current_system == target)
			continue
		F.current_system?.fleets -= F
		for(var/obj/structure/overmap/OM as anything in F.all_ships)
			if(!QDELETED(OM))
				SSstar_system.move_existing_object(OM, target)
		target.fleets += F
		F.current_system = target

/// Okręty eskorty trzymają się przy okręcie gracza i biją jego cele (jak cel „obrona” NSV, ale dla okrętu gracza)
/datum/ai_goal/aquila_escort
	name = "Escort the player ship"
	score = AI_SCORE_CRITICAL

/datum/ai_goal/aquila_escort/check_score(obj/structure/overmap/OM)
	if(!..())
		return 0
	var/datum/fleet/aquila_escort/F = OM.fleet
	if(!istype(F) || QDELETED(F.escorting) || F.escorting.z != OM.z)
		return 0
	return score

/datum/ai_goal/aquila_escort/action(obj/structure/overmap/OM)
	..()
	var/datum/fleet/aquila_escort/F = OM.fleet
	var/obj/structure/overmap/escorted = F.escorting
	OM.defense_target = escorted
	if(escorted.last_target && !QDELETED(escorted.last_target) && overmap_dist(escorted, escorted.last_target) < escorted.max_weapon_range * 1.5)
		OM.last_target = escorted.last_target // ostrzał bierze last_target okrętu eskorty, więc cel musi być ten sam co manewr
		defensively_engage(OM, escorted.last_target)
		return
	if(OM.last_target && !QDELETED(OM.last_target) && overmap_dist(OM.last_target, escorted) <= OM.max_weapon_range * 2)
		defensively_engage(OM, OM.last_target)
		return
	guard(OM, escorted)

// ===== oferta stacji =====

/datum/trader_item/aquila_escort
	name = "Fregata eskorty"
	desc = "Fregata Nanotrasen z załogą AI dołącza do waszego okrętu: skacze za wami i bije wasze cele. Najwyżej 4 okręty eskorty naraz."
	price = 3000
	stock = 2
	var/escort_type = /obj/structure/overmap/nanotrasen/frigate/ai
	/// Ile jednostek daje jeden zakup
	var/escort_count = 1

/datum/trader_item/aquila_escort/on_purchase(obj/structure/overmap/OM)
	for(var/i in 1 to escort_count)
		OM.hex_add_escort(escort_type)

/datum/trader_item/aquila_escort/cruiser
	name = "Krążownik eskorty"
	desc = "Krążownik patrolowy Nanotrasen z załogą AI dołącza do waszego okrętu: skacze za wami i bije wasze cele. Najwyżej 4 okręty eskorty naraz."
	price = 8000
	stock = 1
	escort_type = /obj/structure/overmap/nanotrasen/patrol_cruiser/ai

/datum/trader_item/aquila_escort/fighters
	name = "Klucz myśliwców eskorty"
	desc = "Dwa lekkie myśliwce Viper z pilotami AI dołączają do waszego okrętu: skaczą za wami i bronią was przed myśliwcami i rakietami. Najwyżej 6 myśliwców eskorty naraz, osobno od okrętów."
	price = 1000
	stock = 3
	escort_type = /obj/structure/overmap/nanotrasen/ai/fighter
	escort_count = 2

/datum/trader_item/aquila_nuke
	name = "Torpeda termojądrowa"
	desc = "Jedna torpeda NTNK „Nadchodząca Burza” w kapsule zaopatrzeniowej. Do wyrzutni torped albo VLS, strzał strategiczny przy DEFCON 2."
	price = 15000
	stock = 1
	unlock_path = /obj/item/ship_weapon/ammunition/torpedo/nuke

/// Stocznie sprzedają eskortę, zbrojownia White Rapids także atomówkę (dopisane przy każdym uzupełnieniu towaru)
/datum/trader/stock_items()
	if(GLOB.hexmap?.built)
		if(istype(src, /datum/trader/czanekcorp) || istype(src, /datum/trader/minsky))
			sold_items |= list(/datum/trader_item/aquila_escort/fighters, /datum/trader_item/aquila_escort, /datum/trader_item/aquila_escort/cruiser)
		if(type == /datum/trader/armsdealer)
			sold_items |= list(/datum/trader_item/aquila_nuke, /datum/trader_item/aquila_escort/fighters, /datum/trader_item/aquila_escort)
	return ..()

