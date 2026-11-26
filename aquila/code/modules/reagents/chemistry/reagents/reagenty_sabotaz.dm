// AQUILA - reagenty z przeglądu 246 kodów (raport/reagenty_02_plan_portu.md), grupa sabotaz.
// C. Sabotaż i elektronika: Obskurytol, Fulguracyna (Polaris YW), Rozrusznik radiomagnetyczny (Monke), Kardoks (Aurora).
// D. Sterowanie lekami: Malaksytol (Polaris YW), Enzym wzmacniający, Polimer glukozy (Goon), Kordiolis hepatyczny (tg).
// Receptury poza Rozrusznikiem (Monke) i Enzymem (Goon, bez wodoru, tlenu i węgla, bo te trzy z etanolem to morfina) są nasze:
// oryginały Polaris to losowe odczynniki z ksenoarcheologii, Kardoks potrzebuje platyny i sterylizyny, których nie mamy,
// a Kordiolis w tg nie ma receptury.

/// Najwięcej jednostek leku, które Enzym wzmacniający uzupełnia (Goon: 18)
#define BOOSTER_ENZYME_MAX_VOLUME 18
/// Ile sekund uwalniania daje 1 j. Polimeru glukozy w tabletce
#define GLUCOSE_POLYMER_SECONDS_PER_UNIT 12

// --- C. Sabotaż i elektronika ---

/datum/reagent/obscuritol
	name = "Obskurytol"
	description = "Czarna ciecz o dziwnych właściwościach elektromagnetycznych. Wylana tłucze pobliskie lampy, a dalsze zaczynają migać."
	reagent_state = LIQUID
	color = "#1A1A2E"
	taste_description = "elektryczność"

// Polaris: tłucze lampy w promieniu ceil(j./10), miga w promieniu ceil(j./6). U nas z limitem, żeby jedna zlewka nie gasiła pokładu.
/datum/reagent/obscuritol/reaction_turf(turf/T, reac_volume)
	if(!istype(T) || reac_volume < 1)
		return
	var/break_range = min(CEILING(reac_volume / 10, 1), 4)
	var/flicker_range = min(CEILING(reac_volume / 6, 1), 7)
	for(var/obj/machinery/light/lamp in range(break_range, T))
		lamp.break_light_tube()
	for(var/obj/machinery/light/lamp in range(flicker_range, T))
		lamp.flicker()

/datum/chemical_reaction/obscuritol
	name = "Obskurytol"
	id = /datum/reagent/obscuritol
	results = list(/datum/reagent/obscuritol = 3)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/silver = 1, /datum/reagent/carbon = 1)

/datum/reagent/toxin/radiomagnetic_disruptor
	name = "Rozrusznik radiomagnetyczny"
	description = "Toksyczny związek, który szybko niszczy nanity w ciele i wywołuje słabe, bardzo lokalne impulsy EMP."
	color = "#1D5A1A"
	taste_description = "fale radiowe"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20
	self_consuming = TRUE
	toxpwr = 1
	/// Ile nanitów niszczy na tick (Monke: 10 na sekundę, u nas tick to 2 s)
	var/purge_rate = 20

/datum/reagent/toxin/radiomagnetic_disruptor/on_mob_life(mob/living/carbon/M)
	SEND_SIGNAL(M, COMSIG_NANITE_ADJUST_VOLUME, -(overdosed ? purge_rate * 2 : purge_rate))
	if(prob(4))
		empulse(get_turf(M), 0, 1)
	return ..()

/datum/reagent/toxin/radiomagnetic_disruptor/overdose_process(mob/living/M)
	if(prob(8))
		empulse(get_turf(M), 1, 1)
	..()

/datum/chemical_reaction/radiomagnetic_disruptor
	name = "Rozrusznik radiomagnetyczny"
	id = /datum/reagent/toxin/radiomagnetic_disruptor
	results = list(/datum/reagent/toxin/radiomagnetic_disruptor = 2)
	required_reagents = list(/datum/reagent/thermite = 1, /datum/reagent/uranium/radium = 1)

/datum/reagent/fulguracin
	name = "Fulguracyna"
	description = "Silny inhibitor przewodnictwa. Na skórze nic nie robi, ale wylana na cyborga albo syntetyka pali jego układy."
	reagent_state = LIQUID
	color = "#C0D8FF"
	taste_description = "metal i ozon"
	process_flags = ORGANIC | SYNTHETIC // inaczej reaction_check() nie pokaże jej IPC
	/// Najwięcej obrażeń od jednego oblania
	var/max_damage = 30

// Polaris: oparzenia równe połowie objętości, u syntetyków i silikonów
/datum/reagent/fulguracin/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	if(!istype(M) || !(method in list(TOUCH, VAPOR)) || !(MOB_ROBOTIC in M.mob_biotypes))
		return ..()
	var/damage = min(reac_volume / 2, max_damage) * (1 - touch_protection)
	if(damage > 0)
		M.adjustFireLoss(damage)
		if(show_message)
			to_chat(M, "<span class='warning'>Część twoich układów zgłasza uszkodzenia od cieczy.</span>")
	return ..()

/datum/chemical_reaction/fulguracin
	name = "Fulguracyna"
	id = /datum/reagent/fulguracin
	results = list(/datum/reagent/fulguracin = 3)
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/copper = 1, /datum/reagent/toxin/acid = 1)

/datum/reagent/toxin/cardox
	name = "Kardoks"
	description = "Lekko toksyczny środek czyszczący. Wiąże plazmę z powietrza, na które go wylano, i rozpuszcza szlamy."
	color = "#B0B0B0"
	taste_description = "gorzki metal"
	toxpwr = 0.5
	/// Ile moli plazmy wiąże 1 j. (Aurora: 10)
	var/moles_per_unit = 10
	/// Ile obrażeń toksycznych dostaje szlam od 1 j. (Aurora: 10)
	var/slime_damage_per_unit = 10

/datum/reagent/toxin/cardox/reaction_turf(turf/T, reac_volume)
	var/turf/open/floor = T
	if(!istype(floor) || !floor.air || reac_volume <= 0)
		return
	var/datum/gas_mixture/air = floor.air
	var/to_bind = reac_volume * moles_per_unit
	var/plasma = min(to_bind, air.get_moles(GAS_PLASMA))
	if(plasma > 0)
		air.adjust_moles(GAS_PLASMA, -plasma)
	var/constricted = min(to_bind - plasma, air.get_moles(GAS_CONSTRICTED_PLASMA))
	if(constricted > 0)
		air.adjust_moles(GAS_CONSTRICTED_PLASMA, -constricted)

/datum/reagent/toxin/cardox/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	if(isslime(M) && reac_volume >= 1)
		M.adjustToxLoss(reac_volume * slime_damage_per_unit)
	return ..()

/datum/chemical_reaction/cardox
	name = "Kardoks"
	id = /datum/reagent/toxin/cardox
	results = list(/datum/reagent/toxin/cardox = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/gold = 1, /datum/reagent/space_cleaner = 1)

// --- D. Sterowanie lekami ---

/// Ile reagentu ubywa na tick z samego metabolizmu: zwykle rate * metabolism_efficiency (reagents.dm),
/// leki odwrotnie, rate / metabolism_efficiency, bo najedzony organizm dłużej je trzyma (medicine_reagents.dm)
/datum/reagent/proc/aq_metabolized_per_tick(mob/living/carbon/M)
	return metabolization_rate * M.metabolism_efficiency

/datum/reagent/medicine/aq_metabolized_per_tick(mob/living/carbon/M)
	return metabolization_rate / M.metabolism_efficiency

/datum/reagent/malaxitol
	name = "Malaksytol"
	description = "Przyspiesza przemianę materii: wszystkie inne związki we krwi rozkładają się dwa razy szybciej. Przedawkowanie wywołuje drżenie i głód."
	reagent_state = LIQUID
	color = "#FFB347"
	taste_description = "pieprz"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

// Polaris woła drugi raz on_mob_life() innych reagentów (dwa razy więcej działania). U nas tylko szybszy rozkład, bez podwójnego efektu.
/datum/reagent/malaxitol/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/other as anything in M.reagents.reagent_list.Copy())
		if(other == src || other.holder != M.reagents || other.metabolization_rate <= 0)
			continue
		M.reagents.remove_reagent(other.type, other.aq_metabolized_per_tick(M))
	return ..()

/datum/reagent/malaxitol/overdose_process(mob/living/M)
	M.Jitter(3)
	M.adjust_nutrition(-2)
	..()

/datum/chemical_reaction/malaxitol
	name = "Malaksytol"
	id = /datum/reagent/malaxitol
	results = list(/datum/reagent/malaxitol = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/phosphorus = 1, /datum/reagent/toxin/plasma = 1)

/datum/reagent/medicine/booster_enzyme
	name = "Enzym wzmacniający"
	description = "Enzym, który pomaga organizmowi odtwarzać leki już obecne we krwi, więc działają dłużej. Nie odtwarza leków ponad próg przedawkowania."
	reagent_state = LIQUID
	color = "#7FA0C0"
	taste_description = "drożdże"
	metabolization_rate = REAGENTS_METABOLISM
	overdose_threshold = 20

/// Czy enzym odtwarza ten lek
/datum/reagent/medicine/booster_enzyme/proc/can_boost(datum/reagent/medicine/drug)
	if(drug == src || drug.metabolization_rate <= 0)
		return FALSE
	if(istype(drug, /datum/reagent/medicine/booster_enzyme) || istype(drug, /datum/reagent/medicine/adminordrazine) || istype(drug, /datum/reagent/medicine/strange_reagent))
		return FALSE
	return TRUE

// Goon: 19 leków z listy dostaje co tick tyle, ile się zużyło, do 18 j. U nas każdy lek (/datum/reagent/medicine), poniżej progu przedawkowania.
/datum/reagent/medicine/booster_enzyme/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/medicine/drug in M.reagents.reagent_list.Copy())
		if(drug.holder != M.reagents || !can_boost(drug) || drug.volume >= BOOSTER_ENZYME_MAX_VOLUME)
			continue
		var/amount = min(drug.aq_metabolized_per_tick(M), BOOSTER_ENZYME_MAX_VOLUME - drug.volume)
		if(drug.overdose_threshold && drug.volume + amount >= drug.overdose_threshold)
			continue
		M.reagents.add_reagent(drug.type, amount, reagtemp = M.reagents.chem_temp, no_react = TRUE, added_purity = drug.purity)
	return ..()

/datum/reagent/medicine/booster_enzyme/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	if(prob(10) && iscarbon(M))
		var/mob/living/carbon/C = M
		C.vomit(10)
	..()
	return TRUE

/datum/chemical_reaction/booster_enzyme
	name = "Enzym wzmacniający"
	id = /datum/reagent/medicine/booster_enzyme
	results = list(/datum/reagent/medicine/booster_enzyme = 4)
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/sulfur = 1, /datum/reagent/medicine/strange_reagent = 1)
	required_temp = 373

/datum/reagent/consumable/glucose_polymer
	name = "Polimer glukozy"
	description = "Płynny polimer glukozy. Tabletka, w której jest, rozpuszcza się w żołądku powoli i uwalnia resztę zawartości przez kilka minut."
	color = "#C8C8C8"
	taste_description = "mdła słodycz"
	nutriment_factor = 1 * REAGENTS_METABOLISM

/datum/chemical_reaction/glucose_polymer
	name = "Polimer glukozy"
	id = /datum/reagent/consumable/glucose_polymer
	results = list(/datum/reagent/consumable/glucose_polymer = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/glycerol = 1)

// Goon: zamrożony polimer zamyka w sobie resztę zawartości i oddaje ją w ciele stopniowo. U nas bez zamrażania:
// połknięta tabletka z polimerem oddaje resztę zawartości do żołądka po równo, 12 s na każdą jednostkę polimeru (1–5 minut).
/obj/item/reagent_containers/pill/attack(mob/M, mob/user, obj/item/bodypart/affecting)
	var/polymer = reagents?.get_reagent_amount(/datum/reagent/consumable/glucose_polymer)
	if(!polymer || apply_type != INGEST || !iscarbon(M) || reagents.total_volume <= polymer)
		return ..()
	var/mob/living/carbon/eater = M
	// Bez żołądka (choć powinien być) wszystko i tak wraca, więc niech core zrobi to jak zwykle
	if(!eater.getorganslot(ORGAN_SLOT_STOMACH) && eater.needs_stomach())
		return ..()
	// Reszta zawartości czeka w schowku, a core połyka sam polimer. Gdy połknięcie się nie uda, wraca do tabletki.
	var/datum/reagents/stash = new(reagents.maximum_volume)
	stash.flags |= NO_REACT
	reagents.remove_reagent(/datum/reagent/consumable/glucose_polymer, polymer)
	reagents.trans_to(stash, reagents.total_volume, no_react = TRUE)
	reagents.add_reagent(/datum/reagent/consumable/glucose_polymer, polymer, no_react = TRUE)
	. = ..()
	if(!.)
		if(!QDELETED(src))
			stash.trans_to(src, stash.total_volume, no_react = TRUE)
		qdel(stash)
		return
	var/release_time = clamp(polymer * GLUCOSE_POLYMER_SECONDS_PER_UNIT, 60, 300) SECONDS
	eater.apply_status_effect(/datum/status_effect/aq_extended_release, stash, release_time)

/// Tabletka z Polimerem glukozy w żołądku: oddaje schowaną zawartość po równo przez release_time
/datum/status_effect/aq_extended_release
	id = "aq_extended_release"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	duration = -1
	tick_interval = 2 SECONDS
	/// Zawartość tabletki, która jeszcze się nie uwolniła
	var/datum/reagents/stash
	/// Ile jednostek uwalnia się na tick
	var/per_tick = 0
	/// Uwolnione, ale jeszcze nieprzelane: holder odrzuca porcje reagentu poniżej CHEMICAL_VOLUME_ROUNDING (0,01 j.), więc drobne porcje czekają, aż urosną
	var/pending = 0

/datum/status_effect/aq_extended_release/on_creation(mob/living/new_owner, datum/reagents/pill_contents, release_time = 2 MINUTES)
	stash = pill_contents
	if(stash?.total_volume)
		per_tick = stash.total_volume / max(release_time / initial(tick_interval), 1)
	return ..()

/datum/status_effect/aq_extended_release/on_apply()
	return stash?.total_volume > 0

/datum/status_effect/aq_extended_release/tick()
	if(!stash?.total_volume || !iscarbon(owner))
		qdel(src)
		return
	// Bez minimalnej porcji: 1 j. leku też ma schodzić przez cały czas uwalniania. Resztka po błędach zaokrągleń idzie z ostatnią porcją.
	pending += per_tick
	var/amount = pending
	if(stash.total_volume - amount < 0.001)
		amount = stash.total_volume
	else
		// Każdy reagent porcji musi mieć co najmniej 0,01 j., inaczej holder by go zgubił: czekamy, aż porcja urośnie
		var/smallest = stash.total_volume
		for(var/datum/reagent/bit as anything in stash.reagent_list)
			smallest = min(smallest, bit.volume)
		if(amount * smallest / stash.total_volume < CHEMICAL_VOLUME_ROUNDING)
			return
	pending = 0
	// Jak pill/attack(): reakcja połknięcia (mutagen, święcona woda itp.) przed przelaniem, ale bez smaku co tick
	var/part = amount / stash.total_volume
	SEND_SIGNAL(owner, COMSIG_ATOM_EXPOSE_REAGENTS, stash.reagent_list, stash, INGEST, part, FALSE)
	for(var/datum/reagent/bit as anything in stash.reagent_list.Copy())
		if(stash.reaction_check(owner, bit))
			bit.reaction_mob(owner, INGEST, bit.volume * part, FALSE)
	if(QDELETED(src) || !stash?.total_volume)
		return
	stash.trans_to_ingested(owner, amount)
	if(stash.total_volume < 0.001)
		qdel(src)

/// Wymioty i płukanie żołądka zabierają też nieuwolnioną część tabletki, tak jak resztę zawartości żołądka
/datum/status_effect/aq_extended_release/proc/purge(ratio, purge_amount = 0)
	if(!stash?.total_volume)
		return
	for(var/datum/reagent/bit as anything in stash.reagent_list.Copy())
		stash.remove_reagent(bit.type, max(bit.volume * ratio, min(bit.volume, purge_amount)))
	if(stash.total_volume < 0.01)
		qdel(src)

/obj/item/organ/stomach/purge_contents(ratio = 1)
	. = ..()
	for(var/datum/status_effect/aq_extended_release/release in owner?.status_effects)
		release.purge(ratio)

/obj/item/organ/stomach/purge_to_vomit(obj/effect/decal/cleanable/vomit/pool, ratio = 0.1, purge = 10) // domyślne jak STOMACH_VOMIT_RATIO i STOMACH_VOMIT_PURGE (stomach_contents.dm)
	. = ..()
	for(var/datum/status_effect/aq_extended_release/release in owner?.status_effects)
		release.purge(0, purge)

/datum/status_effect/aq_extended_release/Destroy()
	. = ..()
	QDEL_NULL(stash)

/datum/reagent/medicine/cordiolis_hepatico
	name = "Kordiolis hepatyczny"
	description = "Smoliście czarny odczynnik, który zdaje się pochłaniać światło. Na czas działania wątroba i serce nie niszczą się od toksyn ani przedawkowań, ale ich nie leczy."
	reagent_state = LIQUID
	color = "#000000"
	taste_description = "nicość"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	self_consuming = TRUE

/datum/reagent/medicine/cordiolis_hepatico/overdose_process(mob/living/M)
	M.adjustToxLoss(0.5, 0)
	M.drowsyness = max(M.drowsyness, 3)
	..()
	return TRUE

/datum/chemical_reaction/cordiolis_hepatico
	name = "Kordiolis hepatyczny"
	id = /datum/reagent/medicine/cordiolis_hepatico
	results = list(/datum/reagent/medicine/cordiolis_hepatico = 2)
	required_reagents = list(/datum/reagent/medicine/corazone = 1, /datum/reagent/carbon = 1, /datum/reagent/toxin/plasma = 1)

/mob/living/carbon
	/// Trwa metabolizm reagentów przy Kordiolisie: wątroba i serce nie przyjmują obrażeń
	var/aq_chem_organ_shield = FALSE

// Toksyny w wątrobie i efekty reagentów (także przedawkowania) liczą się w process_reagents() wątroby (liver_toxins.dm),
// więc osłona obejmuje tylko obrażenia zadane w tym czasie. Rany, zawał i inne źródła dalej działają.
/obj/item/organ/liver/process_reagents(mob/living/carbon/C)
	if(!C.reagents?.has_reagent(/datum/reagent/medicine/cordiolis_hepatico))
		return ..()
	C.aq_chem_organ_shield = TRUE
	. = ..()
	C.aq_chem_organ_shield = FALSE

/obj/item/organ/liver/applyOrganDamage(d, maximum = maxHealth)
	if(d > 0 && owner?.aq_chem_organ_shield)
		return
	return ..()

/obj/item/organ/heart/applyOrganDamage(d, maximum = maxHealth)
	if(d > 0 && owner?.aq_chem_organ_shield)
		return
	return ..()

#undef BOOSTER_ENZYME_MAX_VOLUME
#undef GLUCOSE_POLYMER_SECONDS_PER_UNIT
