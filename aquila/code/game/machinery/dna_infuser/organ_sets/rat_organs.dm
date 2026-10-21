// AQUILA - port z tgstation (code/game/machinery/dna_infuser/organ_sets/rat_organs.dm)

/// bonus szczura: przeciskanie się przez wentylację (bez ubrań)
/datum/status_effect/organ_set_bonus/rat
	id = "organ_set_bonus_rat"
	organs_needed = 4
	bonus_activate_text = "<span class='notice'>Gryzoni DNA przeniknęło cię do głębi! Nauczyłeś się przeciskać przez wentylację!</span>"
	bonus_deactivate_text = "<span class='notice'>Twoje DNA nie jest już w większości szczurze, a wraz z nim znika umiejętność łażenia po rurach...</span>"
	/// poprzednia wartość ventcrawler, przywracana po utracie bonusu
	var/old_ventcrawler

/datum/status_effect/organ_set_bonus/rat/enable_bonus(obj/item/organ/inserted_organ)
	. = ..()
	if(!.)
		return
	old_ventcrawler = owner.ventcrawler
	if(owner.ventcrawler < VENTCRAWLER_NUDE)
		owner.ventcrawler = VENTCRAWLER_NUDE

/datum/status_effect/organ_set_bonus/rat/disable_bonus(obj/item/organ/removed_organ)
	. = ..()
	if(QDELETED(owner))
		return
	if(owner.ventcrawler == VENTCRAWLER_NUDE)
		owner.ventcrawler = old_ventcrawler

/// lepsze widzenie w ciemności, ale nadwrażliwość na błyski
/obj/item/organ/eyes/night_vision/rat
	name = "zmutowane szczurze oczy"
	desc = "Szczurze DNA wszczepione w coś, co kiedyś było parą zwykłych oczu."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "rat_eyes"
	flash_protect = -1
	eye_color = "000"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/organ/eyes/night_vision/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Ma głębokie, rozbiegane czarne źrenice otoczone obrzydliwie żółtą twardówką.", BODY_ZONE_PRECISE_EYES)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)

/// większy głód, szybciej mija obrzydzenie
/obj/item/organ/stomach/rat
	name = "zmutowany szczurzy żołądek"
	desc = "Szczurze DNA wszczepione w coś, co kiedyś było zwykłym żołądkiem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "rat_stomach"
	disgust_metabolism = 3
	/// mnożnik głodu
	var/hunger_modifier = 10

/obj/item/organ/stomach/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)
	AddElement(/datum/element/noticable_organ, "Ślini się bez opamiętania.", BODY_ZONE_PRECISE_MOUTH)

/obj/item/organ/stomach/rat/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M && ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.hunger_mod *= hunger_modifier

/obj/item/organ/stomach/rat/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(M) && owner == M)
		var/mob/living/carbon/human/human_owner = M
		if(human_owner.physiology) // przy qdel postaci physiology znika przed organami
			human_owner.physiology.hunger_mod /= hunger_modifier
	return ..()

/// mniejszy, przechodzi po stołach, ale dostaje 1,5x obrażeń
/obj/item/organ/heart/rat
	name = "zmutowane szczurze serce"
	desc = "Szczurze DNA wszczepione w coś, co kiedyś było zwykłym sercem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "rat_heart"

/obj/item/organ/heart/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)
	AddElement(/datum/element/noticable_organ, "Nienaturalnie się garbi!")

/obj/item/organ/heart/rat/update_icon()
	icon_state = "rat_heart"

/obj/item/organ/heart/rat/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	M.resize = 0.8
	M.update_transform()
	passtable_on(M, REF(src))
	if(ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.damage_resistance -= 50

/obj/item/organ/heart/rat/Remove(mob/living/carbon/M, special = 0)
	if(M && owner == M)
		M.resize = 1.25
		M.update_transform()
		passtable_off(M, REF(src))
		if(ishuman(M))
			var/mob/living/carbon/human/human_owner = M
			if(human_owner.physiology) // przy qdel postaci physiology znika przed organami
				human_owner.physiology.damage_resistance += 50
	return ..()

/// piszczy i rzuca serowymi tekstami
/obj/item/organ/tongue/rat
	name = "zmutowany szczurzy język"
	desc = "Szczurze DNA wszczepione w coś, co kiedyś było zwykłym językiem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "rat_tongue"
	say_mod = "piszczy"
	modifies_speech = TRUE
	liked_food = DAIRY // mmm, ser
	disliked_food = NONE // szczur zje wszystko
	toxic_food = NONE

/obj/item/organ/tongue/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Ma dziwnie ukształtowane, pożółkłe zęby.", BODY_ZONE_PRECISE_MOUTH)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)

/obj/item/organ/tongue/rat/handle_speech(datum/source, list/speech_args)
	if(!prob(1) && !(SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		return
	var/message = lowertext(speech_args[SPEECH_MESSAGE])
	if(message == "cześć" || message == "cześć." || message == "hej" || message == "hej.")
		speech_args[SPEECH_MESSAGE] = "Ser-decznie witam!"
		for(var/mob/living/hearer in view(3, owner))
			if(hearer != owner)
				hearer.add_mood_event("infuser_cheesed", /datum/mood_event/infuser_cheesed)
	else if(message == "cześć?" || message == "hej?")
		speech_args[SPEECH_MESSAGE] = "Em... ser-decznie witam?"

/obj/item/organ/tongue/rat/on_life()
	. = ..()
	if(owner && owner.stat == CONSCIOUS && prob(5))
		owner.visible_message("<span class='notice'>[owner] piszczy.</span>")
		playsound(owner, 'sound/effects/mousesqueek.ogg', 100)
