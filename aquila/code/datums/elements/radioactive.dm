// Element radioactive z BeeStation/BeeStation-Hornet#13442 (port tg). Zastępuje komponent /datum/component/radioactive.
#define DELAY_BETWEEN_RADIATION_PULSES (3 SECONDS)

/// Ten atom regularnie wysyła impulsy promieniowania.
/datum/element/radioactive
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// Zasięg w kafelkach
	var/range
	/// Próg izolacji
	var/threshold
	/// Natężenie impulsu
	var/intensity
	/// Minimalny czas ekspozycji
	var/minimum_exposure_time

	var/list/radioactive_objects = list()

/datum/element/radioactive/New()
	START_PROCESSING(SSdcs, src)

/datum/element/radioactive/Attach(
	datum/target,
	range = 3,
	threshold = RAD_LIGHT_INSULATION,
	intensity = URANIUM_IRRADIATION_INTENSITY,
	minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)

	. = ..()

	radioactive_objects[target] = world.time

	src.range = range
	src.threshold = threshold
	src.intensity = intensity
	src.minimum_exposure_time = minimum_exposure_time

/datum/element/radioactive/Detach(datum/source, ...)
	radioactive_objects -= source
	return ..()

/datum/element/radioactive/process(delta_time)
	for (var/radioactive_object in radioactive_objects)
		if (world.time - radioactive_objects[radioactive_object] < DELAY_BETWEEN_RADIATION_PULSES)
			continue

		radiation_pulse(
			radioactive_object,
			max_range = range,
			threshold = threshold,
			intensity = intensity,
			minimum_exposure_time = minimum_exposure_time,
		)

		radioactive_objects[radioactive_object] = world.time

#undef DELAY_BETWEEN_RADIATION_PULSES

/// Aquila: promieniotwórczość na określony czas (w miejsce starego komponentu z czasem połowicznego rozpadu).
/// Te same argumenty co element, plus czas, po którym element znika.
/proc/add_temporary_radioactivity(datum/target, duration, range = 3, threshold = RAD_LIGHT_INSULATION, intensity = URANIUM_IRRADIATION_INTENSITY, minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME)
	if (QDELETED(target))
		return
	target.AddElement(/datum/element/radioactive, range, threshold, intensity, minimum_exposure_time)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/datum, _RemoveElement), list(/datum/element/radioactive, range, threshold, intensity, minimum_exposure_time)), duration)
