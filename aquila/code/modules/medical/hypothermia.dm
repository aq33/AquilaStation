// AQUILA - hipotermia i odmrożenia (AquilaMed 5, etap 5). Pomysł: Baystation12 i /vg/ (handle_hypothermia), tg (odmrożenia
// jako rany w forkach), kod własny.
// Hipotermia (ciepłota ciała): poniżej 34°C dreszcze i wolniejsza regeneracja staminy, poniżej 30°C spowolnienie,
// niezdarne ręce i senność, poniżej 25°C chwile utraty przytomności, wolny puls i migotanie (medical/circulation.dm).
// Niżej (ok. -13°C ciepłoty) dalej działają obrażenia od zimna z core. Leczy ciepło: ciepłe pomieszczenie, koc
// (prześcieradło na szyi grzeje), gorące napoje, leporazyna, sleeper.
// Odmrożenia: ręka albo noga bez ochrony przed zimnem w otoczeniu poniżej -20°C (także w próżni bez skafandra):
// - I stopień: ból, słabszy chwyt, mija sam po ogrzaniu;
// - II stopień: pęcherze, zbiera zarazki, ogrzać i opatrzyć siatką;
// - III stopień: martwica, kończyna bezwładna, zbiera zarazki, ratuje operacja usunięcia martwej tkanki;
//   nieleczona przez 15 minut nadaje się już tylko do amputacji.

#define WOUND_FROSTBITE "frostbite"
/// Body temperature stages of hypothermia (34, 30 and 25°C)
#define AQ_HYPOTHERMIA_MILD (T0C + 34)
#define AQ_HYPOTHERMIA_MODERATE (T0C + 30)
#define AQ_HYPOTHERMIA_SEVERE (T0C + 25)
/// Air colder than this freezes exposed limbs (-20°C)
#define AQ_FROSTBITE_AIR (T0C - 20)
/// Frost a limb gathers per Life (2 s) in the frost, and the frost at which each degree of frostbite appears
#define AQ_FROST_RATE 1
#define AQ_FROST_FIRST 20
#define AQ_FROST_SECOND 50
#define AQ_FROST_THIRD 85
/// Third degree frostbite left untreated this long cannot be saved
#define AQ_FROSTBITE_NECROSIS_TIME (15 MINUTES)

/obj/item/bodypart
	/// Frost gathered on this limb, 0-100
	var/aq_frost = 0

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform || stat == DEAD || IsInStasis())
		return
	aq_handle_hypothermia()
	aq_handle_frostbite()

// --- Hipotermia ---

/mob/living/carbon/human/proc/aq_hypothermia_stage()
	if(HAS_TRAIT(src, TRAIT_RESISTCOLD))
		return 0
	if(bodytemperature < AQ_HYPOTHERMIA_SEVERE)
		return 3
	if(bodytemperature < AQ_HYPOTHERMIA_MODERATE)
		return 2
	if(bodytemperature < AQ_HYPOTHERMIA_MILD)
		return 1
	return 0

/mob/living/carbon/human/proc/aq_handle_hypothermia()
	// Koc: prześcieradło na szyi powoli ogrzewa
	if(istype(wear_neck, /obj/item/bedsheet) && bodytemperature < BODYTEMP_NORMAL)
		adjust_bodytemperature(min(2, BODYTEMP_NORMAL - bodytemperature))
	var/stage = aq_hypothermia_stage()
	if(stage >= 2)
		add_movespeed_modifier("aq_hypothermia", override = TRUE, multiplicative_slowdown = stage >= 3 ? 0.8 : 0.4)
	else
		remove_movespeed_modifier("aq_hypothermia")
	if(!stage)
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "aq_hypothermia")
		return
	SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "aq_hypothermia", /datum/mood_event/aq_hypothermia)
	Jitter(2 * stage)
	adjustStaminaLoss(stage)
	if(prob(4 * stage))
		to_chat(src, "<span class='warning'>[pick("Trzęsiesz się z zimna.", "Szczękasz zębami.", "Nie czujesz palców.", "Zimno przenika cię do szpiku kości.")]</span>")
	if(stage >= 2)
		drowsyness = max(drowsyness, 2 * stage)
		if(prob(3))
			var/obj/item/held = get_active_held_item()
			if(held && dropItemToGround(held))
				to_chat(src, "<span class='warning'>Zgrabiałe palce wypuszczają [held]!</span>")
	if(stage >= 3 && prob(8))
		Unconscious(3 SECONDS)
		to_chat(src, "<span class='danger'>Na chwilę odpływasz z zimna.</span>")

/datum/mood_event/aq_hypothermia
	description = "<span class='warning'>Tak strasznie zimno...</span>\n"
	mood_change = -4

/// Cold slows the pulse and a deeply chilled heart fibrillates (medical/circulation.dm)
/mob/living/carbon/human/aq_pulse_mod()
	. = ..()
	if(aq_hypothermia_stage() >= 3)
		.--

/mob/living/carbon/human/aq_update_pulse(obj/item/organ/heart/heart)
	. = ..()
	if(heart.beating && aq_hypothermia_stage() >= 3 && prob(10))
		heart.aq_pulse = 5 // migotanie z wychłodzenia

// --- Odmrożenia ---

/mob/living/carbon/human/proc/aq_handle_frostbite()
	var/turf/place = get_turf(src)
	var/datum/gas_mixture/air = place?.return_air()
	var/air_temp = air ? air.return_temperature() : T0C
	var/freezing = air_temp < AQ_FROSTBITE_AIR && !HAS_TRAIT(src, TRAIT_RESISTCOLD) && !istype(loc, /obj/machinery) && !istype(loc, /obj/structure/closet)
	var/protected = freezing ? get_cold_protection_flags(air_temp) : 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(limb) || limb.body_zone == BODY_ZONE_CHEST || limb.body_zone == BODY_ZONE_HEAD)
			continue
		if(freezing && !(protected & limb.body_part))
			limb.aq_frost = min(100, limb.aq_frost + AQ_FROST_RATE)
			aq_frostbite_from_frost(limb)
		else if(limb.aq_frost && bodytemperature >= AQ_HYPOTHERMIA_MILD)
			limb.aq_frost = max(0, limb.aq_frost - AQ_FROST_RATE)

/// Frostbite of the degree the frost on the limb has reached
/mob/living/carbon/human/proc/aq_frostbite_from_frost(obj/item/bodypart/limb)
	var/datum/wound/frostbite/current = limb.get_wound(WOUND_FROSTBITE)
	var/wanted
	if(limb.aq_frost >= AQ_FROST_THIRD)
		wanted = /datum/wound/frostbite/third_degree
	else if(limb.aq_frost >= AQ_FROST_SECOND)
		wanted = /datum/wound/frostbite/second_degree
	else if(limb.aq_frost >= AQ_FROST_FIRST)
		wanted = /datum/wound/frostbite/first_degree
	if(!wanted)
		return
	var/datum/wound/frostbite/wanted_type = wanted
	if(current && current.severity >= initial(wanted_type.severity))
		return
	if(current)
		current.replace_with(wanted)
	else
		var/datum/wound/frostbite/frostbite = new wanted()
		frostbite.apply_wound(limb)

/datum/wound/frostbite
	wound_type = WOUND_FROSTBITE
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	threshold = 0
	/// Per second chance to drop what the hand holds
	var/drop_chance = 0

/datum/wound/frostbite/wound_effects(delta_time)
	if(drop_chance && !treated && (limb.body_zone == BODY_ZONE_L_ARM || limb.body_zone == BODY_ZONE_R_ARM) && DT_PROB(drop_chance, delta_time))
		var/obj/item/held = victim.get_item_for_held_index(limb.held_index)
		if(held && victim.dropItemToGround(held))
			to_chat(victim, "<span class='danger'>Odmrożona ręka ([limb.name]) nie utrzymuje [held]!</span>")

/datum/wound/frostbite/first_degree
	name = "Odmrożenie pierwszego stopnia"
	desc = "Skóra blednieje i drętwieje od mrozu"
	examine_desc = "bladą, odmrożoną skórę"
	treat_text = "Ogrzej pacjenta, odmrożenie zejdzie samo."
	severity = WOUND_SEVERITY_MODERATE
	heal_time = 2 MINUTES
	drop_chance = 1
	limp_slowdown = 0.2

/// First degree heals by itself once the body is warm again
/datum/wound/frostbite/first_degree/wound_effects(delta_time)
	. = ..()
	if(!treated && victim.bodytemperature >= AQ_HYPOTHERMIA_MILD && limb.aq_frost < AQ_FROST_FIRST)
		treated = TRUE
		to_chat(victim, "<span class='notice'>Czucie wraca do kończyny ([limb.name]).</span>")

/datum/wound/frostbite/second_degree
	name = "Odmrożenie drugiego stopnia"
	desc = "Na zmarzniętej skórze wyskakują pęcherze"
	examine_desc = "odmrożoną skórę w pęcherzach"
	treat_text = "Ogrzej pacjenta i opatrz siatką. Zostawione zbiera zarazki."
	severity = WOUND_SEVERITY_SEVERE
	heal_time = 3 MINUTES
	drop_chance = 3
	limp_slowdown = 0.5
	treated_limp_slowdown = 0.2
	germ_rate = 0.04

/datum/wound/frostbite/second_degree/can_treat_with(obj/item/item)
	return !treated && istype(item, /obj/item/stack/medical/mesh)

/datum/wound/frostbite/second_degree/treat(obj/item/stack/medical/dressing, mob/user)
	if(victim.bodytemperature < AQ_HYPOTHERMIA_MILD || limb.aq_frost >= AQ_FROST_FIRST)
		to_chat(user, "<span class='warning'>Najpierw trzeba ogrzać [victim], inaczej opatrunek nic nie da.</span>")
		return FALSE
	var/self = user == victim
	if(!do_mob(user, victim, self ? 5 SECONDS : 2 SECONDS))
		return FALSE
	if(QDELETED(src) || treated || !dressing.use(1))
		return FALSE
	treated = TRUE
	victim.aq_medical_overlays_changed()
	user.visible_message("<span class='green'>[user] opatruje odmrożenie ([limb.name]) [victim].</span>", "<span class='green'>Opatrujesz odmrożenie ([limb.name]).</span>")
	return TRUE

/datum/wound/frostbite/third_degree
	name = "Odmrożenie trzeciego stopnia"
	desc = "Kończyna czernieje i przestaje cokolwiek czuć"
	examine_desc = "poczerniałą, martwą kończynę"
	treat_text = "Martwica: ogrzej pacjenta i usuń martwą tkankę operacją. Nieleczona po 15 minutach nadaje się tylko do amputacji."
	severity = WOUND_SEVERITY_CRITICAL
	drop_chance = 0
	limp_slowdown = 1.2
	germ_rate = 0.1
	/// When it can no longer be saved
	var/necrosis_at = 0
	/// Past saving: only amputation helps
	var/necrotic = FALSE
	/// Damage disable the limb would have without the paralysis, tracked while paralysed (is_disabled() hysteresis)
	var/disabled_before = BODYPART_NOT_DISABLED

/datum/wound/frostbite/third_degree/on_apply()
	. = ..()
	necrosis_at = world.time + AQ_FROSTBITE_NECROSIS_TIME
	disabled_before = limb.disabled == BODYPART_DISABLED_DAMAGE ? BODYPART_DISABLED_DAMAGE : BODYPART_NOT_DISABLED
	ADD_TRAIT(limb, TRAIT_PARALYSIS, WOUND_FROSTBITE)
	limb.update_disabled()

/datum/wound/frostbite/third_degree/Destroy()
	if(limb)
		REMOVE_TRAIT(limb, TRAIT_PARALYSIS, WOUND_FROSTBITE)
		// Bee keeps the old disabled state of a damaged limb, so the paralysis is cleared by hand (as in spinal.dm),
		// back to the damage disable the limb would have now without the paralysis.
		if(limb.disabled == BODYPART_DISABLED_PARALYSIS && !HAS_TRAIT(limb, TRAIT_PARALYSIS))
			aq_track_damage_disable()
			limb.set_disabled(disabled_before)
		limb.update_disabled()
	return ..()

/// Follows the damage disable of the limb as is_disabled() would without the paralysis: on at max damage
/// (or 60% with TRAIT_EASYLIMBDISABLE), off again only at half
/datum/wound/frostbite/third_degree/proc/aq_track_damage_disable()
	if(!limb?.owner || !limb.can_dismember() || HAS_TRAIT(limb.owner, TRAIT_NOLIMBDISABLE))
		disabled_before = BODYPART_NOT_DISABLED
		return
	var/damage = limb.get_damage(TRUE)
	if(damage >= limb.max_damage || (HAS_TRAIT(limb.owner, TRAIT_EASYLIMBDISABLE) && damage >= limb.max_damage * 0.6))
		disabled_before = BODYPART_DISABLED_DAMAGE
	else if(disabled_before == BODYPART_DISABLED_DAMAGE && damage <= limb.max_damage * 0.5)
		disabled_before = BODYPART_NOT_DISABLED

/datum/wound/frostbite/third_degree/wound_effects(delta_time)
	. = ..()
	aq_track_damage_disable()
	if(!necrotic && world.time >= necrosis_at)
		necrotic = TRUE
		treat_text = "Martwica jest nieodwracalna: tę kończynę trzeba amputować."
		to_chat(victim, "<span class='userdanger'>Kończyna ([limb.name]) jest martwa i już nic nie poczuje.</span>")

/datum/wound/frostbite/third_degree/get_scan_status()
	return necrotic ? " (martwica, tylko amputacja)" : ..()

// --- Operacja usunięcia martwej tkanki ratuje odmrożenie III stopnia (surgery_tg/operation_debride.dm) ---

/datum/surgery_operation/limb/debride/state_check(obj/item/bodypart/limb)
	var/datum/wound/frostbite/third_degree/frostbite = limb.get_wound(WOUND_FROSTBITE)
	if(istype(frostbite) && !frostbite.necrotic)
		return TRUE
	return ..()

/datum/surgery_operation/limb/debride/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/frostbite/third_degree/frostbite = limb.get_wound(WOUND_FROSTBITE)
	if(istype(frostbite) && !frostbite.necrotic && !limb.get_wound(WOUND_BURN))
		limb.aq_frost = min(limb.aq_frost, AQ_FROST_SECOND - 1)
		frostbite.replace_with(/datum/wound/frostbite/second_degree)
		limb.aq_add_germs(-30)
		limb.owner?.apply_damage(5, BRUTE, limb)
		display_results(
			surgeon,
			limb.owner,
			span_notice("Wycinasz martwą tkankę odmrożenia ([FORMAT_LIMB_OWNER(limb)])."),
			span_notice("[surgeon] wycina martwą tkankę odmrożenia ([FORMAT_LIMB_OWNER(limb)])!"),
			span_notice("[surgeon] kończy operację ([FORMAT_LIMB_OWNER(limb)])."),
		)
		return
	return ..()

#undef WOUND_FROSTBITE
#undef AQ_HYPOTHERMIA_MILD
#undef AQ_HYPOTHERMIA_MODERATE
#undef AQ_HYPOTHERMIA_SEVERE
#undef AQ_FROSTBITE_AIR
#undef AQ_FROST_RATE
#undef AQ_FROST_FIRST
#undef AQ_FROST_SECOND
#undef AQ_FROST_THIRD
#undef AQ_FROSTBITE_NECROSIS_TIME
