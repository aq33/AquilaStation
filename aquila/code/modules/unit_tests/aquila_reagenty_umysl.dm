// AQUILA - testy reagentów z grupy umysl (raport/reagenty_02_plan_portu.md).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Amnestics wipe memory when they leave the blood, locutogen replays the phrase its container heard, solipsizine hides people and deafens
/datum/unit_test/aquila_reagenty_umysl_mind

/datum/unit_test/aquila_reagenty_umysl_mind/Run()
	// Amnestyki: po wypłukaniu senność i zawroty
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.reagents.add_reagent(/datum/reagent/aq_amnestics, 10)
	var/datum/reagent/aq_amnestics/amnestics = victim.reagents.get_reagent(/datum/reagent/aq_amnestics)
	for(var/i in 1 to 3)
		amnestics.on_mob_life(victim)
	TEST_ASSERT(amnestics.aq_dose > 0, "Amnestics count no absorbed dose")
	victim.drowsyness = 0
	victim.reagents.del_reagent(/datum/reagent/aq_amnestics)
	TEST_ASSERT(victim.drowsyness >= 10, "Amnestics leaving the blood gave no drowsiness ([victim.drowsyness])")

	// Lokutogen: pojemnik zapisuje pierwsze zdanie, pijący słyszy je i reagent znika
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	beaker.reagents.add_reagent(/datum/reagent/aq_locutogen, 10, list("phrase" = null))
	var/datum/reagent/aq_locutogen/locutogen = beaker.reagents.get_reagent(/datum/reagent/aq_locutogen)
	TEST_ASSERT(locutogen.aq_ear == beaker, "Locutogen in a beaker does not listen")
	beaker.Hear("Ala ma kota", speaker, null, "Ala ma kota", null, list(), list())
	beaker.Hear("Drugie zdanie", speaker, null, "Drugie zdanie", null, list(), list())
	TEST_ASSERT(locutogen.data["phrase"] == "Ala ma kota", "Locutogen stored [locutogen.data["phrase"]] instead of the first phrase")
	TEST_ASSERT(!locutogen.aq_ear, "Locutogen keeps listening after storing a phrase")
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human)
	beaker.reagents.trans_to(listener, 10)
	var/datum/reagent/aq_locutogen/drunk = listener.reagents.get_reagent(/datum/reagent/aq_locutogen)
	TEST_ASSERT(drunk && drunk.data["phrase"] == "Ala ma kota", "The phrase did not travel with the locutogen into the drinker")
	drunk.on_mob_life(listener)
	TEST_ASSERT(!listener.reagents.has_reagent(/datum/reagent/aq_locutogen), "Locutogen stayed in the blood after replaying the phrase")

	// Lokutogen z prawdziwej syntezy rozłożonej w czasie: produkt pierwszego kroku nasłuchuje, zanim przyjdzie następny krok
	var/obj/item/reagent_containers/glass/beaker/flask = allocate(/obj/item/reagent_containers/glass/beaker)
	flask.reagents.add_reagent(/datum/reagent/medicine/inacusiate, 10)
	flask.reagents.add_reagent(/datum/reagent/consumable/sugar, 10)
	flask.reagents.add_reagent(/datum/reagent/silicon, 10)
	var/datum/reagent/aq_locutogen/brewed = flask.reagents.get_reagent(/datum/reagent/aq_locutogen)
	TEST_ASSERT(brewed, "The first synthesis step made no locutogen")
	TEST_ASSERT(LAZYLEN(flask.reagents.reaction_list), "Locutogen synthesis finished in one step, the timed path is not checked")
	TEST_ASSERT(brewed.aq_ear == flask, "Locutogen from the first synthesis step does not listen in its flask")
	flask.reagents.clear_reagents()

	// Solipsizyna: inni ludzie zasłonięci, głuchota, po wypłukaniu wszystko wraca
	var/mob/living/carbon/human/loner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human)
	loner.reagents.add_reagent(/datum/reagent/aq_solipsizine, 10)
	var/datum/reagent/aq_solipsizine/solipsizine = loner.reagents.get_reagent(/datum/reagent/aq_solipsizine)
	solipsizine.current_cycle = 8
	solipsizine.on_mob_life(loner)
	TEST_ASSERT(LAZYACCESS(solipsizine.aq_hidden, other), "Solipsizine did not hide a human next to the drinker")
	TEST_ASSERT(!LAZYACCESS(solipsizine.aq_hidden, loner), "Solipsizine hid the drinker from himself")
	TEST_ASSERT(HAS_TRAIT(loner, TRAIT_DEAF), "Solipsizine did not silence speech")
	loner.reagents.del_reagent(/datum/reagent/aq_solipsizine)
	TEST_ASSERT(!HAS_TRAIT_FROM(loner, TRAIT_DEAF, /datum/reagent/aq_solipsizine), "Deafness stayed after solipsizine left the blood")

/// Pain enzyme hurts without damage until a strong painkiller breaks it down; brain juice, hyperpsychotic drug, randonium, splitting poison
/datum/unit_test/aquila_reagenty_umysl_body

/datum/unit_test/aquila_reagenty_umysl_body/Run()
	// Enzym bólu
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/base_pain = patient.aq_compute_pain()
	patient.reagents.add_reagent(/datum/reagent/aq_pain_enzyme, 20)
	var/enzyme_pain = patient.aq_compute_pain()
	TEST_ASSERT(enzyme_pain >= base_pain + 80, "Pain enzyme adds too little pain ([base_pain] -> [enzyme_pain])")
	TEST_ASSERT(!patient.getBruteLoss() && !patient.getFireLoss(), "Pain enzyme caused damage")
	var/datum/reagent/aq_pain_enzyme/enzyme = patient.reagents.get_reagent(/datum/reagent/aq_pain_enzyme)
	enzyme.on_mob_life(patient)
	var/slow_left = enzyme.volume
	patient.reagents.add_reagent(/datum/reagent/medicine/morphine, 10)
	enzyme.on_mob_life(patient)
	TEST_ASSERT(slow_left - enzyme.volume >= 2, "Morphine did not break the pain enzyme down ([slow_left] -> [enzyme.volume])")

	// Sok bolących mózgów: jeden uraz mózgu na dawkę
	var/mob/living/carbon/human/thinker = allocate(/mob/living/carbon/human)
	var/got_trauma = FALSE
	for(var/i in 1 to 10)
		thinker.reagents.add_reagent(/datum/reagent/toxin/aq_brain_hurting_juice, 5)
		var/datum/reagent/toxin/aq_brain_hurting_juice/juice = thinker.reagents.get_reagent(/datum/reagent/toxin/aq_brain_hurting_juice)
		juice.on_mob_life(thinker)
		TEST_ASSERT(juice.aq_trauma_given, "Brain hurting juice did not try a trauma")
		thinker.reagents.del_reagent(/datum/reagent/toxin/aq_brain_hurting_juice)
		if(length(thinker.get_traumas()))
			got_trauma = TRUE
			break
	TEST_ASSERT(got_trauma, "Ten doses of brain hurting juice gave no brain trauma")

	// Lek hiperpsychotyczny: ciało bez umysłu nie dostaje drugiej osobowości
	var/mob/living/carbon/human/empty = allocate(/mob/living/carbon/human)
	empty.reagents.add_reagent(/datum/reagent/toxin/aq_hyperpsy, 5)
	TEST_ASSERT(!empty.has_trauma_type(/datum/brain_trauma/severe/split_personality), "A mindless body got a split personality")

	// Randonium: tylko niegroźne reagenty z listy
	var/mob/living/carbon/human/gambler = allocate(/mob/living/carbon/human)
	// bez reakcji: mleko z kawą dałyby latte, której nie ma na liście
	gambler.reagents.flags |= NO_REACT
	gambler.reagents.add_reagent(/datum/reagent/aq_randonium, 10)
	var/datum/reagent/aq_randonium/randonium = gambler.reagents.get_reagent(/datum/reagent/aq_randonium)
	for(var/i in 1 to 12)
		randonium.on_mob_life(gambler)
	var/added = 0
	for(var/datum/reagent/R as anything in gambler.reagents.reagent_list)
		if(R.type == /datum/reagent/aq_randonium)
			continue
		TEST_ASSERT(R.type in randonium.aq_harmless, "Randonium injected [R.type], which is not on the harmless list")
		added++
	TEST_ASSERT(added, "Randonium injected nothing in 12 cycles")

	// Rozłupująca trucizna: kończyny łatwiej odpadają tylko na czas działania
	var/mob/living/carbon/human/brittle = allocate(/mob/living/carbon/human)
	var/datum/reagent/toxin/aq_splitting_poison/poison = new()
	poison.on_mob_metabolize(brittle)
	TEST_ASSERT(HAS_TRAIT(brittle, TRAIT_EASYDISMEMBER), "Splitting poison did not loosen the limbs")
	poison.on_mob_end_metabolize(brittle)
	TEST_ASSERT(!HAS_TRAIT(brittle, TRAIT_EASYDISMEMBER), "Limbs stayed loose after splitting poison")
	qdel(poison)

/// Energetic nanobots charge carried cells from nutrition; SDGF grows one naked copy per player, small doses only heal
/datum/unit_test/aquila_reagenty_umysl_growth

/datum/unit_test/aquila_reagenty_umysl_growth/Run()
	// Nanoboty energetyczne
	var/mob/living/carbon/human/carrier = allocate(/mob/living/carbon/human)
	var/obj/item/stock_parts/cell/cell = allocate(/obj/item/stock_parts/cell)
	cell.charge = 0
	carrier.put_in_hands(cell)
	carrier.set_nutrition(NUTRITION_LEVEL_FED)
	carrier.reagents.add_reagent(/datum/reagent/aq_energetic_nanobots, 10)
	var/datum/reagent/aq_energetic_nanobots/nanobots = carrier.reagents.get_reagent(/datum/reagent/aq_energetic_nanobots)
	nanobots.on_mob_life(carrier)
	TEST_ASSERT(cell.charge > 0, "Energetic nanobots did not charge a cell in hand")
	TEST_ASSERT(carrier.nutrition < NUTRITION_LEVEL_FED, "Charging the cell cost no nutrition")

	// SDGF: kopia naga, z tym samym DNA i imieniem, jedna na gracza
	var/mob/living/carbon/human/original = allocate(/mob/living/carbon/human)
	original.real_name = "Jan Testowy"
	original.name = original.real_name
	original.dna.real_name = original.real_name
	GLOB.aq_sdgf_cloned -= aq_sdgf_key(original)
	var/mob/living/carbon/human/copy = aq_sdgf_grow_clone(original, null)
	TEST_ASSERT(copy, "SDGF grew no copy")
	allocated += copy
	TEST_ASSERT(copy.real_name == original.real_name, "The copy is named [copy.real_name]")
	TEST_ASSERT(copy.dna.unique_enzymes == original.dna.unique_enzymes, "The copy has different DNA")
	TEST_ASSERT(!length(copy.get_equipped_items(TRUE)) && !copy.wear_id, "The copy came with clothes or an ID")
	TEST_ASSERT(!copy.mind, "A copy without a ghost got a mind")
	TEST_ASSERT(!aq_sdgf_grow_clone(original, null), "SDGF grew a second copy of the same player")

	// Klucz limitu jest stały dla gracza: z umysłu, także gdy ciało nie ma ckey (duch wyszedł)
	var/mob/living/carbon/human/ghosted = allocate(/mob/living/carbon/human)
	ghosted.mind_initialize()
	ghosted.mind.key = "Gracz Testowy"
	TEST_ASSERT(!ghosted.ckey && aq_sdgf_key(ghosted) == ckey("Gracz Testowy"), "The SDGF limit key of a body without a client is [aq_sdgf_key(ghosted)], not the player's ckey")

	// Za mała dawka: komórki wtapiają się w ciało i leczą
	var/mob/living/carbon/human/small = allocate(/mob/living/carbon/human)
	small.adjustBruteLoss(30)
	small.reagents.add_reagent(/datum/reagent/aq_sdgf, 10)
	var/datum/reagent/aq_sdgf/sdgf = small.reagents.get_reagent(/datum/reagent/aq_sdgf)
	sdgf.on_mob_life(small)
	TEST_ASSERT(sdgf.aq_merge_only, "A small SDGF dose still tries to grow a copy")
	small.reagents.del_reagent(/datum/reagent/aq_sdgf)
	TEST_ASSERT(small.getBruteLoss() < 30, "Merging SDGF cells healed nothing")
	GLOB.aq_sdgf_cloned -= aq_sdgf_key(original)

/// Nitrogen triiodide pops when dry and touched or heated, photophosphide on a lit floor, argine below zero, punctualite on the hour
/datum/unit_test/aquila_reagenty_umysl_pyro

/datum/unit_test/aquila_reagenty_umysl_pyro/Run()
	var/turf/T = run_loc_floor_bottom_left

	// Trijodek azotu: mokry nie wybucha, suchy od kroku
	var/datum/reagent/aq_nitrogen_triiodide/ni3 = new()
	ni3.reaction_turf(T, 10)
	var/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/wet = locate() in T
	TEST_ASSERT(wet, "Spilled nitrogen triiodide left no stain")
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human)
	wet.on_entered(T, walker)
	TEST_ASSERT(!QDELETED(wet), "Wet nitrogen triiodide went off")
	wet.aq_dry_out()
	wet.on_entered(T, walker)
	TEST_ASSERT(QDELETED(wet), "Dry nitrogen triiodide did not go off under a step")
	TEST_ASSERT(walker.IsKnockdown(), "The nitrogen triiodide pop did not knock the walker down")
	walker.SetKnockdown(0)
	qdel(ni3)
	var/obj/item/reagent_containers/glass/beaker/hot = allocate(/obj/item/reagent_containers/glass/beaker)
	hot.reagents.add_reagent(/datum/reagent/aq_nitrogen_triiodide, 2)
	hot.reagents.chem_temp = 400
	hot.reagents.handle_reactions()
	TEST_ASSERT(!hot.reagents.has_reagent(/datum/reagent/aq_nitrogen_triiodide), "Heated nitrogen triiodide did not go off")

	// Fotofosfid: w ciemności leży, na świetle wybucha
	var/datum/reagent/aq_photophosphide/photo = new()
	photo.reaction_turf(T, 5)
	qdel(photo)
	var/obj/effect/decal/cleanable/chem_pile/aq_photophosphide/pile = locate() in T
	TEST_ASSERT(pile, "Spilled photophosphide left no stain")
	TEST_ASSERT(!pile.aq_check_light(0), "Photophosphide went off in the dark")
	TEST_ASSERT(pile.aq_check_light(1) && QDELETED(pile), "Photophosphide did not go off in the light")

	// Argina: w cieple spokojna, poniżej zera wybucha
	var/obj/item/reagent_containers/glass/beaker/cold = allocate(/obj/item/reagent_containers/glass/beaker)
	cold.reagents.add_reagent(/datum/reagent/aq_argine, 2)
	cold.reagents.handle_reactions()
	TEST_ASSERT(cold.reagents.has_reagent(/datum/reagent/aq_argine), "Argine went off at room temperature")
	cold.reagents.chem_temp = 250
	cold.reagents.handle_reactions()
	TEST_ASSERT(!cold.reagents.has_reagent(/datum/reagent/aq_argine), "Argine did not go off below zero")

	// Punktualit: wybucha o pełnej godzinie rundy
	var/mob/living/carbon/human/sleeper = allocate(/mob/living/carbon/human)
	sleeper.reagents.add_reagent(/datum/reagent/aq_punctualite, 2)
	var/datum/reagent/aq_punctualite/clock = sleeper.reagents.get_reagent(/datum/reagent/aq_punctualite)
	clock.on_mob_life(sleeper)
	TEST_ASSERT(sleeper.reagents.has_reagent(/datum/reagent/aq_punctualite), "Punctualite went off before the hour")
	clock.aq_hour -= 1
	clock.on_mob_life(sleeper)
	TEST_ASSERT(!sleeper.reagents.has_reagent(/datum/reagent/aq_punctualite), "Punctualite did not go off on the hour")
	TEST_ASSERT(sleeper.IsKnockdown(), "The punctualite blast did not knock the carrier down")

#undef TEST_ASSERT
