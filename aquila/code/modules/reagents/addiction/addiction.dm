// AQUILA - uzależnienia z tgstation (AquilaMed 5, etap 2) zamiast uzależnień Bee.
// Port: code/modules/reagents/withdrawal/_addiction.dm, generic_addictions.dm, code/datums/mind/_mind.dm
// (add/remove_addiction_points), code/modules/reagents/chemistry/holder/mob_life.dm (punkty przy metabolizmie).
// - Reagent ma addiction_types: typ nałogu => ile jednostek trzeba zmetabolizować, żeby się uzależnić.
// - Punkty siedzą w umyśle (idą z postacią do klona), od 600 jest nałóg, poniżej 400 mija. Bez brania spadają z czasem
//   (szybciej w późniejszych etapach), więc nałóg od jednej mocnej dawki sam przechodzi po ok. 20 minutach.
// - Odstawienie: 3 etapy wspólne dla typu, z moodletem, kończy się dawką albo czasem.
// Różnice względem tg: bez nałogów maintenance_drugs i medicine (nie mamy tych leków), efekty przepisane na nasze
// statusy (u nas nie ma high_blood_pressure, woozy, seizure, trance); opioidy w odstawieniu bolą (ból z medycyny 4);
// alkohol uzależnia według mocy trunku; nalokson przyspiesza wyjście z nałogu opioidowego kosztem ostrego odstawienia.
// Stary system Bee (addiction_threshold, addiction_act_stage1-4) jest wyłączony hakiem w code/modules/reagents/chemistry/holder.dm.

#define AQ_ADDICTION_MAX_POINTS 1000
/// Seconds of withdrawal at which each stage starts (tg cycles are seconds)
#define AQ_WITHDRAWAL_STAGE1 61
#define AQ_WITHDRAWAL_STAGE2 121
#define AQ_WITHDRAWAL_STAGE3 181
/// Life ticks every 2 seconds
#define AQ_ADDICTION_TICK 2

GLOBAL_LIST_INIT(aq_addictions, aq_init_addictions())

/proc/aq_init_addictions()
	. = list()
	for(var/path in subtypesof(/datum/addiction))
		.[path] = new path()

/datum/reagent
	/// Addiction kind => units that must be metabolized to get addicted (tg)
	var/list/addiction_types

/// Addiction kinds of this reagent; alcohol by the strength of the drink
/datum/reagent/proc/aq_get_addiction_types()
	return addiction_types

/datum/reagent/consumable/ethanol/aq_get_addiction_types()
	if(addiction_types || boozepwr <= 0)
		return addiction_types
	var/static/list/by_power = list()
	var/key = "[boozepwr]"
	if(!by_power[key])
		by_power[key] = list(/datum/addiction/alcohol = max(10, 2000 / boozepwr)) // piwo (35) ok. 57 j., wódka (65) ok. 31 j.
	return by_power[key]

/// Addiction points for what was metabolized this tick (tg mob_life.dm)
/datum/reagent/proc/aq_add_addiction_points(mob/living/carbon/C)
	var/list/kinds = aq_get_addiction_types()
	if(!length(kinds) || !C.mind)
		return
	for(var/kind in kinds)
		var/datum/addiction/addiction = GLOB.aq_addictions[kind]
		C.mind.aq_add_addiction_points(kind, addiction.gain_threshold * metabolization_rate / kinds[kind])

// --- Umysł ---

/datum/mind
	/// Addiction kind => points
	var/list/aq_addiction_points
	/// Addiction kind => seconds of the current withdrawal
	var/list/aq_active_addictions

/datum/mind/proc/aq_add_addiction_points(kind, amount)
	var/last = LAZYACCESS(aq_addiction_points, kind) || 0
	LAZYSET(aq_addiction_points, kind, min(last + amount, AQ_ADDICTION_MAX_POINTS))
	var/datum/addiction/addiction = GLOB.aq_addictions[kind]
	addiction.on_gain_points(src, aq_addiction_points[kind], last)

/// Returns TRUE if the addiction was lost
/datum/mind/proc/aq_remove_addiction_points(kind, amount)
	var/last = LAZYACCESS(aq_addiction_points, kind) || 0
	var/new_amount = max(last - amount, 0)
	if(new_amount)
		LAZYSET(aq_addiction_points, kind, new_amount)
	else
		LAZYREMOVE(aq_addiction_points, kind)
	var/datum/addiction/addiction = GLOB.aq_addictions[kind]
	return addiction.on_lose_points(src, new_amount, last)

/datum/mind/proc/aq_is_addicted(kind)
	return !isnull(LAZYACCESS(aq_active_addictions, kind))

/datum/mind/proc/aq_clear_addictions()
	for(var/kind in aq_active_addictions)
		var/datum/addiction/addiction = GLOB.aq_addictions[kind]
		if(iscarbon(current))
			addiction.end_withdrawal(current)
	aq_addiction_points = null
	aq_active_addictions = null

/// Lines for the chemical scan of the health analyzer (code/game/objects/items/devices/scanners.dm)
/mob/living/proc/aq_addiction_scan_lines()
	. = list()
	if(!mind || !LAZYLEN(mind.aq_active_addictions))
		. += "<span class='notice'>Pacjent nie jest od niczego uzależniony.</span>"
		return
	. += "<span class='boldannounce'>Pacjent jest uzależniony od:</span>"
	for(var/kind in mind.aq_active_addictions)
		var/datum/addiction/addiction = GLOB.aq_addictions[kind]
		var/cycle = mind.aq_active_addictions[kind]
		var/stage = addiction.withdrawal_stage(cycle)
		. += "<span class='alert'>[capitalize(addiction.name)][stage ? " (odstawienie, etap [stage])" : ""]</span>"

/mob/living/carbon/Life()
	. = ..()
	if(QDELETED(src) || stat == DEAD || !mind || IsInStasis())
		return
	for(var/kind in mind.aq_addiction_points)
		var/datum/addiction/addiction = GLOB.aq_addictions[kind]
		addiction.process_addiction(src, AQ_ADDICTION_TICK)

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	if(admin_revive)
		mind?.aq_clear_addictions()

// --- Nałóg ---

/datum/addiction
	var/name = "nałóg"
	/// Genitive for the moodlet: "Przydałoby mi się trochę [name_genitive]"
	var/name_genitive = "tego"
	/// Points at which the addiction starts and below which it ends
	var/gain_threshold = 600
	var/loss_threshold = 400
	/// Points lost per second without the drug, before and in each stage
	var/list/loss_per_stage = list(0.5, 0.5, 1, 1.5)
	/// Units in the blood that satisfy it (a 1u junkie pill is half metabolised before the check in the same Life)
	var/relief_threshold = 0.5
	var/list/stage_messages = list("", "", "")

/datum/addiction/proc/on_gain_points(datum/mind/victim_mind, new_amount, last_amount)
	if(new_amount < gain_threshold || last_amount >= gain_threshold)
		return
	LAZYSET(victim_mind.aq_active_addictions, type, 1)
	victim_mind.current?.log_message("uzależnił(a) się od: [name].", LOG_GAME)

/datum/addiction/proc/on_lose_points(datum/mind/victim_mind, new_amount, last_amount)
	if(last_amount < loss_threshold || new_amount >= loss_threshold)
		return FALSE
	if(!LAZYACCESS(victim_mind.aq_active_addictions, type)) // tg: never addicted, nothing ends
		return FALSE
	var/mob/living/carbon/C = victim_mind.current
	if(iscarbon(C))
		end_withdrawal(C)
		to_chat(C, "<span class='notice'>Czujesz, że głód [name_genitive] minął.</span>")
	LAZYREMOVE(victim_mind.aq_active_addictions, type)
	return TRUE

/// Is the drug of this addiction in the blood
/datum/addiction/proc/is_satisfied(mob/living/carbon/C)
	for(var/datum/reagent/reagent as anything in C.reagents?.reagent_list)
		if(reagent.volume < relief_threshold)
			continue
		var/list/kinds = reagent.aq_get_addiction_types()
		if(kinds && kinds[type])
			return TRUE
	return FALSE

/datum/addiction/proc/withdrawal_stage(cycle)
	if(cycle >= AQ_WITHDRAWAL_STAGE3)
		return 3
	if(cycle >= AQ_WITHDRAWAL_STAGE2)
		return 2
	if(cycle >= AQ_WITHDRAWAL_STAGE1)
		return 1
	return 0

/datum/addiction/proc/process_addiction(mob/living/carbon/C, delta)
	var/datum/mind/victim_mind = C.mind
	var/cycle = LAZYACCESS(victim_mind.aq_active_addictions, type)
	var/satisfied = is_satisfied(C)
	if(satisfied && cycle > 1) // the drug ends a withdrawal once, it does not "end" it again every tick
		end_withdrawal(C)
		cycle = 1
		LAZYSET(victim_mind.aq_active_addictions, type, 1)
	var/stage = withdrawal_stage(cycle)
	if(!satisfied && victim_mind.aq_remove_addiction_points(type, loss_per_stage[stage + 1] * delta))
		return
	if(!cycle || satisfied)
		return
	if(cycle < AQ_WITHDRAWAL_STAGE1 && cycle + delta >= AQ_WITHDRAWAL_STAGE1)
		enters_stage(C, 1)
	else if(cycle < AQ_WITHDRAWAL_STAGE2 && cycle + delta >= AQ_WITHDRAWAL_STAGE2)
		enters_stage(C, 2)
	else if(cycle < AQ_WITHDRAWAL_STAGE3 && cycle + delta >= AQ_WITHDRAWAL_STAGE3)
		enters_stage(C, 3)
	if(stage)
		stage_process(C, stage, delta)
	LAZYSET(victim_mind.aq_active_addictions, type, cycle + delta)

/datum/addiction/proc/enters_stage(mob/living/carbon/C, stage)
	var/static/list/moodlets = list(/datum/mood_event/withdrawal_light, /datum/mood_event/withdrawal_medium, /datum/mood_event/withdrawal_severe)
	SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", moodlets[stage], name_genitive)

/datum/addiction/proc/stage_process(mob/living/carbon/C, stage, delta)
	if(stage_messages[stage] && prob(5 * stage * delta))
		to_chat(C, "<span class='danger'>[stage_messages[stage]]</span>")

/datum/addiction/proc/end_withdrawal(mob/living/carbon/C)
	if(C.mind && LAZYACCESS(C.mind.aq_active_addictions, type))
		LAZYSET(C.mind.aq_active_addictions, type, 1)
	SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "[type]_addiction")

/datum/addiction/opioids
	name = "opioidy"
	name_genitive = "opioidów"
	stage_messages = list("Bolą mnie wszystkie kości...", "Potrzebuję czegoś na ból...", "Wszystko boli... Potrzebuję opioidów!")

/datum/addiction/opioids/stage_process(mob/living/carbon/C, stage, delta)
	. = ..()
	if(prob(5 * delta))
		C.emote("yawn")
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.aq_withdrawal_pain = stage >= 3 ? 30 : (stage == 2 ? 15 : 0)
	if(stage >= 3 && C.disgust < DISGUST_LEVEL_DISGUSTED && prob(4 * delta))
		C.adjust_disgust(12.5 * delta)

/datum/addiction/opioids/end_withdrawal(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.aq_withdrawal_pain = 0
	C.disgust *= 0.5

/datum/addiction/stimulants
	name = "stymulanty"
	name_genitive = "stymulantów"
	stage_messages = list("Brakuje mi sił... Przydałby się kop.", "Wszystko się rozmywa...", "Oczy... same... się zamykają...")

/datum/addiction/stimulants/enters_stage(mob/living/carbon/C, stage)
	. = ..()
	C.add_movespeed_modifier("aq_stimulant_withdrawal", override = TRUE, multiplicative_slowdown = stage >= 3 ? 0.6 : 0.25)

/datum/addiction/stimulants/stage_process(mob/living/carbon/C, stage, delta)
	. = ..()
	if(stage >= 2)
		C.drowsyness = max(C.drowsyness, stage * 2)

/datum/addiction/stimulants/end_withdrawal(mob/living/carbon/C)
	. = ..()
	C.remove_movespeed_modifier("aq_stimulant_withdrawal")

/datum/addiction/alcohol
	name = "alkohol"
	name_genitive = "alkoholu"
	stage_messages = list("Przydałby się kieliszek...", "Może bar jest jeszcze otwarty?..", "Boże, muszę się napić!")

/datum/addiction/alcohol/stage_process(mob/living/carbon/C, stage, delta)
	. = ..()
	C.Jitter(5 * stage * delta)
	if(stage >= 2)
		C.adjust_hallucinations_up_to(5 SECONDS * delta, 60 SECONDS)
	if(stage >= 3 && prob(2 * delta))
		C.visible_message("<span class='danger'>[C] dostaje drgawek!</span>", "<span class='userdanger'>Całe ciało ci się trzęsie, nie panujesz nad nim!</span>")
		C.Paralyze(4 SECONDS)
		C.Jitter(20)

/datum/addiction/hallucinogens
	name = "halucynogeny"
	name_genitive = "halucynogenów"
	stage_messages = list("W środku jest tylko pustka...", "Ciekawe, co porabiają maszynowe elfy?..", "Muszę znowu zobaczyć te piękne kolory!!")

/datum/addiction/hallucinogens/stage_process(mob/living/carbon/C, stage, delta)
	. = ..()
	if(stage >= 2)
		C.blur_eyes(2 * delta)
	if(stage >= 3)
		C.adjust_hallucinations_up_to(5 SECONDS * delta, 60 SECONDS)
		C.Dizzy(2 * delta)

/datum/addiction/nicotine
	name = "nikotyna"
	name_genitive = "nikotyny"
	relief_threshold = 0.01 // papieros daje mało naraz
	stage_messages = list("Zapaliłoby się...", "Robi mi się nerwowo. Muszę zapalić.", "Nie wytrzymam! Daj mi zapalić, TERAZ!")

/datum/addiction/nicotine/stage_process(mob/living/carbon/C, stage, delta)
	. = ..()
	C.Jitter(5 * stage * delta)
	if(prob(stage * delta))
		C.emote("cough")

// --- Ból z odstawienia opioidów (pain/pain.dm doliczają go do bólu z ciała) ---

/mob/living/carbon/human
	/// Pain of opioid withdrawal
	var/aq_withdrawal_pain = 0

// --- Reagenty ---

/datum/reagent/medicine/morphine
	addiction_types = list(/datum/addiction/opioids = 30)

/datum/reagent/medicine/tramadol
	addiction_types = list(/datum/addiction/opioids = 40)

/datum/reagent/medicine/oxycodone
	addiction_types = list(/datum/addiction/opioids = 20)

/datum/reagent/drug/krokodil
	addiction_types = list(/datum/addiction/opioids = 30)

/datum/reagent/drug/methamphetamine
	addiction_types = list(/datum/addiction/stimulants = 25)

/datum/reagent/drug/crank
	addiction_types = list(/datum/addiction/stimulants = 25)

/datum/reagent/drug/bath_salts
	addiction_types = list(/datum/addiction/stimulants = 25)

/datum/reagent/medicine/ephedrine
	addiction_types = list(/datum/addiction/stimulants = 75)

/datum/reagent/medicine/methylphenidate
	addiction_types = list(/datum/addiction/stimulants = 60)

/datum/reagent/consumable/navy_coffee
	addiction_types = list(/datum/addiction/stimulants = 150)

/// Ordinary coffee is a weak stimulant: the NSV "coffee addict" quirk needs it, a cup now and then never addicts
/datum/reagent/consumable/coffee
	addiction_types = list(/datum/addiction/stimulants = 5)

/datum/reagent/drug/happiness
	addiction_types = list(/datum/addiction/hallucinogens = 30)

/datum/reagent/drug/ketamine
	addiction_types = list(/datum/addiction/hallucinogens = 30)

/datum/reagent/drug/bloody_eye
	addiction_types = list(/datum/addiction/hallucinogens = 20)

/datum/reagent/drug/fartium
	addiction_types = list(/datum/addiction/hallucinogens = 90)

/datum/reagent/drug/nicotine
	addiction_types = list(/datum/addiction/nicotine = 10)

// --- Nalokson ---

/datum/reagent/medicine/naloxone
	name = "Nalokson"
	description = "Odtrutka na opioidy: wypłukuje je z krwi i przerywa przedawkowanie. Uzależnionemu przyspiesza wyjście z nałogu, ale od razu wywołuje ostre odstawienie."
	reagent_state = LIQUID
	color = "#B8D8F0"
	taste_description = "gorzka sól"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/naloxone/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/reagent as anything in M.reagents.reagent_list)
		var/list/kinds = reagent.aq_get_addiction_types()
		if(kinds && kinds[/datum/addiction/opioids])
			M.reagents.remove_reagent(reagent.type, 5)
	if(M.mind?.aq_is_addicted(/datum/addiction/opioids))
		M.mind.aq_remove_addiction_points(/datum/addiction/opioids, 20)
		var/datum/addiction/opioids = GLOB.aq_addictions[/datum/addiction/opioids]
		// With an opioid still in the blood the craving is held off anyway, so no sudden withdrawal every tick
		if(M.mind.aq_is_addicted(/datum/addiction/opioids) && !opioids.is_satisfied(M) && LAZYACCESS(M.mind.aq_active_addictions, /datum/addiction/opioids) < AQ_WITHDRAWAL_STAGE3)
			LAZYSET(M.mind.aq_active_addictions, /datum/addiction/opioids, AQ_WITHDRAWAL_STAGE3 - 1)
			to_chat(M, "<span class='userdanger'>Głód uderza naraz ze wszystkich stron!</span>")
	..()

/datum/chemical_reaction/naloxone
	name = "Nalokson"
	id = /datum/reagent/medicine/naloxone
	results = list(/datum/reagent/medicine/naloxone = 3)
	required_reagents = list(/datum/reagent/medicine/charcoal = 1, /datum/reagent/ammonia = 1, /datum/reagent/oxygen = 1)

/obj/item/reagent_containers/glass/bottle/naloxone
	name = "butelka naloksonu"
	desc = "Odtrutka na opioidy."
	list_reagents = list(/datum/reagent/medicine/naloxone = 30)

/obj/item/reagent_containers/hypospray/medipen/naloxone
	name = "medipen z naloksonem"
	desc = "Autostrzykawka z naloksonem na przedawkowanie opioidów."
	icon_state = "atropen"
	volume = 10
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/naloxone = 10)

// --- Cecha „Ćpun” i palacz z Bee na nowym systemie (pełne nadpisanie on_process, LEGACY_OVERRIDES.md) ---

/datum/quirk/junkie/on_spawn()
	. = ..()
	aq_keep_addicted()

/datum/quirk/junkie/on_process()
	if(world.time <= next_process)
		return
	next_process = world.time + process_interval
	if(aq_keep_addicted())
		to_chat(quirk_holder, "<span class='danger'>Wydawało się, że nałóg minął, ale znowu potrzebujesz dawki [initial(reagent_type.name)]...</span>")

/// Keeps the junkie addicted to the kinds of their drug; TRUE if it had to bring the addiction back
/datum/quirk/junkie/proc/aq_keep_addicted()
	var/datum/mind/junkie_mind = quirk_holder?.mind
	// A clone gets the quirk without on_spawn: a fixed drug (smoker, coffee) is made again from reagent_type
	if(!reagent_instance && reagent_type)
		reagent_instance = new reagent_type()
	var/datum/reagent/drug = reagent_instance
	if(!junkie_mind || !drug)
		return FALSE
	var/list/kinds = drug.aq_get_addiction_types()
	for(var/kind in kinds)
		if(junkie_mind.aq_is_addicted(kind))
			continue
		junkie_mind.aq_add_addiction_points(kind, AQ_ADDICTION_MAX_POINTS)
		. = TRUE

#undef AQ_ADDICTION_MAX_POINTS
#undef AQ_WITHDRAWAL_STAGE1
#undef AQ_WITHDRAWAL_STAGE2
#undef AQ_WITHDRAWAL_STAGE3
#undef AQ_ADDICTION_TICK

/// Lowest addiction threshold of a reagent type for the chem master analysis (units metabolised), 0 = not addictive
/proc/aq_addiction_threshold_of(reagent_type)
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
	var/list/types = reagent?.aq_get_addiction_types() // alcohol computes its threshold from boozepwr
	if(!length(types))
		return 0
	. = INFINITY
	for(var/kind in types)
		. = min(., types[kind])
