// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

// AQUILA - regression tests for the fixes found while auditing the wiki (branch poprawki-audyt-wiki)

/// Delimber anomaly: an arm is replaced with an arm (not a leg), and a target missing the picked limb does not end the pulse for the others
/datum/unit_test/aquila_delimber_limb_zones

/datum/unit_test/aquila_delimber_limb_zones/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next_to = locate(start.x + 1, start.y, start.z)
	TEST_ASSERT(isopenturf(next_to), "No open turf next to the test room corner")
	// Only the chest and the left arm are left, so a pulse can pick a zone this human has no limb in
	var/mob/living/carbon/human/stump = allocate(/mob/living/carbon/human, start)
	var/mob/living/carbon/human/whole = allocate(/mob/living/carbon/human, next_to)
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/part = stump.get_bodypart(zone)
		part.drop_limb()
		qdel(part)
	var/obj/item/source = allocate(/obj/item/pen, start)

	// Stałe ziarno: impuls losuje strefy i typy kończyn, więc bez niego wynik zależałby od losowania
	rand_seed(1337)
	var/arm_replaced = FALSE
	for(var/i in 1 to 30)
		var/list/whole_parts = whole.bodyparts.Copy()
		var/obj/item/bodypart/old_arm = stump.get_bodypart(BODY_ZONE_L_ARM)
		delimber_pulse(source, 5)
		var/list/new_parts = whole.bodyparts - whole_parts
		TEST_ASSERT_EQUAL(length(new_parts), 1, "Pulse [i] did not replace exactly one limb of the intact human")
		var/obj/item/bodypart/arm = stump.get_bodypart(BODY_ZONE_L_ARM)
		TEST_ASSERT(istype(arm, /obj/item/bodypart/l_arm), "Pulse [i] turned the left arm into [arm ? arm.type : "nothing"]")
		TEST_ASSERT(!stump.get_bodypart(BODY_ZONE_L_LEG) && !stump.get_bodypart(BODY_ZONE_R_LEG), "Pulse [i] grew a leg on a human with no legs")
		TEST_ASSERT(!stump.get_bodypart(BODY_ZONE_R_ARM) && !stump.get_bodypart(BODY_ZONE_HEAD), "Pulse [i] grew a missing limb back")
		if(arm != old_arm)
			arm_replaced = TRUE
	rand_seed(world.realtime) // dalsze testy znów losowo
	TEST_ASSERT(arm_replaced, "30 pulses never replaced the left arm")

/// Dynamic: rulesets with required_enemies do not index the list with 0 when threat is below 10
/datum/unit_test/aquila_dynamic_low_threat_enemies

/datum/unit_test/aquila_dynamic_low_threat_enemies/Run()
	var/datum/game_mode/dynamic/mode = new
	allocated += mode
	var/mob/living/carbon/human/candidate = allocate(/mob/living/carbon/human)

	var/datum/dynamic_ruleset/midround/autotraitor/sleeper = new
	allocated += sleeper
	sleeper.mode = mode
	sleeper.living_players = list(candidate)
	var/datum/dynamic_ruleset/latejoin/infiltrator/infiltrator = new
	allocated += infiltrator
	infiltrator.mode = mode
	infiltrator.candidates = list(candidate)

	mode.threat_level = 5
	var/result = sleeper.ready()
	TEST_ASSERT(!isnull(result), "Sleeper Agent ready() at threat 5 returned null (runtime on required_enemies)")
	TEST_ASSERT(!result, "Sleeper Agent was ready at threat 5 without the [sleeper.required_enemies[1]] enemies it needs")
	result = infiltrator.ready()
	TEST_ASSERT(!isnull(result), "Syndicate Infiltrator ready() at threat 5 returned null (runtime on required_enemies)")
	TEST_ASSERT(!result, "Syndicate Infiltrator was ready at threat 5 without the [infiltrator.required_enemies[1]] enemies it needs")

	// Above the list (threat 100 -> index 10) still uses the last entry, which needs no enemies
	mode.threat_level = 100
	TEST_ASSERT_EQUAL(sleeper.ready(), TRUE, "Sleeper Agent was not ready at threat 100")
	TEST_ASSERT_EQUAL(infiltrator.ready(), TRUE, "Syndicate Infiltrator was not ready at threat 100")

/// Botany bounties: chili, ice chili and ghost chili are three bounties, each asking for its own pepper
/datum/unit_test/aquila_chili_bounties

/datum/unit_test/aquila_chili_bounties/Run()
	var/list/expected = list(
		/datum/bounty/item/botany/chili = /obj/item/food/grown/chili,
		/datum/bounty/item/botany/ice_chili = /obj/item/food/grown/icepepper,
		/datum/bounty/item/botany/ghost_chili = /obj/item/food/grown/ghost_chili,
	)
	var/list/names = list()
	for(var/bounty_type in expected)
		var/datum/bounty/item/botany/bounty = new bounty_type
		allocated += bounty
		names |= bounty.name
		for(var/pepper in expected)
			var/pepper_type = expected[pepper]
			if(pepper == bounty_type)
				TEST_ASSERT(bounty.wanted_types[pepper_type], "[bounty_type] does not accept [pepper_type]")
			else
				TEST_ASSERT(!bounty.wanted_types[pepper_type], "[bounty_type] accepts [pepper_type]")
	TEST_ASSERT_EQUAL(length(names), 3, "The chili bounties share names: [english_list(names)]")

/// Techweb: designs that used to be in no node can be researched, and the mech taser can be built
/datum/unit_test/aquila_orphan_designs

/datum/unit_test/aquila_orphan_designs/Run()
	var/list/expected = list(
		"botany" = list("seed_editor_board", "plant_mutator_board", "seeder", "plant_analyser_board", "refraction_catalogue_board"),
		"mech_disabler" = list("mech_taser"),
		"sec_basic" = list("detective_scanner"),
		"base" = list("plumbing_receiver", "liquid_pump", "protolathe"),
		"comptech" = list("bounty"),
		"telecomms" = list("message_monitor"),
	)
	for(var/node_id in expected)
		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
		TEST_ASSERT(node != SSresearch.error_node, "Techweb node [node_id] does not exist")
		// SSresearch drops invalid design ids from nodes, so being here means the design exists too
		for(var/design_id in expected[node_id])
			TEST_ASSERT(design_id in node.design_ids, "Node [node_id] does not contain the design [design_id]")
			TEST_ASSERT(SSresearch.techweb_design_by_id(design_id) != SSresearch.error_design, "Design [design_id] does not exist")

	var/datum/design/taser = SSresearch.techweb_design_by_id("mech_taser")
	TEST_ASSERT(length(taser.materials), "The mech taser design needs no materials")
	for(var/material in taser.materials)
		TEST_ASSERT(istype(material, /datum/material/iron), "The mech taser design needs the unknown material [material]")

	var/obj/machinery/plumbing/receiver/receiver = allocate(/obj/machinery/plumbing/receiver)
	TEST_ASSERT(istype(receiver.circuit, /obj/item/circuitboard/machine/plumbing_receiver), "The chemical recipient is not built from its board")

/// Diseases: Viral Evolution gives back what it takes, viral power reads the stage speed, and a copy keeps the mutability
/datum/unit_test/aquila_disease_mutability

/datum/unit_test/aquila_disease_mutability/Run()
	var/datum/disease/advance/virus = new
	allocated += virus
	var/base_mutability = virus.mutability
	var/datum/symptom/viralevolution/evolution = new
	virus.AddSymptom(evolution)
	TEST_ASSERT_EQUAL(virus.mutability, base_mutability + 2, "Viral Evolution did not add 2 mutability")

	var/datum/disease/advance/copy = virus.Copy()
	allocated += copy
	TEST_ASSERT_EQUAL(copy.mutability, virus.mutability, "Copy() of the disease did not keep its mutability")

	virus.RemoveSymptom(evolution)
	TEST_ASSERT_EQUAL(virus.mutability, base_mutability, "Adding and removing Viral Evolution changed the mutability")
	qdel(evolution)

	var/datum/symptom/viralpower/power = new
	virus.stage_rate = 8
	virus.speed = 0
	power.Start(virus)
	TEST_ASSERT_EQUAL(power.power, 2, "Viral power did not double at stage speed 8")
	qdel(power)

/// Cooking: the kremówka recipe is in the build
/datum/unit_test/aquila_kremowka_recipe

/datum/unit_test/aquila_kremowka_recipe/Run()
	for(var/datum/crafting_recipe/recipe as anything in GLOB.cooking_recipes + GLOB.crafting_recipes)
		if(recipe.result == /obj/item/food/pie/kremowka)
			return
	TEST_ASSERT(FALSE, "No crafting recipe makes /obj/item/food/pie/kremowka")

/// End of round survey: an answer of exactly the maximum length is not cut
/datum/unit_test/aquila_round_survey_length

/datum/unit_test/aquila_round_survey_length/Run()
	var/max_text = round_survey_max_text()
	TEST_ASSERT_EQUAL(max_text, 1000, "Survey text limit changed")

	var/answer = "[repeat_string(max_text - 1, "a")]ż"
	var/cleaned = round_survey_clean_text(answer)
	TEST_ASSERT_EQUAL(length_char(cleaned), max_text, "A [max_text] character answer was cut")
	TEST_ASSERT_EQUAL(copytext_char(cleaned, -1), "ż", "The last character of a [max_text] character answer was lost")
	TEST_ASSERT_EQUAL(length_char(round_survey_clean_text("[answer]bbb")), max_text, "A too long answer was not cut to [max_text] characters")

/// End of round survey in the report window: no rating = not saved, one survey per player, the report sends the survey state
/datum/unit_test/aquila_round_survey_submit

/datum/unit_test/aquila_round_survey_submit/Run()
	var/mob/living/carbon/human/player = allocate(/mob/living/carbon/human)
	var/ckey = "aquilasurveytest"
	var/survey_file = "data/unit_test_ankiety.txt"
	fdel(survey_file)
	GLOB.round_survey_submitted -= ckey

	TEST_ASSERT(!round_survey_submit(player, ckey, list("fun" = "0", "bugs" = "x"), survey_file), "A survey without a rating was saved")
	TEST_ASSERT(!round_survey_submit(player, ckey, list("fun" = "2.5"), survey_file), "A survey with a fractional rating was saved")
	TEST_ASSERT(!fexists(survey_file), "A rejected survey was written to the file")

	TEST_ASSERT(round_survey_submit(player, ckey, list("fun" = "4", "bugs" = "linia 1\nlinia 2", "comments" = ""), survey_file), "A correct survey was not saved")
	var/saved = file2text(survey_file)
	TEST_ASSERT(findtext(saved, "Wrażenia: 4/5"), "The rating is missing in the file: [saved]")
	TEST_ASSERT(findtext(saved, "Błędy: linia 1 / linia 2"), "The answer was not put in one line: [saved]")
	TEST_ASSERT(findtext(saved, "Uwagi: -"), "An empty answer was not saved as \"-\": [saved]")
	TEST_ASSERT(!round_survey_submit(player, ckey, list("fun" = "5"), survey_file), "The same player sent the survey twice")

	var/list/data = GLOB.roundend_report_ui.ui_data(player)
	TEST_ASSERT(!data["vote_open"], "The report shows the map vote while no map vote is running")
	var/list/static_data = GLOB.roundend_report_ui.ui_static_data(player)
	TEST_ASSERT_EQUAL(static_data["max_text"], round_survey_max_text(), "The report sends a wrong survey text limit")

	GLOB.round_survey_submitted -= ckey
	fdel(survey_file)

/// Separated Contents: once the fruit mixes, the whole content reacts at once, then the holder goes back to normal reactions
/datum/unit_test/aquila_separated_contents_react

/datum/unit_test/aquila_separated_contents_react/Run()
	var/obj/item/fruit = allocate(/obj/item/pen)
	var/datum/plant_trait/fruit/seperated_contents/trait = new
	allocated += trait
	trait.prepare_fruit(null, fruit)
	TEST_ASSERT(fruit.reagents.flags & NO_REACT, "Prepared fruit can react")
	fruit.reagents.add_reagent(/datum/reagent/hydrogen, 30)
	fruit.reagents.add_reagent(/datum/reagent/nitrogen, 10)
	TEST_ASSERT(!fruit.reagents.has_reagent(/datum/reagent/ammonia), "Separated contents reacted before activation")

	trait.async_catch_activate(fruit) // sleeps a few seconds, like in game
	TEST_ASSERT(fruit.reagents.get_reagent_amount(/datum/reagent/ammonia) >= 29, "Mixed contents did not react at once ([fruit.reagents.get_reagent_amount(/datum/reagent/ammonia)]u of ammonia)")
	TEST_ASSERT(!(fruit.reagents.flags & REAGENT_HOLDER_INSTANT_REACT), "The fruit kept instant reactions after mixing")
	TEST_ASSERT(!(fruit.reagents.flags & NO_REACT), "The fruit still cannot react after mixing")

/// Greed: the cursed bottle restores up to the standard 100 max health, never above it
/datum/unit_test/aquila_greed_bottle

/datum/unit_test/aquila_greed_bottle/Run()
	var/list/cases = list("50" = 70, "90" = 100, "100" = 100, "120" = 120)
	for(var/start_text in cases)
		var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human)
		drinker.maxHealth = text2num(start_text)
		var/obj/item/greedcursed_bottle/bottle = allocate(/obj/item/greedcursed_bottle)
		bottle.attack_self(drinker)
		TEST_ASSERT_EQUAL(drinker.maxHealth, cases[start_text], "The bottle took max health from [start_text] to the wrong value")
		TEST_ASSERT(QDELETED(bottle), "The bottle was not used up")

/// Vampires: clans starting at the Masquerade threshold (Tremere, caitiff) get Masquerade
/datum/unit_test/aquila_vampire_clan_masquerade

/datum/unit_test/aquila_vampire_clan_masquerade/Run()
	for(var/clan_type in list(/datum/vampire_clan/tremere, /datum/vampire_clan))
		var/mob/living/carbon/human/vampire_mob = allocate(/mob/living/carbon/human)
		vampire_mob.mind_initialize()
		var/datum/antagonist/vampire/vampire = new
		vampire.silent = TRUE
		vampire_mob.mind.add_antag_datum(vampire)
		for(var/datum/action/vampire/masquerade/power in vampire.powers)
			vampire.remove_power(power)
			qdel(power)
		vampire.my_clan = new clan_type(vampire)
		vampire.my_clan.on_apply()
		TEST_ASSERT(vampire.humanity >= VAMPIRE_HUMANITY_MASQUERADE_POWER, "[clan_type] starts below the Masquerade threshold ([vampire.humanity])")
		TEST_ASSERT(locate(/datum/action/vampire/masquerade) in vampire.powers, "[clan_type] did not get Masquerade at [vampire.humanity] humanity")

/// Hacking: cut wires do what their name says (autolathe shock, AI control of the air alarm and the cycling airlock controller)
/datum/unit_test/aquila_hacking_wires

/datum/unit_test/aquila_hacking_wires/Run()
	var/obj/machinery/modular_fabricator/autolathe/lathe = allocate(/obj/machinery/modular_fabricator/autolathe)
	TEST_ASSERT(!lathe.shocked, "A new autolathe is electrified")
	lathe.wires.cut(WIRE_SHOCK)
	TEST_ASSERT(lathe.shocked, "Cutting WIRE_SHOCK did not electrify the autolathe")
	lathe.wires.cut(WIRE_SHOCK)
	TEST_ASSERT(!lathe.shocked, "Mending WIRE_SHOCK did not stop the autolathe shocking")

	var/list/ai_machines = list(/obj/machinery/airalarm, /obj/machinery/advanced_airlock_controller)
	for(var/machine_type in ai_machines)
		var/obj/machinery/machine = allocate(machine_type)
		var/datum/wires/wires = machine.wires
		TEST_ASSERT(!machine.vars["aidisabled"], "New [machine_type] has AI control disabled")
		wires.cut(WIRE_AI)
		TEST_ASSERT(machine.vars["aidisabled"], "Cutting WIRE_AI did not block AI control of [machine_type]")
		wires.cut(WIRE_AI)
		TEST_ASSERT(!machine.vars["aidisabled"], "Mending WIRE_AI did not restore AI control of [machine_type]")

/// NTSL: min() i max() z tekstem jako pierwszym argumentem porównują tylko liczby
/datum/unit_test/aquila_ntsl_min_max_text

/datum/unit_test/aquila_ntsl_min_max_text/Run()
	var/datum/n_function/default/max/max_func = new
	var/datum/n_function/default/min/min_func = new
	allocated += max_func
	allocated += min_func
	TEST_ASSERT_EQUAL(max_func.execute(null, list("tekst", 3, 7)), 7, "max() z tekstem na początku")
	TEST_ASSERT_EQUAL(min_func.execute(null, list("tekst", 3, 7)), 3, "min() z tekstem na początku")
	TEST_ASSERT_EQUAL(max_func.execute(null, list("a", "b")), "a", "max() bez liczb zwraca pierwszy argument")
	TEST_ASSERT_EQUAL(min_func.execute(null, list(5)), 5, "min() z jedną liczbą")

/// Maszyna plumbingu zbudowana na przykręconej ramie od razu się przetwarza, a nieprzykręcona nie
/datum/unit_test/aquila_plumbing_construction_processing

/datum/unit_test/aquila_plumbing_construction_processing/Run()
	var/obj/machinery/plumbing/input/anchored_one = allocate(/obj/machinery/plumbing/input)
	TEST_ASSERT(!(anchored_one.datum_flags & DF_ISPROCESSING), "maszyna spoza mapy nie powinna przetwarzać się przed budową")
	anchored_one.setAnchored(TRUE)
	anchored_one.on_construction()
	TEST_ASSERT(anchored_one.datum_flags & DF_ISPROCESSING, "przykręcona maszyna po on_construction() nie przetwarza się")

	var/obj/machinery/plumbing/input/loose_one = allocate(/obj/machinery/plumbing/input)
	loose_one.on_construction()
	TEST_ASSERT(!(loose_one.datum_flags & DF_ISPROCESSING), "nieprzykręcona maszyna nie powinna przetwarzać się po on_construction()")

/// Samobójstwo pustym ostrzem duszy zamyka duszę w ostrzu jako cień, a rytuał „Ostrze duszy” czeka na własny klucz
/datum/unit_test/aquila_soulblade_suicide

/datum/unit_test/aquila_soulblade_suicide/Run()
	var/datum/bloodcult_ritual/suicide_soulblade/ritual = new
	TEST_ASSERT(("suicide_soulblade" in ritual.keys) && !("suicide_tome" in ritual.keys), "rytuał Ostrze duszy nie czeka na klucz suicide_soulblade")
	qdel(ritual)
	TEST_ASSERT(/datum/bloodcult_ritual/suicide_soulblade in GLOB.bloodcult_personal_rituals, "rytuał Ostrze duszy nie jest w puli")

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.mind_initialize()
	var/datum/mind/victim_mind = victim.mind
	// cień w ostrzu dostaje tylko kultysta (osoba spoza kultu: test aquila_audyt_antagi_bloodcult)
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.ignore_implant = TRUE
	TEST_ASSERT(victim_mind.add_antag_datum(new_cultist), "nie udało się zrobić kultysty")
	var/obj/item/melee/soulblade/blade = allocate(/obj/item/melee/soulblade)
	victim.put_in_active_hand(blade)
	var/result = blade.suicide_act(victim)
	TEST_ASSERT(result & MANUAL_SUICIDE, "suicide_act ostrza nie przejmuje zabicia")
	TEST_ASSERT(blade.shade, "w ostrzu nie ma cienia")
	TEST_ASSERT(blade.shade.loc == blade, "cień nie siedzi w ostrzu")
	TEST_ASSERT(blade.shade.mind == victim_mind, "cień nie dostał umysłu samobójcy")
	allocated += blade.shade
	TEST_ASSERT(victim.stat == DEAD, "ciało samobójcy żyje")
	victim_mind.remove_antag_datum(/datum/antagonist/cult)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
