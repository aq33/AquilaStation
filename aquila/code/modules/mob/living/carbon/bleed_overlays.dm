// AQUILA - bleeding overlays on the body from tgstation (/obj/item/bodypart/proc/update_part_wound_overlay(),
// /mob/living/carbon/proc/update_wound_overlays(), the eye puncture overlay of /datum/wound/pierce/bleed/severe/eye).
// Sprites: tgstation icons/mob/effects/bleed_overlays.dmi (CC-BY-SA 3.0), greyscale, tinted with the blood colour.
// The bleeding of each limb comes from blood_limbs.dm; a stump bleeds on the chest.

/// Drawn above the hands and body front overlays, below smell/halo/fire (tg WOUND_LAYER is just above BODY_FRONT_LAYER)
#define AQ_WOUND_DRAW_LAYER (BODY_FRONT_LAYER - 0.5)
/// Thresholds on our bleed scale (tg: 0.5, 1.5 and 3.25 on theirs)
#define AQ_BLEED_OVERLAY_LOW 0.3
#define AQ_BLEED_OVERLAY_MED BLEED_CUT
#define AQ_BLEED_OVERLAY_GUSH BLEED_CRITICAL

/mob/living/carbon
	/// Bleed overlay states shown now, so the overlay is rebuilt only when they change
	var/aq_wound_overlay_key

/// Body zone -> bleeding from that zone (our scale). Bandaged bleeding does not count.
/mob/living/carbon/proc/get_bleeding_zones()
	var/list/zones = list()
	. = zones
	var/list/limb_bleeds = aq_get_limb_bleeds()
	for(var/zone in limb_bleeds)
		var/shown_zone = get_bodypart(zone) ? zone : BODY_ZONE_CHEST // a stump bleeds from the torso
		zones[shown_zone] += limb_bleeds[zone]

/mob/living/carbon/proc/get_open_eye_wound()
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		return null
	for(var/datum/wound/pierce/eye/eye_wound in head.wounds)
		if(!eye_wound.treated)
			return eye_wound
	return null

/// Overlay state for one zone bleeding at bleed_rate, null for none (tg update_part_wound_overlay())
/mob/living/carbon/proc/get_bleed_overlay_state(zone, bleed_rate)
	var/static_state = stat == DEAD || IS_IN_STASIS(src)
	var/lying_down = !(mobility_flags & MOBILITY_STAND)
	if(zone == BODY_ZONE_HEAD && bleed_rate > AQ_BLEED_OVERLAY_LOW && bleed_rate <= AQ_BLEED_OVERLAY_GUSH)
		var/datum/wound/pierce/eye/eye_wound = get_open_eye_wound()
		if(eye_wound)
			return eye_wound.side == "prawe" ? "r_eye" : "l_eye"
	switch(bleed_rate)
		if(-INFINITY to AQ_BLEED_OVERLAY_LOW)
			return null
		if(AQ_BLEED_OVERLAY_LOW to AQ_BLEED_OVERLAY_MED)
			return "[zone]_1"
		if(AQ_BLEED_OVERLAY_MED to AQ_BLEED_OVERLAY_GUSH)
			return (lying_down || static_state) ? "[zone]_2s" : "[zone]_2"
	return static_state ? "[zone]_2s" : "[zone]_3"

/// Handles bleeding overlays (tg)
/mob/living/carbon/proc/update_wound_overlays()
	var/list/states = list()
	if(ishuman(src) && !HAS_TRAIT(src, TRAIT_NO_BLOOD) && !QDELING(src))
		var/list/zones = get_bleeding_zones()
		for(var/zone in zones)
			var/state = get_bleed_overlay_state(zone, zones[zone])
			if(state)
				states += state
	var/key = jointext(states, ",")
	if(key == aq_wound_overlay_key)
		return
	aq_wound_overlay_key = key
	remove_overlay(WOUND_LAYER)
	if(!length(states))
		return
	var/mutable_appearance/wound_overlay = mutable_appearance('aquila/icons/mob/effects/bleed_overlays.dmi', null, -AQ_WOUND_DRAW_LAYER, appearance_flags = KEEP_TOGETHER)
	wound_overlay.color = get_blood_color()
	for(var/state in states)
		wound_overlay.add_overlay(state)
	overlays_standing[WOUND_LAYER] = wound_overlay
	apply_overlay(WOUND_LAYER)

/mob/living/carbon/human/regenerate_icons()
	. = ..()
	if(!.)
		aq_wound_overlay_key = null
		update_wound_overlays()

// The bleeding status refreshes its alert on every change and once a second, which also covers lying down, death and stasis

/datum/status_effect/bleeding/update_icon()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	if(istype(carbon_owner))
		carbon_owner.update_wound_overlays()

/datum/status_effect/bleeding/on_remove()
	var/mob/living/carbon/carbon_owner = owner
	. = ..()
	if(istype(carbon_owner))
		carbon_owner.update_wound_overlays()

/datum/status_effect/bleeding/on_creation(mob/living/new_owner, bleed_rate)
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	if(. && istype(carbon_owner))
		carbon_owner.update_wound_overlays()

#undef AQ_WOUND_DRAW_LAYER
#undef AQ_BLEED_OVERLAY_LOW
#undef AQ_BLEED_OVERLAY_MED
#undef AQ_BLEED_OVERLAY_GUSH
