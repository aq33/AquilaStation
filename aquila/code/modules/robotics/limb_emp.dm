// AQUILA - EMP rani i paraliżuje protezy (tg code/modules/surgery/bodyparts/_bodyparts.dm, emp_effect).
// Każda robotyczna kończyna dostaje 2 obrażenia fizyczne i 1,5 oparzenia (EMP silne: dwa razy tyle), sypie iskrami,
// a gdy ma co najmniej 30% obrażeń, na 3 s (silne: 6 s) przestaje działać jak sparaliżowana. Wcześniej każda proteza
// paraliżowała całe ciało na 10-20 s. Syntetyk (IPC) dostaje do tego krótkie porażenie całego ciała (2,5 s, silne 5 s),
// żeby broń jonowa została na nich groźna. Marka protezy tego nie zmienia (marka to sam wygląd).
// Hook: AQ EDIT w /mob/living/carbon/human/emp_act (code/modules/mob/living/carbon/human/human_defense.dm).

/// Zwraca TRUE, gdy obsłużyło protezy (stara pętla w core się wtedy nie wykonuje)
/mob/living/carbon/human/proc/aq_robotic_limbs_emp(severity)
	var/informed = FALSE
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!limb.aq_emp_effect(severity))
			continue
		if(!informed)
			to_chat(src, "<span class='userdanger'>Twoje protezy przeciążają się z ostrym bólem!</span>")
			informed = TRUE
		if(HAS_TRAIT(src, TRAIT_EASYDISMEMBER) && limb.body_zone != BODY_ZONE_CHEST && prob(20))
			limb.dismember(BRUTE)
	if(MOB_ROBOTIC in mob_biotypes)
		Paralyze(severity == EMP_HEAVY ? 5 SECONDS : 2.5 SECONDS)
	return TRUE

/// Efekt EMP na jednej kończynie. Zwraca TRUE, gdy kończyna jest robotyczna i oberwała.
/obj/item/bodypart/proc/aq_emp_effect(severity)
	if(IS_ORGANIC_LIMB(src) || !(bodytype & BODYTYPE_ROBOTIC))
		return FALSE
	var/paralyze_time = AQ_LIMB_EMP_PARALYZE_TIME
	var/brute = AQ_LIMB_EMP_BRUTE
	var/burn = AQ_LIMB_EMP_BURN
	if(severity == EMP_HEAVY)
		paralyze_time *= 2
		brute *= 2
		burn *= 2
	// EMP przechodzi przez obudowę: bez stałej redukcji obrażeń protez (brute_reduction, burn_reduction)
	var/old_brute_reduction = brute_reduction
	var/old_burn_reduction = burn_reduction
	brute_reduction = 0
	burn_reduction = 0
	receive_damage(brute, burn)
	brute_reduction = old_brute_reduction
	burn_reduction = old_burn_reduction
	do_sparks(1, FALSE, owner || src)
	if(owner && aq_is_extremity() && paralyze_time > 0 && get_damage() / max_damage >= AQ_LIMB_EMP_PARALYZE_PERCENT)
		ADD_TRAIT(src, TRAIT_PARALYSIS, AQ_LIMB_EMP_TRAIT)
		update_disabled()
		addtimer(CALLBACK(src, PROC_REF(aq_emp_recover)), paralyze_time, TIMER_UNIQUE | TIMER_OVERRIDE)
		owner.visible_message("<span class='danger'>Proteza [owner] ([strefa_pl(body_zone)]) zacina się i przestaje działać!</span>", \
			"<span class='userdanger'>Awaria protezy ([strefa_pl(body_zone)])!</span>")
	return TRUE

/// Ręka albo noga (tylko one dają się sparaliżować)
/obj/item/bodypart/proc/aq_is_extremity()
	return body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/obj/item/bodypart/proc/aq_emp_recover()
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, AQ_LIMB_EMP_TRAIT)
	if(owner)
		update_disabled()
