// AQUILA - adrenaline (medycyna 4). Adrenaline is epinephrine: one reagent, /datum/reagent/medicine/epinephrine, and
// this file adds the pain side to it. Nobody we compared has adrenaline that runs out: tgstation gives "Determination"
// for every new wound, Shitmed (Polonium) has a disabled pain shock multiplier. Here the adrenal glands keep a reserve:
// strong pain releases epinephrine into the blood until the reserve runs dry, and it refills slowly only while the pain
// is small. An autoinjector (survival box) or any other epinephrine skips the reserve, but every dose builds tolerance,
// so the next works weaker. It numbs pain and speeds up stamina; when a big dose (an autoinjector) wears off comes the
// crash (stamina). Overdose also strains the heart.

/// Computed pain at which the glands release adrenaline
#define AQ_ADRENAL_PAIN_THRESHOLD 40
/// One release: epinephrine added and reserve used (epinephrine metabolises at 0.1u per Life, so 3u last about a minute)
#define AQ_ADRENAL_RELEASE_UNITS 3
#define AQ_ADRENAL_RELEASE_COST 20
#define AQ_ADRENAL_RELEASE_COOLDOWN (30 SECONDS)
/// Reserve regained per Life (2 s) while the pain is small: empty to full in about 7 minutes
#define AQ_ADRENAL_REGEN 0.5
/// Pain adrenaline takes off at no tolerance
#define AQ_ADRENALINE_PAIN_STRENGTH 45
/// Epinephrine in the blood above which the rush ends with a crash (a natural release is 3u, an autoinjector 10u)
#define AQ_ADRENALINE_CRASH_PEAK 8
/// Tolerance gained per unit metabolised, and lost per Life
#define AQ_ADRENALINE_TOLERANCE_GAIN 0.04
#define AQ_ADRENALINE_TOLERANCE_DECAY 0.004

/mob/living/carbon/human
	/// Adrenal reserve, 0-100
	var/aq_adrenal_reserve = 100
	var/aq_next_adrenal_release = 0
	/// Receptor tolerance: adrenaline works 1 / (1 + tolerance) as strong
	var/aq_adrenaline_tolerance = 0

/// Pain adrenaline in the blood takes off now
/mob/living/carbon/human/proc/aq_adrenaline_strength()
	return AQ_ADRENALINE_PAIN_STRENGTH / (1 + aq_adrenaline_tolerance)

/// The glands release adrenaline under strong pain and refill while it is small
/mob/living/carbon/human/proc/aq_handle_adrenal_glands()
	aq_adrenaline_tolerance = max(0, aq_adrenaline_tolerance - AQ_ADRENALINE_TOLERANCE_DECAY)
	if(stat == DEAD || !reagents)
		return
	var/in_blood = reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine)
	if(aq_pain_raw < 20 && !in_blood)
		aq_adrenal_reserve = min(100, aq_adrenal_reserve + AQ_ADRENAL_REGEN)
		return
	if(aq_pain_raw < AQ_ADRENAL_PAIN_THRESHOLD || world.time < aq_next_adrenal_release || in_blood >= 2)
		return
	if(aq_adrenal_reserve < AQ_ADRENAL_RELEASE_COST / 2)
		return
	aq_next_adrenal_release = world.time + AQ_ADRENAL_RELEASE_COOLDOWN
	aq_adrenal_reserve = max(0, aq_adrenal_reserve - AQ_ADRENAL_RELEASE_COST)
	reagents.add_reagent(/datum/reagent/medicine/epinephrine, AQ_ADRENAL_RELEASE_UNITS)
	if(stat != CONSCIOUS)
		return
	if(aq_adrenal_reserve < AQ_ADRENAL_RELEASE_COST / 2)
		to_chat(src, "<span class='warning'>Ostatni zastrzyk adrenaliny. Ciało nie ma już z czego jej wyrzucić, ból wróci w pełni.</span>")
	else
		to_chat(src, "<span class='notice'>Serce wali jak młot, adrenalina tłumi ból.</span>")

// --- Reagent: epinephrine (core medicine_reagents.dm) is the adrenaline ---

/datum/reagent/medicine/epinephrine
	description = "Epinefryna, czyli adrenalina: hormon walki lub ucieczki. Lekko zwiększa odporność na ogłuszenia, tłumi ból i przyspiesza odzyskiwanie sił. W stanie krytycznym powoli leczy obrażenia i reguluje utratę tlenu. Po dużej dawce przychodzi zmęczenie, a kolejne dawki w krótkim czasie tłumią ból coraz słabiej. Przedawkowanie powoduje osłabienie, obrażenia od toksyn i obciąża serce."
	/// Most epinephrine in the blood during this rush; a big rush ends with a crash
	var/peak = 0

/datum/reagent/medicine/epinephrine/on_mob_metabolize(mob/living/carbon/M)
	..()
	M.stamina?.add_regen_multiplier("aq_adrenaline", 1.5)
	M.adjustStaminaLoss(-30)

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/M)
	peak = max(peak, volume)
	var/mob/living/carbon/human/human = M
	if(istype(human))
		human.aq_adrenaline_tolerance += AQ_ADRENALINE_TOLERANCE_GAIN * metabolization_rate
	if(prob(10))
		M.Jitter(2)
	return ..()

/datum/reagent/medicine/epinephrine/on_mob_end_metabolize(mob/living/carbon/M)
	M.stamina?.remove_regen_multiplier("aq_adrenaline")
	// Only a big rush (an autoinjector, 10u) crashes; the glands' own 3u releases do not
	if(peak >= AQ_ADRENALINE_CRASH_PEAK && M.stat != DEAD)
		M.apply_status_effect(/datum/status_effect/aq_adrenaline_crash)
	peak = 0
	..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 1 * REM)
	if(prob(10))
		to_chat(M, "<span class='danger'>Serce łomocze nierówno, brakuje ci tchu!</span>")
	return ..()

/// After a rush: stamina drops and comes back slowly for a while (tgstation determination crash)
/datum/status_effect/aq_adrenaline_crash
	id = "aq_adrenaline_crash"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/aq_adrenaline_crash/on_apply()
	owner.adjustStaminaLoss(40)
	owner.stamina?.add_regen_multiplier("aq_adrenaline_crash", 0.5)
	to_chat(owner, "<span class='warning'>Adrenalina opada. Nogi robią się jak z waty.</span>")
	return TRUE

/datum/status_effect/aq_adrenaline_crash/on_remove()
	owner.stamina?.remove_regen_multiplier("aq_adrenaline_crash")

// --- Autoinjector ---

/obj/item/reagent_containers/hypospray/medipen/aq_adrenaline
	name = "autostrzykawka z adrenaliną"
	desc = "Jednorazowa autostrzykawka z 10 jednostkami epinefryny, czyli adrenaliny. Tłumi ból i daje chwilę sił, gdy własne nadnercza już nie nadążają. Potem przychodzi zmęczenie, a kolejne dawki działają słabiej."
	icon = 'aquila/icons/obj/medical/adrenaline_pen.dmi'
	icon_state = "adrenalinepen"
	item_state = "medipen"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10)

/// One adrenaline autoinjector in every crew survival box, before the bandages are added
/obj/item/storage/box/survival/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/hypospray/medipen/aq_adrenaline(src)

/obj/item/storage/box/survival_mining/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/hypospray/medipen/aq_adrenaline(src)

/obj/item/storage/box/engineer/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/hypospray/medipen/aq_adrenaline(src)

/obj/item/storage/box/security/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/hypospray/medipen/aq_adrenaline(src)

/obj/machinery/vending/medical/Initialize(mapload)
	products[/obj/item/reagent_containers/hypospray/medipen/aq_adrenaline] = 5
	return ..()

#undef AQ_ADRENAL_PAIN_THRESHOLD
#undef AQ_ADRENAL_RELEASE_UNITS
#undef AQ_ADRENAL_RELEASE_COST
#undef AQ_ADRENAL_RELEASE_COOLDOWN
#undef AQ_ADRENAL_REGEN
#undef AQ_ADRENALINE_PAIN_STRENGTH
#undef AQ_ADRENALINE_TOLERANCE_GAIN
#undef AQ_ADRENALINE_TOLERANCE_DECAY
#undef AQ_ADRENALINE_CRASH_PEAK
