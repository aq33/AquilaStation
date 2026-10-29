// AQUILA - port z tgstation (code/datums/mutations/body.dm)

// --- Internal Martyrdom ---

/datum/mutation/martyrdom
	name = "Wewnętrzne męczeństwo"
	desc = "Gdy pacjent jest bliski śmierci, gwałtownie rozrywa się na strzępy. Tego procesu nie da się odwrócić. \
		Nie wiadomo, żeby raniło to kogoś w pobliżu, ale widok jest bardzo, BARDZO oszałamiający."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = "<span class='warning'>Czujesz potworną zgagę.</span>"
	text_lose_indication = "<span class='notice'>Twoje wnętrzności się uspokajają.</span>"
	/// Czy wybuch już zaplanowany
	var/triggered = FALSE

/datum/mutation/martyrdom/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/datum/mutation/martyrdom/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_STATCHANGE)

/datum/mutation/martyrdom/proc/on_stat_change(datum/source, new_stat)
	SIGNAL_HANDLER
	if(triggered)
		return
	// tg: od twardego krytyka. U nas to nieprzytomność poniżej progu pełnego krytyka albo śmierć.
	if(new_stat != DEAD && !(new_stat == UNCONSCIOUS && owner.health <= HEALTH_THRESHOLD_FULLCRIT))
		return
	triggered = TRUE
	// Sygnał idzie przed zmianą statu, więc wybuchamy chwilę później
	addtimer(CALLBACK(src, PROC_REF(bloody_shower), owner), 1)

/datum/mutation/martyrdom/proc/bloody_shower(mob/living/carbon/victim)
	if(QDELETED(victim))
		return
	for(var/obj/item/organ/head_organ in victim.getorganszone(BODY_ZONE_HEAD, TRUE))
		head_organ.Remove(victim, TRUE)
		qdel(head_organ)

	explosion(victim, 0, 0, 2, adminlog = TRUE)
	for(var/mob/living/carbon/human/splashed in view(2, victim))
		if(splashed == victim)
			continue
		var/obj/item/organ/eyes/eyes = splashed.getorganslot(ORGAN_SLOT_EYES)
		if(eyes)
			to_chat(splashed, "<span class='userdanger'>Oślepia cię fontanna krwi!</span>")
			eyes.applyOrganDamage(5)
		else
			to_chat(splashed, "<span class='userdanger'>Przewraca cię fala... krwi?!</span>")
		splashed.Stun(2 SECONDS)
		splashed.set_eye_blur_if_lower(40 SECONDS)
		splashed.adjust_confusion(3 SECONDS)
	for(var/mob/living/silicon/borgo in view(2, victim))
		to_chat(borgo, "<span class='userdanger'>Fontanna krwi oślepia twoje czujniki!</span>")
		borgo.Paralyze(6 SECONDS)
	victim.investigate_log("has been gibbed by the martyrdom mutation.", INVESTIGATE_DEATHS)
	victim.gib()

// --- Hypermetabolic Blood ---

/datum/mutation/bloodier
	name = "Hipermetaboliczna krew"
	desc = "Metabolizm pacjenta gwałtownie przyspiesza, więc wytwarza on krew znacznie szybciej."
	quality = POSITIVE
	instability = 10
	text_gain_indication = "<span class='notice'>Czujesz, jak przyspiesza ci serce.</span>"
	text_lose_indication = "<span class='notice'>Twoje serce zwalnia.</span>"
	difficulty = 16
	synchronizer_coeff = 1
	power_coeff = 1
	/// Mnożnik krwawienia nałożony na physiology
	var/applied_bleed_rate = 0

/datum/mutation/bloodier/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	apply_bleed_rate()

/datum/mutation/bloodier/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	remove_bleed_rate(owner)

/datum/mutation/bloodier/modify()
	. = ..()
	if(!owner)
		return
	remove_bleed_rate(owner)
	apply_bleed_rate()

/datum/mutation/bloodier/proc/apply_bleed_rate()
	if(!ishuman(owner) || applied_bleed_rate)
		return
	var/mob/living/carbon/human/human_owner = owner
	// Synchronizator zmniejsza krwawienie, wzmacniacz je zwiększa (jak w tg)
	applied_bleed_rate = clamp(1.5 * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 1, 2)
	human_owner.physiology.bleed_mod *= applied_bleed_rate

/datum/mutation/bloodier/proc/remove_bleed_rate(mob/living/carbon/target)
	if(!ishuman(target) || !applied_bleed_rate)
		return
	var/mob/living/carbon/human/human_target = target
	human_target.physiology.bleed_mod /= applied_bleed_rate
	applied_bleed_rate = 0

/// tg mnoży odnawianie krwi przez fizjologię. U nas krew dolewamy tu, na tych samych warunkach co handle_blood.
/datum/mutation/bloodier/on_life()
	if(!ishuman(owner) || owner.blood_volume >= BLOOD_VOLUME_NORMAL)
		return
	var/mob/living/carbon/human/human_owner = owner
	if((NOBLOOD in human_owner.dna.species.species_traits) || HAS_TRAIT(human_owner, TRAIT_NO_BLOOD) || HAS_TRAIT(human_owner, TRAIT_NOHUNGER) || HAS_TRAIT(human_owner, TRAIT_HUSK))
		return
	if(human_owner.bodytemperature < TCRYO)
		return
	if(human_owner.nutrition <= NUTRITION_LEVEL_STARVING)
		return
	// Bazowo 0.5 jednostki na tick, tg daje x6 (wzmacniacz więcej)
	var/extra_regen = 0.5 * (clamp(6 * GET_MUTATION_POWER(src), 4, 12) - 1)
	human_owner.blood_volume = min(BLOOD_VOLUME_NORMAL, human_owner.blood_volume + extra_regen)
	human_owner.adjust_nutrition(-extra_regen * 0.4 * HUNGER_FACTOR)

// --- Inexorable ---

/datum/mutation/inexorable
	name = "Nieugiętość"
	desc = "Ciało pacjenta wytrzymuje więcej, niż pozwala zwykła ludzka wytrzymałość, ale odnosi przy tym obrażenia wewnętrzne."
	quality = POSITIVE
	instability = 25
	text_gain_indication = "<span class='notice'>Czujesz się niepowstrzymany.</span>"
	text_lose_indication = "<span class='notice'>Nagle czujesz się bardziej ludzki.</span>"
	difficulty = 24
	synchronizer_coeff = 1
	mutation_traits = list(TRAIT_NOSOFTCRIT, TRAIT_ANALGESIA, TRAIT_IGNOREDAMAGESLOWDOWN)

/datum/mutation/inexorable/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	REMOVE_TRAIT(owner, TRAIT_WHISPER_ONLY, REF(src))

/// Czy właściciel jest w "udawanym" miękkim krytyku (poniżej progu, ale przytomny)
/datum/mutation/inexorable/proc/in_fake_crit()
	return owner.health <= owner.crit_threshold && owner.stat == CONSCIOUS

/datum/mutation/inexorable/on_life()
	// tg: w miękkim krytyku można tylko szeptać
	if(in_fake_crit())
		ADD_TRAIT(owner, TRAIT_WHISPER_ONLY, REF(src))
	else
		REMOVE_TRAIT(owner, TRAIT_WHISPER_ONLY, REF(src))
		return
	if(IS_IN_STASIS(owner))
		return
	if(HAS_TRAIT(owner, TRAIT_NOCRITDAMAGE) && owner.health <= HEALTH_THRESHOLD_FULLCRIT + 10)
		return
	// Około 30 sekund udawanego krytyka
	var/damage = 0.5 * TGMUT_LIFE_SECONDS * GET_MUTATION_SYNCHRONIZER(src)
	if(HAS_TRAIT(owner, TRAIT_TOXIMMUNE) || HAS_TRAIT(owner, TRAIT_TOXINLOVER))
		owner.adjustBruteLoss(damage * 2)
	else
		owner.adjustToxLoss(damage)
		owner.adjustBruteLoss(damage)
	// Częściowo równoważy duszenie się
	owner.adjustOxyLoss(-0.5 * TGMUT_LIFE_SECONDS)

// --- Regeneration ---

/datum/mutation/limb_regeneration
	name = "Regeneracja kończyn"
	desc = "Ciało pacjenta potrafi we śnie odtworzyć utracone kończyny i organy, jeśli ma dość odpoczynku i składników odżywczych."
	quality = POSITIVE
	instability = 25
	text_gain_indication = "<span class='notice'>Czujesz dziwne mrowienie.</span>"
	text_lose_indication = "<span class='notice'>Dziwne mrowienie mija.</span>"
	difficulty = 20
	synchronizer_coeff = 1
	power_coeff = 1
	/// Ile trzeba mieć jedzenia, żeby coś odrosło
	var/nutrition_threshold = NUTRITION_LEVEL_FED * 0.85
	/// Czy już powiedzieliśmy, że ciało próbuje coś odbudować (wtedy większa szansa)
	var/notified_of_ability = FALSE

/datum/mutation/limb_regeneration/on_acquiring(mob/living/carbon/owner)
	if(HAS_TRAIT(owner, TRAIT_NOHUNGER))
		return TRUE
	return ..()

/datum/mutation/limb_regeneration/proc/is_asleep()
	return owner.stat == UNCONSCIOUS || owner.IsSleeping()

/// Brakujące ważne narządy: lista slot = typ narządu
/datum/mutation/limb_regeneration/proc/get_missing_organs(include_appendix)
	. = list()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/datum/species/species = human_owner.dna?.species
	if(!species)
		return
	if(!(NOBLOOD in species.species_traits) && species.mutant_heart && !owner.getorganslot(ORGAN_SLOT_HEART))
		.[ORGAN_SLOT_HEART] = species.mutant_heart
	if(!(TRAIT_NOBREATH in species.inherent_traits) && !owner.getorganslot(ORGAN_SLOT_LUNGS))
		.[ORGAN_SLOT_LUNGS] = species.mutantlungs || /obj/item/organ/lungs
	if(!(TRAIT_NOMETABOLISM in species.inherent_traits) && !owner.getorganslot(ORGAN_SLOT_LIVER))
		.[ORGAN_SLOT_LIVER] = species.mutantliver || /obj/item/organ/liver
	if(!(NOSTOMACH in species.species_traits) && !owner.getorganslot(ORGAN_SLOT_STOMACH))
		.[ORGAN_SLOT_STOMACH] = species.mutantstomach || /obj/item/organ/stomach
	if(species.mutanteyes && !owner.getorganslot(ORGAN_SLOT_EYES))
		.[ORGAN_SLOT_EYES] = species.mutanteyes
	if(species.mutantears && !owner.getorganslot(ORGAN_SLOT_EARS))
		.[ORGAN_SLOT_EARS] = species.mutantears
	if(species.mutanttongue && !owner.getorganslot(ORGAN_SLOT_TONGUE))
		.[ORGAN_SLOT_TONGUE] = species.mutanttongue
	if(include_appendix && !(TRAIT_NOHUNGER in species.inherent_traits) && !owner.getorganslot(ORGAN_SLOT_APPENDIX))
		.[ORGAN_SLOT_APPENDIX] = /obj/item/organ/appendix

/// Brakujące kończyny (bez głowy i tułowia)
/datum/mutation/limb_regeneration/proc/get_missing_regrowable_limbs()
	return owner.get_missing_limbs() - list(BODY_ZONE_HEAD, BODY_ZONE_CHEST)

/datum/mutation/limb_regeneration/on_life()
	if(owner.InFullCritical())
		return
	if(!TGMUT_SPT_PROB(5 * (notified_of_ability ? 4 : 1) * (GET_MUTATION_POWER(src) ** 2)))
		return

	var/list/missing_limbs = get_missing_regrowable_limbs()
	var/list/missing_organs = get_missing_organs(GET_MUTATION_POWER(src) > 1)
	if(!length(missing_limbs) && !length(missing_organs))
		return

	if(owner.nutrition <= nutrition_threshold)
		if(is_asleep() && !notified_of_ability)
			to_chat(owner, "<span class='green'>Czujesz dziwne mrowienie, jakby twoje ciało próbowało coś zrobić... ale chyba najpierw przydałby się posiłek.</span>")
			notified_of_ability = TRUE
		return
	if(!is_asleep())
		if(!notified_of_ability)
			to_chat(owner, "<span class='green'>Czujesz dziwne mrowienie, jakby twoje ciało próbowało coś zrobić... ale chyba najpierw przydałaby się drzemka.</span>")
			notified_of_ability = TRUE
		return

	notified_of_ability = FALSE
	if(length(missing_organs) && (prob(50) || !length(missing_limbs)))
		var/slot = pick(missing_organs)
		var/organ_type = missing_organs[slot]
		var/obj/item/organ/replacement = new organ_type()
		replacement.Insert(owner, TRUE)
		to_chat(owner, "<span class='green'>Mrowienie narasta, aż w końcu czujesz nowy narząd ([replacement.name]) w miejscu starego!</span>")
	else
		var/replacing_zone = pick(missing_limbs)
		owner.regenerate_limb(replacing_zone)
		var/obj/item/bodypart/replacement = owner.get_bodypart(replacing_zone)
		if(!replacement)
			return
		to_chat(owner, "<span class='green'>Mrowienie narasta, aż w końcu czujesz nową kończynę ([replacement.name]) w miejscu starej!</span>")
		owner.visible_message("<span class='warning'>Kończyna [owner] ([replacement.name]) odrasta z głośnym, obrzydliwym chrzęstem!</span>", ignored_mobs = list(owner))
		owner.update_body()
	owner.adjust_nutrition(-NUTRITION_LEVEL_FULL * 0.5 * GET_MUTATION_SYNCHRONIZER(src))
	playsound(owner, 'sound/magic/demon_consume.ogg', 33, TRUE, -5)

// --- Chemical Allergy ---

/datum/mutation/chemical_allergy
	name = "Alergia na chemikalia"
	desc = "Pacjent jest uczulony niemal na wszystkie leki i używki. Wywołują one między innymi chwilowy wzrost niestabilności genetycznej."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Czujesz dziwne swędzenie skóry.</span>"
	text_lose_indication = "<span class='notice'>Swędzenie skóry ustępuje.</span>"
	difficulty = 20
	/// Ile niestabilności daje reakcja alergiczna (tg: połowa ujemnej niestabilności znika)
	var/allergy_instability = 20
	/// Reagenty, które wywołują alergię
	var/static/list/danger_reagents
	/// Czy właśnie trwa reakcja
	var/was_experiencing_allergy = FALSE

/datum/mutation/chemical_allergy/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(length(danger_reagents))
		return
	danger_reagents = typecacheof(list(/datum/reagent/medicine, /datum/reagent/drug)) - typecacheof(list(/datum/reagent/medicine/mannitol, /datum/reagent/medicine/mutadone))

/datum/mutation/chemical_allergy/on_losing(mob/living/carbon/owner)
	if(was_experiencing_allergy)
		was_experiencing_allergy = FALSE
		instability = initial(instability)
	return ..()

/datum/mutation/chemical_allergy/on_life()
	if(!has_danger_reagent())
		if(was_experiencing_allergy)
			was_experiencing_allergy = FALSE
			instability = initial(instability)
			owner.dna.update_instability()
		return
	if(!TGMUT_SPT_PROB(80))
		return
	if(!was_experiencing_allergy)
		was_experiencing_allergy = TRUE
		instability = allergy_instability
		owner.dna.update_instability()

	if(TGMUT_SPT_PROB(66))
		owner.set_stutter_if_lower(4 SECONDS)
	if(TGMUT_SPT_PROB(33))
		owner.adjust_disgust(24)
		owner.adjustToxLoss(pick(2, 3, 4), forced = TRUE)
	if(TGMUT_SPT_PROB(12))
		owner.set_jitter_if_lower(min(owner.jitteriness * 20 + 6 SECONDS, 36 SECONDS))
		owner.set_dizzy_if_lower(min(owner.dizziness * 20 + 6 SECONDS, 36 SECONDS))
		if(owner.blood_volume > BLOOD_VOLUME_OKAY)
			owner.adjust_blood_volume(-pick(12, 16, 20, 24), minimum = BLOOD_VOLUME_OKAY)
	if(TGMUT_SPT_PROB(6))
		owner.set_confusion_if_lower(min(owner.confused * 20 + 4 SECONDS, 12 SECONDS))
		owner.losebreath = max(owner.losebreath, 4)

/datum/mutation/chemical_allergy/proc/has_danger_reagent()
	for(var/datum/reagent/reagent as anything in owner.reagents?.reagent_list)
		if(!is_type_in_typecache(reagent, danger_reagents))
			continue
		if(!reagent.metabolizing || reagent.volume < 1)
			continue
		return TRUE
	return FALSE

// --- Venomous ---

/datum/mutation/venomous_strikes
	name = "Jadowitość"
	desc = "Ciało pacjenta wytwarza słabą toksynę, którą może wstrzyknąć innym przez zadrapania i ugryzienia. \
		Gdy sam się na nią narazi, jego organizm usuwa ją z krwi."
	quality = POSITIVE
	instability = 25
	power_coeff = 1
	text_gain_indication = "<span class='notice'>Twoje zęby i paznokcie wydają się ostrzejsze.</span>"
	text_lose_indication = "<span class='notice'>Twoje zęby i paznokcie wydają się tępsze.</span>"
	/// Jaki reagent wstrzykujemy
	var/venom_type = /datum/reagent/toxin
	/// Ile na jeden cios
	var/venom_amount = 3

/datum/mutation/venomous_strikes/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/mutation/venomous_strikes/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/// tg: element venomous (on hit). U nas sprawdzamy po ciosie, czy cel naprawdę dostał od nas pięścią.
/datum/mutation/venomous_strikes/proc/on_unarmed_attack(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!proximity || !isliving(target) || target == source)
		return
	var/mob/living/living_target = target
	addtimer(CALLBACK(src, PROC_REF(check_hit), living_target, living_target.last_attacked_time), 1)

/datum/mutation/venomous_strikes/proc/check_hit(mob/living/target, old_attack_time)
	if(QDELETED(target) || QDELETED(owner) || target.stat == DEAD || !target.reagents)
		return
	if(target.last_attacked_time == old_attack_time || target.lastattacker != owner.real_name)
		return
	if(!target.can_inject(owner, FALSE, owner.zone_selected))
		return
	target.reagents.add_reagent(venom_type, venom_amount * GET_MUTATION_POWER(src))

/datum/mutation/venomous_strikes/on_life()
	owner.reagents?.remove_reagent(venom_type, round(venom_amount * 0.33, 0.01) * TGMUT_LIFE_SECONDS)
