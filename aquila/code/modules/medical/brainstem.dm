// AQUILA - pień mózgu po przeszczepie (AquilaMed 5, etap 8). Na wzór Bay: przyszyta głowa albo przeszczepiony mózg
// nie są od razu połączone z rdzeniem. Pacjent ma bezwładne ręce i nogi (rana kręgosłupa jak przy złamaniu szyjnym,
// wounds/spinal.dm) aż do operacji połączenia pnia mózgu na otwartej czaszce. Po niej przez 5 minut jest osłabiony:
// wolniej chodzi i wolniej odzyskuje siły.

#define AQ_BRAINSTEM_TRAIT "aq_brainstem"

/// The brain is not joined to the spinal cord yet: all four limbs are limp until the surgery
/datum/wound/spinal/brainstem
	name = "Niepołączony pień mózgu"
	desc = "Ciało nie słucha głowy, nie czujesz rąk ani nóg"
	examine_desc = "bezwładne ręce i nogi"
	treat_text = "Operacja na otwartej czaszce: połączenie pnia mózgu (hemostat albo nici chirurgiczne). Po niej kilka minut osłabienia."
	severity = WOUND_SEVERITY_CRITICAL
	var/static/list/paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)

/datum/wound/spinal/brainstem/on_apply()
	for(var/trait in paralysis_traits)
		ADD_TRAIT(victim, trait, AQ_BRAINSTEM_TRAIT)
	victim.update_disabled_bodyparts()

/datum/wound/spinal/brainstem/Destroy()
	var/mob/living/carbon/old_victim = victim
	. = ..()
	if(QDELETED(old_victim))
		return
	for(var/trait in paralysis_traits)
		REMOVE_TRAIT(old_victim, trait, AQ_BRAINSTEM_TRAIT)
	// Bee keeps the old disabled state of a limb, so the paralysis is cleared by hand (as in spinal.dm)
	for(var/obj/item/bodypart/part as anything in old_victim.bodyparts)
		if(part.disabled == BODYPART_DISABLED_PARALYSIS && !HAS_TRAIT(part, TRAIT_PARALYSIS))
			part.set_disabled(BODYPART_NOT_DISABLED)
	old_victim.update_disabled_bodyparts()

/datum/wound/spinal/brainstem/get_scan_text()
	return "Pień mózgu: <b>[name]</b>. Sparaliżowane ręce i nogi. [treat_text]"

/datum/wound/spinal/brainstem/get_scar_description()
	return "bliznę dookoła szyi"

/// Surgery done: the limbs work again, weakness for a few minutes
/datum/wound/spinal/brainstem/proc/connect()
	var/mob/living/carbon/patient = victim
	qdel(src)
	patient?.apply_status_effect(/datum/status_effect/aq_transplant_weakness)

/// After a head is sewn on or a brain is put in: the stem is not joined yet
/mob/living/carbon/proc/aq_disconnect_brainstem()
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest || !IS_ORGANIC_LIMB(chest) || !getorganslot(ORGAN_SLOT_BRAIN))
		return null
	var/datum/wound/spinal/existing = chest.get_wound(WOUND_SPINE)
	if(istype(existing, /datum/wound/spinal/brainstem))
		return existing
	qdel(existing) // a broken spine under a new head is joined in the same surgery
	var/datum/wound/spinal/brainstem/wound = new()
	wound.apply_wound(chest)
	return wound

/datum/surgery_operation/limb/prosthetic_replacement/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	. = ..()
	if(operation_args[OPERATION_TARGET_ZONE] != BODY_ZONE_HEAD || !patient)
		return
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	if(head && IS_ORGANIC_LIMB(head))
		patient.aq_disconnect_brainstem()

/datum/surgery_operation/limb/organ_manipulation/on_success_insert_organ(obj/item/bodypart/limb, mob/living/surgeon, operated_zone, obj/item/tool)
	var/obj/item/organ/organ = get_inserted_organ(tool)
	. = ..()
	if(istype(organ, /obj/item/organ/brain) && limb.owner && organ.owner == limb.owner)
		limb.owner.aq_disconnect_brainstem()

/datum/surgery_operation/limb/aq_connect_brainstem
	name = "połączenie pnia mózgu"
	catalog_sections = list(SURGERY_SECTION_HEAD)
	rnd_name = "Połączenie pnia mózgu z rdzeniem"
	desc = "Łączy pień mózgu przyszytej głowy albo przeszczepionego mózgu z rdzeniem kręgowym. Do tego czasu pacjent ma bezwładne ręce i nogi."
	implements = list(TOOL_HEMOSTAT = 1, /obj/item/stack/medical/suture = 1.5, TOOL_WIRECUTTER = 3)
	time = 8 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/limb/aq_connect_brainstem/all_required_strings()
	return list("operacja na głowie", "pień mózgu niepołączony po przeszczepie") + ..()

/datum/surgery_operation/limb/aq_connect_brainstem/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != BODY_ZONE_HEAD || !limb.owner)
		return FALSE
	var/obj/item/bodypart/chest = limb.owner.get_bodypart(BODY_ZONE_CHEST)
	return istype(chest?.get_wound(WOUND_SPINE), /datum/wound/spinal/brainstem)

/datum/surgery_operation/limb/aq_connect_brainstem/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("Zaczynasz łączyć pień mózgu [limb.owner] z rdzeniem..."), span_notice("[surgeon] zaczyna łączyć pień mózgu [limb.owner]."), span_notice("[surgeon] zaczyna operację mózgu [limb.owner]."))
	display_pain(limb.owner, "Prąd przeszywa ci kark i całe ciało!")

/datum/surgery_operation/limb/aq_connect_brainstem/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/bodypart/chest = limb.owner.get_bodypart(BODY_ZONE_CHEST)
	var/datum/wound/spinal/brainstem/wound = chest?.get_wound(WOUND_SPINE)
	if(!istype(wound))
		return
	wound.connect()
	display_results(surgeon, limb.owner, span_notice("Łączysz pień mózgu [limb.owner] z rdzeniem."), span_notice("[surgeon] łączy pień mózgu [limb.owner]."), span_notice("[surgeon] kończy operację mózgu [limb.owner]."))

/datum/surgery_operation/limb/aq_connect_brainstem/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	limb.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	display_results(surgeon, limb.owner, span_warning("Ręka ci się omsknęła i kaleczysz pień mózgu [limb.owner]!"), span_warning("[surgeon] kaleczy pień mózgu [limb.owner]!"), span_warning("[surgeon] partaczy!"))

// --- Osłabienie po przeszczepie ---

/datum/status_effect/aq_transplant_weakness
	id = "aq_transplant_weakness"
	duration = 5 MINUTES
	alert_type = null

/datum/status_effect/aq_transplant_weakness/on_apply()
	owner.add_movespeed_modifier_type(/datum/movespeed_modifier/aq_transplant_weakness) // datum API: the 0.6 slowdown comes from the type
	owner.stamina?.add_regen_multiplier(id, 0.5)
	to_chat(owner, "<span class='notice'>Ciało znowu cię słucha, ale każdy ruch kosztuje dużo siły.</span>")
	return TRUE

/datum/status_effect/aq_transplant_weakness/on_remove()
	owner.remove_movespeed_modifier_type(/datum/movespeed_modifier/aq_transplant_weakness)
	owner.stamina?.remove_regen_multiplier(id)
	to_chat(owner, "<span class='green'>Słabość po przeszczepie mija.</span>")

/datum/movespeed_modifier/aq_transplant_weakness
	multiplicative_slowdown = 0.6

/mob/living/carbon/human/get_wound_scan_lines()
	. = ..()
	var/datum/status_effect/aq_transplant_weakness/weakness = has_status_effect(/datum/status_effect/aq_transplant_weakness)
	if(weakness)
		. += "<span class='notice'>Osłabienie po przeszczepie: jeszcze [DisplayTimeText(weakness.duration - world.time)].</span>"

#undef AQ_BRAINSTEM_TRAIT
