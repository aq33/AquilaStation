// AQUILA - Ciecze na turfie, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_turf.dm)
// Nowe u nas: rozlanie poniżej LIQUID_SPILL_THRESHOLD robi zwykły rozprysk (plama krwi, mokra podłoga), a małe
// rozlania na jednym kafelku się sumują i po przekroczeniu progu zamieniają w kałużę.

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

/// Zwraca listę typ => ilość z reagentów, bez reagentów, które nie mogą być kałużą
/proc/liquid_compile_reagents(datum/reagents/giver, multiplier = 1)
	var/list/compiled_list = list()
	for(var/datum/reagent/R as anything in giver.reagent_list)
		if(!(R.type in GLOB.liquid_blacklist))
			compiled_list[R.type] = R.volume * multiplier
	return compiled_list

/turf/proc/add_liquid_from_reagents(datum/reagents/giver, no_react = FALSE, chem_temp, amount)
	if(!giver?.total_volume)
		return
	var/multiplier = amount ? amount / giver.total_volume : 1
	var/list/compiled_list = liquid_compile_reagents(giver, multiplier)
	if(!length(compiled_list)) //No reagents to add, don't bother going further
		return
	if(isnull(chem_temp))
		chem_temp = giver.chem_temp
	if(QDELETED(liquids))
		liquids = new(src)
	if(QDELETED(liquids))
		liquids = null
		return
	liquids.liquid_group.add_reagents(liquids, compiled_list, chem_temp)

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
 * Rozlanie reagentów na kafelek (pojemniki, wybuchy chemiczne, eventy).
 *
 * Kafelek z kałużą: dolewa do niej.
 * Mniej niż LIQUID_SPILL_THRESHOLD: zwykła reakcja z podłogą (plama, mokra podłoga), a ilość trafia do pamięci małych rozlań.
 * Gdy suma rozlań przekroczy próg: całość zamienia się w kałużę.
 *
 * Nie zużywa reagentów z giver (tak jak reaction()), wołający sam je czyści.
 */
/turf/proc/spill_reagents(datum/reagents/giver, multiplier = 1)
	return

/turf/open/spill_reagents(datum/reagents/giver, multiplier = 1)
	if(!giver?.total_volume)
		return
	if(!QDELETED(liquids))
		add_liquid_from_reagents(giver, amount = giver.total_volume * multiplier)
		return
	if(isgroundlessturf(src))
		giver.reaction(src, TOUCH, multiplier)
		return

	var/spilled = giver.total_volume * multiplier
	if(world.time - liquid_residue_time > LIQUID_RESIDUE_DECAY_TIME)
		clear_liquid_residue()
	liquid_residue_time = world.time
	var/residue_volume = liquid_residue?.total_volume || 0

	if(spilled + residue_volume < LIQUID_SPILL_THRESHOLD)
		// Mały rozprysk jak dotąd, a ilość zostaje w pamięci kafelka
		giver.reaction(src, TOUCH, multiplier)
		remember_liquid_residue(giver, multiplier)
		return

	// Dość, żeby zrobić kałużę: najpierw stare rozlania, potem nowe
	if(residue_volume)
		var/datum/reagents/old_residue = liquid_residue
		liquid_residue = null
		add_liquid_from_reagents(old_residue)
		qdel(old_residue)
	add_liquid_from_reagents(giver, amount = spilled)
	if(!QDELETED(liquids))
		liquids.liquid_group.expose_members_turf(liquids)

/turf/open/proc/remember_liquid_residue(datum/reagents/giver, multiplier)
	if(!liquid_residue)
		liquid_residue = new(LIQUID_SPILL_THRESHOLD * 2, NO_REACT)
		RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_residue_cleaned), override = TRUE)
	for(var/datum/reagent/R as anything in giver.reagent_list)
		if(R.type in GLOB.liquid_blacklist)
			continue
		liquid_residue.add_reagent(R.type, R.volume * multiplier, reagtemp = giver.chem_temp, no_react = TRUE)

/turf/proc/clear_liquid_residue()
	if(!liquid_residue)
		return
	QDEL_NULL(liquid_residue)
	UnregisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT)

/// Mop, mydło i inne czyszczenie zabierają też pamięć małych rozlań
/turf/proc/on_residue_cleaned(datum/source, clean_types)
	SIGNAL_HANDLER
	clear_liquid_residue()

/// Zamykane drzwi wypychają ciecz ze swojego kafelka (z Monke: door.dm i airlock.dm)
/turf/proc/liquids_push_out_by_door()
	if(QDELETED(liquids))
		return
	var/datum/liquid_group/turfs_group = liquids.liquid_group
	if(!QDELETED(turfs_group))
		turfs_group.remove_from_group(src)
		if(!QDELETED(turfs_group))
			turfs_group.try_split(src)
			for(var/dir in GLOB.cardinals)
				var/turf/open/direction_turf = get_step(src, dir)
				if(!isopenturf(direction_turf) || QDELETED(direction_turf.liquids))
					continue
				turfs_group.check_edges(direction_turf)
	QDEL_NULL(liquids)

/// Wołane przez ChangeTurf przed podmianą: ciecz zostaje na nowym turfie albo znika na ścianie i w kosmosie
/turf/proc/liquids_before_change(path)
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
