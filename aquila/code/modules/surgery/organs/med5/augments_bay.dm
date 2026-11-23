// AQUILA - augmenty z Baystation12/Torch (AquilaMed 5, etap 12). Pomysły z code/modules/augment/ (Bay), sprite'y z
// Bay icons/obj/augment.dmi (CC BY-SA 3.0). Dopisane tylko te, których nie było: polinarzędzia, przechwytywacz synaps
// (restart OUN), ostrza i działka w ramieniu już mamy z tg/Bee. Idą z R&D (protolathe i fabrykator robotyki).
// Pazury i kusza z Bay usunięte: dublowały ostrza modliszki i mini kuszę z uplinku.
// Różnice od Bay: zamiast systemu slotów augmentów z Bay zwykłe implanty cybernetyczne (wszczepia je operacja na
// narządach albo autochirurg), pancerz przez physiology, celowanie przez rozrzut broni z gunplay/recoil.dm.

#define ORGAN_SLOT_AQ_SUBDERMAL "aq_subdermal_armor"
#define ORGAN_SLOT_AQ_AIM "aq_aim"
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
		owner.Jitter(20 / severity) // EMP_HEAVY = 1, EMP_LIGHT = 2: a heavy pulse shakes harder
		to_chat(owner, "<span class='warning'>Wzmacniacz celowania szarpie ci rękami!</span>")

/obj/item/gun/get_dynamic_spread(mob/living/user)
	. = ..()
	if(user && HAS_TRAIT(user, TRAIT_AQ_STEADY_AIM))
		. *= 0.5

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

/datum/techweb_node/adv_cyber_implants/New()
	. = ..()
	design_ids += list("aq_subdermal_armor")

/datum/techweb_node/combat_cyber_implants/New()
	. = ..()
	design_ids += list("aq_aim")

#undef ORGAN_SLOT_AQ_SUBDERMAL
#undef ORGAN_SLOT_AQ_AIM
#undef TRAIT_AQ_STEADY_AIM

// ERT: ochrona w pełnym alarmie dostaje parę ostrzy modliszki C.H.R.O.M.A.T.A. (wersja z R&D Nanotrasen,
// cybernetics/mantis_blades.dm)
/datum/outfit/ert/security/alert
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/gun/energy/pulse/carbine/loyalpin=1,
		/obj/item/autosurgeon/aq_mantis_ert=1)

/obj/item/autosurgeon/aq_mantis_ert
	name = "autochirurg (ostrza modliszki)"
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/mantis, /obj/item/organ/cyberimp/arm/mantis/l)
