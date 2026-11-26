// AQUILA - Inwazja mimików: luźne przedmioty w różnych działach okrętu ożywają jako mimiki, a po pół minucie Centrala ogłasza alarm biologiczny (port z ZeroHubProjects/ZeroOnyx code/datums/events/mimics_invasion.dm)
// ZeroOnyx turns 8-16 random items of station areas into mimics, three of them offered to ghosts, and sends the
// level 7 biohazard announcement 30 s later (it disabled the event as an annoying griefer). Ours wakes 4-8 items lying
// on the floor of different areas as our copy mimics (/mob/living/basic/mimic/copy), NPC only: no ghost mimics, so the
// event stays a short scare and not a ghost role. A mimic with nobody to attack slowly wears out and drops its item
// again (idledamage of the copy mimic). IDs, the nuclear disk and other important or indestructible items stay items,
// also when they are inside the item (a wallet with an ID, a box with a PDA), and nothing wakes up in the AI upload,
// the armoury, the bridge, the magazines and the other dangerous or locked areas of our creature events.

/datum/round_event_control/aquila_hex_mimics_invasion
	name = "Inwazja mimików"
	typepath = /datum/round_event/aquila_hex_mimics_invasion
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/aquila_hex_mimics_invasion
	fakeable = FALSE
	startWhen = 1
	announceWhen = 16 // ok. 30 s po starcie, jak w ZeroOnyx
	/// Ile mimików ożyło
	var/spawned = 0

/datum/round_event/aquila_hex_mimics_invasion/start()
	var/list/items = find_items(rand(4, 8))
	for(var/obj/item/item as anything in items)
		if(animate_item(item))
			spawned++
	if(!spawned)
		log_game("Mimics Invasion: no loose items found on the ship, cancelling the event.")
		return kill()
	message_admins("Inwazja mimików: ożyło [spawned] przedmiotów.")
	log_game("Mimics Invasion: [spawned] item(s) came to life as mimics.")

/datum/round_event/aquila_hex_mimics_invasion/announce(fake)
	if(!spawned)
		return
	priority_announce("Wykryto obce formy życia upodabniające się do przedmiotów codziennego użytku w kilku działach okrętu. Załoga powinna zachować ostrożność przy podnoszeniu porzuconych rzeczy. Jeśli twój kubek ma oczy, to nie jest twój kubek.", "Alarm biologiczny", ANNOUNCER_OUTBREAK7)

/// Czy przedmiot może ożyć jako mimik
/proc/aquila_hex_mimic_item_ok(obj/item/item)
	var/static/list/protected_items = typecacheof(list(
		/obj/item/disk/nuclear,
		/obj/item/card/id,
		/obj/item/modular_computer,
		/obj/item/radio/intercom,
		/obj/item/clothing/mask/facehugger,
		/obj/item/mmi,
		/obj/item/organ,
		/obj/item/bodypart,
		/obj/item/clothing/head/mob_holder,
		/obj/item/aicard,
		/obj/item/paicard,
		/obj/item/blackbox,
	))
	if(QDELETED(item) || !isturf(item.loc) || item.anchored)
		return FALSE
	if((item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP) || (item.resistance_flags & INDESTRUCTIBLE))
		return FALSE
	// sam przedmiot i wszystko, co w nim jest (portfel z kartą, pudełko z PDA, mysz w pudełku)
	for(var/atom/movable/thing as anything in item.GetAllContents())
		if(isliving(thing) || is_type_in_typecache(thing, protected_items))
			return FALSE
		if(thing == item || !isobj(thing))
			continue
		var/obj/inner = thing
		if(inner.resistance_flags & INDESTRUCTIBLE)
			return FALSE
	return !is_type_in_typecache(item, GLOB.animatable_blacklist)

/// Do count luźnych przedmiotów z podłóg różnych obszarów statku
/datum/round_event/aquila_hex_mimics_invasion/proc/find_items(count)
	. = list()
	var/list/areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if((A.type in GLOB.the_station_areas) && !aquila_hex_unsafe_area_type(A.type))
			areas += A
	while(length(areas) && length(.) < count)
		var/area/A = pick_n_take(areas)
		var/list/candidates = list()
		for(var/obj/item/item in A)
			if(is_station_level(item.z) && aquila_hex_mimic_item_ok(item))
				candidates += item
		if(length(candidates))
			. += pick(candidates)
		CHECK_TICK

/// Ożywia przedmiot jako mimika; zwraca mimika albo null
/datum/round_event/aquila_hex_mimics_invasion/proc/animate_item(obj/item/item)
	if(!aquila_hex_mimic_item_ok(item))
		return null
	var/turf/spot = get_turf(item)
	var/mob/living/basic/mimic/copy/mimic = new(spot, item)
	if(QDELETED(mimic))
		return null
	if(!(item in mimic.contents)) // CopyObject() odmówił
		qdel(mimic)
		return null
	mimic.visible_message("<span class='danger'>[mimic] nagle otwiera oczy i zaczyna się ruszać!</span>")
	log_game("Mimics Invasion: [item] came to life at [AREACOORD(spot)].")
	return mimic
