// AQUILA - port BeeStation/BeeStation-Hornet#14340 (Modernized Stomachs & Livers), wariant minimalny na naszym API reagentów.
// Połknięte reagenty (jedzenie, napoje, przyprawy, pigułki) trafiają najpierw do żołądka i stamtąd stopniowo do krwi.
// Papierosy, dym, zastrzyki i dotyk idą do krwi jak dawniej.
// Mob, który powinien mieć żołądek, a go nie ma, wszystko zwraca. Mob bez żołądka z natury (ksenomorf, larwa)
// dostaje połknięte reagenty do krwi jak dawniej.
// Wymioty i płukanie żołądka opróżniają żołądek, nie krew.
// Core hooks: get_ingest_holder() w trans_to(method = INGEST) i on_mob_delete() bez żołądka w del_reagent() (holder.dm),
// handle_stomach_digestion() w /mob/living/carbon/Life(), vomit_from_stomach() w clear_reagents_to_vomit_pool() (turf.dm),
// trans_to_ingested() przy piciu i połykaniu (drinks, condiment, glass, pill, crayons), stomach_scan_lines() w chemscan().

/// Pojemność żołądka (Bee: reagent_vol = 1000)
#define STOMACH_REAGENT_VOLUME 1000
/// Najmniej, ile żołądek oddaje do krwi z jednego reagentu na tick Life (2 s), chyba że reagent metabolizuje się szybciej. Bee: 0,5 j./s
#define STOMACH_MIN_TRANSFER 1
/// Sekundy na tick Life: nasze on_life() nie dostaje delta_time
#define STOMACH_TICK_SECONDS 2
/// Jaka część zawartości żołądka ląduje w kałuży z każdego pola wymiotów (Bee/tg: purge_ratio 0,1)
#define STOMACH_VOMIT_RATIO 0.1
/// Ile jednostek każdego reagentu żołądek traci z każdego pola wymiotów (tg)
#define STOMACH_VOMIT_PURGE 10

/obj/item/organ/stomach
	/// Jaka część zawartości (na sekundę) przechodzi z żołądka do krwi, oprócz stałego minimum (Bee: metabolism_efficiency)
	var/metabolism_efficiency = 0.05

/obj/item/organ/stomach/cybernetic
	metabolism_efficiency = 0.035 // gorzej trawi (Bee)

/obj/item/organ/stomach/cybernetic/upgraded
	metabolism_efficiency = 0.07 // Bee: tier2

/obj/item/organ/stomach/plasmaman
	metabolism_efficiency = 0.06 // Bee: digestive crystal

/obj/item/organ/stomach/Initialize(mapload)
	. = ..()
	// Zjadliwy żołądek ma już pojemnik z komponentu edible (10 j. z własnym jedzeniem organu), reszta dostaje nowy
	if(reagents)
		reagents.maximum_volume = STOMACH_REAGENT_VOLUME
	else
		create_reagents(STOMACH_REAGENT_VOLUME)

/// Ile jednostek reagentu w żołądku pochodzi z połkniętych rzeczy, a nie z własnego jedzenia organu (food_reagents zjadliwego organu)
/obj/item/organ/stomach/proc/get_free_amount(datum/reagent/bit)
	var/reserved = 0
	if((organ_flags & ORGAN_EDIBLE) && food_reagents)
		reserved = food_reagents[bit.type] || 0
	return max(bit.volume - reserved, 0)

/// Żołądek oddaje część zawartości do krwi (Bee: /obj/item/organ/stomach/on_life()).
/// Woła to /mob/living/carbon/Life() przed organami, żeby wątroba od razu metabolizowała to, co doszło do krwi.
/obj/item/organ/stomach/proc/digest()
	if(!owner?.reagents || !reagents?.total_volume)
		return
	// Jak krew w metabolize(): zawartość ma temperaturę ciała, a nie reaguje w 300 K jak w zlewce
	reagents.expose_temperature(owner.bodytemperature, 0.25)
	for(var/datum/reagent/bit as anything in reagents.reagent_list.Copy())
		// To, co się nie metabolizuje (np. plastik), zostaje w żołądku
		if(bit.holder != reagents || bit.metabolization_rate <= 0)
			continue
		var/free = get_free_amount(bit)
		if(free <= 0)
			continue
		var/amount = min(round(metabolism_efficiency * free * STOMACH_TICK_SECONDS, 0.05) + max(bit.metabolization_rate, STOMACH_MIN_TRANSFER), free)
		// Czystość idzie razem z reagentem, więc nieczysty chem zmienia się w swój inverse dopiero po wejściu do krwi (REAGENT_HOLDER_ALIVE)
		reagents.trans_id_to(owner, bit.type, amount)

/// Wymioty: część zawartości ląduje w kałuży, a z każdego reagentu znika do 10 j. (tg: clear_reagents_to_vomit_pool())
/obj/item/organ/stomach/proc/purge_to_vomit(obj/effect/decal/cleanable/vomit/pool, ratio = STOMACH_VOMIT_RATIO, purge = STOMACH_VOMIT_PURGE)
	if(!reagents?.total_volume)
		return
	for(var/datum/reagent/bit as anything in reagents.reagent_list.Copy())
		if(bit.holder != reagents)
			continue
		var/free = get_free_amount(bit)
		if(free <= 0)
			continue
		if(pool?.reagents)
			reagents.trans_id_to(pool, bit.type, free * ratio)
		if(bit.holder == reagents)
			reagents.remove_reagent(bit.type, min(get_free_amount(bit), purge))

/// Usuwa podaną część zawartości żołądka, bez własnego jedzenia organu (płukanie żołądka)
/obj/item/organ/stomach/proc/purge_contents(ratio = 1)
	if(!reagents?.total_volume)
		return
	for(var/datum/reagent/bit as anything in reagents.reagent_list.Copy())
		if(bit.holder != reagents)
			continue
		var/free = get_free_amount(bit)
		if(free > 0)
			reagents.remove_reagent(bit.type, free * ratio)

/// Ile wolnej zawartości jest w żołądku (bez własnego jedzenia organu)
/obj/item/organ/stomach/proc/get_contents_volume()
	. = 0
	for(var/datum/reagent/bit as anything in reagents?.reagent_list)
		. += get_free_amount(bit)

/// Trawienie przed organami (core hook w /mob/living/carbon/Life())
/mob/living/carbon/proc/handle_stomach_digestion()
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	belly?.digest()

/// Czy ten mob trawi przez żołądek. FALSE: mob bez żołądka z natury (ksenomorf, larwa), połknięte idzie do krwi jak dawniej.
/mob/living/carbon/proc/needs_stomach()
	return FALSE

/mob/living/carbon/human/needs_stomach()
	var/datum/species/species = dna?.species
	return !species || !(NOSTOMACH in species.species_traits)

/mob/living/carbon/monkey/needs_stomach()
	return TRUE

/// Pojemnik, do którego trafia to, co mob połyka: żołądek, krew moba bez żołądka z natury,
/// albo null, gdy mob powinien mieć żołądek, a go nie ma (wtedy wszystko zwraca).
/datum/reagents/proc/get_ingest_holder(atom/target, amount)
	if(!iscarbon(target))
		return target?.reagents
	var/mob/living/carbon/eater = target
	var/obj/item/organ/stomach/belly = eater.getorganslot(ORGAN_SLOT_STOMACH)
	if(belly?.reagents)
		return belly.reagents
	if(eater.needs_stomach())
		eater.expel_ingested(src, amount)
		return null
	return eater.reagents

/// Przelewa połknięte reagenty do żołądka bez ponownej reakcji z mobem: wołający robi wcześniej reaction(M, INGEST),
/// które wysyła COMSIG_ATOM_EXPOSE_REAGENTS (heretyckie organy) i daje smak.
/datum/reagents/proc/trans_to_ingested(mob/living/target, amount = 1, multiplier = 1, mob/transfered_by)
	if(QDELETED(target) || !total_volume)
		return 0
	var/datum/reagents/belly = get_ingest_holder(target, amount)
	if(!belly)
		return 0
	if(belly == target.reagents)
		return trans_to(target, amount, multiplier, transfered_by = transfered_by)
	return trans_to(belly, amount, multiplier, transfered_by = transfered_by)

/// Mob bez żołądka zwraca to, co próbował połknąć (Bee: /mob/living/carbon/proc/expel_ingested())
/mob/living/carbon/proc/expel_ingested(datum/reagents/source, amount)
	visible_message(span_danger("[src] od razu wszystko zwraca!"), span_userdanger("Bez żołądka nie jesteś w stanie niczego w sobie utrzymać!"))
	var/turf/floor = get_turf(src)
	var/obj/effect/decal/cleanable/vomit/spew
	if(floor)
		spew = new(floor, get_static_viruses())
		if(QDELETED(spew)) // połączyła się z kałużą, która już tu jest
			spew = locate() in floor
	if(spew?.reagents)
		source.trans_to(spew, amount, transfered_by = src)
	else
		source.remove_any(amount)

/// Wymioty zabierają z żołądka, nie z krwi (core hook w clear_reagents_to_vomit_pool()).
/// TRUE, jeśli sprawa załatwiona. FALSE: mob bez żołądka z natury, core zabiera wtedy jak dawniej z krwi.
/mob/living/carbon/proc/vomit_from_stomach(obj/effect/decal/cleanable/vomit/pool)
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(belly?.reagents)
		belly.purge_to_vomit(pool)
		return TRUE
	// Powinien mieć żołądek, a go nie ma: nie ma czego zwrócić, krwi nie ruszamy
	return needs_stomach()

/// Pełne leczenie czyści też żołądek, tak jak core czyści krew
/mob/living/carbon/fully_heal(admin_revive = FALSE)
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	belly?.purge_contents()
	return ..()

/// Wiersze o zawartości żołądka do chemscan() (tryb chemiczny analizatora, monitor funkcji życiowych)
/mob/living/proc/stomach_scan_lines()
	return list()

/mob/living/carbon/stomach_scan_lines()
	. = list()
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly?.reagents)
		return
	var/list/lines = list()
	for(var/datum/reagent/bit as anything in belly.reagents.reagent_list)
		var/free = belly.get_free_amount(bit)
		if(free > 0)
			lines += "<span class='notice'>[round(free, 0.001)] j. [bit.name].</span>"
	if(!length(lines))
		. += "<span class='notice'>Żołądek jest pusty.</span>"
		return
	. += "<span class='notice'>Zawartość żołądka:</span>"
	. += lines

/// Zawartość żołądka do okna analizatora zdrowia (null: brak żołądka)
/mob/living/carbon/proc/stomach_ui_data()
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(!belly?.reagents)
		return null
	. = list()
	for(var/datum/reagent/bit as anything in belly.reagents.reagent_list)
		var/free = belly.get_free_amount(bit)
		if(free > 0)
			. += list(list("name" = bit.name, "colour" = bit.color, "volume" = round(free, 0.1)))

/// Mucha zwraca jedzenie. Dawniej wymioty czyściły je z krwi, teraz opróżniają żołądek,
/// więc to, co zdążyło dojść do krwi, usuwamy tutaj (inaczej mucha wymiotowałaby co tick).
/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(!istype(chem, /datum/reagent/consumable) || chem.holder != H.reagents)
		return
	var/datum/reagent/consumable/food = chem
	if(food.nutriment_factor > 0)
		H.reagents.del_reagent(food.type)

#undef STOMACH_REAGENT_VOLUME
#undef STOMACH_MIN_TRANSFER
#undef STOMACH_TICK_SECONDS
#undef STOMACH_VOMIT_RATIO
#undef STOMACH_VOMIT_PURGE
