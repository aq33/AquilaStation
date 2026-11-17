// Floranie (Floran), port z Monkestation2.0 (monkestation/code/modules/mob/living/carbon/human/species_type/floran.dm
// i powiązane pliki: części ciała, liście, język, oczy, preferencje). Roślinni łowcy ze Starbounda.
// U Monke liście i kwiaty na głowie to zewnętrzne organy tg. U nas rysuje je sam gatunek, bo nasze części ciała są starsze.

#define FLORAN_ICON 'aquila/icons/mob/species/floran/floran.dmi'
#define FLORAN_DEFAULT_SKIN "8FC433"
#define FLORAN_DEFAULT_LEAVES "FF99FF"

/datum/species/floran
	name = "\improper Floranin"
	id = SPECIES_FLORAN
	default_color = FLORAN_DEFAULT_SKIN
	species_traits = list(MUTCOLORS, NO_UNDERWEAR)
	inherent_traits = list(TRAIT_EASYDISMEMBER, TRAIT_LIMBATTACHMENT) // Monke: TRAIT_LIMBATTACHMENT na klatce piersiowej
	inherent_factions = list("plants", "vines")
	default_features = list(
		"mcolor" = FLORAN_DEFAULT_SKIN,
		"floran_leaves" = "Furnivour",
		"floran_leaves_color" = FLORAN_DEFAULT_LEAVES,
		"floran_hair" = "None",
		"floran_hiss" = 3,
		"body_size" = "Normal",
	)
	use_skintones = FALSE
	nojumpsuit = TRUE // Monke: TRAIT_NO_JUMPSUIT
	speedmod = -0.1 // u Monke nogi: speed_modifier -0.05 każda
	burnmod = 1.5 // u Monke burn_modifier 1.5 na każdej części ciała
	heatmod = 0.67
	coldmod = 1.5
	punchdamage = 5 // u Monke cięcie pazurami za 4 zamiast ludzkich 1-10
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/plant
	exotic_blood = /datum/reagent/water // Monke: BLOOD_TYPE_H2O, woda uzupełnia krew
	inert_mutation = /datum/mutation/spores
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/plant
	mutanttongue = /obj/item/organ/tongue/floran
	mutanteyes = /obj/item/organ/eyes/floran
	ass_image = 'icons/ass/asspodperson.png'
	speech_sound = "pod"

	species_chest = /obj/item/bodypart/chest/floran
	species_head = /obj/item/bodypart/head/floran
	species_l_arm = /obj/item/bodypart/l_arm/floran
	species_r_arm = /obj/item/bodypart/r_arm/floran
	species_l_leg = /obj/item/bodypart/l_leg/floran
	species_r_leg = /obj/item/bodypart/r_leg/floran

/mob/living/carbon/human/species/floran
	race = /datum/species/floran

/datum/species/floran/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	for(var/feature in list("floran_leaves", "floran_leaves_color", "floran_hair", "floran_hiss"))
		if(isnull(C.dna.features[feature]))
			C.dna.features[feature] = default_features[feature]

/// Fotosynteza: w jasnym świetle leczy się powoli (Monke: 0.25 obrażeń fizycznych, 0.1 oparzeń na sekundę)
/datum/species/floran/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD || get_light_amount(H) <= 0.3)
		return
	// Life() co 2 sekundy
	H.heal_overall_damage(0.5, 0.2, 0, BODYTYPE_ORGANIC)
	H.adjustToxLoss(-0.5)
	H.adjustOxyLoss(-0.5)

/// Jasność wokół florana od -0.5 (ciemność) do 0.5 (pełne światło), jak u roślinoczłowieka
/datum/species/floran/proc/get_light_amount(mob/living/carbon/human/H)
	if(!isturf(H.loc))
		return -0.5
	var/turf/T = H.loc
	return min(1, T.get_lumcount()) - 0.5

/// Plant-B-Gone i środek chwastobójczy trują florana jak roślinoczłowieka
/datum/species/floran/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem, /datum/reagent/toxin/plantbgone))
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/// Monke: oprysk Plant-B-Gone zadaje roślinom dwudziestokrotne obrażenia od toksyn
/datum/reagent/toxin/plantbgone/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	if(isfloran(M))
		M.adjustToxLoss(min(round(0.4 * reac_volume, 0.1), 10) * 20)
		return
	return ..()

// Oczy floran leżą w tym samym miejscu co ludzkie, ale mają własny kształt
/datum/species/floran/handle_body(mob/living/carbon/human/H)
	. = ..()
	monke_replace_eye_icon(H, FLORAN_ICON)

/datum/species/floran/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	if(C.eyelid)
		C.eyelid.icon = 'icons/mob/human_face.dmi'

/// Liście na ciele (warstwa ADJ jak u Monke), schowane pod kombinezonem kosmicznym
/datum/species/floran/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	var/datum/sprite_accessory/floran_leaves/leaves = GLOB.floran_leaves_list[H.dna.features["floran_leaves"] || default_features["floran_leaves"]]
	if(!leaves || !H.get_bodypart(BODY_ZONE_CHEST))
		return
	if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
		return
	var/mutable_appearance/leaves_overlay = mutable_appearance(leaves.icon, "m_floran_leaves_[leaves.icon_state]_ADJ", -BODY_ADJ_LAYER)
	leaves_overlay.color = forced_colour || (HAS_TRAIT(H, TRAIT_HUSK) ? null : "#[floran_leaves_color(H)]")
	var/list/to_add = list()
	to_add["[BODY_ADJ_LAYER]"] = list(leaves_overlay)
	monke_add_layer_overlays(H, to_add)

/// Kolor liści, a gdy go nie ma, kolor ciała (Monke: fallback_key = MUTANT_COLOR)
/datum/species/floran/proc/floran_leaves_color(mob/living/carbon/human/H)
	return H.dna.features["floran_leaves_color"] || H.dna.features["mcolor"] || FLORAN_DEFAULT_LEAVES

/// Liście i kwiaty na głowie (u Monke pod_hair z floran_hair.dmi), na warstwie włosów, więc chowa je czapka
/datum/species/floran/handle_hair(mob/living/carbon/human/H, forced_colour)
	. = ..()
	var/datum/sprite_accessory/floran_hair/hair = GLOB.floran_hair_list[H.dna.features["floran_hair"]]
	if(!hair || hair.icon_state == "none")
		return
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !IS_ORGANIC_LIMB(head) || HAS_TRAIT(H, TRAIT_HUSK))
		return
	if((H.head?.flags_inv & HIDEHAIR) || (H.wear_mask?.flags_inv & HIDEHAIR))
		return
	var/leaves_color = forced_colour || "#[floran_leaves_color(H)]"
	var/mutable_appearance/hair_overlay = mutable_appearance(hair.icon, "m_floran_hair_[hair.icon_state]_ADJ", -HAIR_LAYER)
	hair_overlay.color = leaves_color
	var/mutable_appearance/flowers_overlay = mutable_appearance(hair.icon, "m_floran_hair_[hair.icon_state]_FRONT", -HAIR_LAYER)
	// Monke: kwiaty w kolorze odwrotnym do liści
	var/list/rgb = rgb2num(leaves_color)
	flowers_overlay.color = rgb(255 - rgb[1], 255 - rgb[2], 255 - rgb[3])
	var/list/to_add = list()
	to_add["[HAIR_LAYER]"] = list(hair_overlay, flowers_overlay)
	monke_add_layer_overlays(H, to_add)

// Krzyk i śmiech jaszczurów (Monke: tongue/floran)
/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(isfloran(user) && !user.mind?.miming)
		return pick_emote_sound(user, list('sound/voice/lizard/lizard_scream_1.ogg', 'sound/voice/lizard/lizard_scream_2.ogg',
			'sound/voice/lizard/lizard_scream_3.ogg', 'sound/voice/lizard/lizard_scream.ogg'))
	return ..()

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(isfloran(user) && !user.mind?.miming)
		return 'aquila/sound/voice/lizard/lizard_laugh1.ogg'
	return ..()

/// Język floran: przeciąga syczące głoski (długość z preferencji „Długość syku”)
/obj/item/organ/tongue/floran
	name = "język floranina"
	desc = "Roślinny narząd do mówienia i jedzenia."
	say_mod = "syczy"
	modifies_speech = TRUE
	liked_food = GORE | MEAT | DAIRY | BUGS // u Monke też SEAFOOD, którego u nas nie ma
	disliked_food = VEGETABLES
	/// Długość syku, gdy właściciel nie ma jej w preferencjach (Monke: losowa 2-6, czasem dłuższa)
	var/draw_length = 3

/obj/item/organ/tongue/floran/Initialize(mapload)
	. = ..()
	draw_length = rand(2, 6)
	if(prob(10))
		draw_length += 2
	// Floranin zna sylvański jak roślinoczłowiek
	languages_possible = languages_possible_base.Copy()
	languages_possible[/datum/language/sylvan] = TRUE

/obj/item/organ/tongue/floran/handle_speech(datum/source, list/speech_args)
	var/static/regex/floran_hiss = new("s+", "g")
	var/static/regex/floran_hiSS = new("S+", "g")
	var/static/regex/floran_kss = new(@"(\w)x", "g")
	var/static/regex/floran_kSS = new(@"(\w)X", "g")
	var/static/regex/floran_ecks = new(@"\bx([\-|r|R]|\b)", "g")
	var/static/regex/floran_eckS = new(@"\bX([\-|r|R]|\b)", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*")
		return
	var/length = hiss_length()
	message = floran_hiss.Replace(message, repeat_string(length, "s"))
	message = floran_hiSS.Replace(message, repeat_string(length, "S"))
	message = floran_kss.Replace(message, "$1k[repeat_string(max(length - 1, 1), "s")]")
	message = floran_kSS.Replace(message, "$1K[repeat_string(max(length - 1, 1), "S")]")
	message = floran_ecks.Replace(message, "eck[repeat_string(max(length - 2, 1), "s")]$1")
	message = floran_eckS.Replace(message, "ECK[repeat_string(max(length - 2, 1), "S")]$1")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/floran/proc/hiss_length()
	var/from_prefs = owner?.dna?.features["floran_hiss"]
	if(isnum(from_prefs))
		return clamp(from_prefs, 2, 6)
	return draw_length

/obj/item/organ/eyes/floran
	name = "oczy fitoida"
	desc = "Wyglądają jak duże jagody..."
	icon = FLORAN_ICON
	icon_state = "floran_eyeballs"
	eye_icon_state = "floraneyes"

// Liście na ciele: 5 wzorów z Monke

GLOBAL_LIST_INIT(floran_leaves_list, monke_init_accessories(/datum/sprite_accessory/floran_leaves))

/datum/sprite_accessory/floran_leaves
	icon = FLORAN_ICON

/datum/sprite_accessory/floran_leaves/furnivour
	name = "Furnivour"
	icon_state = "furnivour"

/datum/sprite_accessory/floran_leaves/leaf
	name = "Leaf"
	icon_state = "leaf"

/datum/sprite_accessory/floran_leaves/pelt
	name = "Pelt"
	icon_state = "pelt"

/datum/sprite_accessory/floran_leaves/savage
	name = "Savage"
	icon_state = "savage"

/datum/sprite_accessory/floran_leaves/survivalist
	name = "Survivalist"
	icon_state = "survivalist"

// Liście i kwiaty na głowie: 10 wzorów z Monke (floran_hair.dmi + kwiaty z podperson_hair.dmi)

GLOBAL_LIST_INIT(floran_hair_list, monke_init_accessories(/datum/sprite_accessory/floran_hair))

/datum/sprite_accessory/floran_hair
	icon = FLORAN_ICON

/datum/sprite_accessory/floran_hair/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/floran_hair/ivy
	name = "Ivy"
	icon_state = "ivy"

/datum/sprite_accessory/floran_hair/cabbage
	name = "Cabbage"
	icon_state = "cabbage"

/datum/sprite_accessory/floran_hair/spinach
	name = "Spinach"
	icon_state = "spinach"

/datum/sprite_accessory/floran_hair/prayer
	name = "Prayer"
	icon_state = "prayer"

/datum/sprite_accessory/floran_hair/vine
	name = "Vine"
	icon_state = "vine"

/datum/sprite_accessory/floran_hair/shrub
	name = "Shrub"
	icon_state = "shrub"

/datum/sprite_accessory/floran_hair/rose
	name = "Rose"
	icon_state = "rose"

/datum/sprite_accessory/floran_hair/orchid
	name = "Orchid"
	icon_state = "orchid"

/datum/sprite_accessory/floran_hair/fig
	name = "Fig"
	icon_state = "fig"

/datum/sprite_accessory/floran_hair/hibiscus
	name = "Hibiscus"
	icon_state = "hibiscus"

// Preferencje w oknie postaci

/// Całe ciało floranina do ikon w oknie postaci
/proc/floran_preview_body(dir = SOUTH)
	var/icon/body = icon('icons/effects/effects.dmi', "nothing")
	for(var/state in list("floran_chest_m", "floran_head", "floran_l_arm", "floran_r_arm", "floran_l_hand", "floran_r_hand", "floran_l_leg", "floran_r_leg"))
		body.Blend(icon(FLORAN_ICON, state, dir), ICON_OVERLAY)
	body.Blend("#[FLORAN_DEFAULT_SKIN]", ICON_MULTIPLY)
	body.Blend(icon(FLORAN_ICON, "floraneyes", dir), ICON_OVERLAY)
	return body

/datum/preference/choiced/species_feature/floran_leaves
	db_key = "feature_floran_leaves"
	feature_key = "floran_leaves"
	relevant_mutant_bodypart = "floran_leaves"
	main_feature_name = "Liście"
	should_generate_icons = TRUE
	accessory_list = "floran_leaves_list"
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/floran_leaves/icon_for(value)
	var/icon/final_icon = floran_preview_body()
	var/datum/sprite_accessory/leaves = GLOB.floran_leaves_list[value]
	if(leaves)
		var/icon/leaves_icon = icon(leaves.icon, "m_floran_leaves_[leaves.icon_state]_ADJ", SOUTH)
		leaves_icon.Blend("#[FLORAN_DEFAULT_LEAVES]", ICON_MULTIPLY)
		final_icon.Blend(leaves_icon, ICON_OVERLAY)
	return final_icon

/datum/preference/choiced/species_feature/floran_leaves/get_display_names()
	return list(
		"Furnivour" = "Drapieżnik",
		"Leaf" = "Liść",
		"Pelt" = "Skóra",
		"Savage" = "Dzikus",
		"Survivalist" = "Surwiwalista",
	)

/datum/preference/choiced/species_feature/floran_leaves/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_floran_leaves_color"
	return data

/datum/preference/choiced/species_feature/floran_hair
	db_key = "feature_floran_hair"
	feature_key = "floran_hair"
	relevant_mutant_bodypart = "floran_hair"
	main_feature_name = "Liście na głowie"
	should_generate_icons = TRUE
	accessory_list = "floran_hair_list"

/datum/preference/choiced/species_feature/floran_hair/icon_for(value)
	var/icon/final_icon = floran_preview_body()
	var/datum/sprite_accessory/hair = GLOB.floran_hair_list[value]
	if(hair && hair.icon_state != "none")
		var/icon/hair_icon = icon(hair.icon, "m_floran_hair_[hair.icon_state]_ADJ", SOUTH)
		hair_icon.Blend("#[FLORAN_DEFAULT_LEAVES]", ICON_MULTIPLY)
		final_icon.Blend(hair_icon, ICON_OVERLAY)
		var/icon/flowers_icon = icon(hair.icon, "m_floran_hair_[hair.icon_state]_FRONT", SOUTH)
		var/list/rgb = rgb2num("#[FLORAN_DEFAULT_LEAVES]")
		flowers_icon.Blend(rgb(255 - rgb[1], 255 - rgb[2], 255 - rgb[3]), ICON_MULTIPLY)
		final_icon.Blend(flowers_icon, ICON_OVERLAY)
	return aq_pref_head_crop(final_icon)

/datum/preference/choiced/species_feature/floran_hair/get_display_names()
	return list(
		"None" = "Brak",
		"Ivy" = "Bluszcz",
		"Cabbage" = "Kapusta",
		"Spinach" = "Szpinak",
		"Prayer" = "Maranta",
		"Vine" = "Pnącze",
		"Shrub" = "Krzew",
		"Rose" = "Róża",
		"Orchid" = "Storczyk",
		"Fig" = "Figa",
		"Hibiscus" = "Hibiskus",
	)

/datum/preference/choiced/species_feature/floran_hair/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_floran_leaves_color"
	return data

/// Kolor liści i kwiatów (Monke: drugi kolor mutanta)
/datum/preference/color/floran_leaves_color
	db_key = "feature_floran_leaves_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	feature_key = "floran_leaves_color"
	relevant_mutant_bodypart = "floran_leaves"
	can_randomize = TRUE

/// Monke: hiss_length
/datum/preference/numeric/floran_hiss
	db_key = "feature_floran_hiss"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "floran_hiss"
	relevant_mutant_bodypart = "floran_hiss"
	minimum = 2
	maximum = 6

// Opis do okna wyboru gatunku

/datum/species/floran/get_species_description()
	return "Roślinni humanoidzi, wyjątkowo agresywni mięsożercy bez centralnego rządu ani struktury władzy, \
		podzieleni na liczne plemiona rozsiane po całym wszechświecie. Każdym plemieniem rządzi Zielonopalcy."

/datum/species/floran/get_species_lore()
	return list(
		"Biologicznie floranie są jednopłciowi, ale jeśli chcą, mogą przybrać cechy płciowe i męską lub żeńską tożsamość. \
		Mówią zwykle prosto i przeciągają syczące głoski.",

		"Ich główne popędy to polowanie, zdobywanie trofeów, walka, jedzenie mięsa i jeszcze więcej polowania. \
		Przypuszcza się, że ich swobodne podejście do zabijania i zjadania innych rozumnych gatunków bierze się stąd, \
		że „mięsa” nie uważają za żywe w tym samym sensie co siebie.",

		"W miarę jak floranie rozprzestrzeniają się po galaktyce, coraz więcej z nich rozumie potrzebę integracji, \
		szukania przyjaciół i, być może, niedźgania każdego, kto choć trochę wejdzie im w drogę. \
		(To NIE jest wymówka do zabijania bez powodu.)",
	)

/datum/species/floran/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Fotosynteza",
			SPECIES_PERK_DESC = "Twoja zielona skóra powoli leczy się w jasnym świetle.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Zwinność",
			SPECIES_PERK_DESC = "Floranie biegają nieco szybciej niż inne gatunki.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Soki zamiast krwi",
			SPECIES_PERK_DESC = "Zamiast krwi masz wodę, więc picie wody uzupełnia krew.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Łatwopalna skóra",
			SPECIES_PERK_DESC = "Twoja łatwopalna skóra jest bardzo podatna na oparzenia, a chłód szkodzi ci bardziej niż innym.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Roślinna biologia",
			SPECIES_PERK_DESC = "Plant-B-Gone i środek chwastobójczy zadają ci ogromne obrażenia. Kończyny łatwo ci odpadają, ale możesz przyczepić je z powrotem bez operacji.",
		),
	)

// Części ciała z Monke (icons/mob/human/species/floran/bodyparts.dmi)

/obj/item/bodypart/head/floran
	icon = FLORAN_ICON
	icon_state = "floran_head"
	limb_id = SPECIES_FLORAN
	is_dimorphic = FALSE

/obj/item/bodypart/chest/floran
	icon = FLORAN_ICON
	icon_state = "floran_chest_m"
	limb_id = SPECIES_FLORAN
	is_dimorphic = TRUE

/obj/item/bodypart/l_arm/floran
	icon = FLORAN_ICON
	icon_state = "floran_l_arm"
	limb_id = SPECIES_FLORAN

/obj/item/bodypart/r_arm/floran
	icon = FLORAN_ICON
	icon_state = "floran_r_arm"
	limb_id = SPECIES_FLORAN

/obj/item/bodypart/l_leg/floran
	icon = FLORAN_ICON
	icon_state = "floran_l_leg"
	limb_id = SPECIES_FLORAN

/obj/item/bodypart/r_leg/floran
	icon = FLORAN_ICON
	icon_state = "floran_r_leg"
	limb_id = SPECIES_FLORAN

#undef FLORAN_ICON
#undef FLORAN_DEFAULT_SKIN
#undef FLORAN_DEFAULT_LEAVES
