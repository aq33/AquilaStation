// AQUILA - Ciecze, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_status_effect.dm), bez oceanu.

/// AQUILA - czy ciecz nie dotyka (trait z Monke albo szczelny strój: skafander, hardsuit, kombinezon bio z hełmem)
/atom/proc/is_liquid_protected()
	return HAS_TRAIT(src, LIQUID_PROTECTION)

/mob/living/carbon/human/is_liquid_protected()
	if(..())
		return TRUE
	var/obj/item/clothing/suit = wear_suit
	var/obj/item/clothing/helmet = head
	if(!istype(suit) || !istype(helmet))
		return FALSE
	var/sealed_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	return (suit.clothing_flags & sealed_flags) && (helmet.clothing_flags & sealed_flags)

/datum/status_effect/water_affected
	id = "wateraffected"
	alert_type = null
	duration = -1

/datum/status_effect/water_affected/on_apply()
	//We should be inside a liquid turf if this is applied
	return calculate_water_slow()

/datum/status_effect/water_affected/proc/calculate_water_slow()
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf || QDELETED(owner_turf.liquids) || QDELETED(owner_turf.liquids.liquid_group) || owner_turf.liquids.liquid_group.group_overlay_state == LIQUID_STATE_PUDDLE || owner_turf.liquids.liquid_group.frozen)
		return FALSE
	var/slowdown_amount = owner_turf.liquids.liquid_group.group_overlay_state * 0.5
	owner.add_movespeed_modifier(MOVESPEED_ID_LIQUIDS, override = TRUE, multiplicative_slowdown = slowdown_amount, blacklisted_movetypes = (FLOATING | FLYING))
	return TRUE

/datum/status_effect/water_affected/tick()
	var/turf/owner_turf = get_turf(owner)
	if(!calculate_water_slow())
		qdel(src)
		return
	//Make the reagents touch the person
	var/fraction = SUBMERGEMENT_PERCENT(owner, owner_turf.liquids)
	var/datum/liquid_group/group = owner_turf.liquids.liquid_group
	if(owner.is_liquid_protected())
		return
	group.expose_atom(owner, fraction, TOUCH)
	group.transfer_to_atom(owner_turf.liquids, (SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT * fraction / 20), owner, TOUCH)

/datum/status_effect/water_affected/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_LIQUIDS)
