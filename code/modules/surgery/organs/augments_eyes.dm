/obj/item/organ/cyberimp/eyes/hud
	name = "cybernetyczny HUD"
	desc = "Sztuczne fotoreceptory o wyspecjalizowanych funkcjach."
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = ORGAN_SLOT_EYES
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY

// HUD implants
/obj/item/organ/cyberimp/eyes/hud
	name = "implant HUD"
	desc = "Te cybernetyczne oczy wyświetlają HUD na wszystkim, co widzisz. Chyba."
	slot = ORGAN_SLOT_HUD
	var/HUD_type
	var/HUD_trait

/obj/item/organ/cyberimp/eyes/hud/Insert(var/mob/living/carbon/M, var/special = 0, drop_if_replaced = FALSE)
	..()
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.add_hud_to(M)
	if(HUD_trait)
		ADD_TRAIT(M, HUD_trait, ORGAN_TRAIT)

/obj/item/organ/cyberimp/eyes/hud/Remove(var/mob/living/carbon/M, var/special = 0)
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.remove_hud_from(M)
	if(HUD_trait)
		REMOVE_TRAIT(M, HUD_trait, ORGAN_TRAIT)
	..()

/obj/item/organ/cyberimp/eyes/hud/medical
	name = "implant HUD medycznego"
	desc = "Te cybernetyczne implanty oczu wyświetlają HUD medyczny na wszystkim, co widzisz."
	HUD_type = DATA_HUD_MEDICAL_ADVANCED
	HUD_trait = TRAIT_MEDICAL_HUD

/obj/item/organ/cyberimp/eyes/hud/security
	name = "implant HUD ochrony"
	desc = "Te cybernetyczne implanty oczu wyświetlają HUD ochrony na wszystkim, co widzisz."
	HUD_type = DATA_HUD_SECURITY_ADVANCED
	HUD_trait = TRAIT_SECURITY_HUD

/obj/item/organ/cyberimp/eyes/hud/diagnostic
	name = "implant HUD diagnostycznego"
	desc = "Te cybernetyczne implanty oczu wyświetlają HUD diagnostyczny na wszystkim, co widzisz."
	HUD_type = DATA_HUD_DIAGNOSTIC_ADVANCED

/obj/item/organ/cyberimp/eyes/hud/security/syndicate
	name = "przemycany implant HUD ochrony"
	desc = "Implant HUD ochrony marki Cybersun Industries. Te nielegalne cybernetyczne implanty oczu wyświetlają HUD ochrony na wszystkim, co widzisz."
	syndicate_implant = TRUE
