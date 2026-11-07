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

/// Zgaszona lampa nie zaczyna migotać (tgstation/tgstation#92503): wcześniej ustawiała flickering i wchodziła w pętlę.
/datum/unit_test/aquila_light_flicker_off

/datum/unit_test/aquila_light_flicker_off/Run()
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light)
	lamp.on = FALSE
	lamp.flicker()
	TEST_ASSERT(!lamp.flickering, "A light that is off started flickering")
	TEST_ASSERT(!lamp.on, "A light that is off was turned on by flicker()")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
