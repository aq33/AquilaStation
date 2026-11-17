// Cechy Voxa w oknie postaci (u Yoga yogstation/code/modules/client/preferences/species_features/vox.dm).
// Wartości trzymamy w active_character.features, kolory piór we włosach i zaroście postaci, jak u Yoga.

/// Sylwetka Voxa do podglądów (odcień, kierunek, wybrane strefy)
/proc/vox_pref_body_icon(tone = VOX_DEFAULT_SKIN_TONE, dir = SOUTH, list/zones)
	var/icon/body = icon('icons/effects/effects.dmi', "nothing")
	if(!zones)
		zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_HEAD)
	for(var/zone in zones)
		body.Blend(icon(VOX_BODYPARTS_ICON, "[SPECIES_VOX]_[zone]_[tone]", dir), ICON_OVERLAY)
	return body

/// Ciemny sprite Voxa z dodanym kolorem (u Yoga COLOR_BLEND_ADD)
/proc/vox_pref_add_color(icon_file, state, color, dir = SOUTH)
	var/icon/I = icon(icon_file, state, dir)
	if(color)
		I.Blend(color, ICON_ADD)
	return I

/datum/preference/choiced/species_feature/vox
	abstract_type = /datum/preference/choiced/species_feature/vox
	should_generate_icons = TRUE

/datum/preference/choiced/species_feature/vox/init_possible_values()
	var/list/source = GLOB.vars[accessory_list]
	return source.Copy()

/// Odcień łusek (u Yoga cecha drugorzędna z kolorami, u nas główna z podglądem ciała)
/datum/preference/choiced/species_feature/vox/skin_tone
	db_key = "feature_vox_skin_tone"
	feature_key = FEATURE_VOX_SKIN_TONE
	relevant_mutant_bodypart = FEATURE_VOX_SKIN_TONE
	main_feature_name = "Łuski"

/datum/preference/choiced/species_feature/vox/skin_tone/init_possible_values()
	return assoc_to_keys(GLOB.vox_skin_tones)

/datum/preference/choiced/species_feature/vox/skin_tone/get_display_names()
	return GLOB.vox_skin_tones.Copy()

/datum/preference/choiced/species_feature/vox/skin_tone/icon_for(value)
	return vox_pref_body_icon(value)

/datum/preference/choiced/species_feature/vox/quills
	db_key = "feature_vox_quills"
	feature_key = FEATURE_VOX_QUILLS
	relevant_mutant_bodypart = FEATURE_VOX_QUILLS
	main_feature_name = "Pióra"
	accessory_list = "vox_quills_list"
	preference_spritesheet = PREFERENCE_SHEET_LARGE

/datum/preference/choiced/species_feature/vox/quills/icon_for(value)
	var/icon/final_icon = vox_pref_body_icon(zones = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD))
	var/datum/sprite_accessory/accessory = GLOB.vox_quills_list[value]
	if(accessory?.icon_state && (accessory.icon_state in aq_pref_icon_states(accessory.icon)))
		final_icon.Blend(vox_pref_add_color(accessory.icon, accessory.icon_state, "#c86020"), ICON_OVERLAY)
	return aq_pref_head_crop(final_icon)

/datum/preference/choiced/species_feature/vox/quills/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_vox_quills_color"
	return data

/datum/preference/choiced/species_feature/vox/facial_quills
	db_key = "feature_vox_facial_quills"
	feature_key = FEATURE_VOX_FACIAL_QUILLS
	relevant_mutant_bodypart = FEATURE_VOX_FACIAL_QUILLS
	main_feature_name = "Pióra na twarzy"
	accessory_list = "vox_facial_quills_list"

/datum/preference/choiced/species_feature/vox/facial_quills/icon_for(value)
	var/icon/final_icon = vox_pref_body_icon(zones = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD))
	var/datum/sprite_accessory/accessory = GLOB.vox_facial_quills_list[value]
	if(accessory?.icon_state && (accessory.icon_state in aq_pref_icon_states(accessory.icon)))
		final_icon.Blend(vox_pref_add_color(accessory.icon, accessory.icon_state, "#c86020"), ICON_OVERLAY)
	return aq_pref_head_crop(final_icon)

/datum/preference/choiced/species_feature/vox/facial_quills/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_vox_facial_quills_color"
	return data

/datum/preference/choiced/species_feature/vox/body_markings
	db_key = "feature_vox_body_markings"
	feature_key = FEATURE_VOX_BODY_MARKINGS
	relevant_mutant_bodypart = FEATURE_VOX_BODY_MARKINGS
	main_feature_name = "Znaczenia na ciele"
	accessory_list = "vox_body_markings_list"

/datum/preference/choiced/species_feature/vox/body_markings/icon_for(value)
	var/icon/final_icon = vox_pref_body_icon()
	var/datum/sprite_accessory/vox_body_markings/accessory = GLOB.vox_body_markings_list[value]
	if(istype(accessory))
		var/list/states = aq_pref_icon_states(accessory.icon)
		for(var/zone in accessory.body_slots)
			var/state = "m_[zone]_[accessory.icon_state]_ADJ"
			if(state in states)
				final_icon.Blend(vox_pref_add_color(accessory.icon, state, "#d0d0d0"), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/species_feature/vox/tail_markings
	db_key = "feature_vox_tail_markings"
	feature_key = FEATURE_VOX_TAIL_MARKINGS
	relevant_mutant_bodypart = FEATURE_VOX_TAIL_MARKINGS
	main_feature_name = "Znaczenia ogona"
	accessory_list = "vox_tail_markings_list"

/datum/preference/choiced/species_feature/vox/tail_markings/icon_for(value)
	var/icon/final_icon = icon('aquila/icons/mob/species/vox/tails.dmi', "m_tail_[VOX_DEFAULT_SKIN_TONE]_BEHIND", EAST)
	final_icon.Blend(vox_pref_body_icon(dir = EAST, zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST)), ICON_OVERLAY)
	var/datum/sprite_accessory/accessory = GLOB.vox_tail_markings_list[value]
	if(accessory?.icon_state)
		var/state = "m_vox_tail_markings_[accessory.icon_state]_BEHIND"
		if(state in aq_pref_icon_states(accessory.icon))
			final_icon.Blend(vox_pref_add_color(accessory.icon, state, "#e8e8e8", EAST), ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/species_feature/vox/tail_markings/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_vox_tail_markings_color"
	return data

// Kolory: pióra głowy biorą kolor i gradient włosów, pióra twarzy kolor zarostu (jak u Yoga)

/datum/preference/color/hair_color/vox
	db_key = "feature_vox_quills_color"
	relevant_species_trait = null
	relevant_mutant_bodypart = FEATURE_VOX_QUILLS

/datum/preference/color/facial_hair_color/vox
	db_key = "feature_vox_facial_quills_color"
	relevant_species_trait = null
	relevant_mutant_bodypart = FEATURE_VOX_FACIAL_QUILLS

/datum/preference/choiced/gradient_style/vox
	db_key = "feature_vox_quills_gradient"
	relevant_species_trait = null
	relevant_mutant_bodypart = FEATURE_VOX_QUILLS

/datum/preference/color/gradient_color/vox
	db_key = "feature_vox_quills_gradient_color"
	relevant_species_trait = null
	relevant_mutant_bodypart = FEATURE_VOX_QUILLS

/datum/preference/color/vox_tail_markings_color
	db_key = "feature_vox_tail_markings_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	feature_key = FEATURE_VOX_TAIL_MARKINGS_COLOR
	relevant_mutant_bodypart = FEATURE_VOX_TAIL_MARKINGS_COLOR
	can_randomize = TRUE

// Wyposażenie do oddychania na start (u Yoga vox_mask i vox_tank_type)

/datum/preference/choiced/vox_mask
	db_key = "feature_vox_mask"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = FEATURE_VOX_MASK
	relevant_mutant_bodypart = FEATURE_VOX_MASK

/datum/preference/choiced/vox_mask/init_possible_values()
	return list(VOX_MASK_BREATH, VOX_MASK_RESPIRATOR)

/datum/preference/choiced/vox_mask/get_display_names()
	return list(VOX_MASK_BREATH = "Maska oddechowa", VOX_MASK_RESPIRATOR = "Respirator")

/datum/preference/choiced/vox_tank
	db_key = "feature_vox_tank"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = FEATURE_VOX_TANK
	relevant_mutant_bodypart = FEATURE_VOX_TANK

/datum/preference/choiced/vox_tank/init_possible_values()
	return list(VOX_TANK_SMALL, VOX_TANK_LARGE)

/datum/preference/choiced/vox_tank/get_display_names()
	return list(VOX_TANK_SMALL = "Mała (na pasku)", VOX_TANK_LARGE = "Duża (na plecach)")
