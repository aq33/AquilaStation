// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - części testów CI to ciągłe kawałki listy: razem każdy test dokładnie raz, w tej samej kolejności; złe ustawienie to cała lista
/datum/unit_test/aquila_unit_test_shards

/datum/unit_test/aquila_unit_test_shards/Run()
	var/list/tests = list("a", "b", "c", "d", "e", "f", "g")
	var/list/joined = list()
	for(var/index in 1 to 3)
		var/list/part = aquila_unit_test_shard_of(tests, "[index]/3", list())
		TEST_ASSERT(length(part) >= 2 && length(part) <= 3, "Part [index]/3 has [length(part)] of 7 tests")
		joined += part
	TEST_ASSERT(length(joined) == length(tests) && !length(tests - joined), "The parts do not cover every test exactly once: [joined.Join(",")]")
	TEST_ASSERT(joined.Join(",") == tests.Join(","), "The parts joined in order are [joined.Join(",")], not the original order")
	var/list/second = aquila_unit_test_shard_of(tests, "2/3", list())
	TEST_ASSERT(second.Join(",") == "c,d,e", "Part 2/3 is [second.Join(",")], expected c,d,e")
	TEST_ASSERT(length(aquila_unit_test_shard_of(tests, "4/3")) == length(tests), "A part number above the count did not run every test")
	TEST_ASSERT(length(aquila_unit_test_shard_of(tests, "abc")) == length(tests), "A malformed setting did not run every test")
	TEST_ASSERT(length(aquila_unit_test_shard_of(tests, "1.5/3")) == length(tests), "A fractional part number did not run every test")
	// Strażnik wycieków idzie na koniec każdej części, niezależnie od miejsca na posortowanej liście
	var/list/with_guard = aquila_unit_test_shard(list(/datum/unit_test/aquila_gc_guard, /datum/unit_test/aquila_unit_test_shards))
	TEST_ASSERT(length(with_guard) && with_guard[length(with_guard)] == /datum/unit_test/aquila_gc_guard, "The leak guard is not the last test of the part: [with_guard.Join(",")]")

/// AQUILA - części testów mają trwać podobnie długo: wolny test dostaje część dla siebie, a nie ciągnie za sobą trzeciej części listy
/datum/unit_test/aquila_unit_test_shards_weighted

/datum/unit_test/aquila_unit_test_shards_weighted/Run()
	var/list/tests = list("a", "b", "c", "d", "e", "f", "g")
	// "c" trwa tyle, co sto pozostałych testów
	var/list/weights = list("c" = 5)
	var/list/joined = list()
	var/list/expected = list("a,b", "c", "d,e,f,g")
	for(var/index in 1 to 3)
		var/list/part = aquila_unit_test_shard_of(tests, "[index]/3", weights)
		TEST_ASSERT(part.Join(",") == expected[index], "Part [index]/3 is [part.Join(",")], expected [expected[index]]")
		joined += part
	TEST_ASSERT(joined.Join(",") == tests.Join(","), "The weighted parts joined in order are [joined.Join(",")], not the original order")
	// Prawdziwa lista testów z prawdziwymi wagami: każdy test dokładnie raz i żadna część nie jest pusta
	var/list/real_tests = subtypesof(/datum/unit_test)
	var/list/real_joined = list()
	for(var/index in 1 to 3)
		var/list/part = aquila_unit_test_shard_of(real_tests, "[index]/3")
		TEST_ASSERT(length(part), "Part [index]/3 of the real test list is empty")
		real_joined += part
	TEST_ASSERT(length(real_joined) == length(real_tests) && !length(real_tests - real_joined), "The real parts hold [length(real_joined)] tests, the list has [length(real_tests)]")

#undef TEST_ASSERT
