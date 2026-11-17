// AQUILA - augmenty z Baystation12/Torch (AquilaMed 5, etap 12). Pomysły z code/modules/augment/ (Bay), sprite'y z
// Bay icons/obj/augment.dmi (CC BY-SA 3.0). Dopisane tylko te, których nie było: polinarzędzia, przechwytywacz synaps
// (restart OUN), ostrza i działka w ramieniu już mamy z tg/Bee. Cywilne idą z R&D (protolathe i fabrykator robotyki),
// broń w ramieniu (pazury, kusza) z uplinku, czarnego rynku i dla ochrony ERT w pełnym alarmie (pazury).
// Różnice od Bay: zamiast systemu slotów augmentów z Bay zwykłe implanty cybernetyczne (wszczepia je operacja na
// narządach albo autochirurg), pancerz i mięśnie przez physiology, celowanie przez rozrzut broni z gunplay/recoil.dm.

#define ORGAN_SLOT_AQ_SUBDERMAL "aq_subdermal_armor"
#define ORGAN_SLOT_AQ_MUSCLE "aq_muscle"
#define ORGAN_SLOT_AQ_AIM "aq_aim"
#define ORGAN_SLOT_AQ_NANITES "aq_repair_nanites"
#define TRAIT_AQ_STEADY_AIM "aq_steady_aim"

/// Subdermal armor plates: the skin takes blows and bullets better
/obj/item/organ/cyberimp/chest/aq_subdermal_armor
	name = "podskórna siatka pancerna"
	desc = "Siatka z kevlaru i ceramiki wszczepiana pod skórę tułowia. Łagodzi ciosy i postrzały."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "armor-chest"
	slot = ORGAN_SLOT_AQ_SUBDERMAL
	implant_color = null

/obj/item/organ/cyberimp/chest/aq_subdermal_armor/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	var/mob/living/carbon/human/H = M
	if(istype(H))
		H.physiology.armor = H.physiology.armor.modifyRating(melee = 15, bullet = 10)

/obj/item/organ/cyberimp/chest/aq_subdermal_armor/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = M
	if(istype(H))
		H.physiology.armor = H.physiology.armor.modifyRating(melee = -15, bullet = -10)
	return ..()

/// Reinforced muscles: harder punches, less tiring blows
/obj/item/organ/cyberimp/chest/aq_muscle
	name = "wzmocnienie mięśni"
	desc = "Syntetyczne włókna wplecione w mięśnie ramion i barków. Pięść uderza mocniej, a ciosy mniej męczą."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "muscule"
	slot = ORGAN_SLOT_AQ_MUSCLE
	implant_color = null

/obj/item/organ/cyberimp/chest/aq_muscle/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	var/mob/living/carbon/human/H = M
	if(istype(H))
		H.unarmed_damage_bonus += 4
		H.physiology.stamina_mod *= 0.8

/obj/item/organ/cyberimp/chest/aq_muscle/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = M
	if(istype(H))
		H.unarmed_damage_bonus -= 4
		H.physiology.stamina_mod /= 0.8
	return ..()

/// Aiming booster: half the extra spread from moving, recoil and wounds
/obj/item/organ/cyberimp/brain/aq_aim
	name = "wzmacniacz celowania"
	desc = "Koprocesor ruchowy, który tłumi drżenie rąk i odrzut. Broń rozrzuca o połowę mniej, gdy strzelasz w ruchu albo seriami."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "booster"
	slot = ORGAN_SLOT_AQ_AIM
	implant_color = null

/obj/item/organ/cyberimp/brain/aq_aim/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	ADD_TRAIT(M, TRAIT_AQ_STEADY_AIM, REF(src))

/obj/item/organ/cyberimp/brain/aq_aim/Remove(mob/living/carbon/M, special = 0)
	REMOVE_TRAIT(M, TRAIT_AQ_STEADY_AIM, REF(src))
	return ..()

/obj/item/organ/cyberimp/brain/aq_aim/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF) && owner)
		owner.Jitter(10 * severity)
		to_chat(owner, "<span class='warning'>Wzmacniacz celowania szarpie ci rękami!</span>")

/obj/item/gun/get_dynamic_spread(mob/living/user)
	. = ..()
	if(user && HAS_TRAIT(user, TRAIT_AQ_STEADY_AIM))
		. *= 0.5

/// Repair nanites: slowly mend prosthetic limbs
/obj/item/organ/cyberimp/chest/aq_repair_nanites
	name = "nanity naprawcze"
	desc = "Rój nanitów w krwiobiegu, który powoli łata protezy kończyn. Organicznego ciała nie leczy."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "leukosuite"
	slot = ORGAN_SLOT_AQ_NANITES
	implant_color = null

/obj/item/organ/cyberimp/chest/aq_repair_nanites/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || (organ_flags & ORGAN_FAILING))
		return
	for(var/obj/item/bodypart/limb as anything in owner.bodyparts)
		if(!IS_ORGANIC_LIMB(limb) && (limb.brute_dam || limb.burn_dam))
			if(limb.heal_damage(0.5, 0.5, null, BODYTYPE_ROBOTIC))
				owner.update_damage_overlays()
			return

/obj/item/organ/cyberimp/chest/aq_repair_nanites/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(40 / severity)

// --- Broń w ramieniu (tylko uplink) ---

/obj/item/aq_implant_claws
	name = "pazury bojowe"
	desc = "Trzy ostrza wysuwane spomiędzy kłykci. Nie odrastają."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "wolverine"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	item_state = "knife"
	force = 16
	w_class = WEIGHT_CLASS_BULKY
	sharpness = IS_SHARP
	attack_verb = list("tnie", "dźga", "rozrywa")
	hitsound = 'sound/weapons/bladeslice.ogg'
	item_flags = DROPDEL
	bleed_force = BLEED_CUT

/obj/item/organ/cyberimp/arm/aq_claws
	name = "implant pazurów bojowych"
	desc = "Pochwa z trzema ostrzami wszczepiana w dłoń. Pazury wysuwają się na myśl właściciela."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "wolverine"
	items_to_create = list(/obj/item/aq_implant_claws)
	implant_color = null

/obj/item/organ/cyberimp/arm/aq_crossbow
	name = "implant kuszy energetycznej"
	desc = "Miniaturowa kusza energetyczna ukryta w przedramieniu. Strzela bełtami z obezwładniającą toksyną."
	icon = 'aquila/icons/obj/medical/augments_bay.dmi'
	icon_state = "circuit"
	items_to_create = list(/obj/item/gun/energy/kinetic_accelerator/crossbow)
	implant_color = null

/obj/item/autosurgeon/syndicate/aq_claws
	name = "podejrzany autochirurg (pazury bojowe)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/aq_claws)

/obj/item/autosurgeon/syndicate/aq_crossbow
	name = "podejrzany autochirurg (kusza w ramieniu)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/aq_crossbow)

/datum/uplink_item/implants/aq_claws
	name = "Implant pazurów bojowych"
	desc = "Pazury wysuwane z dłoni na myśl właściciela, ostre i nie do wytrącenia z ręki. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_claws
	cost = 8
	surplus = 20

/datum/uplink_item/implants/aq_crossbow
	name = "Implant kuszy energetycznej"
	desc = "Miniaturowa kusza energetyczna ukryta w przedramieniu, nie do wytrącenia z ręki. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_crossbow
	cost = 14
	surplus = 10
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

// --- Projekty R&D ---

/datum/design/aq_subdermal_armor
	name = "Podskórna siatka pancerna"
	desc = "Implant: siatka pancerna pod skórą tułowia."
	id = "aq_subdermal_armor"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(/datum/material/iron = 2000, /datum/material/plasma = 500, /datum/material/titanium = 1000)
	build_path = /obj/item/organ/cyberimp/chest/aq_subdermal_armor
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_muscle
	name = "Wzmocnienie mięśni"
	desc = "Implant: syntetyczne włókna mięśniowe."
	id = "aq_muscle"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 500)
	build_path = /obj/item/organ/cyberimp/chest/aq_muscle
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_aim
	name = "Wzmacniacz celowania"
	desc = "Implant: koprocesor tłumiący drżenie rąk."
	id = "aq_aim"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/gold = 500, /datum/material/uranium = 300)
	build_path = /obj/item/organ/cyberimp/brain/aq_aim
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_repair_nanites
	name = "Nanity naprawcze"
	desc = "Implant: nanity łatające protezy kończyn."
	id = "aq_repair_nanites"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 400, /datum/material/diamond = 200)
	build_path = /obj/item/organ/cyberimp/chest/aq_repair_nanites
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/adv_cyber_implants/New()
	. = ..()
	design_ids += list("aq_subdermal_armor", "aq_muscle", "aq_repair_nanites")

/datum/techweb_node/combat_cyber_implants/New()
	. = ..()
	design_ids += list("aq_aim")

#undef ORGAN_SLOT_AQ_SUBDERMAL
#undef ORGAN_SLOT_AQ_MUSCLE
#undef ORGAN_SLOT_AQ_AIM
#undef ORGAN_SLOT_AQ_NANITES
#undef TRAIT_AQ_STEADY_AIM

// ERT: ochrona w pełnym alarmie dostaje pazury, czarny rynek ma oba implanty (łup)
/datum/outfit/ert/security/alert
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/gun/energy/pulse/carbine/loyalpin=1,
		/obj/item/autosurgeon/aq_claws_ert=1)

/obj/item/autosurgeon/aq_claws_ert
	name = "autochirurg (pazury bojowe)"
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/aq_claws)

/datum/market_item/shoddy_implant/aq_claws
	name = "Używane pazury bojowe"
	desc = "Implant pazurów z odzysku, z autochirurgiem. Ktoś je już nosił."
	item = /obj/item/autosurgeon/syndicate/aq_claws
	price_min = MARKET_CRATE_VALUE * 4
	price_max = MARKET_CRATE_VALUE * 6
	availability_prob = 25

/datum/market_item/shoddy_implant/aq_crossbow
	name = "Używana kusza w przedramieniu"
	desc = "Implant miniaturowej kuszy energetycznej z odzysku, z autochirurgiem."
	item = /obj/item/autosurgeon/syndicate/aq_crossbow
	price_min = MARKET_CRATE_VALUE * 6
	price_max = MARKET_CRATE_VALUE * 9
	availability_prob = 15
