// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - kult krwi Cult 4: antag i drużyna, devotion, słowa run, zaklęcia run, dekonwersja
/datum/unit_test/aquila_bloodcult

/datum/unit_test/aquila_bloodcult/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	// Każde zaklęcie runy ma własną kombinację trzech słów
	var/list/combos = list()
	for(var/datum/rune_spell/spell_type as anything in subtypesof(/datum/rune_spell))
		var/w1 = initial(spell_type.word1)
		var/w2 = initial(spell_type.word2)
		var/w3 = initial(spell_type.word3)
		if(!w1 || !w2 || !w3)
			continue
		var/key = "[w1]|[w2]|[w3]"
		TEST_ASSERT(!(key in combos), "Two rune spells share the words of [spell_type]")
		combos += key
	TEST_ASSERT(length(combos) >= 15, "Too few rune spells with words ([length(combos)])")

	// Kultysta, drużyna, devotion
	var/mob/living/carbon/human/cultist_mob = allocate(/mob/living/carbon/human, left)
	cultist_mob.mind_initialize()
	// Mob bez klienta nie przechodzi is_convertable_to_cult (jak w tg), więc pomijamy to sprawdzenie
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.ignore_implant = TRUE
	var/datum/antagonist/cult/cultist = cultist_mob.mind.add_antag_datum(new_cultist)
	TEST_ASSERT(cultist, "Could not make a cultist")
	TEST_ASSERT(IS_CULTIST(cultist_mob), "IS_CULTIST does not see the new cultist")
	TEST_ASSERT(iscultist(cultist_mob), "iscultist() does not see the new cultist")
	var/datum/team/cult/cult = cultist.get_team()
	TEST_ASSERT(cult, "Cultist has no team")
	TEST_ASSERT(cultist_mob.mind in cult.members, "Cultist is not a team member")
	TEST_ASSERT_EQUAL(cultist.get_devotion_rank(), DEVOTION_TIER_0, "Fresh cultist has devotion rank")
	cultist.gain_devotion(600, DEVOTION_TIER_4)
	TEST_ASSERT_EQUAL(cultist.get_devotion_rank(), DEVOTION_TIER_2, "Devotion did not raise the rank")
	TEST_ASSERT(cult.total_devotion >= 600, "Team did not count devotion")

	// Słowa run: zapis trzech słów daje runę Komunikacji, wymazanie usuwa słowo
	initialize_rune_words()
	write_rune_word(right, GLOB.rune_words["self"], null, cultist_mob)
	write_rune_word(right, GLOB.rune_words["other"], null, cultist_mob)
	write_rune_word(right, GLOB.rune_words["technology"], null, cultist_mob)
	var/obj/effect/new_rune/rune = locate() in right
	TEST_ASSERT(rune, "Writing rune words made no rune")
	TEST_ASSERT(rune.word1 && rune.word2 && rune.word3, "Rune does not hold three words")
	var/spell_type = get_rune_spell(null, null, "examine", rune.word1, rune.word2, rune.word3)
	TEST_ASSERT_EQUAL(spell_type, /datum/rune_spell/communication, "Self Other Technology is not Communication")
	erase_rune_word(right)
	TEST_ASSERT(!rune.word3, "Erasing did not remove the last word")
	qdel(rune)

	// Dekonwersja i drużyna bez członków
	cultist_mob.mind.remove_antag_datum(/datum/antagonist/cult)
	TEST_ASSERT(!IS_CULTIST(cultist_mob), "Cultist was not deconverted")

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Blood cult code caused runtimes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
