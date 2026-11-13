// Sprite'y z Civ13 (icons/effects/pooeffect.dmi, AGPL v3): grudki poop1-7 jako floor1-7, plamy floor1 i floor3 jako diarrhea1-2.
// Fioletowy kopczyk felinidów to przemalowany poop6.
/obj/effect/decal/cleanable/feces
	name = "odchody"
	desc = "Brązowe, śmierdzące i śliskie. Równie dobrze mogłoby to być danie kucharza."
	icon = 'aquila/icons/effects/feces.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_POOP
	bloodiness = BLOOD_AMOUNT_PER_DECAL

/obj/effect/decal/cleanable/feces/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddComponent(/datum/component/slippery, BLOOD_SLIPPERY_KNOCKDOWN, NO_SLIP_WHEN_WALKING)

/// Biegunka (typ 6-7 w skali bristolskiej, stoperan): rozbryzg zamiast grudek
/obj/effect/decal/cleanable/feces/proc/make_diarrhea()
	random_icon_states = list("diarrhea1", "diarrhea2")
	icon_state = pick(random_icon_states)

/// Kupa, która faktycznie leży na T: nowa zlewa się w Initialize z leżącą już kupą tego samego typu i znika
/obj/effect/decal/cleanable/feces/proc/surviving_decal(turf/T)
	if(!QDELETED(src))
		return src
	for(var/obj/effect/decal/cleanable/feces/existing in T)
		if(existing.type == type && !QDELETED(existing))
			return existing
	return null

/// Felinidzi robią fioletowe kopczyki
/obj/effect/decal/cleanable/feces/felinid
	icon_state = "felinid"
	random_icon_states = list("felinid")

/obj/effect/decal/cleanable/feces/felinid/make_diarrhea()
	return

/// Typ kupy, którą zostawia mob
/mob/living/proc/feces_type()
	return /obj/effect/decal/cleanable/feces

/mob/living/carbon/human/feces_type()
	if(iscatperson(src))
		return /obj/effect/decal/cleanable/feces/felinid
	return ..()
