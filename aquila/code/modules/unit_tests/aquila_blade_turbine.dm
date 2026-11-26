// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Wlewa na wejście turbiny sam azot o danym ciśnieniu i temperaturze
/proc/aq_test_feed_turbine(obj/machinery/atmospherics/components/binary/blade_turbine/turbine, pressure, temperature)
	var/datum/gas_mixture/input = turbine.airs[1]
	input.clear()
	input.set_temperature(temperature)
	input.set_moles(GAS_N2, pressure * input.return_volume() / (R_IDEAL_GAS_EQUATION * temperature))

/// AQUILA - turbina gazowa z łopatkami (aquila/code/modules/power/blade_turbine.dm): gorący gaz daje obroty i moc,
/// zimny i za gorący nie, nadobroty zużywają łopatki aż do rozpadu, a materiał części zmienia ich właściwości.
/datum/unit_test/aquila_blade_turbine

/datum/unit_test/aquila_blade_turbine/Run()
	var/obj/machinery/atmospherics/components/binary/blade_turbine/turbine = allocate(/obj/machinery/atmospherics/components/binary/blade_turbine, run_loc_floor_bottom_left)
	TEST_ASSERT(turbine.current_blade && turbine.current_stator, "Nowa turbina nie ma łopatek albo statora")
	// Odłamki z rozpadu leciałyby dalej w kolejne testy
	turbine.tear_shrapnel = FALSE
	// Części fabryczne nie mają materiałów (budowa i rozbiórka nie daje żelaza), ale działają jak żelazne
	TEST_ASSERT(!length(turbine.current_blade.custom_materials) && !length(turbine.current_stator.custom_materials), "Fabryczne części turbiny mają materiały do przetopienia")
	TEST_ASSERT(turbine.turbine_mass == 800 && turbine.max_blade_health == 15, "Fabryczne łopatki nie liczą się jak żelazne")
	TEST_ASSERT(turbine.rpm == 0 && turbine.lastgen == 0 && !turbine.ruined, "Nowa turbina nie stoi albo jest rozbita")

	// Gorący gaz: wirnik rusza, jest moc, gaz wychodzi chłodniejszy
	turbine.stator_load = 20000
	for(var/i in 1 to 10)
		aq_test_feed_turbine(turbine, 4000, 1000)
		turbine.process()
	TEST_ASSERT(turbine.rpm > 0, "Wirnik stoi mimo gorącego gazu")
	TEST_ASSERT(turbine.lastgen > 0, "Turbina nie daje mocy z gorącego gazu")
	TEST_ASSERT(!turbine.stalling, "Turbina dławi się przy małym obciążeniu")
	TEST_ASSERT(turbine.last_output_temperature < 1000, "Gaz nie oddał ciepła ([turbine.last_output_temperature] K)")
	var/datum/gas_mixture/output = turbine.airs[2]
	TEST_ASSERT(output.total_moles() > 0, "Gaz nie przeszedł na wyjście")

	// Zawór awaryjny powyżej 3000 K: gaz przechodzi, mocy brak
	aq_test_feed_turbine(turbine, 4000, 3500)
	turbine.process()
	TEST_ASSERT(turbine.lastgen == 0, "Turbina daje moc z gazu ponad limitem temperatury")
	TEST_ASSERT(turbine.overtemp, "Brak ostrzeżenia o przegrzaniu")

	// Za duże obciążenie dławi wirnik
	turbine.stator_load = 1e9
	aq_test_feed_turbine(turbine, 4000, 1000)
	turbine.process()
	TEST_ASSERT(turbine.stalling && turbine.rpm == 0, "Wirnik nie stanął przy obciążeniu 1e9 J/obrót")

	// Nadobroty: łopatki tracą wytrzymałość, a przy zerze turbina się rozpada
	turbine.stator_load = 1
	var/start_health = turbine.blade_health
	var/worn = FALSE
	for(var/i in 1 to 200)
		turbine.rpm = turbine.best_rpm * 3
		aq_test_feed_turbine(turbine, 4000, 1000)
		turbine.process()
		if(turbine.blade_health < start_health)
			worn = TRUE
		if(turbine.ruined)
			break
	TEST_ASSERT(worn, "Łopatki nie zużyły się na nadobrotach")
	TEST_ASSERT(turbine.ruined && !turbine.current_blade, "Turbina nie rozpadła się po zużyciu łopatek")
	aq_test_feed_turbine(turbine, 4000, 1000)
	turbine.process()
	TEST_ASSERT(turbine.lastgen == 0 && turbine.rpm == 0, "Rozbita turbina dalej pracuje")

	// Materiały części: z tabeli materiałów (złoto cięższe od żelaza, diament twardszy, srebro przewodzi lepiej)
	var/obj/item/turbine_part/blade/iron_blade = allocate(/obj/item/turbine_part/blade)
	var/obj/item/turbine_part/blade/gold_blade = allocate(/obj/item/turbine_part/blade)
	gold_blade.set_custom_materials(list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT * 5))
	var/obj/item/turbine_part/blade/diamond_blade = allocate(/obj/item/turbine_part/blade)
	diamond_blade.set_custom_materials(list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT * 5))
	var/list/iron_props = iron_blade.get_turbine_properties()
	TEST_ASSERT(iron_blade.blade_mass(iron_props) == 800 && iron_blade.blade_max_health(iron_props) == 15, "Żelazne łopatki nie mają wartości stali z Goona (800, 15)")
	TEST_ASSERT(gold_blade.blade_mass(gold_blade.get_turbine_properties()) > 800, "Złote łopatki nie są cięższe od żelaznych")
	TEST_ASSERT(diamond_blade.blade_max_health(diamond_blade.get_turbine_properties()) > 15, "Diamentowe łopatki nie są wytrzymalsze od żelaznych")
	var/obj/item/turbine_part/stator/silver_stator = allocate(/obj/item/turbine_part/stator)
	silver_stator.set_custom_materials(list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT * 3))
	TEST_ASSERT(silver_stator.stator_multiplier(silver_stator.get_turbine_properties()) > 1, "Srebrny stator nie daje więcej mocy od żelaznego")

	// Wymiana części na stojącej turbinie przywraca pracę po zespawaniu obudowy
	turbine.replace_part(null, diamond_blade)
	TEST_ASSERT(turbine.current_blade == diamond_blade && turbine.blade_health == turbine.max_blade_health, "Nowe łopatki nie trafiły do turbiny")
	turbine.ruined = FALSE
	turbine.stator_load = 20000
	for(var/i in 1 to 5)
		aq_test_feed_turbine(turbine, 4000, 1000)
		turbine.process()
	TEST_ASSERT(turbine.lastgen > 0, "Naprawiona turbina z nowymi łopatkami nie daje mocy")

	// Łopatki zbite do zera na stojącym wirniku pękają bez rozpadu turbiny
	turbine.stator_load = 1e9
	aq_test_feed_turbine(turbine, 4000, 1000)
	turbine.process()
	TEST_ASSERT(turbine.rpm == 0, "Wirnik nie stanął przed sprawdzeniem pęknięcia")
	turbine.blade_health = 0
	turbine.process()
	TEST_ASSERT(turbine.ruined && !turbine.current_blade, "Łopatki z zerową wytrzymałością nie pękły na stojącym wirniku")

#undef TEST_ASSERT
