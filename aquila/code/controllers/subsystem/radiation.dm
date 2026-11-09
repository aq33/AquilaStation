// SSradiation z BeeStation/BeeStation-Hornet#13442 (port tg). Zastępuje stare code/controllers/subsystem/radiation.dm.
SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_BACKGROUND | SS_NO_INIT

	wait = 0.5 SECONDS

	/// Impulsy (/datum/radiation_pulse_information) czekające na przetworzenie.
	/// Nie ruszaj bezpośrednio, używaj `radiation_pulse`.
	var/list/datum/radiation_pulse_information/processing = list()

/datum/controller/subsystem/radiation/fire(resumed)
	while (processing.len)
		var/datum/radiation_pulse_information/pulse_information = processing[1]

		var/datum/weakref/source_ref = pulse_information.source_ref
		var/atom/source = source_ref.resolve()
		if (isnull(source))
			processing.Cut(1, 2)
			continue

		pulse(source, pulse_information)

		if (MC_TICK_CHECK)
			return

		processing.Cut(1, 2)

/datum/controller/subsystem/radiation/stat_entry(msg)
	msg = "Pulses:[processing.len]"
	return ..()

/datum/controller/subsystem/radiation/proc/pulse(atom/source, datum/radiation_pulse_information/pulse_information)
	var/list/cached_rad_insulations = list()
	var/list/cached_turfs_to_process = pulse_information.turfs_to_process
	var/turf/source_turf = get_turf(source)
	var/turfs_iterated = 0
	for (var/turf/turf_to_irradiate as anything in cached_turfs_to_process)
		turfs_iterated += 1
		for (var/atom/movable/target in turf_to_irradiate)
			if (!can_irradiate_basic(target))
				continue

			// Aquila: przedmioty bez nasłuchu (licznik Geigera ma TRAIT_BYPASS_EARLY_IRRADIATED_CHECK) nie liczą linii,
			// gdy już świecą albo gdy i tak przegrałyby rzut na skażenie. Wynik praktycznie ten sam, a impulsy co sekundę są tańsze.
			if (isitem(target) && !HAS_TRAIT(target, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK))
				if (HAS_TRAIT(target, TRAIT_IRRADIATED) || !prob(pulse_information.intensity))
					continue

			var/current_insulation = get_insulation_to(source_turf, target, pulse_information.threshold, cached_rad_insulations)

			SEND_SIGNAL(target, COMSIG_IN_RANGE_OF_IRRADIATION, pulse_information, current_insulation)

			if (current_insulation <= pulse_information.threshold)
				continue

			var/irradiation_result = SEND_SIGNAL(target, COMSIG_IN_THRESHOLD_OF_IRRADIATION, pulse_information)
			if (irradiation_result & CANCEL_IRRADIATION)
				continue

			if (pulse_information.minimum_exposure_time && !(irradiation_result & SKIP_MINIMUM_EXPOSURE_TIME_CHECK))
				target.AddComponent(/datum/component/radiation_countdown, pulse_information.minimum_exposure_time)
				continue

			// Przedmioty z nasłuchem rzucają tu, reszta przedmiotów już wyżej
			if (isitem(target) && HAS_TRAIT(target, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK) && !prob(pulse_information.intensity))
				continue

			if (irradiate_after_basic_checks(target, pulse_information.intensity))
				target.investigate_log("was irradiated by [source].", INVESTIGATE_RADIATION)

		if(MC_TICK_CHECK)
			break

	cached_turfs_to_process.Cut(1, turfs_iterated + 1)

/// Iloczyn izolacji na linii od kafelka źródła do celu (bez kafelka źródła, z kafelkiem celu).
/// Przerywa, gdy spadnie do progu. `cache` przechowuje izolację kafelków w ramach jednego impulsu.
/datum/controller/subsystem/radiation/proc/get_insulation_to(turf/source_turf, atom/target, threshold, list/cache)
	var/current_insulation = 1
	for (var/turf/turf_in_between in getline(source_turf, target) - source_turf)
		var/insulation = cache?[turf_in_between]
		if (isnull(insulation))
			insulation = turf_in_between.rad_insulation
			for (var/atom/on_turf as anything in turf_in_between.contents)
				insulation *= on_turf.rad_insulation
			if (cache)
				cache[turf_in_between] = insulation

		current_insulation *= insulation

		if (current_insulation <= threshold)
			break
	return current_insulation

/// Próbuje napromieniować cel z ograniczeniami IC (np. strój ochronny).
/datum/controller/subsystem/radiation/proc/irradiate(atom/target, intensity = DEFAULT_RADIATION_INTENSITY)
	if (!can_irradiate_basic(target))
		return FALSE

	irradiate_after_basic_checks(target, intensity)
	return TRUE

/datum/controller/subsystem/radiation/proc/irradiate_after_basic_checks(atom/target, intensity = DEFAULT_RADIATION_INTENSITY)
	PRIVATE_PROC(TRUE)

	if (ishuman(target) && wearing_rad_protected_clothing(target))
		return FALSE

	var/datum/component/irradiated/irradiated_component = target.GetComponent(/datum/component/irradiated)
	if(!irradiated_component)
		irradiated_component = target.AddComponent(/datum/component/irradiated)
		if(!irradiated_component)
			return FALSE

	irradiated_component.adjust_intensity(intensity)

	return TRUE

/// Napromieniowanie od środka (leki, wypita substancja, wszczep): strój ochronny nie pomaga.
/// W Bee ten sam blok jest powtarzany w każdym reagencie.
/datum/controller/subsystem/radiation/proc/irradiate_internal(atom/target, intensity)
	if (!can_irradiate_basic(target))
		return FALSE

	var/datum/component/irradiated/irradiated_component = target.GetComponent(/datum/component/irradiated)
	if(!irradiated_component)
		irradiated_component = target.AddComponent(/datum/component/irradiated)
		if(!irradiated_component)
			return FALSE

	irradiated_component.adjust_intensity(intensity)
	return TRUE

/// Czy cel w ogóle może zostać napromieniowany. Nie sprawdza stroju.
/datum/controller/subsystem/radiation/proc/can_irradiate_basic(atom/target)
	if (!CAN_IRRADIATE(target))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_RADIMMUNE))
		return FALSE

	return TRUE

/// Czy człowiek jest od stóp do głów w stroju chroniącym przed promieniowaniem.
/// Strój chroni z cechą TRAIT_RADIATION_PROTECTED_CLOTHING; Aquila nadaje ją też każdemu ubraniu z pancerzem `rad` >= 100.
/datum/controller/subsystem/radiation/proc/wearing_rad_protected_clothing(mob/living/carbon/human/human)
	for (var/obj/item/bodypart/limb as anything in human.bodyparts)
		var/protected = FALSE

		for (var/obj/item/clothing as anything in human.get_clothing_on_part(limb))
			if (HAS_TRAIT(clothing, TRAIT_RADIATION_PROTECTED_CLOTHING))
				protected = TRUE
				break

		if (!protected)
			return FALSE

	return TRUE

/// Największa odległość, z jakiej kolektor dostaje energię z impulsu
#define RAD_COLLECTOR_MAX_RANGE 12

/// Aquila: kolektory promieniowania zostają (silniki SM i osobliwości na mapach).
/// Dostają siłę w starej skali, osłabioną jak dawna fala: 1/(odległość × spadek)² razy izolacja na linii.
/datum/controller/subsystem/radiation/proc/feed_collectors(turf/source_turf, collector_power, collector_falloff = 1)
	for (var/obj/machinery/power/rad_collector/collector as anything in GLOB.rad_collectors)
		if (collector.z != source_turf.z)
			continue
		var/distance = get_dist(source_turf, collector)
		if (distance > RAD_COLLECTOR_MAX_RANGE)
			continue
		var/turf/collector_turf = get_turf(collector)
		var/insulation = 1
		// Kafelek kolektora się nie liczy: dawna fala trafiała kolektor, zanim jego izolacja ją osłabiła
		for (var/turf/turf_in_between in getline(source_turf, collector_turf) - source_turf - collector_turf)
			insulation *= turf_in_between.rad_insulation
			for (var/atom/on_turf as anything in turf_in_between.contents)
				insulation *= on_turf.rad_insulation
			if (insulation <= 0)
				break
		if (insulation <= 0)
			continue
		collector.receive_radiation_pulse(collector_power * insulation / (max(distance, 1) * collector_falloff) ** 2)

#undef RAD_COLLECTOR_MAX_RANGE
