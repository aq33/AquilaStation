// WYGENEROWANE skryptem gen_fermi_data.py - nie edytuj ręcznie, opis w fermi_readme.md
// Parametry fermichemu przepisów i pH reagentów skopiowane z tgstation@b3949ec362.

////////////////////////////// Przepisy //////////////////////////////

/datum/chemical_reaction/acetone // tg: /datum/chemical_reaction/acetone
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPONENT

/datum/chemical_reaction/acidspit // tg: /datum/chemical_reaction/drink/acidspit
	optimal_temp = 250
	optimal_ph_min = 0
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/alexander // tg: /datum/chemical_reaction/drink/alexander
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/alliescocktail // tg: /datum/chemical_reaction/drink/alliescocktail
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/aloe // tg: /datum/chemical_reaction/drink/aloe
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/amarena
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/amasec // tg: /datum/chemical_reaction/drink/amasec
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/ammonia // tg: /datum/chemical_reaction/ammonia
	optimal_ph_min = 1
	optimal_ph_max = 12
	thermic_constant = 50
	H_ion_release = -0.02
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT | REACTION_TAG_COMPONENT

/datum/chemical_reaction/anacea // tg: /datum/chemical_reaction/anacea
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 6
	optimal_ph_max = 9
	determin_ph_range = 4
	temp_exponent_factor = 1.6
	ph_exponent_factor = 2.4
	thermic_constant = 250
	H_ion_release = 3
	rate_up_lim = 10
	purity_min = 0.7
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/andalusia // tg: /datum/chemical_reaction/drink/andalusia
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/ant_slurry // tg: /datum/chemical_reaction/ant_slurry
	required_temp = 480
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/antifreeze // tg: /datum/chemical_reaction/drink/antifreeze
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/antihol // tg: /datum/chemical_reaction/medicine/antihol
	optimal_ph_min = 3.5
	optimal_ph_max = 8.5
	determin_ph_range = 5
	ph_exponent_factor = 2
	thermic_constant = -100
	H_ion_release = 0.09
	rate_up_lim = 25
	purity_min = 0.15
	reaction_flags = REACTION_CLEAR_INVERSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/ants // tg: /datum/chemical_reaction/ants
	required_temp = 50
	optimal_ph_min = 3
	optimal_ph_max = 12
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/aranesp // tg: /datum/chemical_reaction/aranesp
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/arnold_palmer // tg: /datum/chemical_reaction/drink/arnold_palmer
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/ash // tg: /datum/chemical_reaction/ash
	required_temp = 480
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT | REACTION_TAG_COMPONENT

/datum/chemical_reaction/atomicbomb // tg: /datum/chemical_reaction/drink/atomicbomb
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/atropine // tg: /datum/chemical_reaction/medicine/atropine
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/b52 // tg: /datum/chemical_reaction/drink/b52
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/bacchus_blessing // tg: /datum/chemical_reaction/drink/bacchus_blessing
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/bahama_mama // tg: /datum/chemical_reaction/drink/bahama_mama
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/bananahonk // tg: /datum/chemical_reaction/drink/bananahonk
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/barbers_aid // tg: /datum/chemical_reaction/barbers_aid
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/barefoot // tg: /datum/chemical_reaction/drink/barefoot
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/bastion_bourbon // tg: /datum/chemical_reaction/drink/bastion_bourbon
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/bath_salts // tg: /datum/chemical_reaction/bath_salts
	required_temp = 374
	thermic_constant = 50
	reaction_flags = REACTION_CLEAR_INVERSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/beeffizz
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/beepsky_smash // tg: /datum/chemical_reaction/drink/beepsky_smash
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/beesknees
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/beesplosion // tg: /datum/chemical_reaction/beesplosion
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/between_the_sheets // tg: /datum/chemical_reaction/drink/between_the_sheets
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/bilk // tg: /datum/chemical_reaction/drink/bilk
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE

/datum/chemical_reaction/black_russian // tg: /datum/chemical_reaction/drink/black_russian
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/blank_paper // tg: /datum/chemical_reaction/drink/blank_paper
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/blazaam // tg: /datum/chemical_reaction/drink/blazaam
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/bloody_mary // tg: /datum/chemical_reaction/drink/bloody_mary
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/bluecherryshake // tg: /datum/chemical_reaction/drink/bluecherryshake
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/bonehurtingjuice // tg: /datum/chemical_reaction/bonehurtingjuice
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 5
	optimal_ph_max = 9
	determin_ph_range = 3
	temp_exponent_factor = 0.5
	ph_exponent_factor = 1
	thermic_constant = -400
	H_ion_release = -0.4
	rate_up_lim = 15
	purity_min = 0.4
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/booger // tg: /datum/chemical_reaction/drink/booger
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/branca_menta // tg: /datum/chemical_reaction/drink/branca_menta
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/brave_bull // tg: /datum/chemical_reaction/drink/brave_bull
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/bug_spray // tg: /datum/chemical_reaction/drink/bug_spray
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/cafe_latte // tg: /datum/chemical_reaction/drink/cafe_latte
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/calomel // tg: /datum/chemical_reaction/medicine/calomel
	required_temp = 374
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/candlefication // tg: /datum/chemical_reaction/candlefication
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/capsaicincondensation // tg: /datum/chemical_reaction/capsaicincondensation
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/carbondioxide // tg: /datum/chemical_reaction/carbondioxide
	required_temp = 777
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE
	optimal_temp = 827
	overheat_temp = 1027

/datum/chemical_reaction/carpet // tg: /datum/chemical_reaction/carpet
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/changelingsting // tg: /datum/chemical_reaction/drink/changelingsting
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/cherryshake // tg: /datum/chemical_reaction/drink/cherryshake
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/chloralhydrate // tg: /datum/chemical_reaction/chloralhydrate
	required_temp = 200
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 7
	optimal_ph_max = 9
	determin_ph_range = 2
	temp_exponent_factor = 2
	ph_exponent_factor = 2
	thermic_constant = 250
	H_ion_release = 2
	rate_up_lim = 10
	purity_min = 0.6
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/chocolate_milk // tg: /datum/chemical_reaction/drink/chocolate_milk
	optimal_ph_min = 2
	optimal_ph_max = 10
	thermic_constant = -1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/chocolatepudding // tg: /datum/chemical_reaction/food/chocolatepudding
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/clf3 // tg: /datum/chemical_reaction/clf3
	required_temp = 424
	overheat_temp = 1050
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_DANGEROUS | REACTION_TAG_BURN
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/colorful_reagent // tg: /datum/chemical_reaction/colorful_reagent
	reaction_flags = REACTION_CLEAR_INVERSE

/datum/chemical_reaction/concentrated_barbers_aid // tg: /datum/chemical_reaction/concentrated_barbers_aid
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/corgium // tg: /datum/chemical_reaction/corgium
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/cream_soda // tg: /datum/chemical_reaction/drink/cream_soda
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/crevice_spike // tg: /datum/chemical_reaction/drink/crevice_spike
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/cryogenic_fuel
	optimal_temp = 0
	overheat_temp = NO_OVERHEAT

/datum/chemical_reaction/cryostylane // tg: /datum/chemical_reaction/cryostylane
	required_temp = -200
	optimal_temp = 300
	overheat_temp = NO_OVERHEAT
	optimal_ph_min = 4
	optimal_ph_max = 10
	determin_ph_range = 6
	temp_exponent_factor = 0.5
	ph_exponent_factor = 1
	thermic_constant = -1.5
	H_ion_release = 0
	rate_up_lim = 10
	purity_min = 0.2
	reaction_flags = REACTION_HEAT_ARBITARY | REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_ORGAN

/datum/chemical_reaction/cryostylane_oxygen // tg: /datum/chemical_reaction/cryostylane_oxygen
	optimal_ph_min = 0
	optimal_ph_max = 14
	determin_ph_range = 0
	ph_exponent_factor = 1
	thermic_constant = -5
	H_ion_release = 0
	rate_up_lim = 4
	purity_min = 0.15
	reaction_flags = REACTION_HEAT_ARBITARY | REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/cryoxadone // tg: /datum/chemical_reaction/medicine/cryoxadone
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_PLANT | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/cryptobiolin // tg: /datum/chemical_reaction/cryptobiolin
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/cuba_libre // tg: /datum/chemical_reaction/drink/cuba_libre
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/cyanide // tg: /datum/chemical_reaction/cyanide
	required_temp = 380
	is_cold_recipe = FALSE
	optimal_temp = 420
	overheat_temp = NO_OVERHEAT
	optimal_ph_min = 9
	optimal_ph_max = 11
	determin_ph_range = 3
	temp_exponent_factor = 0.7
	ph_exponent_factor = 2
	thermic_constant = -300
	H_ion_release = 3.2
	rate_up_lim = 10
	purity_min = 0.4
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OXY | REACTION_TAG_TOXIN

/datum/chemical_reaction/demonsblood // tg: /datum/chemical_reaction/drink/demonsblood
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/devilskiss // tg: /datum/chemical_reaction/drink/devilskiss
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/diethylamine // tg: /datum/chemical_reaction/diethylamine
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT | REACTION_TAG_COMPONENT

/datum/chemical_reaction/diphenhydramine // tg: /datum/chemical_reaction/medicine/diphenhydramine
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/doctor_delight // tg: /datum/chemical_reaction/drink/doctor_delight
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/driestmartini // tg: /datum/chemical_reaction/drink/driestmartini
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/drunkenblumpkin // tg: /datum/chemical_reaction/drink/drunkenblumpkin
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/drying_agent // tg: /datum/chemical_reaction/drying_agent
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_COMPONENT

/datum/chemical_reaction/duplex // tg: /datum/chemical_reaction/drink/duplex
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/eggnog // tg: /datum/chemical_reaction/drink/eggnog
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/emp_pulse // tg: /datum/chemical_reaction/emp_pulse
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/energized_jelly // tg: /datum/chemical_reaction/energized_jelly
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DANGEROUS | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/ephedrine // tg: /datum/chemical_reaction/medicine/ephedrine
	optimal_ph_min = 7
	optimal_ph_max = 9
	determin_ph_range = 3
	ph_exponent_factor = 0.8
	thermic_constant = -0.25
	H_ion_release = -0.02
	rate_up_lim = 15
	purity_min = 0.32
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/epinephrine // tg: /datum/chemical_reaction/medicine/epinephrine
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_OTHER

/datum/chemical_reaction/erikasurprise // tg: /datum/chemical_reaction/drink/erikasurprise
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/facid // tg: /datum/chemical_reaction/facid
	required_temp = 380
	is_cold_recipe = FALSE
	optimal_temp = 680
	overheat_temp = 800
	optimal_ph_min = 0
	optimal_ph_max = 2
	determin_ph_range = 5
	temp_exponent_factor = 2
	ph_exponent_factor = 10
	thermic_constant = -200
	H_ion_release = -25
	rate_up_lim = 20
	purity_min = 0.5
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_PLANT | REACTION_TAG_BURN | REACTION_TAG_TOXIN

/datum/chemical_reaction/fanciulli // tg: /datum/chemical_reaction/drink/fanciulli
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/feed_carnivorous_blood // tg: /datum/chemical_reaction/feed_carnivorous_blood
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/fentanyl // tg: /datum/chemical_reaction/fentanyl
	required_temp = 674
	is_cold_recipe = FALSE
	optimal_temp = 774
	overheat_temp = 874
	optimal_ph_min = 7
	optimal_ph_max = 11
	determin_ph_range = 3
	temp_exponent_factor = 0.7
	ph_exponent_factor = 10
	thermic_constant = 50
	H_ion_release = 3
	rate_up_lim = 5
	purity_min = 0.5
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_ORGAN | REACTION_TAG_TOXIN

/datum/chemical_reaction/fernet_cola // tg: /datum/chemical_reaction/drink/fernet_cola
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_TOXIN

/datum/chemical_reaction/fetching_fizz // tg: /datum/chemical_reaction/drink/fetching_fizz
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/firefighting_foam // tg: /datum/chemical_reaction/firefighting_foam
	required_temp = 200
	is_cold_recipe = 1
	optimal_temp = 50
	overheat_temp = 5
	thermic_constant = -1
	H_ion_release = -0.02
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/flash_powder // tg: /datum/chemical_reaction/flash_powder
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/flash_powder_flash // tg: /datum/chemical_reaction/flash_powder_flash
	required_temp = 374
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/foam // tg: /datum/chemical_reaction/foam
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/foaming_agent // tg: /datum/chemical_reaction/foaming_agent
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/food/american // tg: /datum/chemical_reaction/food/cheesewheel
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/bbqsauce // tg: /datum/chemical_reaction/food/bbqsauce
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/cakebatter // tg: /datum/chemical_reaction/food/cakebatter
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/cakebatter/vegan // tg: /datum/chemical_reaction/food/cakebatter/vegan
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/caramel // tg: /datum/chemical_reaction/food/caramel
	required_temp = 413.15
	optimal_temp = 600
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/caramel_burned // tg: /datum/chemical_reaction/food/caramel_burned
	required_temp = 483.15
	optimal_temp = 1000
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 10
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/chocolate_bar // tg: /datum/chemical_reaction/food/chocolate_bar
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/chocolate_bar2 // tg: /datum/chemical_reaction/food/chocolate_bar2
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/coffee // tg: /datum/chemical_reaction/drink/coffee
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/food/corn_syrup // tg: /datum/chemical_reaction/food/corn_syrup
	required_temp = 374
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/dough // tg: /datum/chemical_reaction/food/dough
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/hell_ramen // tg: /datum/chemical_reaction/food/hell_ramen
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/hot_ramen // tg: /datum/chemical_reaction/food/hot_ramen
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/imitationcarpmeat // tg: /datum/chemical_reaction/food/imitationcarpmeat
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/soysauce // tg: /datum/chemical_reaction/food/soysauce
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/synthmeat // tg: /datum/chemical_reaction/food/synthmeat
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/tea // tg: /datum/chemical_reaction/drink/tea
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/food/tofu // tg: /datum/chemical_reaction/food/tofu
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/uncooked_rice // tg: /datum/chemical_reaction/food/uncooked_rice
	optimal_temp = 400
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/formaldehyde // tg: /datum/chemical_reaction/formaldehyde
	required_temp = 420
	is_cold_recipe = FALSE
	optimal_temp = 520
	overheat_temp = 900
	optimal_ph_min = 0
	optimal_ph_max = 7
	determin_ph_range = 2
	temp_exponent_factor = 2
	ph_exponent_factor = 1.2
	thermic_constant = 200
	H_ion_release = -3
	rate_up_lim = 15
	purity_min = 0.5
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_CHEMICAL | REACTION_TAG_BRUTE | REACTION_TAG_TOXIN

/datum/chemical_reaction/fourthwall
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/fringe_weaver // tg: /datum/chemical_reaction/drink/fringe_weaver
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/ftliver
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/gargle_blaster // tg: /datum/chemical_reaction/drink/gargle_blaster
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/ghoulpowder // tg: /datum/chemical_reaction/ghoulpowder
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 5
	optimal_ph_max = 14
	determin_ph_range = 2
	temp_exponent_factor = 3
	ph_exponent_factor = 1
	thermic_constant = 150
	H_ion_release = -0.25
	rate_up_lim = 15
	purity_min = 0.4
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/gibbfloats // tg: /datum/chemical_reaction/drink/gibbfloats
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/gin_fizz // tg: /datum/chemical_reaction/drink/gin_fizz
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/gin_tonic // tg: /datum/chemical_reaction/drink/gin_tonic
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/glycerol // tg: /datum/chemical_reaction/glycerol
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/goldschlager
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/goldsolidification // tg: /datum/chemical_reaction/gold_solidification
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/grape_soda // tg: /datum/chemical_reaction/drink/grape_soda
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/grappa // tg: /datum/chemical_reaction/drink/grappa
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/grasshopper // tg: /datum/chemical_reaction/drink/grasshopper
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/greenbeer // tg: /datum/chemical_reaction/drink/greenbeer
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/greenbeer2 // tg: /datum/chemical_reaction/drink/greenbeer2
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/grog // tg: /datum/chemical_reaction/drink/grog
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/hair_dye // tg: /datum/chemical_reaction/hair_dye
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/haloperidol // tg: /datum/chemical_reaction/medicine/haloperidol
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/happiness // tg: /datum/chemical_reaction/happiness
	thermic_constant = 50
	reaction_flags = REACTION_CLEAR_INVERSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/hearty_punch // tg: /datum/chemical_reaction/drink/hearty_punch
	required_temp = 315
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/heparin // tg: /datum/chemical_reaction/heparin
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 800
	optimal_ph_min = 5
	optimal_ph_max = 9.5
	determin_ph_range = 3
	temp_exponent_factor = 2.5
	ph_exponent_factor = 2
	thermic_constant = 375
	H_ion_release = -0.6
	rate_up_lim = 10
	purity_min = 0.6
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/hippiesdelight // tg: /datum/chemical_reaction/drink/hippiesdelight
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/hooch // tg: /datum/chemical_reaction/drink/hooch
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/icecoffee // tg: /datum/chemical_reaction/drink/icecoffee
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/iced_beer // tg: /datum/chemical_reaction/drink/iced_beer
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/icetea // tg: /datum/chemical_reaction/drink/icetea
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/icewing
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/impedrezene // tg: /datum/chemical_reaction/impedrezene
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_ORGAN

/datum/chemical_reaction/inacusiate // tg: /datum/chemical_reaction/medicine/inacusiate
	optimal_ph_min = 5
	optimal_ph_max = 10
	determin_ph_range = 4
	ph_exponent_factor = 1
	thermic_constant = 20
	H_ion_release = 1.5
	rate_up_lim = 3
	purity_min = 0.25
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/irish_coffee // tg: /datum/chemical_reaction/drink/irish_coffee
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/irish_cream // tg: /datum/chemical_reaction/drink/irish_cream
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/irishcarbomb // tg: /datum/chemical_reaction/drink/irishcarbomb
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/ironfoam // tg: /datum/chemical_reaction/ironfoam
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/itching_powder // tg: /datum/chemical_reaction/itching_powder
	required_temp = 280
	is_cold_recipe = FALSE
	optimal_temp = 360
	overheat_temp = 700
	optimal_ph_min = 5
	optimal_ph_max = 9
	determin_ph_range = 4
	temp_exponent_factor = 0.7
	ph_exponent_factor = 1.5
	thermic_constant = -200
	H_ion_release = 5.7
	rate_up_lim = 20
	purity_min = 0.3
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_BRUTE

/datum/chemical_reaction/jack_rose // tg: /datum/chemical_reaction/drink/jack_rose
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/kahlua // tg: /datum/chemical_reaction/drink/kahlua
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/kamikaze // tg: /datum/chemical_reaction/drink/kamikaze
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/krokodil // tg: /datum/chemical_reaction/krokodil
	required_temp = 380
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG

/datum/chemical_reaction/laughter // tg: /datum/chemical_reaction/laughter
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/ldm_vortex // tg: /datum/chemical_reaction/ldm_vortex
	required_temp = 474
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/lemonade // tg: /datum/chemical_reaction/drink/lemonade
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/leporazine // tg: /datum/chemical_reaction/medicine/leporazine
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/lexorin // tg: /datum/chemical_reaction/lexorin
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 1.8
	optimal_ph_max = 7
	determin_ph_range = 3
	temp_exponent_factor = 2
	ph_exponent_factor = 5
	thermic_constant = -400
	H_ion_release = 0.1
	rate_up_lim = 25
	purity_min = 0.4
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OXY

/datum/chemical_reaction/life // tg: /datum/chemical_reaction/life
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/life_friendly // tg: /datum/chemical_reaction/life_friendly
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/lipolicide // tg: /datum/chemical_reaction/lipolicide
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 4
	optimal_ph_max = 8.5
	determin_ph_range = 2
	temp_exponent_factor = 1
	ph_exponent_factor = 0.2
	thermic_constant = 500
	H_ion_release = 2.5
	rate_up_lim = 10
	purity_min = 0.7
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/liquid_dark_matter // tg: /datum/chemical_reaction/liquid_dark_matter
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/longislandicedtea // tg: /datum/chemical_reaction/drink/longislandicedtea
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/lube // tg: /datum/chemical_reaction/lube
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/lye // tg: /datum/chemical_reaction/lye
	required_temp = 10
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPONENT

/datum/chemical_reaction/lye2 // tg: /datum/chemical_reaction/lye2
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPONENT

/datum/chemical_reaction/manhattan // tg: /datum/chemical_reaction/drink/manhattan
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/manhattan_proj // tg: /datum/chemical_reaction/drink/manhattan_proj
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/manly_dorf // tg: /datum/chemical_reaction/drink/manly_dorf
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/mannitol // tg: /datum/chemical_reaction/medicine/mannitol
	required_temp = 50
	optimal_temp = 300
	overheat_temp = 650
	optimal_ph_min = 5
	optimal_ph_max = 7.5
	determin_ph_range = 3
	temp_exponent_factor = 1
	ph_exponent_factor = 1
	thermic_constant = 100
	H_ion_release = 0
	rate_up_lim = 10
	purity_min = 0.4
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/margarita // tg: /datum/chemical_reaction/drink/margarita
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/martini // tg: /datum/chemical_reaction/drink/martini
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/mauna_loa // tg: /datum/chemical_reaction/drink/mauna_loa
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/mead // tg: /datum/chemical_reaction/drink/mead
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/meatification // tg: /datum/chemical_reaction/meatification
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/metalfoam // tg: /datum/chemical_reaction/metalfoam
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/metalgen_imprint // tg: /datum/chemical_reaction/metalgen_imprint
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/methamphetamine // tg: /datum/chemical_reaction/methamphetamine
	required_temp = 372
	optimal_temp = 376
	overheat_temp = 380
	optimal_ph_min = 6.5
	optimal_ph_max = 7.5
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 1.4
	thermic_constant = 0.1
	H_ion_release = -0.025
	rate_up_lim = 12.5
	purity_min = 0.5
	reaction_flags = REACTION_HEAT_ARBITARY
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DRUG | REACTION_TAG_DANGEROUS | REACTION_TAG_ORGAN

/datum/chemical_reaction/methane
	optimal_temp = 570
	overheat_temp = 900

/datum/chemical_reaction/mimesbane // tg: /datum/chemical_reaction/mimesbane
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 0
	optimal_ph_max = 8
	determin_ph_range = 4
	temp_exponent_factor = 1.5
	ph_exponent_factor = 3
	thermic_constant = -400
	H_ion_release = -2
	rate_up_lim = 15
	purity_min = 0.5
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/mindbreaker // tg: /datum/chemical_reaction/mindbreaker
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 6
	optimal_ph_max = 14
	determin_ph_range = 3
	temp_exponent_factor = 2.5
	ph_exponent_factor = 2
	thermic_constant = 150
	H_ion_release = -0.06
	rate_up_lim = 15
	purity_min = 0.4
	reaction_flags = REACTION_CLEAR_INVERSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/mine_salve // tg: /datum/chemical_reaction/medicine/mine_salve
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/mine_salve2 // tg: /datum/chemical_reaction/medicine/mine_salve2
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/mix_virus // tg: /datum/chemical_reaction/mix_virus
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/falter_virus // tg: /datum/chemical_reaction/mix_virus
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_10 // tg: /datum/chemical_reaction/mix_virus/mix_virus_10
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_11 // tg: /datum/chemical_reaction/mix_virus/mix_virus_11
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_12 // tg: /datum/chemical_reaction/mix_virus/mix_virus_12
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_13 // tg: /datum/chemical_reaction/mix_virus/mix_virus_13
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_14 // tg: /datum/chemical_reaction/mix_virus
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_2 // tg: /datum/chemical_reaction/mix_virus/mix_virus_2
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_3 // tg: /datum/chemical_reaction/mix_virus/mix_virus_3
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_4 // tg: /datum/chemical_reaction/mix_virus/mix_virus_4
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_5 // tg: /datum/chemical_reaction/mix_virus/mix_virus_5
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_6 // tg: /datum/chemical_reaction/mix_virus/mix_virus_6
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_7 // tg: /datum/chemical_reaction/mix_virus/mix_virus_7
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_8 // tg: /datum/chemical_reaction/mix_virus/mix_virus_8
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/mix_virus_9 // tg: /datum/chemical_reaction/mix_virus/mix_virus_9
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/neuter_virus // tg: /datum/chemical_reaction/mix_virus/neuter_virus
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/preserve_virus // tg: /datum/chemical_reaction/mix_virus
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/mix_virus/rem_virus // tg: /datum/chemical_reaction/mix_virus/rem_virus
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_ACTIVE

/datum/chemical_reaction/modafinil // tg: /datum/chemical_reaction/medicine/modafinil
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/mojito // tg: /datum/chemical_reaction/drink/mojito
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/moonshine // tg: /datum/chemical_reaction/drink/moonshine
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/morphine // tg: /datum/chemical_reaction/medicine/morphine
	required_temp = 480
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/mulligan // tg: /datum/chemical_reaction/mulligan
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/mutadone // tg: /datum/chemical_reaction/medicine/mutadone
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/mutagen // tg: /datum/chemical_reaction/mutagen
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 3
	optimal_ph_max = 9
	determin_ph_range = 1
	temp_exponent_factor = 2
	ph_exponent_factor = 5
	thermic_constant = 350
	H_ion_release = 0.1
	rate_up_lim = 10
	purity_min = 0.7
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_PLANT | REACTION_TAG_OTHER | REACTION_TAG_COMPONENT

/datum/chemical_reaction/mutationtoxin/ethereal // tg: /datum/chemical_reaction/slime/slimeethereal
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/mutationtoxin/felinid // tg: /datum/chemical_reaction/slime/slimefelinid
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/mutationtoxin/lizard // tg: /datum/chemical_reaction/slime/slimelizard
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/mutationtoxin/moth // tg: /datum/chemical_reaction/slime/slimemoth
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/mutationtoxin/stable // tg: /datum/chemical_reaction/slime/slimehuman
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/mutetoxin // tg: /datum/chemical_reaction/mutetoxin
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 6
	optimal_ph_max = 14
	determin_ph_range = 2
	temp_exponent_factor = 3
	ph_exponent_factor = 1
	thermic_constant = -250
	H_ion_release = -0.2
	rate_up_lim = 15
	purity_min = 0.4
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/napalm // tg: /datum/chemical_reaction/napalm
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_PLANT

/datum/chemical_reaction/narsour // tg: /datum/chemical_reaction/drink/narsour
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/neurine // tg: /datum/chemical_reaction/medicine/neurine
	required_temp = 100
	optimal_temp = 500
	overheat_temp = 700
	optimal_ph_min = 6.8
	optimal_ph_max = 10
	determin_ph_range = 8
	temp_exponent_factor = 0.8
	ph_exponent_factor = 2
	thermic_constant = 87
	H_ion_release = -0.05
	rate_up_lim = 15
	purity_min = 0.4
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/neurotoxin // tg: /datum/chemical_reaction/drink/neurotoxin
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/nitrous_oxide // tg: /datum/chemical_reaction/nitrous_oxide
	required_temp = 525
	optimal_temp = 550
	overheat_temp = 575
	temp_exponent_factor = 0.2
	thermic_constant = 35
	rate_up_lim = 25
	purity_min = 0.3
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL

/datum/chemical_reaction/nuka_cola // tg: /datum/chemical_reaction/drink/nuka_cola
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/oculine // tg: /datum/chemical_reaction/medicine/oculine
	optimal_ph_min = 4.8
	optimal_ph_max = 8.5
	determin_ph_range = 5
	ph_exponent_factor = 1.7
	thermic_constant = 1
	H_ion_release = 0.01
	rate_up_lim = 14.5
	purity_min = 0.3
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/old_timer // tg: /datum/chemical_reaction/drink/old_timer
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/oxandrolone // tg: /datum/chemical_reaction/medicine/oxandrolone
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/painkiller // tg: /datum/chemical_reaction/drink/painkiller
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/pair_carnivorous_blood // tg: /datum/chemical_reaction/slime/slimemonkey
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/patron // tg: /datum/chemical_reaction/drink/patron
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/pax // tg: /datum/chemical_reaction/pax
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/pen_acid // tg: /datum/chemical_reaction/medicine/pen_acid
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/peppermint_patty // tg: /datum/chemical_reaction/drink/peppermint_patty
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/pestkiller // tg: /datum/chemical_reaction/pestkiller
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/phenol // tg: /datum/chemical_reaction/phenol
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPONENT

/datum/chemical_reaction/phlogiston // tg: /datum/chemical_reaction/phlogiston
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/pina_colada // tg: /datum/chemical_reaction/drink/pina_colada
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/planet_cracker // tg: /datum/chemical_reaction/drink/planet_cracker
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/plantbgone // tg: /datum/chemical_reaction/plantbgone
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/plasmaflood
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/plasmasolidification // tg: /datum/chemical_reaction/plasma_solidification
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/potass_iodide // tg: /datum/chemical_reaction/medicine/potass_iodide
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/psicodine // tg: /datum/chemical_reaction/medicine/psicodine
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/pumpkin_latte // tg: /datum/chemical_reaction/drink/pumpkin_latte
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/pyrosium // tg: /datum/chemical_reaction/pyrosium
	required_temp = 0
	optimal_temp = 20
	overheat_temp = NO_OVERHEAT
	temp_exponent_factor = 10
	thermic_constant = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/pyrosium_oxygen // tg: /datum/chemical_reaction/pyrosium_oxygen
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/pyroxadone // tg: /datum/chemical_reaction/medicine/pyroxadone
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/quadruplesec // tg: /datum/chemical_reaction/drink/quadruplesec
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/quintuplesec // tg: /datum/chemical_reaction/drink/quintuplesec
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/ratvander
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/reagent_explosion/methsplosion // tg: /datum/chemical_reaction/reagent_explosion/methsplosion
	required_temp = 380
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/reagent_explosion/methsplosion/methboom2 // tg: /datum/chemical_reaction/reagent_explosion/methsplosion/methboom2
	required_temp = 300
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/reagent_explosion/nitroglycerin // tg: /datum/chemical_reaction/reagent_explosion/nitroglycerin
	required_temp = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/reagent_explosion/nitroglycerin_explosion // tg: /datum/chemical_reaction/reagent_explosion/nitroglycerin_explosion
	required_temp = 474
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/reagent_explosion/nitrous_oxide // tg: /datum/chemical_reaction/reagent_explosion/nitrous_oxide
	required_temp = 575
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE
	optimal_temp = 625
	overheat_temp = 900

/datum/chemical_reaction/reagent_explosion/potassium_explosion // tg: /datum/chemical_reaction/reagent_explosion/potassium_explosion
	required_temp = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/reagent_explosion/potassium_explosion/holyboom // tg: /datum/chemical_reaction/reagent_explosion/holyboom
	required_temp = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/reagent_explosion/teslium_lightning // tg: /datum/chemical_reaction/reagent_explosion/teslium_lightning
	required_temp = 0
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/reagent_explosion/teslium_lightning/heat // tg: /datum/chemical_reaction/reagent_explosion/teslium_lightning/heat
	required_temp = 474
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/red_mead // tg: /datum/chemical_reaction/drink/red_mead
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/red_queen // tg: /datum/chemical_reaction/drink/red_queen
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/regen_jelly // tg: /datum/chemical_reaction/medicine/regen_jelly
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/rezadone // tg: /datum/chemical_reaction/medicine/rezadone
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING

/datum/chemical_reaction/rotatium // tg: /datum/chemical_reaction/rotatium
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 3
	optimal_ph_max = 9
	determin_ph_range = 2.5
	temp_exponent_factor = 2.5
	ph_exponent_factor = 2
	thermic_constant = -425
	H_ion_release = 4
	rate_up_lim = 15
	purity_min = 0.6
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/royal_bee_jelly // tg: /datum/chemical_reaction/royal_bee_jelly
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/rubberneck // tg: /datum/chemical_reaction/drink/rubberneck
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/rum_coke // tg: /datum/chemical_reaction/drink/rum_coke
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/sake // tg: /datum/chemical_reaction/drink/sake
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/sal_acid // tg: /datum/chemical_reaction/medicine/sal_acid
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/salbutamol // tg: /datum/chemical_reaction/medicine/salbutamol
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OXY

/datum/chemical_reaction/salglu_solution // tg: /datum/chemical_reaction/medicine/salglu_solution
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/saltpetre // tg: /datum/chemical_reaction/saltpetre
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT | REACTION_TAG_COMPONENT

/datum/chemical_reaction/sarsaparilliansunset
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/sbiten // tg: /datum/chemical_reaction/drink/sbiten
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/screwdriver // tg: /datum/chemical_reaction/drink/screwdriver
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/sidecar // tg: /datum/chemical_reaction/drink/sidecar
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/silencer // tg: /datum/chemical_reaction/drink/silencer
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/singulo // tg: /datum/chemical_reaction/drink/singulo
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/slime/adamantine // tg: /datum/chemical_reaction/slime/adamantine
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/docility // tg: /datum/chemical_reaction/slime/docility
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/flight_potion // tg: /datum/chemical_reaction/slime/flight_potion
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/gender // tg: /datum/chemical_reaction/slime/gender
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/lavasteroid // tg: /datum/chemical_reaction/slime/slimespawn
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/pyroxadone // tg: /datum/chemical_reaction/medicine/pyroxadone
	optimal_ph_max = 10
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/slime/renaming // tg: /datum/chemical_reaction/slime/renaming
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeRNG // tg: /datum/chemical_reaction/slime/slimespawn
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slime_territory // tg: /datum/chemical_reaction/slime/slime_territory
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slime_transfer // tg: /datum/chemical_reaction/slime/slime_transfer
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimebloodlust // tg: /datum/chemical_reaction/slime/slimebloodlust
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimebomb // tg: /datum/chemical_reaction/slime/slimebomb
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimebork // tg: /datum/chemical_reaction/slime/slimebork
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimebork/drinks // tg: /datum/chemical_reaction/slime/slimebork/drinks
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimecamera // tg: /datum/chemical_reaction/slime/slimecamera
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimecasp // tg: /datum/chemical_reaction/slime/slimecasp
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimecell // tg: /datum/chemical_reaction/slime/slimecell
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimecrayon // tg: /datum/chemical_reaction/slime/slimecrayon
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimecrystal // tg: /datum/chemical_reaction/slime/slimecrystal
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeexplosion // tg: /datum/chemical_reaction/slime/slimeexplosion
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimefertilise
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/slime/slimefire // tg: /datum/chemical_reaction/slime/slimefire
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimefireproof // tg: /datum/chemical_reaction/slime/slimefireproof
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimefloor // tg: /datum/chemical_reaction/slime/slimefloor
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimefloor2 // tg: /datum/chemical_reaction/slime/slimefloor2
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimefoam
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/slime/slimefreeze // tg: /datum/chemical_reaction/slime/slimefreeze
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimefrost // tg: /datum/chemical_reaction/slime/slimefrost
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeglass // tg: /datum/chemical_reaction/slime/slimeglass
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeglow // tg: /datum/chemical_reaction/slime/slimeglow
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeinaprov // tg: /datum/chemical_reaction/slime/slimeinaprov
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimemetal // tg: /datum/chemical_reaction/slime/slimemetal
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimemobspawn // tg: /datum/chemical_reaction/slime/slimemobspawn
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimemobspawn/friendly // tg: /datum/chemical_reaction/slime/slimemobspawn/friendly
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimemobspawn/lesser // tg: /datum/chemical_reaction/slime/slimemobspawn/lesser
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimemobspawn/spider // tg: /datum/chemical_reaction/slime/slimemobspawn/spider
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimemonkey // tg: /datum/chemical_reaction/slime/slimemonkey
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimemutate // tg: /datum/chemical_reaction/slime/slimemutate
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimemutate2 // tg: /datum/chemical_reaction/slime/slimemutate2
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimemutator // tg: /datum/chemical_reaction/slime/slimemutator
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeoil
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/slime/slimeoverload // tg: /datum/chemical_reaction/slime/slimeoverload
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/slime/slimepaint // tg: /datum/chemical_reaction/slime/slimepaint
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeplasma // tg: /datum/chemical_reaction/slime/slimeplasma
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimepotion2 // tg: /datum/chemical_reaction/slime/slimepotion2
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimepsteroid // tg: /datum/chemical_reaction/slime/slimepsteroid
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimepsteroid2 // tg: /datum/chemical_reaction/slime/slimepsteroid2
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimepull // tg: /datum/chemical_reaction/liquid_dark_matter
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/slime/slimepush // tg: /datum/chemical_reaction/sorium
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/slime/slimeradio // tg: /datum/chemical_reaction/slime/slimeradio
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimeregen // tg: /datum/chemical_reaction/slime/slimeregen
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimesmoke // tg: /datum/chemical_reaction/slime/slimesmoke
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimespawn // tg: /datum/chemical_reaction/slime/slimespawn
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimespeed // tg: /datum/chemical_reaction/slime/slimespeed
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimestabilizer // tg: /datum/chemical_reaction/slime/slimestabilizer
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimestop // tg: /datum/chemical_reaction/slime/slimestop
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/slimesummonlegion // tg: /datum/chemical_reaction/slime/slimemonkey
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

/datum/chemical_reaction/slime/unstabletoxin
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/smart_foam // tg: /datum/chemical_reaction/smart_foam
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/smart_foaming_agent // tg: /datum/chemical_reaction/smart_foaming_agent
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/smoke_powder // tg: /datum/chemical_reaction/smoke_powder
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS

/datum/chemical_reaction/smoke_powder_smoke // tg: /datum/chemical_reaction/smoke_powder_smoke
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/snowwhite // tg: /datum/chemical_reaction/drink/snowwhite
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/soapification // tg: /datum/chemical_reaction/soapification
	required_temp = 374
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/sonic_powder // tg: /datum/chemical_reaction/sonic_powder
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/sonic_powder_deafen // tg: /datum/chemical_reaction/sonic_powder_deafen
	required_temp = 374
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/sorium // tg: /datum/chemical_reaction/sorium
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/sorium_vortex // tg: /datum/chemical_reaction/sorium_vortex
	required_temp = 474
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE

/datum/chemical_reaction/soy_latte // tg: /datum/chemical_reaction/drink/soy_latte
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/space_cleaner // tg: /datum/chemical_reaction/space_cleaner
	rate_up_lim = 40
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_COMPONENT

/datum/chemical_reaction/space_drugs // tg: /datum/chemical_reaction/space_drugs
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DRUG

/datum/chemical_reaction/spaceacillin // tg: /datum/chemical_reaction/medicine/spaceacillin
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/spacebeer // tg: /datum/chemical_reaction/drink/spacebeer
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/spraytan // tg: /datum/chemical_reaction/spraytan
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/spraytan2 // tg: /datum/chemical_reaction/spraytan2
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/squirt_cider // tg: /datum/chemical_reaction/drink/squirt_cider
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/stabilizing_agent // tg: /datum/chemical_reaction/stabilizing_agent
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE | REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT | REACTION_TAG_COMPONENT

/datum/chemical_reaction/sterilizine // tg: /datum/chemical_reaction/sterilizine
	thermic_constant = 50
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER

/datum/chemical_reaction/stinger // tg: /datum/chemical_reaction/drink/stinger
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/strange_reagent // tg: /datum/chemical_reaction/medicine/strange_reagent
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/sugar_rush // tg: /datum/chemical_reaction/drink/sugar_rush
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/sulfonal // tg: /datum/chemical_reaction/sulfonal
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 4
	optimal_ph_max = 9
	determin_ph_range = 2
	temp_exponent_factor = 1.5
	ph_exponent_factor = 1.5
	thermic_constant = 200
	H_ion_release = 5
	rate_up_lim = 10
	purity_min = 0.5
	reaction_flags = REACTION_PH_VOL_CONSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/surfactant // tg: /datum/chemical_reaction/surfactant
	thermic_constant = 50
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/synaptizine // tg: /datum/chemical_reaction/medicine/synaptizine
	optimal_temp = 700
	optimal_ph_max = 10
	temp_exponent_factor = 1.2
	ph_exponent_factor = 0.8
	thermic_constant = 50
	rate_up_lim = 35
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/syndicatebomb // tg: /datum/chemical_reaction/drink/syndicatebomb
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/tequila_sunrise // tg: /datum/chemical_reaction/drink/tequila_sunrise
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/teslium // tg: /datum/chemical_reaction/teslium
	required_temp = 400
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/thermite // tg: /datum/chemical_reaction/thermite
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE | REACTION_TAG_OTHER | REACTION_TAG_DAMAGING

/datum/chemical_reaction/thirteenloko // tg: /datum/chemical_reaction/drink/thirteenloko
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/threemileisland // tg: /datum/chemical_reaction/drink/threemileisland
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/torp_juice
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/toxins_special // tg: /datum/chemical_reaction/drink/toxins_special
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/trappist // tg: /datum/chemical_reaction/drink/trappist
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/triple_citrus // tg: /datum/chemical_reaction/drink/triple_citrus
	optimal_temp = 250
	optimal_ph_min = 0
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/turbo // tg: /datum/chemical_reaction/drink/turbo
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/vanillapudding // tg: /datum/chemical_reaction/food/vanillapudding
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/virus_food // tg: /datum/chemical_reaction/virus_food
	required_temp = 600
	optimal_temp = 625
	overheat_temp = 700

/datum/chemical_reaction/vodka // tg: /datum/chemical_reaction/drink/vodka
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/vodka_tonic // tg: /datum/chemical_reaction/drink/vodka_tonic
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/vodkamartini // tg: /datum/chemical_reaction/drink/vodkamartini
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/weedkiller // tg: /datum/chemical_reaction/weedkiller
	H_ion_release = -0.05
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_PLANT

/datum/chemical_reaction/whiskey_cola // tg: /datum/chemical_reaction/drink/whiskey_cola
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/whiskey_sour // tg: /datum/chemical_reaction/drink/whiskey_sour
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/whiskeysoda // tg: /datum/chemical_reaction/drink/whiskeysoda
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/white_russian // tg: /datum/chemical_reaction/drink/white_russian
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/wine
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY

/datum/chemical_reaction/wizz_fizz // tg: /datum/chemical_reaction/drink/wizz_fizz
	optimal_temp = 250
	optimal_ph_min = 2
	optimal_ph_max = 10
	temp_exponent_factor = 1
	H_ion_release = 0
	rate_up_lim = 60
	purity_min = 0
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER

/datum/chemical_reaction/zombiepowder // tg: /datum/chemical_reaction/zombiepowder
	required_temp = 100
	is_cold_recipe = FALSE
	optimal_temp = 450
	overheat_temp = 900
	optimal_ph_min = 5
	optimal_ph_max = 14
	determin_ph_range = 2
	temp_exponent_factor = 3
	ph_exponent_factor = 1
	thermic_constant = 150
	H_ion_release = -0.25
	rate_up_lim = 15
	purity_min = 0.3
	reaction_flags = REACTION_CLEAR_INVERSE
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

////////////////////////////// Reagenty //////////////////////////////

/datum/reagent/ammonia
	ph = 11.6

/datum/reagent/ants
	ph = 4.6

/datum/reagent/ash
	ph = 6.5

/datum/reagent/blood
	ph = 7.4

/datum/reagent/bluespace
	ph = 12

/datum/reagent/bromine
	ph = 7.8

/datum/reagent/carbon
	ph = 5

/datum/reagent/carbondioxide
	ph = 6

/datum/reagent/chlorine
	ph = 7.4

/datum/reagent/colorful_reagent
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/colorful_reagent

/datum/reagent/colorful_reagent/powder/blue
	ph = 10

/datum/reagent/colorful_reagent/powder/orange
	ph = 2

/datum/reagent/colorful_reagent/powder/purple
	ph = 13

/datum/reagent/colorful_reagent/powder/red
	ph = 0.5

/datum/reagent/colorful_reagent/powder/yellow
	ph = 5

/datum/reagent/consumable
	inverse_chem_val = 0.1
	inverse_chem = null

/datum/reagent/consumable/applejuice
	ph = 3.2

/datum/reagent/consumable/condensedcapsaicin
	ph = 7.4

/datum/reagent/consumable/entpoly
	ph = 12

/datum/reagent/consumable/ethanol
	ph = 7.33

/datum/reagent/consumable/ethanol/ale
	ph = 4.5

/datum/reagent/consumable/ethanol/bastion_bourbon
	ph = 4

/datum/reagent/consumable/ethanol/beepsky_smash
	ph = 2

/datum/reagent/consumable/ethanol/beer
	ph = 4

/datum/reagent/consumable/ethanol/beer/green
	ph = 6

/datum/reagent/consumable/ethanol/beer/light
	ph = 5

/datum/reagent/consumable/ethanol/cognac
	ph = 3.5

/datum/reagent/consumable/ethanol/fruit_wine
	ph = 4

/datum/reagent/consumable/ethanol/gin
	ph = 6.9

/datum/reagent/consumable/ethanol/gintonic
	ph = 3

/datum/reagent/consumable/ethanol/grappa
	ph = 3.5

/datum/reagent/consumable/ethanol/kahlua
	ph = 6

/datum/reagent/consumable/ethanol/lizardwine
	ph = 3

/datum/reagent/consumable/ethanol/patron
	ph = 4.5

/datum/reagent/consumable/ethanol/rum
	ph = 6.5

/datum/reagent/consumable/ethanol/rum_coke
	ph = 4

/datum/reagent/consumable/ethanol/tequila
	ph = 4

/datum/reagent/consumable/ethanol/threemileisland
	ph = 3.5

/datum/reagent/consumable/ethanol/torp_juice // tg: /datum/reagent/consumable/ethanol
	ph = 7.33

/datum/reagent/consumable/ethanol/vermouth
	ph = 3.25

/datum/reagent/consumable/ethanol/vodka
	ph = 8.1

/datum/reagent/consumable/ethanol/whiskey
	ph = 4.5

/datum/reagent/consumable/ethanol/wine
	ph = 3.45

/datum/reagent/consumable/frostoil
	ph = 13

/datum/reagent/consumable/lemonjuice
	ph = 2

/datum/reagent/consumable/limejuice
	ph = 2.2

/datum/reagent/consumable/milk
	ph = 6.5

/datum/reagent/consumable/orangejuice
	ph = 3.3

/datum/reagent/consumable/secretsauce
	ph = 6.1

/datum/reagent/consumable/tearjuice
	ph = 5

/datum/reagent/consumable/tinlux
	ph = 11.2

/datum/reagent/consumable/vitfro
	ph = 10.4

/datum/reagent/copper
	ph = 5.5

/datum/reagent/cryostylane
	ph = 8.6
	inverse_chem_val = 0.5

/datum/reagent/cryptobiolin
	ph = 11.9

/datum/reagent/diethylamine
	ph = 12

/datum/reagent/drug/aranesp
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/aranesp

/datum/reagent/drug/bath_salts
	ph = 8.2
	inverse_chem_val = 0.3

/datum/reagent/drug/happiness
	inverse_chem_val = 0.4
	inverse_chem = /datum/reagent/inverse/happiness

/datum/reagent/drug/krokodil
	ph = 9
	inverse_chem_val = 0.3

/datum/reagent/drug/methamphetamine
	ph = 5

/datum/reagent/drug/mushroomhallucinogen
	ph = 11

/datum/reagent/drug/nicotine
	ph = 8

/datum/reagent/drug/space_drugs
	ph = 9

/datum/reagent/drying_agent
	ph = 10.7

/datum/reagent/fluorine
	ph = 2

/datum/reagent/fluorosurfactant
	ph = 11

/datum/reagent/foaming_agent
	ph = 11.5

/datum/reagent/fuel
	ph = 4

/datum/reagent/fuel/unholywater
	ph = 6.5

/datum/reagent/fungalspores
	ph = 11

/datum/reagent/glycerol
	ph = 9

/datum/reagent/helgrasp // tg: /datum/reagent/inverse/helgrasp
	ph = 14

/datum/reagent/helgrasp/heretic // tg: /datum/reagent/inverse/helgrasp/heretic
	ph = 14

/datum/reagent/hellwater
	ph = 0.1

/datum/reagent/hydrogen
	ph = 0.1

/datum/reagent/impedrezene
	ph = 9.1

/datum/reagent/iodine
	ph = 4.5

/datum/reagent/iron
	ph = 6

/datum/reagent/liquidgibs // tg: /datum/reagent/consumable/liquidgibs
	ph = 7.45

/datum/reagent/lithium
	ph = 11.3

/datum/reagent/lye
	ph = 11.9

/datum/reagent/medicine/antihol
	ph = 4
	inverse_chem_val = 0.35
	inverse_chem = /datum/reagent/inverse/antihol

/datum/reagent/medicine/atropine
	ph = 12
	inverse_chem_val = 0.35
	inverse_chem = /datum/reagent/inverse/atropine

/datum/reagent/medicine/calomel
	ph = 1.5

/datum/reagent/medicine/cryoxadone
	ph = 11

/datum/reagent/medicine/diphenhydramine
	ph = 11.5

/datum/reagent/medicine/earthsblood
	ph = 11

/datum/reagent/medicine/ephedrine
	ph = 12
	inverse_chem_val = 0.4

/datum/reagent/medicine/epinephrine
	ph = 10.2

/datum/reagent/medicine/haloperidol
	ph = 4.3

/datum/reagent/medicine/inacusiate
	ph = 2
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/impurity/inacusiate

/datum/reagent/medicine/inaprovaline
	ph = 8.5

/datum/reagent/medicine/insulin
	ph = 6.7

/datum/reagent/medicine/leporazine
	ph = 8.4

/datum/reagent/medicine/mannitol
	ph = 10.4
	inverse_chem_val = 0.45
	inverse_chem = /datum/reagent/inverse

/datum/reagent/medicine/mine_salve
	ph = 2.6

/datum/reagent/medicine/modafinil
	ph = 7.89

/datum/reagent/medicine/morphine
	ph = 8.96

/datum/reagent/medicine/mutadone
	ph = 2

/datum/reagent/medicine/neurine
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/neurine

/datum/reagent/medicine/oculine
	ph = 10
	inverse_chem_val = 0.45
	inverse_chem = /datum/reagent/inverse/oculine

/datum/reagent/medicine/omnizine
	ph = 2

/datum/reagent/medicine/oxandrolone
	ph = 10.7
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/oxandrolone

/datum/reagent/medicine/pen_acid
	ph = 1
	inverse_chem_val = 0.4
	inverse_chem = /datum/reagent/inverse/pen_acid

/datum/reagent/medicine/potass_iodide
	ph = 12

/datum/reagent/medicine/psicodine
	ph = 9.12

/datum/reagent/medicine/pyroxadone
	ph = 12

/datum/reagent/medicine/rezadone
	ph = 12.2
	inverse_chem_val = 0.25
	inverse_chem = /datum/reagent/inverse/rezadone

/datum/reagent/medicine/sal_acid
	ph = 2.1
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/sal_acid

/datum/reagent/medicine/salbutamol
	ph = 2
	inverse_chem_val = 0.25

/datum/reagent/medicine/salglu_solution
	ph = 5.5

/datum/reagent/medicine/spaceacillin
	ph = 8.1
	inverse_chem_val = 0.3

/datum/reagent/medicine/strange_reagent
	ph = 0.5

/datum/reagent/medicine/synaphydramine
	ph = 5.2

/datum/reagent/medicine/synaptizine
	ph = 4

/datum/reagent/medicine/syndicate_nanites
	ph = 11

/datum/reagent/medicine/synthflesh // tg: /datum/reagent/medicine/c2/synthflesh
	ph = 7.2

/datum/reagent/nitrous_oxide
	ph = 5.8

/datum/reagent/oil // tg: /datum/reagent/fuel/oil
	ph = 4

/datum/reagent/oxygen
	ph = 9.2

/datum/reagent/pax
	ph = 15

/datum/reagent/phenol
	ph = 5.5

/datum/reagent/phosphorus
	ph = 6.5

/datum/reagent/plantnutriment
	ph = 3

/datum/reagent/plastic_polymers
	ph = 6

/datum/reagent/romerol
	ph = 0.5

/datum/reagent/royal_bee_jelly
	ph = 3

/datum/reagent/saltpetre
	ph = 11.2

/datum/reagent/serotrotium
	ph = 10

/datum/reagent/silicon
	ph = 10

/datum/reagent/smart_foaming_agent
	ph = 11.8

/datum/reagent/snail
	ph = 11

/datum/reagent/sodium
	ph = 11.6

/datum/reagent/space_cleaner
	ph = 5.5

/datum/reagent/space_cleaner/ez_clean
	ph = 2

/datum/reagent/space_cleaner/sterilizine
	ph = 10.5

/datum/reagent/spraytan
	ph = 5

/datum/reagent/stable_plasma
	ph = 1.5

/datum/reagent/sulfur
	ph = 4.5

/datum/reagent/toxin/acid
	ph = 2.75

/datum/reagent/toxin/acid/fluacid
	ph = 0.0

/datum/reagent/toxin/amatoxin
	ph = 13

/datum/reagent/toxin/anacea
	ph = 8

/datum/reagent/toxin/bonehurtingjuice
	ph = 3.1

/datum/reagent/toxin/carnivorousblood
	ph = 7.4

/datum/reagent/toxin/carpotoxin
	ph = 12

/datum/reagent/toxin/chloralhydrate
	ph = 11
	inverse_chem = /datum/reagent/impurity/chloralax

/datum/reagent/toxin/coffeepowder
	ph = 4.2

/datum/reagent/toxin/cyanide
	ph = 9.3

/datum/reagent/toxin/fakebeer
	ph = 2

/datum/reagent/toxin/fentanyl
	ph = 9

/datum/reagent/toxin/formaldehyde
	ph = 2.0
	inverse_chem = /datum/reagent/impurity/methanol

/datum/reagent/toxin/ghoulpowder
	ph = 14.5

/datum/reagent/toxin/heparin
	ph = 11.6

/datum/reagent/toxin/itching_powder
	ph = 7

/datum/reagent/toxin/lexorin
	ph = 1.2

/datum/reagent/toxin/lipolicide
	ph = 6
	inverse_chem = /datum/reagent/impurity/ipecacide

/datum/reagent/toxin/mimesbane
	ph = 1.7

/datum/reagent/toxin/mindbreaker
	ph = 11
	inverse_chem = /datum/reagent/impurity/rosenol

/datum/reagent/toxin/mutagen
	ph = 2.3

/datum/reagent/toxin/mutetoxin
	ph = 12.2

/datum/reagent/toxin/pestkiller
	ph = 3.2

/datum/reagent/toxin/plantbgone
	ph = 2.7

/datum/reagent/toxin/plantbgone/weedkiller
	ph = 3

/datum/reagent/toxin/plasma
	ph = 4

/datum/reagent/toxin/rotatium
	ph = 6.2

/datum/reagent/toxin/slimejelly
	ph = 10

/datum/reagent/toxin/spore
	ph = 11

/datum/reagent/toxin/spore_burning
	ph = 13

/datum/reagent/toxin/sulfonal
	ph = 6

/datum/reagent/toxin/teapowder
	ph = 4.9

/datum/reagent/toxin/zombiepowder
	ph = 13

/datum/reagent/uranium
	ph = 4

/datum/reagent/uranium/radium
	ph = 10

/datum/reagent/water/holywater
	ph = 7.5
