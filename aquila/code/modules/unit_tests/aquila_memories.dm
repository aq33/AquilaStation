// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Wspomnienia z tg: zapis, zastępowanie, nieprzytomność, opowieść, hak podpalenia, rycina, tatuaż i wchłonięcie przez Zmiennokształtnego
/datum/unit_test/aquila_memories

/datum/unit_test/aquila_memories/Run()
	var/mob/living/carbon/human/cook = allocate(/mob/living/carbon/human)
	cook.mind_initialize()
	cook.mind.assigned_role = JOB_NAME_COOK
	var/datum/mind/mind = cook.mind

	// Zapis i nazwa z zawodem w mianowniku
	var/datum/memory/first = cook.add_mob_memory(/datum/memory/witnessed_death, protagonist = cook)
	TEST_ASSERT(istype(first, /datum/memory/witnessed_death), "add_mob_memory did not return the memory")
	TEST_ASSERT_EQUAL(mind.memories[/datum/memory/witnessed_death], first, "Memory not stored under its type")
	TEST_ASSERT(findtext(first.name, lowertext(JOB_NAME_COOK)), "Memory name has no job title: [first.name]")

	// Ten sam typ zastępuje stare wspomnienie
	var/datum/memory/second = cook.add_mob_memory(/datum/memory/witnessed_death, protagonist = cook)
	TEST_ASSERT(QDELETED(first), "Replaced memory was not deleted")
	TEST_ASSERT_EQUAL(mind.memories[/datum/memory/witnessed_death], second, "Memory was not replaced")

	// Nieprzytomny nie zapamiętuje, chyba że wspomnienie ma MEMORY_SKIP_UNCONSCIOUS
	cook.stat = UNCONSCIOUS
	TEST_ASSERT(isnull(cook.add_mob_memory(/datum/memory/was_slipped, antagonist = cook)), "Unconscious mob got a memory")
	TEST_ASSERT(cook.add_mob_memory(/datum/memory/was_cyborged, protagonist = mind), "MEMORY_SKIP_UNCONSCIOUS memory was not added")
	cook.stat = CONSCIOUS

	// Opowieść do ryciny: polska, z datą
	var/story = second.generate_story(STORY_ENGRAVING, STORY_FLAG_DATED)
	TEST_ASSERT(length(story) && findtext(story, "roku"), "Engraving story has no date: [story]")
	TEST_ASSERT(findtext(story, lowertext(JOB_NAME_COOK)), "Engraving story has no protagonist: [story]")

	// Prawdziwy hak: podpalenie daje wspomnienie
	cook.fire_stacks = 5
	cook.IgniteMob()
	cook.ExtinguishMob()
	TEST_ASSERT(mind.memories[/datum/memory/was_burning], "Igniting did not give the was_burning memory")

	// Rycina w ścianie
	var/turf/wall_turf = locate(cook.x + 1, cook.y, cook.z)
	var/old_turf_type = wall_turf.type
	var/turf/closed/wall/wall = wall_turf.ChangeTurf(/turf/closed/wall)
	wall.AddComponent(/datum/component/engraved, story, TRUE, second.story_value)
	var/datum/component/engraved/engraving = wall.GetComponent(/datum/component/engraved)
	TEST_ASSERT(engraving, "Engraving component was not added to the wall")
	TEST_ASSERT(HAS_TRAIT(wall, TRAIT_NOT_ENGRAVABLE), "Engraved wall can be engraved again")
	TEST_ASSERT(engraving in SSpersistence.wall_engravings, "Engraving is not tracked for persistence")
	TEST_ASSERT(findtext(jointext(wall.examine(cook), ""), story), "Engraving story not shown on examine")
	qdel(engraving)
	TEST_ASSERT(!HAS_TRAIT(wall, TRAIT_NOT_ENGRAVABLE), "Trait stays after the engraving is removed")
	TEST_ASSERT(!(engraving in SSpersistence.wall_engravings), "Removed engraving stays in persistence")
	wall.ChangeTurf(old_turf_type)

	// Tatuaż widać przy oglądaniu właściciela bez ubrania
	var/obj/item/bodypart/chest = cook.get_bodypart(BODY_ZONE_CHEST)
	chest.AddComponent(/datum/component/tattoo, "Tatuaż testowy z kotwicą.")
	TEST_ASSERT(HAS_TRAIT(chest, TRAIT_NOT_ENGRAVABLE), "Tattooed limb can be tattooed again")
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	TEST_ASSERT(findtext(jointext(cook.examine(viewer), ""), "Tatuaż testowy z kotwicą."), "Tattoo not shown when examining the owner")

	// Wykorzystane wspomnienia nie nadają się już na rycinę
	for(var/memory_type in mind.memories)
		var/datum/memory/memory = mind.memories[memory_type]
		memory.memory_flags |= MEMORY_FLAG_ALREADY_USED
	TEST_ASSERT(!mind.has_story_memory(), "Used memories are still offered for engraving")

	// Zmiennokształtny czyta wspomnienia jako opowieści, a ofiara je traci
	var/memory_name = second.name
	var/stolen = changeling_absorb_memory_stories(mind)
	TEST_ASSERT(findtext(stolen, memory_name), "Changeling did not get the victim's memory: [stolen]")
	TEST_ASSERT(!length(mind.memories), "Victim kept memories after absorb")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
