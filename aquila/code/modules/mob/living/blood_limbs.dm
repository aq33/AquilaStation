// AQUILA - bleeding per limb. Bee keeps one bleed rate per mob (code/modules/mob/living/blood.dm); here every body zone
// bleeds, heals and is bandaged on its own, like tgstation, where the bleeding is the sum of the limbs.
// The status keeps bleed_rate and bandaged_bleeding as the sums of the zones, so everything that reads them still works.
// Which zone new bleeding comes from: the zone passed to add_bleeding(), else the wound or limb being handled
// (aq_bleed_zone_context), else the limb hit a moment ago, else the chest. A stump keeps bleeding from its zone.
// Full overrides (tick, merge, cauterise_wounds, suppress_bloodloss, get_bleed_rate_string): LEGACY_OVERRIDES.md.

/// How long after a hit new bleeding without a zone is still put on the limb that was hit
#define AQ_BLEED_HIT_MEMORY (1 SECONDS)

/mob/living/carbon
	/// Zone of the wound or limb being handled right now, used by add_bleeding() without a zone
	var/aq_bleed_zone_context
	/// The limb that last took brute or burn damage, and when
	var/aq_last_hit_zone
	var/aq_last_hit_time = 0
	/// Zone pressed by hand (hold_wounds)
	var/aq_held_bleed_zone
	/// Zone a medical stack is being put on, for suppress_bloodloss() called without a zone
	var/aq_bandage_zone

/datum/status_effect/bleeding
	/// Body zone -> bleed rate from that zone
	var/list/limb_bleed = list()
	/// Body zone -> bleeding stopped by a bandage on that zone, heals slowly
	var/list/limb_bandaged = list()

/// Zone new bleeding without a zone comes from
/mob/living/proc/aq_bleed_zone()
	return BODY_ZONE_CHEST

/mob/living/carbon/aq_bleed_zone()
	if(aq_bleed_zone_context)
		return aq_bleed_zone_context
	if(aq_last_hit_zone && world.time - aq_last_hit_time <= AQ_BLEED_HIT_MEMORY)
		return aq_last_hit_zone
	return BODY_ZONE_CHEST

/obj/item/bodypart/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null)
	if(owner && (brute > 0 || burn > 0))
		owner.aq_last_hit_zone = body_zone
		owner.aq_last_hit_time = world.time
	return ..()

/// A torn off limb bleeds from its stump
/obj/item/bodypart/dismember(dam_type = BRUTE)
	var/mob/living/carbon/old_owner = owner
	if(!old_owner)
		return ..()
	var/old_context = old_owner.aq_bleed_zone_context
	old_owner.aq_bleed_zone_context = body_zone
	. = ..()
	old_owner.aq_bleed_zone_context = old_context

/// add_bleeding(level, zone): the zone is optional, see the header. Humans too: the core human override calls ..()
/// with the level only, so the zone travels in aq_bleed_zone_context.
/mob/living/carbon/add_bleeding(bleed_level, zone)
	if(!zone)
		return ..()
	var/old_context = aq_bleed_zone_context
	aq_bleed_zone_context = check_zone(zone)
	. = ..()
	aq_bleed_zone_context = old_context

/mob/living/carbon/human/add_bleeding(bleed_level, zone)
	if(!zone)
		return ..()
	var/old_context = aq_bleed_zone_context
	aq_bleed_zone_context = check_zone(zone)
	. = ..()
	aq_bleed_zone_context = old_context

// --- The status ---

/datum/status_effect/bleeding/on_creation(mob/living/new_owner, bleed_rate, zone)
	. = ..()
	if(!.)
		return
	src.bleed_rate = 0
	add_limb_bleeding(zone ? check_zone(zone) : owner.aq_bleed_zone(), bleed_rate)
	linked_alert.maptext = MAPTEXT(owner.get_bleed_rate_string())

/// Bee merge formula, per zone: more bleeding on a bleeding limb adds less
/datum/status_effect/bleeding/merge(bleed_level, zone)
	add_limb_bleeding(zone ? check_zone(zone) : owner.aq_bleed_zone(), bleed_level)
	update_icon()

/datum/status_effect/bleeding/proc/add_limb_bleeding(zone, bleed_level)
	if(bleed_level <= 0)
		if(bleed_level < 0)
			change_limb_bleeding(zone, bleed_level)
		return
	var/current = limb_bleed[zone] || 0
	var/new_rate = current > 0 ? current + max(min(bleed_level * bleed_level, sqrt(bleed_level)) / max(current, 1), bleed_level - current) : bleed_level
	var/added = new_rate - current
	var/mob/living/carbon/carbon_owner = owner
	if(istype(carbon_owner))
		added = carbon_owner.aq_tourniquet_absorb(zone, added) // tourniquet.dm
	change_limb_bleeding(zone, added)

/// Adds (or with a negative amount takes) bleeding on one zone, without the merge formula
/datum/status_effect/bleeding/proc/change_limb_bleeding(zone, amount)
	limb_bleed[zone] = max(0, (limb_bleed[zone] || 0) + amount)
	recalc()

/// Moves bleeding of one zone under a bandage. Returns how much was bandaged.
/datum/status_effect/bleeding/proc/bandage_limb(zone, amount)
	amount = min(amount, limb_bleed[zone] || 0)
	if(amount <= 0)
		return 0
	limb_bleed[zone] -= amount
	limb_bandaged[zone] = (limb_bandaged[zone] || 0) + amount
	recalc()
	return amount

/// bleed_rate and bandaged_bleeding are the sums of the zones; empty zones are dropped
/datum/status_effect/bleeding/proc/recalc()
	bleed_rate = 0
	for(var/zone in limb_bleed.Copy())
		if(limb_bleed[zone] <= 0)
			limb_bleed -= zone
		else
			bleed_rate += limb_bleed[zone]
	bandaged_bleeding = 0
	for(var/zone in limb_bandaged.Copy())
		if(limb_bandaged[zone] <= 0)
			limb_bandaged -= zone
		else
			bandaged_bleeding += limb_bandaged[zone]

/// Zones from the worst bleeding down
/datum/status_effect/bleeding/proc/zones_by_bleeding()
	. = list()
	var/list/left = limb_bleed.Copy()
	while(length(left))
		var/worst
		for(var/zone in left)
			if(!worst || left[zone] > left[worst])
				worst = zone
		. += worst
		left -= worst

/// Bleeding cut by holding a limb with a hand: up to BLEED_RATE_MINOR, from the held zone only
/datum/status_effect/bleeding/proc/get_held_reduction()
	if(!HAS_TRAIT(owner, TRAIT_BLEED_HELD))
		return 0
	var/mob/living/carbon/carbon_owner = owner
	var/zone = istype(carbon_owner) ? carbon_owner.aq_held_bleed_zone : null
	if(!zone || !limb_bleed[zone])
		zone = length(limb_bleed) ? zones_by_bleeding()[1] : null
	return zone ? min(BLEED_RATE_MINOR, limb_bleed[zone]) : 0

/datum/status_effect/bleeding/tick()
	if(HAS_TRAIT(owner, TRAIT_NO_BLOOD))
		qdel(src)
		return
	time_applied += tick_interval
	if(time_applied < 1 SECONDS)
		if(bleed_rate >= BLEED_DEEP_WOUND)
			owner.add_splatter_floor(owner.loc)
		else
			owner.add_splatter_floor(owner.loc, TRUE)
		return
	time_applied = 0
	var/heal = BLEED_HEAL_RATE_MINOR * bleed_heal_multiplier
	if(!ishuman(owner))
		// Non-humans stop bleeding a lot quicker, even if it is not a minor cut
		for(var/zone in limb_bleed)
			limb_bleed[zone] -= heal * 4
		for(var/zone in limb_bandaged)
			limb_bandaged[zone] -= heal * 4
	else
		// A minor bleed closes by itself; a bandage heals while its limb does not bleed on its own
		for(var/zone in limb_bleed)
			if(limb_bleed[zone] < BLEED_RATE_MINOR)
				limb_bleed[zone] -= heal
		for(var/zone in limb_bandaged)
			if(!(limb_bleed[zone] > 0 && limb_bleed[zone] < BLEED_RATE_MINOR))
				limb_bandaged[zone] -= heal
	recalc()
	update_icon()
	tick_interval = bleed_rate <= BLEED_RATE_MINOR ? 1 SECONDS : 0.2 SECONDS
	if(bleed_rate <= 0 && bandaged_bleeding <= 0)
		qdel(src)
		return
	var/final_bleed_rate = bleed_rate - get_held_reduction()
	if(final_bleed_rate <= 0)
		return
	owner.bleed(min(MAX_BLEED_RATE, final_bleed_rate))

/datum/status_effect/bleeding/robotic/tick()
	limb_bandaged.Cut() // no flesh: sealed leaks are repaired at once (Bee robotic/tick zeroes bandaged_bleeding)
	return ..()

// --- Mob procs ---

/mob/living/carbon/proc/get_bleed_status()
	RETURN_TYPE(/datum/status_effect/bleeding)
	return has_status_effect(STATUS_EFFECT_BLEED)

/// Bleeding from one zone (not bandaged)
/mob/living/carbon/proc/aq_get_limb_bleed(zone)
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	return bleed ? (bleed.limb_bleed[zone] || 0) : 0

/// Bandaged bleeding on one zone
/mob/living/carbon/proc/aq_get_limb_bandaged(zone)
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	return bleed ? (bleed.limb_bandaged[zone] || 0) : 0

/// Zone -> bleeding, a copy
/mob/living/carbon/proc/aq_get_limb_bleeds()
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	return bleed ? bleed.limb_bleed.Copy() : list()

/mob/living/carbon/is_bleeding(zone)
	if(!zone)
		return ..()
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	return aq_get_limb_bleed(check_zone(zone)) > 0

/mob/living/carbon/is_bandaged(zone)
	if(!zone)
		return ..()
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	return aq_get_limb_bandaged(check_zone(zone)) > 0

/// Closes bleeding: from one zone, or with no zone from the worst bleeding limbs first. INFINITY closes everything.
/// A negative amount opens bleeding again (vampire recuperate).
/mob/living/carbon/cauterise_wounds(amount = INFINITY, zone)
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed)
		return FALSE
	if(amount < 0)
		bleed.change_limb_bleeding(zone ? check_zone(zone) : aq_bleed_zone(), -amount)
		bleed.update_icon()
		return TRUE
	if(zone)
		zone = check_zone(zone)
		bleed.change_limb_bleeding(zone, -amount)
		if(amount == INFINITY)
			bleed.limb_bandaged -= zone
			bleed.recalc()
	else if(amount == INFINITY)
		bleed.limb_bleed.Cut()
		bleed.recalc()
	else
		for(var/worst in bleed.zones_by_bleeding())
			if(amount <= 0)
				break
			var/closed = min(amount, bleed.limb_bleed[worst])
			bleed.change_limb_bleeding(worst, -closed)
			amount -= closed
	// Bee: cauterising ends the status once nothing bleeds; a zone-only cautery keeps the other bandages
	if(bleed.bleed_rate <= 0 && (!zone || bleed.bandaged_bleeding <= 0))
		remove_status_effect(STATUS_EFFECT_BLEED)
	else
		bleed.update_icon()
	return TRUE

/// Bandages bleeding: on one zone, or with no zone the worst bleeding limbs first
/mob/living/carbon/suppress_bloodloss(amount, zone)
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed)
		return
	zone = zone || aq_bandage_zone
	if(zone)
		bleed.bandage_limb(check_zone(zone), amount)
	else
		for(var/worst in bleed.zones_by_bleeding())
			if(amount <= 0)
				break
			amount -= bleed.bandage_limb(worst, amount)
	bleed.update_icon()
	if(bleed.bleed_rate <= 0)
		stop_holding_wounds()

/mob/living/carbon/get_bleed_rate_string()
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed)
		return "0.0/s"
	var/final_bleed_rate = round(max(0, bleed.bleed_rate - bleed.get_held_reduction()), 0.1)
	if((final_bleed_rate * 10) % 10 == 0)
		return "[final_bleed_rate].0/s"
	return "[final_bleed_rate]/s"

/mob/living/carbon/aq_trail_bleed_rate()
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed)
		return 0
	return max(0, bleed.bleed_rate - bleed.get_held_reduction())

/// Pressing a wound holds the selected limb, or the worst bleeding one
/mob/living/carbon/hold_wounds()
	. = ..()
	if(!(locate(/obj/item/offhand/bleeding_suppress) in held_items))
		return
	var/zone = check_zone(zone_selected)
	if(aq_get_limb_bleed(zone) <= 0)
		var/datum/status_effect/bleeding/bleed = get_bleed_status()
		var/list/worst = bleed?.zones_by_bleeding()
		zone = length(worst) ? worst[1] : zone
	aq_held_bleed_zone = zone
	to_chat(src, "<span class='notice'>Uciskasz krwawiącą ranę ([strefa_pl(zone)]).</span>")
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	bleed?.update_icon()

/// A bandage stops the bleeding of the targeted limb only, a stump included
/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!stop_bleeding || !iscarbon(M) || !user)
		return ..()
	var/mob/living/carbon/patient = M
	var/zone = check_zone(user.zone_selected)
	if(patient.is_bleeding() && !patient.is_bleeding(zone))
		to_chat(user, "<span class='warning'>Ta część ciała ([strefa_pl(zone)]) nie krwawi. Krwawi: [patient.aq_bleeding_zones_text()].</span>")
		if(!patient.get_bodypart(zone)?.brute_dam || !heal_brute)
			return
	if(!patient.get_bodypart(zone) && patient.is_bleeding(zone))
		bandage_stump(patient, user, zone)
		return
	patient.aq_bandage_zone = zone
	. = ..()
	patient.aq_bandage_zone = null

/obj/item/stack/medical/proc/bandage_stump(mob/living/carbon/patient, mob/user, zone)
	if(patient in user.do_afters)
		return
	if(patient == user && !do_mob(user, patient, self_delay))
		return
	if(!patient.is_bleeding(zone) || !use(1))
		return
	patient.suppress_bloodloss(stop_bleeding, zone)
	user.visible_message("<span class='green'>[user] opatruje kikut ([strefa_pl(zone)]) [patient].</span>", "<span class='green'>Opatrujesz kikut ([strefa_pl(zone)]).</span>")

/// "lewa noga 1.2/s, klatka piersiowa 0.4/s" for the scanner and messages
/mob/living/carbon/proc/aq_bleeding_zones_text(bandaged = FALSE)
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed)
		return ""
	var/list/source = bandaged ? bleed.limb_bandaged : bleed.limb_bleed
	var/list/parts = list()
	for(var/zone in source)
		var/stump = get_bodypart(zone) ? "" : " (kikut)"
		parts += bandaged ? "[strefa_pl(zone)][stump]" : "[strefa_pl(zone)][stump] [round(source[zone], 0.1)]/s"
	return jointext(parts, ", ")

/mob/living/carbon/get_wound_scan_lines()
	. = ..()
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	if(length(bleed.limb_bleed))
		. += "<span class='alert'>Krwawienie: [aq_bleeding_zones_text()].</span>"
	if(length(bleed.limb_bandaged))
		. += "<span class='notice'>Opatrzone krwawienie: [aq_bleeding_zones_text(TRUE)].</span>"

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	var/datum/status_effect/bleeding/bleed = get_bleed_status()
	if(!bleed || !length(bleed.limb_bleed) || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	var/list/parts = list()
	for(var/zone in bleed.zones_by_bleeding())
		parts += get_bodypart(zone) ? strefa_pl(zone) : "kikut ([strefa_pl(zone)])"
	. += "<span class='warning'>Krew cieknie z: [jointext(parts, ", ")].</span>"

#undef AQ_BLEED_HIT_MEMORY
