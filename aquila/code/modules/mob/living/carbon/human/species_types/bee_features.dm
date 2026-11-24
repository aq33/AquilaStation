// Cechy wyglądu psyfozy z BeeStation-Hornet (sprite_accessories.dm i organy zewnętrzne).
// U Bee to organy zewnętrzne z nakładkami części ciała, u nas zwykłe dna.features rysowane w handle_mutant_bodyparts()
// gatunku. Stany ikon mają nazwy jak u Bee: m_[klucz]_[icon_state]_ADJ.

/// Klucz cechy -> nazwa globalnej listy akcesoriów
GLOBAL_LIST_INIT(bee_species_feature_lists, list(
	FEATURE_PSYPHOZA_CAP = "psyphoza_cap_list",
))

GLOBAL_LIST_INIT(psyphoza_cap_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/psyphoza_cap))

/// Akcesorium wybrane w cesze albo null
/proc/bee_species_accessory(mob/living/carbon/human/H, key)
	var/list/accessories = GLOB.vars[GLOB.bee_species_feature_lists[key]]
	if(!accessories || !H?.dna)
		return null
	return accessories[H.dna.features[key]]

/// Dorysowuje cechy z listy na warstwę BODY_ADJ_LAYER. Wołane po bazowym handle_mutant_bodyparts(), który tę warstwę buduje od nowa.
/datum/species/proc/bee_add_feature_overlays(mob/living/carbon/human/H, list/keys, forced_colour)
	var/list/standing = list()
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	var/suit_hides_body = H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && !is_type_in_list(src, H.wear_suit.species_exception)
	for(var/key in keys)
		var/datum/sprite_accessory/accessory = bee_species_accessory(H, key)
		if(!accessory || !accessory.icon_state || accessory.icon_state == "none")
			continue
		var/on_head = key == FEATURE_PSYPHOZA_CAP || findtext(accessory.icon_state, "head")
		if(on_head && !head)
			continue
		// Kapelusz psyfozy chowa się pod każdym nakryciem głowy (rysował się nad hełmem i kaskiem)
		if(key == FEATURE_PSYPHOZA_CAP && H.head)
			continue
		// U Bee cechy na tułowiu chowa strój zakrywający kombinezon
		if(!on_head && suit_hides_body)
			continue
			continue
		var/mutable_appearance/overlay = mutable_appearance(accessory.icon, "m_[key]_[accessory.icon_state]_ADJ", -BODY_ADJ_LAYER)
		if(!HAS_TRAIT(H, TRAIT_HUSK))
			if(forced_colour)
				overlay.color = forced_colour
			else if(accessory.color_src == MUTCOLORS)
				overlay.color = "#[H.dna.features["mcolor"]]"
		standing += overlay
	if(!length(standing))
		return
	var/list/existing = H.overlays_standing[BODY_ADJ_LAYER] // przed remove_overlay, które zeruje warstwę
	H.remove_overlay(BODY_ADJ_LAYER)
	if(islist(existing))
		standing = existing + standing
	else if(existing)
		standing += existing
	H.overlays_standing[BODY_ADJ_LAYER] = standing
	H.apply_overlay(BODY_ADJ_LAYER)

/// Uzupełnia brakujące albo nieznane wartości cech domyślnymi (stare zapisy postaci ich nie mają)
/datum/species/proc/bee_sanitize_features(mob/living/carbon/human/H)
	for(var/key in default_features)
		var/list_name = GLOB.bee_species_feature_lists[key]
		if(!list_name)
			continue
		var/list/accessories = GLOB.vars[list_name]
		if(!(H.dna.features[key] in accessories))
			H.dna.features[key] = default_features[key]

// Kapelusze psyfozy. Nazwy to polskie nazwy grzybów (u Bee łacińskie i angielskie).

/datum/sprite_accessory/psyphoza_cap
	icon = 'aquila/icons/mob/species/psyphoza/caps.dmi'
	color_src = MUTCOLORS

/datum/sprite_accessory/psyphoza_cap/wide
	name = "Portobello"
	icon_state = "wide"

/datum/sprite_accessory/psyphoza_cap/cup
	name = "Kurka"
	icon_state = "cup"

/datum/sprite_accessory/psyphoza_cap/round
	name = "Łysiczka"
	icon_state = "round"

/datum/sprite_accessory/psyphoza_cap/flat
	name = "Boczniak"
	icon_state = "flat"

/datum/sprite_accessory/psyphoza_cap/string
	name = "Aseroe"
	icon_state = "string"

/datum/sprite_accessory/psyphoza_cap/fuzz
	name = "Enoki"
	icon_state = "fuzz"

/datum/sprite_accessory/psyphoza_cap/rizz
	name = "Naparstniczka"
	icon_state = "rizz"

/datum/sprite_accessory/psyphoza_cap/brain
	name = "Żółciak"
	icon_state = "brain"

/datum/sprite_accessory/psyphoza_cap/crown
	name = "Smardz"
	icon_state = "crown"

/datum/sprite_accessory/psyphoza_cap/sponge
	name = "Piestrzyca"
	icon_state = "sponge"
