// AQUILA - puls, zatrzymanie krążenia i niedotlenienie mózgu (AquilaMed 5, etap 4), na wzór Baystation12
// (code/modules/organs/internal/heart.dm: handle_pulse, brain.dm: niedotlenienie, human_attackhand.dm: RKO), kod własny.
// - Serce ma puls: brak, wolny, prawidłowy, szybki, bardzo szybki, migotanie. Przyspieszają go stymulanty, energetyki
//   i kawa, ból i mała ilość krwi, zwalniają opioidy. Bardzo szybki puls po trochu uszkadza serce.
// - Serce staje przy krwi poniżej progu przeżycia, ciężkim uszkodzeniu mózgu, migotaniu, nadmiarze stymulantów,
//   po defibrylacji zdrowego serca i od silnego porażenia prądem. Samo nie rusza: RKO czasem, defibrylator na pewno.
// - Krążenie: bijące serce pompuje krew zależnie od pulsu, zatrzymane 25%, a RKO na 20 s daje 50%.
// - Mózg bez krążenia traci tlen jak w Bay, ale dwa razy wolniej: traumy po ok. 6-8 minutach, śmierć mózgu po ok. 16.
//   Samo zatrzymanie serca nie zadaje już obrażeń ciału (hak w code/modules/mob/living/carbon/human/life.dm).
// - Mózg poza ciałem (bez MMI, lodu, stazy i pojemnika na narządy) obumiera w kilka minut.

#define AQ_PULSE_NONE 0
#define AQ_PULSE_SLOW 1
#define AQ_PULSE_NORM 2
#define AQ_PULSE_FAST 3
#define AQ_PULSE_2FAST 4
#define AQ_PULSE_THREADY 5
/// Brain damage per Life (2 s) without any circulation: ~16 minutes to brain death (200)
#define AQ_HYPOXIA_BRAIN_DAMAGE 0.42
/// How long one round of chest compressions keeps the blood moving
#define AQ_CPR_DURATION (20 SECONDS)

/// Reagent => how much it speeds up (or slows down) the pulse per 10 units, up to twice that
GLOBAL_LIST_INIT(aq_pulse_reagents, list(
	/datum/reagent/medicine/epinephrine = 1,
	/datum/reagent/medicine/ephedrine = 1,
	/datum/reagent/medicine/methylphenidate = 1,
	/datum/reagent/drug/methamphetamine = 2,
	/datum/reagent/drug/crank = 2,
	/datum/reagent/drug/bath_salts = 2,
	/datum/reagent/drug/nicotine = 0.5,
	/datum/reagent/consumable/coffee = 0.5,
	/datum/reagent/consumable/navy_coffee = 1,
	/datum/reagent/consumable/grey_bull = 1,
	/datum/reagent/consumable/monkey_energy = 1,
	/datum/reagent/consumable/spacemountainwind = 0.5,
	/datum/reagent/medicine/morphine = -1,
	/datum/reagent/medicine/oxycodone = -1,
	/datum/reagent/medicine/tramadol = -0.5,
	/datum/reagent/drug/krokodil = -1,
))

/obj/item/organ/heart
	/// Pulse from the last Life, AQ_PULSE_*
	var/aq_pulse = AQ_PULSE_NORM

/obj/item/organ/heart/Stop()
	. = ..()
	aq_pulse = AQ_PULSE_NONE

/obj/item/organ/heart/Restart()
	. = ..()
	aq_pulse = AQ_PULSE_NORM

/// What the stethoscope and the analyzer say about the pulse
/obj/item/organ/heart/proc/aq_pulse_text()
	if(!beating)
		return "<span class='danger'>brak</span>"
	switch(aq_pulse)
		if(AQ_PULSE_SLOW)
			return "wolny (ok. 50/min)"
		if(AQ_PULSE_FAST)
			return "szybki (ok. 110/min)"
		if(AQ_PULSE_2FAST)
			return "<span class='warning'>bardzo szybki (ok. 150/min)</span>"
		if(AQ_PULSE_THREADY)
			return "<span class='danger'>nitkowaty, nieregularny (migotanie)</span>"
	return "prawidłowy (ok. 75/min)"

/mob/living/carbon/human
	/// Chest compressions keep the blood moving until this time
	var/aq_cpr_until = 0

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform || stat == DEAD || IsInStasis())
		return
	aq_handle_circulation()

/mob/living/carbon/human/proc/aq_handle_circulation()
	if(!needs_heart())
		return
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(heart && !(heart.organ_flags & ORGAN_SYNTHETIC))
		aq_update_pulse(heart)
	aq_handle_brain_oxygen()

/// How much the pulse is pushed up (stimulants, pain, too little blood) or down (opioids)
/mob/living/carbon/human/proc/aq_pulse_mod()
	. = 0
	for(var/datum/reagent/reagent as anything in reagents?.reagent_list)
		var/strength = GLOB.aq_pulse_reagents[reagent.type]
		if(strength)
			. += strength * min(reagent.volume / 10, 2)
	if(aq_pain > 30)
		.++
	if(aq_pain > 80)
		.++
	if(blood_volume < BLOOD_VOLUME_OKAY)
		.++
	if(blood_volume < BLOOD_VOLUME_BAD)
		.++

/mob/living/carbon/human/proc/aq_update_pulse(obj/item/organ/heart/heart)
	if(!heart.beating)
		heart.aq_pulse = AQ_PULSE_NONE
		return
	var/mod = aq_pulse_mod()
	// Bay: a racing heart wears itself out
	if(mod > 2 && prob((mod - 2) ** 2 * 2))
		heart.applyOrganDamage(1)
	var/stop_reason
	if(blood_volume < BLOOD_VOLUME_SURVIVE && prob(80))
		stop_reason = "Za mało krwi, serce nie ma czego pompować"
	else if(getOrganLoss(ORGAN_SLOT_BRAIN) > 150 && prob(getOrganLoss(ORGAN_SLOT_BRAIN) - 150))
		stop_reason = "Mózg przestaje sterować sercem"
	else if(heart.aq_pulse == AQ_PULSE_THREADY && prob(5))
		stop_reason = "Migotanie przechodzi w zatrzymanie"
	else if(mod >= 5 && prob(3))
		stop_reason = "Serce nie wytrzymuje takiego tempa"
	if(stop_reason)
		set_heartattack(TRUE)
		heart.aq_pulse = AQ_PULSE_NONE
		to_chat(src, "<span class='userdanger'>Twoje serce stanęło! [stop_reason].</span>")
		log_message("doznał(a) zatrzymania krążenia: [stop_reason]", LOG_ATTACK)
		return
	if(mod < 6)
		heart.aq_pulse = clamp(AQ_PULSE_NORM + round(mod, 1), AQ_PULSE_SLOW, AQ_PULSE_2FAST)
	else
		heart.aq_pulse = AQ_PULSE_THREADY
	if(blood_volume <= BLOOD_VOLUME_SURVIVE || (aq_pain > 120 && prob(30)))
		heart.aq_pulse = AQ_PULSE_THREADY

/// Blood the heart moves, in blood volume units
/mob/living/carbon/human/proc/aq_get_circulation()
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(heart && heart.beating && !undergoing_cardiac_arrest())
		if(heart.organ_flags & ORGAN_SYNTHETIC)
			return blood_volume
		var/static/list/pulse_factor = list(0.9, 1, 1.1, 1.25, 0.8)
		return blood_volume * pulse_factor[clamp(heart.aq_pulse, AQ_PULSE_SLOW, AQ_PULSE_THREADY)]
	if(world.time < aq_cpr_until)
		return blood_volume * 0.5
	return blood_volume * 0.25

/// Bay: the brain starves of oxygen when too little blood reaches it, here twice as slowly
/mob/living/carbon/human/proc/aq_handle_brain_oxygen()
	if(HAS_TRAIT(src, TRAIT_NOBREATH) && !needs_heart())
		return
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain || (brain.organ_flags & ORGAN_SYNTHETIC))
		// No brain to starve (positronic brain of an IPC): the body wears down instead, as the core did before
		if(stat != DEAD && undergoing_cardiac_arrest())
			adjustBruteLoss(2)
		return
	// Procent normalnej objętości krwi docierającej do mózgu, progi jak w Bay (85/75/60/30%)
	var/circulation = 100 * aq_get_circulation() / BLOOD_VOLUME_NORMAL
	var/damage = brain.damage
	switch(circulation)
		if(85 to INFINITY)
			return
		if(75 to 85)
			if(damage < 40 && prob(30))
				adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
		if(60 to 75)
			blur_eyes(6)
			if(damage < 80 && prob(40))
				adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
			if(prob(5))
				Unconscious(2 SECONDS)
		if(30 to 60)
			blur_eyes(6)
			if(damage < 120 && prob(50))
				adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
			if(prob(7))
				Unconscious(rand(3, 5) SECONDS)
		else
			adjustOrganLoss(ORGAN_SLOT_BRAIN, AQ_HYPOXIA_BRAIN_DAMAGE)
			Unconscious(4 SECONDS)

/// Lines for the health analyzer (wounds/_wounds.dm get_wound_scan_lines)
/mob/living/carbon/proc/aq_pulse_scan_lines()
	. = list()
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!heart || stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH) || (heart.organ_flags & ORGAN_SYNTHETIC)) // udawana śmierć wygląda jak śmierć
		return
	. += "<span class='info'>Tętno: [heart.aq_pulse_text()].</span>"

// --- RKO ---

/// Chest compressions on a stopped heart (Bay): blood moves for a while, a rib may crack, the heart may start again
/mob/living/carbon/human/do_cpr(mob/living/carbon/C)
	var/mob/living/carbon/human/patient = C
	if(!istype(patient) || patient.stat == DEAD || !patient.undergoing_cardiac_arrest() || !patient.can_heartattack())
		return ..()
	if(patient.aq_cpr_until > world.time + AQ_CPR_DURATION - 5 SECONDS)
		return
	visible_message("<span class='notice'>[src] zaczyna uciskać klatkę piersiową [patient].</span>", "<span class='notice'>Zaczynasz uciskać klatkę piersiową [patient]... Nie ruszaj się!</span>")
	if(!do_mob(src, patient, 3 SECONDS))
		to_chat(src, "<span class='warning'>Przerywasz uciskanie.</span>")
		return
	if(QDELETED(patient) || patient.stat == DEAD)
		return
	patient.aq_cpr_until = world.time + AQ_CPR_DURATION
	// Rescue breaths as in the core CPR, when both mouths are free
	if(!HAS_TRAIT(src, TRAIT_NOBREATH) && !is_mouth_covered() && !patient.is_mouth_covered())
		patient.adjustOxyLoss(-min(patient.getOxyLoss(), 7))
	visible_message("<span class='notice'>[src] uciska klatkę piersiową [patient] w równym rytmie.</span>", "<span class='notice'>Uciskasz klatkę piersiową [patient]. Krew krąży, dopóki uciskasz.</span>")
	SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "perform_cpr", /datum/mood_event/perform_cpr)
	log_combat(src, patient, "uciskał(a) klatkę piersiową (RKO)")
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	if(chest && prob(10) && !chest.get_wound(WOUND_BLUNT))
		var/datum/wound/blunt/fracture/ribs = new()
		ribs.apply_wound(chest, silent = TRUE)
		visible_message("<span class='danger'>Coś chrupie w klatce piersiowej [patient]!</span>", "<span class='warning'>Pod twoimi dłońmi trzaska żebro.</span>")
	if(prob(5))
		patient.set_heartattack(FALSE)
		visible_message("<span class='notice'>Serce [patient] znów zaczyna bić!</span>")

/// A stopped heart does not lower health any more (the core only offers CPR below 0 health), so a lying patient
/// in cardiac arrest gets CPR on a help click too, with the same checks as the core
/datum/species/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	// Każdy umysł ma domyślną sztukę walki: liczy się tylko udany chwyt, potem sztuka walki już nie wchodzi drugi raz
	if(attacker_style?.help_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	if(!aq_wants_cpr(user, target))
		return ..(user, target, null)
	if(HAS_TRAIT(user, TRAIT_NOBREATH))
		to_chat(user, "<span class='notice'>Nie oddychasz, więc nie możesz przeprowadzić resuscytacji.</span>")
	else if(!user.getorganslot(ORGAN_SLOT_LUNGS))
		to_chat(user, "<span class='warning'>Nie masz płuc, więc nie możesz przeprowadzić resuscytacji.</span>")
	else
		user.do_cpr(target)
	return TRUE

/// A help click on this target is CPR on a stopped heart that the core would only shake
/datum/species/proc/aq_wants_cpr(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return target != user && target.stat != DEAD && target.health >= 0 && !(target.mobility_flags & MOBILITY_STAND) && target.undergoing_cardiac_arrest()

// --- Prąd ---

// Defibrylator w trybie walki bez zabezpieczenia zatrzymuje zdrowe serce już w core (defib.dm, do_harm).

/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, safety = 0, override = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	var/was_beating = can_heartattack() && !undergoing_cardiac_arrest()
	. = ..()
	if(was_beating && !illusion && . >= 20 && stat != DEAD && prob(15))
		set_heartattack(TRUE)
		to_chat(src, "<span class='userdanger'>Prąd przechodzi przez serce, a ono staje!</span>")

// --- Mózg poza ciałem ---

/obj/item/organ/brain/on_death(delta_time = 2)
	. = ..()
	if(owner || (organ_flags & (ORGAN_FROZEN | ORGAN_SYNTHETIC)) || istype(loc, /obj/item/mmi))
		return
	applyOrganDamage(0.55 * delta_time / 2) // ok. 6 minut do śmierci mózgu

// --- Regeneracja tkanek po toksynach i niedotlenieniu (Citadel/Skyrat: toxichealing) ---

/datum/surgery_operation/limb/tissue_regeneration
	name = "regeneracja tkanek"
	catalog_sections = list(SURGERY_SECTION_CHEST)
	rnd_name = "Regeneracja tkanek"
	desc = "Oczyszcza tkanki z toksyn i skutków niedotlenienia. Powtarzana leczy po 15 obrażeń toksycznych i z niedotlenienia, działa też na zwłokach."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 4,
	)
	time = 4 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_LOOPING
	all_surgery_states_required = SURGERY_SKIN_OPEN
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_operation/limb/tissue_regeneration/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_CHEST)]", "pacjent ma obrażenia toksyczne albo z niedotlenienia") + ..()

/datum/surgery_operation/limb/tissue_regeneration/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat")

/datum/surgery_operation/limb/tissue_regeneration/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && limb.owner && (limb.owner.getToxLoss() > 0 || limb.owner.getOxyLoss() > 0)

/datum/surgery_operation/limb/tissue_regeneration/can_loop(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	return ..() && patient && (patient.getToxLoss() > 0 || patient.getOxyLoss() > 0)

/datum/surgery_operation/limb/tissue_regeneration/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz oczyszczać tkanki [limb.owner]..."),
		span_notice("[surgeon] zaczyna oczyszczać tkanki [limb.owner] za pomocą [tool]."),
		span_notice("[surgeon] zaczyna operację klatki piersiowej [limb.owner]."),
	)
	display_pain(limb.owner, "Klatkę piersiową wypełnia ci tępy, rozlewający się ból.")

/datum/surgery_operation/limb/tissue_regeneration/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/patient = limb.owner
	patient.adjustToxLoss(-15, forced = TRUE)
	patient.adjustOxyLoss(-15)
	display_results(
		surgeon,
		patient,
		span_notice("Oczyszczasz część tkanek [patient]."),
		span_notice("[surgeon] oczyszcza część tkanek [patient]."),
		span_notice("[surgeon] kończy krok operacji [patient]."),
	)

#undef AQ_PULSE_NONE
#undef AQ_PULSE_SLOW
#undef AQ_PULSE_NORM
#undef AQ_PULSE_FAST
#undef AQ_PULSE_2FAST
#undef AQ_PULSE_THREADY
#undef AQ_HYPOXIA_BRAIN_DAMAGE
#undef AQ_CPR_DURATION
