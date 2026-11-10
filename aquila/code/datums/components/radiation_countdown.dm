// Odliczanie przed napromieniowaniem z BeeStation/BeeStation-Hornet#13442 (port tg).

// Dłużej niż jakikolwiek minimalny czas ekspozycji
#define TIME_UNTIL_DELETION (10 SECONDS)

/// Zaczyna odliczanie, zanim cel może zostać napromieniowany.
/// Dodawany przez SSradiation, gdy impuls ma minimalny czas ekspozycji. Po chwili sam znika.
/datum/component/radiation_countdown
	/// Kiedy komponent został dodany
	var/time_added

	/// Najkrótszy minimalny czas przed napromieniowaniem.
	var/minimum_exposure_time

/datum/component/radiation_countdown/Initialize(minimum_exposure_time)
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	src.minimum_exposure_time = minimum_exposure_time

	time_added = world.time

	if (ismob(parent))
		to_chat(parent, span_userdanger("Powietrze wokół ciebie robi się ciepłe... może lepiej stąd odejść."))

	start_deletion_timer()

/datum/component/radiation_countdown/proc/start_deletion_timer()
	addtimer(CALLBACK(src, PROC_REF(remove_self)), TIME_UNTIL_DELETION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/radiation_countdown/proc/remove_self()
	if (ismob(parent) && !HAS_TRAIT(parent, TRAIT_IRRADIATED))
		to_chat(parent, span_notice("Powietrze tutaj wydaje się bezpieczniejsze."))

	qdel(src)

/datum/component/radiation_countdown/RegisterWithParent()
	RegisterSignal(parent, COMSIG_IN_THRESHOLD_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation_within_range))

/datum/component/radiation_countdown/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_IN_THRESHOLD_OF_IRRADIATION)

/datum/component/radiation_countdown/proc/on_pre_potential_irradiation_within_range(datum/source, datum/radiation_pulse_information/pulse_information)
	SIGNAL_HANDLER

	minimum_exposure_time = min(minimum_exposure_time, pulse_information.minimum_exposure_time)

	start_deletion_timer()

	// Igrał z ogniem, teraz może zostać napromieniowany
	if (world.time - time_added >= minimum_exposure_time)
		return SKIP_MINIMUM_EXPOSURE_TIME_CHECK

	return CANCEL_IRRADIATION

#undef TIME_UNTIL_DELETION
