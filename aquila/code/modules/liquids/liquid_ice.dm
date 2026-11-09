// AQUILA - Ciecze: bloki lodu z głębokiej zamarzniętej cieczy i zimno w próżni (nowe, nie ma tego w Monke).
// Blok powstaje z kafla zamarzniętej grupy, na którym jest co najmniej LIQUID_ICE_BLOCK_VOLUME jednostek.
// Trzyma reagenty kafla i oddaje je jako ciecz po stopieniu albo rozbiciu. Zatrzymuje powietrze (może zatkać wyłom)
// i więzi postacie oraz przedmioty, które na kaflu leżały (bez GODMODE, inaczej niż kostka ze szlamów).

/// Zamienia jeden pasujący kafel grupy w blok lodu. Zwraca FALSE, gdy żaden się nie nadaje.
/datum/liquid_group/proc/freeze_into_block(turf/open/preferred)
	var/list/candidates = list()
	if(preferred)
		candidates += preferred
	candidates |= members
	for(var/turf/open/member as anything in candidates)
		if(!istype(member) || QDELETED(member.liquids) || member.liquids.liquid_group != src)
			continue
		if(locate(/obj/structure/liquid_ice_block) in member)
			continue
		var/blocked = FALSE
		for(var/atom/movable/AM as anything in member)
			if(AM.density && !isliving(AM))
				blocked = TRUE
				break
		if(blocked)
			continue
		var/obj/structure/liquid_ice_block/block = new(member)
		update_volume_cache()
		reagents.trans_to(block.reagents, reagents_per_turf, no_react = TRUE)
		block.reagents.chem_temp = reagents.chem_temp
		block.update_freezing_point()
		block.trap_contents()
		remove_from_group(member)
		QDEL_NULL(member.liquids)
		if(!QDELETED(src))
			total_reagent_volume = reagents.total_volume
			process_group()
		return TRUE
	return FALSE

/obj/structure/liquid_ice_block
	name = "blok lodu"
	desc = "Gruba bryła zamarzniętej cieczy. Topi się w cieple i od ognia, da się ją też rozbić."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	max_integrity = 150
	armor = list("melee" = 20, "bullet" = 40, "laser" = -50, "energy" = -50, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = -80, "acid" = 30, "stamina" = 0, "bleed" = 0)
	CanAtmosPass = ATMOS_PASS_DENSITY
	/// Temperatura, w której blok zaczyna topnieć
	var/freezing_point = T0C
	/// Kto właśnie się wybija od środka
	var/list/escaping = list()

/obj/structure/liquid_ice_block/Initialize(mapload)
	. = ..()
	create_reagents(LIQUID_ICE_BLOCK_VOLUME * 3, NO_REACT)
	air_update_turf()
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/effects/glassbr1.ogg', 30, TRUE)

/obj/structure/liquid_ice_block/Destroy()
	STOP_PROCESSING(SSobj, src)
	var/turf/T = get_turf(src)
	release_contents()
	if(T && reagents?.total_volume)
		// Rozbity albo stopiony spawarką lód nie zamarza od razu z powrotem (inaczej w zimnie więziłby od nowa)
		reagents.chem_temp = max(reagents.chem_temp, freezing_point + 2)
		T.add_liquid_from_reagents(reagents)
	QDEL_NULL(reagents)
	escaping = null
	. = ..()
	T?.air_update_turf()

/obj/structure/liquid_ice_block/proc/update_freezing_point()
	var/freezable_volume = 0
	var/weighted_point = 0
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		if(isnull(reagent.freezing_point))
			continue
		freezable_volume += reagent.volume
		weighted_point += reagent.freezing_point * reagent.volume
	freezing_point = freezable_volume ? weighted_point / freezable_volume : T0C
	color = mix_color_from_reagents(reagents.reagent_list)

/// Wciąga do środka postacie i luźne przedmioty z kafla
/obj/structure/liquid_ice_block/proc/trap_contents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM as anything in T)
		if(AM == src || AM.anchored || iseffect(AM) || isobserver(AM))
			continue
		if(isliving(AM))
			var/mob/living/L = AM
			L.forceMove(src)
			ADD_TRAIT(L, TRAIT_IMMOBILIZED, REF(src))
			ADD_TRAIT(L, TRAIT_HANDS_BLOCKED, REF(src))
			to_chat(L, "<span class='userdanger'>Ciecz wokół ciebie zamarza i więzi cię w bryle lodu! Opieraj się (resist), żeby się wybić.</span>")
			continue
		if(isitem(AM))
			AM.forceMove(src)

/obj/structure/liquid_ice_block/proc/release_contents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM as anything in contents)
		if(isliving(AM))
			var/mob/living/L = AM
			REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, REF(src))
			REMOVE_TRAIT(L, TRAIT_HANDS_BLOCKED, REF(src))
		AM.forceMove(T)

/obj/structure/liquid_ice_block/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		REMOVE_TRAIT(gone, TRAIT_IMMOBILIZED, REF(src))
		REMOVE_TRAIT(gone, TRAIT_HANDS_BLOCKED, REF(src))

/obj/structure/liquid_ice_block/examine(mob/user)
	. = ..()
	var/list/trapped = list()
	for(var/mob/living/L in contents)
		trapped += "[L]"
	if(length(trapped))
		. += "<span class='warning'>W środku jest uwięzion[length(trapped) > 1 ? "e" : "a"] [english_list(trapped)]!</span>"
	. += "<span class='notice'>Można go stopić <b>spawarką</b> albo rozbić.</span>"

/obj/structure/liquid_ice_block/process(delta_time)
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	// Blok powoli przyjmuje temperaturę powietrza, a uwięzieni przyjmują temperaturę bloku
	var/air_temperature = T.GetTemperature()
	reagents.chem_temp += (air_temperature - reagents.chem_temp) * 0.1 * delta_time
	for(var/mob/living/L in contents)
		chill_trapped(L, delta_time)
	if(reagents.chem_temp > freezing_point + 1)
		melt()

/obj/structure/liquid_ice_block/proc/chill_trapped(mob/living/L, delta_time)
	if(L.bodytemperature <= reagents.chem_temp)
		return
	var/protection = 0
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		protection = H.get_cold_protection(reagents.chem_temp)
	L.adjust_bodytemperature(max((reagents.chem_temp - L.bodytemperature) * 0.05 * delta_time * (1 - protection), BODYTEMP_COOLING_MAX))

/obj/structure/liquid_ice_block/proc/melt()
	visible_message("<span class='notice'>[src] topnieje!</span>")
	qdel(src)

/obj/structure/liquid_ice_block/fire_act(exposed_temperature, exposed_volume)
	reagents.chem_temp = max(reagents.chem_temp, exposed_temperature)
	return ..()

/obj/structure/liquid_ice_block/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount = 0))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz topić [src]...</span>")
	if(I.use_tool(src, user, 3 SECONDS, volume = 50))
		melt()
	return TRUE

/obj/structure/liquid_ice_block/container_resist(mob/living/user)
	if(user in escaping)
		return
	escaping += user
	to_chat(user, "<span class='notice'>Zaczynasz obijać lód od środka...</span>")
	visible_message("<span class='warning'>[src] trzeszczy, ktoś w środku próbuje się wydostać!</span>")
	if(do_after(user, LIQUID_ICE_BLOCK_ESCAPE_TIME, needhand = FALSE, target = src))
		if(!QDELETED(src) && (user in contents))
			visible_message("<span class='danger'>[user] wybija się z [src]!</span>")
			deconstruct(FALSE)
	if(!QDELETED(src))
		escaping -= user

/obj/structure/liquid_ice_block/deconstruct(disassembled = TRUE)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, TRUE)
	qdel(src)

// Zimno w próżni (wariant A): auxmos po gwałtownej dekompresji czyści gaz, ale zostawia temperaturę (Mixture::clear),
// więc odessany kafel miałby dalej ~293 K. Ustawiamy TCMB; po ponownym napełnieniu temperatura wraca sama,
// bo pusta mieszanina nie ma pojemności cieplnej. Nadpisania podłogi technicznej i reaktorowej w LINDA_turf_tile.dm
// wracają bez ..(), więc nadpisujemy wszystkie trzy.
/turf/open/floor/handle_decompression_floor_rip(sum)
	. = ..()
	chill_after_decompression()

/turf/open/floor/plating/handle_decompression_floor_rip(sum)
	. = ..()
	chill_after_decompression()

/turf/open/floor/engine/handle_decompression_floor_rip(sum)
	. = ..()
	chill_after_decompression()

/turf/open/proc/chill_after_decompression()
	if(air && !air.total_moles())
		air.set_temperature(TCMB)
