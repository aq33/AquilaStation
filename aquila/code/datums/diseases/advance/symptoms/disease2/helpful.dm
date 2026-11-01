// AQUILA - pomocne objawy z wirusologii disease2 Monkestation (monkestation/code/modules/virology/disease/symtoms/helpful/),
// przerobione na advance disease: mnożnik siły zastąpiony progami statystyk, stadium Monke N to u nas stadium N+1.

/datum/symptom/heal/antitox
	name = "Zespół antyoksydacyjny"
	from_disease2 = TRUE
	desc = "Wirus pobudza organizm do wytwarzania antytoksyny, która oczyszcza krew i wątrobę."
	stealth = 1
	resistance = -1
	stage_speed = 0
	transmission = -1
	level = 5
	severity = -1
	symptom_delay_min = 3
	symptom_delay_max = 6
	prefixes = list("Antioxidant ")
	passive_message = "<span class='notice'>Twoja wątroba czuje się wypoczęta.</span>"
	threshold_desc = "<b>Odporność 6:</b> leczy dwa razy szybciej.<br><b>Ukrycie 3:</b> bez komunikatów o oczyszczaniu."

/datum/symptom/heal/antitox/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.resistance >= 6)
		power = 2
	if(A.stealth >= 3)
		suppress_warning = TRUE
	return TRUE

/datum/symptom/heal/antitox/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(!M.getToxLoss() && !M.getOrganLoss(ORGAN_SLOT_LIVER))
		return FALSE
	return power

/datum/symptom/heal/antitox/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	if(!suppress_warning && prob(5))
		to_chat(M, "<span class='notice'>[pick("Czujesz, jak toksyny opuszczają twoje ciało!", "Twoja wątroba czuje, że da radę.")]</span>")
	M.adjustToxLoss(-2 * actual_power)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -actual_power)
	return TRUE

/datum/symptom/heal/damage_converter
	name = "Kompensacja toksyczna"
	from_disease2 = TRUE
	desc = "Wirus pobudza wzrost komórek i leczy obrażenia fizyczne i oparzenia, ale naprawa zostawia w organizmie toksyny."
	stealth = 0
	resistance = 1
	stage_speed = 1
	transmission = -2
	level = 4
	severity = 0
	symptom_delay_min = 2
	symptom_delay_max = 4
	prefixes = list("Compensating ")
	threshold_desc = "<b>Odporność 7:</b> powstaje o połowę mniej toksyn.<br><b>Szybkość stadiów 7:</b> leczy szybciej."
	/// Mnożnik toksyn za każdy wyleczony punkt
	var/toxin_ratio = 1

/datum/symptom/heal/damage_converter/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.resistance >= 7)
		toxin_ratio = 0.5
	if(A.stage_rate >= 7)
		power = 2
	return TRUE

/datum/symptom/heal/damage_converter/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(HAS_TRAIT(M, TRAIT_TOXINLOVER) || HAS_TRAIT(M, TRAIT_TOXIMMUNE))
		return FALSE
	if(!M.getBruteLoss() && !M.getFireLoss())
		return FALSE
	return power

/datum/symptom/heal/damage_converter/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	var/heal_amount = rand(1, 3) * actual_power
	M.heal_overall_damage(heal_amount, heal_amount)
	M.adjustToxLoss(max(1, heal_amount * toxin_ratio))
	return TRUE

/datum/symptom/heal/darkness
	name = "Regeneracja nocna"
	from_disease2 = TRUE
	desc = "Wirus leczy ciało nosiciela, gdy ten przebywa w ciemności. Najlepiej radzi sobie z obrażeniami fizycznymi."
	stealth = 2
	resistance = -1
	stage_speed = -2
	transmission = -1
	level = 6
	severity = -1
	prefixes = list("Nocturnal ")
	passive_message = "<span class='notice'>Czujesz mrowienie skóry, gdy pada na nią światło.</span>"
	threshold_desc = "<b>Szybkość stadiów 8:</b> leczy dwa razy szybciej."
	COOLDOWN_DECLARE(heal_msg_cooldown)

/datum/symptom/heal/darkness/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.stage_rate >= 8)
		power = 2
	return TRUE

/datum/symptom/heal/darkness/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(isturf(M.loc)) // poza turfem uznajemy, że jest ciemno
		var/turf/mob_turf = M.loc
		if(mob_turf.get_lumcount() > 0.7)
			return FALSE
	return power

/datum/symptom/heal/darkness/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	var/old_health = M.health
	M.heal_overall_damage(actual_power * 2, actual_power)
	if(M.health > old_health && COOLDOWN_FINISHED(src, heal_msg_cooldown))
		to_chat(M, "<span class='notice'>Ciemność koi i zasklepia twoje rany.</span>")
		COOLDOWN_START(src, heal_msg_cooldown, 25 SECONDS)
	return TRUE

/datum/symptom/heal/darkness/passive_message_condition(mob/living/M)
	return M.getBruteLoss() || M.getFireLoss()

/datum/symptom/delightful
	name = "Efekt zachwytu"
	from_disease2 = TRUE
	desc = "Wirus pobudza ośrodek przyjemności. Nosiciel czuje się wspaniale."
	stealth = 2
	resistance = 0
	stage_speed = -1
	transmission = 1
	level = 3
	severity = -1
	symptom_delay_min = 20
	symptom_delay_max = 40
	prefixes = list("Delightful ")
	threshold_desc = "<b>Ukrycie 2:</b> bez komunikatów o zachwycie."

/datum/symptom/delightful/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2)
		suppress_warning = TRUE

/datum/symptom/delightful/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/M = A.affected_mob
	if(!suppress_warning && prob(10))
		to_chat(M, "<span class='hypnophrase'>Czujesz się zachwycająco!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "delightful_symptom", /datum/mood_event/delightful_symptom)

/datum/symptom/delightful/End(datum/disease/advance/A)
	if(!..())
		return
	SEND_SIGNAL(A.affected_mob, COMSIG_CLEAR_MOOD_EVENT, "delightful_symptom")

/datum/mood_event/delightful_symptom
	description = "<span class='nicegreen'>Wszystko jest takie zachwycające!</span>\n"
	mood_change = 6
	timeout = 2 MINUTES

/datum/symptom/lantern
	name = "Zespół latarni"
	from_disease2 = TRUE
	desc = "Skóra nosiciela zaczyna świecić w kolorze substancji krążących w jego krwi."
	stealth = -3
	resistance = 1
	stage_speed = 1
	transmission = 0
	level = 3
	severity = 0
	symptom_delay_min = 10
	symptom_delay_max = 20
	prefixes = list("Lantern ")
	threshold_desc = "<b>Szybkość stadiów 6:</b> jaśniejsze światło.<br><b>Szybkość stadiów 10:</b> bardzo jasne światło.<br>Płyn czyszczący we krwi na stałe zmienia światło na białe."
	/// Zasięg światła
	var/light_range = 4
	/// Po płynie czyszczącym świeci już tylko na biało
	var/uncolored = FALSE
	var/obj/effect/dummy/lighting_obj/moblight

/datum/symptom/lantern/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 10)
		light_range = 8
	else if(A.stage_rate >= 6)
		light_range = 6

/datum/symptom/lantern/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 3)
		return
	var/mob/living/M = A.affected_mob
	if(!moblight)
		moblight = new(M)
		to_chat(M, "<span class='notice'>Świecisz!</span>")
	var/light_color = "#FFFFFF"
	if(M.reagents)
		if(M.reagents.has_reagent(/datum/reagent/space_cleaner))
			uncolored = TRUE
		if(!uncolored && length(M.reagents.reagent_list))
			light_color = mix_color_from_reagents(M.reagents.reagent_list)
	moblight.set_light(light_range, light_range / 3, light_color)

/datum/symptom/lantern/End(datum/disease/advance/A)
	if(!..())
		return
	if(moblight)
		QDEL_NULL(moblight)
		to_chat(A.affected_mob, "<span class='notice'>Nie świecisz już tak jasno.</span>")

/datum/symptom/heal/immortal
	name = "Zespół długowieczności"
	from_disease2 = TRUE
	desc = "Dopóki objaw działa, nosiciel jest praktycznie nieśmiertelny: wirus leczy obrażenia i rany. Wyleczenie choroby powoduje gwałtowny nawrót: wszystko, co wyleczył, wraca jako obrażenia, a nosiciel się starzeje."
	stealth = -2
	resistance = 3
	stage_speed = -3
	transmission = -4
	level = 9
	severity = -1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Immortal ")
	threshold_desc = "<b>Odporność 10:</b> leczy dwa razy szybciej (i dwa razy mocniej odbija się przy wyleczeniu)."
	/// Ile leczenia trzeba będzie oddać po wyleczeniu choroby
	var/total_healed = 0

/datum/symptom/heal/immortal/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.resistance >= 10)
		power = 2
	return TRUE

/datum/symptom/heal/immortal/Activate(datum/disease/advance/A)
	if(neutered || stopped || !A)
		return
	if(A.stage < 5) // u Monke stadium 4 z 4
		return
	return ..()

/datum/symptom/heal/immortal/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	if(iscarbon(M))
		for(var/datum/wound/wound as anything in M.get_all_wounds())
			to_chat(M, "<span class='notice'>Czujesz, jak [wound.name] goi się samo.</span>")
			wound.remove_wound()
			break
	var/heal_amt = 4 * actual_power
	var/current_damage = M.getBruteLoss()
	total_healed += min(heal_amt, current_damage) * 0.5
	M.heal_overall_damage(heal_amt, heal_amt)
	if(!HAS_TRAIT(M, TRAIT_TOXINLOVER) && !HAS_TRAIT(M, TRAIT_TOXIMMUNE))
		M.adjustToxLoss(-heal_amt)
	return TRUE

/datum/symptom/heal/immortal/End(datum/disease/advance/A)
	if(!..())
		return FALSE
	var/mob/living/M = A.affected_mob
	if(QDELETED(M) || M.stat == DEAD || total_healed <= 0)
		return TRUE
	if(ishuman(M))
		var/mob/living/carbon/human/person = M
		to_chat(person, "<span class='warning'>Nagle czujesz się obolały i stary...</span>")
		person.age += round(4 * power * total_healed / 10)
	M.take_overall_damage(total_healed / 2, total_healed / 2)
	total_healed = 0
	return TRUE

#define PLASMA_HEAL_PER_MOL 1.1
#define PLASMA_HEAL_PER_BREATH_PRESSURE 0.05
#define PLASMA_HEAL_MAX_INTERNALS 0.75
#define PLASMA_HEAL_MAX_ENVIRONMENT 0.5
#define PLASMA_HEAL_MAX_BLOODSTREAM 0.75

/datum/symptom/heal/plasma
	name = "Fiksacja plazmy"
	from_disease2 = TRUE
	desc = "Wirus pobiera plazmę z otoczenia, z butli i z krwi nosiciela, żeby leczyć obrażenia i wyrównywać temperaturę ciała."
	stealth = 0
	resistance = 3
	stage_speed = -2
	transmission = -2
	level = 8
	severity = -1
	prefixes = list("Plasma ")
	passive_message = "<span class='notice'>Czujesz dziwne przyciąganie do plazmy.</span>"
	threshold_desc = "<b>Szybkość stadiów 7:</b> szybciej wyrównuje temperaturę.<br><b>Odporność 7:</b> leczy dwa razy szybciej."
	/// Tempo wyrównywania temperatury
	var/temp_rate = 1

/datum/symptom/heal/plasma/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.stage_rate >= 7)
		temp_rate = 4
	if(A.resistance >= 7)
		power = 2
	return TRUE

/datum/symptom/heal/plasma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/base = 0
	if(iscarbon(M))
		var/mob/living/carbon/breather = M
		var/obj/item/tank/internals/internals_tank = breather.internal
		if(internals_tank)
			var/datum/gas_mixture/tank_contents = internals_tank.return_air()
			if(tank_contents && round(tank_contents.return_pressure()) && tank_contents.get_moles(GAS_PLASMA))
				base += power * min(PLASMA_HEAL_MAX_INTERNALS, internals_tank.distribute_pressure * PLASMA_HEAL_PER_BREATH_PRESSURE)
	var/datum/gas_mixture/environment = M.loc?.return_air()
	if(environment && environment.get_moles(GAS_PLASMA))
		base += power * min(PLASMA_HEAL_MAX_ENVIRONMENT, environment.get_moles(GAS_PLASMA) * PLASMA_HEAL_PER_MOL)
	if(M.reagents?.has_reagent(/datum/reagent/toxin/plasma, needs_metabolizing = TRUE))
		base += power * PLASMA_HEAL_MAX_BLOODSTREAM
	return base

/datum/symptom/heal/plasma/passive_message_condition(mob/living/M)
	return M.getBruteLoss() || M.getFireLoss()

/datum/symptom/heal/plasma/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power
	if(prob(5))
		to_chat(M, "<span class='notice'>Czujesz, jak wchłaniasz plazmę w sobie i wokół siebie...</span>")
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	else if(M.bodytemperature < (BODYTEMP_NORMAL + 1))
		M.adjust_bodytemperature(20 * temp_rate * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	M.adjustToxLoss(-heal_amt, forced = TRUE)
	if(M.getBruteLoss() || M.getFireLoss())
		M.heal_overall_damage(heal_amt, heal_amt)
		if(prob(5))
			to_chat(M, "<span class='notice'>Ból ran szybko słabnie.</span>")
	return TRUE

#undef PLASMA_HEAL_PER_MOL
#undef PLASMA_HEAL_PER_BREATH_PRESSURE
#undef PLASMA_HEAL_MAX_INTERNALS
#undef PLASMA_HEAL_MAX_ENVIRONMENT
#undef PLASMA_HEAL_MAX_BLOODSTREAM

/datum/symptom/spaceadapt
	name = "Adaptacja kosmiczna"
	from_disease2 = TRUE
	desc = "Skóra nosiciela wydziela cienką, izolującą warstwę, która chroni przed zimnem i próżnią."
	stealth = 1
	resistance = 2
	stage_speed = -3
	transmission = -3
	level = 9
	severity = -1
	symptom_delay_min = 5
	symptom_delay_max = 10
	prefixes = list("Spaceproof ")
	threshold_desc = "<b>Odporność 8:</b> ochrona działa już od czwartego stadium."
	/// Od którego stadium działa ochrona
	var/required_stage = 5
	var/spaceproof = FALSE

/datum/symptom/spaceadapt/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 8)
		required_stage = 4

/datum/symptom/spaceadapt/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(spaceproof || A.stage < required_stage)
		return
	var/mob/living/M = A.affected_mob
	ADD_TRAIT(M, TRAIT_RESISTCOLD, DISEASE_TRAIT)
	ADD_TRAIT(M, TRAIT_RESISTLOWPRESSURE, DISEASE_TRAIT)
	spaceproof = TRUE
	to_chat(M, "<span class='notice'>Ciepła poświata pokrywa twoją skórę.</span>")

/datum/symptom/spaceadapt/End(datum/disease/advance/A)
	if(!..())
		return
	if(!spaceproof)
		return
	var/mob/living/M = A.affected_mob
	REMOVE_TRAIT(M, TRAIT_RESISTCOLD, DISEASE_TRAIT)
	REMOVE_TRAIT(M, TRAIT_RESISTLOWPRESSURE, DISEASE_TRAIT)
	spaceproof = FALSE
	to_chat(M, "<span class='notice'>Znów czujesz chłód powietrza.</span>")
	M.emote("shiver")

/datum/symptom/thick_blood
	name = "Hiperfibrynogeneza"
	from_disease2 = TRUE
	desc = "Wirus nadprodukuje czynniki krzepnięcia: tamuje krwawienie i szybko odtwarza utraconą krew."
	stealth = 0
	resistance = 2
	stage_speed = -1
	transmission = -2
	level = 7
	severity = -1
	symptom_delay_min = 5
	symptom_delay_max = 15
	prefixes = list("Coagulant ")
	threshold_desc = "<b>Szybkość stadiów 8:</b> działa częściej."

/datum/symptom/thick_blood/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		symptom_delay_min = 2
		symptom_delay_max = 5

/datum/symptom/thick_blood/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!iscarbon(M) || !M.is_bleeding())
		return
	M.restore_blood()
	// /mob/living/carbon/human/restore_blood() tamuje rany samo, ale bazowa wersja dla innych ciał węglowych
	// ustawia tylko objętość krwi, więc bez tego krwawienie trwa dalej, a komunikat leciałby w kółko
	M.cauterise_wounds()
	to_chat(M, "<span class='notice'>Czujesz, jak krew się odnawia, a krwawienie ustaje!</span>")

/datum/symptom/heal/water
	name = "Nawodnienie tkanek"
	from_disease2 = TRUE
	desc = "Wirus wykorzystuje wodę w ciele i na nim do naprawy uszkodzonych komórek. Najlepiej leczy oparzenia, a woda święcona działa mocniej."
	stealth = 0
	resistance = -1
	stage_speed = 0
	transmission = 1
	level = 6
	severity = -1
	prefixes = list("Hydrating ")
	passive_message = "<span class='notice'>Twoja skóra wydaje się dziwnie sucha...</span>"
	threshold_desc = "<b>Odporność 5:</b> szybciej wchłania wodę.<br><b>Szybkość stadiów 7:</b> leczy dwa razy szybciej."
	/// Ile wody naraz wchłania
	var/absorption_coeff = 1

/datum/symptom/heal/water/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.resistance >= 5)
		absorption_coeff = 2
	if(A.stage_rate >= 7)
		power = 2
	return TRUE

/datum/symptom/heal/water/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/base = 0
	if(M.fire_stacks < 0)
		M.adjust_fire_stacks(min(absorption_coeff, -M.fire_stacks))
		base += power
	if(M.reagents?.has_reagent(/datum/reagent/water/holywater))
		M.reagents.remove_reagent(/datum/reagent/water/holywater, 0.5 * absorption_coeff)
		base += power * 0.75
	else if(M.reagents?.has_reagent(/datum/reagent/water))
		M.reagents.remove_reagent(/datum/reagent/water, 0.5 * absorption_coeff)
		base += power * 0.5
	return base

/datum/symptom/heal/water/passive_message_condition(mob/living/M)
	return M.getBruteLoss() || M.getFireLoss()

/datum/symptom/heal/water/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	if(prob(5))
		to_chat(M, "<span class='notice'>Wchłaniasz wodę wokół siebie, a ona koi uszkodzoną skórę.</span>")
	M.heal_overall_damage(actual_power, actual_power * 2)
	return TRUE

#define STARLIGHT_RANGE 2

/datum/symptom/heal/starlight
	name = "Kondensacja światła gwiazd"
	from_disease2 = TRUE
	desc = "Wirus reaguje na bezpośrednie światło gwiazd i wytwarza substancje lecznicze. Najlepiej leczy toksyny."
	stealth = -1
	resistance = -2
	stage_speed = 0
	transmission = 1
	level = 6
	severity = -1
	prefixes = list("Starlight ")
	passive_message = "<span class='notice'>Tęsknisz za dotykiem światła gwiazd na skórze.</span>"
	threshold_desc = "<b>Szybkość stadiów 6:</b> leczy więcej.<br><b>Transmisja 6:</b> pełne leczenie także przy przestrzeni kosmicznej w pobliżu."
	/// Ile leczenia zostaje, gdy kosmos jest tylko w pobliżu
	var/nearspace_penalty = 0.3

/datum/symptom/heal/starlight/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.stage_rate >= 6)
		power = 2
	if(A.transmission >= 6)
		nearspace_penalty = 1
	return TRUE

/datum/symptom/heal/starlight/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/turf/mob_turf = get_turf(M)
	if(isspaceturf(mob_turf))
		return power
	for(var/turf/T in view(STARLIGHT_RANGE, M))
		if(isspaceturf(T))
			return power * nearspace_penalty
	return FALSE

/datum/symptom/heal/starlight/passive_message_condition(mob/living/M)
	return M.getBruteLoss() || M.getFireLoss() || M.getToxLoss()

/datum/symptom/heal/starlight/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	if(M.getToxLoss() && prob(5))
		to_chat(M, "<span class='notice'>Skóra mrowi, gdy światło gwiazd zaczyna cię leczyć.</span>")
	M.adjustToxLoss(-4 * actual_power, forced = TRUE)
	M.heal_overall_damage(actual_power, actual_power)
	return TRUE

#undef STARLIGHT_RANGE
