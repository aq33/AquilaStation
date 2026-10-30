// AQUILA - pierce wounds from tgstation (code/datums/wounds/pierce.dm) on top of Bee bleeding: bullets and pointy weapons.
// Every further hit on a pierced limb bleeds it from the inside. Closed by cauterizing (a cautery, or any hot item
// like a lit welder or a lighter), one severity at a time, or by the cauterization surgery. Bullet holes don't clot.

/datum/wound/pierce
	wound_type = WOUND_PIERCE
	name = "Rana kłuta"
	examine_desc = "ranę kłutą"
	/// Bleeding added when the wound appears
	var/initial_bleed = BLEED_SURFACE
	/// Chance (plus the damage) that a hit on the limb bleeds it from the inside (tg internal_bleeding_chance)
	var/internal_bleeding_chance = 0
	/// Blood lost from the inside on such a hit, times sqrt(damage)
	var/internal_bleeding_coefficient = 1
	/// Wound left after one cauterization, null closes it
	var/cauterized_into

/datum/wound/pierce/on_apply()
	victim.add_bleeding(initial_bleed)
	if(wound_source_is_projectile)
		name = replacetext(name, "kłuta", "postrzałowa")
		examine_desc = replacetext(examine_desc, "kłut", "postrzałow")
	else if(heal_time)
		treated = TRUE // a small stab clots by itself

/// Called by check_wounding on every hit on the limb, before the roll
/datum/wound/pierce/proc/on_limb_hit(damage)
	if(victim.stat == DEAD || damage < WOUND_MINIMUM_DAMAGE || HAS_TRAIT(victim, TRAIT_NO_BLOOD) || !victim.blood_volume)
		return
	if(!prob(internal_bleeding_chance + damage))
		return
	var/blood_lost = sqrt(damage) * internal_bleeding_coefficient * pick(0.75, 1, 1.25, 1.5)
	victim.blood_volume = max(victim.blood_volume - blood_lost, 0)
	victim.add_splatter_floor(get_turf(victim))
	to_chat(victim, "<span class='danger'>Czujesz, jak krew wylewa się z rany ([limb.name])!</span>")

/datum/wound/pierce/can_treat_with(obj/item/item)
	return item.tool_behaviour == TOOL_CAUTERY || item.is_hot()

/datum/wound/pierce/treat(obj/item/tool, mob/user)
	var/self = user == victim
	var/improvised = tool.tool_behaviour != TOOL_CAUTERY
	var/delay = (self ? 1.5 : 1) * (improvised ? 1.25 : 1) * 3 SECONDS
	user.visible_message("<span class='danger'>[user] zaczyna przypalać ranę ([limb.name]) [victim] za pomocą [tool].</span>", "<span class='warning'>Zaczynasz przypalać ranę ([limb.name])[self ? "" : " [victim]"] za pomocą [tool].</span>")
	playsound(victim, 'sound/surgery/cautery1.ogg', 75, TRUE)
	if(!do_mob(user, victim, delay))
		return FALSE
	if(QDELETED(src))
		return FALSE
	playsound(victim, 'sound/surgery/cautery2.ogg', 75, TRUE)
	victim.apply_damage(2 + severity, BURN, limb)
	if(prob(30))
		victim.emote("scream")
	victim.suppress_bloodloss(initial_bleed)
	user.visible_message("<span class='green'>[user] przypala ranę ([limb.name]) [victim].</span>", "<span class='green'>Przypalasz ranę ([limb.name]).</span>")
	replace_with(cauterized_into)
	return TRUE

/// A cautery, or a hot item on someone you hold in an aggressive grab (or yourself), closes a pierce wound
/obj/item/attack(mob/living/M, mob/living/user, params)
	if(iscarbon(M) && (tool_behaviour == TOOL_CAUTERY || is_hot()) && !user.combat_mode && try_cauterize_pierce(M, user))
		return
	return ..()

/obj/item/proc/try_cauterize_pierce(mob/living/carbon/patient, mob/living/user)
	if(patient in user.do_afters)
		return FALSE
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	var/datum/wound/pierce/hole = limb?.get_wound(WOUND_PIERCE)
	if(!hole || !hole.can_treat_with(src))
		return FALSE
	if(tool_behaviour != TOOL_CAUTERY && patient != user && (patient.pulledby != user || user.grab_state < GRAB_AGGRESSIVE))
		return FALSE
	INVOKE_ASYNC(hole, TYPE_PROC_REF(/datum/wound, treat), src, user)
	return TRUE

/datum/wound/pierce/puncture
	name = "Rana kłuta"
	desc = "Coś przebija ci skórę"
	examine_desc = "małą ranę kłutą"
	treat_text = "Zagoi się sama, rana postrzałowa wymaga przypalenia (kauter, zapalniczka, spawarka)."
	severity = WOUND_SEVERITY_MODERATE
	threshold = 30
	series_threshold_penalty = 20
	initial_bleed = BLEED_SURFACE
	internal_bleeding_chance = 30
	internal_bleeding_coefficient = 1.5
	heal_time = 1 MINUTES

/datum/wound/pierce/open
	name = "Otwarta rana kłuta"
	desc = "Coś przebija cię na wylot"
	examine_desc = "otwartą, krwawiącą ranę kłutą"
	treat_text = "Przypal ją (kauter, zapalniczka, spawarka) albo operacja kauteryzacji."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 50
	series_threshold_penalty = 35
	initial_bleed = BLEED_CUT
	internal_bleeding_chance = 60
	internal_bleeding_coefficient = 2
	cauterized_into = /datum/wound/pierce/puncture

/datum/wound/pierce/cavity
	name = "Rozerwana rana kłuta"
	desc = "Coś rozrywa ci ciało na wylot"
	examine_desc = "rozerwaną, tryskającą krwią ranę kłutą"
	treat_text = "Przypal ją dwa razy albo operacja kauteryzacji."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 100
	threshold_penalty = 15
	initial_bleed = BLEED_CRITICAL
	internal_bleeding_chance = 80
	internal_bleeding_coefficient = 2.75
	cauterized_into = /datum/wound/pierce/open

// The cauterized wound clots by itself
/datum/wound/pierce/puncture/on_apply()
	. = ..()
	if(!wound_source_is_projectile)
		return
	treat_text = "Przypal ją (kauter, zapalniczka, spawarka)."

// --- Eye puncture ---

/// Pierced eyeball: not rolled, comes from stabbing the eyes or a bullet in the eyes (tg). Scars the eye for good.
/datum/wound/pierce/eye
	wound_type = WOUND_PIERCE
	name = "Przebite oko"
	desc = "Coś przebija ci oko"
	examine_desc = "przebite, krwawiące oko"
	treat_text = "Przypal ranę (kauter, zapalniczka). Oko zostanie z blizną: okulary korekcyjne albo nowe oczy."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 1000 // never rolled
	allowed_zones = list(BODY_ZONE_HEAD)
	initial_bleed = BLEED_CUT
	internal_bleeding_chance = 30
	internal_bleeding_coefficient = 1.5
	/// Which eye: "prawe" or "lewe"
	var/side = "prawe"

/datum/wound/pierce/eye/on_apply()
	. = ..()
	name = "Przebite [side] oko"
	examine_desc = "przebite [side] oko, z którego leje się krew"
	var/obj/item/organ/eyes/eyes = victim.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.applyOrganDamage(20)
		eyes.scar_eye()
	victim.adjust_blurriness(20)

/datum/wound/pierce/eye/wound_effects(delta_time)
	if(!treated && DT_PROB(5, delta_time))
		victim.adjust_blurriness(5)
		to_chat(victim, "<span class='danger'>Krew z oka zalewa ci widok!</span>")

/// Puts an eye puncture on the head unless it already has a pierce wound. Returns the wound.
/mob/living/carbon/proc/puncture_eye()
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	if(!head || head.get_wound(WOUND_PIERCE) || !getorganslot(ORGAN_SLOT_EYES) || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	var/datum/wound/pierce/eye/eye_wound = new
	eye_wound.side = pick("prawe", "lewe")
	to_chat(src, "<span class='userdanger'>Przeszywający ból przechodzi przez twoje [eye_wound.side] oko!</span>")
	eye_wound.apply_wound(head)
	return eye_wound

/obj/item/organ/eyes
	/// Scarred by a puncture: near sighted until the eyes are replaced
	var/scarred = FALSE

/obj/item/organ/eyes/proc/scar_eye()
	scarred = TRUE
	owner?.become_nearsighted(EYE_SCAR_TRAIT)

/obj/item/organ/eyes/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(scarred)
		owner?.become_nearsighted(EYE_SCAR_TRAIT)

/obj/item/organ/eyes/Remove(mob/living/carbon/M, special = 0)
	if(scarred)
		M?.cure_nearsighted(EYE_SCAR_TRAIT)
	return ..()

/// Stabbing the eyes can pierce one (tg eyestab)
/obj/item/eyestab(mob/living/carbon/M, mob/living/carbon/user)
	. = ..()
	var/obj/item/organ/eyes/eyes = M?.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && prob(eyes.damage - 9))
		M.puncture_eye()

/// A bullet aimed at the eyes can pierce one (tg)
/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	var/aimed_at_eyes = P?.def_zone == BODY_ZONE_PRECISE_EYES
	. = ..()
	if(aimed_at_eyes && . == BULLET_ACT_HIT && P.wound_kind == WOUND_PIERCE && P.damage >= 10 && !P.nodamage && prob(25))
		puncture_eye()
