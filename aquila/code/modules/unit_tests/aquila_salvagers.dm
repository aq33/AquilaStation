// Makra asercji z core są #undef na końcu code/modules/unit_tests/_unit_tests.dm, test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - złomiarze jak w Goonie: czasy reklamatora (z premią złomiarza), złom z rozbiórki, paczki maszyn
/// z urządzenia dwukonstrukcyjnego i ich cena w S.R.O.K.A., teleporter ręczny z telekryształem, punkty i cel załogi
/datum/unit_test/aquila_salvagers

/datum/unit_test/aquila_salvagers/Run()
	var/turf/open/corner = run_loc_floor_bottom_left
	var/turf/open/east = locate(corner.x + 1, corner.y, corner.z)
	var/turf/open/north = locate(corner.x, corner.y + 1, corner.z)
	var/turf/open/far = locate(corner.x + 2, corner.y + 2, corner.z)

	var/mob/living/carbon/human/salvager = allocate(/mob/living/carbon/human, north)
	salvager.mind_initialize()
	salvager.mind.add_antag_datum(/datum/antagonist/pirate/salvager)
	var/datum/antagonist/pirate/salvager/datum = get_salvager_datum(salvager)
	TEST_ASSERT(istype(datum?.crew, /datum/team/pirate/salvager), "A salvager should get a salvager crew")
	TEST_ASSERT(locate(/datum/objective/salvage_points) in datum.crew.objectives, "The salvager crew should have the salvage objective")

	// Reklamator: czasy jak w Goonie, złomiarz pracuje o 25% szybciej
	var/obj/item/salvage_reclaimer/reclaimer = allocate(/obj/item/salvage_reclaimer)
	var/obj/machinery/recharger/recharger = allocate(/obj/machinery/recharger, east)
	var/expected = 5 SECONDS + salvage_complexity(recharger) * 3 SECONDS
	TEST_ASSERT_EQUAL(reclaimer.salvage_time(recharger), expected, "A machine should take 5 s plus 3 s per part")
	TEST_ASSERT_EQUAL(salvager_work_time(salvager, 20 SECONDS), 15 SECONDS, "A salvager should work 25% faster")
	recharger.resistance_flags |= INDESTRUCTIBLE
	TEST_ASSERT_EQUAL(reclaimer.salvage_time(recharger), 0, "Indestructible machines must not be salvaged")
	recharger.resistance_flags &= ~INDESTRUCTIBLE
	var/obj/machinery/atmospherics/pipe/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/simple, far)
	TEST_ASSERT_EQUAL(reclaimer.salvage_time(pipe), 0, "Pipes must not be salvaged")

	// Regresja: kliknięcie maszyny reklamatorem poza trybem walki rozbiera ją, a nie uderza (pusty akumulator kończy bez czekania)
	salvager.set_combat_mode(FALSE)
	reclaimer.charge = 0
	reclaimer.melee_attack_chain(salvager, recharger)
	TEST_ASSERT_EQUAL(recharger.obj_integrity, recharger.max_integrity, "The reclaimer should not hit what it salvages outside combat mode")
	reclaimer.charge = reclaimer.max_charge

	// To samo dla urządzenia dwukonstrukcyjnego przy maszynie, której nie da się spakować
	var/obj/item/salvage_dualconstructor/dualconstructor = allocate(/obj/item/salvage_dualconstructor)
	recharger.flags_1 |= NODECONSTRUCT_1
	dualconstructor.melee_attack_chain(salvager, recharger)
	TEST_ASSERT_EQUAL(recharger.obj_integrity, recharger.max_integrity, "The dualconstruction device should not hit machines outside combat mode")
	recharger.flags_1 &= ~NODECONSTRUCT_1

	// Złomiarze mają własną preferencję roli (antagoniści są opt-in, a ankieta nie może wymagać piratów)
	TEST_ASSERT(GLOB.role_preference_entries[/datum/role_preference/midround_ghost/salvager], "Salvagers should have their own role preference")

	// Rozbiórka reklamatorem daje złom
	reclaimer.salvage(recharger)
	TEST_ASSERT(QDELETED(recharger), "The salvaged machine should be gone")
	TEST_ASSERT(locate(/obj/item/stack/scrap/plating) in east, "Salvaging a machine should leave scrap metal")
	TEST_ASSERT(locate(/obj/item/stack/scrap/electronics) in east, "Salvaging a machine should leave electronic scrap")
	var/obj/item/stack/scrap/plating/scrap = locate() in east
	TEST_ASSERT_EQUAL(salvager_appraise(scrap), scrap.scrap_value * scrap.amount, "S.R.O.K.A. should buy scrap by its value")

	// Urządzenie dwukonstrukcyjne pakuje maszynę w paczkę, którą S.R.O.K.A. skupuje najdrożej
	var/obj/machinery/recharger/second = allocate(/obj/machinery/recharger, far)
	TEST_ASSERT(salvage_packable(second), "A recharger should be packable")
	var/obj/item/salvage_frame/frame = allocate(/obj/item/salvage_frame, far)
	frame.pack(second)
	TEST_ASSERT_EQUAL(frame.machine_type, /obj/machinery/recharger, "The frame should remember the machine")
	TEST_ASSERT_EQUAL(salvager_appraise(frame), 100, "A packed machine from the ship should be worth 100")
	frame.had_access = TRUE
	TEST_ASSERT_EQUAL(salvager_appraise(frame), 175, "Restricted access should add 75")
	frame.salvager_part = TRUE
	TEST_ASSERT_EQUAL(salvager_appraise(frame), 5, "Things bought in the shop should sell for 5")
	// Regresja: paczka tworzyła przy złożeniu nową maszynę (pełny automat, naprawiona maszyna); teraz wraca ta sama
	TEST_ASSERT_EQUAL(second.loc, frame, "The packed machine should travel inside the frame")
	var/obj/machinery/deployed = frame.deploy(far, NORTH)
	TEST_ASSERT_EQUAL(deployed, second, "Unpacking should bring back the same machine")
	TEST_ASSERT_EQUAL(second.loc, far, "The machine should stand where the frame was")
	TEST_ASSERT(QDELETED(frame), "The frame should be used up")
	// Regresja: dostęp z mapy (req_access_txt) nie był liczony, bo listy powstają dopiero w gen_access()
	var/obj/machinery/recharger/restricted = allocate(/obj/machinery/recharger, far)
	restricted.req_access = null
	restricted.req_access_txt = "[ACCESS_RESEARCH]"
	var/obj/item/salvage_frame/restricted_frame = allocate(/obj/item/salvage_frame, far)
	restricted_frame.pack(restricted)
	TEST_ASSERT(restricted_frame.had_access, "Mapped access should count as restricted access")

	// Regresja: magazyn energii jest tylko w sklepie, a zasada „rzeczy ze sklepu za 5” zjadała jego cenę
	var/obj/item/powersink/salvager/sink = allocate(/obj/item/powersink/salvager)
	sink.salvager_part = TRUE
	sink.power_drained = sink.max_power
	TEST_ASSERT_EQUAL(salvager_appraise(sink), 15000, "A full salvager power sink should be worth 15000")

	// Teleporter ręczny: telekryształ dodaje ładunek, najwyżej 5
	var/obj/item/salvager_hand_tele/tele = allocate(/obj/item/salvager_hand_tele)
	var/obj/item/stack/telecrystal/crystals = allocate(/obj/item/stack/telecrystal)
	crystals.amount = 5
	tele.attackby(crystals, salvager)
	TEST_ASSERT_EQUAL(tele.charges, 4, "A telecrystal should add a charge")
	tele.attackby(crystals, salvager)
	tele.attackby(crystals, salvager)
	TEST_ASSERT_EQUAL(tele.charges, 5, "The teleporter should hold at most 5 charges")

	// Punkty: osobiste do wydania, wspólne do celu załogi
	datum.add_salvage_points(15000)
	TEST_ASSERT_EQUAL(datum.salvager_points, 15000, "Sold scrap should give points to spend")
	var/datum/team/pirate/salvager/crew = datum.crew
	TEST_ASSERT_EQUAL(crew.total_points(), 15000, "The crew should count every salvager's points")
	var/datum/objective/salvage_points/goal = locate() in crew.objectives
	TEST_ASSERT(goal.check_completion(), "Selling 15000 points of scrap should complete the objective")

	// Szablon statku jest poprawną mapą
	var/datum/map_template/shuttle/pirate/salvager/ship = new
	TEST_ASSERT(ship.width > 0 && ship.height > 0, "The salvager ship template did not load its map")

	salvager.mind.remove_antag_datum(/datum/antagonist/pirate/salvager)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
