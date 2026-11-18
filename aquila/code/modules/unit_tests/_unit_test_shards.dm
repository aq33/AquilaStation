/**
 * AQUILA - podział testów między równoległe joby CI.
 *
 * Zmienna środowiskowa UNIT_TEST_SHARD="numer/liczba" (np. "2/3") zostawia numer-ty ciągły kawałek posortowanej listy.
 * Ciągły, nie co liczba-ty test: część testów zależy od poprzedników w kolejności, więc sąsiedztwo zostaje jak przy
 * przebiegu wszystkich testów naraz (co trzeci test psuł np. sabre_shuttle_rotated). Bez zmiennej
 * (gra, lokalny serwer) wykonują się wszystkie testy. Zmienną ustawia .github/workflows/continuous_integration.yml
 * i tools/local_ci (--czesci).
 *
 * Kawałki mają trwać podobnie długo, a nie mieć po tyle samo testów: kilkanaście testów trwa po kilkadziesiąt sekund
 * (planety), a reszta ułamki sekundy, więc przy równej liczbie testów jedna część trwała trzy razy dłużej od pozostałych.
 * Czasy wolnych testów są w _unit_test_weights.dm (odświeża je tools/ci/unit_test_weights.py).
 *
 * Testy z aquila_unit_test_every_shard() nie biorą udziału w podziale: idą na koniec każdej części (i całej listy).
 */

/// Waga testu, którego nie ma w aquila_unit_test_weights() (średni czas krótkiego testu w sekundach)
#define AQUILA_UNIT_TEST_DEFAULT_WEIGHT 0.05

/proc/aquila_unit_test_shard(list/tests)
	var/list/every_shard = tests & aquila_unit_test_every_shard()
	var/list/rest = tests - every_shard
	var/setting = world.GetConfig("env", "UNIT_TEST_SHARD")
	if(setting)
		rest = aquila_unit_test_shard_of(rest, setting)
	return rest + every_shard

/// Testy wykonywane na samym końcu każdej części, bo sprawdzają, co zostawiły po sobie wszystkie poprzednie
/proc/aquila_unit_test_every_shard()
	. = list()
#ifdef UNIT_TESTS
	. += /datum/unit_test/aquila_gc_guard
#endif

/// Część listy testów dla ustawienia "numer/liczba"; przy złym ustawieniu cała lista. Wagi domyślnie z aquila_unit_test_weights()
/proc/aquila_unit_test_shard_of(list/tests, setting, list/weights)
	var/list/parts = splittext(setting, "/")
	var/index = length(parts) == 2 ? text2num(parts[1]) : null
	var/count = length(parts) == 2 ? text2num(parts[2]) : null
	if(!index || !count || index < 1 || index > count || index != round(index) || count != round(count))
		log_world("UNIT_TEST_SHARD=[setting] nie ma postaci numer/liczba, wykonuję wszystkie testy")
		return tests
	if(!weights)
		weights = aquila_unit_test_weights()
	var/total = 0
	for(var/test in tests)
		total += weights["[test]"] || AQUILA_UNIT_TEST_DEFAULT_WEIGHT
	. = list()
	var/before = 0
	for(var/test in tests)
		var/weight = weights["[test]"] || AQUILA_UNIT_TEST_DEFAULT_WEIGHT
		// Test idzie do części, w której leży środek jego odcinka na osi czasu: części są ciągłe, a każdy test jest w dokładnie jednej
		if(clamp(round((before + weight / 2) * count / total) + 1, 1, count) == index)
			. += test
		before += weight
	log_world("Testy: część [index]/[count], [length(.)] z [length(tests)]")

#undef AQUILA_UNIT_TEST_DEFAULT_WEIGHT
