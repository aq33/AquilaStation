// AQUILA - medical overlays on the body (medycyna 4), drawn with the bleeding overlays (bleed_overlays.dm):
// - bandages on a bandaged limb, from a patch to a full wrap by how much bleeding they hold (tgstation icons/mob/human/bandage.dmi);
// - splints on a splinted fracture of an arm or a leg, a brace on a stabilised broken spine (the neck: a halo),
//   stumps of torn off limbs and the open skull during brain surgery (cmss13 icons/mob/humans/onmob/med_human.dmi
//   and icons/mob/humans/dam_human.dmi).
// Sprites in aquila/icons/mob/effects/medical_overlays.dmi, tgstation and cmss13, both CC-BY-SA 3.0.
// The cracked skull is not here: it is the cranial fissure displacement on the head (wounds/skull.dm).

#define AQ_MEDICAL_OVERLAY_ICON 'aquila/icons/mob/effects/medical_overlays.dmi'

/mob/living/carbon
	/// Splints, braces, wrapped wounds, stumps and the open skull: rebuilt only after aq_medical_overlays_changed()
	var/list/aq_medical_static_states
	/// Zones wrapped because of a treated wound (bandage stage 1 unless the bleeding asks for more)
	var/list/aq_medical_wrapped_zones
	var/aq_medical_states_dirty = TRUE

/// Something the medical overlays show changed (wound, treatment, surgery, limb): rebuild them
/mob/living/carbon/proc/aq_medical_overlays_changed()
	aq_medical_states_dirty = TRUE
	update_wound_overlays()

/mob/living/carbon/proc/aq_rebuild_medical_static_states()
	aq_medical_states_dirty = FALSE
	aq_medical_static_states = list()
	aq_medical_wrapped_zones = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/zone = limb.body_zone
		var/arm_or_leg = zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_R_ARM || zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG
		for(var/datum/wound/wound as anything in limb.wounds)
			if(wound.wound_type == WOUND_BLUNT && wound.treated && wound.severity >= WOUND_SEVERITY_SEVERE)
				if(arm_or_leg)
					aq_medical_static_states += "splint_[zone]"
					if(zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG)
						aq_medical_static_states += "splint_[zone == BODY_ZONE_L_LEG ? "l" : "r"]_foot"
				else
					aq_medical_wrapped_zones |= zone // a splinted chest or head is wrapped
			else if((wound.wound_type == WOUND_SLASH || wound.wound_type == WOUND_PIERCE || wound.wound_type == WOUND_BURN) && wound.treated)
				aq_medical_wrapped_zones |= zone
			else if(istype(wound, /datum/wound/spinal/fracture))
				var/datum/wound/spinal/fracture/spine = wound
				if(spine.stabilized)
					aq_medical_static_states += spine.cervical ? "brace_neck" : "brace_torso"
		if(zone == BODY_ZONE_HEAD && LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
			aq_medical_static_states += "skull_open"
	// Stumps of torn off limbs
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!get_bodypart(zone))
			aq_medical_static_states += "!stump_[zone]_blood"
			aq_medical_static_states += "stump_[zone]_bone"

/// Overlay states for the medical overlays. A state starting with "!" is tinted with the blood colour.
/// Called on every bleeding tick, so only the bandages (their stage follows the bleeding they hold) are computed here.
/mob/living/carbon/proc/aq_medical_overlay_states()
	. = list()
	if(!ishuman(src))
		return
	if(aq_medical_states_dirty)
		aq_rebuild_medical_static_states()
	. += aq_medical_static_states
	// Bandages: the more bleeding they hold, the more of the limb they cover
	var/list/bandaged_zones = list()
	for(var/zone in aq_medical_wrapped_zones)
		bandaged_zones[zone] = 1
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(bleed)
		for(var/zone in bleed.limb_bandaged)
			if(get_bodypart(zone))
				bandaged_zones[zone] = bleed.limb_bandaged[zone] >= BLEED_CUT ? 3 : (bleed.limb_bandaged[zone] >= 1 ? 2 : 1)
	for(var/zone in bandaged_zones)
		. += "bandage_[zone][bandaged_zones[zone]]"

/// Appearances for the medical overlays, plain and blood tinted
/mob/living/carbon/proc/aq_medical_overlays(list/states, draw_layer)
	. = list()
	var/mutable_appearance/plain = mutable_appearance(AQ_MEDICAL_OVERLAY_ICON, null, -draw_layer, appearance_flags = KEEP_TOGETHER)
	var/mutable_appearance/bloody = mutable_appearance(AQ_MEDICAL_OVERLAY_ICON, null, -draw_layer, appearance_flags = KEEP_TOGETHER)
	bloody.color = get_blood_color()
	for(var/state in states)
		if(copytext(state, 1, 2) == "!")
			bloody.add_overlay(copytext(state, 2))
		else
			plain.add_overlay(state)
	if(length(bloody.overlays))
		. += bloody
	if(length(plain.overlays))
		. += plain

// Things that change the medical overlays

/// A wound appeared, healed or got treated: wounds call this on apply and on Destroy (this file is included before
/// _wounds.dm, so a Destroy override here would run after the wound forgot its victim)
/mob/living/carbon/update_wound_slowdown()
	. = ..()
	aq_medical_overlays_changed()

/obj/item/bodypart/update_surgical_state(old_state, changed_states)
	. = ..()
	owner?.aq_medical_overlays_changed()

/obj/item/bodypart/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(!QDELETED(old_owner))
		old_owner.aq_medical_overlays_changed()

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(!QDELETED(C))
		C.aq_medical_overlays_changed()

#undef AQ_MEDICAL_OVERLAY_ICON
