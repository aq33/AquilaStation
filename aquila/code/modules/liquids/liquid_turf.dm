// AQUILA - Ciecze na turfie, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_turf.dm)
// Nowe u nas: każde rozlanie raz reaguje z podłogą (woda gasi, kwas trawi, plazma paruje). Poniżej LIQUID_SPILL_THRESHOLD
// zostaje sam rozprysk, a małe rozlania na jednym kafelku się sumują i po przekroczeniu progu zamieniają w kałużę.
// Reagenty z GLOB.liquid_turf_converting zamieniają się przy reakcji w coś innego, więc do kałuży nie trafiają.
// Kałuże zachowują dane reagentów (DNA krwi, materiał metalgenu) i czystość.

/turf
	var/obj/effect/abstract/liquid_turf/liquids
	var/liquid_height = 0
	var/turf_height = 0
	/// AQUILA - suma małych rozlań na kafelku (bez kałuży), z której robi się kałuża po przekroczeniu progu
	var/datum/reagents/liquid_residue
	/// AQUILA - kiedy ostatnio coś tu rozlano (pamięć rozlań przepada po LIQUID_RESIDUE_DECAY_TIME)
	var/liquid_residue_time = 0

/turf/proc/reasses_liquids()
	if(!liquids)
		return
	if(!liquids.liquid_group)
		liquids.liquid_group = new(1, liquids)

/// Czy reagent może trafić do kałuży (skip_converting: także bez tych, które przy rozlaniu zamieniają się w coś innego)
/proc/liquid_can_pool(reagent_type, skip_converting = FALSE)
	if(reagent_type in GLOB.liquid_blacklist)
		return FALSE
	if(skip_converting && GLOB.liquid_turf_converting[reagent_type])
		return FALSE
	return TRUE

/// Ile z reagentów może trafić do kałuży
/proc/liquid_poolable_volume(datum/reagents/giver, skip_converting = FALSE)
	. = 0
	for(var/datum/reagent/R as anything in giver?.reagent_list)
		if(liquid_can_pool(R.type, skip_converting))
			. += R.volume

/**
 * Kopiuje reagenty, które mogą być kałużą, razem z danymi (DNA krwi, materiał metalgenu), czystością i pH.
 * Nie zużywa reagentów z giver i nie wywołuje reakcji. Zwraca skopiowaną ilość.
 */
/proc/liquid_copy_reagents(datum/reagents/giver, datum/reagents/target, multiplier = 1, skip_converting = FALSE)
	. = 0
	if(!giver || !target || multiplier <= 0)
		return
	for(var/datum/reagent/R as anything in giver.reagent_list)
		if(!liquid_can_pool(R.type, skip_converting))
			continue
		var/amount = R.volume * multiplier
		if(amount <= 0)
			continue
		target.add_reagent(R.type, amount, giver.copy_data(R), giver.chem_temp, no_react = TRUE, added_purity = R.purity, added_ph = R.ph)
		. += amount

/// Wlewa reagenty do kałuży na kafelku (tworzy ją w razie potrzeby). amount to ilość z całego giver, domyślnie wszystko.
/turf/proc/add_liquid_from_reagents(datum/reagents/giver, no_react = FALSE, chem_temp, amount, skip_converting = FALSE)
	if(!giver?.total_volume)
		return
	var/multiplier = amount ? amount / giver.total_volume : 1
	if(liquid_poolable_volume(giver, skip_converting) * multiplier <= 0) //No reagents to add, don't bother going further
		return
	if(QDELETED(liquids))
		liquids = new(src)
	if(QDELETED(liquids))
		liquids = null
		return
	liquids.liquid_group.add_reagents_from(giver, multiplier, skip_converting)

//More efficient than add_liquid for multiples
/turf/proc/add_liquid_list(reagent_list, no_react = FALSE, chem_temp)
	if(liquids && !liquids.liquid_group)
		qdel(liquids)
		return

	if(QDELETED(liquids))
		liquids = new(src)
	if(QDELETED(liquids))
		liquids = null
		return
	liquids.liquid_group.add_reagents(liquids, reagent_list, chem_temp)
	//Expose turf
	liquids.liquid_group.expose_members_turf(liquids)

/turf/proc/add_liquid(reagent, amount, no_react = FALSE, chem_temp = T20C)
	if(reagent in GLOB.liquid_blacklist)
		return
	if(QDELETED(liquids))
		liquids = new(src)
	if(QDELETED(liquids))
		liquids = null
		return

	liquids.liquid_group.add_reagent(liquids, reagent, amount, chem_temp)
	//Expose turf
	liquids.liquid_group.expose_members_turf(liquids)

/**
 * Rozlanie reagentów na kafelek (pojemniki, mocz, przelana toaleta).
 *
 * Zawsze jedna reakcja z podłogą, jak przed cieczami (woda gasi ogień, kwas trawi, plazma paruje).
 * Kafelek z kałużą: reszta dolewa się do niej.
 * Mniej niż LIQUID_SPILL_THRESHOLD: sam rozprysk, a ilość trafia do pamięci małych rozlań.
 * Gdy suma rozlań przekroczy próg: całość zamienia się w kałużę.
 * Reagenty z GLOB.liquid_turf_converting zamieniają się przy reakcji, więc nie idą ani do kałuży, ani do pamięci.
 * Mobów na kafelku rozlanie nie polewa (tak jak dawniej chlust w podłogę); dotyka ich dopiero kałuża, w którą wejdą.
 *
 * Nie zużywa reagentów z giver (tak jak reaction()), wołający sam je czyści.
 */
/turf/proc/spill_reagents(datum/reagents/giver, multiplier = 1)
	return

/turf/open/spill_reagents(datum/reagents/giver, multiplier = 1)
	if(!giver?.total_volume)
		return
	giver.reaction(src, TOUCH, multiplier)
	if(isgroundlessturf(src))
		return
	pool_reagents(giver, multiplier)

/**
 * Część rozlania bez reakcji z podłogą: do kałuży albo do pamięci małych rozlań.
 * Woła ją spill_reagents po reakcji i rozprysk z granatu (chem_splash już zareagował z kafelkami).
 */
/turf/open/proc/pool_reagents(datum/reagents/giver, multiplier = 1)
	var/spilled = liquid_poolable_volume(giver, TRUE) * multiplier
	if(spilled <= 0)
		return
	if(!QDELETED(liquids))
		add_liquid_from_reagents(giver, amount = giver.total_volume * multiplier, skip_converting = TRUE)
		MakeDry(TURF_WET_WATER, TRUE) // mokrą podłogę z reakcji wody zastępuje kałuża
		return

	if(world.time - liquid_residue_time > LIQUID_RESIDUE_DECAY_TIME)
		clear_liquid_residue()
	liquid_residue_time = world.time
	var/residue_volume = liquid_residue?.total_volume || 0

	if(spilled + residue_volume < LIQUID_SPILL_THRESHOLD)
		create_liquid_residue()
		liquid_copy_reagents(giver, liquid_residue, multiplier, TRUE)
		return

	// Dość, żeby zrobić kałużę: najpierw stare rozlania, potem nowe
	flush_liquid_residue()
	add_liquid_from_reagents(giver, amount = giver.total_volume * multiplier, skip_converting = TRUE)
	MakeDry(TURF_WET_WATER, TRUE)

/turf/open/proc/create_liquid_residue()
	if(liquid_residue)
		return
	liquid_residue = new(LIQUID_SPILL_THRESHOLD * 2, NO_REACT)
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_residue_cleaned), override = TRUE)

/// Zamienia pamięć małych rozlań w kałużę
/turf/open/proc/flush_liquid_residue()
	if(!liquid_residue)
		return
	if(liquid_residue.total_volume)
		add_liquid_from_reagents(liquid_residue)
	clear_liquid_residue()

/**
 * Dolewa ciecz bez rozprysku i reakcji z podłogą (krew z krwawienia): plamy robi wołający sam.
 * Na kafelku z kałużą dolewa do niej, inaczej dodaje do pamięci małych rozlań, a gdy razem z pamięcią
 * przekroczy LIQUID_SPILL_THRESHOLD, pamięć i nowa ilość robią kałużę.
 */
/turf/proc/pool_liquid(reagent_type, amount, chem_temp = T20C, list/data)
	return

/turf/open/pool_liquid(reagent_type, amount, chem_temp = T20C, list/data)
	if(amount <= 0 || !liquid_can_pool(reagent_type, TRUE) || isgroundlessturf(src))
		return
	var/datum/reagents/pooled = new(amount + 1, NO_REACT)
	pooled.add_reagent(reagent_type, amount, data, chem_temp, no_react = TRUE)
	pool_reagents(pooled)
	qdel(pooled)

/turf/proc/clear_liquid_residue()
	if(!liquid_residue)
		return
	QDEL_NULL(liquid_residue)
	UnregisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT)

/// Mop, mydło i inne czyszczenie zabierają też pamięć małych rozlań
/turf/proc/on_residue_cleaned(datum/source, clean_types)
	SIGNAL_HANDLER
	clear_liquid_residue()

/**
 * Rozprysk z granatu albo rozbitego zbiornika (chem_splash): pętla rozprysku już zareagowała z kafelkami i mobami,
 * więc tu tylko reszta trafia do kałuży albo pamięci rozlań, najwyżej LIQUID_SPLASH_PUDDLE_MAX.
 * threatscale granatu dokłada reagenty ponad zawartość (chem_splash), więc kałuża liczy się od zawartości bez niego.
 */
/turf/proc/pool_splash_remainder(datum/reagents/splash_holder, threatscale = 1)
	return

/turf/open/pool_splash_remainder(datum/reagents/splash_holder, threatscale = 1)
	if(!splash_holder?.total_volume || isgroundlessturf(src))
		return
	var/amount = min(splash_holder.total_volume / max(threatscale, 1), LIQUID_SPLASH_PUDDLE_MAX)
	pool_reagents(splash_holder, amount / splash_holder.total_volume)

/// Zamykane drzwi wypychają ciecz ze swojego kafelka (z Monke: door.dm i airlock.dm)
/turf/proc/liquids_push_out_by_door()
	if(QDELETED(liquids))
		return
	var/datum/liquid_group/turfs_group = liquids.liquid_group
	if(QDELETED(turfs_group))
		QDEL_NULL(liquids)
		return
	turfs_group.remove_from_group(src)
	// Najpierw kasujemy ciecz z kafla drzwi: check_edges pomija kierunki do kafli z cieczą,
	// a sąsiedzi muszą dostać krawędź w stronę drzwi, żeby ciecz wróciła po ich otwarciu
	QDEL_NULL(liquids)
	if(QDELETED(turfs_group))
		return
	turfs_group.try_split(src)
	for(var/dir in GLOB.cardinals)
		var/turf/open/direction_turf = get_step(src, dir)
		if(!isopenturf(direction_turf) || QDELETED(direction_turf.liquids) || QDELETED(direction_turf.liquids.liquid_group))
			continue
		direction_turf.liquids.liquid_group.check_edges(direction_turf)

/// Wołane przez ChangeTurf przed podmianą: ciecz zostaje na nowym turfie albo znika na ścianie i w kosmosie
/turf/proc/liquids_before_change(path)
	clear_liquid_residue() // pamięci małych rozlań nowy turf nie dostaje
	if(QDELETED(liquids))
		return null
	if(ispath(path, /turf/closed) || is_type_in_typecache(path, GLOB.turfs_without_ground))
		QDEL_NULL(liquids)
		return null
	return liquids

/turf/proc/liquids_after_change(obj/effect/abstract/liquid_turf/old_liquids)
	if(QDELETED(old_liquids))
		return
	liquids = old_liquids
	old_liquids.my_turf = src
