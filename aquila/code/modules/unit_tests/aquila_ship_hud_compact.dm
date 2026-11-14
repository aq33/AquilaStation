// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Kompaktowy HUD sternika: zamiast panelu pasek i radar, DRADIS bez samootwierania, segmenty działają jak przyciski,
/// katapulta wymaga potwierdzenia, radar widzi sojusznika, a zejście ze sterów usuwa HUD
/datum/unit_test/aquila_ship_hud_compact
	var/obj/structure/overmap/small_craft/combat/light/fighter
	var/obj/structure/overmap/small_craft/combat/light/wingman
	var/mob/living/carbon/human/dummy

/datum/unit_test/aquila_ship_hud_compact/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "Brak środka stacji")
	fighter = new(center)
	wingman = new(locate(center.x + 5, center.y, center.z))
	dummy = new(center)
	fighter.enter(dummy)
	dummy.aq_ship_hud_override = "compact"
	fighter.start_piloting(dummy, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)

	var/datum/aq_ship_hud/hud = dummy.aq_ship_hud
	TEST_ASSERT(hud?.ship == fighter, "Pilot nie dostał kompaktowego HUD-u")
	TEST_ASSERT(!LAZYLEN(dummy.aquila_consoles), "Pilot z kompaktowym HUD-em dostał też stary panel")
	TEST_ASSERT(fighter.skip_dradis_popup(OVERMAP_USER_ROLE_PILOT), "DRADIS dalej otwiera się sam przy kompaktowym HUD-zie")

	var/list/contents = hud.bar_contents()
	for(var/id in list("brakes", "rotation", "weapon", "hull", "eject"))
		TEST_ASSERT(id in contents, "Na pasku pilota myśliwca brakuje segmentu [id]")

	// Segment hamulca przełącza hamulec i zmienia napis
	var/brakes_before = fighter.brakes
	hud.use_segment("brakes")
	TEST_ASSERT(fighter.brakes != brakes_before, "Segment hamulca nie przełączył hamulca")
	TEST_ASSERT(hud.bar_contents()["brakes"] != contents["brakes"], "Napis hamulca się nie zmienił")

	// Katapulta: pierwsze kliknięcie tylko uzbraja
	hud.use_segment("eject")
	TEST_ASSERT(hud.eject_armed_until > world.time, "Pierwsze kliknięcie nie uzbroiło katapulty")
	TEST_ASSERT(dummy.loc == fighter, "Jedno kliknięcie katapulty wyrzuciło pilota")

	// Radar widzi sojuszniczy myśliwiec na zielono
	var/found = FALSE
	for(var/list/contact as anything in aq_radar_contacts(fighter, fighter.dradis))
		if(contact["atom"] == wingman)
			found = contact["colour"] == "#32cd32"
	TEST_ASSERT(found, "Radar nie pokazał sojusznika na zielono")

	// Klasyczny układ dalej działa
	TEST_ASSERT(aq_ship_bar_width("Kadłub 100%") >= 40, "Za wąski segment paska")
	fighter.stop_piloting(dummy, eject_mob = FALSE)
	TEST_ASSERT(!dummy.aq_ship_hud && QDELETED(hud), "HUD został po zejściu ze sterów")

/datum/unit_test/aquila_ship_hud_compact/Destroy()
	if(fighter && dummy)
		fighter.mobs_in_ship -= dummy
		dummy.moveToNullspace()
	QDEL_NULL(fighter)
	QDEL_NULL(wingman)
	QDEL_NULL(dummy)
	return ..()

#undef TEST_ASSERT
