// Procedury holdera z fermichemu tg (tgstation@b3949ec362, holder/properties.dm i holder/mob_life.dm).

//======================PH(clamped between 0->14)========================================
/*
* Adjusts the base pH of all of the reagents in a beaker
*
* - moves it towards acidic
* + moves it towards basic
* Arguments:
* * value - How much to adjust the base pH by
*/
/datum/reagents/proc/adjust_all_reagents_ph(value)
	for(var/datum/reagent/reagent as anything in reagent_list)
		reagent.ph = clamp(reagent.ph + value, CHEMICAL_MIN_PH, CHEMICAL_MAX_PH)
	update_total()

/*
* Adjusts the base pH of a specific type
*
* - moves it towards acidic
* + moves it towards basic
* Arguments:
* * input_reagent - type path of the reagent
* * value - How much to adjust the base pH by
*/
/datum/reagents/proc/adjust_specific_reagent_ph(input_reagent, value)
	var/datum/reagent/reagent = get_reagent(input_reagent)
	if(!reagent) //We can call this with missing reagents.
		return FALSE
	reagent.ph = clamp(reagent.ph + value, CHEMICAL_MIN_PH, CHEMICAL_MAX_PH)

//==========================TEMPERATURE======================================
/// Returns the total heat capacity for all of the reagents currently in this holder.
/datum/reagents/proc/heat_capacity()
	. = 0
	for(var/datum/reagent/reagent as anything in reagent_list)
		. += reagent.specific_heat * reagent.volume

/** Sets the temperature of this reagent container to a new value.
 *
 * Arguments:
 * - _temperature: The new temperature value.
 */
/datum/reagents/proc/set_temperature(_temperature)
	if(_temperature == chem_temp)
		return
	. = chem_temp
	chem_temp = clamp(_temperature, 0, CHEMICAL_MAXIMUM_TEMPERATURE)

//==============================PURITY==========================================
/**
 * Get the purity of this reagent
 * Arguments
 * * [reagent][datum/reagent] - the typepath of the specific reagent to get purity of
 */
/datum/reagents/proc/get_reagent_purity(datum/reagent/reagent)
	for(var/datum/reagent/cached_reagent as anything in reagent_list)
		if(cached_reagent.type == reagent)
			return round(cached_reagent.purity, 0.01)
	return 0

/**
 * Get the average purity of all reagents (or all subtypes of provided typepath)
 * Arguments
 * * [parent_type][datum/reagent] - the typepath of specific reagents to look for
 */
/datum/reagents/proc/get_average_purity(datum/reagent/parent_type = null)
	var/total_amount = 0
	var/weighted_purity = 0
	for(var/datum/reagent/reagent as anything in reagent_list)
		if(!isnull(parent_type) && !istype(reagent, parent_type))
			continue
		total_amount += reagent.volume
		weighted_purity += reagent.volume * reagent.purity
	if(!total_amount)
		return 1
	return weighted_purity / total_amount

/**
 * Directly set the purity of all contained reagents to a new value
 * Arguments
 * * new_purity - the new purity value
 */
/datum/reagents/proc/set_all_reagents_purity(new_purity = 0)
	for(var/datum/reagent/cached_reagent as anything in reagent_list)
		cached_reagent.purity = max(0, new_purity)

//==============================MOBS==========================================
/**
 * Processes the reagents in the holder and converts them, only called in a mob/living/carbon on addition
 *
 * Arguments:
 * * reagent - the added reagent datum/object
 * * added_volume - the volume of the reagent that was added (since it can already exist in a mob)
 * * added_purity - the purity of the added volume
 * * reagent_datum - a list of [datum/reagent]=amount that will contain the inverse reagent that was added
 * returns the volume of the original, pure, reagent to add / keep
 */
/datum/reagents/proc/process_mob_reagent_purity(datum/reagent/reagent, added_volume, added_purity, list/reagent_datum)
	//no splitting when purity is perfect
	if(added_purity == 1)
		return added_volume
	if(reagent.fermi_flags & REAGENT_DONOTSPLIT)
		return added_volume

	//Turns all of a added reagent into the inverse chem
	if(reagent.inverse_chem_val > added_purity && reagent.inverse_chem)
		if(isnull(reagent_datum))
			reagent_datum = list()
		var/added_amount = add_reagent(reagent.inverse_chem, added_volume, FALSE, added_purity = reagent.get_inverse_purity(reagent.creation_purity), reagent_added = reagent_datum)
		if(length(reagent_datum))
			var/datum/reagent/inverse_reagent = reagent_datum[reagent_datum.len]
			if(inverse_reagent.fermi_flags & REAGENT_SNEAKYNAME)
				inverse_reagent.name = reagent.name //Negative effects are hidden
		return added_amount * -1

	//reagent did not split because purity was above inverse value
	return added_volume
