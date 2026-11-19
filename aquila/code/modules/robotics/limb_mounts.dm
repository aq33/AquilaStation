// AQUILA - szybkie odłączanie protez (Nova Sector modular_nova/modules/robot_limb_detach/code/robot_limb_detach_quirk.dm,
// Effigy local/code/datums/quirks/neutral_quirks/robot_limb_detach.dm). Cecha „Mocowania protez” (neutralna) daje akcję odpięcia
// sprawnej robotycznej ręki albo nogi (5 s, bez ran, co 30 s) i pozwala przypiąć robotyczną kończynę z powrotem bez operacji
// (przyłożenie do kikuta, 3 s). Głowy i klatki nie da się odpiąć. Pasuje do protezy-przedmiotu
// (item_as_prosthetic_limb) i do wymiany ręki na narzędziową albo oddania kończyny robotykowi do naprawy.

/datum/quirk/aq_limb_mounts
	name = "Mocowania protez"
	desc = "Masz szybkozłącza w stawach: sam odpinasz i przypinasz sprawne protezy rąk i nóg, bez operacji."
	value = 0
	mob_trait = TRAIT_AQ_LIMB_MOUNTS
	gain_text = "<span class='notice'>Czujniki zgłaszają gotowość protokołów odłączania kończyn.</span>"
	lose_text = "<span class='notice'>BŁĄD: protokoły odłączania kończyn wyłączone.</span>"
	medical_record_text = "Pacjent ma szybkozłącza na protezy kończyn."
	icon = "plug"
	var/datum/action/innate/aq_detach_limb/detach_action

/datum/quirk/aq_limb_mounts/add()
	detach_action = new
	detach_action.Grant(quirk_holder)

/datum/quirk/aq_limb_mounts/remove()
	QDEL_NULL(detach_action)

/datum/action/innate/aq_detach_limb
	name = "Odepnij protezę"
	desc = "Odpina jedną ze sprawnych robotycznych rąk albo nóg z szybkozłącza."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "autotomy"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED | AB_CHECK_STUN
	COOLDOWN_DECLARE(detach_cooldown)

/// Cecha usuwa akcję razem z właścicielem, a sygnał usunięcia może jeszcze dojść do usuniętej akcji
/datum/action/innate/aq_detach_limb/owner_deleted(datum/source)
	if(QDELETED(src))
		return
	return ..()

/datum/action/innate/aq_detach_limb/Activate()
	var/mob/living/carbon/human/user = owner
	if(!istype(user))
		return
	if(!COOLDOWN_FINISHED(src, detach_cooldown))
		to_chat(user, "<span class='warning'>Szybkozłącza jeszcze się nie odblokowały.</span>")
		return
	var/list/choices = list()
	for(var/obj/item/bodypart/limb as anything in user.aq_detachable_limbs())
		choices[strefa_pl(limb.body_zone)] = limb
	if(!length(choices))
		to_chat(user, "<span class='warning'>BŁĄD: brak sprawnych protez rąk i nóg do odłączenia.</span>")
		return
	var/picked = input(user, "Którą protezę odpiąć?", "Odłączanie protezy") as null|anything in choices
	var/obj/item/bodypart/limb = choices[picked]
	if(!limb || QDELETED(src) || limb.owner != user)
		return
	user.aq_detach_own_limb(limb)

/// Robotyczne ręce i nogi bez ran, które da się odpiąć
/mob/living/carbon/human/proc/aq_detachable_limbs()
	. = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!limb.aq_is_extremity() || IS_ORGANIC_LIMB(limb) || !(limb.bodytype & BODYTYPE_ROBOTIC) || limb.is_pseudopart)
			continue
		if(LAZYLEN(limb.wounds))
			continue
		. += limb

/mob/living/carbon/human/proc/aq_detach_own_limb(obj/item/bodypart/limb, delay = 5 SECONDS)
	if(LAZYLEN(limb.wounds))
		to_chat(src, "<span class='warning'>Nie da się odpiąć uszkodzonej protezy, najpierw ją napraw.</span>")
		return FALSE
	visible_message("<span class='notice'>[src] przekręca protezę ([strefa_pl(limb.body_zone)]), siłowniki syczą i zwalniają zaczep...</span>")
	playsound(src, 'sound/items/rped.ogg', 25, TRUE)
	if(delay && !do_after(src, delay, target = src))
		return FALSE
	if(limb.owner != src)
		return FALSE
	limb.drop_limb()
	// put_in_hands() wybiera rękę po stronie, nawet gdy właśnie odpięliśmy tę rękę, więc szukamy wolnej ręki sami
	for(var/hand_index in 1 to length(held_items))
		if(can_put_in_hand(limb, hand_index) && put_in_hand(limb, hand_index))
			break
	playsound(src, 'sound/items/deconstruct.ogg', 25, TRUE)
	visible_message("<span class='notice'>[src] odpina protezę ([strefa_pl(limb.body_zone)]).</span>")
	for(var/datum/action/innate/aq_detach_limb/action in actions)
		COOLDOWN_START(action, detach_cooldown, 30 SECONDS)
	return TRUE

/// Z cechą przypina się robotyczną kończynę bez operacji, przykładając ją do kikuta
/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C) && HAS_TRAIT(C, TRAIT_AQ_LIMB_MOUNTS) && !IS_ORGANIC_LIMB(src) && (bodytype & BODYTYPE_ROBOTIC) && aq_is_extremity() \
		&& !C.get_bodypart(body_zone) && isliving(user))
		var/mob/living/living_user = user
		if(!living_user.combat_mode)
			INVOKE_ASYNC(src, PROC_REF(aq_easy_attach_to), C, user)
			return
	return ..()
