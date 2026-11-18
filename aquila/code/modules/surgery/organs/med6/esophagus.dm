// AQUILA - przełyk (AquilaMed 6, etap 2). Projekt własny: Skyrat13 ma tylko slot ORGAN_SLOT_ESOPHAGUS bez narządu.
// - Bez przełyku albo z niewydolnym nie da się nic zjeść ani wypić.
// - Każdy kęs może utknąć: rzadko, częściej na leżąco i przy uszkodzonym przełyku. Zadławiony nie oddycha i nie mówi.
//   Sam czasem wykaszle kęs, a ktoś obok ratuje go kliknięciem w klatkę bez trybu walki (chwyt Heimlicha).
// - Uszkadzają go połknięte kwasy i krwawe wymioty, goi się sam jak inne narządy.

#define AQ_CHOKING_TRAIT "aq_choking"

/obj/item/organ/esophagus
	name = "przełyk"
	desc = "Mięśniowa rura z gardła do żołądka. Bez niej nic nie da się przełknąć."
	icon = 'aquila/icons/obj/medical/organs_med6.dmi'
	icon_state = "esophagus"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_ESOPHAGUS
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold_passed = "<span class='info'>Przełykanie trochę piecze.</span>"
	high_threshold_passed = "<span class='warning'>Każdy łyk pali cię w piersi.</span>"
	now_failing = "<span class='danger'>Nie jesteś w stanie niczego przełknąć.</span>"
	now_fixed = "<span class='info'>Przełykanie przestaje boleć.</span>"

/obj/item/organ/esophagus/aq_scan_line()
	if(owner?.has_status_effect(/datum/status_effect/aq_choking))
		return "<b>Zadławienie:</b> kęs utknął w przełyku. Chwyt Heimlicha: kliknij klatkę piersiową bez trybu walki."
	if(organ_flags & ORGAN_FAILING)
		return "<b>Zniszczony przełyk:</b> pacjent nie może jeść ani pić. Wymień przełyk."

/// Can this body swallow at all
/mob/living/carbon/proc/aq_can_swallow()
	var/mob/living/carbon/human/H = src
	if(!istype(H) || !H.dna?.species?.mutantesophagus || !H.dna.species.aq_has_med5_organs())
		return TRUE
	if(has_status_effect(/datum/status_effect/aq_choking))
		return FALSE
	var/obj/item/organ/esophagus/esophagus = getorganslot(ORGAN_SLOT_ESOPHAGUS)
	return esophagus && !(esophagus.organ_flags & ORGAN_FAILING)

/// Chance in percent that a bite gets stuck
/mob/living/carbon/proc/aq_choke_chance()
	var/obj/item/organ/esophagus/esophagus = getorganslot(ORGAN_SLOT_ESOPHAGUS)
	if(!esophagus)
		return 0
	. = 0.5
	if(!(mobility_flags & MOBILITY_STAND))
		. += 8
	. += 20 * esophagus.damage / esophagus.maxHealth

/mob/living/carbon/proc/aq_swallow_refusal(mob/living/feeder)
	if(has_status_effect(/datum/status_effect/aq_choking))
		to_chat(feeder, "<span class='warning'>[feeder == src ? "Dławisz się, nie przełkniesz teraz niczego!" : "[src] dławi się, nie przełknie teraz niczego!"]</span>")
	else
		to_chat(feeder, "<span class='warning'>[feeder == src ? "Nie jesteś w stanie niczego przełknąć." : "[src] nie jest w stanie niczego przełknąć."]</span>")

/datum/component/edible/CanConsume(mob/living/eater, mob/living/feeder)
	. = ..()
	if(!. || !iscarbon(eater))
		return
	var/mob/living/carbon/C = eater
	if(!C.aq_can_swallow())
		C.aq_swallow_refusal(feeder || eater)
		return FALSE

/datum/component/edible/TakeBite(mob/living/eater, mob/living/feeder)
	. = ..()
	if(!. || !iscarbon(eater) || QDELETED(eater))
		return
	var/mob/living/carbon/C = eater
	var/mob/living/carbon/human/H = C
	if(istype(H) && H.dna?.species?.aq_has_med5_organs() && prob(C.aq_choke_chance()))
		C.apply_status_effect(/datum/status_effect/aq_choking)

/obj/item/reagent_containers/canconsume(mob/eater, mob/user)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/C = eater
	if(!C.aq_can_swallow())
		C.aq_swallow_refusal(user || eater)
		return FALSE

/// Swallowed acid burns the esophagus
/datum/reagent/toxin/acid/reaction_mob(mob/living/carbon/C, method = TOUCH, reac_volume)
	. = ..()
	if(method != INGEST || !istype(C))
		return
	var/obj/item/organ/esophagus/esophagus = C.getorganslot(ORGAN_SLOT_ESOPHAGUS)
	esophagus?.applyOrganDamage(min(20, reac_volume * toxpwr))

/// Vomiting blood tears the esophagus a little
/mob/living/carbon/vomit(lost_nutrition = 10, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, toxic = FALSE)
	. = ..()
	if(. && blood && has_mouth() && !HAS_TRAIT(src, TRAIT_NOHUNGER) && !HAS_TRAIT(src, TRAIT_NOVOMIT))
		var/obj/item/organ/esophagus/esophagus = getorganslot(ORGAN_SLOT_ESOPHAGUS)
		esophagus?.applyOrganDamage(2)

// --- Zadławienie ---

/datum/status_effect/aq_choking
	id = "aq_choking"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/aq_choking

/atom/movable/screen/alert/status_effect/aq_choking
	name = "Zadławienie"
	desc = "Kęs utknął ci w gardle. Nie możesz oddychać ani mówić. Ktoś musi uderzyć cię w plecy albo zrobić chwyt Heimlicha."
	icon_state = "asleep"

/datum/status_effect/aq_choking/on_apply()
	ADD_TRAIT(owner, TRAIT_MUTE, AQ_CHOKING_TRAIT)
	owner.visible_message("<span class='danger'>[owner] łapie się za gardło i nie może złapać tchu!</span>", "<span class='userdanger'>Kęs staje ci w gardle! Nie możesz oddychać!</span>")
	return TRUE

/datum/status_effect/aq_choking/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MUTE, AQ_CHOKING_TRAIT)

/datum/status_effect/aq_choking/tick()
	if(owner.stat == DEAD) // po wskrzeszeniu ciało nie dusi się dalej od tego samego kęsa
		qdel(src)
		return
	var/mob/living/carbon/C = owner
	if(istype(C))
		C.losebreath = max(C.losebreath, 3)
	if(prob(owner.stat == CONSCIOUS ? 4 : 1))
		cough_out()
		return
	if(owner.stat == CONSCIOUS && prob(30))
		owner.emote("gasp")

/mob/living/fully_heal(admin_revive = 0)
	. = ..()
	remove_status_effect(/datum/status_effect/aq_choking)

/datum/status_effect/aq_choking/proc/cough_out(mob/living/helper)
	if(helper)
		owner.visible_message("<span class='notice'>[helper] wypycha kęs z gardła [owner]!</span>", "<span class='notice'>[helper] wypycha ci kęs z gardła. Możesz oddychać!</span>")
	else
		owner.visible_message("<span class='notice'>[owner] wykasłuje kęs, który utknął w gardle.</span>", "<span class='notice'>Wykasłujesz kęs. Możesz oddychać!</span>")
	qdel(src)

/// Heimlich manoeuvre: a help click on the chest of someone who chokes
/datum/species/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style?.help_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	var/datum/status_effect/aq_choking/choking = target?.has_status_effect(/datum/status_effect/aq_choking)
	if(!choking || user == target || user.zone_selected != BODY_ZONE_CHEST)
		return ..(user, target, null)
	user.visible_message("<span class='notice'>[user] obejmuje [target] od tyłu i mocno uciska brzuch.</span>", "<span class='notice'>Obejmujesz [target] od tyłu i uciskasz brzuch.</span>")
	if(!do_after(user, 2 SECONDS, target = target))
		return TRUE
	if(QDELETED(choking))
		return TRUE
	if(prob(60))
		choking.cough_out(user)
	else
		to_chat(user, "<span class='warning'>Kęs nie chce wyjść, spróbuj jeszcze raz.</span>")
	return TRUE

#undef AQ_CHOKING_TRAIT
