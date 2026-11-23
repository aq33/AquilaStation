// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Sprawdza przesunięcie w pikselach; makro, żeby Fail() przerwał test
#define TEST_ASSERT_PIXELS(thing, want_x, want_y, what) TEST_ASSERT(thing.pixel_x == want_x && thing.pixel_y == want_y, "[what]: przesunięcie [thing.pixel_x],[thing.pixel_y] zamiast [want_x],[want_y]")

/// Rakiety na wózku leżą w równym stosie, także gdy przed załadowaniem miały losowe przesunięcie, i po zdjęciu jednej
/datum/unit_test/aquila_munitions_trolley_stack

/datum/unit_test/aquila_munitions_trolley_stack/Run()
	var/obj/structure/munitions_trolley/trolley = allocate(/obj/structure/munitions_trolley, run_loc_floor_bottom_left)
	var/list/missiles = list()
	for(var/i in 1 to 3)
		var/obj/item/ship_weapon/ammunition/missile/missile = allocate(/obj/item/ship_weapon/ammunition/missile, run_loc_floor_bottom_left)
		missile.pixel_x = rand(-6, 6) // jak po dropItemToGround
		missile.pixel_y = rand(-6, 6)
		trolley.load_trolley(missile)
		missiles += missile
	for(var/i in 1 to 3)
		var/obj/item/ship_weapon/ammunition/missile/missile = missiles[i]
		TEST_ASSERT(missile.loc == trolley, "Rakieta [i] nie trafiła na wózek")
		TEST_ASSERT_PIXELS(missile, initial(missile.pixel_x), 5 * i, "Rakieta [i] po załadowaniu")
	var/obj/item/ship_weapon/ammunition/missile/top = missiles[3]
	var/obj/item/ship_weapon/ammunition/missile/bottom = missiles[1]
	TEST_ASSERT(top.layer > bottom.layer, "Górna rakieta nie rysuje się nad dolną")

	// Zdjęcie środkowej: dolna zostaje na dole, górna schodzi o jedno miejsce
	trolley.unload_munition(missiles[2])
	TEST_ASSERT(trolley.amount == 2, "Po zdjęciu jednej rakiety wózek liczy [trolley.amount]")
	TEST_ASSERT_PIXELS(bottom, initial(bottom.pixel_x), 5, "Dolna rakieta po zdjęciu środkowej")
	TEST_ASSERT_PIXELS(top, initial(top.pixel_x), 10, "Górna rakieta po zdjęciu środkowej")
	trolley.unload_munition(top)
	trolley.unload_munition(bottom)

#undef TEST_ASSERT_PIXELS
#undef TEST_ASSERT
