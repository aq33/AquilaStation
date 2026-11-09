/mob/living/carbon/human/attack_hand(mob/user)
	. = ..()

/// Ubrania zakrywające daną część ciała (Bee: get_clothing_on_part, potrzebne do ochrony przed promieniowaniem).
/// Te same sloty co checkarmor(), bez kieszeni.
/mob/living/carbon/human/proc/get_clothing_on_part(obj/item/bodypart/def_zone)
	var/list/covering_part = list()
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck)
	for(var/bp in body_parts)
		if(!isclothing(bp))
			continue
		var/obj/item/clothing/C = bp
		if(C.body_parts_covered & def_zone.body_part)
			covering_part += C
	return covering_part
