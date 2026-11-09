// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - urządzenia naścienne na ścianach Paradise (paradise_urzadzenia/przesuniecia.dm): przesunięcia z map wyrównane
/// do ściany, przesunięcie wzdłuż ściany zostaje, kierunek sprite'a z przesunięcia, zawieszenie z ramki po właściwej stronie
/datum/unit_test/aquila_wall_mounts

/datum/unit_test/aquila_wall_mounts/Run()
	var/turf/spot = run_loc_floor_bottom_left

	// Przycisk z mapy na starym przesunięciu 24 px nad podłogą trafia na środek kafla ściany
	var/obj/machinery/button/door/button = mapped_mount(/obj/machinery/button/door, spot, 0, 24)
	TEST_ASSERT_EQUAL(button.pixel_y, 34, "A door button mapped at pixel_y 24 did not move onto the north wall")
	TEST_ASSERT_EQUAL(button.pixel_x, 0, "A door button on the north wall moved sideways")

	// Request console na ścianie wschodniej: przy wewnętrznej krawędzi ściany, wyżej i z kierunkiem ściany
	var/obj/machinery/requests_console/console = mapped_mount(/obj/machinery/requests_console, spot, 30, 0)
	TEST_ASSERT_EQUAL(console.pixel_x, 28, "A requests console on the east wall has the wrong offset")
	TEST_ASSERT_EQUAL(console.pixel_y, 4, "A requests console on the east wall was not raised to the wall segment")
	TEST_ASSERT_EQUAL(console.dir, EAST, "A requests console on the east wall does not face its wall")

	// Włącznik światła przesunięty wzdłuż ściany zachodniej (dwa urządzenia na jednym kawałku ściany) zostaje przesunięty
	var/obj/machinery/light_switch/light_switch = mapped_mount(/obj/machinery/light_switch, spot, -26, 8)
	TEST_ASSERT_EQUAL(light_switch.pixel_x, -24, "A light switch on the west wall has the wrong offset")
	TEST_ASSERT_EQUAL(light_switch.pixel_y, 8, "A light switch lost the mapper's offset along the wall")
	TEST_ASSERT_EQUAL(light_switch.dir, EAST, "A light switch on the west wall does not face away from it")

	// Tabliczka 32x32 zachodząca na podłogę wraca na środek kafla ściany, a mała przesunięta tabliczka zostaje
	var/obj/structure/sign/warning/vacuum/sign = mapped_mount(/obj/structure/sign/warning/vacuum, spot, 0, -26)
	TEST_ASSERT_EQUAL(sign.pixel_y, -32, "A sign mapped at pixel_y -26 did not move onto the south wall")
	var/obj/structure/sign/warning/vacuum/small_shift = mapped_mount(/obj/structure/sign/warning/vacuum, spot, 0, 8)
	TEST_ASSERT_EQUAL(small_shift.pixel_y, 8, "A sign with a small offset was moved")

	// Ramka newscastera na ścianie północnej: newscaster wisi na tej ścianie, nie po drugiej stronie gracza
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/turf/north_wall = locate(user.x, user.y + 1, user.z)
	var/obj/item/wallframe/newscaster/frame = allocate(/obj/item/wallframe/newscaster)
	frame.attach(north_wall, user)
	var/obj/machinery/newscaster/caster = locate() in get_turf(user)
	TEST_ASSERT(caster, "The newscaster frame did not build a newscaster")
	allocated += caster
	TEST_ASSERT_EQUAL(caster.pixel_y, 34, "A newscaster built on the north wall does not hang on it")
	TEST_ASSERT_EQUAL(caster.dir, NORTH, "A newscaster built on the north wall does not face it")

	// Ramka gaśnicy na ścianie zachodniej (przesunięcie z Initialize, potem z ramki): wyrównana raz, bez podwójnego podniesienia
	var/turf/west_wall = locate(user.x - 1, user.y, user.z)
	var/obj/item/wallframe/extinguisher_cabinet/cabinet_frame = allocate(/obj/item/wallframe/extinguisher_cabinet)
	cabinet_frame.attach(west_wall, user)
	var/obj/structure/extinguisher_cabinet/cabinet = locate() in get_turf(user)
	TEST_ASSERT(cabinet, "The extinguisher cabinet frame did not build a cabinet")
	allocated += cabinet
	TEST_ASSERT_EQUAL(cabinet.pixel_x, -25, "An extinguisher cabinet built on the west wall has the wrong offset")
	TEST_ASSERT_EQUAL(cabinet.pixel_y, 4, "An extinguisher cabinet built on the west wall was raised the wrong amount")

/// Tworzy urządzenie tak jak ładowanie mapy: przesunięcie ustawione przed Initialize()
/datum/unit_test/aquila_wall_mounts/proc/mapped_mount(path, turf/spot, offset_x, offset_y)
	world.preloader_setup(list("pixel_x" = offset_x, "pixel_y" = offset_y), path)
	var/atom/movable/mount = new path(spot)
	GLOB.use_preloader = FALSE
	allocated += mount
	return mount

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
