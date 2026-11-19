// AQUILA - nowe rodzaje protez:
// - zaawansowane protezy (tg code/modules/surgery/bodyparts/robot_bodyparts.dm, /obj/item/bodypart/arm/left/robot/advanced):
//   mocniejsze ciosy, większa wytrzymałość, mniej obrażeń przenoszonych na ciało; drukowane w fabrykatorze egzoszkieletów po badaniach,
// - protezy kinetyczne (Bubberstation#4861, modular_zubbers/code/modules/surgery/bodyparts/kinetic.dm): tanie, bez elektroniki,
//   „grube palce” (bez broni palnej), łatwo odpadają i łatwo się je zakłada,
// - prowizoryczne protezy (tg code/modules/surgery/bodyparts/ghetto_parts.dm, slapcraft z Daedalus Dock): drewniany kołek
//   z dwóch desek albo ręka ze złomu, z menu wytwarzania, bez fabrykatora.
// Kołki i protezy kinetyczne nie są ani organiczne, ani robotyczne (BODYTYPE_HUMANOID): EMP, rany i chirurgia ich nie dotyczą,
// a zniszczone wymienia się na nowe. Ciosy liczymy przez unarmed_damage_bonus (u nas obrażenia pięści są na gatunku).
// Ikony: tg (advanced_augments.dmi, ghetto.dmi, CC BY-SA 3.0), Bubberstation (kinetic.dmi, CC BY-SA 3.0).

/obj/item/bodypart
	/// AQUILA - mnożniki obrażeń kończyny niezależne od marki (kołki, protezy kinetyczne)
	var/aq_brute_mod = 1
	var/aq_burn_mod = 1
	/// AQUILA - premia do ciosów, póki kończyna jest przyczepiona
	var/aq_unarmed_bonus = 0
	/// AQUILA - kończyna bez precyzji: właściciel nie strzela z broni palnej (tg TRAIT_CHUNKYFINGERS)
	var/aq_chunky_fingers = FALSE
	/// AQUILA - zakłada się ją bez operacji, przykładając do kikuta (tg TRAIT_EASY_ATTACH)
	var/aq_easy_attach = FALSE
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

// --- Protezy kinetyczne ---

/obj/item/bodypart/l_arm/aq_kinetic
	name = "lewa proteza kinetyczna"
	desc = "Prosta, ale zgrabna proteza. Oddaje część sprawności i wygląda jak ręka, ale nie ma precyzji: nie da się nią strzelać."
	static_icon = 'aquila/icons/mob/augmentation/kinetic.dmi'
	icon = null
	icon_state = "kinetic_l_arm"
	limb_id = "kinetic"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	max_damage = 20
	body_damage_coeff = 0.5
	aq_chunky_fingers = TRUE
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/obj/item/bodypart/r_arm/aq_kinetic
	name = "prawa proteza kinetyczna"
	desc = "Prosta, ale zgrabna proteza. Oddaje część sprawności i wygląda jak ręka, ale nie ma precyzji: nie da się nią strzelać."
	static_icon = 'aquila/icons/mob/augmentation/kinetic.dmi'
	icon = null
	icon_state = "kinetic_r_arm"
	limb_id = "kinetic"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	max_damage = 20
	body_damage_coeff = 0.5
	aq_chunky_fingers = TRUE
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/obj/item/bodypart/l_leg/aq_kinetic
	name = "lewa proteza kinetyczna nogi"
	desc = "Prosta, ale zgrabna proteza z płozą zamiast stopy. Chodzi się na niej normalnie."
	static_icon = 'aquila/icons/mob/augmentation/kinetic.dmi'
	icon = null
	icon_state = "kinetic_l_leg"
	limb_id = "kinetic"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	max_damage = 20
	body_damage_coeff = 0.5
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/obj/item/bodypart/r_leg/aq_kinetic
	name = "prawa proteza kinetyczna nogi"
	desc = "Prosta, ale zgrabna proteza z płozą zamiast stopy. Chodzi się na niej normalnie."
	static_icon = 'aquila/icons/mob/augmentation/kinetic.dmi'
	icon = null
	icon_state = "kinetic_r_leg"
	limb_id = "kinetic"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	max_damage = 20
	body_damage_coeff = 0.5
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/datum/design/aq_kinetic_limb
	name = "Proteza kinetyczna"
	desc = "Tania proteza kończyny bez elektroniki."
	build_type = PROTOLATHE | MECHFAB
	construction_time = 100
	materials = list(/datum/material/iron = 2000, /datum/material/plastic = 1000)
	category = list("Cyborg", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_kinetic_limb/l_arm
	name = "Lewa proteza kinetyczna"
	id = "aq_kinetic_l_arm"
	build_path = /obj/item/bodypart/l_arm/aq_kinetic

/datum/design/aq_kinetic_limb/r_arm
	name = "Prawa proteza kinetyczna"
	id = "aq_kinetic_r_arm"
	build_path = /obj/item/bodypart/r_arm/aq_kinetic

/datum/design/aq_kinetic_limb/l_leg
	name = "Lewa proteza kinetyczna nogi"
	id = "aq_kinetic_l_leg"
	build_path = /obj/item/bodypart/l_leg/aq_kinetic

/datum/design/aq_kinetic_limb/r_leg
	name = "Prawa proteza kinetyczna nogi"
	id = "aq_kinetic_r_leg"
	build_path = /obj/item/bodypart/r_leg/aq_kinetic

// --- Prowizoryczne protezy ---

/obj/item/bodypart/l_arm/aq_peg
	name = "lewa drewniana proteza ręki"
	desc = "Z grubsza ociosany kołek w miejscu przedramienia. Prosty i wytrzymały, zrobiony w pośpiechu z tego, co było pod ręką."
	static_icon = 'aquila/icons/mob/augmentation/ghetto.dmi'
	icon = null
	icon_state = "peg_l_arm"
	limb_id = "peg"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	aq_brute_mod = 1.2
	aq_burn_mod = 1.5
	aq_chunky_fingers = TRUE
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/obj/item/bodypart/r_arm/aq_peg
	name = "prawa drewniana proteza ręki"
	desc = "Z grubsza ociosany kołek w miejscu przedramienia. Prosty i wytrzymały, zrobiony w pośpiechu z tego, co było pod ręką."
	static_icon = 'aquila/icons/mob/augmentation/ghetto.dmi'
	icon = null
	icon_state = "peg_r_arm"
	limb_id = "peg"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	aq_brute_mod = 1.2
	aq_burn_mod = 1.5
	aq_chunky_fingers = TRUE
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/obj/item/bodypart/l_leg/aq_peg
	name = "lewa drewniana noga"
	desc = "Podejrzanie przypomina nogę od stołu. Chwieje się i skrzypi przy każdym kroku, ale da się na niej chodzić."
	static_icon = 'aquila/icons/mob/augmentation/ghetto.dmi'
	icon = null
	icon_state = "peg_l_leg"
	limb_id = "peg"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	aq_brute_mod = 1.2
	aq_burn_mod = 1.5
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/obj/item/bodypart/r_leg/aq_peg
	name = "prawa drewniana noga"
	desc = "Podejrzanie przypomina nogę od stołu. Chwieje się i skrzypi przy każdym kroku, ale da się na niej chodzić."
	static_icon = 'aquila/icons/mob/augmentation/ghetto.dmi'
	icon = null
	icon_state = "peg_r_leg"
	limb_id = "peg"
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_HUMANOID
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	aq_brute_mod = 1.2
	aq_burn_mod = 1.5
	aq_easy_attach = TRUE
	aq_cyberpsychosis_cost = 0

/datum/crafting_recipe/aq_peg_l_arm
	name = "lewa drewniana proteza ręki"
	result = /obj/item/bodypart/l_arm/aq_peg
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2, /obj/item/stack/sticky_tape = 1)
	category = CAT_ROBOT

/datum/crafting_recipe/aq_peg_r_arm
	name = "prawa drewniana proteza ręki"
	result = /obj/item/bodypart/r_arm/aq_peg
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2, /obj/item/stack/sticky_tape = 1)
	category = CAT_ROBOT

/datum/crafting_recipe/aq_peg_l_leg
	name = "lewa drewniana noga"
	result = /obj/item/bodypart/l_leg/aq_peg
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2, /obj/item/stack/sticky_tape = 1)
	category = CAT_ROBOT

/datum/crafting_recipe/aq_peg_r_leg
	name = "prawa drewniana noga"
	result = /obj/item/bodypart/r_leg/aq_peg
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2, /obj/item/stack/sticky_tape = 1)
	category = CAT_ROBOT

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

/// Kołki i protezy kinetyczne zakłada się, przykładając je do kikuta (tg TRAIT_EASY_ATTACH)
/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(aq_easy_attach && ishuman(C) && !animal_origin && !C.get_bodypart(body_zone) && isliving(user))
		var/mob/living/living_user = user
		if(!living_user.combat_mode)
			INVOKE_ASYNC(src, PROC_REF(aq_easy_attach_to), C, user)
			return
	return ..()

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
	if(aq_chunky_fingers)
		ADD_TRAIT(C, TRAIT_NOGUNS, REF(src))
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
		if(aq_chunky_fingers)
			REMOVE_TRAIT(old_owner, TRAIT_NOGUNS, REF(src))
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
