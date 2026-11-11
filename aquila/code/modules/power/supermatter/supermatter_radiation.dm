// Promieniowanie naszej supermaterii po porcie BeeStation/BeeStation-Hornet#13442.
// Sama supermateria zostaje nasza (auxmos), wzór na impuls jest z Bee (supermatter_extra_effects.dm),
// a kolektory dostają dawną siłę `last_rads`, więc silniki SM dają podobną moc jak przedtem.

// Moc powyżej tej liczby jest obcinana
#define SM_RAD_MAX_ACCEPTED_POWER_OUTPUT 5000
// Przy najwyższej mocy i pełnej integralności próg spada do 0
#define SM_RAD_THRESHOLD_EQUATION_SLOPE (-1 / SM_RAD_MAX_ACCEPTED_POWER_OUTPUT)
// Im wyżej, tym szybciej niska integralność obniża próg
#define SM_RAD_INTEGRITY_EXPONENTIAL_DEGREE 2
// Przy SM_RAD_INTEGRITY_MIN_NUDGABLE_AMOUNT moc liczy się jako co najmniej SM_RAD_INTEGRITY_MAX_POWER_NUDGE
#define SM_RAD_INTEGRITY_MAX_POWER_NUDGE 1500
#define SM_RAD_INTEGRITY_MIN_NUDGABLE_AMOUNT 0.7

#define SM_RAD_INTENSITY_AT_FULL_INTEGRITY 0.03
#define SM_RAD_INTENSITY_AT_ZERO_INTEGRITY 0.4
#define SM_RAD_INTENSITY_EQUATION_SLOPE (SM_RAD_INTENSITY_AT_ZERO_INTEGRITY - SM_RAD_INTENSITY_AT_FULL_INTEGRITY)

/// Impuls promieniowania z kryształu. `collector_power` to dawna siła (`last_rads`) dla kolektorów.
/obj/machinery/power/supermatter_crystal/proc/emit_radiation_pulse(collector_power)
	// Z mocą rośnie promieniowanie. Typowa SM na N2 ma około 1500.
	var/power_factor = min(power, SM_RAD_MAX_ACCEPTED_POWER_OUTPUT)

	var/integrity = 1 - CLAMP01(damage / explosion_point)

	// Spadek integralności podnosi moc do minimum, żeby wyłączenie emiterów przy rozpadającej się SM nie zatrzymało promieniowania
	var/integrity_power_nudge = LERP(SM_RAD_INTEGRITY_MAX_POWER_NUDGE, 0, CLAMP01((integrity - SM_RAD_INTEGRITY_MIN_NUDGABLE_AMOUNT) / (1 - SM_RAD_INTEGRITY_MIN_NUDGABLE_AMOUNT)))

	power_factor = max(power_factor, integrity_power_nudge)

	// Przy zwykłej mocy N2 i pełnej integralności wychodzi 0,7: zatrzymają to ściany albo osłony przeciwradiacyjne.
	// Im niższa integralność, tym więcej przechodzi.
	var/threshold
	switch(integrity)
		if(0)
			threshold = power_factor ? 0 : 1
		if(1)
			threshold = (SM_RAD_THRESHOLD_EQUATION_SLOPE * power_factor + 1)
		else
			threshold = (SM_RAD_THRESHOLD_EQUATION_SLOPE * power_factor + 1) ** ((1 / integrity) ** SM_RAD_INTEGRITY_EXPONENTIAL_DEGREE)

	// Natężenie zależy tylko od integralności, żeby rozpadająca się SM była groźniejsza
	var/intensity = (SM_RAD_INTENSITY_EQUATION_SLOPE * (1 - integrity)) + SM_RAD_INTENSITY_AT_FULL_INTEGRITY

	radiation_pulse(
		src,
		max_range = 8,
		threshold = threshold,
		intensity = intensity * 30,
		collector_power = collector_power,
	)

#undef SM_RAD_MAX_ACCEPTED_POWER_OUTPUT
#undef SM_RAD_THRESHOLD_EQUATION_SLOPE
#undef SM_RAD_INTEGRITY_EXPONENTIAL_DEGREE
#undef SM_RAD_INTEGRITY_MAX_POWER_NUDGE
#undef SM_RAD_INTEGRITY_MIN_NUDGABLE_AMOUNT
#undef SM_RAD_INTENSITY_AT_FULL_INTEGRITY
#undef SM_RAD_INTENSITY_AT_ZERO_INTEGRITY
#undef SM_RAD_INTENSITY_EQUATION_SLOPE
