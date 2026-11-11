// AQUILA - pain (medycyna 4). Compared in raport/medycyna4_03_bol_porownanie.md.
// Like TGMC (code/modules/mob/living/carbon/shock.dm) the pain is computed from zero every Life: damage, wounds, missing
// limbs, open surgery, organs, tourniquets. Like cmss13 (code/datums/pain/_pain.dm) painkillers take off less when the
// pain is big. Adrenaline from the adrenal glands (adrenaline.dm) or an autoinjector numbs it for a while. The felt pain
// catches up with the computed one gradually. Limbs paralysed by the spine or the brain feel nothing.
// Pain gives only messages about the worst limb, screen effects (the red vignette follows the felt pain instead of the
// damage, blur, a flash on a sharp jump), slowdown in place of the Bee damage slowdown, and slower stamina regeneration.
// Analgesia (anaesthesia, determination-like effects) and robotic limbs feel nothing.

/// Felt pain catches up this fraction of the difference per Life (2 s): faster up than down
#define AQ_PAIN_RISE 0.4
#define AQ_PAIN_FALL 0.2
/// Pain at which the slowdown starts, and how it scales (like the old damage slowdown: 40 -> 0.4, 100 -> 1.2)
#define AQ_PAIN_SLOWDOWN_START 30
#define AQ_PAIN_SLOWDOWN_SCALE 75
#define AQ_PAIN_SLOWDOWN_MAX 3
/// cmss13: painkillers lose this much of their strength per point of pain
#define AQ_PAIN_REDUCTION_FALLOFF 0.25
/// A jump of the computed pain this big flashes the screen
#define AQ_PAIN_SHARP_JUMP 15

/// Painkiller -> how much pain it takes off (cmss13/TGMC scale)
GLOBAL_LIST_INIT(aq_painkillers, list(
	/datum/reagent/medicine/morphine = 80,
	/datum/reagent/drug/ketamine = 60,
	/datum/reagent/toxin/fentanyl = 60,
	/datum/reagent/drug/krokodil = 50,
	/datum/reagent/medicine/mine_salve = 40,
	/datum/reagent/consumable/ethanol/painkiller = 25,
	/datum/reagent/medicine/sal_acid = 20,
	/datum/reagent/medicine/epinephrine = 10,
))

/mob/living/carbon/human
	/// Pain computed from the body this Life
	var/aq_pain_raw = 0
	/// Felt pain, after painkillers and adrenaline, smoothed
	var/aq_pain = 0
	/// Computed pain of the previous Life, for the sharp pain flash
	var/aq_pain_last_raw = 0
	/// Adds to the vignette for one HUD update after a sharp jump
	var/aq_pain_flash = 0
	var/aq_next_pain_message = 0
	/// Last stamina regeneration multiplier from pain, so the container is touched only on a change
	var/aq_pain_regen_mult = 1

/// Pain one wound adds; a treated wound hurts half as much
/datum/wound/proc/get_pain()
	. = 5
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			. = 8
		if(WOUND_SEVERITY_SEVERE)
			. = 18
		if(WOUND_SEVERITY_CRITICAL)
			. = 30
	if(treated)
		. *= 0.5

/// Does this limb feel pain: organic and not paralysed
/mob/living/carbon/human/proc/aq_limb_feels_pain(obj/item/bodypart/limb)
	return IS_ORGANIC_LIMB(limb) && limb.disabled != BODYPART_DISABLED_PARALYSIS

/// Pain of one limb: damage, wounds, open surgery
/mob/living/carbon/human/proc/aq_limb_pain(obj/item/bodypart/limb)
	if(!aq_limb_feels_pain(limb))
		return 0
	. = limb.brute_dam + limb.burn_dam * 1.2
	for(var/datum/wound/wound as anything in limb.wounds)
		. += wound.get_pain()
	if(LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_SKIN_STATES))
		. += 15

/// Pain computed from the body, before painkillers
/mob/living/carbon/human/proc/aq_compute_pain()
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_ANALGESIA) || (status_flags & GODMODE))
		return 0
	// A synthetic body (IPC, full prosthetic torso) has no nerves to hurt and no adrenal glands
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest || !IS_ORGANIC_LIMB(chest))
		return 0
	. = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. += aq_limb_pain(limb)
	// A stump hurts
	for(var/zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!get_bodypart(zone))
			. += 15
	. += getToxLoss() * 0.5 + getCloneLoss()
	for(var/obj/item/organ/organ as anything in internal_organs)
		if(organ.damage > 0 && organ.slot != ORGAN_SLOT_BRAIN && organ.status == ORGAN_ORGANIC)
			. += organ.damage * 0.3
	. += 5 * LAZYLEN(aq_tourniquets)

/// How much the painkillers and adrenaline in the blood take off a pain this big
/mob/living/carbon/human/proc/aq_pain_suppression(raw_pain)
	var/strongest = 0
	var/rest = 0
	for(var/datum/reagent/reagent as anything in reagents?.reagent_list)
		var/strength = GLOB.aq_painkillers[reagent.type]
		if(istype(reagent, /datum/reagent/medicine/adrenaline))
			strength = aq_adrenaline_strength()
		if(!strength)
			continue
		if(strength > strongest)
			rest += strongest
			strongest = strength
		else
			rest += strength
	var/total = strongest + rest * 0.5 + min(drunkenness, 40) * 0.5
	return max(0, total - AQ_PAIN_REDUCTION_FALLOFF * raw_pain)

/// Felt pain level name for the scanner
/proc/aq_pain_level_text(pain)
	switch(pain)
		if(-INFINITY to 10)
			return "brak"
		if(10 to 30)
			return "lekki"
		if(30 to 60)
			return "umiarkowany"
		if(60 to 100)
			return "silny"
	return "nie do zniesienia"

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform)
		return
	aq_handle_pain()

/mob/living/carbon/human/proc/aq_handle_pain()
	aq_pain_raw = aq_compute_pain()
	aq_handle_adrenal_glands() // adrenaline.dm
	var/target = max(0, aq_pain_raw - aq_pain_suppression(aq_pain_raw))
	aq_pain += (target - aq_pain) * (target > aq_pain ? AQ_PAIN_RISE : AQ_PAIN_FALL)
	if(HAS_TRAIT(src, TRAIT_ANALGESIA))
		aq_pain = 0 // anaesthesia numbs at once, it does not wear the pain off slowly
	if(aq_pain < 1)
		aq_pain = target < 1 ? 0 : aq_pain
	var/sharp = aq_pain_raw - aq_pain_last_raw >= AQ_PAIN_SHARP_JUMP && target > 10
	aq_pain_last_raw = aq_pain_raw
	aq_update_pain_slowdown()
	aq_update_pain_stamina()
	if(stat != CONSCIOUS)
		update_damage_hud()
		return
	if(sharp)
		aq_pain_flash = 30
		blur_eyes(1)
	else if(aq_pain >= 100 && prob(40))
		blur_eyes(2)
	else if(aq_pain >= 60 && prob(20))
		blur_eyes(1)
	update_damage_hud()
	aq_pain_flash = 0
	aq_pain_message(sharp)

/// Slowdown from pain, in place of the damage slowdown; ignored by the same effects (morphine and the like)
/mob/living/carbon/human/proc/aq_update_pain_slowdown()
	if(aq_pain < AQ_PAIN_SLOWDOWN_START || HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN) || stat == DEAD)
		remove_movespeed_modifier("aq_pain")
		remove_movespeed_modifier("aq_pain_flying")
		return
	var/over = aq_pain - AQ_PAIN_SLOWDOWN_START + 10
	add_movespeed_modifier("aq_pain", override = TRUE, multiplicative_slowdown = min(AQ_PAIN_SLOWDOWN_MAX, over / AQ_PAIN_SLOWDOWN_SCALE), blacklisted_movetypes = FLOATING|FLYING)
	add_movespeed_modifier("aq_pain_flying", override = TRUE, multiplicative_slowdown = min(AQ_PAIN_SLOWDOWN_MAX * 2, over / 25), movetypes = FLOATING)

/// Pain slows the stamina regeneration
/mob/living/carbon/human/proc/aq_update_pain_stamina()
	var/mult = 1
	switch(aq_pain)
		if(30 to 60)
			mult = 0.75
		if(60 to 100)
			mult = 0.5
		if(100 to INFINITY)
			mult = 0.35
	if(mult == aq_pain_regen_mult || !stamina)
		return
	aq_pain_regen_mult = mult
	if(mult == 1)
		stamina.remove_regen_multiplier("aq_pain")
	else
		stamina.add_regen_multiplier("aq_pain", mult)

/// The red vignette follows the felt pain instead of the damage
/mob/living/carbon/human/update_damage_hud()
	. = ..()
	if(!client)
		return
	var/hurt = aq_pain + aq_pain_flash + damageoverlaytemp
	if(stat != CONSCIOUS || hurt < 10)
		clear_fullscreen("brute")
		return
	var/severity = 1
	switch(hurt)
		if(25 to 40)
			severity = 2
		if(40 to 60)
			severity = 3
		if(60 to 85)
			severity = 4
		if(85 to 110)
			severity = 5
		if(110 to INFINITY)
			severity = 6
	overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)

/// The limb that hurts most, null if none feels pain
/mob/living/carbon/human/proc/aq_worst_pain_zone()
	var/worst_pain = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/limb_pain = aq_limb_pain(limb)
		if(limb_pain > worst_pain)
			worst_pain = limb_pain
			. = limb.body_zone

/// Messages about the worst limb (vgstation handle_pain()), more often the more it hurts
/mob/living/carbon/human/proc/aq_pain_message(sharp)
	if(aq_pain < 10 || (!sharp && world.time < aq_next_pain_message))
		return
	aq_next_pain_message = world.time + rand(20, 40) SECONDS * (1 - min(aq_pain, 150) / 250)
	var/zone = aq_worst_pain_zone()
	var/part = zone ? strefa_pl(zone) : "całe ciało"
	if(sharp && zone)
		to_chat(src, "<span class='userdanger'>Ostry ból przeszywa [strefa_pl(zone, TRUE)]!</span>")
		return
	switch(aq_pain)
		if(10 to 30)
			to_chat(src, "<span class='danger'>[capitalize(part)] boli.</span>")
		if(30 to 60)
			to_chat(src, "<span class='danger'>[capitalize(part)] mocno boli!</span>")
		if(60 to 100)
			to_chat(src, "<span class='danger'><b>[capitalize(part)] pulsuje ostrym bólem!</b></span>")
		else
			to_chat(src, "<span class='userdanger'>Ból jest nie do zniesienia, najgorzej boli [part]!</span>")

/mob/living/carbon/human/get_wound_scan_lines()
	. = ..()
	if(aq_pain >= 10 || aq_pain_raw >= 10)
		. += "<span class='alert'>Ból: [aq_pain_level_text(aq_pain)] ([round(aq_pain)], bez leków [round(aq_pain_raw)]).</span>"
	if(aq_adrenaline_tolerance >= 0.2)
		. += "<span class='notice'>Rezerwa nadnerczy: [round(aq_adrenal_reserve)]%, tolerancja na adrenalinę [round(aq_adrenaline_tolerance * 100)]%.</span>"
	else if(aq_adrenal_reserve < 100)
		. += "<span class='notice'>Rezerwa nadnerczy: [round(aq_adrenal_reserve)]%.</span>"

/mob/living/carbon/human/fully_heal(admin_revive = FALSE)
	. = ..()
	aq_pain = 0
	aq_pain_raw = 0
	aq_pain_last_raw = 0
	aq_update_pain_slowdown()
	aq_update_pain_stamina()

#undef AQ_PAIN_RISE
#undef AQ_PAIN_FALL
#undef AQ_PAIN_SLOWDOWN_START
#undef AQ_PAIN_SLOWDOWN_SCALE
#undef AQ_PAIN_SLOWDOWN_MAX
#undef AQ_PAIN_REDUCTION_FALLOFF
#undef AQ_PAIN_SHARP_JUMP
