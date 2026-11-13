// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// „Po sprzęt” z konsoli XO: każdy członek dostaje znacznik przy bliższym automacie, zepsuty automat jest pomijany,
/// bez automatu nic się nie sypie, a otwarcie właściwego automatu zdejmuje znacznik
/datum/unit_test/aquila_squad_gear_ping

/datum/unit_test/aquila_squad_gear_ping/Run()
	var/datum/squad/squad = GLOB.squad_manager.get_squad("Charlie")
	TEST_ASSERT(squad, "Brak drużyny Charlie")
	var/obj/machinery/squad_vendor/near_vendor = allocate(/obj/machinery/squad_vendor, run_loc_floor_bottom_left)
	var/obj/machinery/squad_vendor/far_vendor = allocate(/obj/machinery/squad_vendor, run_loc_floor_top_right)
	// pokój testowy może nie mieć zasilania
	near_vendor.set_machine_stat(NONE)
	far_vendor.set_machine_stat(NONE)
	TEST_ASSERT((near_vendor in GLOB.aq_squad_vendors) && (far_vendor in GLOB.aq_squad_vendors), "Automaty nie trafiły na listę automatów drużyn")
	var/list/vendors = list(near_vendor, far_vendor)
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	squad.add_member(first)
	squad.add_member(second)

	var/pinged = squad.aq_ping_gear(officer, vendors)
	TEST_ASSERT(pinged >= 2, "Znacznik dostało [pinged] członków zamiast co najmniej 2")
	var/datum/aq_squad_marker/gear/first_marker = squad.aq_gear_markers?[first]
	var/datum/aq_squad_marker/gear/second_marker = squad.aq_gear_markers?[second]
	TEST_ASSERT(first_marker?.vendor == near_vendor, "Pierwszy członek dostał znacznik przy [first_marker?.vendor] zamiast przy bliższym automacie")
	TEST_ASSERT(second_marker?.vendor == far_vendor, "Drugi członek dostał znacznik przy [second_marker?.vendor] zamiast przy bliższym automacie")
	TEST_ASSERT(first_marker.target_turf == get_turf(near_vendor), "Znacznik nie stoi na polu automatu")
	TEST_ASSERT(first_marker.marker_type == SQUAD_MARKER_GEAR, "Znacznik ma typ [first_marker.marker_type]")
	TEST_ASSERT(!(SQUAD_MARKER_GEAR in squad.aq_markers), "Osobisty znacznik trafił do wspólnych znaczników drużyny")
	TEST_ASSERT(isnull(squad.aq_ping_gear(officer, vendors)), "Drugie „Po sprzęt” od razu po pierwszym ominęło odstęp")

	// Otwarcie cudzego automatu nie zdejmuje znacznika, otwarcie właściwego zdejmuje
	far_vendor.ui_interact(first)
	TEST_ASSERT(squad.aq_gear_markers?[first] == first_marker, "Otwarcie innego automatu zdjęło znacznik")
	far_vendor.ui_interact(second)
	TEST_ASSERT(QDELETED(second_marker) && !squad.aq_gear_markers?[second], "Otwarcie wskazanego automatu nie zdjęło znacznika")

	// Zepsuty automat jest pomijany
	near_vendor.set_machine_stat(BROKEN)
	officer.aq_next_squad_marker = 0
	squad.aq_ping_gear(officer, vendors)
	TEST_ASSERT(QDELETED(first_marker), "Nowe „Po sprzęt” nie zastąpiło starego znacznika")
	first_marker = squad.aq_gear_markers?[first]
	TEST_ASSERT(first_marker?.vendor == far_vendor, "Zepsuty automat nie został pominięty")

	// Bez automatu: komunikat zamiast znacznika, bez runtime
	officer.aq_next_squad_marker = 0
	TEST_ASSERT(squad.aq_ping_gear(officer, list()) == 0, "Bez automatów ktoś dostał znacznik")
	TEST_ASSERT(QDELETED(first_marker) && !squad.aq_gear_markers?[first], "Bez działającego automatu został stary znacznik")

	// Wyjście z drużyny zdejmuje znacznik (najpierw świeży, bo poprzedni zniknął przy braku automatu)
	officer.aq_next_squad_marker = 0
	squad.aq_ping_gear(officer, vendors)
	first_marker = squad.aq_gear_markers?[first]
	TEST_ASSERT(first_marker && !QDELETED(first_marker), "Ponowne „Po sprzęt” nie dało znacznika przed wyjściem z drużyny")
	squad.remove_member(first)
	squad.remove_member(second)
	TEST_ASSERT(QDELETED(first_marker) && !squad.aq_gear_markers?[first], "Wyjście z drużyny nie zdjęło znacznika")

#undef TEST_ASSERT
