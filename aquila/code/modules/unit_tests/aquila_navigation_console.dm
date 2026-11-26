// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - konsole bez starej mapy gwiazd: komputer FTL ma własne okno napędu (ftl_computer_window.dm) z położeniem
/// okrętu i sterowaniem tylko z dostępem, astrometria pokazuje mapę hex i skanuje układy do 3 kafli
/// (hex_astrometrics.dm), konsola nawigacji daje okno mapy hex, a menedżer układów admina ma mapę hex z flotami
/// i obiektami zaznaczonego układu (hex_starsystem_manager.dm).
/datum/unit_test/aquila_navigation_console
	var/obj/structure/overmap/main_ship
	var/obj/old_drive

/datum/unit_test/aquila_navigation_console/Run()
	main_ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(main_ship, "No main ship")
	TEST_ASSERT(GLOB.hexmap?.built, "The hex map isn't built")
	old_drive = main_ship.ftl_drive

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/computer/ship/navigation/nav = allocate(/obj/machinery/computer/ship/navigation, main_ship)
	var/obj/machinery/computer/ship/navigation/astrometrics/astro = allocate(/obj/machinery/computer/ship/navigation/astrometrics, main_ship)
	var/obj/machinery/computer/ship/ftl_computer/ftl = allocate(/obj/machinery/computer/ship/ftl_computer, main_ship)
	nav.has_overmap()
	astro.has_overmap()
	ftl.has_overmap()
	TEST_ASSERT(main_ship.ftl_drive == ftl, "The legacy FTL computer didn't become the ship's drive")

	// Komputer FTL: własne okno napędu z położeniem okrętu, bez starej mapy
	var/list/data = ftl.ui_data(user)
	TEST_ASSERT_EQUAL(data["ftl"]?["kind"], "legacy", "The FTL computer sends no drive data")
	TEST_ASSERT_EQUAL(data["position"]?["system"], main_ship.current_system?.name, "The FTL computer shows a wrong ship position")
	TEST_ASSERT(isnull(data["star_systems"]), "The FTL computer still sends the old star map")
	ftl.req_access = list(ACCESS_ENGINE_EQUIP)
	TEST_ASSERT(!ftl.ui_data(user)["ftl"]["allowed"], "The FTL computer allows a user without engineering access")
	ftl.req_access = null

	// Nawigacja: okno mapy hex
	data = nav.ui_data(user)
	TEST_ASSERT(islist(data["systems"]) && islist(data["ship"]), "The navigation console doesn't send the hex map")
	TEST_ASSERT(isnull(data["mode"]) || data["mode"] == "nav", "The navigation console isn't in the navigation mode")

	// Astrometria: mapa hex w trybie skanu, nie steruje okrętem, układ w zasięgu 3 kafli da się skanować
	data = astro.ui_data(user)
	TEST_ASSERT_EQUAL(data["mode"], "astro", "The astrometrics console isn't in the scan mode")
	TEST_ASSERT(!data["can_control"], "The astrometrics console can control the ship")
	var/datum/hex/here = main_ship.current_hex()
	TEST_ASSERT(here, "The main ship isn't on a hex")
	var/datum/star_system/near
	var/datum/star_system/far
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || istype(S, /datum/star_system/random/hex_empty) || S.hex.sector != here.sector)
			continue
		var/dist = GLOB.hexmap.distance(here, S.hex)
		if(dist <= 3 && !near)
			near = S
		if(dist > 3 && !far)
			far = S
	if(near)
		astro.hex_selected = near.hex
		astro.sync_astrometrics_selection()
		TEST_ASSERT(astro.selected_system == near, "Selecting a hex didn't select its system for the scan")
		TEST_ASSERT(astro.astrometrics_hex_data()["system"]?["can_scan"], "A system [GLOB.hexmap.distance(here, near.hex)] hexes away can't be scanned")
	if(far)
		TEST_ASSERT(!astro.is_in_range(main_ship.current_system, far), "A system [GLOB.hexmap.distance(here, far.hex)] hexes away is in scan range")

	// Menedżer układów admina: mapa hex z flotami i obiektami zaznaczonego układu
	var/datum/starsystem_manager/manager = new(user)
	data = manager.ui_data(user)
	TEST_ASSERT_EQUAL(data["mode"], "admin", "The star system manager isn't in the admin mode")
	TEST_ASSERT(islist(data["systems"]), "The star system manager sends no hex map")
	var/datum/hex/target_hex = near?.hex || here
	manager.ui_act("hex_select", list("hex" = target_hex.id))
	data = manager.ui_data(user)
	if(target_hex.system)
		TEST_ASSERT_EQUAL(data["admin"]?["name"], target_hex.system.name, "The star system manager doesn't show the selected system")
	qdel(manager)

/datum/unit_test/aquila_navigation_console/Destroy()
	if(main_ship)
		main_ship.ftl_drive = old_drive
	main_ship = null
	old_drive = null
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
