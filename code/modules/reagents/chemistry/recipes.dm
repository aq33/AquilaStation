/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/required_container = null // the exact container path required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	var/is_cold_recipe = 0 // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/mix_message = "Roztwór zaczyna bulgotać." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

	// AQ EDIT START - fermichem z tg, opis: aquila/code/modules/reagents/chemistry/fermi_readme.md
	/// Required temperature for the reaction to begin, for fermimechanics it defines the lower area of bell curve for determining heat based rate reactions, aka the minimum
	var/required_temp = 100
	/// Upper end for above (i.e. the end of the curve section defined by temp_exponent_factor)
	var/optimal_temp = 500
	/// Temperature at which reaction explodes - If any reaction is this hot, it explodes!
	var/overheat_temp = 900
	/// Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/optimal_ph_min = 5
	/// Higest value for above
	var/optimal_ph_max = 9
	/// How far out pH wil react, giving impurity place (Exponential phase)
	var/determin_ph_range = 4
	/// How sharp the temperature exponential curve is (to the power of value)
	var/temp_exponent_factor = 2
	/// How sharp the pH exponential curve is (to the power of value)
	var/ph_exponent_factor = 2
	/// How much the temperature changes per unit of chem used. without REACTION_HEAT_ARBITARY flag the rate of change depends on the holder heat capacity else results are more accurate
	var/thermic_constant = 0
	/// pH change per 1u reaction
	var/H_ion_release = 0.01
	/// Optimal/max rate possible if all conditions are perfect
	var/rate_up_lim = 30
	/// If purity is below 0.15, it calls overly_impure() too. Set to 0 to disable this.
	var/purity_min = 0.15
	/// bitflags for clear conversions; see aquila/code/__DEFINES/fermichem.dm
	var/reaction_flags = NONE
	/// A bitflag var for tagging reactions for the recipe lookup
	var/reaction_tags = NONE
	// AQ EDIT END

/**
 * Shit that happens on reaction
 * Only procs at the START of a reaction (and once for instant ones)
 * use reaction_step() for each step of a reaction
 * or reaction_finish() when the reaction stops
 *
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - how many times the recipe fits in the holder. look at 'var/list/results'.
 */
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " (<A HREF='byond://?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Ostatni odcisk palca: [(A.fingerprintslast ? A.fingerprintslast : "brak")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom)))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S
			if(random)
				S = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				S = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH,SOUTH,EAST,WEST))

///Simulates a vortex that moves nearby movable atoms towards or away from the turf T. Range also determines the strength of the effect. High values cause nearby objects to be thrown.
/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1) //Can happen twice at most. So this is fine.
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_away), X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_towards), X, T), 2)
