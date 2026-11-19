// AQUILA - kalibracja świeżo przyszytej protezy (CM-SS13 code/modules/surgery/robolimb_repair.dm, „Calibrate prosthesis”).
// Ręka albo noga robotyczna przyczepiona operacją nie słucha poleceń (TRAIT_PARALYSIS ze źródła AQ_UNCALIBRATED_TRAIT),
// dopóki lekarz albo robotyk nie skalibruje jej multitoolem albo hemostatem: 2,5 s, bez kładzenia pacjenta i bez trybu walki,
// celując w kończynę (robotic_wounds.dm, aq_robotics_tool_act). Bez kalibracji: syntetyki z TRAIT_LIMBATTACHMENT (same
// przypinają kończyny), przyczepianie specjalne (lobby, zmiana gatunku) i kończyny bez elektroniki (kołki, protezy kinetyczne).

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(special || QDELETED(C) || owner != C)
		return
	if(!aq_is_extremity() || IS_ORGANIC_LIMB(src) || !(bodytype & BODYTYPE_ROBOTIC) || is_pseudopart)
		return
	if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT) || HAS_TRAIT(C, TRAIT_AQ_LIMB_MOUNTS))
		return
	ADD_TRAIT(src, TRAIT_PARALYSIS, AQ_UNCALIBRATED_TRAIT)
	update_disabled()
	to_chat(C, "<span class='warning'>Nowa proteza ([strefa_pl(body_zone)]) nie słucha poleceń. Trzeba ją skalibrować multitoolem albo hemostatem.</span>")

/obj/item/bodypart/drop_limb(special)
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, AQ_UNCALIBRATED_TRAIT)
	return ..()

/obj/item/bodypart/proc/aq_needs_calibration()
	return HAS_TRAIT_FROM(src, TRAIT_PARALYSIS, AQ_UNCALIBRATED_TRAIT)

/obj/item/bodypart/proc/aq_calibrate(mob/living/user, obj/item/tool, delay = 2.5 SECONDS)
	var/mob/living/carbon/patient = owner
	if(!patient || !aq_needs_calibration())
		return FALSE
	user.visible_message("<span class='notice'>[user] zaczyna kalibrować protezę [patient] ([strefa_pl(body_zone)]).</span>", \
		"<span class='notice'>Zaczynasz kalibrować protezę [user == patient ? "" : "[patient] "]([strefa_pl(body_zone)]).</span>")
	playsound(patient, 'sound/surgery/tape_flip.ogg', 30, TRUE)
	if(delay && !do_mob(user, patient, delay))
		return FALSE
	if(owner != patient || !aq_needs_calibration())
		return FALSE
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, AQ_UNCALIBRATED_TRAIT)
	update_disabled()
	playsound(patient, 'sound/machines/ping.ogg', 30, TRUE)
	user.visible_message("<span class='green'>[user] kalibruje protezę [patient] ([strefa_pl(body_zone)]).</span>", "<span class='green'>Proteza jest skalibrowana.</span>")
	to_chat(patient, "<span class='green'>Proteza ([strefa_pl(body_zone)]) zaczyna słuchać poleceń.</span>")
	return TRUE

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(aq_needs_calibration())
		. += "<span class='warning'>Proteza nie jest skalibrowana.</span>"
