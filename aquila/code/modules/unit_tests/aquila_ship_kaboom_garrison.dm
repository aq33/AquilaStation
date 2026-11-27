// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - obsada ruin: ludzie z mapy ruiny zamieniają się na żołnierzy frakcji układu z tą samą bronią, fauna zostaje
/datum/unit_test/planet_ruin_garrison
	var/list/spawned = list()

/datum/unit_test/planet_ruin_garrison/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/list/turf/spots = list()
	for(var/i in 0 to 4)
		spots += locate(start.x + i, start.y, start.z)
	spawned += new /mob/living/basic/trooper/pirate/ranged(spots[1])
	spawned += new /mob/living/basic/trooper/pirate/ranged/space(spots[2])
	spawned += new /mob/living/basic/trooper/russian/ranged/trooper(spots[3])
	spawned += new /mob/living/basic/cockroach(spots[4])
	// Pustelnik z ruiny pubbytown: pirat, któremu mapa zmieniła frakcję
	var/mob/living/basic/trooper/pirate/melee/hermit = new(spots[5])
	hermit.faction = list("hermit", "mining")
	spawned += hermit

	// Układ niczyj: obsada z mapy zostaje
	TEST_ASSERT_EQUAL(planet_garrison_ruin(spots, "unaligned", 100, "test"), 0, "An unaligned system changed the ruin crew")

	// Syndykat: ta sama broń, wersja próżniowa dla próżniowego oryginału, karaluch zostaje
	TEST_ASSERT_EQUAL(planet_garrison_ruin(spots, "syndicate", 100, "test"), 3, "Not every human of the ruin joined the Syndicate")
	TEST_ASSERT(locate(/mob/living/basic/trooper/syndicate/ranged) in spots[1], "A pistol pirate did not become a Syndicate gunner")
	TEST_ASSERT(!(locate(/mob/living/basic/trooper/pirate) in spots[1]), "The replaced pirate stayed in the ruin")
	TEST_ASSERT(locate(/mob/living/basic/trooper/syndicate/ranged/space) in spots[2], "A space pirate did not get a Syndicate space suit")
	TEST_ASSERT(locate(/mob/living/basic/trooper/syndicate/ranged/shotgun) in spots[3], "A Russian with a shotgun did not keep the shotgun")
	TEST_ASSERT(locate(/mob/living/basic/cockroach) in spots[4], "The ruin fauna was replaced")
	TEST_ASSERT(!QDELETED(hermit) && hermit.loc == spots[5], "A hermit with a faction set by the map was replaced by the system faction")
	hermit.faction = list("pirate")
	hermit.name = "pustelnik"
	TEST_ASSERT(planet_garrison_mapped_character(hermit), "A trooper renamed by the map does not count as a ruin character")

	// Blok NT: ochrona strzela dopiero zaatakowana; próżniowi zostają, bo ochrona NT nie ma skafandrów
	TEST_ASSERT_EQUAL(planet_garrison_ruin(spots, "solgov", 100, "test"), 2, "Wrong number of humans replaced for SolGov")
	var/mob/living/basic/trooper/nanotrasen/ranged/gunner = locate() in spots[1]
	TEST_ASSERT(gunner?.type == /mob/living/basic/trooper/nanotrasen/ranged/peaceful, "A Syndicate pistol gunner in SolGov space did not become NT security with a pistol ([gunner?.type])")
	TEST_ASSERT(istype(gunner.ai_controller, /datum/ai_controller/basic_controller/trooper/ranged/peaceful), "NT security in a ruin attacks on sight instead of only when attacked")
	TEST_ASSERT(locate(/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful) in spots[3], "A shotgun trooper in SolGov space did not get the closest NT weapon")
	TEST_ASSERT(locate(/mob/living/basic/trooper/syndicate/ranged/space) in spots[2], "A space trooper was replaced by NT security without a suit")

/datum/unit_test/planet_ruin_garrison/Destroy()
	var/turf/start = run_loc_floor_bottom_left
	for(var/i in 0 to 4)
		for(var/mob/living/basic/M in locate(start.x + i, start.y, start.z))
			qdel(M)
	spawned.Cut()
	return ..()

/// AQUILA - kinematyk zniszczenia okrętu: scena z ikony okrętu, trafienia w kadłub i wrak w trzech kawałkach
/datum/unit_test/ship_kaboom_cinematic

/datum/unit_test/ship_kaboom_cinematic/Run()
	GLOB.ship_kaboom_source = list('nsv13/icons/overmap/new/nanotrasen/frigate.dmi', "shrike")
	var/datum/cinematic/nsv_kaboom/kaboom = new
	TEST_ASSERT_EQUAL(kaboom.ship_state, "shrike", "The cinematic did not take the destroyed ship's sprite")
	TEST_ASSERT_EQUAL(length(GLOB.ship_kaboom_source), 0, "The ship source stayed for the next cinematic")
	TEST_ASSERT_EQUAL(kaboom.ship_scale, 4, "A 48 px ship is not scaled to fill the screen")
	TEST_ASSERT_EQUAL(length(kaboom.hit_points), 5, "Wrong number of hull hits")
	var/icon/sprite = icon(kaboom.ship_icon, kaboom.ship_state, SOUTH, 1)
	for(var/list/point as anything in kaboom.hit_points)
		TEST_ASSERT(sprite.GetPixel(point[1], point[2]), "A hull hit at [point[1]],[point[2]] lands outside the hull")
	kaboom.hit(1)
	TEST_ASSERT(length(kaboom.ship.vis_contents) >= 2, "A hit added no explosion and fire to the hull")
	kaboom.break_apart(120)
	TEST_ASSERT_EQUAL(length(kaboom.wreck), 3, "The wreck did not break into three pieces")
	for(var/obj/effect/abstract/ship_kaboom/piece as anything in kaboom.wreck)
		TEST_ASSERT(piece in kaboom.stage.vis_contents, "A wreck piece is not on the screen")
	qdel(kaboom)

	// Nieznany sprite (np. kinematyk z panelu admina): domyślna fregata
	GLOB.ship_kaboom_source = list('nsv13/icons/overmap/new/nanotrasen/frigate.dmi', "no such state")
	kaboom = new
	TEST_ASSERT_EQUAL(kaboom.ship_state, "frigate", "An unknown ship sprite did not fall back to the frigate")
	qdel(kaboom)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
