// Reagenty fermichemu z tg (tgstation@b3949ec362): ogólne nieczystości, bufory pH i katalizatory.
// tg liczy efekty na sekundę, nasz on_mob_life idzie co tick (2 s) - wartości przeliczone.

/**
 * Called before a reagent is moved into another holder by trans_to()/copy_to().
 * Returning TRUE stops the transfer of this reagent, the reagent is expected to handle (and remove) itself.
 * Used by the pH buffers, which are consumed instead of being added.
 */
/datum/reagent/proc/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	return FALSE

//Reagents produced by metabolising/reacting fermichems suboptimally, i.e. inverse_chems or impure_chems
//Inverse = Splitting
//Invert = Whole conversion

//Causes slight liver damage, and that's it.
/datum/reagent/impurity
	name = "Chemical Isomers"
	description = "Nieczyste izomery powstałe w nieoptymalnej reakcji. Lekko uszkadzają wątrobę."
	color = "#c8c8a0"
	taste_description = "chemiczną gorycz"
	fermi_flags = REAGENT_SNEAKYNAME
	ph = 3
	inverse_chem = null
	inverse_chem_val = 0
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	/// liver damage per tick
	var/liver_damage = 0.5

/datum/reagent/impurity/on_mob_life(mob/living/carbon/M)
	if(M.getorganslot(ORGAN_SLOT_LIVER))
		M.adjustOrganLoss(ORGAN_SLOT_LIVER, liver_damage)
	else
		M.adjustToxLoss(liver_damage * 2, FALSE) //Incase of no liver!
	..()
	return TRUE

//Basically just so people don't forget to adjust metabolization_rate
/datum/reagent/inverse
	name = "Toxic Monomers"
	description = "Odwrócone odczynniki powstają, gdy czystość odczynnika spadnie poniżej jego progu odwrócenia. Tworzą się przy spożyciu, zastępując swój odczynnik, albo w samej reakcji."
	color = "#7a1f4b"
	taste_description = "metaliczną gorycz"
	ph = 2
	fermi_flags = REAGENT_SNEAKYNAME
	inverse_chem = null
	/// how much this reagent does for tox damage per tick
	var/tox_damage = 1

/datum/reagent/inverse/on_mob_life(mob/living/carbon/M)
	if(tox_damage)
		M.adjustToxLoss(tox_damage, FALSE)
	..()
	return TRUE

//Failed chems - generally use inverse if you want to use a impure subtype for it
//technically not a impure chem, but it's here because it can only be made with a failed impure reaction
/datum/reagent/consumable/failed_reaction
	name = "Viscous Sludge"
	description = "Śmierdzący szlam, który powstaje, gdy reakcja jest zbyt nieczysta."
	nutriment_factor = -1
	quality = -1
	ph = 1.5
	taste_description = "okropny, mocno chemiczny smak"
	color = "#270d03"
	inverse_chem = null

////////////////////////////// Bufory i środki reakcyjne //////////////////////////////

/datum/reagent/reaction_agent
	name = "Reaction Agent"
	description = "Hello! I am a bugged reagent. Please report me for my crimes. Thank you!!"
	inverse_chem = null
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/reaction_agent/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	if(!target)
		return FALSE
	if(target.flags & NO_REACT)
		return FALSE
	if(target.has_reagent(/datum/reagent/stabilizing_agent))
		return FALSE
	if(!target.total_volume)
		return FALSE
	if(LAZYLEN(target.reagent_list) == 1)
		if(target.has_reagent(type)) //Allow dispensing into self
			return FALSE
	return TRUE

/// Plays the buffer sound and message on the target container
/datum/reagent/reaction_agent/proc/buffer_feedback(datum/reagents/target, message, sound = 'aquila/sound/effects/chemistry/bufferadd.ogg')
	if(!target.my_atom)
		return
	target.my_atom.audible_message(span_warning(message))
	if(sound)
		playsound(target.my_atom, sound, 50, TRUE)

/// Removes the used up part of the buffer from its own holder
/datum/reagent/reaction_agent/proc/consume_self(amount, copy_only)
	if(copy_only)
		return
	volume -= amount
	holder.update_total()

/datum/reagent/reaction_agent/acidic_buffer
	name = "Strong Acidic Buffer"
	description = "Ten odczynnik zużywa się przy dolaniu do innego i przesuwa pH roztworu w stronę kwaśnego."
	color = "#fbc314"
	ph = 0
	taste_description = "kwas"

//Consumes self on addition and shifts ph
/datum/reagent/reaction_agent/acidic_buffer/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return
	//do the ph change
	if(target.ph <= ph)
		buffer_feedback(target, "Roztwór pieni się po dodaniu buforu, bez efektu.")
	else
		target.adjust_all_reagents_ph(-(amount / target.total_volume) * BUFFER_IONIZING_STRENGTH)
		buffer_feedback(target, "Roztwór pieni się, gdy zmienia się jego pH!")
	consume_self(amount, copy_only)

/datum/reagent/reaction_agent/basic_buffer
	name = "Strong Basic Buffer"
	description = "Ten odczynnik zużywa się przy dolaniu do innego i przesuwa pH roztworu w stronę zasadowego."
	color = "#3853a4"
	ph = 14
	taste_description = "mydło"

/datum/reagent/reaction_agent/basic_buffer/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return
	if(target.ph >= ph)
		buffer_feedback(target, "Roztwór pieni się po dodaniu buforu, bez efektu.")
	else
		target.adjust_all_reagents_ph((amount / target.total_volume) * BUFFER_IONIZING_STRENGTH)
		buffer_feedback(target, "Roztwór pieni się, gdy zmienia się jego pH!")
	consume_self(amount, copy_only)

//purity testor/reaction agent prefactors

/datum/reagent/prefactor_a
	name = "Interim Product Alpha"
	description = "Prekursor testera czystości. Reaguje ze stabilną plazmą."
	color = "#bafa69"

/datum/reagent/prefactor_b
	name = "Interim Product Beta"
	description = "Prekursor przyspieszacza reakcji. Reaguje ze stabilną plazmą."
	color = "#8a3aa9"

/datum/reagent/reaction_agent/purity_tester
	name = "Purity Tester"
	description = "Ten odczynnik zużywa się przy dolaniu i gwałtownie reaguje, jeśli w zlewce jest bardzo nieczysty odczynnik."
	ph = 3
	color = "#ffffff"

/datum/reagent/reaction_agent/purity_tester/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return
	var/is_inverse = FALSE
	for(var/datum/reagent/reagent as anything in target.reagent_list)
		if(reagent.purity <= reagent.inverse_chem_val)
			is_inverse = TRUE
	if(is_inverse)
		buffer_feedback(target, "Roztwór gwałtownie bulgocze po dodaniu odczynnika!")
	else
		buffer_feedback(target, "Dodany odczynnik nie robi chyba nic szczególnego.", null)
	consume_self(amount, copy_only)

///How much the reaction speed is sped up by - for 5u added to 100u, an additional step of 1 will be done up to a max of 2x
#define SPEED_REAGENT_STRENGTH 20

/datum/reagent/reaction_agent/speed_agent
	name = "Tempomyocin"
	description = "Ten odczynnik zużywa się i przyspiesza trwającą reakcję, zmieniając jej czystość na swoją."
	ph = 10
	color = "#e61f82"

/datum/reagent/reaction_agent/speed_agent/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return FALSE
	if(!length(target.reaction_list))//you can add this reagent to a beaker with no ongoing reactions, so this prevents it from being used up.
		return FALSE
	var/used = amount
	amount /= target.reaction_list.len
	for(var/datum/equilibrium/reaction as anything in target.reaction_list)
		var/power = (amount / max(reaction.target_vol, 1)) * SPEED_REAGENT_STRENGTH
		power *= creation_purity
		power = clamp(power, 0, 2)
		reaction.react_timestep(power, creation_purity)
	consume_self(used, copy_only)

#undef SPEED_REAGENT_STRENGTH

/datum/reagent/reaction_agent/inversing_buffer
	name = "Chiral Inversing Buffer"
	description = "Ten odczynnik zużywa się i zamienia nieczyste odczynniki w ich odwrócone odpowiedniki. Ilość zależy od objętości buforu."
	ph = 7
	color = "#b60046"

/datum/reagent/reaction_agent/inversing_buffer/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return

	var/conversion_buffer = amount * 10 //Converts up to 10 units of reagent per 1 unit of inversing buffer.
	var/converted = 0
	var/list/cached_reagents = target.reagent_list.Copy()
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(!conversion_buffer)
			break
		if(reagent.inverse_chem && reagent.purity <= reagent.inverse_chem_val)
			//compute volume of reagent to be converted
			converted = min(reagent.volume, conversion_buffer)
			//remove original reagent from target
			reagent.volume -= converted
			target.update_total()
			//add new inverse reagent to target
			target.add_reagent(reagent.inverse_chem, converted, null, added_purity = reagent.get_inverse_purity(reagent.purity))
			//remove from buffer remaining
			conversion_buffer -= converted

	//audible feedback
	if(conversion_buffer < amount * 10)
		buffer_feedback(target, "Roztwór zaczyna wrzeć, a jego zawartość się odwraca!", 'aquila/sound/effects/chemistry/catalyst.ogg')
	else
		buffer_feedback(target, "Bufor syczy, bez efektu.", null)

	//return the part of the buffer that wasn't used
	var/volume_to_transfer = amount - (amount * (1 - (conversion_buffer / (amount * 10))))
	if(volume_to_transfer)
		target.add_reagent(type, volume_to_transfer, null, holder.chem_temp, added_purity = purity, added_ph = ph)
	consume_self(amount, copy_only)

////////////////////////////// Katalizatory //////////////////////////////

///These alter reaction conditions while they're in the beaker
/datum/reagent/catalyst_agent
	name = "Catalyst agent"
	inverse_chem = null
	///The typepath of the reagent they that they affect
	var/target_reagent_type
	///The minimumvolume required in the beaker for them to have an effect
	var/min_volume = 10
	///The value in which the associated type is modified
	var/modifier = 1

/datum/reagent/catalyst_agent/proc/consider_catalyst(datum/equilibrium/equilibrium)
	for(var/_product in equilibrium.reaction.results)
		if(ispath(_product, target_reagent_type))
			return TRUE
	return FALSE

/datum/reagent/catalyst_agent/speed
	name = "Speed Catalyst Agent"

/datum/reagent/catalyst_agent/speed/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.speed_mod = creation_purity * modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier
		equilibrium.time_deficit += creation_purity * (0.05 * modifier) //give the reaction a little boost too (40% faster)

/datum/reagent/catalyst_agent/ph
	name = "pH Catalyst Agent"

/datum/reagent/catalyst_agent/ph/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.h_ion_mod = ((creation_purity - 0.5) * 2) * modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier

/datum/reagent/catalyst_agent/temperature
	name = "Temperature Catalyst Agent"

/datum/reagent/catalyst_agent/temperature/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.thermic_mod = ((creation_purity - 0.5) * 2) * modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier

///Catalyst precursors. P is the harder one to make, because it is probably more useful
/datum/reagent/catalyst_precursor_ph
	name = "Catalysium P"
	description = "Bliski krewny prefaktorów, prekursor modulatora jonowego. Reaguje ze stabilną plazmą."
	color = "#bafa69"
	ph = 7

/datum/reagent/catalyst_precursor_temp
	name = "Catalysium T"
	description = "Bliski krewny prefaktorów, prekursor modulatora termicznego. Reaguje ze stabilną plazmą."
	color = "#c91a1a"
	ph = 7

///General catalysts
/datum/reagent/catalyst_agent/ph/generic
	name = "Ionic Modulator"
	target_reagent_type = /datum/reagent
	modifier = 0.5
	description = "Ten katalizator stabilizuje reakcje w zlewce, zmniejszając zmiany pH powodowane przez reagujące chemikalia."
	ph = 7
	color = "#84e30b"

/datum/reagent/catalyst_agent/temperature/generic
	name = "Thermic Modulator"
	target_reagent_type = /datum/reagent
	modifier = 0.5
	description = "Ten katalizator stabilizuje reakcje w zlewce, zmniejszając ich endo- i egzotermiczność."
	ph = 7
	color = "#84e30b"

///These affect medicines
/datum/reagent/catalyst_agent/speed/medicine
	name = "Palladium Synthate Catalyst"
	description = "Ten katalizator mocno przyspiesza wszystkie reakcje leków w tej samej zlewce."
	target_reagent_type = /datum/reagent/medicine
	modifier = 2
	ph = 2 //drift towards acidity
	color = "#b1b1b1"
