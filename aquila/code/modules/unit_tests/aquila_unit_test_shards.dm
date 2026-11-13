// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - części testów CI to ciągłe kawałki listy: razem każdy test dokładnie raz, w tej samej kolejności; złe ustawienie to cała lista
/datum/unit_test/aquila_unit_test_shards

/datum/unit_test/aquila_unit_test_shards/Run()
	var/list/tests = list("a", "b", "c", "d", "e", "f", "g")
	var/list/joined = list()
	for(var/index in 1 to 3)
		var/list/part = aquila_unit_test_shard_of(tests, "[index]/3")
		TEST_ASSERT(length(part) >= 2 && length(part) <= 3, "Part [index]/3 has [length(part)] of 7 tests")
		joined += part
	TEST_ASSERT(length(joined) == length(tests) && !length(tests - joined), "The parts do not cover every test exactly once: [joined.Join(",")]")
	TEST_ASSERT(joined.Join(",") == tests.Join(","), "The parts joined in order are [joined.Join(",")], not the original order")
	var/list/second = aquila_unit_test_shard_of(tests, "2/3")
	TEST_ASSERT(second.Join(",") == "c,d", "Part 2/3 is [second.Join(",")], expected c,d")
	TEST_ASSERT(length(aquila_unit_test_shard_of(tests, "4/3")) == length(tests), "A part number above the count did not run every test")
	TEST_ASSERT(length(aquila_unit_test_shard_of(tests, "abc")) == length(tests), "A malformed setting did not run every test")
	TEST_ASSERT(length(aquila_unit_test_shard_of(tests, "1.5/3")) == length(tests), "A fractional part number did not run every test")

#undef TEST_ASSERT
