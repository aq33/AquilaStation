// AQUILA - Tajemniczy prezent: obok kogoś z załogi z błyskiem iskier pojawia się zapakowana skrzynia z losowym zestawem z ładowni (port z LLA-Gaming/SS13 code/modules/events/roundstart/mysterious_gift.dm)
// LLA picks any crate pack, keeps its access lock and names every item "Mysterious <name>"; the event is hidden.
// Ours draws only from a fixed list of plain cargo packs with fixed contents (common materials, food and seeds,
// clothes and costumes, toys and art supplies, toolboxes, service supplies), so it never hands out weapons, armour,
// mobs, implants, an RCD or a fortune in materials. The crate comes unlocked, wrapped as a gift, on a free safe turf
// in the room of a random crew member (any safe room when nobody is in one; never the brig, cells, command offices or
// other closed rooms). Items keep their names, so name checks still work; their description says where they came from.
// The event stays silent like the original; ghosts are told where it is.

/datum/round_event_control/aquila_hex_mystery_gift
	name = "Tajemniczy prezent"
	typepath = /datum/round_event/aquila_hex_mystery_gift
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_mystery_gift
	fakeable = FALSE
	startWhen = 1

/datum/round_event/aquila_hex_mystery_gift/start()
	var/turf/spot = find_spot()
	var/obj/structure/big_delivery/gift = make_gift(spot)
	if(!gift)
		log_game("Mystery Gift: no free safe turf or no cargo pack, cancelling the event.")
		return kill()
	announce_to_ghosts(gift)
	log_game("Mystery Gift: a gift crate appeared at [AREACOORD(spot)].")

/// Wolne bezpieczne pole w pomieszczeniu losowego członka załogi; gdy nikt nie stoi w bezpiecznym pomieszczeniu, w dowolnym
/datum/round_event/aquila_hex_mystery_gift/proc/find_spot()
	for(var/mob/living/carbon/human/crew in shuffle(aquila_hex_ship_crew()))
		var/area/crew_area = get_area(crew)
		if(!crew_area || aquila_hex_closed_area_type(crew_area.type) || istype(crew_area, /area/maintenance) || !(crew_area.type in GLOB.the_station_areas))
			continue
		var/list/turfs = list()
		for(var/turf/T in view(4, crew))
			if(get_area(T) == crew_area && aquila_hex_free_safe_turf(T))
				turfs += T
		if(length(turfs))
			return pick(turfs)
	var/list/room = aquila_hex_room_turfs(1)
	return length(room) ? room[1] : null

/// Paczki z ładowni ze stałą zawartością, bez broni, mobów, implantów i drogich materiałów (tylko te, które są w SSshuttle)
/datum/round_event/aquila_hex_mystery_gift/proc/gift_packs()
	var/static/list/allowed_packs = list(
		/datum/supply_pack/materials/cardboard50,
		/datum/supply_pack/materials/glass50,
		/datum/supply_pack/materials/iron50,
		/datum/supply_pack/materials/plastic50,
		/datum/supply_pack/materials/sandstone30,
		/datum/supply_pack/materials/wood50,
		/datum/supply_pack/organic/food,
		/datum/supply_pack/organic/seeds,
		/datum/supply_pack/service/vending/snack,
		/datum/supply_pack/costumes_toys/costume_original,
		/datum/supply_pack/costumes_toys/formalwear,
		/datum/supply_pack/costumes_toys/wardrobes/general,
		/datum/supply_pack/costumes_toys/chess_white,
		/datum/supply_pack/costumes_toys/chess_black,
		/datum/supply_pack/misc/artsupply,
		/datum/supply_pack/misc/bigband,
		/datum/supply_pack/misc/wrapping_paper,
		/datum/supply_pack/misc/fountainpens,
		/datum/supply_pack/engineering/tools,
		/datum/supply_pack/service/lightbulbs,
		/datum/supply_pack/service/carpet,
	)
	. = list()
	for(var/pack_type in allowed_packs)
		if(SSshuttle.supply_packs[pack_type])
			. += pack_type

/// Zapakowana skrzynia z zestawem pack_type (domyślnie losowym) na polu spot; null, gdy nie ma pola albo zestawu
/datum/round_event/aquila_hex_mystery_gift/proc/make_gift(turf/spot, pack_type)
	var/list/packs = gift_packs()
	if(!isturf(spot) || !length(packs))
		return null
	var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type || pick(packs)]
	if(!pack)
		return null
	var/obj/structure/closet/crate/crate = pack.generate(null)
	if(!istype(crate))
		qdel(crate)
		return null
	crate.locked = FALSE
	crate.req_access = null
	crate.req_one_access = null
	crate.update_icon()
	for(var/obj/item/content in crate)
		content.desc = content.desc ? "[content.desc] Pochodzi z tajemniczego prezentu." : "Pochodzi z tajemniczego prezentu."
	var/obj/structure/big_delivery/gift = new(spot)
	gift.name = "tajemniczy prezent"
	gift.desc = "Skrzynia owinięta w kolorowy papier. Nie ma nadawcy, nie ma adresata, jest tylko kokarda."
	gift.giftwrapped = TRUE
	gift.icon_state = "giftdeliverycrate"
	crate.forceMove(gift)
	do_sparks(3, FALSE, spot)
	playsound(spot, 'sound/effects/phasein.ogg', 40, TRUE)
	return gift
