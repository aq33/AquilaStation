// AQUILA - skull wounds. A fracture or a compound fracture on the head is a cracked or a caved-in skull: the head is split
// down the middle by a displacement map drawn for our head sprite (aquila/icons/effects/skull_crack.dmi: a one pixel notch at the
// top, the right half with its eye one pixel lower, the jaw untouched; checked in a BYOND render against the look the
// user asked for). The tgstation cranial fissure map only flattened our head. The split skull uses it too. Like
// tgstation bones.dm on the head, the wound keeps giving brain traumas until the bone is fixed.

#define AQ_SKULL_FILTER "cranial_fissure_displacement"

/// Is any skull wound on the head: a cracked or caved-in skull, or a split one
/mob/living/carbon/proc/aq_has_skull_wound()
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	for(var/datum/wound/wound as anything in head?.wounds)
		if(QDELETED(wound))
			continue
		if(wound.wound_type == WOUND_CRANIAL || (wound.wound_type == WOUND_BLUNT && wound.severity >= WOUND_SEVERITY_SEVERE))
			return TRUE
	return FALSE

/// The head looks split open while a skull wound is on it
/mob/living/carbon/proc/aq_update_skull_filter()
	if(aq_has_skull_wound())
		// the map stores offsets of whole pixels as 128 +- 127/9 per pixel, so size 9 moves them by exactly one
		add_filter(AQ_SKULL_FILTER, 2, displacement_map_filter(icon('aquila/icons/effects/skull_crack.dmi', "displacement"), size = 9))
	else
		remove_filter(AQ_SKULL_FILTER)

/datum/wound/blunt
	/// Head texts, used instead of the limb ones when the bone breaks on the head
	var/skull_name
	var/skull_desc
	var/skull_examine_desc
	/// Brain traumas the broken skull keeps giving (tgstation brain_trauma_group), null for none
	var/skull_trauma_group
	/// How long one trauma lasts and how long the pause after it is, +/- 20%
	var/skull_trauma_cooldown = 0
	var/datum/brain_trauma/skull_trauma
	var/next_skull_trauma = 0

/datum/wound/blunt/apply_wound(obj/item/bodypart/new_limb, silent = FALSE)
	if(new_limb.body_zone == BODY_ZONE_HEAD && skull_name)
		name = skull_name
		desc = skull_desc
		examine_desc = skull_examine_desc
	. = ..()
	if(is_skull())
		victim.aq_update_skull_filter()
		cycle_skull_trauma()

/datum/wound/blunt/Destroy()
	var/mob/living/carbon/old_victim = victim
	var/was_skull = is_skull()
	QDEL_NULL(skull_trauma)
	. = ..()
	if(was_skull && !QDELETED(old_victim))
		old_victim.aq_update_skull_filter()

/datum/wound/blunt/proc/is_skull()
	return limb?.body_zone == BODY_ZONE_HEAD && skull_trauma_group

/datum/wound/blunt/wound_effects(delta_time)
	. = ..()
	if(skull_trauma && QDELETED(skull_trauma)) // cured by brain surgery
		skull_trauma = null
	if(is_skull() && world.time >= next_skull_trauma)
		cycle_skull_trauma()

/// tgstation: the trauma comes, goes away for a while, and another one comes
/datum/wound/blunt/proc/cycle_skull_trauma()
	if(skull_trauma)
		QDEL_NULL(skull_trauma)
	else
		skull_trauma = roll_skull_trauma()
	next_skull_trauma = world.time + rand(80, 120) * 0.01 * skull_trauma_cooldown

/// A random trauma of the group; gain_trauma_type() does not return the trauma, so the type is picked here
/datum/wound/blunt/proc/roll_skull_trauma()
	var/obj/item/organ/brain/brain = victim.getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return null
	var/list/possible = list()
	for(var/datum/brain_trauma/trauma_type as anything in subtypesof(skull_trauma_group))
		if(initial(trauma_type.random_gain) && brain.can_gain_trauma(trauma_type, TRAUMA_RESILIENCE_SURGERY))
			possible += trauma_type
	if(!length(possible))
		return null
	return brain.gain_trauma(pick(possible), TRAUMA_RESILIENCE_SURGERY)

/datum/wound/blunt/get_scan_text()
	. = ..()
	if(is_skull())
		. += " Dopóki kość się nie zrośnie, pacjent będzie miewał [severity >= WOUND_SEVERITY_CRITICAL ? "ciężkie" : "lekkie"] urazy mózgu."

/datum/wound/blunt/fracture
	skull_name = "Pęknięta czaszka"
	skull_desc = "Słyszysz trzask pękającej czaszki"
	skull_examine_desc = "pękniętą, zniekształconą czaszkę"
	skull_trauma_group = BRAIN_TRAUMA_MILD
	skull_trauma_cooldown = 1.5 MINUTES

/datum/wound/blunt/compound
	skull_name = "Wgnieciona czaszka"
	skull_desc = "Twoja czaszka zapada się z chrzęstem"
	skull_examine_desc = "wgniecioną czaszkę z wystającymi odłamkami kości"
	skull_trauma_group = BRAIN_TRAUMA_SEVERE
	skull_trauma_cooldown = 2.5 MINUTES
