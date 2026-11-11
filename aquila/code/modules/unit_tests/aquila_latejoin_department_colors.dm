// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - okno „Wybierz profesję” pokazuje działy w barwach Żandarmerii, Orlenu i InPostu, nie w starych kolorach
/datum/unit_test/aquila_latejoin_department_colors

/datum/unit_test/aquila_latejoin_department_colors/Run()
	var/list/colors = list()
	for(var/list/department as anything in GLOB.latejoin_menu.get_departments())
		colors[department["name"]] = department["color"]
	TEST_ASSERT_EQUAL(colors["Ochrona"], "#5fbf7a", "Ochrona nie ma zieleni Żandarmerii")
	TEST_ASSERT_EQUAL(colors["Inżynieria"], "#e03a3e", "Inżynieria nie ma czerwieni Orlenu")
	TEST_ASSERT_EQUAL(colors["Zaopatrzenie"], "#ffcd00", "Zaopatrzenie nie ma żółci InPostu")

#undef TEST_ASSERT_EQUAL
