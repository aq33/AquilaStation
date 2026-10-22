// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - laser przesyłu mocy z Monke: terminal za plecami, wzór sprzedaży i obrażenia wiązki
/datum/unit_test/transmission_laser

/datum/unit_test/transmission_laser/Run()
	var/turf/corner = run_loc_floor_bottom_left
	// Bez terminala laser od razu jest zepsuty
	var/obj/machinery/power/transmission_laser/lonely = allocate(/obj/machinery/power/transmission_laser, corner)
	TEST_ASSERT(lonely.machine_stat & BROKEN, "PTL without a terminal was not broken")
	qdel(lonely)

	// Laser patrzy na południe, więc terminal stoi kratkę nad kwadratem 3x3
	var/turf/terminal_turf = locate(corner.x + 1, corner.y + 3, corner.z)
	TEST_ASSERT(terminal_turf, "No room for the PTL terminal")
	var/obj/machinery/power/terminal/terminal = allocate(/obj/machinery/power/terminal, terminal_turf)
	var/obj/machinery/power/transmission_laser/laser = allocate(/obj/machinery/power/transmission_laser, corner)
	TEST_ASSERT_EQUAL(laser.terminal, terminal, "PTL did not find the terminal behind it")
	TEST_ASSERT_EQUAL(terminal.master, laser, "Terminal master was not set to the PTL")
	TEST_ASSERT(!(laser.machine_stat & BROKEN), "PTL with a terminal was broken")

	// Wzór nasyca się: 5 MW to kilkanaście kredytów, 100 MW niewiele ponad 25
	TEST_ASSERT_EQUAL(laser.calculate_credits(0), 0, "Selling nothing gave credits")
	TEST_ASSERT_EQUAL(laser.calculate_credits(5 * PTL_MW), 11, "Wrong payout for 5 MW")
	TEST_ASSERT_EQUAL(laser.calculate_credits(100 * PTL_MW), 27, "Wrong payout for 100 MW")

	// Sprzedaż dzieli kredyty 50/25/25 i niczego nie zostawia
	var/datum/bank_account/department/eng = SSeconomy.get_dep_account(ACCOUNT_ENG)
	var/eng_before = eng.account_balance
	laser.sell_power(100 * PTL_MW)
	TEST_ASSERT_EQUAL(laser.total_earnings, 27, "Total earnings were not counted")
	TEST_ASSERT_EQUAL(eng.account_balance - eng_before, 13.5, "Engineering did not get half of the payout")
	TEST_ASSERT_EQUAL(laser.unsent_earnings, 0, "Credits were left unsent")

	// Słaba wiązka pali, nie gibuje
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(corner, EAST))
	laser.output_level = 2 * PTL_MW
	laser.atom_entered_beam(null, victim)
	TEST_ASSERT_EQUAL(victim.getFireLoss(), 30, "2 MW beam did not burn for 30")
	TEST_ASSERT(!QDELETED(victim), "2 MW beam gibbed the victim")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
