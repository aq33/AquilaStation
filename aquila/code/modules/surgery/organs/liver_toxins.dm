// AQUILA - port BeeStation/BeeStation-Hornet#14340: nowa wątroba, z obrażeniami od toksyn skalibrowanymi do dawnych (decyzja 16).
// - Toksyna, której w ciele (krew + żołądek) jest nie więcej niż tolerancja wątroby, metabolizuje się w zwykłym tempie,
//   bez efektów i bez szkody dla wątroby. Dawniej znikała po 1 j. na tick, ale w tym czasie działała.
// - Powyżej tolerancji toksyna działa normalnie, a wątroba dostaje obrażenia zależne od ilości i groźności (toxpwr) toksyny.
//   Bee: (ilość / 15) * toxpwr na sekundę, ok. 20 razy więcej niż u nas. Zostaje nasza skala: ilość * toxLethality na tick
//   przy toxpwr zwykłej toksyny (1,5); groźniejsze toksyny bardziej, toksyny bez toxpwr wcale.
// - Tolerancja maleje razem ze zdrowiem wątroby (Bee).
// - Niewydolna wątroba: etapy z Bee co minutę (ból, wymioty, krew, utrata przytomności) zamiast stałych 4 toksyn na tick.
// Core hooks: process_reagents() w /obj/item/organ/liver/on_life() (liver.dm), skip_reagents w metabolize() (holder.dm).

/// toxpwr zwykłej toksyny (/datum/reagent/toxin): przy niej wątroba obrywa tyle co przed portem
#define LIVER_BASELINE_TOXPWR 1.5
/// Najwięcej obrażeń wątroby od toksyn na tick (Bee: 2 na sekundę)
#define LIVER_MAX_TOXIN_DAMAGE 4
/// Co ile sekund niewydolność wątroby przechodzi w kolejny etap (Bee)
#define LIVER_FAILURE_STAGE_SECONDS 60
/// Sekundy na tick Life: nasze on_life() nie dostaje delta_time
#define LIVER_TICK_SECONDS 2

#define HAS_SILENT_TOXIN 0 //don't provide a feedback message if this is the only toxin present
#define HAS_NO_TOXIN 1
#define HAS_PAINFUL_TOXIN 2

/obj/item/organ/liver
	/// Ile sekund wątroba jest już niewydolna (Bee: failure_time)
	var/failure_time = 0

/obj/item/organ/liver/cybernetic/upgraded
	// Bee: 5. Dawne 15 j. przy nowym filtrze znaczyłoby, że pełna strzykawka toksyny w ogóle nie działa
	toxTolerance = 5

/obj/item/organ/liver/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M)
		RegisterSignal(M, COMSIG_PARENT_EXAMINE, PROC_REF(on_owner_examine), override = TRUE)

/obj/item/organ/liver/Remove(mob/living/carbon/M, special = 0)
	if(M)
		UnregisterSignal(M, COMSIG_PARENT_EXAMINE)
	return ..()

/// Filtr toksyn, metabolizm i niewydolność (core hook w /obj/item/organ/liver/on_life())
/obj/item/organ/liver/proc/process_reagents(mob/living/carbon/C)
	if(organ_flags & ORGAN_FAILING)
		C.reagents.end_metabolization(C, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
		C.reagents.metabolize(C, can_overdose = FALSE, liverless = TRUE)
		handle_liver_failure(C)
		return
	// Wraca w tym samym tempie, w jakim narastała (Bee)
	if(failure_time > 0)
		failure_time = max(failure_time - LIVER_TICK_SECONDS, 0)

	var/list/tolerated
	var/liver_damage = 0
	var/provide_pain_message = HAS_NO_TOXIN
	if(filterToxins && !HAS_TRAIT(C, TRAIT_TOXINLOVER))
		var/tolerance = toxTolerance * (maxHealth - damage) / maxHealth
		var/obj/item/organ/stomach/belly = C.getorganslot(ORGAN_SLOT_STOMACH)
		for(var/datum/reagent/toxin/toxin in C.reagents.reagent_list)
			var/amount = toxin.volume
			if(belly?.reagents)
				amount += belly.reagents.get_reagent_amount(toxin.type)
			if(amount <= tolerance)
				LAZYADD(tolerated, toxin)
				continue
			if(!toxin_harms_liver(toxin))
				continue
			liver_damage += amount * toxLethality * toxin.toxpwr / LIVER_BASELINE_TOXPWR
			if(provide_pain_message != HAS_PAINFUL_TOXIN)
				provide_pain_message = toxin.silent_toxin ? HAS_SILENT_TOXIN : HAS_PAINFUL_TOXIN

	// Mała dawka: znika w zwykłym tempie metabolizmu, ale nie działa
	for(var/datum/reagent/toxin/toxin as anything in tolerated)
		C.reagents.remove_reagent(toxin.type, toxin.metabolization_rate * C.metabolism_efficiency)

	C.reagents.metabolize(C, can_overdose = TRUE, skip_reagents = tolerated)

	if(liver_damage > 0)
		applyOrganDamage(min(liver_damage, LIVER_MAX_TOXIN_DAMAGE))

	if(provide_pain_message && damage > 10 && prob(damage/3))//the higher the damage the higher the probability
		to_chat(C, "<span class='warning'>Czujesz tępy ból w brzuchu.</span>")

/// Czy ta toksyna niszczy tę wątrobę
/obj/item/organ/liver/proc/toxin_harms_liver(datum/reagent/toxin/toxin)
	return toxin.toxpwr > 0

/// Plazmaludzie metabolizują plazmę, więc nie niszczy ich kryształu (Bee: TRAIT_PLASMA_LOVER_METABOLISM zeruje toxpwr plazmy)
/obj/item/organ/liver/plasmaman/toxin_harms_liver(datum/reagent/toxin/toxin)
	if(istype(toxin, /datum/reagent/toxin/plasma))
		return FALSE
	return ..()

/// Etapy niewydolności wątroby (Bee: /obj/item/organ/liver/organ_failure()), co LIVER_FAILURE_STAGE_SECONDS sekund cięższe
/obj/item/organ/liver/proc/handle_liver_failure(mob/living/carbon/C)
	if(HAS_TRAIT(C, TRAIT_STABLELIVER))
		return
	failure_time += LIVER_TICK_SECONDS

	switch(failure_time / LIVER_FAILURE_STAGE_SECONDS)
		if(1)
			to_chat(C, span_userdanger("Czujesz kłujący ból w brzuchu!"))
		if(2)
			to_chat(C, span_userdanger("Czujesz palenie w trzewiach!"))
			C.vomit()
		if(3)
			to_chat(C, span_userdanger("Czujesz w gardle palący kwas!"))
			C.vomit(10, TRUE)
		if(4)
			to_chat(C, span_userdanger("Przytłaczający ból pozbawia cię przytomności!"))
			C.vomit(10, TRUE, distance = rand(1, 2))
			C.emote("scream")
			C.AdjustUnconscious(2.5 SECONDS)
		if(5)
			to_chat(C, span_userdanger("Masz wrażenie, że zaraz rozpuszczą ci się wnętrzności!"))
			C.vomit(10, TRUE, distance = rand(1, 3))
			C.emote("scream")
			C.AdjustUnconscious(5 SECONDS)

	// Wartości Bee na sekundę razy 2 s ticku
	switch(failure_time)
		if(1 * LIVER_FAILURE_STAGE_SECONDS to 2 * LIVER_FAILURE_STAGE_SECONDS - 1)
			C.adjustToxLoss(0.4, TRUE, TRUE)
			C.adjust_disgust(0.2)
		if(2 * LIVER_FAILURE_STAGE_SECONDS to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			C.adjustToxLoss(0.8, TRUE, TRUE)
			C.drowsyness = max(C.drowsyness, 1)
			C.adjust_disgust(0.6)
		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			C.adjustToxLoss(1.2, TRUE, TRUE)
			C.adjustOrganLoss(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS), 0.4)
			C.drowsyness = max(C.drowsyness, 2)
			C.adjust_disgust(1.2)
			if(prob(3))
				C.emote("drool")
		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			C.adjustToxLoss(1.6, TRUE, TRUE)
			C.adjustOrganLoss(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_EYES, ORGAN_SLOT_EARS), 1)
			C.drowsyness = max(C.drowsyness, 3)
			C.adjust_disgust(2.4)
			if(prob(6))
				C.emote("drool")

/// Żółte oczy przy niewydolnej wątrobie (Bee: on_owner_examine)
/obj/item/organ/liver/proc/on_owner_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!ishuman(owner) || !(organ_flags & ORGAN_FAILING) || HAS_TRAIT(owner, TRAIT_STABLELIVER))
		return
	var/mob/living/carbon/human/humie_owner = owner
	if(!humie_owner.getorganslot(ORGAN_SLOT_EYES) || humie_owner.is_eyes_covered())
		return
	switch(failure_time)
		if(0 to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_warning("Ta osoba ma lekko pożółkłe białka oczu.")
		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_warning("Ta osoba ma całkiem żółte oczy i widać, że cierpi.")
		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			examine_list += span_boldwarning("Ta osoba ma całkiem żółte, zaropiałe oczy. Nie wygląda, jakby miała długo pożyć.")

#undef LIVER_BASELINE_TOXPWR
#undef LIVER_MAX_TOXIN_DAMAGE
#undef LIVER_FAILURE_STAGE_SECONDS
#undef LIVER_TICK_SECONDS
#undef HAS_SILENT_TOXIN
#undef HAS_NO_TOXIN
#undef HAS_PAINFUL_TOXIN
