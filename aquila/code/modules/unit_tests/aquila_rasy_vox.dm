// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Stany ikon nakładek na warstwie (pojedyncza nakładka albo lista)
/proc/aquila_rasy_vox_layer_states(mob/living/carbon/human/H, layer)
	. = list()
	var/list/standing = H.overlays_standing[layer]
	if(!islist(standing))
		standing = standing ? list(standing) : list()
	for(var/mutable_appearance/overlay in standing)
		. += overlay.icon_state

/// Plik ikony nakładki ubrania na warstwie, jako tekst
/proc/aquila_rasy_vox_layer_icon(mob/living/carbon/human/H, layer)
	var/mutable_appearance/overlay = H.overlays_standing[layer]
	if(islist(overlay))
		var/list/overlays = overlay
		overlay = overlays[1]
	return overlay ? "[overlay.icon]" : null

/// Sprite'y ciała, cech i ubrań Voxa istnieją, a podglądy w oknie postaci da się wygenerować
/datum/unit_test/aquila_rasy_vox_sprites

/datum/unit_test/aquila_rasy_vox_sprites/Run()
	for(var/tone in GLOB.vox_skin_tones)
		for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
			TEST_ASSERT(icon_exists(VOX_BODYPARTS_ICON, "[SPECIES_VOX]_[zone]_[tone]"), "Missing limb sprite [SPECIES_VOX]_[zone]_[tone]")
			TEST_ASSERT(icon_exists(VOX_BODYPARTS_ICON, "[SPECIES_VOX]_husk_[zone]"), "Missing husk sprite for [zone]")
		for(var/prefix in list("tail", "waggingtail"))
			for(var/layertext in list("BEHIND", "FRONT"))
				TEST_ASSERT(icon_exists('aquila/icons/mob/species/vox/tails.dmi', "m_[prefix]_[tone]_[layertext]"), "Missing tail sprite m_[prefix]_[tone]_[layertext]")
	TEST_ASSERT_EQUAL(length(GLOB.vox_quills_list), 24, "Wrong number of quill styles")
	TEST_ASSERT_EQUAL(length(GLOB.vox_facial_quills_list), 6, "Wrong number of facial quill styles")
	for(var/list/accessories in list(GLOB.vox_quills_list, GLOB.vox_facial_quills_list))
		for(var/name in accessories)
			var/datum/sprite_accessory/accessory = accessories[name]
			if(accessory.icon_state != "none")
				TEST_ASSERT(icon_exists(accessory.icon, accessory.icon_state), "Missing quill sprite [accessory.icon_state]")
	for(var/name in GLOB.vox_body_markings_list)
		var/datum/sprite_accessory/vox_body_markings/markings = GLOB.vox_body_markings_list[name]
		for(var/zone in markings.body_slots)
			TEST_ASSERT(icon_exists(markings.icon, "m_[zone]_[markings.icon_state]_ADJ"), "Missing body marking sprite m_[zone]_[markings.icon_state]_ADJ")
	for(var/name in GLOB.vox_tail_markings_list)
		var/datum/sprite_accessory/vox_tail_markings/tail_markings = GLOB.vox_tail_markings_list[name]
		if(tail_markings.icon_state == "none")
			continue
		for(var/prefix in list("", "wagging_"))
			TEST_ASSERT(icon_exists(tail_markings.icon, "m_[prefix]vox_tail_markings_[tail_markings.icon_state]_BEHIND"), "Missing tail marking sprite [tail_markings.icon_state]")
	for(var/source in GLOB.vox_worn_icons)
		TEST_ASSERT(length(icon_states(GLOB.vox_worn_icons[source])), "The vox clothing file for [source] is empty")
	for(var/config in GLOB.vox_gags_worn_configs)
		TEST_ASSERT(SSgreyscale.configurations["[GLOB.vox_gags_worn_configs[config]]"], "The vox GAGS config for [config] is not loaded")
	for(var/db_key in list("feature_vox_skin_tone", "feature_vox_quills", "feature_vox_facial_quills", "feature_vox_body_markings", "feature_vox_tail_markings"))
		var/datum/preference/choiced/entry = GLOB.preference_entries_by_key[db_key]
		TEST_ASSERT(istype(entry), "No preference entry [db_key]")
		for(var/value in entry.get_choices())
			TEST_ASSERT(isicon(entry.icon_for(value)), "No preview icon for [db_key] = [value]")
	for(var/db_key in list("feature_vox_quills_color", "feature_vox_facial_quills_color", "feature_vox_quills_gradient", "feature_vox_quills_gradient_color", "feature_vox_tail_markings_color", "feature_vox_mask", "feature_vox_tank"))
		TEST_ASSERT(istype(GLOB.preference_entries_by_key[db_key], /datum/preference), "No preference entry [db_key]")

/// Vox: ciało w wybranym odcieniu, pióra, ogon z merdaniem, oddychanie azotem, wyposażenie na start i zmiana rasy w obie strony
/datum/unit_test/aquila_rasy_vox

/datum/unit_test/aquila_rasy_vox/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/vox)
	TEST_ASSERT(isvox(H), "set_species did not make a vox")
	TEST_ASSERT_EQUAL(H.dna.features[FEATURE_VOX_SKIN_TONE], VOX_DEFAULT_SKIN_TONE, "A vox without a saved skin tone did not get the default one")
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(istype(head, /obj/item/bodypart/head/vox), "A vox has no vox head")

	// Odcień łusek trafia do sprite'ów kończyn
	H.dna.features[FEATURE_VOX_SKIN_TONE] = "azure"
	H.update_body_parts(TRUE)
	var/found_tone = FALSE
	for(var/image/part in head.get_limb_icon())
		if(part.icon_state == "[SPECIES_VOX]_[BODY_ZONE_HEAD]_azure")
			found_tone = TRUE
	TEST_ASSERT(found_tone, "The vox head is not drawn in the chosen skin tone")

	// Pióra na głowie i twarzy rysują się na warstwie włosów i chowa je hełm
	H.dna.features[FEATURE_VOX_QUILLS] = "Irokez"
	H.dna.features[FEATURE_VOX_FACIAL_QUILLS] = "Broda"
	H.update_hair()
	var/list/hair_states = aquila_rasy_vox_layer_states(H, HAIR_LAYER)
	TEST_ASSERT("beard" in hair_states, "Facial quills are not drawn")
	var/quills_drawn = FALSE
	var/list/hair_layer = H.overlays_standing[HAIR_LAYER]
	for(var/mutable_appearance/overlay in hair_layer)
		for(var/mutable_appearance/inner as anything in overlay.overlays)
			if(inner.icon_state == "mohawk")
				quills_drawn = TRUE
	TEST_ASSERT(quills_drawn, "Quills are not drawn")

	// Ogon: organ, nakładka i merdanie
	var/obj/item/organ/tail/vox/tail = H.getorganslot(ORGAN_SLOT_TAIL)
	TEST_ASSERT(istype(tail), "A vox has no vox tail")
	H.update_body()
	TEST_ASSERT(("m_tail_azure_BEHIND" in aquila_rasy_vox_layer_states(H, BODY_BEHIND_LAYER)) || ("m_tail_lime_BEHIND" in aquila_rasy_vox_layer_states(H, BODY_BEHIND_LAYER)), "The vox tail is not drawn")
	tail.toggle_wag(H)
	TEST_ASSERT(tail.is_wagging(H), "The vox tail does not wag")
	TEST_ASSERT(length(aquila_rasy_vox_layer_states(H, BODY_BEHIND_LAYER) & list("m_waggingtail_lime_BEHIND", "m_waggingtail_azure_BEHIND")), "The wagging vox tail is not drawn")
	tail.toggle_wag(H)
	TEST_ASSERT(!tail.is_wagging(H), "The vox tail does not stop wagging")

	// Azot jest do oddychania, tlen truje
	var/obj/item/organ/lungs/vox/lungs = H.getorganslot(ORGAN_SLOT_LUNGS)
	TEST_ASSERT(istype(lungs), "A vox has no vox lungs")
	var/datum/gas_mixture/station_air = new(BREATH_VOLUME)
	station_air.set_temperature(T20C)
	station_air.set_moles(GAS_O2, MOLES_O2STANDARD * BREATH_PERCENTAGE)
	station_air.set_moles(GAS_N2, MOLES_N2STANDARD * BREATH_PERCENTAGE)
	H.setToxLoss(0)
	lungs.check_breath(station_air, H)
	TEST_ASSERT(H.getToxLoss() > 0, "Oxygen in the air did not poison the vox")
	var/datum/gas_mixture/nitrogen = new(BREATH_VOLUME)
	nitrogen.set_temperature(T20C)
	nitrogen.set_moles(GAS_N2, (MOLES_O2STANDARD + MOLES_N2STANDARD) * BREATH_PERCENTAGE)
	H.setToxLoss(0)
	H.failed_last_breath = TRUE
	lungs.check_breath(nitrogen, H)
	TEST_ASSERT_EQUAL(H.getToxLoss(), 0, "Pure nitrogen poisoned the vox")
	TEST_ASSERT(!H.failed_last_breath, "The vox suffocated on pure nitrogen")

	// Wyposażenie na start: maska i podłączona butla z azotem
	var/datum/species/vox/vox_species = H.dna.species
	vox_species.vox_equip_internals(H, VOX_MASK_RESPIRATOR, VOX_TANK_SMALL)
	TEST_ASSERT(istype(H.wear_mask, /obj/item/clothing/mask/breath/vox/respirator), "The vox did not get the chosen mask")
	var/obj/item/tank/internals/tank = H.internal
	TEST_ASSERT(istype(tank, /obj/item/tank/internals/emergency_oxygen/vox), "The vox is not breathing from a nitrogen tank")
	TEST_ASSERT(tank.air_contents.get_moles(GAS_N2) > 0 && !tank.air_contents.get_moles(GAS_O2), "The vox tank is not filled with nitrogen")

	// Ubranie na głowie dostaje sprite dopasowany do Voxa
	var/obj/item/clothing/head/hardhat/hat = allocate(/obj/item/clothing/head/hardhat)
	H.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE)
	H.regenerate_icons()
	var/vox_icon = aquila_rasy_vox_layer_icon(H, HEAD_LAYER)
	var/list/vox_files = list()
	for(var/source in GLOB.vox_worn_icons)
		vox_files += "[GLOB.vox_worn_icons[source]]"
	TEST_ASSERT(vox_icon in vox_files, "The hard hat on a vox uses the human sprite ([vox_icon])")
	var/obj/item/clothing/under/color/grey/jumpsuit = allocate(/obj/item/clothing/under/color/grey)
	H.equip_to_slot_if_possible(jumpsuit, ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
	H.regenerate_icons()
	TEST_ASSERT(H.overlays_standing[UNIFORM_LAYER], "The jumpsuit is not drawn on a vox")

	// Z powrotem człowiek: ludzki sprite czapki, bez ogona Voxa
	H.set_species(/datum/species/human)
	H.regenerate_icons()
	var/human_icon = aquila_rasy_vox_layer_icon(H, HEAD_LAYER)
	TEST_ASSERT(!(human_icon in vox_files), "The hard hat on a human still uses the vox sprite")
	TEST_ASSERT(!istype(H.getorganslot(ORGAN_SLOT_TAIL), /obj/item/organ/tail/vox), "A human kept the vox tail")
	TEST_ASSERT(!istype(H.getorganslot(ORGAN_SLOT_LUNGS), /obj/item/organ/lungs/vox), "A human kept the vox lungs")
	TEST_ASSERT(!length(aquila_rasy_vox_layer_states(H, BODY_BEHIND_LAYER) & list("m_tail_azure_BEHIND", "m_tail_lime_BEHIND")), "The vox tail is still drawn on a human")
	// I jeszcze raz Vox, żeby zmiana w obie strony nie zostawiała śmieci
	H.set_species(/datum/species/vox)
	TEST_ASSERT(istype(H.getorganslot(ORGAN_SLOT_TAIL), /obj/item/organ/tail/vox), "A vox again has no vox tail")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
