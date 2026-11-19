// AQUILA - nerwy w kończynach (AquilaMed 5, etap 6). Ciężka rana cięta albo kłuta ręki lub nogi może przerwać nerw:
// kończyna przestaje boleć (ból jej ran nie liczy się do bólu), ręka z przerwanym nerwem upuszcza to, co trzyma,
// a noga podwija się przy chodzeniu (kula albo laska trzymają). Analizator pokazuje przerwany nerw, naprawia go
// operacja zszycia nerwu.

/// Chance per severe or critical slash / pierce wound on an arm or a leg
#define AQ_NERVE_CUT_CHANCE_SEVERE 15
#define AQ_NERVE_CUT_CHANCE_CRITICAL 30
/// Chance per Life (2 s) that a hand with a cut nerve lets go
#define AQ_NERVE_DROP_CHANCE 3
/// Chance per step that a leg with a cut nerve gives way
#define AQ_NERVE_STUMBLE_CHANCE 4

/obj/item/bodypart
	/// A cut nerve: no feeling, no grip or a leg that gives way
	var/aq_nerve_cut = FALSE

/obj/item/bodypart/proc/aq_can_cut_nerve()
	return IS_ORGANIC_LIMB(src) && (body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))

/obj/item/bodypart/proc/aq_cut_nerve()
	if(aq_nerve_cut || !aq_can_cut_nerve())
		return FALSE
	aq_nerve_cut = TRUE
	if(owner)
		to_chat(owner, "<span class='userdanger'>Coś pęka głęboko w ranie ([strefa_pl(body_zone)]), a potem tracisz w niej czucie!</span>")
	return TRUE

/// Severe cuts and stabs can cut a nerve
/datum/wound/proc/aq_roll_nerve()
	if(!limb || aq_from_treatment || severity < WOUND_SEVERITY_SEVERE || !limb.aq_can_cut_nerve())
		return
	if(prob(severity >= WOUND_SEVERITY_CRITICAL ? AQ_NERVE_CUT_CHANCE_CRITICAL : AQ_NERVE_CUT_CHANCE_SEVERE))
		limb.aq_cut_nerve()

/datum/wound/slash/on_apply()
	. = ..()
	aq_roll_nerve()

/datum/wound/pierce/on_apply()
	. = ..()
	aq_roll_nerve()

/// A limb with a cut nerve does not hurt
/mob/living/carbon/human/aq_limb_feels_pain(obj/item/bodypart/limb)
	return !limb.aq_nerve_cut && ..()

/// A hand with a cut nerve lets go now and then
/mob/living/carbon/human/proc/aq_handle_nerves()
	if(stat != CONSCIOUS)
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!limb.aq_nerve_cut || !limb.held_index || !prob(AQ_NERVE_DROP_CHANCE))
			continue
		var/obj/item/held = get_item_for_held_index(limb.held_index)
		if(held && dropItemToGround(held))
			to_chat(src, "<span class='warning'>Palce nie słuchają, [held.name] wypada ci z ręki ([strefa_pl(limb.body_zone)]).</span>")

/mob/living/carbon/human/aq_handle_pain()
	. = ..()
	aq_handle_nerves()

/// A leg with a cut nerve gives way while walking, unless a crutch or a cane holds it
/mob/living/carbon/human/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(Forced || buckled || !isturf(loc) || (movement_type & (FLYING | FLOATING)) || !(mobility_flags & MOBILITY_STAND))
		return
	for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/leg = get_bodypart(zone)
		if(!leg?.aq_nerve_cut || aq_walking_aids() || !prob(AQ_NERVE_STUMBLE_CHANCE))
			continue
		Knockdown(1.5 SECONDS)
		visible_message("<span class='warning'>Noga podwija się pod [src]!</span>", "<span class='warning'>Noga ([strefa_pl(zone)]) podwija się pod tobą!</span>")
		return

/mob/living/carbon/human/get_wound_scan_lines()
	. = ..()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(limb.aq_nerve_cut)
			. += "<span class='alert'><b>Przerwany nerw ([strefa_pl(limb.body_zone)]):</b> brak czucia, potrzebne zszycie nerwu.</span>"

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.aq_nerve_cut = FALSE

/datum/surgery_operation/limb/nerve_repair
	name = "zszycie nerwu"
	catalog_sections = list(SURGERY_SECTION_WOUNDS)
	rnd_name = "Neurorafia (zszycie nerwu)"
	desc = "Zszywa przerwany nerw w ręce albo nodze i przywraca w niej czucie i władzę."
	implements = list(TOOL_HEMOSTAT = 1, /obj/item/stack/medical/suture = 1.2, TOOL_WIRECUTTER = 2.85)
	time = 6 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/limb/nerve_repair/all_required_strings()
	return list("przerwany nerw w kończynie") + ..()

/datum/surgery_operation/limb/nerve_repair/state_check(obj/item/bodypart/limb)
	return limb.aq_nerve_cut

/datum/surgery_operation/limb/nerve_repair/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("Zaczynasz zszywać nerw ([FORMAT_LIMB_OWNER(limb)])..."), span_notice("[surgeon] zaczyna zszywać nerw ([FORMAT_LIMB_OWNER(limb)])."), span_notice("[surgeon] zaczyna operację ([FORMAT_LIMB_OWNER(limb)])."))

/datum/surgery_operation/limb/nerve_repair/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	limb.aq_nerve_cut = FALSE
	display_results(surgeon, limb.owner, span_notice("Zszywasz nerw ([FORMAT_LIMB_OWNER(limb)])."), span_notice("[surgeon] zszywa nerw ([FORMAT_LIMB_OWNER(limb)])."), span_notice("[surgeon] kończy operację ([FORMAT_LIMB_OWNER(limb)])."))
	display_pain(limb.owner, "Czucie wraca, a z nim ostry, kłujący ból!")

#undef AQ_NERVE_CUT_CHANCE_SEVERE
#undef AQ_NERVE_CUT_CHANCE_CRITICAL
#undef AQ_NERVE_DROP_CHANCE
#undef AQ_NERVE_STUMBLE_CHANCE
