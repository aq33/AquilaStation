// AQUILA - kręgosłup jako narząd (AquilaMed 6, etap 4). Projekt własny: tg ma tylko implant w slocie "spine".
// Urazy kręgosłupa to dalej rany z medycyny 4 (wounds/spinal.dm): stłuczenie i złamanie nie uszkadzają narządu,
// żeby nie dublować złamania. Narząd dokłada tylko to, czego rana nie ma:
// - bez kręgosłupa bezwładne są ręce i nogi, zniszczony (zgniły przed przeszczepem, uszkodzony EMP) paraliżuje nogi;
// - przeszczepiony kręgosłup trzeba połączyć z mózgiem tą samą operacją co po przeszczepie głowy (medical/brainstem.dm);
// - tytanowy (cybernetyczny) nie łamie się, rdzeń można najwyżej stłuc; impuls EMP na chwilę wyłącza nogi.

#define AQ_SPINE_ORGAN_TRAIT "aq_spine_organ"
/// Same source as a leg giving out in wounds/spinal.dm, so aq_spine_twitch_end() clears it
#define AQ_SPINE_TWITCH_TRAIT "aq_spine_twitch"

/obj/item/organ/aq_spine
	name = "kręgosłup"
	desc = "Kręgi z rdzeniem kręgowym w środku. Bez niego ciało nie słucha głowy."
	icon = 'aquila/icons/obj/medical/organs_med6.dmi'
	icon_state = "spine"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_AQ_SPINE
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	w_class = WEIGHT_CLASS_NORMAL
	low_threshold_passed = "<span class='info'>Plecy sztywnieją i bolą przy każdym skręcie.</span>"
	high_threshold_passed = "<span class='warning'>Nogi drętwieją, a ból w plecach nie mija.</span>"
	now_failing = "<span class='danger'>Przestajesz czuć nogi.</span>"
	now_fixed = "<span class='info'>Czucie w nogach wraca.</span>"
	var/was_failing = FALSE

/obj/item/organ/aq_spine/cybernetic
	name = "kręgosłup tytanowy"
	desc = "Tytanowe kręgi z przewodem zamiast rdzenia. Nie łamią się, ale impuls EMP na chwilę odcina nogi."
	icon_state = "spine-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 1.5

/obj/item/organ/aq_spine/cybernetic/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	applyOrganDamage(20 / severity)
	for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/leg = owner.get_bodypart(zone)
		if(!leg || HAS_TRAIT_FROM(leg, TRAIT_PARALYSIS, AQ_SPINE_TWITCH_TRAIT))
			continue
		ADD_TRAIT(leg, TRAIT_PARALYSIS, AQ_SPINE_TWITCH_TRAIT)
		leg.update_disabled()
		addtimer(CALLBACK(leg, TYPE_PROC_REF(/obj/item/bodypart, aq_spine_twitch_end)), 8 SECONDS / severity)
	to_chat(owner, "<span class='userdanger'>Kręgosłup iskrzy, a nogi przestają cię słuchać!</span>")

/obj/item/organ/aq_spine/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(M?.loc)
		M.aq_update_spine_paralysis()

/obj/item/organ/aq_spine/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M && !QDELETED(M) && M.loc) // a body being deleted or a fresh dummy has nowhere to fall
		M.aq_update_spine_paralysis()

/obj/item/organ/aq_spine/on_life()
	. = ..()
	var/failing = !!(organ_flags & ORGAN_FAILING)
	if(failing != was_failing) // tylko przy zmianie, nie co tick
		was_failing = failing
		owner?.aq_update_spine_paralysis()

/// Podpowiedź leczenia w oknie analizatora
/obj/item/organ/proc/aq_treat_hint()
	return "Operacja, leki na narząd"

/obj/item/organ/aq_spine/aq_treat_hint()
	return "Goi się sam; zniszczony: wymiana kręgosłupa i połączenie pnia mózgu"

/obj/item/organ/pancreas/aq_treat_hint()
	return "Insulina doraźnie; niewydolna: przeszczep albo trzustka cybernetyczna"

/obj/item/organ/esophagus/aq_treat_hint()
	return "Goi się sam; zniszczony: wymiana przełyku"

/obj/item/organ/aq_spine/aq_scan_line()
	if(organ_flags & ORGAN_FAILING)
		return "<b>Zniszczony kręgosłup:</b> nogi sparaliżowane. Wymień kręgosłup i połącz pień mózgu."

/// Paralysis from the spine organ: none when it works, the legs when it is dead, everything without one
/mob/living/carbon/proc/aq_update_spine_paralysis()
	var/list/wanted = list()
	var/mob/living/carbon/human/H = src
	if(istype(H) && H.dna?.species?.mutantspine && H.dna.species.aq_has_med5_organs())
		var/obj/item/organ/aq_spine/spine = getorganslot(ORGAN_SLOT_AQ_SPINE)
		if(!spine)
			wanted = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		else if(spine.organ_flags & ORGAN_FAILING)
			wanted = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
	aq_set_limb_paralysis(AQ_SPINE_ORGAN_TRAIT, wanted)

/// Sets exactly these limb paralysis traits from one source (the others from it go); TRUE when something changed
/mob/living/carbon/proc/aq_set_limb_paralysis(source, list/wanted_traits)
	var/changed = FALSE
	for(var/trait in list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM))
		var/has = HAS_TRAIT_FROM(src, trait, source)
		if((trait in wanted_traits) && !has)
			ADD_TRAIT(src, trait, source)
			changed = TRUE
		else if(!(trait in wanted_traits) && has)
			REMOVE_TRAIT(src, trait, source)
			changed = TRUE
	if(!changed)
		return FALSE
	// Bee keeps the old disabled state of a limb, so the paralysis is cleared by hand (as in wounds/spinal.dm)
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.disabled == BODYPART_DISABLED_PARALYSIS && !HAS_TRAIT(part, TRAIT_PARALYSIS))
			part.set_disabled(BODYPART_NOT_DISABLED)
	update_disabled_bodyparts()
	return TRUE

/// A titanium spine does not break; no spine, nothing to injure. The wound itself stays the only injury
/mob/living/carbon/aq_injure_spine(severity = WOUND_SEVERITY_SEVERE, cervical = FALSE)
	var/mob/living/carbon/human/H = src
	if(!istype(H) || !H.dna?.species?.mutantspine || !H.dna.species.aq_has_med5_organs())
		return ..()
	var/obj/item/organ/aq_spine/spine = getorganslot(ORGAN_SLOT_AQ_SPINE)
	if(!spine)
		return null
	if(spine.organ_flags & ORGAN_SYNTHETIC)
		severity = min(severity, WOUND_SEVERITY_SEVERE)
	return ..(severity, cervical)

/// A transplanted spine is not joined to the brain yet
/datum/surgery_operation/limb/organ_manipulation/on_success_insert_organ(obj/item/bodypart/limb, mob/living/surgeon, operated_zone, obj/item/tool)
	var/obj/item/organ/organ = get_inserted_organ(tool)
	. = ..()
	if(istype(organ, /obj/item/organ/aq_spine) && limb.owner && organ.owner == limb.owner)
		limb.owner.aq_disconnect_brainstem()

/datum/design/cybernetic_spine
	name = "Kręgosłup tytanowy"
	desc = "Tytanowe kręgi z przewodem zamiast rdzenia kręgowego."
	id = "aq_cybernetic_spine"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 1000, /datum/material/gold = 200)
	build_path = /obj/item/organ/aq_spine/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

#undef AQ_SPINE_ORGAN_TRAIT
#undef AQ_SPINE_TWITCH_TRAIT
