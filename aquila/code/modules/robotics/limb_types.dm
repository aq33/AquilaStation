// AQUILA - trzy klasy protez: tania (robot/surplus z core, też ręka ze złomu z menu wytwarzania), zwykła (robot z core)
// i zaawansowana (tg code/modules/surgery/bodyparts/robot_bodyparts.dm, /obj/item/bodypart/arm/left/robot/advanced):
// mocniejsze ciosy, większa wytrzymałość, mniej obrażeń przenoszonych na ciało; drukowana w fabrykatorze egzoszkieletów po badaniach.
// Ciosy liczymy przez unarmed_damage_bonus (u nas obrażenia pięści są na gatunku). Ikony: tg (advanced_augments.dmi, CC BY-SA 3.0).

/obj/item/bodypart
	/// AQUILA - premia do ciosów, póki kończyna jest przyczepiona
	var/aq_unarmed_bonus = 0
	/// AQUILA - koszt cyberpsychozy, null = wartość domyślna z aq_cyberpsychosis_load()
	var/aq_cyberpsychosis_cost

// --- Zaawansowane protezy ---

/obj/item/bodypart/l_arm/robot/aq_advanced
	name = "zaawansowana lewa ręka robotyczna"
	desc = "Zaawansowana cybernetyczna ręka, silniejsza i wytrzymalsza od zwykłej protezy."
	static_icon = 'aquila/icons/mob/augmentation/advanced_augments.dmi'
	max_damage = 75
	body_damage_coeff = 0.5
	aq_unarmed_bonus = 3
	aq_cyberpsychosis_cost = 14

/obj/item/bodypart/r_arm/robot/aq_advanced
	name = "zaawansowana prawa ręka robotyczna"
	desc = "Zaawansowana cybernetyczna ręka, silniejsza i wytrzymalsza od zwykłej protezy."
	static_icon = 'aquila/icons/mob/augmentation/advanced_augments.dmi'
	max_damage = 75
	body_damage_coeff = 0.5
	aq_unarmed_bonus = 3
	aq_cyberpsychosis_cost = 14

/obj/item/bodypart/l_leg/robot/aq_advanced
	name = "zaawansowana lewa noga robotyczna"
	desc = "Zaawansowana cybernetyczna noga, silniejsza i wytrzymalsza od zwykłej protezy."
	static_icon = 'aquila/icons/mob/augmentation/advanced_augments.dmi'
	max_damage = 75
	body_damage_coeff = 0.5
	aq_cyberpsychosis_cost = 14

/obj/item/bodypart/r_leg/robot/aq_advanced
	name = "zaawansowana prawa noga robotyczna"
	desc = "Zaawansowana cybernetyczna noga, silniejsza i wytrzymalsza od zwykłej protezy."
	static_icon = 'aquila/icons/mob/augmentation/advanced_augments.dmi'
	max_damage = 75
	body_damage_coeff = 0.5
	aq_cyberpsychosis_cost = 14

/// Zaawansowana proteza ma własny wygląd, marka z maszyny go nie zmienia
/obj/item/bodypart/proc/aq_is_advanced()
	return istype(src, /obj/item/bodypart/l_arm/robot/aq_advanced) || istype(src, /obj/item/bodypart/r_arm/robot/aq_advanced) \
		|| istype(src, /obj/item/bodypart/l_leg/robot/aq_advanced) || istype(src, /obj/item/bodypart/r_leg/robot/aq_advanced)

/datum/design/aq_advanced_limb
	name = "Zaawansowana proteza"
	desc = "Mocniejsza i wytrzymalsza proteza kończyny."
	build_type = MECHFAB
	construction_time = 300
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 3000, /datum/material/gold = 3000)
	category = list("Cyborg")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_advanced_limb/l_arm
	name = "Zaawansowana lewa ręka robotyczna"
	id = "aq_adv_l_arm"
	build_path = /obj/item/bodypart/l_arm/robot/aq_advanced

/datum/design/aq_advanced_limb/r_arm
	name = "Zaawansowana prawa ręka robotyczna"
	id = "aq_adv_r_arm"
	build_path = /obj/item/bodypart/r_arm/robot/aq_advanced

/datum/design/aq_advanced_limb/l_leg
	name = "Zaawansowana lewa noga robotyczna"
	id = "aq_adv_l_leg"
	build_path = /obj/item/bodypart/l_leg/robot/aq_advanced

/datum/design/aq_advanced_limb/r_leg
	name = "Zaawansowana prawa noga robotyczna"
	id = "aq_adv_r_leg"
	build_path = /obj/item/bodypart/r_leg/robot/aq_advanced

// --- Proteza ze złomu ---

/// Ręka ze złomu (CEV Eris makeshift_arm): tania proteza surplus z prętów i kabla, z obudową z blachy
/datum/crafting_recipe/aq_scrap_l_arm
	name = "prowizoryczna lewa ręka ze złomu"
	result = /obj/item/bodypart/l_arm/robot/surplus
	time = 10 SECONDS
	reqs = list(/obj/item/stack/rods = 4, /obj/item/stack/sheet/iron = 2, /obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_ROBOT

/datum/crafting_recipe/aq_scrap_r_arm
	name = "prowizoryczna prawa ręka ze złomu"
	result = /obj/item/bodypart/r_arm/robot/surplus
	time = 10 SECONDS
	reqs = list(/obj/item/stack/rods = 4, /obj/item/stack/sheet/iron = 2, /obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_ROBOT

// --- Przyczepianie i odczepianie ---

/// Przypięcie protezy do kikuta bez operacji (cecha „Mocowania protez”, limb_mounts.dm)
/obj/item/bodypart/proc/aq_easy_attach_to(mob/living/carbon/human/target, mob/user)
	user.visible_message("<span class='notice'>[user] przykłada [name] do kikuta [target == user ? "" : "[target] "]([strefa_pl(body_zone)]).</span>", \
		"<span class='notice'>Przykładasz [name] do kikuta ([strefa_pl(body_zone)]).</span>")
	if(!do_mob(user, target, 3 SECONDS))
		return FALSE
	if(target.get_bodypart(body_zone) || loc != user || !user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	attach_limb(target, TRUE)
	target.visible_message("<span class='notice'>[name] wskakuje na miejsce.</span>")
	return TRUE

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(QDELETED(C) || owner != C)
		return
	if(aq_unarmed_bonus && ishuman(C))
		var/mob/living/carbon/human/H = C
		H.unarmed_damage_bonus += aq_unarmed_bonus
	if(aq_brand?.lifelike)
		if(!aq_lifelike_icon && ishuman(C))
			var/mob/living/carbon/human/H = C
			var/obj/item/bodypart/species_limb = H.dna?.species?.aq_species_limb_type(body_zone)
			if(species_limb)
				aq_lifelike_icon = initial(species_limb.icon)
				aq_lifelike_limb_id = initial(species_limb.limb_id)
		update_limb(is_creating = TRUE)
		C.update_body()

/obj/item/bodypart/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	if(old_owner)
		if(aq_unarmed_bonus && ishuman(old_owner))
			var/mob/living/carbon/human/H = old_owner
			H.unarmed_damage_bonus -= aq_unarmed_bonus
	return ..()

/// Typ kończyny gatunku dla strefy
/datum/species/proc/aq_species_limb_type(zone)
	switch(zone)
		if(BODY_ZONE_L_ARM)
			return species_l_arm
		if(BODY_ZONE_R_ARM)
			return species_r_arm
		if(BODY_ZONE_L_LEG)
			return species_l_leg
		if(BODY_ZONE_R_LEG)
			return species_r_leg
		if(BODY_ZONE_CHEST)
			return species_chest
		if(BODY_ZONE_HEAD)
			return species_head
