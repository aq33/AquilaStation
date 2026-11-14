// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - drużyna Echo: istnieje od startu, daje dostęp do myśliwców i hangaru, bierze pilotów, a nie zwykłą załogę
/datum/unit_test/squad_echo

/datum/unit_test/squad_echo/Run()
	var/datum/squad/echo = GLOB.squad_manager.aq_get_echo()
	TEST_ASSERT(echo && (echo in GLOB.squad_manager.squads), "The Echo squad doesn't exist at round start")
	TEST_ASSERT(echo.aq_is_echo && echo.name == "Echo", "The Echo squad isn't marked as Echo")
	TEST_ASSERT(echo.access_enabled, "Echo squad access is disabled")
	var/list/access = echo.GetAccess()
	TEST_ASSERT((ACCESS_COMBAT_PILOT in access) && (ACCESS_HANGAR in access), "Echo doesn't grant fighter and hangar access")

	// Piloci trafiają do Echo, zwykła załoga nie
	var/datum/job/pilot = SSjob.GetJobType(/datum/job/pilot)
	var/datum/job/assistant = SSjob.GetJobType(/datum/job/assistant)
	TEST_ASSERT(GLOB.squad_manager.aq_pick_squad(pilot, null) == echo, "A pilot isn't placed in Echo")
	if(assistant)
		TEST_ASSERT(GLOB.squad_manager.aq_pick_squad(assistant, "Echo") != echo, "Regular crew is placed in Echo on their own")
	TEST_ASSERT(!echo.hidden, "Picking a squad for regular crew left Echo hidden")

	// Zmiana zadania w konsoli nie zabiera Echo dostępu do myśliwców
	echo.retask(DC_SQUAD)
	TEST_ASSERT(ACCESS_COMBAT_PILOT in echo.GetAccess(), "Retasking Echo took away fighter access")
	echo.retask(COMBAT_AIR_PATROL)

	TEST_ASSERT(echo.aq_echo_limit() >= 1, "The Echo member limit is below one")
	// Dostęp Echo to kopia: wspólna lista roli patrolu myśliwców nie dostała hangaru
	TEST_ASSERT(!(ACCESS_HANGAR in GLOB.squad_manager.role_access_map[COMBAT_AIR_PATROL]), "Echo added hangar access to every combat air patrol squad")

#undef TEST_ASSERT
