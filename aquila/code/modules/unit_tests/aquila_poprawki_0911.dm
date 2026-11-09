// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprzątacz widzi odchody jako cel (wcześniej przejeżdżał obok nich)
/datum/unit_test/aquila_cleanbot_feces

/datum/unit_test/aquila_cleanbot_feces/Run()
	var/mob/living/simple_animal/bot/cleanbot/bot = allocate(/mob/living/simple_animal/bot/cleanbot)
	var/obj/effect/decal/cleanable/feces/poop = allocate(/obj/effect/decal/cleanable/feces)
	TEST_ASSERT(bot.process_scan(poop) == poop, "The cleanbot doesn't target feces")
	// Przełączenie opcji przebudowuje listę celów od nowa, odchody mają w niej zostać
	bot.blood = !bot.blood
	bot.get_targets()
	TEST_ASSERT(bot.process_scan(poop) == poop, "The cleanbot forgets feces after its settings change")

/// AQUILA - minimapa skalowana o ułamek ma się skalować po pikselach razem z nakładkami (wcześniej rozmyta)
/datum/unit_test/aquila_holomap_pixel_scale

/datum/unit_test/aquila_holomap_pixel_scale/Run()
	var/datum/station_holomap/holomap = new
	var/turf/spot = run_loc_floor_bottom_left
	holomap.initialize_holomap(spot.x, spot.y, spot.z, reinit_base_map = TRUE)
	TEST_ASSERT(holomap.base_map.appearance_flags & PIXEL_SCALE, "The holomap image is scaled with smoothing")
	TEST_ASSERT(holomap.base_map.appearance_flags & KEEP_TOGETHER, "The holomap overlays are scaled apart from the map")
	qdel(holomap)

/// AQUILA - każda latarka ma własną maskę cienia (wcześniej wspólna maska płaszczyzny: cień jednej latarki
/// wycinał światło drugiej i robił czarne kliny w oświetlonych miejscach)
/datum/unit_test/aquila_light_shadow_own_mask

/datum/unit_test/aquila_light_shadow_own_mask/Run()
	var/obj/effect/abstract/aq_light_shadow/first = allocate(/obj/effect/abstract/aq_light_shadow)
	var/obj/effect/abstract/aq_light_shadow/second = allocate(/obj/effect/abstract/aq_light_shadow)
	TEST_ASSERT(first.render_target && first.render_target != second.render_target, "Two lights share one shadow mask")
	TEST_ASSERT(copytext(first.render_target, 1, 2) == "*", "The shadow mask is drawn on the map")
	TEST_ASSERT(first.appearance_flags & KEEP_TOGETHER, "Without KEEP_TOGETHER BYOND 516 gives no mask for an object with overlays only")

#undef TEST_ASSERT
