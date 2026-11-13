// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Wymienia w maszynie wszystkie części typu old_path na new_path i przelicza maszynę
/proc/mechanic_test_swap_parts(obj/machinery/machine, old_path, new_path)
	for(var/obj/item/part in machine.component_parts.Copy())
		if(part.type == old_path)
			machine.component_parts -= part
			qdel(part)
			machine.component_parts += new new_path(null)
	machine.RefreshParts()

/// AQUILA - mechanik: czarna lista skanera i pakownicy, wersje z uplinku ją omijają
/datum/unit_test/mechanic_blacklist

/datum/unit_test/mechanic_blacklist/Run()
	var/obj/machinery/computer/security/security_console = allocate(/obj/machinery/computer/security)
	var/obj/machinery/computer/crew/crew_console = allocate(/obj/machinery/computer/crew)
	TEST_ASSERT(mechanic_machine_problem(security_console), "Zwykły skaner bierze konsolę kamer ochrony z czarnej listy")
	TEST_ASSERT(!mechanic_machine_problem(security_console, TRUE), "Skaner z uplinku nie bierze konsoli z czarnej listy")
	TEST_ASSERT(!mechanic_machine_problem(crew_console), "Skaner nie bierze zwykłej konsoli monitorowania załogi")

	var/obj/item/machine_packer/packer = allocate(/obj/item/machine_packer)
	TEST_ASSERT(packer.pack_problem(security_console), "Zwykła pakownica pakuje konsolę z czarnej listy")
	var/obj/item/machine_packer/syndicate/syndicate_packer = allocate(/obj/item/machine_packer/syndicate)
	TEST_ASSERT(!syndicate_packer.pack_problem(security_console), "Pakownica z uplinku nie pakuje konsoli z czarnej listy")

	// Maszyna z zamkniętym włazem nie da się spakować
	var/obj/machinery/schematic_reader/reader = allocate(/obj/machinery/schematic_reader)
	reader.panel_open = FALSE
	TEST_ASSERT(packer.pack_problem(reader), "Pakownica składa maszynę z zamkniętym włazem")

/// AQUILA - mechanik: skan pamięta tier części, pakowanie i rozkładanie zachowuje ulepszenia, komputer wraca z paczki
/datum/unit_test/mechanic_pack_roundtrip

/datum/unit_test/mechanic_pack_roundtrip/Run()
	var/turf/pack_turf = get_step(run_loc_floor_bottom_left, NORTH)
	var/obj/machinery/schematic_reader/reader = allocate(/obj/machinery/schematic_reader)
	mechanic_test_swap_parts(reader, /obj/item/stock_parts/scanning_module, /obj/item/stock_parts/scanning_module/adv)
	TEST_ASSERT_EQUAL(reader.scan_rating, 2, "Czytnik z modułami tier 2 liczy zły tier")

	var/datum/machine_schematic/schematic = new
	TEST_ASSERT(schematic.read_machine(reader), "Schemat nie czyta czytnika schematów")
	TEST_ASSERT_EQUAL(schematic.tier, 2, "Schemat nie zapamiętał tieru części")
	TEST_ASSERT_EQUAL(schematic.part_types[/obj/item/stock_parts/scanning_module/adv], 2, "Schemat nie zapamiętał ulepszonych modułów")
	TEST_ASSERT_EQUAL(schematic.build_path, /obj/machinery/schematic_reader, "Schemat ma zły cel budowy")
	qdel(schematic)

	reader.forceMove(pack_turf)
	var/obj/item/flatpack/pack = mechanic_pack_machine(reader)
	TEST_ASSERT(QDELETED(reader), "Maszyna została po spakowaniu")
	TEST_ASSERT(istype(pack) && pack.board, "Pakowanie nie dało paczki z płytką")
	var/obj/machinery/schematic_reader/deployed = pack.deploy(SOUTH)
	TEST_ASSERT(istype(deployed), "Paczka nie rozłożyła się w czytnik schematów")
	TEST_ASSERT(QDELETED(pack), "Paczka została po rozłożeniu")
	TEST_ASSERT(istype(deployed.circuit, /obj/item/circuitboard/machine/schematic_reader), "Rozłożona maszyna nie ma płytki z paczki")
	TEST_ASSERT_EQUAL(deployed.scan_rating, 2, "Rozłożona maszyna straciła ulepszone części")
	qdel(deployed)

	var/obj/machinery/computer/crew/console = new(pack_turf)
	var/obj/item/flatpack/console_pack = mechanic_pack_machine(console)
	TEST_ASSERT(istype(console_pack?.board, /obj/item/circuitboard/computer/crew), "Paczka z konsolą nie ma jej płytki")
	var/obj/machinery/computer/crew/deployed_console = console_pack.deploy(EAST)
	TEST_ASSERT(istype(deployed_console), "Paczka nie rozłożyła się w konsolę")
	TEST_ASSERT(istype(deployed_console.circuit, /obj/item/circuitboard/computer/crew), "Konsola z paczki nie ma płytki")
	TEST_ASSERT_EQUAL(deployed_console.dir, EAST, "Konsola z paczki stoi w złą stronę")
	qdel(deployed_console)

/// AQUILA - mechanik: flatpacker robi paczkę ze schematu z bazy (tier części, koszt, płytka), a maszyny z czarnej listy tylko po emagu
/datum/unit_test/mechanic_flatpacker

/datum/unit_test/mechanic_flatpacker/Run()
	var/obj/machinery/flatpacker/packer = allocate(/obj/machinery/flatpacker)
	var/datum/component/material_container/materials = packer.GetComponent(/datum/component/material_container)
	materials.max_amount = INFINITY
	for(var/material_path in list(/datum/material/iron, /datum/material/glass, /datum/material/copper, /datum/material/silver, /datum/material/gold, /datum/material/titanium, /datum/material/plasma, /datum/material/uranium, /datum/material/diamond))
		materials.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 100, getmaterialref(material_path))

	// Schemat ulepszonego czytnika w bazie testowej sieci badań
	var/datum/techweb/web = new /datum/techweb
	packer.stored_research = web
	var/obj/machinery/schematic_reader/source = allocate(/obj/machinery/schematic_reader)
	mechanic_test_swap_parts(source, /obj/item/stock_parts/scanning_module, /obj/item/stock_parts/scanning_module/adv)
	var/datum/machine_schematic/schematic = new
	schematic.read_machine(source)
	TEST_ASSERT(web.add_machine_schematic(schematic), "Baza nie przyjęła nowego schematu")
	TEST_ASSERT(!web.add_machine_schematic(schematic.copy()), "Baza przyjęła ten sam schemat dwa razy")
	var/datum/design/reader_design = mechanic_design_for(/obj/item/circuitboard/machine/schematic_reader)
	TEST_ASSERT(web.researched_designs[reader_design.id], "Odczyt schematu nie odblokował projektu płytki")

	packer.selected_key = schematic.get_key()
	packer.recalculate()
	TEST_ASSERT_EQUAL(packer.print_tier, 2, "Flatpacker liczy zły tier schematu")
	TEST_ASSERT(packer.disable_reason(), "Flatpacker z manipulatorem tier 1 pakuje części tier 2")
	mechanic_test_swap_parts(packer, /obj/item/stock_parts/manipulator, /obj/item/stock_parts/manipulator/nano)
	TEST_ASSERT_EQUAL(packer.max_part_tier, 2, "Manipulator tier 2 nie podnosi limitu tieru")
	TEST_ASSERT_EQUAL(packer.disable_reason(), "", "Flatpacker nie chce pakować schematu: [packer.disable_reason()]")

	// Część włożona pod inną maszynę nie trafia do paczki
	var/obj/item/vending_refill/coffee/stray_part = new(packer)
	packer.flatpacked_components += stray_part

	var/iron_before = materials.get_material_amount(/datum/material/iron)
	var/obj/item/flatpack/pack = packer.finish_build()
	TEST_ASSERT(istype(pack), "Flatpacker nie zrobił paczki")
	TEST_ASSERT(!(stray_part in pack.contents), "Do paczki trafiła część, której maszyna nie wymaga")
	TEST_ASSERT_EQUAL(stray_part.loc, packer, "Niepotrzebna część zniknęła z flatpackera")
	packer.drop_manual_parts()
	qdel(stray_part)
	TEST_ASSERT(materials.get_material_amount(/datum/material/iron) < iron_before, "Flatpacker nie zużył żelaza")
	TEST_ASSERT(istype(pack.board, /obj/item/circuitboard/machine/schematic_reader), "Paczka ze schematu ma złą płytkę")
	pack.forceMove(get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/machinery/schematic_reader/deployed = pack.deploy(SOUTH)
	TEST_ASSERT(istype(deployed), "Paczka ze schematu nie rozłożyła się w maszynę")
	TEST_ASSERT_EQUAL(deployed.scan_rating, 2, "Maszyna ze schematu nie ma części ze schematu")
	qdel(deployed)

	// Płytka z czarnej listy: blokada, a po emagu paczka
	var/obj/item/circuitboard/computer/security/security_board = new(packer)
	packer.inserted_board = security_board
	packer.recalculate()
	TEST_ASSERT(packer.source_illegal, "Konsola kamer ochrony nie jest na czarnej liście flatpackera")
	TEST_ASSERT(packer.disable_reason(), "Flatpacker bez emaga pakuje konsolę z czarnej listy")
	packer.obj_flags |= EMAGGED
	TEST_ASSERT_EQUAL(packer.disable_reason(), "", "Flatpacker po emagu nie pakuje konsoli: [packer.disable_reason()]")
	var/obj/item/flatpack/security_pack = packer.finish_build()
	TEST_ASSERT(istype(security_pack?.board, /obj/item/circuitboard/computer/security), "Paczka z płytki nie ma tej płytki")
	TEST_ASSERT(!packer.inserted_board, "Płytka została we flatpackerze po pakowaniu")
	qdel(security_pack)
	packer.stored_research = SSresearch.science_tech
	qdel(web)

/// AQUILA - mechanik: poprawki z przeglądu (pusta paczka, kierunek rur, czarna lista, pauza czytnika)
/datum/unit_test/mechanic_review_fixes

/datum/unit_test/mechanic_review_fixes/Run()
	// Paczka bez płytki usuwa się po pełnej inicjalizacji
	var/obj/item/flatpack/empty_pack = new(run_loc_floor_bottom_left)
	TEST_ASSERT(QDELETED(empty_pack), "Paczka bez płytki nie usunęła się")
	TEST_ASSERT(empty_pack.flags_1 & INITIALIZED_1, "Paczka bez płytki nie wywołała Initialize rodzica")

	// Zamrażarka rozłożona na północ łączy się na północ
	var/turf/pack_turf = get_step(run_loc_floor_bottom_left, NORTH)
	var/obj/machinery/atmospherics/components/unary/thermomachine/freezer/freezer = new(pack_turf)
	freezer.panel_open = TRUE
	var/obj/item/flatpack/freezer_pack = mechanic_pack_machine(freezer)
	var/obj/machinery/atmospherics/components/unary/thermomachine/deployed_freezer = freezer_pack.deploy(NORTH)
	TEST_ASSERT(istype(deployed_freezer), "Paczka nie rozłożyła się w zamrażarkę")
	TEST_ASSERT_EQUAL(deployed_freezer.dir, NORTH, "Zamrażarka z paczki stoi w złą stronę")
	TEST_ASSERT_EQUAL(deployed_freezer.initialize_directions, NORTH, "Zamrażarka z paczki łączy się w inną stronę, niż patrzy")
	qdel(deployed_freezer)

	// Konsole uzbrojenia i IFF są na czarnej liście
	TEST_ASSERT(mechanic_is_blacklisted(/obj/machinery/computer/ams), "Konsola AMS nie jest na czarnej liście")
	TEST_ASSERT(mechanic_is_blacklisted(/obj/machinery/computer/iff_console), "Konsola IFF nie jest na czarnej liście")

	// Czytnik bez prądu oddaje bieżący skan do kolejki
	var/obj/machinery/schematic_reader/reader = allocate(/obj/machinery/schematic_reader)
	var/datum/machine_schematic/schematic = new
	schematic.read_machine(reader)
	reader.current = schematic
	reader.read_timer = addtimer(CALLBACK(reader, TYPE_PROC_REF(/obj/machinery/schematic_reader, finish_reading)), 1 MINUTES, TIMER_STOPPABLE)
	reader.pause_reading()
	TEST_ASSERT(isnull(reader.current), "Czytnik bez prądu dalej czyta")
	TEST_ASSERT(isnull(reader.read_timer), "Czytnik bez prądu nie zatrzymał odczytu")
	TEST_ASSERT_EQUAL(reader.queue[1], schematic, "Przerwany skan nie wrócił na początek kolejki")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
