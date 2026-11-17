// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - misje od handlarzy (trader_missions.dm): nagroda za okręty liczy tylko zniszczone wrogie okręty w układzie
/// okrętu gracza, plombowane skrzynie płacą ćwierć stawki za otwartą i nic za zgubioną, otwarcie głowicy kończy jej misję,
/// rozpoznanie kończy się na kaflu celu, a stacje Syndykatu nie zlecają misji
/datum/unit_test/aquila_trader_missions
	var/old_nt_tickets

/obj/structure/overmap/syndicate/ai/gunboat/mission_test
	missiles = 0
	shots_left = 0
	torpedoes = 0

/obj/structure/overmap/syndicate/ai/gunboat/mission_test/apply_weapons()
	return

/datum/unit_test/aquila_trader_missions/Run()
	var/datum/faction/NT = SSstar_system.faction_by_id(FACTION_ID_NT)
	old_nt_tickets = NT?.tickets
	var/fail = check_kills() || check_cargo() || check_nuke() || check_explore() || check_offers() || check_gear() || check_fail_reputation()
	if(NT)
		NT.tickets = old_nt_tickets
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_trader_missions/proc/start(datum/aq_contract/mission/M)
	M.state = "w toku"
	M.deadline = world.time + 10 MINUTES

/// Cofa nagrodę i premię wykonanej misji
/datum/unit_test/aquila_trader_missions/proc/refund(datum/aq_contract/contract)
	var/datum/bank_account/account = SSeconomy.get_dep_account(contract.account)
	account?.adjust_money(-contract.reward)
	GLOB.department_commission_pending[contract.account] -= contract.reward

/datum/unit_test/aquila_trader_missions/proc/check_kills()
	var/obj/structure/overmap/player = SSstar_system.find_main_overmap()
	if(!player)
		return
	var/datum/star_system/old_system = player.current_system
	var/datum/star_system/here = old_system || SSstar_system.systems[1]
	player.current_system = here
	var/datum/aq_contract/mission/kill_ships/M = new(null)
	start(M)
	M.amount = 2
	GLOB.aq_ship_contracts += M
	. = kill_one(M, "syndicate", here, TRUE)
	if(!.)
		. = kill_one(M, "nanotrasen", here, FALSE)
	if(!.)
		var/datum/star_system/elsewhere
		for(var/datum/star_system/S as anything in SSstar_system.systems)
			if(S != here)
				elsewhere = S
				break
		. = kill_one(M, "syndicate", elsewhere, FALSE)
	if(!.)
		. = kill_one(M, "pirate", here, TRUE)
	if(!.)
		M.check_progress()
		if(!M.is_done())
			. = "Two enemy kills didn't complete the bounty ([M.kills]/[M.amount])"
		else
			refund(M)
	player.current_system = old_system
	qdel(M)

/// Niszczy okręt testowy; counts: czy powinien się liczyć do nagrody
/datum/unit_test/aquila_trader_missions/proc/kill_one(datum/aq_contract/mission/kill_ships/M, faction, datum/star_system/where, counts)
	var/before = M.kills
	var/obj/structure/overmap/syndicate/ai/gunboat/mission_test/target = allocate(/obj/structure/overmap/syndicate/ai/gunboat/mission_test)
	target.faction = faction
	target.current_system = where
	target.mass = MASS_SMALL
	target.obj_integrity = 0
	qdel(target)
	if(counts && M.kills != before + 1)
		return "A destroyed [faction] ship in the player's system didn't count for the bounty"
	if(!counts && M.kills != before)
		return "A destroyed [faction] ship in [where] counted for the bounty"

/datum/unit_test/aquila_trader_missions/proc/check_cargo()
	// Dwie skrzynie: jedna dotarła nienaruszona, drugą otwarto łomem
	var/datum/aq_contract/mission/cargo/M = new(null)
	start(M)
	M.amount = 2
	M.max_reward = 4000
	M.max_reputation = 10
	var/obj/structure/closet/crate/large/freight_objective/aq_sealed/sealed = allocate(/obj/structure/closet/crate/large/freight_objective/aq_sealed, run_loc_floor_bottom_left)
	var/obj/structure/closet/crate/large/freight_objective/aq_sealed/opened = allocate(/obj/structure/closet/crate/large/freight_objective/aq_sealed, run_loc_floor_top_right)
	M.bind_crate(sealed)
	M.bind_crate(opened)
	if(length(M.cargo) != 2)
		return "The mission doesn't track the contents of its crates ([length(M.cargo)])"
	SEND_SIGNAL(opened, COMSIG_FREIGHT_TAMPERED)
	var/list/shipment = sealed.GetAllContents() + opened.GetAllContents()
	if(M.deliver(shipment) != 2)
		return "Delivering both crates didn't settle both pieces of cargo"
	M.check_progress()
	if(!M.is_done())
		return "Delivering all cargo didn't complete the mission"
	if(M.reward != round(4000 * 1.25 / 2))
		return "An opened crate didn't cut the pay to a quarter ([M.reward])"
	refund(M)
	qdel(M)

	// Zgubiony ładunek: nic nie dotarło, misja przepada
	var/datum/aq_contract/mission/cargo/lost = new(null)
	start(lost)
	lost.amount = 1
	var/obj/structure/closet/crate/large/freight_objective/aq_sealed/crate = allocate(/obj/structure/closet/crate/large/freight_objective/aq_sealed, run_loc_floor_bottom_left)
	lost.bind_crate(crate)
	for(var/atom/movable/inside as anything in crate.contents)
		qdel(inside)
	lost.check_progress()
	if(!lost.is_failed())
		return "A mission whose only cargo was destroyed didn't fail"
	qdel(lost)

/datum/unit_test/aquila_trader_missions/proc/check_nuke()
	var/old_level = GLOB.security_level
	var/datum/aq_contract/mission/cargo/nuke/M = new(null)
	start(M)
	M.amount = 1
	var/obj/structure/closet/crate/large/freight_objective/aq_sealed/nuke/crate = allocate(/obj/structure/closet/crate/large/freight_objective/aq_sealed/nuke, run_loc_floor_bottom_left)
	M.bind_crate(crate)
	var/obj/machinery/nuclearbomb/aq_mission_cargo/bomb = locate() in crate
	if(!bomb?.timing)
		return "The mission crate has no ticking warhead"
	SEND_SIGNAL(crate, COMSIG_FREIGHT_TAMPERED)
	if(!M.is_failed())
		return "Opening the warhead crate didn't end the mission"
	qdel(bomb)
	if(GLOB.security_level != old_level)
		return "Deleting the warhead changed the security level"
	qdel(M)

/datum/unit_test/aquila_trader_missions/proc/check_explore()
	var/obj/structure/overmap/player = SSstar_system.find_main_overmap()
	var/datum/hex/here = player?.current_hex()
	if(!GLOB.hexmap?.built || !here)
		return
	var/datum/hex/far = aq_mission_pick_hex(here, 5, 9)
	if(far)
		var/list/field = hex_mission_distance_field(list(here), 9)
		if(isnull(field[far]) || field[far] < 5)
			return "The scouting target is outside the 5-9 jump range ([field[far]])"
	var/datum/aq_contract/mission/explore/M = new(null)
	start(M)
	M.target = far || here
	if(far)
		M.check_progress()
		if(!M.is_active())
			return "The scouting mission ended before the ship reached the target"
	M.target = here
	M.check_progress()
	if(!M.is_done())
		return "Reaching the target tile didn't complete the scouting mission"
	refund(M)
	qdel(M)

/// Towar w nagrodę: tylko z unlock_path, bez Żółtych stron i nie droższy niż limit
/datum/trader_item/mission_gear_test
	name = "towar testowy"
	unlock_path = /obj/item/crowbar
	price = 100
	var/given = FALSE

/datum/trader_item/mission_gear_test/on_purchase(obj/structure/overmap/OM)
	given = TRUE

/datum/unit_test/aquila_trader_missions/proc/check_gear()
	var/obj/structure/overmap/trader/station
	for(var/datum/trader/candidate as anything in SSstar_system.traders)
		if(!QDELETED(candidate.current_location))
			station = candidate.current_location
			break
	if(!station || !SSstar_system.find_main_overmap())
		return
	var/datum/trader/T = station.inhabited_trader
	var/list/old_stock = T.stonks
	var/datum/trader_item/mission_gear_test/cheap = new
	var/datum/trader_item/mission_gear_test/expensive = new
	expensive.price = 1000000
	var/datum/trader_item/yellow_pages/pages = new
	T.stonks = list(expensive, pages, cheap)
	var/datum/aq_contract/mission/waves/M = new(station)
	var/datum/trader_item/gift = M.give_gear()
	T.stonks = old_stock
	. = null
	if(gift != cheap || !cheap.given || expensive.given)
		. = "The gear reward didn't pick the only allowed item from the station's stock"
	qdel(M)
	qdel(cheap)
	qdel(expensive)
	qdel(pages)

/// Porażka misji obniża reputację u stacji, która ją zleciła
/datum/unit_test/aquila_trader_missions/proc/check_fail_reputation()
	var/obj/structure/overmap/trader/station
	for(var/datum/trader/candidate as anything in SSstar_system.traders)
		if(!QDELETED(candidate.current_location) && candidate.faction_type != FACTION_ID_SYNDICATE)
			station = candidate.current_location
			break
	if(station?.inhabited_trader)
		var/datum/trader/owner = station.inhabited_trader
		var/old_reputation = owner.aq_reputation
		owner.aq_reputation = 30
		var/datum/aq_contract/mission/explore/mission = new(station)
		mission.state = "w toku"
		mission.deadline = world.time + 10 MINUTES
		mission.fail("test")
		if(owner.aq_reputation != 30 - mission.fail_reputation)
			. = "A failed mission didn't lower the reputation ([owner.aq_reputation])"
		owner.aq_reputation = old_reputation
		qdel(mission)

/datum/unit_test/aquila_trader_missions/proc/check_offers()
	var/old_nuke = GLOB.aq_mission_nuke_offered
	for(var/datum/trader/trader as anything in SSstar_system.traders)
		var/obj/structure/overmap/trader/station = trader.current_location
		if(QDELETED(station) || !station.inhabited_trader)
			continue
		var/list/old_offers = station.aq_mission_offers
		station.aq_mission_offers = null
		var/list/offers = station.aq_get_mission_offers()
		var/syndicate = station.inhabited_trader.faction_type == FACTION_ID_SYNDICATE
		var/error
		if(syndicate && length(offers))
			error = "A Syndicate station offered missions to the NT ship"
		for(var/datum/aq_contract/C as anything in offers)
			if(!C.is_mission || C.state != "oferta")
				error = "A mission offer isn't a mission ([C.type])"
		QDEL_LIST(station.aq_mission_offers)
		station.aq_mission_offers = old_offers
		GLOB.aq_mission_nuke_offered = old_nuke
		if(error)
			return error

#undef TEST_ASSERT
