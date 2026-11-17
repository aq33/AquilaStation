// Wspólne części ras z Goonstation (mops i żaba): odmiany umaszczenia w oknie postaci i części ciała zależne od odmiany.
// W Goonie to mutantrace'y wybierane cechą, a umaszczenie to special_styles (osobny plik .dmi na odmianę).
// U nas wszystkie odmiany rasy są w jednym .dmi jako stany [rasa]_[odmiana]_[część], a część ciała bierze odmianę z dna.features.
// Grafika: Goonstation (icons/mob/pug/, icons/mob/amphibian/, CC BY-NC-SA 3.0), przełożona na nasz szablon części ciała.

/obj/item/bodypart
	/// Klucz w dna.features z odmianą rasy z Goona (null = część ciała bez odmian)
	var/goon_variant_feature
	/// Przedrostek stanów ikony, np. "pug" -> "pug_fawn_head"
	var/goon_variant_prefix
	/// Nazwa globalnej listy odmian (odmiana -> polska nazwa); pierwsza jest domyślna
	var/goon_variant_list

/obj/item/bodypart/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	. = ..()
	if(!goon_variant_feature || dropping_limb || no_update)
		return
	var/mob/living/carbon/human/H = source || owner
	if(!ishuman(H) || !H.dna)
		return
	limb_id = "[goon_variant_prefix]_[goon_species_variant(H, goon_variant_feature, goon_variant_list)]"

/// Odmiana rasy z Goona zapisana w DNA, a gdy jej brak albo jest nieznana: pierwsza z listy
/proc/goon_species_variant(mob/living/carbon/human/H, feature, list_name)
	var/list/variants = GLOB.vars[list_name]
	var/variant = H?.dna?.features[feature]
	if(variant in variants)
		return variant
	return variants[1]

/// Wybór odmiany (umaszczenia) rasy z Goona w oknie postaci. Guziki z ikonami, bez wpisu w TSX.
/datum/preference/choiced/goon_variant
	abstract_type = /datum/preference/choiced/goon_variant
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE
	can_randomize = TRUE
	/// Plik z częściami ciała rasy
	var/icon_file
	/// Przedrostek stanów, jak goon_variant_prefix części ciała
	var/state_prefix
	/// Nazwa globalnej listy odmian (odmiana -> polska nazwa)
	var/variant_list

/datum/preference/choiced/goon_variant/init_possible_values()
	var/list/variants = GLOB.vars[variant_list]
	var/list/values = list()
	for(var/variant in variants)
		values += variant
	return values

/datum/preference/choiced/goon_variant/get_display_names()
	var/list/variants = GLOB.vars[variant_list]
	return variants.Copy()

/// Stare postacie i świeżo wybrana rasa nie mają odmiany: pokazujemy domyślną, tak jak rysuje ją ciało
/datum/preference/choiced/goon_variant/read_value(datum/preferences/prefs)
	var/list/variants = GLOB.vars[variant_list]
	return ..() || variants[1]

/datum/preference/choiced/goon_variant/icon_for(value)
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	for(var/part in list("chest", "l_arm", "r_arm", "l_hand", "r_hand", "head"))
		final_icon.Blend(icon(icon_file, "[state_prefix]_[value]_[part]", SOUTH, 1), ICON_OVERLAY)
	return aq_pref_head_crop(final_icon)
