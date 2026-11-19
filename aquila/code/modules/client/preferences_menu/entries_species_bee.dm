// Cechy psyfozy w oknie postaci (u Bee species_features/psyphoza.dm).
// Wartość trzymamy w active_character.features, jak resztę cech gatunków.

/// Wspólny podgląd: część ciała gatunku z nałożoną cechą, przybliżona na głowę i tułów jak u Bee
/datum/preference/choiced/species_feature/bee
	abstract_type = /datum/preference/choiced/species_feature/bee
	should_generate_icons = TRUE
	icon_base_file = 'aquila/icons/mob/species/psyphoza/bodyparts.dmi'
	icon_color = null
	/// Części ciała pod cechą na podglądzie
	var/list/preview_parts = list("psyphoza_chest", "psyphoza_head")

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
