// AQUILA - narzędzia medyczne AquilaMed 5: nożyce do amputacji, nanopasta.
// Nożyce: tgstation (code/modules/surgery/surgery_tools.dm), nanopasta: Baystation12
// (code/game/objects/items/stacks/nanopaste.dm). Sprite'y z tych repozytoriów (CC-BY-SA 3.0).
// Różnice: nożyce działają tylko na leżącym, skutym albo nieprzytomnym pacjencie i tylko na rękach i nogach.

/// Time to snip a healthy limb and a destroyed one
#define AQ_SHEARS_TIME_HEALTHY (15 SECONDS)
#define AQ_SHEARS_TIME_DESTROYED (5 SECONDS)

/obj/item/shears
	name = "nożyce do amputacji"
	desc = "Ciężkie nożyce chirurgiczne do czystego odcięcia ręki albo nogi. Pacjent musi leżeć, być skuty albo nieprzytomny. Zniszczoną kończynę odcinają dużo szybciej niż zdrową."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "shears"
	flags_1 = CONDUCT_1
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 6
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron = 8000, /datum/material/titanium = 6000)
	attack_verb = list("tnie", "ciacha")
	sharpness = IS_SHARP
	toolspeed = 1

/obj/item/shears/attack(mob/living/M, mob/living/user)
	if(!iscarbon(M) || user.combat_mode)
		return ..()
	var/mob/living/carbon/patient = M
	var/zone = check_zone(user.zone_selected)
	if(zone != BODY_ZONE_L_ARM && zone != BODY_ZONE_R_ARM && zone != BODY_ZONE_L_LEG && zone != BODY_ZONE_R_LEG)
		return ..()
	var/obj/item/bodypart/limb = patient.get_bodypart(zone)
	if(!limb)
		to_chat(user, "<span class='warning'>[patient] nie ma już tej kończyny.</span>")
		return
	if(HAS_TRAIT(patient, TRAIT_NODISMEMBER))
		to_chat(user, "<span class='warning'>Kończyny [patient] są za twarde, nożyce ich nie przetną.</span>")
		return
	if(!aq_can_hold_still(patient))
		to_chat(user, "<span class='warning'>[patient] się rusza. Pacjent musi leżeć, być skuty albo nieprzytomny, żeby założyć nożyce.</span>")
		return
	if(patient in user.do_afters)
		return
	var/time = aq_limb_destroyed(limb) ? AQ_SHEARS_TIME_DESTROYED : AQ_SHEARS_TIME_HEALTHY
	if(patient.stat != CONSCIOUS || HAS_TRAIT(patient, TRAIT_INCAPACITATED))
		time *= 0.5
	if(patient.stat != DEAD && patient.jitteriness)
		time *= 1.5
	patient.visible_message("<span class='danger'>[user] zakłada [src] na [limb.name] [patient].</span>", "<span class='userdanger'>[user] zakłada [src] na twoją kończynę: [limb.name]!</span>")
	playsound(get_turf(patient), 'sound/items/ratchet.ogg', 20, TRUE)
	if(!do_mob(user, patient, time * toolspeed))
		return
	if(QDELETED(limb) || limb.owner != patient || !aq_can_hold_still(patient))
		return
	playsound(get_turf(patient), 'sound/weapons/bladeslice.ogg', 70, TRUE)
	limb.dismember()
	user.visible_message("<span class='danger'>[src] zatrzaskują się z hukiem i odcinają kończynę [patient]: [limb.name].</span>", "<span class='notice'>Odcinasz [patient] kończynę: [limb.name].</span>")
	log_combat(user, patient, "amputował(a) [limb.name] nożycami", src)

/// Lying, cuffed, buckled or out cold: the shears can be lined up
/obj/item/shears/proc/aq_can_hold_still(mob/living/carbon/patient)
	return patient.stat != CONSCIOUS || !(patient.mobility_flags & MOBILITY_STAND) || patient.handcuffed || patient.buckled

/// A limb that is all but gone: disabled by damage, almost at its max damage or with a critical wound
/obj/item/shears/proc/aq_limb_destroyed(obj/item/bodypart/limb)
	if(limb.disabled == BODYPART_DISABLED_DAMAGE || limb.get_damage() >= limb.max_damage * 0.75)
		return TRUE
	for(var/datum/wound/wound as anything in limb.wounds)
		if(wound.severity >= WOUND_SEVERITY_CRITICAL)
			return TRUE
	return FALSE

// --- Nanopasta ---

/obj/item/stack/medical/nanopaste
	name = "nanopasta"
	singular_name = "porcja nanopasty"
	desc = "Tubka pasty z rojem nanitów naprawczych. Naprawia uszkodzenia protez, ciał IPC i cyborgów, a na żywą tkankę nie działa."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "nanopaste"
	amount = 10
	max_amount = 10
	novariants = TRUE
	self_delay = 3 SECONDS
	heal_brute = 15
	heal_burn = 15
	resistance_flags = NONE

/obj/item/stack/medical/nanopaste/one
	amount = 1

/obj/item/stack/medical/nanopaste/attack(mob/living/M, mob/user)
	if(iscyborg(M))
		if(!M.getBruteLoss() && !M.getFireLoss())
			to_chat(user, "<span class='notice'>Wszystkie układy [M] działają prawidłowo.</span>")
			return
		M.adjustBruteLoss(-heal_brute)
		M.adjustFireLoss(-heal_burn)
		use(1)
		user.visible_message("<span class='notice'>[user] smaruje nanopastą uszkodzenia [M].</span>", "<span class='notice'>Smarujesz nanopastą uszkodzenia [M].</span>")
		return
	if(!iscarbon(M))
		to_chat(user, "<span class='warning'>Nanopasta tu nic nie naprawi.</span>")
		return
	var/mob/living/carbon/patient = M
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		to_chat(user, "<span class='warning'>[patient] nie ma tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return
	if(IS_ORGANIC_LIMB(limb))
		to_chat(user, "<span class='warning'>Nanopasta działa tylko na protezy i ciała syntetyków.</span>")
		return
	if(!limb.brute_dam && !limb.burn_dam)
		to_chat(user, "<span class='notice'>[capitalize(limb.name)] nie ma czego naprawiać.</span>")
		return
	if(patient in user.do_afters)
		return
	if(patient == user && !do_mob(user, patient, self_delay))
		return
	if(QDELETED(limb) || limb.owner != patient || !use(1))
		return
	if(limb.heal_damage(heal_brute, heal_burn, 0, BODYTYPE_ROBOTIC))
		patient.update_damage_overlays() // dents and scorch marks go from the sprite, as with a welder or cable
	patient.updatehealth()
	user.visible_message("<span class='notice'>[user] smaruje nanopastą [limb.name] [patient].</span>", "<span class='notice'>Smarujesz nanopastą [limb.name] [patient == user ? "" : "[patient]"].</span>")

#undef AQ_SHEARS_TIME_HEALTHY
#undef AQ_SHEARS_TIME_DESTROYED
