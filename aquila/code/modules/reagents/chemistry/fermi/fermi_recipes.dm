// Receptury buforów, testera czystości i katalizatorów z tg (tgstation@b3949ec362, recipes/reaction_agents.dm, recipes/catalysts.dm)

/datum/chemical_reaction/basic_buffer
	name = "Mocny bufor zasadowy"
	id = /datum/reagent/reaction_agent/basic_buffer
	results = list(/datum/reagent/reaction_agent/basic_buffer = 10)
	required_reagents = list(/datum/reagent/ammonia = 3, /datum/reagent/chlorine = 2, /datum/reagent/hydrogen = 2, /datum/reagent/oxygen = 2) //vagely NH4OH + NH4Cl buffer
	mix_message = "Roztwór musuje w zlewce."
	required_temp = 250
	optimal_temp = 500
	overheat_temp = NO_OVERHEAT
	optimal_ph_min = 0
	optimal_ph_max = 14
	determin_ph_range = 0
	temp_exponent_factor = 4
	ph_exponent_factor = 0
	thermic_constant = 0
	H_ion_release = 0.01
	rate_up_lim = 15
	purity_min = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/acidic_buffer
	name = "Mocny bufor kwaśny"
	id = /datum/reagent/reaction_agent/acidic_buffer
	results = list(/datum/reagent/reaction_agent/acidic_buffer = 10)
	required_reagents = list(/datum/reagent/sodium = 2, /datum/reagent/hydrogen = 2, /datum/reagent/consumable/ethanol = 2, /datum/reagent/water = 2)
	mix_message = "Roztwór pieni się w zlewce."
	required_temp = 250
	optimal_temp = 500
	overheat_temp = NO_OVERHEAT
	optimal_ph_min = 0
	optimal_ph_max = 14
	determin_ph_range = 0
	temp_exponent_factor = 4
	ph_exponent_factor = 0
	thermic_constant = 0
	H_ion_release = -0.01
	rate_up_lim = 20
	purity_min = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

//////////////////// Example competitive reaction (REACTION_COMPETITIVE) ////////////////////

/datum/chemical_reaction/prefactor_a
	name = "Półprodukt Alfa"
	id = /datum/reagent/prefactor_a
	results = list(/datum/reagent/prefactor_a = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/consumable/ethanol = 3, /datum/reagent/toxin/plasma = 1)
	mix_message = "Roztwór gęstnieje."
	is_cold_recipe = TRUE
	required_temp = 800
	optimal_temp = 300
	overheat_temp = -1 //no overheat
	optimal_ph_min = 2
	optimal_ph_max = 12
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 0
	thermic_constant = -400
	H_ion_release = 0
	rate_up_lim = 4
	purity_min = 0.25
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/prefactor_b
	name = "Półprodukt Beta"
	id = /datum/reagent/prefactor_b
	results = list(/datum/reagent/prefactor_b = 5)
	required_reagents = list(/datum/reagent/prefactor_a = 5)
	mix_message = "Roztwór rzednie."
	mix_sound = 'aquila/sound/effects/chemistry/bluespace.ogg'
	required_temp = 50
	optimal_temp = 500
	overheat_temp = 500
	optimal_ph_min = 5
	optimal_ph_max = 8
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 2
	thermic_constant = -800
	H_ion_release = -0.02
	rate_up_lim = 6
	purity_min = 0.35
	reaction_flags = REACTION_COMPETITIVE //Competes with /datum/chemical_reaction/prefactor_a/competitive
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/prefactor_b/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	. = ..()
	if(holder.has_reagent(/datum/reagent/bluespace))
		holder.remove_reagent(/datum/reagent/bluespace, 1, TRUE)
		reaction.delta_t *= 5

/datum/chemical_reaction/prefactor_b/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	explode_shockwave(holder, equilibrium)
	var/vol = max(20, holder.total_volume / 5) //Not letting you have more than 5
	clear_reagents(holder, vol)//Lest we explode forever

/datum/chemical_reaction/prefactor_b/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	explode_fire(holder, equilibrium)
	var/vol = max(20, holder.total_volume / 5) //Not letting you have more than 5
	clear_reagents(holder, vol)

/datum/chemical_reaction/prefactor_a/competitive //So we have a back and forth reaction
	id = "prefactor_a_competitive"
	results = list(/datum/reagent/prefactor_a = 5)
	required_reagents = list(/datum/reagent/prefactor_b = 5)
	rate_up_lim = 3
	reaction_flags = REACTION_COMPETITIVE //Competes with /datum/chemical_reaction/prefactor_b
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

//The actual results
/datum/chemical_reaction/prefactor_a/purity_tester
	name = "Tester czystości"
	id = /datum/reagent/reaction_agent/purity_tester
	results = list(/datum/reagent/reaction_agent/purity_tester = 5)
	required_reagents = list(/datum/reagent/prefactor_a = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = 0.05
	thermic_constant = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/prefactor_b/speed_agent
	name = "Tempomiocyna"
	id = /datum/reagent/reaction_agent/speed_agent
	results = list(/datum/reagent/reaction_agent/speed_agent = 5)
	required_reagents = list(/datum/reagent/prefactor_b = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = -0.15
	thermic_constant = 0
	reaction_tags = REACTION_TAG_HARD | REACTION_TAG_DANGEROUS | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/////////////////////////// PRECURSOR ////////////////////////////

/datum/chemical_reaction/catalyst_precursor_temp
	name = "Katalizum T"
	id = /datum/reagent/catalyst_precursor_temp
	results = list(/datum/reagent/catalyst_precursor_temp = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/toxin/mutagen = 3, /datum/reagent/toxin/plasma = 1)
	mix_message = "Roztwór paruje i się pieni."
	is_cold_recipe = TRUE
	required_temp = 800
	optimal_temp = 300
	overheat_temp = -1
	optimal_ph_min = 0.1
	optimal_ph_max = 13.9
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 0
	thermic_constant = -400
	H_ion_release = 0
	rate_up_lim = 4
	purity_min = 0.25
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/catalyst_precursor_ph
	name = "Katalizum P"
	id = /datum/reagent/catalyst_precursor_ph
	results = list(/datum/reagent/catalyst_precursor_ph = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_temp = 5)
	mix_message = "Roztwór krzepnie."
	required_temp = 50
	optimal_temp = 500
	overheat_temp = 500
	optimal_ph_min = 6.5
	optimal_ph_max = 7.5
	determin_ph_range = 1
	temp_exponent_factor = 1
	ph_exponent_factor = 3
	thermic_constant = -800
	H_ion_release = -0.02
	rate_up_lim = 6
	purity_min = 0.35
	reaction_flags = REACTION_COMPETITIVE
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/catalyst_precursor_ph/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	. = ..()
	if(holder.has_reagent(/datum/reagent/gold))
		holder.remove_reagent(/datum/reagent/gold, 1, TRUE)
		reaction.delta_t *= 5

/datum/chemical_reaction/catalyst_precursor_temp/competitive
	id = "catalyst_precursor_temp_competitive"
	results = list(/datum/reagent/catalyst_precursor_temp = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_ph = 5)
	rate_up_lim = 3
	reaction_flags = REACTION_COMPETITIVE //Competes with /datum/chemical_reaction/catalyst_precursor_ph
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/////////////////////////// CATALYSTS ////////////////////////////

/datum/chemical_reaction/thermic_modulator
	name = "Modulator termiczny"
	id = /datum/reagent/catalyst_agent/temperature/generic
	results = list(/datum/reagent/catalyst_agent/temperature/generic = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_temp = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = 0
	thermic_constant = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/ionic_modulator
	name = "Modulator jonowy"
	id = /datum/reagent/catalyst_agent/ph/generic
	results = list(/datum/reagent/catalyst_agent/ph/generic = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_ph = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = 0
	thermic_constant = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE
