// AQUILA - augmentacje wybierane w lobby (Nova Sector modular_nova/modules/customization/modules/client/augment/limbs.dm, organs.dm;
// Daedalus Dock code/modules/client/preferences/augments/augments.dm; /vg/station preferences subsections limbs.dm, organs.dm).
// W kreatorze postaci (kategoria bez kontekstu, jak „Preferowany posterunek ochrony”) każda ręka i noga ma wybór: ciało,
// tania proteza, proteza kinetyczna, zaawansowana proteza albo proteza jednej z marek (limb_brands.dm), a serce, płuca,
// wątroba, żołądek, oczy i uszy: organiczne, cybernetyczne albo ulepszone cybernetyczne. Wybór siedzi w features postaci
// (bez nowej kolumny w bazie, jak antag_target_opt_in) i wchodzi w życie przy pojawieniu się w rundzie, po cechach
// (SSquirks.AssignQuirks), więc wybrana kończyna wygrywa z losową protezą z cechy „Proteza”.
// Pominięte z Novy: punkty i limity augmentacji, implanty startowe (część IMPLANTY), proteza całego ciała, głowy i klatki
// (protezy głowy i klatki u nas zdejmują włosy i organy, to osobna robota), podgląd protez na manekinie w kreatorze.
// Kolizje z aq33/AquilaStation#655 (przebudowa okna postaci): wszystkie wpisy są w tym pliku i w jednym nowym pliku TSX
// (character_preferences/aq_augments.tsx), bez zmian w CharacterPreferenceWindow.tsx i bez nowej zakładki. Cecha
// „Protetyczny organ” z #655 losuje tani organ przy pojawieniu, a ten wybór idzie po cechach, więc wybrany tu organ ją nadpisuje.
// Syntetyki (IPC) nie widzą tych wpisów: całe ciało i tak mają robotyczne.

#define AQ_AUG_ORGANIC "organic"
#define AQ_AUG_SURPLUS "surplus"
#define AQ_AUG_KINETIC "kinetic"
#define AQ_AUG_ADVANCED "advanced"
#define AQ_AUG_CYBERNETIC "cybernetic"
#define AQ_AUG_UPGRADED "upgraded"

/datum/preference/choiced/aq_augment
	abstract_type = /datum/preference/choiced/aq_augment
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/aq_augment/read_value(datum/preferences/prefs)
	. = ..()
	if(isnull(.))
		. = AQ_AUG_ORGANIC

/datum/preference/choiced/aq_augment/create_random_value(datum/preferences/prefs)
	return AQ_AUG_ORGANIC

/datum/preference/choiced/aq_augment/is_accessible(datum/preferences/prefs)
	. = ..()
	if(!.)
		return
	var/datum/species/species = prefs.active_character?.pref_species
	return !(MOB_ROBOTIC in species?.inherent_biotypes)

// Kończyny

/datum/preference/choiced/aq_augment/limb
	abstract_type = /datum/preference/choiced/aq_augment/limb
	/// Strefa ciała
	var/zone

/datum/preference/choiced/aq_augment/limb/init_possible_values()
	. = list(AQ_AUG_ORGANIC, AQ_AUG_SURPLUS, AQ_AUG_KINETIC, AQ_AUG_ADVANCED)
	for(var/id in GLOB.aq_robolimb_brands)
		. += id

/datum/preference/choiced/aq_augment/limb/get_display_names()
	. = list(
		AQ_AUG_ORGANIC = "Ciało",
		AQ_AUG_SURPLUS = "Tania proteza",
		AQ_AUG_KINETIC = "Proteza kinetyczna",
		AQ_AUG_ADVANCED = "Zaawansowana proteza",
	)
	for(var/id in GLOB.aq_robolimb_brands)
		var/datum/aq_robolimb_brand/brand = GLOB.aq_robolimb_brands[id]
		.[id] = "Proteza [brand.name]"

/datum/preference/choiced/aq_augment/limb/l_arm
	db_key = "aq_aug_l_arm"
	feature_key = "aq_aug_l_arm"
	zone = BODY_ZONE_L_ARM

/datum/preference/choiced/aq_augment/limb/r_arm
	db_key = "aq_aug_r_arm"
	feature_key = "aq_aug_r_arm"
	zone = BODY_ZONE_R_ARM

/datum/preference/choiced/aq_augment/limb/l_leg
	db_key = "aq_aug_l_leg"
	feature_key = "aq_aug_l_leg"
	zone = BODY_ZONE_L_LEG

/datum/preference/choiced/aq_augment/limb/r_leg
	db_key = "aq_aug_r_leg"
	feature_key = "aq_aug_r_leg"
	zone = BODY_ZONE_R_LEG

// Organy

/datum/preference/choiced/aq_augment/organ
	abstract_type = /datum/preference/choiced/aq_augment/organ
	/// Slot organu
	var/organ_slot
	/// Cybernetyczny i ulepszony cybernetyczny organ
	var/cybernetic_type
	var/upgraded_type

/datum/preference/choiced/aq_augment/organ/init_possible_values()
	. = list(AQ_AUG_ORGANIC, AQ_AUG_CYBERNETIC)
	if(upgraded_type)
		. += AQ_AUG_UPGRADED

/datum/preference/choiced/aq_augment/organ/get_display_names()
	return list(
		AQ_AUG_ORGANIC = "Organiczne",
		AQ_AUG_CYBERNETIC = "Cybernetyczne",
		AQ_AUG_UPGRADED = "Ulepszone cybernetyczne",
	)

/datum/preference/choiced/aq_augment/organ/heart
	db_key = "aq_aug_heart"
	feature_key = "aq_aug_heart"
	organ_slot = ORGAN_SLOT_HEART
	cybernetic_type = /obj/item/organ/heart/cybernetic
	upgraded_type = /obj/item/organ/heart/cybernetic/upgraded

/datum/preference/choiced/aq_augment/organ/lungs
	db_key = "aq_aug_lungs"
	feature_key = "aq_aug_lungs"
	organ_slot = ORGAN_SLOT_LUNGS
	cybernetic_type = /obj/item/organ/lungs/cybernetic
	upgraded_type = /obj/item/organ/lungs/cybernetic/upgraded

/datum/preference/choiced/aq_augment/organ/liver
	db_key = "aq_aug_liver"
	feature_key = "aq_aug_liver"
	organ_slot = ORGAN_SLOT_LIVER
	cybernetic_type = /obj/item/organ/liver/cybernetic
	upgraded_type = /obj/item/organ/liver/cybernetic/upgraded

/datum/preference/choiced/aq_augment/organ/stomach
	db_key = "aq_aug_stomach"
	feature_key = "aq_aug_stomach"
	organ_slot = ORGAN_SLOT_STOMACH
	cybernetic_type = /obj/item/organ/stomach/cybernetic
	upgraded_type = /obj/item/organ/stomach/cybernetic/upgraded

/datum/preference/choiced/aq_augment/organ/eyes
	db_key = "aq_aug_eyes"
	feature_key = "aq_aug_eyes"
	organ_slot = ORGAN_SLOT_EYES
	cybernetic_type = /obj/item/organ/eyes/robotic

/datum/preference/choiced/aq_augment/organ/ears
	db_key = "aq_aug_ears"
	feature_key = "aq_aug_ears"
	organ_slot = ORGAN_SLOT_EARS
	cybernetic_type = /obj/item/organ/ears/robot

// --- Wejście w życie ---

/datum/controller/subsystem/processing/quirks/AssignQuirks(mob/living/user, client/cli, spawn_effects)
	. = ..()
	if(ishuman(user) && cli?.prefs?.active_character)
		var/mob/living/carbon/human/H = user
		H.aq_apply_lobby_augments(cli.prefs.active_character.features)

/// Zakłada protezy i organy wybrane w kreatorze (features postaci)
/mob/living/carbon/human/proc/aq_apply_lobby_augments(list/features)
	if(!features || !dna?.species || (MOB_ROBOTIC in dna.species.inherent_biotypes))
		return
	var/changed = FALSE
	for(var/pref_type in subtypesof(/datum/preference/choiced/aq_augment/limb))
		var/datum/preference/choiced/aq_augment/limb/pref = GLOB.preference_entries[pref_type]
		var/choice = features[pref?.feature_key]
		if(choice && choice != AQ_AUG_ORGANIC && aq_install_lobby_limb(pref.zone, choice))
			changed = TRUE
	for(var/pref_type in subtypesof(/datum/preference/choiced/aq_augment/organ))
		var/datum/preference/choiced/aq_augment/organ/pref = GLOB.preference_entries[pref_type]
		var/choice = features[pref?.feature_key]
		if(choice && choice != AQ_AUG_ORGANIC && aq_install_lobby_organ(pref, choice))
			changed = TRUE
	if(changed)
		regenerate_icons()

/// Typ protezy dla strefy i rodzaju
/proc/aq_lobby_limb_type(zone, choice)
	switch(choice)
		if(AQ_AUG_SURPLUS)
			switch(zone)
				if(BODY_ZONE_L_ARM)
					return /obj/item/bodypart/l_arm/robot/surplus
				if(BODY_ZONE_R_ARM)
					return /obj/item/bodypart/r_arm/robot/surplus
				if(BODY_ZONE_L_LEG)
					return /obj/item/bodypart/l_leg/robot/surplus
				if(BODY_ZONE_R_LEG)
					return /obj/item/bodypart/r_leg/robot/surplus
		if(AQ_AUG_KINETIC)
			switch(zone)
				if(BODY_ZONE_L_ARM)
					return /obj/item/bodypart/l_arm/aq_kinetic
				if(BODY_ZONE_R_ARM)
					return /obj/item/bodypart/r_arm/aq_kinetic
				if(BODY_ZONE_L_LEG)
					return /obj/item/bodypart/l_leg/aq_kinetic
				if(BODY_ZONE_R_LEG)
					return /obj/item/bodypart/r_leg/aq_kinetic
		if(AQ_AUG_ADVANCED)
			switch(zone)
				if(BODY_ZONE_L_ARM)
					return /obj/item/bodypart/l_arm/robot/aq_advanced
				if(BODY_ZONE_R_ARM)
					return /obj/item/bodypart/r_arm/robot/aq_advanced
				if(BODY_ZONE_L_LEG)
					return /obj/item/bodypart/l_leg/robot/aq_advanced
				if(BODY_ZONE_R_LEG)
					return /obj/item/bodypart/r_leg/robot/aq_advanced
		else
			switch(zone)
				if(BODY_ZONE_L_ARM)
					return /obj/item/bodypart/l_arm/robot
				if(BODY_ZONE_R_ARM)
					return /obj/item/bodypart/r_arm/robot
				if(BODY_ZONE_L_LEG)
					return /obj/item/bodypart/l_leg/robot
				if(BODY_ZONE_R_LEG)
					return /obj/item/bodypart/r_leg/robot

/mob/living/carbon/human/proc/aq_install_lobby_limb(zone, choice)
	var/limb_type = aq_lobby_limb_type(zone, choice)
	if(!limb_type)
		return FALSE
	var/datum/aq_robolimb_brand/brand = GLOB.aq_robolimb_brands[choice]
	var/obj/item/bodypart/old_limb = get_bodypart(zone)
	var/obj/item/bodypart/new_limb = new limb_type()
	if(brand)
		new_limb.aq_set_brand(brand, gender)
		new_limb.aq_copy_lifelike_look(old_limb)
	// NSV13: nogi digitigrade dostają protezę digitigrade (jak w cesze „Proteza”)
	if(old_limb && (old_limb.bodytype & BODYTYPE_DIGITIGRADE) && (new_limb.bodytype & BODYTYPE_ROBOTIC) && !new_limb.aq_is_advanced())
		new_limb.bodytype |= BODYTYPE_DIGITIGRADE
		new_limb.static_icon = 'nsv13/icons/mob/augmentation/digitigrade_legs.dmi'
		new_limb.limb_id = "digitigrade"
	new_limb.replace_limb(src, TRUE)
	if(old_limb && old_limb.owner != src)
		qdel(old_limb)
	return new_limb.owner == src

/mob/living/carbon/human/proc/aq_install_lobby_organ(datum/preference/choiced/aq_augment/organ/pref, choice)
	var/organ_type = choice == AQ_AUG_UPGRADED ? pref.upgraded_type : pref.cybernetic_type
	if(!organ_type)
		return FALSE
	var/obj/item/organ/old_organ = getorganslot(pref.organ_slot)
	if(!old_organ) // gatunek bez tego organu (np. bez płuc)
		return FALSE
	var/obj/item/organ/new_organ = new organ_type()
	new_organ.Insert(src, TRUE, FALSE)
	return TRUE

#undef AQ_AUG_ORGANIC
#undef AQ_AUG_SURPLUS
#undef AQ_AUG_KINETIC
#undef AQ_AUG_ADVANCED
#undef AQ_AUG_CYBERNETIC
#undef AQ_AUG_UPGRADED
