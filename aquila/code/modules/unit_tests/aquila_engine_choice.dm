// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message || "No message"] (expected [b], got [a])") }

/// AQUILA - wybór silnika: Główny Inżynier rozstrzyga sam, bez niego większość, a typy spoza slotu się nie liczą
/datum/unit_test/aquila_engine_choice_pick

/datum/unit_test/aquila_engine_choice_pick/Run()
	var/list/all = list(ENGINE_CHOICE_TESLA, ENGINE_CHOICE_STORMDRIVE, ENGINE_CHOICE_SUPERMATTER)
	var/list/votes = list(
		list(JOB_NAME_STATIONENGINEER, ENGINE_CHOICE_SUPERMATTER),
		list(JOB_NAME_STATIONENGINEER, ENGINE_CHOICE_SUPERMATTER),
		list(JOB_NAME_CHIEFENGINEER, ENGINE_CHOICE_TESLA),
	)
	TEST_ASSERT_EQUAL(engine_choice_pick(votes, all), ENGINE_CHOICE_TESLA, "Główny Inżynier powinien przegłosować inżynierów")
	votes.Cut(3)
	TEST_ASSERT_EQUAL(engine_choice_pick(votes, all), ENGINE_CHOICE_SUPERMATTER, "bez Głównego Inżyniera decyduje większość")
	// Padalec nie ma Tesli: wybór Głównego Inżyniera, którego nie da się spełnić, oddaje głos inżynierom
	votes += list(list(JOB_NAME_CHIEFENGINEER, ENGINE_CHOICE_TESLA))
	TEST_ASSERT_EQUAL(engine_choice_pick(votes, list(ENGINE_CHOICE_STORMDRIVE, ENGINE_CHOICE_SUPERMATTER)), ENGINE_CHOICE_SUPERMATTER, "silnik spoza slotu nie może wygrać")
	TEST_ASSERT_EQUAL(engine_choice_pick(list(), all), null, "bez głosów silnik zostaje wylosowany")

/// AQUILA - podmiana wariantu silnika: stary znika z pól, które stawiał, nowy staje, a pola wspólne zostają nietknięte
/datum/unit_test/aquila_engine_choice_swap

/datum/unit_test/aquila_engine_choice_swap/Run()
	var/datum/map_template/random_room/stormdrive = engine_choice_test_template(/datum/map_template/random_room/aq_engine_snk_01)
	var/datum/map_template/random_room/supermatter = engine_choice_test_template(/datum/map_template/random_room/aq_engine_snk_03)
	// Bez Release(): zwolnione pola od razu bierze komora testowa (wzór: aquila_mining_asteroids)
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(stormdrive.width + 1, stormdrive.height + 1)
	TEST_ASSERT(reservation, "brak miejsca na rezerwację pod szablon silnika")
	var/turf/origin = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	TEST_ASSERT(stormdrive.load(origin, centered = FALSE), "nie wczytał się szablon Stormdrive'a")

	var/list/owned = stormdrive.engine_owned_turfs(origin)
	var/list/area_turfs = stormdrive.get_affected_turfs(origin)
	TEST_ASSERT(length(owned) && length(owned) < length(area_turfs), "szablon powinien mieć pola własne i wspólne (template_noop): [length(owned)] z [length(area_turfs)]")
	// Znacznik na polu wspólnym udaje rzecz z mapy bazowej
	var/turf/shared
	for(var/turf/T as anything in area_turfs)
		if(!(T in owned))
			shared = T
			break
	var/obj/item/stack/rods/marker = new(shared)

	var/list/slot = list(origin, stormdrive)
	TEST_ASSERT(engine_choice_swap(slot, supermatter), "podmiana na supermaterię się nie udała")
	TEST_ASSERT_EQUAL(slot[2], supermatter, "slot powinien pamiętać nowy wariant")
	var/reactors = 0
	var/crystals = 0
	for(var/turf/T as anything in area_turfs)
		for(var/obj/O in T)
			if(istype(O, /obj/machinery/atmospherics/components/binary/stormdrive_reactor))
				reactors++
			if(istype(O, /obj/machinery/power/supermatter_crystal))
				crystals++
	TEST_ASSERT_EQUAL(reactors, 0, "po podmianie został reaktor Stormdrive")
	TEST_ASSERT_EQUAL(crystals, 1, "po podmianie powinien stać jeden kryształ supermaterii")
	TEST_ASSERT(!QDELETED(marker) && marker.loc == shared, "podmiana ruszyła rzecz na polu wspólnym")
	TEST_ASSERT(findtext(GLOB.ship_structure_room_turfs[origin], supermatter.room_id), "trwała struktura nie wie o nowym wariancie na polach silnika")

/// Osobna instancja szablonu: test nie rusza stanu szablonów z SSmapping (stock, spawned)
/datum/unit_test/aquila_engine_choice_swap/proc/engine_choice_test_template(template_type)
	var/datum/map_template/random_room/template = new template_type()
	return template

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
