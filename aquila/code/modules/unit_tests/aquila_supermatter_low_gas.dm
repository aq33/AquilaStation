// AQUILA: test regresji supermaterii w prawie pustej komorze.
// Kryształ dodawał pobranemu gazowi pełny przyrost temperatury, pełną porcję plazmy i tlenu oraz pełny zysk mocy
// z temperatury bez względu na to, ile gazu było w komorze. Przy kilku molach nakręcał się sam (własna plazma i tlen
// to idealna mieszanka), czego nie dało się zatrzymać. Teraz te efekty rosną z ilością gazu (SUPERMATTER_FULL_REACTION_MOLES).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/datum/unit_test/aquila_supermatter_low_gas

/datum/unit_test/aquila_supermatter_low_gas/Run()
	var/turf/open/start = run_loc_floor_bottom_left
	var/obj/machinery/power/supermatter_crystal/crystal = allocate(/obj/machinery/power/supermatter_crystal, start)
	var/datum/gas_mixture/air = start.return_air()

	// Prawie pusta komora: kryształ nie może zalać jej gorącą plazmą i tlenem ani zyskać mocy z resztek gazu
	air.clear()
	air.set_moles(GAS_PLASMA, 0.5)
	air.set_moles(GAS_O2, 0.5)
	air.set_temperature(T20C)
	crystal.damage = 0
	crystal.power = 1000
	crystal.process_atmos()
	var/low_moles = air.total_moles()
	var/low_temperature = air.return_temperature()
	var/low_power = crystal.power

	// Zwykła komora z azotem: kryształ dalej grzeje gaz i wydziela plazmę jak dotąd
	air.clear()
	air.set_moles(GAS_N2, 100)
	air.set_temperature(T20C)
	crystal.damage = 0
	crystal.power = 1000
	crystal.process_atmos()
	var/normal_plasma = air.get_moles(GAS_PLASMA)
	var/normal_temperature = air.return_temperature()

	// Przywróć zwykłe powietrze na kafelku dla kolejnych testów
	air.clear()
	air.set_moles(GAS_O2, MOLES_O2STANDARD)
	air.set_moles(GAS_N2, MOLES_N2STANDARD)
	air.set_temperature(T20C)

	// Bez skalowania ten sam tick dodawał ok. 37 moli gorącej plazmy i tlenu do 1 mola w komorze (z nim ok. 0,4 mola)
	TEST_ASSERT(low_moles < 2, "a crystal in a near-empty chamber released [low_moles - 1] mol of gas in one tick")
	TEST_ASSERT(low_temperature < T20C + 100, "a crystal heated a near-empty chamber to [low_temperature] K in one tick")
	TEST_ASSERT(low_power < 1000, "a crystal gained power from 1 mol of gas (power [low_power])")
	TEST_ASSERT(normal_plasma > 0.3, "a crystal in a normal nitrogen chamber released only [normal_plasma] mol of plasma")
	TEST_ASSERT(normal_temperature > T20C, "a crystal in a normal nitrogen chamber did not heat the gas")

#undef TEST_ASSERT
