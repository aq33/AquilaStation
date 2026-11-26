// AQUILA - Tajemniczy prezent: obok kogoś z załogi z błyskiem iskier pojawia się zapakowana skrzynia z losowym zestawem z ładowni (port z LLA-Gaming/SS13 code/modules/events/roundstart/mysterious_gift.dm)
// LLA picks any crate pack, keeps its access lock and names every item "Mysterious <name>"; the event is hidden.
// Ours draws only from cargo packs anyone may order: no special, hidden, contraband, dangerous, admin, drop pod only or
// access-locked packs, nothing from the security packs, no pack with guns, ammo, grenades or melee weapons and nothing
// pricier than 4000 credits, so it never hands out weapons, armour or a fortune in materials. The crate comes
// unlocked, wrapped as a gift, on a free safe turf in the room of a random crew member (any safe room when nobody is
// in one). Items get the Polish suffix "z tajemniczego prezentu" instead of a prefix, which would not agree in gender
// with every Polish name. The event stays silent like the original; ghosts are told where it is.

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
		if(!crew_area || aquila_hex_unsafe_area_type(crew_area.type) || istype(crew_area, /area/maintenance) || !(crew_area.type in GLOB.the_station_areas))
			continue
		var/list/turfs = list()
		for(var/turf/T in view(4, crew))
			if(get_area(T) == crew_area && aquila_hex_free_safe_turf(T))
				turfs += T
		if(length(turfs))
			return pick(turfs)
	var/list/room = aquila_hex_room_turfs(1)
	return length(room) ? room[1] : null

/// Paczki z ładowni, które może dostać każdy: bez dostępów, broni, kontrabandy i paczek specjalnych
/datum/round_event/aquila_hex_mystery_gift/proc/gift_packs()
	var/static/list/packs
	if(!packs)
		packs = list()
		for(var/pack_type in SSshuttle.supply_packs)
			var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type]
			if(pack.special || pack.hidden || pack.contraband || pack.dangerous || pack.admin_spawned || pack.DropPodOnly)
				continue
			if(pack.access || pack.access_any || ispath(pack_type, /datum/supply_pack/security))
				continue
			if(!ispath(pack.crate_type, /obj/structure/closet/crate) || pack.cost > 4000)
				continue
			var/armed = FALSE
			for(var/item_type in pack.contains)
				if(ispath(item_type, /obj/item/gun) || ispath(item_type, /obj/item/ammo_box) || ispath(item_type, /obj/item/ammo_casing) || ispath(item_type, /obj/item/grenade) || ispath(item_type, /obj/item/melee))
					armed = TRUE
					break
			if(!armed)
				packs += pack_type
	return packs

/// Zapakowana skrzynia z losowym zestawem na polu spot; null, gdy nie ma pola albo zestawu
/datum/round_event/aquila_hex_mystery_gift/proc/make_gift(turf/spot)
	var/list/packs = gift_packs()
	if(!isturf(spot) || !length(packs))
		return null
	var/datum/supply_pack/pack = SSshuttle.supply_packs[pick(packs)]
	var/obj/structure/closet/crate/crate = pack.generate(null)
	if(!istype(crate))
		qdel(crate)
		return null
	crate.locked = FALSE
	crate.req_access = null
	crate.req_one_access = null
	crate.update_icon()
	for(var/obj/item/content in crate)
		content.name = "[content.name] z tajemniczego prezentu"
	var/obj/structure/big_delivery/gift = new(spot)
	gift.name = "tajemniczy prezent"
	gift.desc = "Skrzynia owinięta w kolorowy papier. Nie ma nadawcy, nie ma adresata, jest tylko kokarda."
	gift.giftwrapped = TRUE
	gift.icon_state = "giftdeliverycrate"
	crate.forceMove(gift)
	do_sparks(3, FALSE, spot)
	playsound(spot, 'sound/effects/phasein.ogg', 40, TRUE)
	return gift
