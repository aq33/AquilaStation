// Vox z Yogstation (yogstation/code/modules/mob/living/carbon/human/species_types/vox.dm i pliki pomocnicze).
// Ptasio-gadzi humanoid z dziobem, piórami i ogonem, oddycha czystym azotem, tlen go truje.
// U Yoga ciało ma odcień łusek (vox_skin_tone) z osobnym, niebarwionym sprite'em pazurów i dzioba („static”).
// U nas oba są złożone w jeden stan vox_[strefa]_[odcień], a odcień dopisuje get_limb_icon() części ciała Voxa.
// Pióra (głowy i twarzy), znaczenia ciała, ogon i znaczenia ogona to cechy w dna.features rysowane przez gatunek.
// Ubrania dopasowuje do sylwetki Voxa vox_clothing.dm.

/datum/species/vox
	name = "\improper Vox"
	id = SPECIES_VOX
	sexes = FALSE // U Yoga is_dimorphic = FALSE: ciało bez wersji męskiej i żeńskiej
	default_color = "FFFFFF"
	// Kolor mutanta barwi tylko znaczenia ciała, części ciała mają gotowe kolory odcienia
	species_traits = list(EYECOLOR, MUTCOLORS_PARTSONLY, NOEYESPRITES)
	inherent_traits = list(TRAIT_RESISTCOLD)
	mutant_bodyparts = list(VOX_TAIL_PART)
	default_features = list(
		FEATURE_VOX_SKIN_TONE = VOX_DEFAULT_SKIN_TONE,
		FEATURE_VOX_QUILLS = "Brak",
		FEATURE_VOX_FACIAL_QUILLS = "Brak",
		FEATURE_VOX_BODY_MARKINGS = "Brak",
		FEATURE_VOX_TAIL_MARKINGS = "Brak",
		FEATURE_VOX_TAIL_MARKINGS_COLOR = "E8E8E8",
		FEATURE_VOX_MASK = VOX_MASK_BREATH,
		FEATURE_VOX_TANK = VOX_TANK_SMALL,
		"body_size" = "Normal",
	)
	attack_verb = "slash" // pazury (u Yoga scratch/claw)
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	use_skintones = FALSE
	breathid = "n2"
	species_language_holder = /datum/language_holder/vox
	outfit_important_for_life = /datum/outfit/vox
	mutant_brain = /obj/item/organ/brain/vox
	mutant_heart = /obj/item/organ/heart/vox
	mutantlungs = /obj/item/organ/lungs/vox
	mutantliver = /obj/item/organ/liver/vox
	mutantstomach = /obj/item/organ/stomach/vox
	mutanttongue = /obj/item/organ/tongue/vox
	mutantears = /obj/item/organ/ears/vox
	mutanteyes = /obj/item/organ/eyes/vox
	mutanttail = /obj/item/organ/tail/vox

	species_chest = /obj/item/bodypart/chest/vox
	species_head = /obj/item/bodypart/head/vox
	species_l_arm = /obj/item/bodypart/l_arm/vox
	species_r_arm = /obj/item/bodypart/r_arm/vox
	species_l_leg = /obj/item/bodypart/l_leg/vox
	species_r_leg = /obj/item/bodypart/r_leg/vox

/mob/living/carbon/human/species/vox
	race = /datum/species/vox

/// Odcienie łusek (stany ikon) -> polska nazwa
GLOBAL_LIST_INIT(vox_skin_tones, list(
	"lime" = "Limonkowy",
	"crimson" = "Karmazynowy",
	"grey" = "Szary",
	"nebula" = "Mgławicowy",
	"azure" = "Lazurowy",
	"emerald" = "Szmaragdowy",
	"brown" = "Brązowy",
	"plum" = "Śliwkowy",
	"mossy" = "Omszały",
))

/// Imię Voxa: 2-8 sylab skrzeku (Yogstation vox_name())
/proc/vox_name()
	. = ""
	for(var/i in 1 to rand(2, 8))
		. += pick("ti", "hi", "ki", "ya", "ta", "ha", "ka", "yi", "chi", "cha", "kah")
	return capitalize(.)

/datum/species/vox/random_name(gender, unique, lastname, attempts)
	for(var/i in 1 to (unique ? (attempts || 10) : 1))
		. = vox_name()
		if(!unique || !findname(.))
			return

/datum/species/vox/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		vox_sanitize_features(C)
	return ..()

/// Brakujące albo nieznane wartości cech (stare zapisy, zmiana rasy w grze) -> domyślne
/datum/species/vox/proc/vox_sanitize_features(mob/living/carbon/human/H)
	var/list/features = H.dna.features
	if(!(features[FEATURE_VOX_SKIN_TONE] in GLOB.vox_skin_tones))
		features[FEATURE_VOX_SKIN_TONE] = VOX_DEFAULT_SKIN_TONE
	var/list/accessory_lists = list(
		FEATURE_VOX_QUILLS = GLOB.vox_quills_list,
		FEATURE_VOX_FACIAL_QUILLS = GLOB.vox_facial_quills_list,
		FEATURE_VOX_BODY_MARKINGS = GLOB.vox_body_markings_list,
		FEATURE_VOX_TAIL_MARKINGS = GLOB.vox_tail_markings_list,
	)
	for(var/key in accessory_lists)
		var/list/accessories = accessory_lists[key]
		if(!(features[key] in accessories))
			features[key] = default_features[key]
	if(!istext(features[FEATURE_VOX_TAIL_MARKINGS_COLOR]) || !findtext(features[FEATURE_VOX_TAIL_MARKINGS_COLOR], GLOB.is_color))
		features[FEATURE_VOX_TAIL_MARKINGS_COLOR] = default_features[FEATURE_VOX_TAIL_MARKINGS_COLOR]
	if(!(features[FEATURE_VOX_MASK] in list(VOX_MASK_BREATH, VOX_MASK_RESPIRATOR)))
		features[FEATURE_VOX_MASK] = VOX_MASK_BREATH
	if(!(features[FEATURE_VOX_TANK] in list(VOX_TANK_SMALL, VOX_TANK_LARGE)))
		features[FEATURE_VOX_TANK] = VOX_TANK_SMALL

/// Tlen we krwi truje Voxa (Yogstation handle_chemicals)
/datum/species/vox/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/oxygen)
		H.adjustToxLoss(1 * REAGENTS_EFFECT_MULTIPLIER)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/// Na start maska i butla z azotem, od razu podłączona (Yogstation after_equip_job)
/datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source = null)
	. = ..()
	var/list/features = preference_source?.prefs?.active_character?.features
	vox_equip_internals(H, features?[FEATURE_VOX_MASK], features?[FEATURE_VOX_TANK], visualsOnly)

/// Zakłada maskę Voxa i butlę z azotem. Maskę, przez którą nie da się oddychać z butli, chowa do plecaka.
/datum/species/vox/proc/vox_equip_internals(mob/living/carbon/human/H, mask_style, tank_size, visualsOnly = FALSE)
	var/obj/item/clothing/mask/current_mask = H.wear_mask
	if(current_mask && !(current_mask.clothing_flags & MASKINTERNALS))
		H.dropItemToGround(current_mask, TRUE, TRUE)
		if(!H.equip_to_slot_if_possible(current_mask, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
			H.put_in_hands(current_mask)
	if(!H.wear_mask)
		var/mask_type = mask_style == VOX_MASK_RESPIRATOR ? /obj/item/clothing/mask/breath/vox/respirator : /obj/item/clothing/mask/breath/vox
		H.equip_to_slot_or_del(new mask_type(H), ITEM_SLOT_MASK)
	if(visualsOnly)
		return
	vox_replace_survival_boxes(H)
	var/tank_type = tank_size == VOX_TANK_LARGE ? /obj/item/tank/internals/nitrogen : /obj/item/tank/internals/emergency_oxygen/vox
	var/obj/item/tank/internals/tank = new tank_type(H)
	if(!H.equip_to_appropriate_slot(tank) && !H.put_in_hands(tank))
		tank.forceMove(H.drop_location())
	H.internal = tank
	H.update_internals_hud_icon(1)
	to_chat(H, "<span class='notice'>Oddychasz azotem z butli ([tank.name]). Tlen jest dla twojego gatunku trujący, więc musisz oddychać czystym azotem.</span>")

/// W pudełkach przetrwania butla z tlenem i zwykła maska zamieniają się na azotową butlę i maskę Voxa (Yogstation survival_box_replacement)
/datum/species/vox/proc/vox_replace_survival_boxes(mob/living/carbon/human/H)
	for(var/obj/item/storage/box/survival/box in H.GetAllContents())
		for(var/obj/item/tank/internals/emergency_oxygen/oxygen_tank in box)
			if(istype(oxygen_tank, /obj/item/tank/internals/emergency_oxygen/vox) || istype(oxygen_tank, /obj/item/tank/internals/emergency_oxygen/nitrogen))
				continue
			qdel(oxygen_tank)
			new /obj/item/tank/internals/emergency_oxygen/nitrogen(box)
		for(var/obj/item/clothing/mask/breath/breath_mask in box)
			if(istype(breath_mask, /obj/item/clothing/mask/breath/vox))
				continue
			qdel(breath_mask)
			new /obj/item/clothing/mask/breath/vox(box)

/// Strój ważny do życia (np. porwanie przez kontrakt Syndykatu): maska i butla z azotem
/datum/outfit/vox
	name = "Vox"
	mask = /obj/item/clothing/mask/breath/vox
	r_pocket = /obj/item/tank/internals/emergency_oxygen/vox
	internals_slot = ITEM_SLOT_RPOCKET

/datum/species/vox/get_species_description()
	return "Voxy to pozostałość prastarej rasy, która pochodzi ze statków-arek. Te biologicznie zaprojektowane, gadzie, \
		dziobate i pierzaste istoty mają fizjologiczny system kastowy i wyznają zasady „Nienaruszalnego”. \
		Oddychają czystym azotem, więc poza swoimi arkami potrzebują specjalnych masek i butli."

/datum/species/vox/get_species_lore()
	return list(
		"Voxy nie mają własnych kolonii. Większość z nich pochodzi z miejsca zwanego Ławicą: rozległego, \
			przypominającego labirynt kosmicznego megalitu z gruzu i asteroid sklejonych przez niezliczone orbity. \
			Stamtąd bierze się ich bezwzględność i oportunizm.",
		"O historii Voxów wiadomo niewiele, bo poza osobistymi osiągnięciami i opowieściami o zyskach i triumfach \
			nie prowadzą żadnych zapisów. Żyją w Ławicy i wśród gwiazd, odkąd ktokolwiek sięga pamięcią.",
		"Możliwe, że gatunek przeszedł mroczne wieki, zanim poznała go reszta galaktyki. Krążą plotki, że porwani \
			przez voxowych najeźdźców trafiają do Ławicy jako niewolnicy, a ci, którzy się do tego nie nadają, \
			są sprzedawani handlarzom ciał na „ekstrakcję”.",
		"Wiele Voxów polubiło życie wśród gwiazd i zwykle unika planet. Mają smykałkę do handlu, \
			ratownictwa w głębokim kosmosie, a czasem do przestępstw międzygwiezdnych. Niektórzy szukają szczęścia \
			na granicy cywilizowanego kosmosu jako (wątpliwie legalni) kupcy albo najemni pracownicy korporacji, \
			inni łupią statki, ładunki i ludzi, których zabierają do Ławicy.",
	)

/datum/species/vox/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Odporność na zimno",
			SPECIES_PERK_DESC = "Skóra Voxa świetnie izoluje od chłodu kosmosu.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart-circle-check",
			SPECIES_PERK_NAME = "Niepsujące się organy",
			SPECIES_PERK_DESC = "Organy Voxa zawierają zaawansowaną cybernetykę, która nie pozwala im się rozkładać.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Wrażliwość na EMP",
			SPECIES_PERK_DESC = "Organy Voxa są częściowo syntetyczne, więc impuls elektromagnetyczny je uszkadza.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "head-side-mask",
			SPECIES_PERK_NAME = "Oddychanie azotem",
			SPECIES_PERK_DESC = "Tlen jest dla Voxa trujący, musi oddychać czystym azotem z butli.",
		),
	)

// Części ciała: gotowe kolory odcienia, bez barwienia

/obj/item/bodypart
	/// Odcień łusek Voxa (stany vox_[strefa]_[odcień]); ustawiany z dna.features właściciela
	var/vox_tone

/obj/item/bodypart/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	. = ..()
	if(limb_id != SPECIES_VOX || dropping_limb || no_update)
		return
	var/mob/living/carbon/human/H = source || owner
	if(istype(H) && H.dna?.features[FEATURE_VOX_SKIN_TONE])
		vox_tone = H.dna.features[FEATURE_VOX_SKIN_TONE]

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	if(limb_id != SPECIES_VOX || is_husked)
		return
	var/tone = vox_tone || VOX_DEFAULT_SKIN_TONE
	for(var/image/part in .)
		if(part.icon != VOX_BODYPARTS_ICON)
			continue
		if(part.icon_state == "[SPECIES_VOX]_[body_zone]" || (aux_zone && part.icon_state == "[SPECIES_VOX]_[aux_zone]"))
			part.icon_state = "[part.icon_state]_[tone]"

/// Odcień w kluczu pamięci podręcznej kończyn, inaczej Voxy o różnych łuskach dzieliłyby jeden sprite
/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(BP.vox_tone && BP.limb_id == SPECIES_VOX)
		. += "-[BP.vox_tone]"

/obj/item/bodypart/head/vox
	static_icon = VOX_BODYPARTS_ICON
	icon = VOX_BODYPARTS_ICON
	husk_icon = VOX_BODYPARTS_ICON
	husk_type = SPECIES_VOX
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/chest/vox
	static_icon = VOX_BODYPARTS_ICON
	icon = VOX_BODYPARTS_ICON
	husk_icon = VOX_BODYPARTS_ICON
	husk_type = SPECIES_VOX
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/l_arm/vox
	static_icon = VOX_BODYPARTS_ICON
	icon = VOX_BODYPARTS_ICON
	husk_icon = VOX_BODYPARTS_ICON
	husk_type = SPECIES_VOX
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/r_arm/vox
	static_icon = VOX_BODYPARTS_ICON
	icon = VOX_BODYPARTS_ICON
	husk_icon = VOX_BODYPARTS_ICON
	husk_type = SPECIES_VOX
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/l_leg/vox
	static_icon = VOX_BODYPARTS_ICON
	icon = VOX_BODYPARTS_ICON
	husk_icon = VOX_BODYPARTS_ICON
	husk_type = SPECIES_VOX
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

/obj/item/bodypart/r_leg/vox
	static_icon = VOX_BODYPARTS_ICON
	icon = VOX_BODYPARTS_ICON
	husk_icon = VOX_BODYPARTS_ICON
	husk_type = SPECIES_VOX
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE

// Wygląd: oczy, pióra, znaczenia, ogon

/// Macierz koloru dodającego barwę do ciemnych sprite'ów (u Yoga COLOR_BLEND_ADD)
/proc/vox_add_color_matrix(color)
	if(!istext(color) || !length(color))
		return null
	if(color[1] == "#")
		color = copytext(color, 2)
	if(length(color) == 3) // zapis skrócony, np. mcolor "FFF"
		color = "[color[1]][color[1]][color[2]][color[2]][color[3]][color[3]]"
	var/list/rgb = rgb2num("#[copytext(color, 1, 7)]")
	return list(1, 0, 0, 0, 1, 0, 0, 0, 1, rgb[1] / 255, rgb[2] / 255, rgb[3] / 255)

/// Dokłada nakładki do warstwy, nie kasując tego, co już na niej jest
/datum/species/vox/proc/vox_add_layer_overlays(mob/living/carbon/human/H, layer, list/overlays)
	if(!length(overlays))
		return
	var/existing = H.overlays_standing[layer]
	H.remove_overlay(layer)
	var/list/combined = list()
	if(islist(existing))
		combined += existing
	else if(existing)
		combined += existing
	combined += overlays
	H.overlays_standing[layer] = combined
	H.apply_overlay(layer)

/// Oczy Voxa mają inny kształt niż ludzkie (u nas NOEYESPRITES i własna nakładka)
/datum/species/vox/handle_body(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !IS_ORGANIC_LIMB(head) || HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	var/mutable_appearance/eye_overlay = mutable_appearance('aquila/icons/mob/species/vox/eyes.dmi', eyes ? "eyes" : "eyes_missing", -BODY_LAYER)
	if(eyes)
		eye_overlay.color = "#[H.eye_color]"
	vox_add_layer_overlays(H, BODY_LAYER, list(eye_overlay))

/// Pióra na głowie (kolor i gradient włosów) i na twarzy (kolor zarostu), na warstwie włosów
/datum/species/vox/handle_hair(mob/living/carbon/human/H, forced_colour)
	. = ..()
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !IS_ORGANIC_LIMB(head) || HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/list/to_add = list()
	var/hide_facial = (H.head?.flags_inv & HIDEFACIALHAIR) || (H.wear_mask?.flags_inv & HIDEFACIALHAIR)
	var/datum/sprite_accessory/vox_facial_quills/facial = GLOB.vox_facial_quills_list[H.dna.features[FEATURE_VOX_FACIAL_QUILLS]]
	if(!hide_facial && facial && facial.icon_state != "none")
		var/mutable_appearance/facial_overlay = mutable_appearance(facial.icon, facial.icon_state, -HAIR_LAYER)
		facial_overlay.color = forced_colour || vox_add_color_matrix(H.facial_hair_color)
		facial_overlay.alpha = hair_alpha
		to_add += facial_overlay
	var/hide_quills = (H.head?.flags_inv & HIDEHAIR) || (H.wear_mask?.flags_inv & HIDEHAIR)
	var/datum/sprite_accessory/vox_quills/quills = GLOB.vox_quills_list[H.dna.features[FEATURE_VOX_QUILLS]]
	if(!hide_quills && quills && quills.icon_state != "none")
		var/mutable_appearance/quills_overlay = mutable_appearance(layer = -HAIR_LAYER, appearance_flags = KEEP_TOGETHER)
		var/mutable_appearance/quills_base = mutable_appearance(quills.icon, quills.icon_state)
		quills_base.color = forced_colour || vox_add_color_matrix(H.hair_color)
		quills_overlay.overlays += quills_base
		var/datum/sprite_accessory/gradient = GLOB.hair_gradients_list[H.gradient_style]
		if(!forced_colour && gradient && gradient.icon_state != "none")
			var/mutable_appearance/gradient_overlay = mutable_appearance(gradient.icon, gradient.icon_state)
			gradient_overlay.color = "#[H.gradient_color]"
			gradient_overlay.blend_mode = BLEND_INSET_OVERLAY
			quills_overlay.overlays += gradient_overlay
		quills_overlay.alpha = hair_alpha
		to_add += quills_overlay
	vox_add_layer_overlays(H, HAIR_LAYER, to_add)

/datum/species/vox/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	if(HAS_TRAIT(H, TRAIT_HUSK))
		return
	// Znaczenia ciała: po jednym stanie na każdą część ciała Voxa
	var/datum/sprite_accessory/vox_body_markings/markings = GLOB.vox_body_markings_list[H.dna.features[FEATURE_VOX_BODY_MARKINGS]]
	if(markings && markings.icon_state != "none")
		var/list/marking_overlays = list()
		for(var/zone in markings.body_slots)
			var/obj/item/bodypart/part = H.get_bodypart(zone)
			if(!part || part.limb_id != SPECIES_VOX || !IS_ORGANIC_LIMB(part))
				continue
			var/mutable_appearance/marking = mutable_appearance(markings.icon, "m_[zone]_[markings.icon_state]_ADJ", -BODY_ADJ_LAYER)
			marking.color = forced_colour || vox_add_color_matrix(H.dna.features["mcolor"])
			marking_overlays += marking
		vox_add_layer_overlays(H, BODY_ADJ_LAYER, marking_overlays)
	// Ogon i jego znaczenia, schowane pod strojem zakrywającym kombinezon
	var/wagging = (VOX_TAIL_WAGGING_PART in mutant_bodyparts)
	if(!wagging && !(VOX_TAIL_PART in mutant_bodyparts))
		return
	if(!H.get_bodypart(BODY_ZONE_CHEST) || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT)))
		return
	var/obj/item/organ/tail/vox/tail = H.getorganslot(ORGAN_SLOT_TAIL)
	var/tone = (istype(tail) && tail.tail_type) || H.dna.features[FEATURE_VOX_SKIN_TONE] || VOX_DEFAULT_SKIN_TONE
	var/datum/sprite_accessory/vox_tail_markings/tail_markings = GLOB.vox_tail_markings_list[(istype(tail) && tail.tail_markings) || H.dna.features[FEATURE_VOX_TAIL_MARKINGS]]
	for(var/layer in list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER))
		var/layertext = mutant_bodyparts_layertext(layer)
		var/list/tail_overlays = list()
		tail_overlays += mutable_appearance('aquila/icons/mob/species/vox/tails.dmi', "m_[wagging ? "waggingtail" : "tail"]_[tone]_[layertext]", -layer)
		if(tail_markings && tail_markings.icon_state != "none")
			var/mutable_appearance/marking = mutable_appearance(tail_markings.icon, "m_[wagging ? "wagging_" : ""]vox_tail_markings_[tail_markings.icon_state]_[layertext]", -layer)
			marking.color = forced_colour || vox_add_color_matrix(H.dna.features[FEATURE_VOX_TAIL_MARKINGS_COLOR])
			tail_overlays += marking
		vox_add_layer_overlays(H, layer, tail_overlays)

// Akcesoria (nazwy po polsku, stany jak u Yoga)

GLOBAL_LIST_INIT(vox_quills_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/vox_quills))
GLOBAL_LIST_INIT(vox_facial_quills_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/vox_facial_quills))
GLOBAL_LIST_INIT(vox_body_markings_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/vox_body_markings))
GLOBAL_LIST_INIT(vox_tail_markings_list, init_sprite_accessory_subtypes(/datum/sprite_accessory/vox_tail_markings))

/datum/sprite_accessory/vox_quills
	icon = 'aquila/icons/mob/species/vox/quills.dmi'

/datum/sprite_accessory/vox_quills/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/vox_quills/crested
	name = "Czubate"
	icon_state = "crested"

/datum/sprite_accessory/vox_quills/emperor
	name = "Cesarskie"
	icon_state = "emperor"

/datum/sprite_accessory/vox_quills/keel
	name = "Kil"
	icon_state = "keel"

/datum/sprite_accessory/vox_quills/keet
	name = "Papużka"
	icon_state = "keet"

/datum/sprite_accessory/vox_quills/short
	name = "Krótkie"
	icon_state = "short"

/datum/sprite_accessory/vox_quills/tiel
	name = "Nimfa"
	icon_state = "tiel"

/datum/sprite_accessory/vox_quills/kingly
	name = "Królewskie"
	icon_state = "kingly"

/datum/sprite_accessory/vox_quills/afro
	name = "Puszyste"
	icon_state = "afro"

/datum/sprite_accessory/vox_quills/yasuhiro
	name = "Długie"
	icon_state = "yasuhiro"

/datum/sprite_accessory/vox_quills/razor
	name = "Brzytwa"
	icon_state = "razor"

/datum/sprite_accessory/vox_quills/razor_clipped
	name = "Przycięta brzytwa"
	icon_state = "razor_clipped"

/datum/sprite_accessory/vox_quills/long_braid
	name = "Długi warkocz"
	icon_state = "long_braid"

/datum/sprite_accessory/vox_quills/short_braid
	name = "Krótki warkocz"
	icon_state = "short_braid"

/datum/sprite_accessory/vox_quills/mohawk
	name = "Irokez"
	icon_state = "mohawk"

/datum/sprite_accessory/vox_quills/hawk
	name = "Jastrząb"
	icon_state = "hawk"

/datum/sprite_accessory/vox_quills/horns
	name = "Rogi"
	icon_state = "horns"

/datum/sprite_accessory/vox_quills/mange
	name = "Wyliniałe"
	icon_state = "mange"

/datum/sprite_accessory/vox_quills/ponytail
	name = "Kucyk"
	icon_state = "ponytail"

/datum/sprite_accessory/vox_quills/rows
	name = "Rzędy"
	icon_state = "rows"

/datum/sprite_accessory/vox_quills/surf
	name = "Fala"
	icon_state = "surf"

/datum/sprite_accessory/vox_quills/flowing
	name = "Opadające"
	icon_state = "flowing"

/datum/sprite_accessory/vox_quills/nights
	name = "Nocne"
	icon_state = "nights"

/datum/sprite_accessory/vox_quills/cropped
	name = "Ścięte"
	icon_state = "cropped"

/datum/sprite_accessory/vox_facial_quills
	icon = 'aquila/icons/mob/species/vox/facial_quills.dmi'

/datum/sprite_accessory/vox_facial_quills/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/vox_facial_quills/colonel
	name = "Pułkownik"
	icon_state = "colonel"

/datum/sprite_accessory/vox_facial_quills/fu
	name = "Fu"
	icon_state = "fu"

/datum/sprite_accessory/vox_facial_quills/neck
	name = "Szyja"
	icon_state = "neck"

/datum/sprite_accessory/vox_facial_quills/beard
	name = "Broda"
	icon_state = "beard"

/datum/sprite_accessory/vox_facial_quills/ruff
	name = "Kryza"
	icon_state = "ruff"

/datum/sprite_accessory/vox_body_markings
	icon = 'aquila/icons/mob/species/vox/body_markings.dmi'
	/// Strefy ciała ze stanem m_[strefa]_[icon_state]_ADJ
	var/list/body_slots = list()

/datum/sprite_accessory/vox_body_markings/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/vox_body_markings/heart
	name = "Serce"
	icon_state = "heart"
	body_slots = list(BODY_ZONE_R_ARM)

/datum/sprite_accessory/vox_body_markings/hive
	name = "Plaster"
	icon_state = "hive"
	body_slots = list(BODY_ZONE_CHEST)

/datum/sprite_accessory/vox_body_markings/nightling
	name = "Nocny ptak"
	icon_state = "nightling"
	body_slots = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/sprite_accessory/vox_body_markings/tiger_body
	name = "Tygrysie pręgi"
	icon_state = "tiger"
	body_slots = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/sprite_accessory/vox_tail_markings
	icon = 'aquila/icons/mob/species/vox/tail_markings.dmi'

/datum/sprite_accessory/vox_tail_markings/none
	name = "Brak"
	icon_state = "none"

/datum/sprite_accessory/vox_tail_markings/bands
	name = "Pasy"
	icon_state = "bands"

/datum/sprite_accessory/vox_tail_markings/tip
	name = "Końcówka"
	icon_state = "tip"

/datum/sprite_accessory/vox_tail_markings/stripe
	name = "Pręga"
	icon_state = "stripe"

// Organy (u Yoga nie gniją, część reaguje na EMP)

/obj/item/organ/brain/vox
	name = "stos korowy"
	desc = "Osobliwie zaawansowane urządzenie bioelektroniczne, które zdaje się przechowywać wspomnienia i tożsamość Voxa."
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "cortical-stack"
	decay_factor = 0

/obj/item/organ/brain/vox/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, "<span class='warning'>Boli cię głowa.</span>")
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, clamp(severity * 5, 5, 50))

/obj/item/organ/heart/vox
	name = "serce Voxa"
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "heart-vox-on"
	icon_base = "heart-vox"
	decay_factor = 0

/obj/item/organ/lungs/vox
	name = "płuca Voxa"
	desc = "Są pełne kurzu... wow."
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "lungs-vox"
	decay_factor = 0
	breathing_class = BREATH_VOX

/// Azotu nie można mieć za dużo, a tlen już od 0,05 kPa truje
/obj/item/organ/lungs/vox/populate_gas_info()
	..()
	gas_max[GAS_O2] = 0.05
	gas_max -= BREATH_VOX
	gas_damage[GAS_O2] = list(min = MIN_TOXIC_GAS_DAMAGE, max = MAX_TOXIC_GAS_DAMAGE, damage_type = TOX)

/obj/item/organ/lungs/vox/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.emote("gasp")

/obj/item/organ/liver/vox
	name = "wątroba Voxa"
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "liver-vox"
	decay_factor = 0

/obj/item/organ/stomach/vox
	name = "żołądek mięśniowy"
	desc = "Trawienie mechaniczne."
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "stomach-vox"
	decay_factor = 0

/obj/item/organ/stomach/vox/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.adjust_disgust(10)

/obj/item/organ/ears/vox
	name = "uszy Voxa"
	desc = "Badacze przypuszczają, że błona bębenkowa wzmocniona tytanem chroni Voxa przed jego własnym skrzeczeniem."
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "ears-vox"
	decay_factor = 0

/obj/item/organ/ears/vox/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	deaf = max(deaf, 10)

/obj/item/organ/eyes/vox
	name = "oczy Voxa"
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "eyes-vox"
	decay_factor = 0

/obj/item/organ/eyes/vox/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.adjust_hallucinations(10 SECONDS)

/obj/item/organ/tongue/vox
	name = "język Voxa"
	desc = "Można by przysiąc, że słychać, jak skrzeczy."
	icon = 'aquila/icons/mob/species/vox/organs.dmi'
	icon_state = "tongue-vox"
	say_mod = "skrzeczy"
	taste_sensitivity = 50 // padlinożerca nie potrzebuje wyczulonego smaku
	liked_food = MEAT | FRIED
	modifies_speech = TRUE

/obj/item/organ/tongue/vox/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base.Copy()
	languages_possible[/datum/language/vox] = TRUE

/// Jak u Yoga: czasem mowie towarzyszy skrzek
/obj/item/organ/tongue/vox/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*" || !owner)
		return
	if(prob(20))
		playsound(owner, 'aquila/sound/voice/vox/shriek1.ogg', 25, TRUE, 1)

// Ogon

/obj/item/organ/tail/vox
	name = "ogon Voxa"
	desc = "Odcięty ogon Voxa. Gdzieś na pewno ktoś, kto nie znosi Voxów, jest z siebie bardzo zadowolony."
	icon = 'aquila/icons/mob/species/vox/tails.dmi'
	icon_state = "m_tail_lime_BEHIND"
	tail_type = null
	/// Znaczenia ogona (nazwa akcesorium)
	var/tail_markings

/obj/item/organ/tail/vox/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(!istype(H))
		return
	// Ogon pamięta wygląd pierwszego właściciela, także po przeszczepie
	if(!tail_type)
		tail_type = H.dna.features[FEATURE_VOX_SKIN_TONE] || VOX_DEFAULT_SKIN_TONE
		tail_markings = H.dna.features[FEATURE_VOX_TAIL_MARKINGS]
	icon_state = "m_tail_[tail_type]_BEHIND"
	if(!(VOX_TAIL_WAGGING_PART in H.dna.species.mutant_bodyparts))
		H.dna.species.mutant_bodyparts |= VOX_TAIL_PART
	H.update_body()

/obj/item/organ/tail/vox/Remove(mob/living/carbon/human/H, special = 0)
	..()
	if(!istype(H))
		return
	H.dna.species.mutant_bodyparts -= list(VOX_TAIL_PART, VOX_TAIL_WAGGING_PART)
	H.update_body()

/obj/item/organ/tail/vox/is_wagging(mob/living/carbon/human/H)
	return H?.dna?.species && (VOX_TAIL_WAGGING_PART in H.dna.species.mutant_bodyparts)

/obj/item/organ/tail/vox/set_wagging(mob/living/carbon/human/H, wagging = FALSE)
	. = FALSE
	if(!H?.dna?.species)
		return
	var/datum/species/species = H.dna.species
	if(wagging)
		species.mutant_bodyparts -= VOX_TAIL_PART
		species.mutant_bodyparts |= VOX_TAIL_WAGGING_PART
		. = TRUE
	else
		species.mutant_bodyparts -= VOX_TAIL_WAGGING_PART
		species.mutant_bodyparts |= VOX_TAIL_PART
	H.update_body()

// Oddychanie azotem

/datum/breathing_class/vox
	gases = list(
		GAS_N2 = 1,
		GAS_CO2 = -0.7,
	)
	products = list(
		GAS_CO2 = 1,
	)
	low_alert_category = "not_enough_nitro"
	low_alert_datum = /atom/movable/screen/alert/not_enough_nitro
	high_alert_category = "too_much_nitro"
	high_alert_datum = /atom/movable/screen/alert/too_much_nitro

/obj/item/tank/internals/emergency_oxygen/nitrogen
	name = "awaryjna butla z azotem"
	desc = "Awaryjna butla zaprojektowana specjalnie dla Voxów."
	icon = 'aquila/icons/mob/species/vox/items.dmi'
	icon_state = "emergency_nitrogen"
	worn_icon = 'aquila/icons/mob/species/vox/items_belt.dmi'
	worn_icon_state = "emergency_nitrogen"
	item_state = "emergency_nitrogen"
	lefthand_file = 'aquila/icons/mob/species/vox/items_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/species/vox/items_righthand.dmi'

/obj/item/tank/internals/emergency_oxygen/nitrogen/populate_gas()
	air_contents.set_moles(GAS_N2, (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/tank/internals/emergency_oxygen/vox
	name = "specjalistyczna butla azotowa Voxa"
	desc = "Zaawansowana technicznie butla z azotem, zaprojektowana specjalnie dla Voxów."
	icon = 'aquila/icons/mob/species/vox/items.dmi'
	icon_state = "emergency_vox"
	worn_icon = 'aquila/icons/mob/species/vox/items_belt.dmi'
	worn_icon_state = "emergency_vox"
	item_state = "emergency_vox"
	lefthand_file = 'aquila/icons/mob/species/vox/items_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/species/vox/items_righthand.dmi'
	volume = 35

/obj/item/tank/internals/emergency_oxygen/vox/populate_gas()
	air_contents.set_moles(GAS_N2, (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/tank/internals/emergency_oxygen/vox/empty/populate_gas()
	return

/obj/item/tank/internals/nitrogen
	name = "butla z azotem"
	desc = "Butla z azotem."
	icon_state = "oxygen_fr"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/nitrogen/populate_gas()
	air_contents.set_moles(GAS_N2, (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/clothing/mask/breath/vox
	name = "maska oddechowa Voxa"
	desc = "Dziwnie wyprofilowana maska oddechowa."
	icon = 'aquila/icons/mob/species/vox/items.dmi'
	icon_state = "voxmask"
	worn_icon = 'aquila/icons/mob/species/vox/mask_worn.dmi'
	flags_cover = NONE
	visor_flags_cover = NONE
	actions_types = list()

// U Yoga maski Voxa nie da się opuścić
/obj/item/clothing/mask/breath/vox/attack_self(mob/user)
	return

/obj/item/clothing/mask/breath/vox/AltClick(mob/user)
	return

/obj/item/clothing/mask/breath/vox/respirator
	name = "respirator Voxa"
	desc = "Dziwnie wyprofilowana maska oddechowa, zaprojektowana na dziób Voxa."
	icon_state = "voxmask2"

// Język

/datum/language_holder/vox
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/vox = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/vox = list(LANGUAGE_ATOM))

/datum/language/vox
	name = "Pidżyn Voxów"
	desc = "Wspólna mowa statków Voxów tworzących Ławicę. Dla wszystkich innych brzmi jak chaotyczne skrzeczenie."
	speech_verb = "skrzeczy"
	ask_verb = "pokrzykuje"
	exclaim_verb = "głośno skrzeczy"
	key = "5" // u Yoga „v”, u nas zajęte przez voltaic
	syllables = list("ti", "ti", "ti", "hi", "hi", "ki", "ki", "ki", "ki", "ya", "ta", "ha", "ka", "ya", "yi", "chi", "cha", "kah", \
		"SKRE", "AHK", "EHK", "RAWK", "KRA", "AAA", "EEE", "KI", "II", "KRI", "KA")
	default_priority = 90
	icon = 'aquila/icons/mob/species/vox/language.dmi'
	icon_state = "voxpidgin"

// Dźwięki i emotki (u Yoga screamsound, get_cough_sound, get_sneeze_sound, message_vox i *quill)

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(isvox(user) && !user.mind?.miming)
		return 'aquila/sound/voice/scream/skyrat_voxscream.ogg'
	return ..()

/datum/emote/living/carbon/human/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(isvox(user) && .)
		. = "skrzeczy"

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(isvox(user) && !user.mind?.miming)
		return 'aquila/sound/voice/laugh/vox_laugh.ogg'
	return ..()

/datum/emote/living/cough/get_sound(mob/living/user)
	if(isvox(user) && !user.mind?.miming)
		return 'aquila/sound/voice/vox/shriekcough.ogg'
	return ..()

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(isvox(user) && !user.mind?.miming)
		return 'aquila/sound/voice/vox/shrieksneeze.ogg'
	return ..()

/datum/emote/living/carbon/human/quill
	key = "quill"
	key_third_person = "quills"
	message = "szeleści piórami"
	message_param = "szeleści piórami na %t"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/quill/get_sound(mob/living/user)
	return 'aquila/sound/voice/vox/voxrustle.ogg' // dźwięk: sound-ideas (freesfx.co.uk), jak u Yoga

/datum/emote/living/carbon/human/quill/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	return ..() && isvox(user)
