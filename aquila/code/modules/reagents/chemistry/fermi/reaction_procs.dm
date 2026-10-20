// Procedury przepisów z fermichemu tg (tgstation@b3949ec362, code/modules/reagents/chemistry/recipes.dm).
// Nasze on_reaction() ma dalej dwa argumenty (holder, created_volume), reszta sygnatur jak w tg.

/**
 * Checks if this reaction can occur. Extra conditions on top of reagents, temperature and pH.
 */
/datum/chemical_reaction/proc/pre_reaction_other_checks(datum/reagents/holder)
	return TRUE

/**
 * Stuff that occurs in the middle of a reaction
 * Only procs DURING a reaction
 * If reaction_flags & REACTION_INSTANT then this isn't called
 * returning END_REACTION will END the reaction
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * reaction - the equilibrium reaction holder that is reaction is processed within - use this to edit delta_t and delta_ph
 * * delta_t - how close to the optimal temperature the step is (0-1)
 * * delta_ph - how close to the optimal pH the step is (0-1)
 * * step_reaction_vol - how much product the step aims to create
 */
/datum/chemical_reaction/proc/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	return

/**
 * Stuff that should happen at the end of the reaction. Presently only REACTION_CLEAR_INVERSE is respected here
 * You should be calling ..() if you're writing a child function of this proc otherwise purity methods won't work correctly
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * reaction - the equilibrium that just ended
 * * react_vol - volume created across the whole reaction
 */
/datum/chemical_reaction/proc/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	if(!(reaction_flags & REACTION_CLEAR_INVERSE))
		return

	var/list/inverse_data = list()
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(!results[reagent.type] || !reagent.inverse_chem || reagent.purity == 1 || reagent.purity > reagent.inverse_chem_val)
			continue

		inverse_data += reagent.inverse_chem
		inverse_data += reagent.volume
		inverse_data += reagent.get_inverse_purity(reagent.purity)
		reagent.volume = 0

	holder.update_total()

	var/cached_temp = holder.chem_temp
	while(inverse_data.len)
		holder.add_reagent(popleft(inverse_data), popleft(inverse_data), reagtemp = cached_temp, added_purity = popleft(inverse_data))

/**
 * Occurs when a reation is overheated (i.e. past its overheat_temp)
 * Will be called every tick in the reaction that it is overheated
 * If you want this to be a once only proc (i.e. the reaction is stopped after) set equilibrium.to_delete = TRUE
 * By default the parent proc will reduce the final yield slightly. If you don't want that don't add ..()
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * equilibrium - the equilibrium datum that contains the equilibrium reaction properties and methods
 * * step_volume_added - how much product (across all products) was added for this single step
 */
/datum/chemical_reaction/proc/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(!results[reagent.type])
			continue
		reagent.volume *= 0.98 //Slowly lower yield per tick
	holder.update_total()

/**
 * Occurs when a reation is too impure (i.e. it's below purity_min)
 * Will be called every tick in the reaction that it is too impure
 * By default the parent proc will reduce the purity of all reagents involved in the reaction in the beaker slightly. If you don't want that don't add ..()
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * equilibrium - the equilibrium datum that contains the equilibrium reaction properties and methods
 * * step_volume_added - how much product (across all products) was added for this single step
 */
/datum/chemical_reaction/proc/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	var/list/affected_list = results + required_reagents
	for(var/_reagent in affected_list)
		var/datum/reagent/reagent = holder.has_reagent(_reagent)
		if(!reagent)
			continue
		reagent.purity = clamp((reagent.purity - 0.01), 0, 1) //slowly reduce purity of reagents

//////////////////Generic explosions/failures////////////////////
// It is HIGHLY, HIGHLY recomended that you consume all/a good volume of the reagents/products in an explosion - because it will just keep going forever until the reaction stops

/**
 * The same method that pyrotechnic reagents used before
 * Any recipe can call it and define their own method
 * WILL REMOVE ALL REAGENTS
 *
 * arguments:
 * * holder - the reagents datum that it is being used on
 * * volume - the volume of reacting elements
 * * modifier - a flat additive numeric to the size of the explosion - set this if you want a minimum range
 * * strengthdiv - the divisional factor of the explosion, a larger number means a smaller range
 * * clear_mob_reagents - should our mob be purged of their reagents?
 */
/proc/reagent_explode(datum/reagents/holder, volume, modifier = 0, strengthdiv = 10, clear_mob_reagents = FALSE)
	if(QDELETED(holder) || !holder.my_atom)
		return
	var/power = modifier + round(volume / strengthdiv, 1)
	if(power > 0)
		var/turf/our_turf = get_turf(holder.my_atom)
		var/inside_msg
		if(ismob(holder.my_atom))
			var/mob/owner = holder.my_atom
			inside_msg = " inside [ADMIN_LOOKUPFLW(owner)]"
		var/lastkey = holder.my_atom.fingerprintslast
		var/touch_msg = "N/A"
		if(lastkey)
			var/mob/toucher = get_mob_by_ckey(lastkey)
			touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
		if(!istype(holder.my_atom, /obj/machinery/plumbing)) //excludes standard plumbing equipment from spamming admins with this shit
			message_admins("Reagent explosion reaction occurred at [ADMIN_VERBOSEJMP(our_turf)][inside_msg]. Last Fingerprint: [touch_msg].")
		log_game("Reagent explosion reaction occurred at [AREACOORD(our_turf)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
		var/datum/effect_system/reagents_explosion/explosion_system = new
		explosion_system.set_up(power, our_turf, 0, 0)
		explosion_system.start()
	if(!ismob(holder.my_atom) || clear_mob_reagents)
		holder.clear_reagents()

/// Creates a flash effect only - less expensive than explode()
/datum/chemical_reaction/proc/explode_flash(datum/reagents/holder, datum/equilibrium/equilibrium, range = 2, length = 25)
	var/turf/location = get_turf(holder.my_atom)
	for(var/mob/living/living_mob in viewers(range, location))
		living_mob.flash_act()
	holder.my_atom.visible_message("<span class='warning'>[holder.my_atom] nagle błyska jasnym światłem!</span>")

/// Deafens those in range causing ear damage and muting sound
/datum/chemical_reaction/proc/explode_deafen(datum/reagents/holder, datum/equilibrium/equilibrium, power = 3, stun = 20, range = 2)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, TRUE)
	for(var/mob/living/carbon/carbon in get_hearers_in_view(range, location))
		carbon.soundbang_act(1, stun, power)

/// Spews out the inverse of the chems in the beaker of the products/reactants only
/datum/chemical_reaction/proc/explode_invert_smoke(datum/reagents/holder, datum/equilibrium/equilibrium, force_range = 0, clear_products = TRUE, clear_reactants = TRUE, accept_impure = TRUE)
	var/datum/reagents/invert_reagents = new (2100, NO_REACT)
	var/sum_volume = 0
	invert_reagents.my_atom = holder.my_atom //Give the gas a fingerprint
	for(var/datum/reagent/reagent as anything in holder.reagent_list) //make gas for reagents, has to be done this way, otherwise it never stops Exploding
		if(!(reagent.type in required_reagents) || !(reagent.type in results))
			continue
		if(reagent.inverse_chem)
			invert_reagents.add_reagent(reagent.inverse_chem, reagent.volume, no_react = TRUE)
			holder.remove_reagent(reagent.type, reagent.volume)
			continue
		invert_reagents.add_reagent(reagent.type, reagent.volume, added_purity = reagent.purity, no_react = TRUE)
		sum_volume += reagent.volume
		holder.remove_reagent(reagent.type, reagent.volume)
	if(!force_range)
		force_range = (sum_volume / 6) + 3
	if(length(invert_reagents.reagent_list))
		do_fermi_smoke(invert_reagents, holder.my_atom, force_range)
	holder.my_atom.audible_message("<span class='warning'>[holder.my_atom] nagle wybucha, rozpylając odczynniki w powietrze!</span>")
	qdel(invert_reagents)
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

/// Spews out the corrisponding reactions reagents (products/required) of the beaker in a smokecloud. Doesn't spew catalysts
/datum/chemical_reaction/proc/explode_smoke(datum/reagents/holder, datum/equilibrium/equilibrium, force_range = 0, clear_products = TRUE, clear_reactants = TRUE)
	var/datum/reagents/smoke_reagents = new /datum/reagents(2100, NO_REACT)
	smoke_reagents.my_atom = holder.my_atom //fingerprint
	var/sum_volume = 0
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if((reagent.type in required_reagents) || (reagent.type in results))
			sum_volume += reagent.volume
			smoke_reagents.add_reagent(reagent.type, reagent.volume, added_purity = reagent.purity, no_react = TRUE)
			holder.remove_reagent(reagent.type, reagent.volume)
	if(!force_range)
		force_range = (sum_volume / 6) + 3
	if(length(smoke_reagents.reagent_list))
		do_fermi_smoke(smoke_reagents, holder.my_atom, force_range)
	holder.my_atom.audible_message("<span class='warning'>[holder.my_atom] nagle wybucha, rozpylając odczynniki w powietrze!</span>")
	qdel(smoke_reagents)
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

/// Smoke helper for the explode_* procs, in tg this is do_chem_smoke()
/proc/do_fermi_smoke(datum/reagents/carry, atom/location, range)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(carry, round(range), location, silent = TRUE)
	smoke.start()

/// Pushes everything out, and damages mobs
/datum/chemical_reaction/proc/explode_shockwave(datum/reagents/holder, datum/equilibrium/equilibrium, range = 3, damage = 5, sound_and_text = TRUE, implosion = FALSE)
	var/turf/this_turf = get_turf(holder.my_atom)
	if(sound_and_text)
		holder.my_atom.audible_message("<span class='warning'>[holder.my_atom] nagle wybucha, a fala uderzeniowa rozchodzi się w powietrzu!</span>")
		playsound(this_turf, 'aquila/sound/effects/chemistry/shockwave_explosion.ogg', 80, TRUE)
	for(var/atom/movable/movey in orange(range, this_turf))
		if(isliving(movey) && damage)
			var/mob/living/live = movey
			live.apply_damage(damage)//Since this can be called multiple times
		if(movey.anchored)
			continue
		if(iseffect(movey) || iscameramob(movey) || isdead(movey))
			continue
		if(implosion)
			var/distance = get_dist(movey, this_turf)
			var/moving_power = max(4 - distance, 1)
			var/turf/target = get_turf(holder.my_atom)
			movey.throw_at(target, moving_power, 1)
		else
			var/distance = get_dist(movey, this_turf)
			var/moving_power = max(3 - distance, 1)//Make sure we're thrown out of range of the next one
			var/atom/throw_target = get_edge_target_turf(movey, get_dir(movey, get_step_away(movey, this_turf)))
			movey.throw_at(throw_target, moving_power, 1)

/// Calls the default explosion subsystem handler to explode with fire (random firespots and noise)
/datum/chemical_reaction/proc/explode_fire(datum/reagents/holder, datum/equilibrium/equilibrium, range = 3)
	explosion(holder.my_atom, 0, 0, 0, 0, flame_range = range)
	holder.my_atom.audible_message("<span class='warning'>[holder.my_atom] nagle buchają płomienie!</span>")

/**
 * Creates a square of fire in a fire_range radius,
 * fire_range = 0 will be on the exact spot of the holder,
 * fire_range = 1 or more will be additional tiles around the holder. Every tile will be heated this way.
 */
/datum/chemical_reaction/proc/explode_fire_square(datum/reagents/holder, datum/equilibrium/equilibrium, fire_range = 1)
	var/turf/location = get_turf(holder.my_atom)
	if(fire_range == 0)
		new /obj/effect/hotspot(location)
		return
	for(var/turf/turf as anything in RANGE_TURFS(fire_range, location))
		new /obj/effect/hotspot(turf)

/**
 * Freezes in a circle around the holder location
 * Arguments:
 * * temp - the temperature to set the air to
 * * radius - the range of the effect
 * * freeze_duration - how long the icey spots remain for
 * * snowball_chance - the chance to spawn a snowball on a turf
 */
/datum/chemical_reaction/proc/freeze_radius(datum/reagents/holder, datum/equilibrium/equilibrium, temp, radius = 2, freeze_duration = 50 SECONDS, snowball_chance = 0)
	var/turf/center = get_turf(holder.my_atom)
	for(var/turf/open/open_turf in RANGE_TURFS(radius, center))
		open_turf.MakeSlippery(TURF_WET_PERMAFROST, freeze_duration, freeze_duration, freeze_duration)
		if(prob(snowball_chance))
			new /obj/item/toy/snowball(open_turf)

/// Clears the beaker of the reagents only. If volume is not set, it will remove all of the reactant
/datum/chemical_reaction/proc/clear_reactants(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	for(var/reagent in required_reagents)
		holder.remove_reagent(reagent, volume)

/// Clears the beaker of the product only
/datum/chemical_reaction/proc/clear_products(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	for(var/reagent in results)
		holder.remove_reagent(reagent, volume)

/// Clears the beaker of ALL reagents inside
/datum/chemical_reaction/proc/clear_reagents(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	if(!volume)
		volume = holder.total_volume
	holder.remove_all(volume)

/**
 * "Attacks" all mobs within range with a specified reagent
 * Will be blocked if they're wearing proper protective equipment unless disabled
 */
/datum/chemical_reaction/proc/explode_attack_chem(datum/reagents/holder, datum/equilibrium/equilibrium, reagent, vol, range = 3, ignore_mask = FALSE, ignore_eyes = FALSE)
	if(istype(reagent, /datum/reagent))
		var/datum/reagent/temp_reagent = reagent
		reagent = temp_reagent.type
	for(var/mob/living/carbon/target in orange(range, get_turf(holder.my_atom)))
		if(target.has_smoke_protection() && !ignore_mask)
			continue
		if(target.get_eye_protection() && !ignore_eyes)
			continue
		to_chat(target, "<span class='warning'>[holder.my_atom] wyrzuca na ciebie część swojej zawartości!</span>")
		target.reagents.add_reagent(reagent, vol)

/**
 * Applies a cooldown to the reaction
 * Returns false if time is below required, true if it's above required
 * Time is kept in eqilibrium data
 *
 * Arguments:
 * * seconds - the amount of time in server seconds to delay between true returns, will ceiling to the nearest 0.25
 * * id - a string phrase so that multiple cooldowns can be applied if needed
 * * initial_delay - The number of seconds of delay to add on creation
 */
/datum/chemical_reaction/proc/off_cooldown(datum/reagents/holder, datum/equilibrium/equilibrium, seconds = 1, id = "default", initial_delay = 0)
	id = "[id]_cooldown"
	if(isnull(equilibrium.data[id]))
		equilibrium.data[id] = 0
		if(initial_delay)
			equilibrium.data[id] += initial_delay
			return FALSE
		return TRUE//first time we know we can go
	equilibrium.data[id] += equilibrium.time_deficit ? 0.5 : 0.25 //sync to lag compensator
	if(equilibrium.data[id] >= seconds)
		equilibrium.data[id] = 0
		return TRUE
	return FALSE
