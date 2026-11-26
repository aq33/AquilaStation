// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the vampire mode obeys the weighted rotation antagonist limit (WEIGHTED_MAX_ANTAGS VAMPIRE)
/datum/unit_test/aquila_vampire_weighted_cap

/datum/unit_test/aquila_vampire_weighted_cap/Run()
	var/old_rep = CONFIG_GET(flag/use_antag_rep)
	CONFIG_SET(flag/use_antag_rep, FALSE)
	var/datum/game_mode/vampire/mode = new
	var/list/minds = list()
	for(var/i in 1 to 3)
		var/datum/mind/candidate = new("aquila_vampire_test_[i]")
		minds += candidate
		mode.antag_candidates += candidate
	mode.weighted_antag_cap = 0
	var/started = mode.pre_setup()
	CONFIG_SET(flag/use_antag_rep, old_rep)
	TEST_ASSERT_EQUAL(length(mode.pre_vamps), 0, "Vampires picked over a used up weighted limit")
	TEST_ASSERT(!started, "The mode started without vampires")
	for(var/datum/mind/candidate as anything in minds)
		candidate.special_role = null
	qdel(mode)

/// AQUILA - better manipulators lower the limb grower's reagent use (a local var used to shadow the machine var)
/datum/unit_test/aquila_limbgrower_manipulator

/datum/unit_test/aquila_limbgrower_manipulator/Run()
	var/obj/machinery/limbgrower/grower = allocate(/obj/machinery/limbgrower)
	TEST_ASSERT_EQUAL(grower.production_coefficient, 1, "Stock limb grower coefficient")
	for(var/obj/item/stock_parts/manipulator/old_part in grower.component_parts)
		grower.component_parts -= old_part
		qdel(old_part)
	grower.component_parts += new /obj/item/stock_parts/manipulator/femto(grower)
	grower.RefreshParts()
	TEST_ASSERT_EQUAL(grower.production_coefficient, 0.25, "Femto manipulator coefficient")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
