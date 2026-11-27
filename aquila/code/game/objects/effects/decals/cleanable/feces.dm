// Sprite'y z Civ13 (icons/effects/pooeffect.dmi, AGPL v3): grudki poop1-7 jako floor1-7, plamy floor1 i floor3 jako diarrhea1-2.
// Fioletowy kopczyk felinidów to przemalowany poop6.
/obj/effect/decal/cleanable/feces
	name = "odchody"
	desc = "Brązowe, śmierdzące i śliskie. Równie dobrze mogłoby to być danie kucharza."
	icon = 'aquila/icons/effects/feces.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_POOP
	/// Z BLOOD_AMOUNT_PER_DECAL (20) buty dostawały tyle, ile wynosi próg śladu (BLOOD_LOSS_IN_SPREAD), więc kupa nigdy nie zostawiała śladów.
	/// 60: wdepnięcie daje butom BLOOD_GAIN_PER_STEP (40), czyli kilka brązowych śladów.
	bloodiness = 60
	/// Grudka rozdeptana w plamę albo od razu biegunka: dalsze wdepnięcia już jej nie zmieniają
	var/squashed = FALSE

// Zwykła kupa nie jest śliska: wdepnięcie (także w biegu) brudzi buty i zostawia ślady. Ślizga się tylko biegunka.

/// Biegunka (typ 6-7 w skali bristolskiej, stoperan): rozbryzg zamiast grudek, śliski przy bieganiu
/obj/effect/decal/cleanable/feces/proc/make_diarrhea()
	random_icon_states = list("diarrhea1", "diarrhea2")
	icon_state = pick(random_icon_states)
	squashed = TRUE
	AddComponent(/datum/component/slippery, BLOOD_SLIPPERY_KNOCKDOWN, NO_SLIP_WHEN_WALKING)

/// Wdepnięcie w grudkę rozgniata ją w plamę (nie śliską jak biegunka). Ślady butów robi już on_entered z cleanable.
/obj/effect/decal/cleanable/feces/on_entered(datum/source, atom/movable/O)
	. = ..()
	if(!squashed && can_squash(O))
		squash(O)

/obj/effect/decal/cleanable/feces/proc/can_squash(atom/movable/O)
	if(!isliving(O))
		return FALSE
	var/mob/living/walker = O
	if((walker.movement_type & (FLYING|FLOATING)) || HAS_TRAIT(walker, TRAIT_LIGHT_STEP) || walker.mob_size < MOB_SIZE_HUMAN)
		return FALSE
	return TRUE

/obj/effect/decal/cleanable/feces/proc/squash(mob/living/walker)
	squashed = TRUE
	name = "rozdeptane odchody"
	desc = "Ktoś w to wdepnął i rozsmarował po podłodze. Ślady prowadzą dalej."
	random_icon_states = list("diarrhea1", "diarrhea2")
	icon_state = pick(random_icon_states)
	if(walker && !walker.censors_bodily_functions())
		to_chat(walker, "<span class='warning'>Wdeptujesz w kupę i rozgniatasz ją na podłodze.</span>")

/// Fioletowy kopczyk felinida nie ma sprite'u plamy, więc zostaje kopczykiem (ślady i tak zostawia)
/obj/effect/decal/cleanable/feces/felinid/squash(mob/living/walker)
	squashed = TRUE

/// Kupa, która faktycznie leży na T: nowa zlewa się w Initialize z leżącą już kupą tego samego typu i znika
/obj/effect/decal/cleanable/feces/proc/surviving_decal(turf/T)
	RETURN_TYPE(/obj/effect/decal/cleanable/feces)
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
