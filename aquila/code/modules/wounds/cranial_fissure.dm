// AQUILA - cranial fissure from tgstation (code/datums/wounds/cranial_fissure.dm). A big hit on the head of someone
// already in hard crit splits the skull open: anyone can reach in and pull the eyes out, and slipping spills the brain.
// Fixed only by the skull reconstruction surgery.

#define CRANIAL_FISSURE_FILTER "cranial_fissure_displacement"

/datum/wound/cranial_fissure
	wound_type = WOUND_CRANIAL
	name = "Pęknięcie czaszki"
	desc = "Twoja czaszka pęka na dwie części"
	examine_desc = "rozłupaną czaszkę"
	treat_text = "Operacja rekonstrukcji czaszki."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = WOUND_CRANIAL_THRESHOLD
	threshold_penalty = 40
	allowed_zones = list(BODY_ZONE_HEAD)

/datum/wound/cranial_fissure/on_apply()
	playsound(victim, 'sound/effects/splat.ogg', 80, TRUE)
	victim.add_filter(CRANIAL_FISSURE_FILTER, 2, displacement_map_filter(icon('aquila/icons/effects/cranial_fissure.dmi', "displacement"), size = 3))
	RegisterSignal(victim, COMSIG_PARENT_QDELETING, PROC_REF(on_victim_deleted))

/datum/wound/cranial_fissure/Destroy()
	if(victim)
		victim.remove_filter(CRANIAL_FISSURE_FILTER)
	return ..()

/datum/wound/cranial_fissure/proc/on_victim_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Slipping spills the brain out of the open skull
/datum/wound/cranial_fissure/proc/spill_brain()
	if(victim.stat == DEAD)
		return
	var/obj/item/organ/brain/brain = victim.getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return
	var/turf/victim_turf = get_turf(victim)
	brain.Remove(victim)
	brain.forceMove(victim_turf)
	brain.throw_at(get_step(victim_turf, victim.dir), 1, 1)
	victim.visible_message("<span class='boldwarning'>Mózg [victim] wylewa się z rozłupanej czaszki!</span>", \
		"<span class='userdanger'>Twój mózg wylewa się z czaszki!</span>")

/// Pulling the eyes out through the skull: empty hand, help, aiming at the head, the victim lying down
/datum/wound/cranial_fissure/proc/pull_eyes(mob/living/carbon/user)
	var/obj/item/organ/eyes/eyes = victim.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		victim.balloon_alert(user, "nie ma oczu!")
		return
	playsound(victim, 'sound/surgery/organ2.ogg', 50, TRUE)
	user.visible_message("<span class='boldwarning'>[user] sięga do wnętrza czaszki [victim]...</span>", ignored_mobs = list(user, victim))
	to_chat(user, "<span class='warning'>Sięgasz do wnętrza czaszki [victim] i chwytasz oczy...</span>")
	to_chat(victim, "<span class='userdanger'>[user] sięga do twojej czaszki i ciągnie za oczy!</span>")
	if(!do_mob(user, victim, 10 SECONDS) || QDELETED(src) || victim.getorganslot(ORGAN_SLOT_EYES) != eyes)
		return
	eyes.Remove(victim)
	user.put_in_hands(eyes)
	log_combat(user, victim, "pulled out the eyes of")
	playsound(victim, 'sound/surgery/organ1.ogg', 75, TRUE)
	user.visible_message("<span class='boldwarning'>[user] wyrywa oczy [victim]!</span>", "<span class='boldwarning'>Wyrywasz oczy [victim]!</span>", ignored_mobs = victim)
	to_chat(victim, "<span class='userdanger'>[user] wyrywa ci oczy!</span>")

/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	. = ..()
	if(!.)
		return
	var/datum/wound/cranial_fissure/fissure = get_bodypart(BODY_ZONE_HEAD)?.get_wound(WOUND_CRANIAL)
	fissure?.spill_brain()

/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	var/zone = M.zone_selected
	if((zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES) && !(mobility_flags & MOBILITY_STAND) && !M.get_active_held_item() && !M.combat_mode)
		var/datum/wound/cranial_fissure/fissure = get_bodypart(BODY_ZONE_HEAD)?.get_wound(WOUND_CRANIAL)
		if(fissure)
			if(!(src in M.do_afters))
				INVOKE_ASYNC(fissure, TYPE_PROC_REF(/datum/wound/cranial_fissure, pull_eyes), M)
			return
	return ..()

// --- Skull reconstruction ---

/datum/surgery/aq_skull_repair
	name = "rekonstrukcja czaszki"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/aq_reconstruct_skull,
				/datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE

/datum/surgery/aq_skull_repair/can_start(mob/user, mob/living/carbon/target, target_zone)
	return !!target.get_bodypart(BODY_ZONE_HEAD)?.get_wound(WOUND_CRANIAL)

/datum/surgery_step/aq_reconstruct_skull
	name = "złóż czaszkę"
	implements = list(TOOL_BONESET = 100, TOOL_RETRACTOR = 70, TOOL_HEMOSTAT = 50, TOOL_CROWBAR = 25)
	time = 6 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'

/datum/surgery_step/aq_reconstruct_skull/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz składać rozłupaną czaszkę [target]...</span>",
		"[user] zaczyna składać czaszkę [target].",
		"[user] zaczyna operować głowę [target].")

/datum/surgery_step/aq_reconstruct_skull/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/wound/fissure = target.get_bodypart(BODY_ZONE_HEAD)?.get_wound(WOUND_CRANIAL)
	qdel(fissure)
	display_results(user, target, "<span class='notice'>Składasz czaszkę [target].</span>",
		"[user] składa czaszkę [target].",
		"[user] kończy operację głowy [target].")
	return TRUE

#undef CRANIAL_FISSURE_FILTER
