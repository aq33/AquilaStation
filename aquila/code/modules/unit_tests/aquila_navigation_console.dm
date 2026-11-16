// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - okno „Nawigacja i skok” (aquila/code/modules/overmap/consoles/navigation_console.dm): konsola nawigacji
/// i stary komputer FTL dają dane mapy i zakładki napędu, komputer FTL zaczyna od napędu, a z zakładki napędu
/// w nawigacji da się rozkręcić stary napęd tylko z dostępem komputera FTL i nie z publicznej mapy. Przy zbudowanej mapie
/// hex konsola oddaje okno mapie hex (hexmap/hex_console.dm), więc scalone okno sprawdzamy na starej mapie.
/datum/unit_test/aquila_navigation_console
	var/obj/structure/overmap/main_ship
	var/obj/old_drive
	/// Stan GLOB.hexmap.built sprzed testu (null = mapy hex nie ma)
	var/hex_built

/datum/unit_test/aquila_navigation_console/Run()
	main_ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(main_ship, "No main ship")
	TEST_ASSERT(length(SSstar_system.ships[main_ship]), "The main ship isn't registered in SSstar_system.ships")
	old_drive = main_ship.ftl_drive

	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, left)
	// Konsole w środku okrętu: get_overmap() znajduje go przez loc (poziom testowy nie musi być podpięty do okrętu),
	// a komputer FTL potrzebuje okrętu już w Initialize (start_monitoring)
	var/obj/machinery/computer/ship/navigation/nav = allocate(/obj/machinery/computer/ship/navigation, main_ship)
	var/obj/machinery/computer/ship/navigation/public/public_nav = allocate(/obj/machinery/computer/ship/navigation/public, main_ship)
	var/obj/machinery/computer/ship/ftl_computer/ftl = allocate(/obj/machinery/computer/ship/ftl_computer, main_ship)
	TEST_ASSERT(nav.has_overmap() == main_ship, "The navigation console isn't linked to the main ship")
	public_nav.has_overmap()
	ftl.has_overmap()
	TEST_ASSERT(main_ship.ftl_drive == ftl, "The legacy FTL computer didn't become the ship's drive")

	// Mapa hex: konsola nawigacji daje okno mapy hex, nie scalone okno starej mapy
	hex_built = GLOB.hexmap?.built
	if(GLOB.hexmap)
		GLOB.hexmap.built = TRUE
		var/list/hex_data = nav.ui_data(user)
		TEST_ASSERT(isnull(hex_data?["screen"]), "With the hex map the navigation console still sends the old star map window")
		GLOB.hexmap.built = FALSE

	// Stara mapa. Nawigacja: domyślnie mapa, do tego zakładka napędu ze starym komputerem FTL
	var/list/data = nav.ui_data(user)
	TEST_ASSERT_EQUAL(data["screen"], 1, "The navigation console doesn't start on the star map")
	TEST_ASSERT(islist(data["star_systems"]), "The navigation console sends no star map")
	TEST_ASSERT(islist(data["ftl"]), "The navigation console sends no FTL drive tab")
	TEST_ASSERT_EQUAL(data["ftl"]["kind"], "legacy", "The FTL tab doesn't see the legacy FTL computer")
	TEST_ASSERT(islist(data["position"]), "The navigation console sends no ship position")

	// Komputer FTL: to samo okno, zaczyna od zakładki napędu, a mapa jest o jedną akcję dalej
	data = ftl.ui_data(user)
	TEST_ASSERT_EQUAL(data["screen"], 3, "The FTL computer doesn't start on the FTL drive tab")
	TEST_ASSERT(data["ftl_console"], "The FTL computer isn't marked as the drive console")
	TEST_ASSERT_EQUAL(data["ftl"]?["kind"], "legacy", "The FTL computer sends no FTL drive tab")
	var/datum/tgui/ftl_ui = new(user, ftl, "Starmap")
	usr = user
	ftl.ui_act("map", list(), ftl_ui)
	usr = null
	qdel(ftl_ui)
	data = ftl.ui_data(user)
	TEST_ASSERT_EQUAL(data["screen"], 1, "The FTL computer didn't switch to the star map")
	TEST_ASSERT(islist(data["star_systems"]), "The FTL computer sends no star map on the map tab")

	// Zakładka napędu w nawigacji: bez dostępu komputera FTL nic się nie dzieje
	ftl.req_access = list(ACCESS_ENGINE_EQUIP)
	var/datum/tgui/nav_ui = new(user, nav, "Starmap")
	usr = user
	nav.ui_act("ftl_tab", list(), nav_ui)
	var/switched_tab = (nav.screen == 3)
	nav.ui_act("toggle_power", list(), nav_ui)
	var/powered_without_access = ftl.active
	ftl.req_access = null
	var/datum/tgui/public_ui = new(user, public_nav, "Starmap")
	public_nav.ui_act("toggle_power", list(), public_ui)
	var/powered_from_public = ftl.active
	nav.ui_act("toggle_power", list(), nav_ui)
	var/powered_with_access = ftl.active
	var/spooling = (ftl.ftl_state == FTL_STATE_SPOOLING)
	nav.ui_act("toggle_power", list(), nav_ui)
	var/powered_after_off = ftl.active
	usr = null
	qdel(nav_ui)
	qdel(public_ui)
	TEST_ASSERT(switched_tab, "The navigation console didn't switch to the FTL drive tab")
	TEST_ASSERT(!powered_without_access, "The FTL tab spooled the drive for a user without engineering access")
	TEST_ASSERT(!powered_from_public, "The public star map console spooled the FTL drive")
	TEST_ASSERT(powered_with_access, "The FTL tab didn't spool the legacy drive")
	TEST_ASSERT(spooling, "The legacy drive isn't spooling after the FTL tab turned it on")
	TEST_ASSERT(!powered_after_off, "The FTL tab didn't turn the legacy drive off")

	// Publiczna mapa nie może skakać ani sterować napędem
	data = public_nav.ui_data(user)
	TEST_ASSERT(!data["can_control"], "The public star map console allows controlling the ship")
	TEST_ASSERT(!data["ftl"]?["can_control"], "The public star map console allows controlling the FTL drive")

/datum/unit_test/aquila_navigation_console/Destroy()
	if(GLOB.hexmap && !isnull(hex_built))
		GLOB.hexmap.built = hex_built
	if(main_ship)
		main_ship.ftl_drive = old_drive
	main_ship = null
	old_drive = null
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
