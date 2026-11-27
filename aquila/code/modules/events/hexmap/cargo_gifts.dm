// AQUILA - Prezent od Nanotrasen: kapsuła zaopatrzeniowa Centrali z darmowym zestawem skrzyń dla jednego działu ląduje w magazynie zaopatrzenia (port z space-wizards/space-station-14 Resources/Prototypes/GameRules/cargo_gifts.yml)
// SS14 adds free orders to the cargo console (engineering, medical, janitor, pizza party, vending restock, EVA gifts).
// Ours sends the crates at once in one Central Command supply pod to the cargo bay (any safe area when the ship has
// none), like our stray cargo pod (landing checks through parent_type), with no landing explosion. The contents are
// our cargo packs; the pizza party became a party crate with food, because our pizza pack can carry a bomb pizza.

/datum/round_event_control/aquila_hex_cargo_gifts
	name = "Prezent od Nanotrasen"
	typepath = /datum/round_event/aquila_hex_cargo_gifts
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_cargo_gifts
	parent_type = /datum/round_event/aquila_stray_cargo
	fakeable = FALSE
	/// Department the gift is for, a key of gift_variants()
	var/gift_department

/datum/round_event/aquila_hex_cargo_gifts/setup()
	gift_department = pick(gift_variants())
	return ..()

/// Department name => cargo packs of its gift
/datum/round_event/aquila_hex_cargo_gifts/proc/gift_variants()
	var/static/list/variants = list(
		"Inżynierii" = list(/datum/supply_pack/materials/iron50, /datum/supply_pack/materials/glass50, /datum/supply_pack/materials/plasteel20, /datum/supply_pack/engineering/tools),
		"Medycyny" = list(/datum/supply_pack/medical/supplies, /datum/supply_pack/medical/basickits, /datum/supply_pack/medical/bruisekits),
		"Woźnego" = list(/datum/supply_pack/service/janitor, /datum/supply_pack/service/lightbulbs),
		"Baru" = list(/datum/supply_pack/service/party, /datum/supply_pack/organic/food, /datum/supply_pack/service/vending/snack),
		"Zaopatrzenia" = list(/datum/supply_pack/emergency/spacesuit, /datum/supply_pack/emergency/internals, /datum/supply_pack/engineering/vending/engineering),
	)
	return variants

/datum/round_event/aquila_hex_cargo_gifts/announce(fake)
	if(!landing_zone)
		return
	priority_announce("Dział Morale Nanotrasen przesyła załodze prezent: darmowy zestaw zaopatrzenia dla działu [gift_department]. Kapsuła wyląduje w: [impact_area?.name || "nieznane"]. Prosimy nie stać pod kapsułą.", "Prezent od Nanotrasen")

/datum/round_event/aquila_hex_cargo_gifts/start()
	if(!landing_zone)
		return kill()
	if(is_blocked_turf(landing_zone, TRUE))
		landing_zone = get_landing_zone()
		if(!landing_zone)
			return kill()
	var/obj/structure/closet/supplypod/pod = new(null, STYLE_CENTCOM)
	pod.explosionSize = list(0, 0, 0, 0)
	for(var/obj/crate as anything in make_gift_crates())
		crate.forceMove(pod)
	var/obj/effect/pod_landingzone/landing_marker = new(landing_zone, pod)
	announce_to_ghosts(landing_marker)
	log_game("Cargo Gifts: gift for [gift_department] landing at [AREACOORD(landing_zone)].")

/// The crates of the gift, in nullspace
/datum/round_event/aquila_hex_cargo_gifts/proc/make_gift_crates()
	. = list()
	for(var/pack_type in gift_variants()[gift_department])
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type]
		if(!pack)
			continue
		var/obj/structure/closet/crate/crate = pack.generate(null)
		if(!crate)
			continue
		if(istype(crate))
			crate.locked = FALSE
			crate.name = "[crate.name] (prezent dla działu [gift_department])"
			crate.update_icon()
		. += crate

/// The cargo bay, any safe station area when the ship has no free floor there
/datum/round_event/aquila_hex_cargo_gifts/find_event_area()
	for(var/area_type in list(/area/quartermaster/storage, /area/quartermaster/warehouse, /area/quartermaster))
		var/area/cargo = GLOB.areas_by_type[area_type]
		if(!cargo)
			continue
		for(var/turf/open/T in cargo)
			if(!isspaceturf(T) && !is_blocked_turf(T, TRUE))
				return cargo
	return ..()
