// Cechy wyglądu psyfozy i diony z BeeStation-Hornet (sprite_accessories.dm i organy zewnętrzne).
// U Bee to organy zewnętrzne z nakładkami części ciała, u nas zwykłe dna.features rysowane w handle_mutant_bodyparts()
// gatunku. Stany ikon mają nazwy jak u Bee: m_[klucz]_[icon_state]_ADJ.

/// Klucz cechy -> nazwa globalnej listy akcesoriów
GLOBAL_LIST_INIT(bee_species_feature_lists, list(
	FEATURE_PSYPHOZA_CAP = "psyphoza_cap_list",
	FEATURE_DIONA_LEAVES = "diona_leaves_list",
	FEATURE_DIONA_THORNS = "diona_thorns_list",
	FEATURE_DIONA_FLOWERS = "diona_flowers_list",
	FEATURE_DIONA_MOSS = "diona_moss_list",
	FEATURE_DIONA_MUSHROOM = "diona_mushroom_list",
	FEATURE_DIONA_ANTENNAE = "diona_antennae_list",
	FEATURE_DIONA_EYES = "diona_eyes_list",
	FEATURE_DIONA_PBODY = "diona_pbody_list",
))

GLOBAL_LIST_INIT(psyphoza_cap_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/psyphoza_cap))
GLOBAL_LIST_INIT(diona_leaves_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_leaves))
GLOBAL_LIST_INIT(diona_thorns_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_thorns))
GLOBAL_LIST_INIT(diona_flowers_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_flowers))
GLOBAL_LIST_INIT(diona_moss_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_moss))
GLOBAL_LIST_INIT(diona_mushroom_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_mushroom))
GLOBAL_LIST_INIT(diona_antennae_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_antennae))
GLOBAL_LIST_INIT(diona_eyes_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_eyes))
GLOBAL_LIST_INIT(diona_pbody_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_pbody))

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
		// U Bee wyrostki na tułowiu chowa strój zakrywający kombinezon, a oczy diony to, co zakrywa oczy albo włosy
		if(!on_head && suit_hides_body)
			continue
		if(key == FEATURE_DIONA_EYES && ((H.head?.flags_inv | H.wear_mask?.flags_inv) & (HIDEEYES | HIDEHAIR)))
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
	H.remove_overlay(BODY_ADJ_LAYER)
	var/list/existing = H.overlays_standing[BODY_ADJ_LAYER]
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

// Wyrostki diony (bez barwienia, jak u Bee)

/datum/sprite_accessory/diona_leaves
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_leaves/none
	name = "Brak"
	icon_state = "none"

/// U Bee kilka wariantów nosi tę samą nazwę, więc w liście zostaje tylko ostatni (tułów)
/datum/sprite_accessory/diona_leaves/torso
	name = "Liście"
	icon_state = "chest"

/datum/sprite_accessory/diona_thorns
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_thorns/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_thorns/head
	name = "Ciernie (głowa)"
	icon_state = "head"

/datum/sprite_accessory/diona_thorns/torso
	name = "Ciernie (tułów)"
	icon_state = "chest"

/datum/sprite_accessory/diona_flowers
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_flowers/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_flowers/head
	name = "Kwiaty (głowa)"
	icon_state = "head"

/datum/sprite_accessory/diona_flowers/torso
	name = "Kwiaty (tułów)"
	icon_state = "chest"

/datum/sprite_accessory/diona_moss
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_moss/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_moss/torso
	name = "Mech"
	icon_state = "chest"

/datum/sprite_accessory/diona_mushroom
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_mushroom/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_mushroom/head
	name = "Grzyb"
	icon_state = "head"

/datum/sprite_accessory/diona_antennae
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_antennae/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_antennae/head
	name = "Czułki"
	icon_state = "head"

/datum/sprite_accessory/diona_eyes
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_eyes/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_eyes/bug_eyes
	name = "Oczy owada"
	icon_state = "bugeyes_head"

/datum/sprite_accessory/diona_eyes/human_eyes
	name = "Ludzkie oczy"
	icon_state = "humaneyes_head"

/// U Bee są dwa warianty „Small Horns” z tym samym stanem ikony, zostaje jeden
/datum/sprite_accessory/diona_eyes/small_horns
	name = "Małe rogi"
	icon_state = "smallhorns_head"

/datum/sprite_accessory/diona_eyes/horns
	name = "Rogi"
	icon_state = "horns_head"

/datum/sprite_accessory/diona_eyes/treebeard
	name = "Drzewiec"
	icon_state = "treebeard_head"

/datum/sprite_accessory/diona_eyes/tinyeye
	name = "Maleńkie oko"
	icon_state = "tinyeye_head"

/datum/sprite_accessory/diona_eyes/eyebrow
	name = "Brew"
	icon_state = "eyebrow_head"

/datum/sprite_accessory/diona_eyes/bullhorn
	name = "Bycze rogi"
	icon_state = "bullhorn_head"

/datum/sprite_accessory/diona_eyes/mono_eye
	name = "Jedno oko"
	icon_state = "monoeye_head"

/datum/sprite_accessory/diona_eyes/trioptics
	name = "Troje oczu"
	icon_state = "trioptics_head"

/datum/sprite_accessory/diona_eyes/lopsided
	name = "Krzywe oczy"
	icon_state = "lopsided_head"

/datum/sprite_accessory/diona_eyes/helmethead
	name = "Hełmogłowa"
	icon_state = "helmethead_head"

/datum/sprite_accessory/diona_eyes/eyestalk
	name = "Oko na szypułce"
	icon_state = "eyestalk_head"

/datum/sprite_accessory/diona_eyes/periscope
	name = "Peryskop"
	icon_state = "periscope_head"

/datum/sprite_accessory/diona_eyes/glorp
	name = "Glorp"
	icon_state = "glorp_head"

/datum/sprite_accessory/diona_eyes/oak
	name = "Dąb"
	icon_state = "oak_head"

/datum/sprite_accessory/diona_eyes/stump
	name = "Pniak"
	icon_state = "stump_head"

/datum/sprite_accessory/diona_eyes/snout
	name = "Pysk"
	icon_state = "snout_head"

/datum/sprite_accessory/diona_pbody
	icon = 'aquila/icons/mob/species/diona/markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_pbody/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/diona_pbody/pbody
	name = "P-Body"
	icon_state = "chest"

/datum/sprite_accessory/diona_pbody/blinking
	name = "Mrugające P-Body"
	icon_state = "blinking_chest"
