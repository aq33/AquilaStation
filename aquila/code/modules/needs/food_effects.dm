// AQUILA - co robi to, co jemy i pijemy: cukier, kofeina, białko, tłuszcz, przyprawy, kwas żołądkowy.
// Każdy składnik ma zaletę. Licznik cukru, kofeiny, soli i tłuszczu czyta needs.dm, kwas i podrażnienie stomach_ulcer.dm.

/datum/reagent/consumable
	/// Ile cukru (zastrzyk staminy, potem spadek) daje wchłonięta jednostka
	var/aq_sugar = 0
	/// Kofeina: trochę szybsza regeneracja staminy, póki jest we krwi
	var/aq_caffeine = FALSE
	/// Ile kwasu w żołądku dokłada wchłonięta jednostka. Ujemny osłania żołądek i przyspiesza gojenie wrzodów.
	var/aq_stomach_acid = 0
	/// Drażni wrzody, które już są (ostre, alkohol)
	var/aq_ulcer_irritant = FALSE

/datum/reagent/consumable/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(aq_sugar)
			H.aq_sugar_load += aq_sugar * metabolization_rate
		if(aq_caffeine)
			H.aq_caffeine_until = world.time + 20 SECONDS
		if(aq_stomach_acid || aq_ulcer_irritant)
			H.aq_stomach_reagent(src)
	return ..()

// --- Cukier: szybki zastrzyk staminy, po nim łagodny spadek ---

/datum/reagent/consumable/sugar
	aq_sugar = 1

// Słodkie gazowane napoje z automatów: cukier, ale też kwas dla żołądka
/datum/reagent/consumable/space_cola
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/nuka_cola
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/spacemountainwind
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/dr_gibb
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/space_up
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/lemon_lime
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/pwr_game
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/shamblers
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/grape_soda
	aq_sugar = 1
	aq_stomach_acid = 0.5

/datum/reagent/consumable/cream_soda
	aq_sugar = 1
	aq_stomach_acid = 0.5

// Energetyki: cukier i kofeina
/datum/reagent/consumable/grey_bull
	aq_sugar = 1
	aq_caffeine = TRUE
	aq_stomach_acid = 0.5

/datum/reagent/consumable/monkey_energy
	aq_sugar = 1
	aq_caffeine = TRUE
	aq_stomach_acid = 0.5

// --- Kawa i herbata: kofeina, ale kawa nawadnia słabiej niż woda i soki ---

/datum/reagent/consumable/coffee
	aq_caffeine = TRUE
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/icecoffee
	aq_caffeine = TRUE
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/soy_latte
	aq_caffeine = TRUE
	hydration_factor = 9 * REAGENTS_METABOLISM

/datum/reagent/consumable/cafe_latte
	aq_caffeine = TRUE
	hydration_factor = 9 * REAGENTS_METABOLISM

/datum/reagent/consumable/pumpkin_latte
	aq_caffeine = TRUE

/datum/reagent/consumable/navy_coffee
	aq_caffeine = TRUE

/datum/reagent/consumable/tea
	aq_caffeine = TRUE

// --- Mleko osłania żołądek ---

/datum/reagent/consumable/milk
	aq_stomach_acid = -1

/datum/reagent/consumable/soymilk
	aq_stomach_acid = -0.5

// --- Alkohol i ostre drażnią wrzody, które już są ---

/datum/reagent/consumable/ethanol
	aq_ulcer_irritant = TRUE

/datum/reagent/consumable/capsaicin
	aq_ulcer_irritant = TRUE

/datum/reagent/consumable/hell_ramen
	aq_ulcer_irritant = TRUE

// --- Białko odbudowuje krew, tłuszcz dłużej syci ---

/datum/reagent/consumable/nutriment/protein/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.blood_volume < BLOOD_VOLUME_NORMAL && !(NOBLOOD in H.dna.species.species_traits) && !HAS_TRAIT(H, TRAIT_NO_BLOOD))
			H.blood_volume = min(H.blood_volume + 0.5, BLOOD_VOLUME_NORMAL)
	return ..()

/datum/reagent/consumable/nutriment/fat/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.aq_fat_until = world.time + 3 MINUTES
	return ..()

// --- Przyprawy ---

/// Sól zatrzymuje wodę: nawodnienie spada wolniej
/datum/reagent/consumable/sodiumchloride/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.aq_salt_until = world.time + 3 MINUTES
	return ..()

/// Pieprz pobudza trawienie: obrzydzenie mija szybciej
/datum/reagent/consumable/blackpepper/on_mob_life(mob/living/carbon/M)
	if(M.disgust)
		M.adjust_disgust(-1)
	return ..()

/// Przyprawy, które dodane ręcznie do gotowego dania podnoszą jego jakość
GLOBAL_LIST_INIT(aq_spice_reagents, typecacheof(list(
	/datum/reagent/consumable/sodiumchloride,
	/datum/reagent/consumable/blackpepper,
	/datum/reagent/consumable/capsaicin,
	/datum/reagent/consumable/frostoil,
	/datum/reagent/consumable/soysauce,
	/datum/reagent/consumable/ketchup,
	/datum/reagent/consumable/mayonnaise,
	/datum/reagent/consumable/bbqsauce,
)))

/// Czy w tym pojemniku jest jakaś przyprawa
/datum/reagents/proc/aq_has_spice()
	for(var/datum/reagent/bit as anything in reagent_list)
		if(GLOB.aq_spice_reagents[bit.type])
			return TRUE
	return FALSE

/// Przyprawa wylana na gotowe danie zostawia na nim znacznik
/obj/item/reagent_containers/food/condiment/proc/aq_mark_seasoned(atom/target, volume_before)
	if(QDELETED(target) || !isitem(target) || !target.reagents)
		return
	if(target.reagents.total_volume > volume_before)
		ADD_TRAIT(target, TRAIT_AQ_SEASONED, AQ_NEEDS_TRAIT)

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user, proximity)
	var/seasoning = proximity && istype(target, /obj/item/food) && target.reagents && reagents?.aq_has_spice()
	var/volume_before = seasoning ? target.reagents.total_volume : 0
	. = ..()
	if(seasoning)
		aq_mark_seasoned(target, volume_before)

// Saszetka rozrywa się nad daniem i znika, zanim wywoła rodzica
/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user, proximity)
	var/seasoning = proximity && istype(target, /obj/item/food) && target.reagents && reagents?.aq_has_spice()
	var/volume_before = seasoning ? target.reagents.total_volume : 0
	. = ..()
	if(seasoning)
		aq_mark_seasoned(target, volume_before)

/datum/component/edible/get_perceived_food_quality(mob/living/carbon/human/eater)
	. = ..()
	if(. > TOXIC_FOOD_QUALITY_THRESHOLD && HAS_TRAIT(parent, TRAIT_AQ_SEASONED) && !HAS_TRAIT(eater, TRAIT_AGEUSIA))
		. += 1

/obj/item/food/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_AQ_SEASONED))
		. += "<span class='notice'>Ktoś to doprawił.</span>"

// --- Automaty: wydany przedmiot dostaje znacznik (jedzenie z automatu liczy się do wrzodów) ---

/obj/machinery/vending/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_VENDING_DISPENSED, PROC_REF(aq_mark_vended))

/obj/machinery/vending/proc/aq_mark_vended(datum/source, obj/item/vended_item)
	SIGNAL_HANDLER
	if(istype(vended_item, /obj/item/food))
		ADD_TRAIT(vended_item, TRAIT_AQ_VENDED, AQ_NEEDS_TRAIT)
