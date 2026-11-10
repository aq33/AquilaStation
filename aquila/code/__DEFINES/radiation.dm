// Promieniowanie z BeeStation/BeeStation-Hornet#13442 (port tg): impuls z natężeniem,
// izolacja mnożona po linii, komponent /datum/component/irradiated 0-100%.
// Plik dołączany wcześnie w nsv13.dme zamiast starego code/__DEFINES/radiation.dm,
// bo z tych makr korzysta core (leki, gatunki, burza, kostiumy).

/// Ile natężenia (%) potrzeba do wypadania włosów
#define RAD_MOB_HAIRLOSS 20
/// Szansa na sekundę, że włosy zaczną wypadać powyżej progu
#define RAD_MOB_HAIRLOSS_PROB 7.5

/// Ile natężenia (%) potrzeba do wymiotów
#define RAD_MOB_VOMIT 60
/// Szansa na sekundę na wymioty
#define RAD_MOB_VOMIT_PROB 0.5

/// Ile natężenia (%) potrzeba do omdleń
#define RAD_MOB_KNOCKDOWN 40
/// Szansa na sekundę na omdlenie
#define RAD_MOB_KNOCKDOWN_PROB 0.5
/// Czas omdlenia
#define RAD_MOB_KNOCKDOWN_AMOUNT 3

/// Ile natężenia (%) potrzeba, żeby IPC dostał uraz mózgu (NSV13, w miejsce mutacji)
#define RAD_MOB_IPC_TRAUMA 75
/// Szansa na sekundę na uraz mózgu IPC
#define RAD_MOB_IPC_TRAUMA_PROB 0.5

#define RAD_NO_INSULATION 1.0 // Rzeczy, które nie powinny osłabiać promieniowania
#define RAD_VERY_LIGHT_INSULATION 0.9 // Dźwigary
#define RAD_LIGHT_INSULATION 0.8
#define RAD_MEDIUM_INSULATION 0.7 // Zwykłe ściany
#define RAD_HEAVY_INSULATION 0.6 // Ściany wzmocnione
#define RAD_EXTREME_INSULATION 0.5 // Kolektory promieniowania, basen
#define RAD_FULL_INSULATION 0 // Zatrzymuje promieniowanie całkowicie

/// Domyślne natężenie impulsu
#define DEFAULT_RADIATION_INTENSITY 5

/// Domyślne natężenie impulsu uranu
#define URANIUM_IRRADIATION_INTENSITY DEFAULT_RADIATION_INTENSITY

/// Minimalny czas przebywania obok uranu, zanim zacznie napromieniowywać
#define URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME (3 SECONDS)

/// Wartości zwracane przez [/proc/get_perceived_radiation_danger]
// Przy zmianie popraw też /datum/looping_sound/geiger.
#define PERCEIVED_RADIATION_DANGER_LOW 1
#define PERCEIVED_RADIATION_DANGER_MEDIUM 2
#define PERCEIVED_RADIATION_DANGER_HIGH 3
#define PERCEIVED_RADIATION_DANGER_EXTREME 4

/// Czas, po którym licznik Geigera bez impulsów wraca do normy
#define TIME_WITHOUT_RADIATION_BEFORE_RESET (5 SECONDS)

/// Naturalny zanik natężenia u człowieka na sekundę (Aquila, w Bee go nie ma).
/// 0,1%/s: lekkie napromieniowanie (20%) mija w ok. 3,5 min, pełne (100%) w ok. 17 min.
#define RADIATION_NATURAL_DECAY_PER_SECOND 0.1

/// Aquila: przelicznik starej skali radów (dawne `radiation`, `irradiate` pocisków) na natężenie w %.
/// Stare 2000 radów (wymioty i omdlenia) to 60%, 300 radów pocisku rentgenowskiego to 9%.
#define RAD_LEGACY_TO_INTENSITY 0.03
/// Aquila: to samo dla dawnej siły impulsu/rad_act() u celu, która w mobie dawała 20% (RAD_MOB_COEFFICIENT).
#define RAD_LEGACY_PULSE_TO_INTENSITY (0.2 * RAD_LEGACY_TO_INTENSITY)

/// Czy ten atom w ogóle może zostać napromieniowany
#define CAN_IRRADIATE(atom) (ishuman(##atom) || isitem(##atom))

// Cechy

/// Atom jest napromieniowany
#define TRAIT_IRRADIATED "iraddiated"

/// Szkodliwe skutki promieniowania (toksyny, oparzenia, mutacje) są wstrzymane
#define TRAIT_HALT_RADIATION_EFFECTS "halt_radiation_effects"

/// Ten strój chroni przed promieniowaniem. Nadawany samemu ubraniu, nie przez clothing_traits.
#define TRAIT_RADIATION_PROTECTED_CLOTHING "radiation_protected_clothing"

/// Przedmiot z tą cechą dalej dostaje COMSIG_IN_RANGE_OF_IRRADIATION, choć już jest napromieniowany
#define TRAIT_BYPASS_EARLY_IRRADIATED_CHECK "radiation_bypass_early_irradiated_check"

/// Promieniowanie leczy zamiast szkodzić: natężenie szybko spada, bez obrażeń i mutacji (podludzie)
#define TRAIT_RADHEALER "rad_healer"

// Sygnały

/// Z SSradiation, przed możliwym napromieniowaniem: w zasięgu jest źródło.
/// Nie znaczy, że promieniowanie dotrze.
/// (datum/radiation_pulse_information/pulse_information, insulation_to_target)
#define COMSIG_IN_RANGE_OF_IRRADIATION "in_range_of_irradiation"

/// Cel może zostać napromieniowany, tuż przed rzutem szansy.
/// (datum/radiation_pulse_information/pulse_information)
#define COMSIG_IN_THRESHOLD_OF_IRRADIATION "pre_potential_irradiation_within_range"
	#define CANCEL_IRRADIATION (1 << 0)
	/// Pomija sprawdzanie minimalnego czasu ekspozycji
	#define SKIP_MINIMUM_EXPOSURE_TIME_CHECK (1 << 1)

/// Skanowanie licznikiem Geigera. (mob/user, obj/item/geiger_counter/geiger_counter)
#define COMSIG_GEIGER_COUNTER_SCAN "geiger_counter_scan"
	/// Jeśli żaden handler go nie ustawi, licznik zgłasza brak skażenia
	#define COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL (1 << 0)

/// Alert napromieniowania
#define ALERT_IRRADIATED "irradiated"
