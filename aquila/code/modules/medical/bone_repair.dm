// AQUILA - bone gel, surgical tape and the bonesetter from tgstation
// (code/game/objects/items/stacks/medical.dm, stacks/tape.dm, modules/surgery/surgery_tools.dm).
// Gel and then tape on a fracture or a compound fracture make the bone knit by itself (aquila/code/modules/wounds/blunt.dm),
// in surgery they glue the set bone (/datum/surgery_step/aq_gel_bone). The bonesetter is the best tool for setting it.
// Sprites: surgical tape from tgstation (CC-BY-SA 3.0), bone gel and bonesetter from our icons/obj/surgery.dmi,
// bonesetter inhands from tgstation (CC-BY-SA 3.0).

/obj/item/stack/medical/bone_gel
	name = "żel kostny"
	singular_name = "żel kostny"
	desc = "Silny żel medyczny, który nałożony na uszkodzoną kość podczas operacji wywołuje gwałtowne stapianie i naprawia ją. \
		W nagłym wypadku można go nałożyć wprost na złamanie i owinąć taśmą chirurgiczną, ale to bardzo boli i nie jest zalecane."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	item_state = "bone-gel"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medkit_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medkit_righthand.dmi'
	amount = 5
	max_amount = 5
	self_delay = 2 SECONDS
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 10)

/obj/item/stack/medical/bone_gel/one
	amount = 1

/// Only for fractures (treatment.dm hands it to the wound), never the usual healing
/obj/item/stack/medical/bone_gel/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	M.balloon_alert(user, "brak złamań!")

/obj/item/stack/sticky_tape/surgical
	name = "taśma chirurgiczna"
	singular_name = "taśma chirurgiczna"
	desc = "Do łatania złamanych kości razem z żelem kostnym, nie do robienia psikusów."
	icon = 'aquila/icons/obj/medical/medical_tg.dmi'
	icon_state = "tape_surgical"
	w_class = WEIGHT_CLASS_TINY
	prefix = "surgical"
	conferred_embed = list("embed_chance" = 30, "pain_mult" = 0, "jostle_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE)
	custom_price = 50

/// On a gelled fracture the tape starts the knitting, the mouth stays for tape gags
/obj/item/stack/sticky_tape/surgical/attack(mob/living/M, mob/living/user)
	if(!iscarbon(M) || (user.zone_selected == BODY_ZONE_PRECISE_MOUTH && !user.combat_mode))
		return ..()
	var/mob/living/carbon/patient = M
	if(patient in user.do_afters)
		return
	var/datum/wound/wound = patient.get_treatable_wound(patient.get_bodypart(check_zone(user.zone_selected)), src)
	if(!wound)
		return ..()
	INVOKE_ASYNC(wound, TYPE_PROC_REF(/datum/wound, treat), src, user)

/obj/item/bonesetter
	name = "nastawiacz kości"
	desc = "Żeby wszystko wróciło na swoje miejsce."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone_setter"
	item_state = "bonesetter"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medical_tg_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medical_tg_righthand.dmi'
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("koryguje", "porządnie nastawia")
	tool_behaviour = TOOL_BONESET
	toolspeed = 1
