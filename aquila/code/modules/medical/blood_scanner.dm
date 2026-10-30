// AQUILA - hemoanalytic scanner from tgstation (code/game/objects/items/devices/blood_scanner.dm).
// Pricks the patient with a needle: blood type and warnings about oxygen, blood volume and toxins.
// The secondary click scans the blood for chemicals. Moving away during the scan can tear a small hole.
// Sprite from tgstation (CC-BY-SA 3.0).

/obj/item/blood_scanner
	name = "skaner hemoanalityczny"
	desc = "Urządzenie medyczne marki Me-Lo Tech, które wykrywa nieprawidłowości w przepływie i składzie krwi. Przycisk z boku bada krew pod kątem leków."
	icon = 'aquila/icons/obj/medical/medical_tg.dmi'
	icon_state = "bloodscanner"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron = 200, /datum/material/glass = 50)

/obj/item/blood_scanner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kliknij pacjenta, żeby zbadać krew, albo [user.secondary_click_text()], żeby sprawdzić leki we krwi.</span>"

/obj/item/blood_scanner/attack(mob/living/M, mob/living/user)
	if(!usable_check(user, M))
		return
	INVOKE_ASYNC(src, PROC_REF(prick), user, M, FALSE)

/obj/item/blood_scanner/attack_secondary(mob/living/victim, mob/living/user, params)
	if(usable_check(user, victim))
		INVOKE_ASYNC(src, PROC_REF(prick), user, victim, TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/blood_scanner/proc/prick(mob/living/user, mob/living/carbon/patient, chemicals)
	if(patient in user.do_afters)
		return
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		return
	user.visible_message("<span class='notice'>[user] nakłuwa [patient] igłą [src].</span>", "<span class='notice'>Zaczynasz badać [patient] za pomocą [src].</span>", ignored_mobs = patient)
	to_chat(patient, "<span class='notice'>[user] wbija ci igłę [src] w [limb.name] i zaczyna wciskać przyciski.</span>")
	if(!do_mob(user, patient, 2 SECONDS))
		if(prob(25))
			regret(user, patient, limb)
		return
	add_fingerprint(user)
	if(chemicals)
		chemscan(user, patient)
	else
		scan_blood(user, patient)

/obj/item/blood_scanner/proc/scan_blood(mob/living/user, mob/living/carbon/patient)
	var/list/render = list("<span class='info'>Odczytujesz ekran [src]:</span>")
	render += "<span class='notice'>Grupa krwi: [patient.dna?.blood_type || "nieznana"]</span>"
	if(patient.getOxyLoss() > 50)
		render += "<span class='danger'>Uwaga: niedotlenienie krwi.</span>"
	if(!HAS_TRAIT(patient, TRAIT_NO_BLOOD) && patient.blood_volume <= BLOOD_VOLUME_SAFE)
		render += "<span class='danger'>Uwaga: niebezpiecznie mało krwi.</span>"
	if(patient.getToxLoss() > 10)
		render += "<span class='danger'>Uwaga: we krwi zbierają się toksyny.</span>"
	to_chat(user, jointext(render, "\n"))

/// The needle is torn out: a scratch that bleeds a little (tg gives a needle puncture wound)
/obj/item/blood_scanner/proc/regret(mob/living/user, mob/living/carbon/patient, obj/item/bodypart/limb)
	if(QDELETED(limb) || limb.owner != patient)
		return
	limb.receive_damage(3)
	patient.add_bleeding(BLEED_SCRATCH)
	user.visible_message("<span class='warning'>Igła [src] się wyrywa i rozdziera [limb.name] [patient]!</span>", "<span class='warning'>Cholera! Igła się wyrywa i robi małą dziurę w [limb.name] [patient].</span>", ignored_mobs = patient)
	to_chat(patient, "<span class='userdanger'><b>AŁA!</b> Igła [src] się wyrywa i robi ci małą dziurę w [limb.name]!</span>")

/obj/item/blood_scanner/proc/usable_check(mob/living/user, atom/target)
	if(!isliving(target))
		return FALSE
	if(!iscarbon(target))
		to_chat(user, "<span class='warning'>[src] nie pasuje do tej istoty.</span>")
		return FALSE
	if(user.incapacitated() || user.eye_blind)
		to_chat(user, "<span class='warning'>Nie możesz odczytać ekranu [src]!</span>")
		return FALSE
	return TRUE
