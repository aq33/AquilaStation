// Odwrócone (inverse) i nieczyste (impurity) odpowiedniki naszych chemów z tg
// (tgstation@b3949ec362, reagents/impure_reagents/*.dm), przepisane na nasze API (on_mob_life co tick).
// Powstają, gdy nieczysty chem (czystość poniżej inverse_chem_val) trafia do ciała.
// Brak tu odwróceń zależnych od systemów, których nie mamy (np. Corazargh, Monkey Dust) - te zostają przy ogólnym Toxic Monomers.

/////////////////////////////// MEDICINE ///////////////////////////////

/datum/reagent/inverse/neurine
	name = "Neruwhine"
	description = "Wywołuje u pacjenta chwilową traumę mózgu, przekierowując aktywność neuronów."
	color = "#DCDCAA"
	ph = 13.4
	metabolization_rate = 0.0625 * REAGENTS_METABOLISM
	tox_damage = 0
	///The temporary trauma passed to the affected mob
	var/datum/brain_trauma/temp_trauma

/datum/reagent/inverse/neurine/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(temp_trauma)
		return
	if(!prob(creation_purity * 20))
		return
	var/obj/item/organ/brain/brain = M.getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return
	var/static/list/traumalist
	if(!traumalist)
		// only the harmless, self curing kind - no antag, ghost or permanent ones
		traumalist = subtypesof(/datum/brain_trauma/mild) - subtypesof(/datum/brain_trauma/mild/phobia)
	for(var/trauma in shuffle(traumalist))
		temp_trauma = brain.brain_gain_trauma(trauma, TRAUMA_RESILIENCE_MAGIC)
		if(temp_trauma)
			return

/datum/reagent/inverse/neurine/on_mob_delete(mob/living/carbon/M)
	. = ..()
	if(!temp_trauma)
		return
	QDEL_NULL(temp_trauma)

/datum/reagent/inverse/antihol
	name = "Prohol"
	description = "Wzmacnia alkohol w organizmie pacjenta, przez co jego działanie jest silniejsze."
	taste_description = "alkohol" //mostly for sneaky slips
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	color = "#4C8000"
	tox_damage = 0

/datum/reagent/inverse/antihol/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/consumable/ethanol/alcohol in M.reagents.reagent_list)
		alcohol.boozepwr += 2
	return ..()

/datum/reagent/inverse/oculine
	name = "Oculater"
	description = "Tymczasowo oślepia pacjenta."
	color = "#DDDDDD"
	taste_description = "dziwną toksynę"
	ph = 13
	tox_damage = 0
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	///Did we get a headache?
	var/headache = FALSE

/datum/reagent/inverse/oculine/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(headache)
		return
	if(prob(100 * creation_purity))
		M.become_blind("impure_oculine")
		to_chat(M, "<span class='danger'>Nagle dostajesz pulsującego bólu głowy, a obraz ci się rozmywa.</span>")
		headache = TRUE

/datum/reagent/inverse/oculine/on_mob_delete(mob/living/M)
	. = ..()
	M.cure_blind("impure_oculine")
	if(headache)
		to_chat(M, "<span class='notice'>Ból głowy mija!</span>")

/datum/reagent/impurity/inacusiate
	name = "Tinacusiate"
	description = "Sprawia, że pacjent przez chwilę dziwnie słyszy."
	color = "#DDDDFF"
	taste_description = "ciepło parujące z ust"
	ph = 1
	liver_damage = 0.1
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	///The random span we start hearing in
	var/random_span

/datum/reagent/impurity/inacusiate/on_mob_metabolize(mob/living/L)
	. = ..()
	random_span = pick("clown", "small", "big", "hypnophrase", "alien", "cult", "alert", "danger", "emote", "yell", "brass", "sans", "papyrus", "robot")
	RegisterSignal(L, COMSIG_MOVABLE_HEAR, PROC_REF(owner_hear))
	to_chat(L, "<span class='warning'>Coś jest nie tak z twoim słuchem!</span>")

/datum/reagent/impurity/inacusiate/on_mob_end_metabolize(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_MOVABLE_HEAR)
	to_chat(L, "<span class='notice'>Znowu słyszysz normalnie.</span>")

/datum/reagent/impurity/inacusiate/proc/owner_hear(mob/living/owner, list/hearing_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT(owner, TRAIT_DEAF))
		return
	var/list/spans = hearing_args[6] // spans, HEARING_SPANS jest u nas zakomentowane
	var/list/copied_spans = islist(spans) ? spans.Copy() : list()
	copied_spans |= random_span
	hearing_args[6] = copied_spans

/datum/reagent/inverse/oxandrolone
	name = "Oxymetholone"
	description = "Steryd anaboliczny, który pobudza wzrost mięśni w trakcie i po wysiłku."
	color = "#520c23"
	taste_description = "pot"
	overdose_threshold = 25
	ph = 12.2
	tox_damage = 0

/datum/reagent/inverse/oxandrolone/on_mob_life(mob/living/carbon/M)
	if(prob(4))
		to_chat(M, "<span class='notice'>[pick("Czujesz się nie do zatrzymania.", "DAJESZ Z SIEBIE WSZYSTKO!!", "Jesteś gotów na wszystko.", "Masz ochotę zrobić tysiąc pajacyków!")]</span>")
	return ..()

/datum/reagent/inverse/oxandrolone/overdose_process(mob/living/carbon/M)
	. = ..()
	if(prob(40))
		M.adjust_bodytemperature(30 * TEMPERATURE_DAMAGE_COEFFICIENT)
		M.Jitter(6)
		M.adjustStaminaLoss(5, FALSE)
	else if(prob(10))
		M.vomit(0, TRUE, TRUE, 3)
		M.Paralyze(3 SECONDS)

/datum/reagent/inverse/pen_acid
	name = "Pendetide"
	description = "Usuwa podstawowe leki na toksyny i nasila chorobę popromienną."
	color = "#09ff00"
	ph = 3.7
	taste_description = "jad"
	metabolization_rate = 0.0625 * REAGENTS_METABOLISM
	tox_damage = 0

/datum/reagent/inverse/pen_acid/on_mob_life(mob/living/carbon/M)
	holder.remove_reagent(/datum/reagent/medicine/potass_iodide, 40 * REM, TRUE)
	holder.remove_reagent(/datum/reagent/medicine/charcoal, 40 * REM, TRUE)
	if(M.radiation > 0)
		M.radiation += 5
		M.Jitter(10)
		M.adjust_disgust(5)
		if(prob(5))
			to_chat(M, "<span class='warning'>Okropny ból rozlewa się po twoich wnętrznościach!</span>")
			M.confused = clamp(M.confused + 10, 0, 15)
	return ..()

/datum/reagent/inverse/atropine
	name = "Hyoscyamine"
	description = "Powoli regeneruje uszkodzone narządy, ale nie przywróci tych, które przestały działać."
	color = "#273333"
	ph = 13.6
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	tox_damage = 0
	overdose_threshold = 40

/datum/reagent/inverse/atropine/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, -2)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, -2)
	if(M.getToxLoss() <= 25)
		M.adjustToxLoss(-1, FALSE)
	..()
	return TRUE

/datum/reagent/inverse/atropine/overdose_process(mob/living/carbon/M)
	. = ..()
	var/static/list/possible_organs = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_TONGUE,
	)
	M.adjustOrganLoss(pick(possible_organs), 4)
	holder.remove_reagent(type, 2, TRUE)

/datum/reagent/inverse/rezadone
	name = "Inreziniver"
	description = "Wywołuje u pacjenta okropny strach przed pająkami."
	color = "#c92eb4"
	ph = 13.9
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	tox_damage = 0

/datum/reagent/inverse/rezadone/on_mob_metabolize(mob/living/carbon/M)
	. = ..()
	if(iscarbon(M))
		M.gain_trauma(/datum/brain_trauma/mild/phobia/spiders, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/inverse/rezadone/on_mob_end_metabolize(mob/living/carbon/M)
	. = ..()
	if(iscarbon(M))
		M.cure_trauma_type(/datum/brain_trauma/mild/phobia/spiders, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/inverse/sal_acid
	name = "Benzoic Acid"
	description = "Silny nawóz, który daje roślinom sporo korzyści."
	taste_description = "kwiaty"
	color = "#e6c843"
	ph = 3.4
	tox_damage = 0

/datum/reagent/inverse/aranesp
	name = "Epoetin Alfa"
	description = "Syntetyczny lek, który pobudza odnowę krwi. Przy nadużyciu powoduje uszkodzenie serca i migreny."
	color = "#dee4ff"
	metabolization_rate = 0.625 * REAGENTS_METABOLISM
	overdose_threshold = 20
	ph = 6.1
	tox_damage = 0

/datum/reagent/inverse/aranesp/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(overdosed)
		return
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = min(M.blood_volume + 3.2, BLOOD_VOLUME_NORMAL)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.32)
	switch(current_cycle)
		if(10)
			to_chat(M, "<span class='warning'>Czujesz nadchodzącą migrenę...</span>")
			M.blur_eyes(2)
		if(15 to 30)
			if(prob(10))
				to_chat(M, "<span class='warning'>Boli cię głowa, a obraz się rozmywa.</span>")
				M.blur_eyes(4)
			if(prob(10))
				to_chat(M, "<span class='warning'>Twarz wykrzywia ci nagły ból głowy.</span>")
				M.Stun(1 SECONDS)
		if(31 to INFINITY)
			if(prob(10))
				to_chat(M, "<span class='warning'>Głowa ci pęka, prawie nic nie widzisz!</span>")
				M.blur_eyes(8)
				M.confused = clamp(M.confused + 5, 0, 20)
				M.hallucination += 10
			if(prob(10))
				to_chat(M, "<span class='warning'>Coraz trudniej ci oddychać!</span>")
				holder.add_reagent(/datum/reagent/toxin/histamine, 3.2)

/datum/reagent/inverse/aranesp/overdose_process(mob/living/carbon/M)
	. = ..()
	if(prob(20))
		to_chat(M, "<span class='warning'>Masz wrażenie, że głowa ci zaraz implodouje!</span>")
		M.blur_eyes(8)
		M.confused = clamp(M.confused + 10, 0, 20)
		M.hallucination += 30
	if(prob(20))
		to_chat(M, "<span class='warning'>Oddychasz słabo i chrapliwie, ledwo jesteś przytomny!</span>")
		holder.add_reagent(/datum/reagent/toxin/histamine, 4.8)
		M.losebreath += 3

/datum/reagent/inverse/happiness
	name = "Sadness"
	description = "Wywołuje silne stany depresyjne i usuwa z organizmu inne antydepresanty."
	color = "#0004ff"
	ph = 12
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	tox_damage = 0

/datum/reagent/inverse/happiness/on_mob_metabolize(mob/living/L)
	. = ..()
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "sadness_inverse", /datum/mood_event/sadness_inverse)
	if(volume >= 1)
		L.say("Co?? Nie... NIE...", forced = type)

/datum/reagent/inverse/happiness/on_mob_end_metabolize(mob/living/L)
	. = ..()
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "sadness_inverse")

/datum/reagent/inverse/happiness/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(method == TOUCH || method == VAPOR)
		M.emote("cry")

/datum/reagent/inverse/happiness/on_mob_life(mob/living/carbon/M)
	holder.remove_reagent(/datum/reagent/drug/happiness, 20 * REM, TRUE)
	holder.remove_reagent(/datum/reagent/medicine/psicodine, 20 * REM, TRUE)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	if(mood)
		mood.setSanity(max(mood.sanity - 26, SANITY_INSANE))
		if(mood.sanity < SANITY_CRAZY)
			M.drowsyness = min(M.drowsyness + 3, 15)
			if(prob(40))
				M.emote(pick("cry", "frown", "sigh"))
			if(prob(6))
				M.say(pick("Po co my w ogóle tu jesteśmy? Żeby cierpieć?", "Żyć to cierpieć!", "Życie to cierpienie. Taka jest natura istnienia!", "Każdy dzień przybliża nas do śmierci."), forced = type)
	return ..()

/datum/mood_event/sadness_inverse
	description = "<span class='boldwarning'>Nie ma nadziei... Wszystko jest bez sensu.</span>\n"
	mood_change = -20

/datum/reagent/inverse/colorful_reagent
	name = "Dulling Reagent"
	description = "Wyjątkowo szary barwnik, ulubiony przez korporacje, które chcą zmaksymalizować cierpienie."
	color = "#808080"
	ph = 10
	metabolization_rate = REAGENTS_METABOLISM
	tox_damage = 0
	/// Used when applying colors on valid things
	var/list/random_color_list = list("#1a1a1a", "#2e2e2e", "#424242", "#565656", "#6a6a6a", "#7e7e7e", "#929292", "#a6a6a6", "#bababa", "#cecece")

/datum/reagent/inverse/colorful_reagent/on_mob_life(mob/living/carbon/M)
	M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	return ..()

/datum/reagent/inverse/colorful_reagent/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	return ..()

/datum/reagent/inverse/colorful_reagent/reaction_obj(obj/O, reac_volume)
	O?.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)

/datum/reagent/inverse/colorful_reagent/reaction_turf(turf/T, reac_volume)
	T?.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)

/////////////////////////////// TOXINS ///////////////////////////////

/datum/reagent/impurity/ipecacide
	name = "Ipecacide"
	description = "Wyjątkowo obrzydliwa substancja, która wywołuje wymioty. Powstaje w nieczystych reakcjach lipolicydu."
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/ipecacide/on_mob_add(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.disgust < DISGUST_LEVEL_GROSS)
			C.adjust_disgust(50)

/datum/reagent/impurity/methanol
	name = "Methanol"
	description = "Lekka, bezbarwna ciecz o wyraźnym zapachu. Spożycie może prowadzić do ślepoty. Powstaje przy rozkładzie nieczystego formaldehydu."
	color = "#aae7e4"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/methanol/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_EYES, 0.5)
	return ..()

/datum/reagent/impurity/chloralax
	name = "Chloralax"
	description = "Oleista, bezbarwna i lekko toksyczna ciecz. Powstaje, gdy organizm rozkłada nieczysty wodzian chloralu."
	color = "#387774"
	ph = 7
	liver_damage = 0

/datum/reagent/impurity/chloralax/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, FALSE)
	..()
	return TRUE

/datum/reagent/impurity/rosenol
	name = "Rosenol"
	description = "Dziwna niebieska ciecz powstająca w nieczystych reakcjach mindbreakera. Kiedyś nadużywana do pisania poezji."
	color = "#0963ad"
	ph = 7
	liver_damage = 0
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/impurity/rosenol/on_mob_life(mob/living/carbon/M)
	if(M.getorganslot(ORGAN_SLOT_TONGUE))
		if(prob(8))
			M.visible_message("<span class='emote'><b>[M]</b> cmoka językiem.</span>")
			M.say("Pycha.", forced = type)
		if(prob(4))
			M.say(pick("Ach! To był błąd!", "Okropne.", "Uwaga wszyscy, ziemniak jest naprawdę gorący.", "Jak miałem sześć lat, zjadłem worek śliwek.", "A jeśli czegoś nie znoszę, to pomidorów.", "A jeśli coś kocham, to pomidory."), forced = type)
	return ..()
