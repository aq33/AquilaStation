/**
 * AQUILA - podział testów między równoległe joby CI.
 *
 * Zmienna środowiskowa UNIT_TEST_SHARD="numer/liczba" (np. "2/3") zostawia numer-ty ciągły kawałek posortowanej listy.
 * Ciągły, nie co liczba-ty test: część testów zależy od poprzedników w kolejności, więc sąsiedztwo zostaje jak przy
 * przebiegu wszystkich testów naraz (co trzeci test psuł np. sabre_shuttle_rotated). Bez zmiennej
 * (gra, lokalny serwer) wykonują się wszystkie testy. Zmienną ustawia .github/workflows/continuous_integration.yml
 * i tools/local_ci (--czesci).
 */
/proc/aquila_unit_test_shard(list/tests)
	var/setting = world.GetConfig("env", "UNIT_TEST_SHARD")
	if(!setting)
		return tests
	return aquila_unit_test_shard_of(tests, setting)

/// Część listy testów dla ustawienia "numer/liczba"; przy złym ustawieniu cała lista
/proc/aquila_unit_test_shard_of(list/tests, setting)
	var/list/parts = splittext(setting, "/")
	var/index = length(parts) == 2 ? text2num(parts[1]) : null
	var/count = length(parts) == 2 ? text2num(parts[2]) : null
	if(!index || !count || index < 1 || index > count || index != round(index) || count != round(count))
		log_world("UNIT_TEST_SHARD=[setting] nie ma postaci numer/liczba, wykonuję wszystkie testy")
		return tests
	var/first = round((index - 1) * length(tests) / count) + 1
	var/last = round(index * length(tests) / count)
	. = last >= first ? tests.Copy(first, last + 1) : list()
	log_world("Testy: część [index]/[count], [length(.)] z [length(tests)]")
