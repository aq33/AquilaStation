/mob/living/proc/check_contact_sterility(body_part)
	return FALSE

/mob/living/carbon/human/check_contact_sterility(body_part)
	var/check_flags
	if(body_part == BODY_ZONE_EVERYTHING)
		check_flags = FULL_BODY
	else if(body_part == BODY_ZONE_LEGS)
		check_flags = LEGS | FEET
	else if(body_part == BODY_ZONE_ARMS)
		check_flags = ARMS | HANDS
	else
		check_flags = body_zone2cover_flags(body_part)

	for(var/obj/item/cloth as anything in get_equipped_items())
		if(QDELETED(cloth))
			continue
		if((cloth.body_parts_covered & check_flags) && prob(cloth.armor?["bio"]))
			return TRUE
	return FALSE

/mob/living/proc/check_bodypart_bleeding(zone)
	return FALSE

/mob/living/carbon/human/check_bodypart_bleeding(zone)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD) || blood_volume <= 0)
		return FALSE

	var/list/checks
	if(zone == BODY_ZONE_EVERYTHING)
		checks = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_R_ARM, BODY_ZONE_HEAD)
	else if(zone == BODY_ZONE_LEGS)
		checks = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	else if(zone == BODY_ZONE_ARMS)
		checks = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	else
		checks = islist(zone) ? zone : list(zone)

	// AQ: u nas krwawienie jest efektem statusowym calego moba (/datum/status_effect/bleeding),
	// a nie polem konczyny, wiec krwawiace sa wszystkie sprawdzane strefy.
	var/bleeding_flags = NONE
	if(is_bleeding())
		for(var/obj/item/bodypart/limb as anything in bodyparts)
			if(limb.body_zone in checks)
				bleeding_flags |= limb.body_part

	if(!bleeding_flags)
		return FALSE

	for(var/obj/item/cloth as anything in get_equipped_items())
		if(QDELETED(cloth))
			continue
		if(prob(cloth.armor?["bio"]))
			bleeding_flags &= ~cloth.body_parts_covered

	return !!bleeding_flags

/mob/living/proc/check_airborne_sterility()
	return FALSE

/mob/living/carbon/human/check_airborne_sterility()
	if (wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH) && prob(wear_mask.armor?["bio"]))
		return TRUE
	if (head && (head.flags_cover & HEADCOVERSMOUTH) && prob(head.armor?["bio"]))
		return TRUE
	return FALSE
