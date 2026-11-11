// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Dyszenie startuje przy wyczerpaniu, cichnie po złapaniu oddechu i nie tyka dalej u martwego
/datum/unit_test/aquila_exhaustion_panting

/datum/unit_test/aquila_exhaustion_panting/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human)
	runner.stamina.adjust(-STAMINA_MAX * 0.7)
	TEST_ASSERT(HAS_TRAIT(runner, TRAIT_EXHAUSTED), "Low stamina did not exhaust")
	TEST_ASSERT(runner.exhaustion_panting?.timerid, "An exhausted human does not pant")
	runner.setStaminaLoss(0)
	TEST_ASSERT(!runner.exhaustion_panting.timerid, "Panting went on after catching breath")

	runner.stamina.adjust(-STAMINA_MAX * 0.7)
	TEST_ASSERT(runner.exhaustion_panting.timerid, "Panting did not come back on the second exhaustion")
	runner.death()
	runner.exhaustion_panting.sound_loop(world.time)
	TEST_ASSERT(!runner.exhaustion_panting.timerid, "The panting loop kept ticking on a dead body")

/// Wybuch, który dołożył głuchoty, daje pisk; nauszniki chronią przed głuchotą i piskiem
/datum/unit_test/aquila_explosion_ring

/datum/unit_test/aquila_explosion_ring/Run()
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human)
	bystander.ex_act(EXPLODE_LIGHT)
	TEST_ASSERT_EQUAL(bystander.last_explosion_ring, world.time, "A deafening explosion did not ring in the ears")

	var/mob/living/carbon/human/protected = allocate(/mob/living/carbon/human)
	protected.equip_to_slot_or_del(new /obj/item/clothing/ears/earmuffs(protected), ITEM_SLOT_EARS)
	protected.ex_act(EXPLODE_LIGHT)
	TEST_ASSERT_EQUAL(protected.last_explosion_ring, 0, "Earmuffs did not stop the ringing")

/// Kolor sprayu jest wspólny dla kombinezonu i hełmu, zmycie z jednej części zmywa obie
/datum/unit_test/aquila_hardsuit_colour_sync

/datum/unit_test/aquila_hardsuit_colour_sync/Run()
	var/obj/item/clothing/suit/space/hardsuit/suit = allocate(/obj/item/clothing/suit/space/hardsuit)
	TEST_ASSERT(suit.helmet, "A hardsuit spawned without its helmet")
	suit.add_atom_colour("#ff0000", WASHABLE_COLOUR_PRIORITY)
	TEST_ASSERT_EQUAL(suit.helmet.color, "#ff0000", "Painting the suit did not paint the helmet")
	suit.helmet.add_atom_colour("#00ff00", WASHABLE_COLOUR_PRIORITY)
	TEST_ASSERT_EQUAL(suit.color, "#00ff00", "Painting the helmet did not paint the suit")
	suit.helmet.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	TEST_ASSERT(!suit.color && !suit.helmet.color, "Washing the helmet left paint on the suit")

/// Szafa na skafandry: pętla dezynfekcji podczas cyklu, wersja awarii przy przeładowaniu, cisza po końcu
/datum/unit_test/aquila_suit_storage_uv_sound

/datum/unit_test/aquila_suit_storage_uv_sound/Run()
	var/obj/machinery/suit_storage_unit/unit = allocate(/obj/machinery/suit_storage_unit)
	unit.state_open = FALSE
	unit.cook()
	TEST_ASSERT(unit.uv_soundloop && !istype(unit.uv_soundloop, /datum/looping_sound/suit_storage_uv/overloaded), "The UV cycle has no disinfection loop")
	unit.uv_cycles = 0
	unit.cook()
	TEST_ASSERT(!unit.uv_soundloop, "The disinfection loop outlived the cycle")

	var/obj/machinery/suit_storage_unit/overloaded = allocate(/obj/machinery/suit_storage_unit)
	overloaded.uv_super = TRUE
	overloaded.cook()
	TEST_ASSERT(istype(overloaded.uv_soundloop, /datum/looping_sound/suit_storage_uv/overloaded), "An overloaded UV cycle sounds like a normal one")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
