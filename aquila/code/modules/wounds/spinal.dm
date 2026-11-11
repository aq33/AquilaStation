// AQUILA - spine wounds (medycyna 4). No codebase we compared has them: tgstation, Monkestation and Yogstation only give
// the "paraplegic" brain trauma (tackle, a vending machine), Yogstation makes it curable by surgery. Here the spine is
// a wound on the chest:
// - a bruised spinal cord slows down and now and then a leg gives out for a few seconds; it heals while lying down,
//   and standing on it can break the spine;
// - a broken spine paralyses the legs (the neck: all four limbs) until surgery: stabilising the spine, then fusing the
//   vertebrae; after it the nerves regrow for a few minutes, faster with mannitol or neurine.
// Causes: a heavy blunt hit on the chest of someone lying down or with broken ribs, falling two or more floors,
// a vending machine falling on you. Limbs below the break feel no pain (pain.dm).

/// Trait source for the paralysis from a broken spine and for a leg giving out
#define AQ_SPINE_TRAIT "aq_spine"
#define AQ_SPINE_TWITCH_TRAIT "aq_spine_twitch"

/datum/wound/spinal
	wound_type = WOUND_SPINE
	allowed_zones = list(BODY_ZONE_CHEST)
	threshold = 0
	threshold_penalty = 10

/// Bruised spinal cord: slows down, a leg gives out now and then, heals while lying down
/datum/wound/spinal/bruise
	name = "Stłuczenie rdzenia kręgowego"
	desc = "Coś chrupie ci w krzyżu, nogi drętwieją"
	examine_desc = "sztywno wyprostowane plecy"
	treat_text = "Leżenie: rdzeń wraca do siebie po około dwóch minutach. Chodzenie może złamać kręgosłup."
	severity = WOUND_SEVERITY_SEVERE
	var/rest_progress = 0
	var/rest_time = 2 MINUTES

/datum/wound/spinal/bruise/wound_effects(delta_time)
	if(!(victim.mobility_flags & MOBILITY_STAND))
		rest_progress += delta_time SECONDS
		if(rest_progress >= rest_time)
			to_chat(victim, "<span class='green'>Drętwienie w nogach mija, kręgosłup przestaje boleć.</span>")
			qdel(src)
		return
	if(DT_PROB(1.5, delta_time))
		give_out_leg()
	if(DT_PROB(0.3, delta_time))
		to_chat(victim, "<span class='userdanger'>Coś trzaska ci w kręgosłupie, nogi przestają cię słuchać!</span>")
		replace_with(/datum/wound/spinal/fracture)

/// A leg goes numb for a few seconds
/datum/wound/spinal/bruise/proc/give_out_leg()
	var/obj/item/bodypart/leg = victim.get_bodypart(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(!leg || HAS_TRAIT_FROM(leg, TRAIT_PARALYSIS, AQ_SPINE_TWITCH_TRAIT))
		return
	ADD_TRAIT(leg, TRAIT_PARALYSIS, AQ_SPINE_TWITCH_TRAIT)
	leg.update_disabled()
	to_chat(victim, "<span class='danger'>Prąd przeszywa ci kręgosłup, a [strefa_pl(leg.body_zone)] odmawia posłuszeństwa!</span>")
	addtimer(CALLBACK(leg, TYPE_PROC_REF(/obj/item/bodypart, aq_spine_twitch_end)), 4 SECONDS)

/obj/item/bodypart/proc/aq_spine_twitch_end()
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, AQ_SPINE_TWITCH_TRAIT)
	update_disabled()

/// Broken spine: the legs (or all limbs) are paralysed until surgery and the nerves regrow
/datum/wound/spinal/fracture
	name = "Złamanie kręgosłupa"
	desc = "W plecach coś trzaska i przestajesz czuć nogi"
	examine_desc = "bezwładne nogi"
	treat_text = "Operacja na otwartej klatce piersiowej: ustabilizowanie kręgosłupa (nastawiacz kości), potem zespolenie kręgów (żel kostny albo taśma chirurgiczna). Po operacji nerwy odrastają kilka minut, szybciej z mannitolem albo neuryną. Do tego czasu nosze albo wózek."
	severity = WOUND_SEVERITY_CRITICAL
	/// Broken neck: all four limbs, not only the legs
	var/cervical = FALSE
	/// Surgery step one done
	var/stabilized = FALSE
	/// After the surgery: how long the nerves take to regrow
	var/regen_time = 4 MINUTES
	var/regen_progress = 0
	var/list/paralysis_traits

/datum/wound/spinal/fracture/cervical
	name = "Złamanie kręgosłupa szyjnego"
	desc = "W karku coś trzaska i przestajesz czuć całe ciało"
	examine_desc = "bezwładne ręce i nogi"
	cervical = TRUE
	regen_time = 6 MINUTES

/datum/wound/spinal/fracture/on_apply()
	victim.play_bone_break()
	paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
	if(cervical)
		paralysis_traits += list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
	for(var/trait in paralysis_traits)
		ADD_TRAIT(victim, trait, AQ_SPINE_TRAIT)
	victim.update_disabled_bodyparts()
	RegisterSignal(victim, COMSIG_MOVABLE_MOVED, PROC_REF(on_victim_moved))

/datum/wound/spinal/fracture/Destroy()
	var/mob/living/carbon/old_victim = victim
	if(old_victim)
		UnregisterSignal(old_victim, COMSIG_MOVABLE_MOVED)
	. = ..()
	if(QDELETED(old_victim))
		return
	for(var/trait in paralysis_traits)
		REMOVE_TRAIT(old_victim, trait, AQ_SPINE_TRAIT)
	// Bee keeps the old disabled state of a damaged limb (is_disabled() inertia), so the paralysis is cleared by hand
	for(var/obj/item/bodypart/part as anything in old_victim.bodyparts)
		if(part.disabled == BODYPART_DISABLED_PARALYSIS && !HAS_TRAIT(part, TRAIT_PARALYSIS))
			part.set_disabled(BODYPART_NOT_DISABLED)
	old_victim.update_disabled_bodyparts()

/// Moved around unstabilised and not on a stretcher, a bed or a wheelchair: the broken vertebrae shift
/datum/wound/spinal/fracture/proc/on_victim_moved(datum/source)
	SIGNAL_HANDLER
	if(stabilized || victim.buckled || victim.stat == DEAD || !prob(3))
		return
	limb.receive_damage(brute = 3)
	to_chat(victim, "<span class='danger'>Złamane kręgi przesuwają się przy każdym ruchu!</span>")

/datum/wound/spinal/fracture/wound_effects(delta_time)
	if(!treated)
		return
	regen_progress += delta_time SECONDS
	if(victim.reagents?.has_reagent(/datum/reagent/medicine/mannitol) || victim.reagents?.has_reagent(/datum/reagent/medicine/neurine))
		regen_progress += delta_time SECONDS
	if(regen_progress >= regen_time)
		to_chat(victim, "<span class='green'>Czucie wraca, znowu możesz ruszać [cervical ? "rękami i nogami" : "nogami"]!</span>")
		qdel(src)

/// Surgery step one
/datum/wound/spinal/fracture/proc/stabilize()
	stabilized = TRUE
	victim.update_wound_overlays() // brace (medical_overlays.dm)
	treat_text = "Kręgosłup ustabilizowany: zespól kręgi żelem kostnym albo taśmą chirurgiczną."

/// Surgery step two: the nerves start regrowing
/datum/wound/spinal/fracture/proc/fuse()
	treated = TRUE
	treat_text = "Kręgi zespolone, nerwy odrastają. Mannitol albo neuryna przyspieszają."

/datum/wound/spinal/fracture/get_scan_text()
	var/status = "nieustabilizowane, nie ruszaj pacjenta bez noszy"
	if(treated)
		status = "po operacji, nerwy odrastają ([round(100 * regen_progress / regen_time)]%)"
	else if(stabilized)
		status = "ustabilizowane, czeka na zespolenie"
	return "Kręgosłup: <b>[name]</b> ([status]). [cervical ? "Odcinek szyjny: sparaliżowane ręce i nogi." : "Odcinek lędźwiowy: sparaliżowane nogi."] [treat_text]"

/datum/wound/spinal/bruise/get_scan_text()
	return "Kręgosłup: <b>[name]</b>. [treat_text]"

/datum/wound/spinal/on_examine(mob/living/source, mob/user, list/examine_list)
	examine_list += "<span class='warning'>Ma [examine_desc]!</span>"

/datum/wound/spinal/bruise/get_scar_description()
	return null

/datum/wound/spinal/fracture/get_scar_description()
	return "długą bliznę po operacji kręgosłupa"

// --- Causes ---

/// Hurts the spine: a bruise or a fracture, never milder than what is there already
/mob/living/carbon/proc/aq_injure_spine(severity = WOUND_SEVERITY_SEVERE, cervical = FALSE)
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest || !IS_ORGANIC_LIMB(chest) || (status_flags & GODMODE))
		return null
	var/datum/wound/spinal/existing = chest.get_wound(WOUND_SPINE)
	var/new_type = /datum/wound/spinal/bruise
	if(severity >= WOUND_SEVERITY_CRITICAL)
		new_type = cervical ? /datum/wound/spinal/fracture/cervical : /datum/wound/spinal/fracture
	if(existing)
		if(existing.type == new_type || existing.severity > severity || istype(existing, /datum/wound/spinal/fracture/cervical))
			return existing
		return existing.replace_with(new_type)
	var/datum/wound/spinal/wound = new new_type()
	wound.apply_wound(chest)
	return wound

/// Broken spine, for core code that has no wound defines (vending machine crush)
/mob/living/carbon/proc/aq_break_spine()
	return aq_injure_spine(WOUND_SEVERITY_CRITICAL)

/// A heavy blunt hit on the chest reaches the spine of someone lying down or with broken ribs
/mob/living/carbon/check_wounding(obj/item/bodypart/limb, damage, wound_type, wound_bonus = 0, bare_wound_bonus = 0, atom/wound_source)
	. = ..()
	if(wound_type != WOUND_BLUNT || wound_bonus == CANT_WOUND || damage < WOUND_MINIMUM_DAMAGE || QDELETED(limb) || limb.owner != src || limb.body_zone != BODY_ZONE_CHEST)
		return
	var/lying = !(mobility_flags & MOBILITY_STAND)
	var/datum/wound/ribs = limb.get_wound(WOUND_BLUNT)
	var/broken_ribs = ribs && ribs.severity >= WOUND_SEVERITY_SEVERE
	if(!lying && !broken_ribs)
		return
	var/roll = rand(1, max(1, round(min(damage, WOUND_MAX_CONSIDERED_DAMAGE) ** WOUND_DAMAGE_EXPONENT))) + wound_bonus
	if(lying && broken_ribs)
		roll += 15
	if(roll >= 100)
		aq_injure_spine(WOUND_SEVERITY_CRITICAL)
	else if(roll >= 65)
		aq_injure_spine(WOUND_SEVERITY_SEVERE)

/// Falling two or more floors breaks the spine, the long ones can break the neck
/mob/living/carbon/human/ZImpactDamage(turf/T, levels)
	var/brute_before = getBruteLoss()
	. = ..()
	if(getBruteLoss() <= brute_before) // landed on its feet or something softened the fall
		return
	if(levels >= 3)
		aq_injure_spine(WOUND_SEVERITY_CRITICAL, cervical = prob(30))
	else if(levels == 2)
		aq_injure_spine(prob(40) ? WOUND_SEVERITY_CRITICAL : WOUND_SEVERITY_SEVERE)
	else if(prob(10))
		aq_injure_spine(WOUND_SEVERITY_SEVERE)

/mob/living/carbon/update_wound_slowdown()
	. = ..()
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(locate(/datum/wound/spinal/bruise) in chest?.wounds)
		add_movespeed_modifier("aq_spine", override = TRUE, multiplicative_slowdown = 0.6)
	else
		remove_movespeed_modifier("aq_spine")

#undef AQ_SPINE_TRAIT
#undef AQ_SPINE_TWITCH_TRAIT
