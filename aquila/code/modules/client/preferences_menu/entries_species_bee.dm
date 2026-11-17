// Cechy psyfozy i diony w oknie postaci (u Bee species_features/psyphoza.dm i diona.dm).
// Wartość trzymamy w active_character.features, jak resztę cech gatunków.

/// Wspólny podgląd: część ciała gatunku z nałożoną cechą, przybliżona na głowę i tułów jak u Bee
/datum/preference/choiced/species_feature/bee
	abstract_type = /datum/preference/choiced/species_feature/bee
	should_generate_icons = TRUE
	icon_base_file = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	icon_color = "#59CE00"
	/// Części ciała pod cechą na podglądzie
	var/list/preview_parts = list("diona_chest", "diona_head", "diona_l_arm", "diona_r_arm", "diona_l_leg", "diona_r_leg", "diona_l_hand", "diona_r_hand")

/datum/preference/choiced/species_feature/bee/icon_for(value)
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	for(var/part in preview_parts)
		var/icon/part_icon = icon(icon_base_file, part, SOUTH, 1)
		if(icon_color)
			part_icon.Blend(icon_color, ICON_MULTIPLY)
		final_icon.Blend(part_icon, ICON_OVERLAY)
	var/list/source = GLOB.vars[accessory_list]
	var/datum/sprite_accessory/accessory = source[value]
	if(accessory?.icon_state && accessory.icon_state != "none")
		var/state = "m_[feature_key]_[accessory.icon_state]_ADJ"
		if(state in aq_pref_icon_states(accessory.icon))
			var/icon/feature_icon = icon(accessory.icon, state, SOUTH, 1)
			if(accessory.color_src == MUTCOLORS && icon_color)
				feature_icon.Blend(icon_color, ICON_MULTIPLY)
			final_icon.Blend(feature_icon, ICON_OVERLAY)
	final_icon.Crop(8, 17, 23, 32)
	final_icon.Scale(32, 32)
	return final_icon

/datum/preference/choiced/species_feature/bee/psyphoza_cap
	db_key = "feature_psyphoza_cap"
	feature_key = FEATURE_PSYPHOZA_CAP
	relevant_mutant_bodypart = FEATURE_PSYPHOZA_CAP
	main_feature_name = "Kapelusz"
	accessory_list = "psyphoza_cap_list"
	icon_base_file = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon_color = null
	preview_parts = list("psyphoza_chest", "psyphoza_head")

/datum/preference/choiced/species_feature/bee/diona_leaves
	db_key = "feature_diona_leaves"
	feature_key = FEATURE_DIONA_LEAVES
	relevant_mutant_bodypart = FEATURE_DIONA_LEAVES
	main_feature_name = "Liście"
	accessory_list = "diona_leaves_list"

/datum/preference/choiced/species_feature/bee/diona_thorns
	db_key = "feature_diona_thorns"
	feature_key = FEATURE_DIONA_THORNS
	relevant_mutant_bodypart = FEATURE_DIONA_THORNS
	main_feature_name = "Ciernie"
	accessory_list = "diona_thorns_list"

/datum/preference/choiced/species_feature/bee/diona_flowers
	db_key = "feature_diona_flowers"
	feature_key = FEATURE_DIONA_FLOWERS
	relevant_mutant_bodypart = FEATURE_DIONA_FLOWERS
	main_feature_name = "Kwiaty"
	accessory_list = "diona_flowers_list"

/datum/preference/choiced/species_feature/bee/diona_moss
	db_key = "feature_diona_moss"
	feature_key = FEATURE_DIONA_MOSS
	relevant_mutant_bodypart = FEATURE_DIONA_MOSS
	main_feature_name = "Mech"
	accessory_list = "diona_moss_list"

/datum/preference/choiced/species_feature/bee/diona_mushroom
	db_key = "feature_diona_mushroom"
	feature_key = FEATURE_DIONA_MUSHROOM
	relevant_mutant_bodypart = FEATURE_DIONA_MUSHROOM
	main_feature_name = "Grzyby"
	accessory_list = "diona_mushroom_list"

/datum/preference/choiced/species_feature/bee/diona_antennae
	db_key = "feature_diona_antennae"
	feature_key = FEATURE_DIONA_ANTENNAE
	relevant_mutant_bodypart = FEATURE_DIONA_ANTENNAE
	main_feature_name = "Czułki"
	accessory_list = "diona_antennae_list"

/datum/preference/choiced/species_feature/bee/diona_eyes
	db_key = "feature_diona_eyes"
	feature_key = FEATURE_DIONA_EYES
	relevant_mutant_bodypart = FEATURE_DIONA_EYES
	main_feature_name = "Oczy diony"
	accessory_list = "diona_eyes_list"

/datum/preference/choiced/species_feature/bee/diona_pbody
	db_key = "feature_diona_pbody"
	feature_key = FEATURE_DIONA_PBODY
	relevant_mutant_bodypart = FEATURE_DIONA_PBODY
	main_feature_name = "P-Body"
	accessory_list = "diona_pbody_list"
