// Teren gangów jak w Goonstation: znak (i szafka) zajmuje okrąg kafelków, a nie cały obszar.
// Na terenie wroga nie da się stawiać znaków, ale można zamalować wrogi znak (trwa dłużej, wróg dostaje ostrzeżenie).
// Co 15 s każdy znak daje punkty zależnie od tego, ilu ludzi kręci się w pobliżu (gorąco, skala logarytmiczna 0-6).

/// Kafelek -> lista źródeł terenu (znak albo szafka) -> gang
GLOBAL_LIST_EMPTY(gang_turf_sources)

/datum/team/gang
	/// Źródła terenu gangu -> lista zajętych kafelków
	var/list/claim_sources = list()
	/// Ile kafelków (otwartych, na stacji) gang zajmuje
	var/claimed_tiles = 0
	/// Znaki gangu (przynoszą dochód)
	var/list/tags = list()
	/// Kafelki, za które gang dostał już punkty za znak (zmycie i ponowne malowanie nie płaci drugi raz)
	var/list/tag_reward_turfs = list()

/obj/effect/decal/gang
	/// Gorąco znaku: rośnie z ruchem ludzi w pobliżu, spada co cykl
	var/heat = 0

/// Zajmuje dla gangu `G` kafelki w okręgu `radius` wokół `source`
/proc/aq_gang_claim(atom/source, datum/team/gang/G, radius)
	var/turf/center = get_turf(source)
	if(!center || !G || G.claim_sources[source])
		return
	var/list/claimed = list()
	for(var/turf/open/T in RANGE_TURFS(radius, center))
		if(!aq_gang_claimable_turf(T) || get_dist_euclidian(T, center) > radius)
			continue
		var/list/sources = GLOB.gang_turf_sources[T]
		if(!sources)
			sources = list()
			GLOB.gang_turf_sources[T] = sources
		if(!aq_gang_sources_have(sources, G))
			G.claimed_tiles++
		sources[source] = G
		claimed += T
	G.claim_sources[source] = claimed

/// Zwalnia teren zajęty przez `source`
/proc/aq_gang_unclaim(atom/source, datum/team/gang/G)
	var/list/claimed = G?.claim_sources[source]
	if(!claimed)
		return
	G.claim_sources -= source
	for(var/turf/T as anything in claimed)
		var/list/sources = GLOB.gang_turf_sources[T]
		if(!sources)
			continue
		sources -= source
		if(!aq_gang_sources_have(sources, G))
			G.claimed_tiles--
		if(!length(sources))
			GLOB.gang_turf_sources -= T

/proc/aq_gang_sources_have(list/sources, datum/team/gang/G)
	for(var/source in sources)
		if(sources[source] == G)
			return TRUE
	return FALSE

/// Gangi, do których należy kafelek (więcej niż jeden = teren sporny)
/proc/aq_gang_turf_gangs(turf/T)
	. = list()
	var/list/sources = GLOB.gang_turf_sources[T]
	for(var/source in sources)
		. |= sources[source]

/// Kafelek, na którym gangi i złomiarze działają jak na stacji: poziom stacji, komora testowa albo pokój testów jednostkowych
/proc/aq_gang_station_turf(turf/T)
	if(!T)
		return FALSE
	if(is_station_level(T.z))
		return TRUE
	var/area/A = get_area(T)
	return istype(A, /area/test_chamber) || istype(A, /area/testroom)

/// Kafelek, który gang może zająć: otwarty, nie kosmos, na stacji, w obszarze z VALID_TERRITORY
/proc/aq_gang_claimable_turf(turf/T)
	if(!isopenturf(T) || isspaceturf(T) || !aq_gang_station_turf(T))
		return FALSE
	var/area/A = get_area(T)
	return A && (A.area_flags & VALID_TERRITORY)

/// Otwarte kafelki stacji, które da się zająć; liczone raz, bo stacja się nie powiększa
/proc/aq_gang_station_tiles()
	var/static/total = 0
	if(total)
		return total
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.area_flags & VALID_TERRITORY) || !is_station_level(A.z))
			continue
		for(var/turf/open/T in A)
			if(aq_gang_claimable_turf(T))
				total++
		CHECK_TICK
	total = max(total, 1)
	return total

/datum/team/gang/proc/territory_percent()
	return round(claimed_tiles / aq_gang_station_tiles() * 100, 1)

/datum/team/gang/proc/determine_domination_time()
	return max(180, 480 - territory_percent() * 9)

/datum/team/gang/proc/owns_turf(turf/T)
	return (src in aq_gang_turf_gangs(T))

///////////////////
// Znaki
///////////////////

/obj/effect/decal/gang/Initialize(mapload, datum/team/gang/G, e_name = "znak gangu", rotation = 0, mob/user)
	. = ..()
	if(QDELETED(src) || !gang)
		return
	if(gang.tag_icon)
		icon_state = gang.tag_icon
	gang.tags += src
	aq_gang_claim(src, gang, GANG_TAG_RADIUS)
	var/turf/T = get_turf(src)
	if(user?.mind && !gang.tag_reward_turfs[T])
		gang.tag_reward_turfs[T] = TRUE
		gang.add_income(GANG_TAG_POINTS, GANG_SCORE_TURF, user.mind)

/obj/effect/decal/gang/Destroy()
	if(gang)
		gang.tags -= src
		aq_gang_unclaim(src, gang)
	return ..()

/// Czas malowania znaku: 3 s, a zamalowanie wrogiego 15 s
/obj/item/toy/crayon/proc/gang_spray_time(mob/user, atom/target)
	var/datum/antagonist/gang/GA = user.mind?.has_antag_datum(/datum/antagonist/gang)
	for(var/obj/effect/decal/gang/tag in get_turf(target))
		if(tag.gang != GA?.gang)
			return 15 SECONDS
	return 3 SECONDS

// Zasady stawiania znaków według terenu z kafelków (pełne nadpisanie, wpis w LEGACY_OVERRIDES.md: core liczył cały obszar)
/obj/item/toy/crayon/can_claim_for_gang(mob/user, atom/target, alert)
	var/turf/T = get_turf(target)
	var/area/A = get_area(T)
	if(!T || !A || isspaceturf(T) || !aq_gang_station_turf(T) || !(A.area_flags & VALID_TERRITORY))
		to_chat(user, "<span class='warning'>Tutaj nie da się oznaczyć terenu.</span>")
		return FALSE
	if(locate(/obj/machinery/power/apc) in T)
		to_chat(user, "<span class='warning'>Nie możesz otagować APC.</span>")
		return FALSE
	var/datum/antagonist/gang/GA = user.mind?.has_antag_datum(/datum/antagonist/gang)
	// Sprawdzane też po malowaniu: gangster mógł w tym czasie stracić rolę albo przejść do innego gangu
	if(!GA?.gang || (istype(gang, /datum/team/gang) && gang != GA.gang))
		to_chat(user, "<span class='warning'>Kolor tej puszki to nie kolor twojego gangu.</span>")
		return FALSE
	for(var/obj/effect/decal/gang/tag in T)
		if(tag.gang == GA.gang)
			to_chat(user, "<span class='warning'>Tu już jest znak twojego gangu.</span>")
			return FALSE
		if(alert)
			to_chat(user, "<span class='notice'>Gang [tag.gang] dowie się, że zamalowujesz jego znak!</span>")
			tag.gang.message_gang("Ktoś zamalowuje nasz znak w: [get_area_name(T)]!")
		return TRUE
	for(var/datum/team/gang/owner as anything in aq_gang_turf_gangs(T))
		if(owner != GA.gang)
			to_chat(user, "<span class='danger'>To teren gangu [owner]. Najpierw zamaluj jego znak.</span>")
			return FALSE
	for(var/obj/effect/decal/gang/own_tag as anything in GA.gang.tags)
		if(own_tag.z == T.z && get_dist(own_tag, T) < GANG_TAG_SIGHT * 2)
			to_chat(user, "<span class='warning'>Wasz znak jest za blisko. Postaw nowy dalej, żeby zająć więcej terenu.</span>")
			return FALSE
	return TRUE

///////////////////
// Dochód z terenu
///////////////////

/// Jeden cykl dochodu z terenu dla wszystkich gangów (gorąco liczone względem najgorętszego znaku)
/proc/aq_gang_territory_tick()
	var/list/people = list()
	for(var/mob/living/carbon/human/H as anything in GLOB.alive_mob_list)
		if(istype(H) && H.client && aq_gang_station_turf(get_turf(H)))
			people += H
	var/max_heat = 0
	var/list/all_tags = list()
	for(var/datum/team/gang/G as anything in GLOB.gangs)
		for(var/obj/effect/decal/gang/tag as anything in G.tags)
			var/visitors = 0
			for(var/mob/living/carbon/human/H as anything in people)
				if(H.z == tag.z && get_dist(H, tag) <= GANG_TAG_SIGHT)
					visitors++
			tag.heat = tag.heat * GANG_HEAT_DECAY + visitors
			max_heat = max(max_heat, tag.heat)
			all_tags += tag
	if(max_heat <= 0)
		return
	for(var/obj/effect/decal/gang/tag as anything in all_tags)
		var/income = round(GANG_TAG_MAX_INCOME * log(1 + tag.heat) / log(1 + max_heat))
		if(income > 0)
			tag.gang.add_income(income, GANG_SCORE_TURF)
