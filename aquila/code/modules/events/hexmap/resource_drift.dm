// AQUILA - Dryfujące zasoby: przy burcie okrętu dryfuje 3-8 skrzyń z surowcami do wyłowienia w EVA (port z MrMelbert/MapleStationCode maplestation_modules/code/modules/events/resource_drift.dm)
// MapleStation spawns its resource caches at carp spawns, throws them at a random crew member (with space dust in front
// of them) and lets them hit the station. Ours puts the crates in space a few turfs off one side of the hull, with
// a GPS tag on each and no dust or throwing, so nothing hits the hull; the announcement comes once they are there.
// The contents are our own sets of common materials in reasonable amounts (no precious materials).

/// Skrzynia z surowcami z eventów (dryfujące zasoby, kapsuły z zasobami): jeden z zestawów zwykłych materiałów
/obj/structure/closet/crate/aquila_resource_cache
	name = "skrzynia z surowcami"
	desc = "Opieczętowana skrzynia transportowa z surowcami. Plomba jest zerwana, a zawartość niekompletna, ale to wciąż dobry towar."
	/// Nazwa zestawu (klucz resource_sets()), losowana przy tworzeniu, gdy pusta
	var/resource_set

/obj/structure/closet/crate/aquila_resource_cache/Initialize(mapload, set_name)
	if(set_name)
		resource_set = set_name
	return ..()

/// Nazwa zestawu => (typ => ilość)
/obj/structure/closet/crate/aquila_resource_cache/proc/resource_sets()
	var/static/list/sets = list(
		"budowlany" = list(/obj/item/stack/sheet/iron = 30, /obj/item/stack/sheet/glass = 20, /obj/item/stack/rods = 20),
		"szklarski" = list(/obj/item/stack/sheet/glass = 30, /obj/item/stack/sheet/rglass = 10),
		"stolarski" = list(/obj/item/stack/sheet/mineral/wood = 20, /obj/item/stack/sheet/plastic = 10, /obj/item/stack/sheet/cardboard = 10),
		"elektryczny" = list(/obj/item/stack/cable_coil = 30, /obj/item/stack/sheet/iron = 15),
		"konstrukcyjny" = list(/obj/item/stack/sheet/plasteel = 5, /obj/item/stack/sheet/iron = 20, /obj/item/stack/tile/plasteel = 20),
	)
	return sets

/obj/structure/closet/crate/aquila_resource_cache/PopulateContents()
	var/list/sets = resource_sets()
	if(!sets[resource_set])
		resource_set = pick(sets)
	var/list/contents_list = sets[resource_set]
	for(var/stack_type in contents_list)
		new stack_type(src, contents_list[stack_type])

/datum/round_event_control/aquila_hex_resource_drift
	name = "Dryfujące zasoby"
	typepath = /datum/round_event/aquila_hex_resource_drift
	weight = 12
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_resource_drift
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Ile skrzyń ma dryfować
	var/cache_count = 3
	/// Ile skrzyń stoi w kosmosie
	var/caches_placed = 0
	/// Pomieszczenie statku najbliższe skrzyniom
	var/near_area_name

/datum/round_event/aquila_hex_resource_drift/setup()
	cache_count = rand(3, 8)

/datum/round_event/aquila_hex_resource_drift/start()
	var/list/caches = place_caches(cache_count)
	if(!length(caches))
		log_game("Resource Drift: no free space next to the hull, cancelling the event.")
		return kill()
	caches_placed = length(caches)
	var/obj/first = caches[1]
	near_area_name = aquila_hex_nearest_ship_area_name(get_turf(first))
	announce_to_ghosts(first)
	log_game("Resource Drift: [caches_placed] resource crate(s) placed near [AREACOORD(first)].")

/datum/round_event/aquila_hex_resource_drift/announce(fake)
	if(!caches_placed)
		return
	priority_announce("Skanery wykryły dryfujące skrzynie z surowcami, najpewniej zgubione przez frachtowiec, który przeleciał tędy przed nami. Unoszą się w kosmosie kilka metrów od burty[near_area_name ? ", w pobliżu: [near_area_name]" : ""]. Liczba skrzyń: [caches_placed]. Każda nadaje sygnał GPS. Zespół EVA może je wyłowić; Nanotrasen przypomina, że znalezione surowce wpisuje się do inwentarza, a nie do kieszeni.", "Ostrzeżenie nawigacyjne")

/// Stawia do amount skrzyń na wolnych polach kosmosu przy jednej burcie (gdy brakuje miejsca, przy kolejnych); zwraca listę skrzyń
/datum/round_event/aquila_hex_resource_drift/proc/place_caches(amount)
	. = list()
	for(var/side in shuffle(GLOB.cardinals.Copy()))
		if(length(.) >= amount)
			return
		var/turf/hull = aquila_hex_ship_hull_turf(side)
		if(!isspaceturf(hull))
			continue
		var/turf/center = aquila_hex_inside_map(get_ranged_target_turf(hull, side, rand(2, 4)))
		for(var/turf/spot as anything in aquila_hex_free_space_near(center, amount - length(.), 2))
			. += make_cache(spot)

/// Skrzynia z surowcami z sygnałem GPS na polu spot
/datum/round_event/aquila_hex_resource_drift/proc/make_cache(turf/spot)
	var/obj/structure/closet/crate/aquila_resource_cache/cache = new(spot)
	cache.AddComponent(/datum/component/gps, "Skrzynia z surowcami")
	return cache
