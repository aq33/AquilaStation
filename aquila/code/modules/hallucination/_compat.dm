// AQUILA - nazwy z Bee/tg, których używają pliki halucynacji, przełożone na nasze odpowiedniki

#define HALLUCINATION_FILE "hallucination.json"

#define ALERT_FIRE "fire"
#define ALERT_TEMPERATURE "temp"
#define ALERT_NOT_ENOUGH_OXYGEN "not_enough_oxy"
#define ALERT_NOT_ENOUGH_PLASMA "not_enough_tox"
#define ALERT_NOT_ENOUGH_CO2 "not_enough_co2"
#define ALERT_TOO_MUCH_OXYGEN "too_much_oxy"
#define ALERT_TOO_MUCH_PLASMA "too_much_tox"
#define ALERT_TOO_MUCH_CO2 "too_much_co2"

#define AIRLOCK_LIGHT_BOLTS "bolts"
#define MESSENGER_RINGTONE_DEFAULT "beep"
#define PASSTRANSPARENT PASSGLASS
/// U nas nie ma testu tworzenia wszystkich atomów z listą wyjątków
#define CREATION_TEST_IGNORE_SUBTYPES(path)

/// tg: pierwszy człon imienia
/proc/first_name(given_name)
	var/list/split_name = splittext(given_name, " ")
	return split_name[1]

/// tg: ostatni człon imienia
/proc/last_name(given_name)
	var/list/split_name = splittext(given_name, " ")
	return split_name[length(split_name)]

/// Ludzie w grze (w tg GLOB.human_list)
/proc/hallucination_human_list()
	var/list/humans = list()
	for(var/mob/living/carbon/human/human in GLOB.carbon_list)
		humans += human
	return humans
