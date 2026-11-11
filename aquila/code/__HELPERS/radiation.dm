// Promieniowanie z BeeStation/BeeStation-Hornet#13442 (port tg). Zastępuje stare code/__HELPERS/radiation.dm.

/**
 * Wysyła impuls promieniowania ze źródła.
 *
 * Zbiera ludzi i przedmioty leżące bezpośrednio na kafelkach w zasięgu `max_range` (0 = tylko kafelek źródła).
 * Liczba zaczynająca się od 1 jest mnożona przez izolację (`rad_insulation`) wszystkiego na linii do celu.
 * Jeśli spadnie do `threshold` lub niżej, cel jest bezpieczny. Inaczej człowiek dostaje `intensity` (%),
 * a przedmiot zostaje skażony z szansą `intensity`%.
 * Większy zasięg zwykle idzie z niższym progiem i odwrotnie.
 *
 * `minimum_exposure_time`: cel musi przebywać przy jakimkolwiek źródle przez ten czas, zanim impuls zadziała.
 *
 * Aquila: `collector_power` to siła w starej skali (jak dawne `radiation_pulse(src, siła)`), którą dostają
 * kolektory promieniowania w zasięgu (`/obj/machinery/power/rad_collector`), z dawnym spadkiem 1/(odległość × `collector_falloff`)².
 * Ludzi i przedmiotów nie dotyczy.
 */
/proc/radiation_pulse(
	atom/source,
	max_range,
	threshold,
	intensity = DEFAULT_RADIATION_INTENSITY,
	minimum_exposure_time = 0,
	collector_power = 0,
	collector_falloff = 1,
)
	if(!SSradiation.can_fire || QDELETED(source))
		return

	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return

	if(collector_power > 0)
		SSradiation.feed_collectors(source_turf, collector_power, collector_falloff)

	if(intensity <= 0)
		return

	var/datum/radiation_pulse_information/pulse_information = new
	pulse_information.source_ref = WEAKREF(source)
	// Aquila: kafelek i nazwa zostają, gdy źródło zniknie przed przetworzeniem impulsu (granat, meteor)
	pulse_information.source_turf = source_turf
	pulse_information.source_name = "[source]"
	// Aquila: osłona samego źródła. Kafelek źródła nie leży na linii do celu, więc pręt w basenie na wypalone paliwo
	// albo w reaktorze osłaniają tylko kafelek i pojemniki, w których leży (dawniej źródło w basenie miało 10% siły).
	if(source != source_turf)
		var/source_insulation = source_turf.rad_insulation
		for(var/atom/container = source.loc; container && container != source_turf; container = container.loc)
			source_insulation *= container.rad_insulation
		pulse_information.source_insulation = source_insulation
	pulse_information.max_range = max_range
	pulse_information.threshold = threshold
	pulse_information.intensity = intensity
	pulse_information.minimum_exposure_time = minimum_exposure_time
	pulse_information.turfs_to_process = RANGE_TURFS(max_range, source_turf)

	SSradiation.processing += pulse_information

	return TRUE

/datum/radiation_pulse_information
	var/datum/weakref/source_ref
	/// Aquila: kafelek źródła z chwili impulsu
	var/turf/source_turf
	/// Aquila: nazwa źródła do logu
	var/source_name
	/// Aquila: iloczyn izolacji kafelka i pojemników źródła
	var/source_insulation = 1
	var/max_range
	var/threshold
	var/intensity
	var/minimum_exposure_time
	var/list/turfs_to_process

#define MEDIUM_RADIATION_THRESHOLD_RANGE 0.5
#define EXTREME_RADIATION_INTENSITY 30

/// Odczuwane „zagrożenie” impulsem przy danej izolacji do celu.
/// Zwraca PERCEIVED_RADIATION_DANGER_*, zob. [aquila/code/__DEFINES/radiation.dm]
/proc/get_perceived_radiation_danger(datum/radiation_pulse_information/pulse_information, insulation_to_target)
	if (insulation_to_target > pulse_information.threshold)
		// Możemy zostać napromieniowani! Skala zależna od natężenia
		if (pulse_information.intensity >= EXTREME_RADIATION_INTENSITY)
			return PERCEIVED_RADIATION_DANGER_EXTREME
		else
			return PERCEIVED_RADIATION_DANGER_HIGH
	else
		// Poza progiem, ale jak daleko?
		if (insulation_to_target / max(pulse_information.threshold, 0.001) <= MEDIUM_RADIATION_THRESHOLD_RANGE)
			return PERCEIVED_RADIATION_DANGER_MEDIUM
		else
			return PERCEIVED_RADIATION_DANGER_LOW

#undef MEDIUM_RADIATION_THRESHOLD_RANGE
#undef EXTREME_RADIATION_INTENSITY
