// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message ? message : "No reason"] (expected [b], got [a])") }

/// Wysokość ikony z pamięci podręcznej (tgstation/tgstation#88266) jest taka sama jak z nowej ikony,
/// którą HUD-y tworzyły wcześniej przy każdej aktualizacji, także dla ikon większych niż 32x32.
/datum/unit_test/aquila_cached_icon_height

/datum/unit_test/aquila_cached_icon_height/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/icon/fresh = icon(human.icon, human.icon_state, human.dir)
	TEST_ASSERT_EQUAL(human.get_cached_height(), fresh.Height(), "Cached height of a human differs from icon().Height()")
	TEST_ASSERT_EQUAL(human.get_cached_width(), fresh.Width(), "Cached width of a human differs from icon().Width()")
	TEST_ASSERT(islist(GLOB.icon_dimensions[human.icon]), "The human icon file was not cached")

	var/obj/effect/abstract/big = allocate(/obj/effect/abstract)
	big.icon = 'icons/effects/32x64.dmi'
	var/icon/big_fresh = icon(big.icon)
	TEST_ASSERT_EQUAL(big.get_cached_height(), big_fresh.Height(), "Cached height of a 32x64 icon differs from icon().Height()")
	TEST_ASSERT_EQUAL(big.get_cached_height(), 64, "A 32x64 icon is not 64 px tall")

	big.icon = null
	TEST_ASSERT_EQUAL(big.get_cached_height(), 0, "An atom without an icon should report 0")

/// Śliska jest tylko podstawowa plama krwi. Warunek liczył wcześniej długości dwóch typesof() przy każdej plamie,
/// teraz porównuje typ; wynik ma zostać ten sam.
/datum/unit_test/aquila_blood_slippery_exact_type

/datum/unit_test/aquila_blood_slippery_exact_type/Run()
	var/obj/effect/decal/cleanable/blood/base = allocate(/obj/effect/decal/cleanable/blood)
	TEST_ASSERT(!QDELETED(base), "The base blood decal was deleted on spawn")
	TEST_ASSERT(base.is_slippery, "The base blood decal is no longer slippery")
	var/obj/effect/decal/cleanable/blood/wallsplatter/splatter = allocate(/obj/effect/decal/cleanable/blood/wallsplatter)
	TEST_ASSERT(!QDELETED(splatter), "The wall splatter was deleted on spawn")
	TEST_ASSERT(!splatter.is_slippery, "A blood subtype became slippery")

/// Migotanie (tgstation/tgstation#92503): lampa bez zasilania obszaru przerywa od razu i zostaje zgaszona.
/// Wcześniej przełączała się, usypiała z flickering = TRUE i na końcu zapalała z powrotem mimo braku zasilania.
/datum/unit_test/aquila_light_flicker_power

/datum/unit_test/aquila_light_flicker_power/Run()
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light)
	lamp.status = LIGHT_OK
	lamp.on = FALSE
	lamp.flicker()
	TEST_ASSERT(!lamp.flickering, "A light that is off started flickering")
	TEST_ASSERT(!lamp.on, "A light that is off was turned on by flicker()")

	var/area/lamp_area = get_area(lamp)
	var/old_power_light = lamp_area.power_light
	lamp_area.power_light = FALSE
	lamp.on = TRUE // stan sprzed power_change(): lampa myśli, że świeci, a obszar właśnie stracił zasilanie
	lamp.flicker(4)
	var/still_flickering = lamp.flickering
	var/still_on = lamp.on
	lamp_area.power_light = old_power_light
	TEST_ASSERT(!still_flickering, "A light without area power kept flickering")
	TEST_ASSERT(!still_on, "A light without area power stayed on after flicker()")

/// Reaktor poza statkiem (get_overmap() == null) nie może migotać lampami spoza statków,
/// bo dla nich get_overmap() też jest null.
/datum/unit_test/aquila_ship_flicker_needs_overmap

/datum/unit_test/aquila_ship_flicker_needs_overmap/Run()
	var/obj/item/reactor_stand_in = allocate(/obj/item/wrench)
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light)
	TEST_ASSERT(isnull(reactor_stand_in.get_overmap()), "Precondition: the test room is not on a ship")
	TEST_ASSERT(isnull(lamp.get_overmap()), "Precondition: the test lamp is not on a ship")
	lamp.status = LIGHT_OK
	lamp.on = TRUE
	TEST_ASSERT(lamp.has_power(), "Precondition: the test room has light power")
	// Własna lista: pętla po GLOB.machines ustępuje przez CHECK_TICK, zanim dojdzie do lampy testowej
	aq_flicker_ship_lights(reactor_stand_in, 100, list(lamp))
	TEST_ASSERT(!lamp.flickering, "A reactor outside any ship made lights outside ships flicker")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
