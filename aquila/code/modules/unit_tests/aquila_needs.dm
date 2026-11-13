// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b]. [message]") }

/// AQUILA - progi nawodnienia i najedzenia, cukier, kofeina, sól, urozmaicenie (aquila/code/modules/needs/)
/datum/unit_test/aquila_needs

/datum/unit_test/aquila_needs/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human)
	eater.set_nutrition(NUTRITION_LEVEL_FED + 10)

	// Nawodnienie: premia przy dobrym, kara przy alercie pragnienia
	eater.set_hydration(HYDRATION_LEVEL_HYDRATED + 50)
	TEST_ASSERT_EQUAL(eater.aq_hydration_effects(), 1.1, "Being well hydrated gives no stamina bonus")
	eater.set_hydration(HYDRATION_LEVEL_THIRSTY)
	TEST_ASSERT_EQUAL(eater.aq_hydration_effects(), 1, "Normal hydration changes stamina")
	eater.set_hydration(HYDRATION_LEVEL_DEHYDRATED - 10)
	TEST_ASSERT_EQUAL(eater.aq_hydration_effects(), 0.85, "Dehydration does not slow stamina regeneration")
	eater.set_hydration(HYDRATION_LEVEL_PARCHED - 10)
	TEST_ASSERT_EQUAL(eater.aq_hydration_effects(), 0.7, "Being parched does not slow stamina regeneration more")
	eater.aq_handle_needs()
	TEST_ASSERT_EQUAL(LAZYACCESS(eater.stamina.regen_multipliers, "aq_needs"), 0.7, "The needs multiplier did not reach the stamina pool")

	var/datum/component/mood/mood = eater.GetComponent(/datum/component/mood)
	TEST_ASSERT(mood, "A human has no mood component")
	mood.HandleNutrition(eater)
	TEST_ASSERT(istype(mood.mood_events["aq_hydration"], /datum/mood_event/aq_parched), "Being parched gives no moodlet")
	eater.set_hydration(HYDRATION_LEVEL_HYDRATED + 50)
	mood.HandleNutrition(eater)
	TEST_ASSERT(istype(mood.mood_events["aq_hydration"], /datum/mood_event/aq_hydrated), "Being well hydrated gives no moodlet")
	eater.aq_handle_needs()
	TEST_ASSERT_EQUAL(LAZYACCESS(eater.stamina.regen_multipliers, "aq_needs"), 1.1, "The hydration bonus did not reach the stamina pool")

	// Sól zatrzymuje wodę
	eater.set_hydration(400)
	eater.aq_salt_until = world.time + 1 MINUTES
	eater.aq_hydration_effects()
	TEST_ASSERT(eater.hydration > 400, "Salt does not keep water in the body")
	eater.aq_salt_until = 0

	// Wygłodzenie: drżą ręce (rozrzut broni i wolniejsze czynności), bez obrażeń
	var/spread_fed = eater.get_move_spread_penalty()
	eater.set_nutrition(NUTRITION_LEVEL_STARVING - 10)
	eater.aq_handle_needs()
	TEST_ASSERT(eater.aq_starving_tremor, "Starving does not make the hands shake")
	TEST_ASSERT(eater.get_move_spread_penalty() > spread_fed, "Shaking hands do not add weapon spread")
	TEST_ASSERT(eater.cached_multiplicative_actions_slowdown > 1, "Shaking hands do not slow actions down")
	eater.set_nutrition(NUTRITION_LEVEL_FED + 10)
	eater.aq_handle_needs()
	TEST_ASSERT(!eater.aq_starving_tremor, "The tremor stays after eating")
	TEST_ASSERT_EQUAL(eater.cached_multiplicative_actions_slowdown, 1, "Actions stay slow after eating")

	// Przejedzenie: senność po obiedzie tylko przy przejściu progu
	eater.set_nutrition(NUTRITION_LEVEL_FULL + 10)
	eater.aq_handle_needs()
	TEST_ASSERT(eater.aq_food_coma_until > world.time, "Overeating gives no food coma")
	// Regresja: podjadanie na granicy przejedzenia nie odnawia senności co kęs
	eater.set_nutrition(NUTRITION_LEVEL_FULL - 10)
	eater.aq_handle_needs()
	var/coma_until = eater.aq_food_coma_until
	eater.set_nutrition(NUTRITION_LEVEL_FULL + 10)
	eater.aq_handle_needs()
	TEST_ASSERT_EQUAL(eater.aq_food_coma_until, coma_until, "Snacking at the overeating threshold renews the food coma every bite")
	eater.set_nutrition(NUTRITION_LEVEL_FED + 10)
	eater.aq_handle_needs()
	eater.aq_food_coma_until = 0
	eater.aq_next_food_coma = 0

	// Cukier: zastrzyk, potem spadek
	eater.aq_sugar_load = 5
	TEST_ASSERT_EQUAL(eater.aq_food_buff_effects(), 1.25, "Sugar gives no rush")
	eater.aq_sugar_rush_until = world.time - 1
	TEST_ASSERT_EQUAL(eater.aq_food_buff_effects(), 0.9, "The sugar rush does not end with a crash")
	// Regresja: cukier pity dalej w trakcie zastrzyku nie przeskakuje spadku
	eater.aq_sugar_load = 10
	TEST_ASSERT_EQUAL(eater.aq_food_buff_effects(), 0.9, "More sugar skips the crash and starts a new rush")
	eater.aq_sugar_crash_until = world.time - 1
	TEST_ASSERT_EQUAL(eater.aq_food_buff_effects(), 1.25, "Sugar after the crash gives no new rush")
	eater.aq_sugar_load = 0
	eater.aq_sugar_rush_until = 0
	eater.aq_sugar_crash_until = 0

	// Kawa: kofeina we krwi
	eater.reagents.add_reagent(/datum/reagent/consumable/coffee, 5)
	var/datum/reagent/consumable/coffee/coffee = eater.reagents.has_reagent(/datum/reagent/consumable/coffee)
	coffee.on_mob_life(eater)
	TEST_ASSERT(eater.aq_caffeine_until > world.time, "Coffee gives no caffeine")
	TEST_ASSERT(eater.aq_food_buff_effects() > 1, "Caffeine does not speed stamina up")
	eater.reagents.clear_reagents()
	eater.aq_caffeine_until = 0

	// Urozmaicenie: cztery różne grupy w krótkim czasie
	TEST_ASSERT(!eater.aq_note_food_variety(MEAT), "One food group already counts as a varied diet")
	eater.aq_note_food_variety(VEGETABLES)
	TEST_ASSERT(!eater.aq_note_food_variety(FRUIT), "Three food groups already count as a varied diet")
	TEST_ASSERT(eater.aq_note_food_variety(GRAIN | DAIRY), "Five food groups do not count as a varied diet")
	TEST_ASSERT(istype(mood.mood_events["aq_variety"], /datum/mood_event/aq_varied_diet), "A varied diet gives no moodlet")

	// Przyprawa wylana na gotowe danie podnosi jakość
	var/obj/item/food/grown/apple/apple = allocate(/obj/item/food/grown/apple)
	var/datum/component/edible/edible = apple.GetComponent(/datum/component/edible)
	var/quality_before = edible.get_perceived_food_quality(eater)
	var/obj/item/reagent_containers/food/condiment/saltshaker/salt = allocate(/obj/item/reagent_containers/food/condiment/saltshaker)
	salt.afterattack(apple, eater, TRUE)
	TEST_ASSERT(HAS_TRAIT(apple, TRAIT_AQ_SEASONED), "Salting a dish does not mark it as seasoned")
	TEST_ASSERT_EQUAL(edible.get_perceived_food_quality(eater), quality_before + 1, "A seasoned dish is not tastier")

/// AQUILA - wrzody żołądka: kwas od śmieciowego jedzenia, stadia, ból, analizator, leczenie
/datum/unit_test/aquila_stomach_ulcer

/datum/unit_test/aquila_stomach_ulcer/Run()
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human)
	var/obj/item/organ/stomach/belly = eater.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT(belly?.aq_can_ulcer(), "A human stomach cannot get ulcers")

	// Jedzenie z automatu: znacznik i kwas po kęsie, nawet gdy samo jedzenie nie jest śmieciowe
	var/obj/machinery/vending/snack/vendor = allocate(/obj/machinery/vending/snack)
	var/obj/item/food/grown/apple/apple = allocate(/obj/item/food/grown/apple)
	SEND_SIGNAL(vendor, COMSIG_VENDING_DISPENSED, apple)
	TEST_ASSERT(HAS_TRAIT(apple, TRAIT_AQ_VENDED), "A vended item is not marked")
	var/datum/component/edible/edible = apple.GetComponent(/datum/component/edible)
	edible.TakeBite(eater, eater)
	TEST_ASSERT(belly.aq_acid > 0, "Food from a vending machine adds no stomach acid")

	// Chipsy podnoszą kwas, sałatka go zbija
	belly.aq_acid = 0
	var/obj/item/food/chips/chips = allocate(/obj/item/food/chips)
	var/datum/component/edible/chips_edible = chips.GetComponent(/datum/component/edible)
	chips_edible.TakeBite(eater, eater)
	var/acid_after_chips = belly.aq_acid
	TEST_ASSERT(acid_after_chips > 0, "Junk food adds no stomach acid")
	eater.aq_stomach_bite(FALSE, VEGETABLES, 1)
	TEST_ASSERT(belly.aq_acid < acid_after_chips, "Vegetables do not lower stomach acid")

	// Długo wysoki kwas robi wrzód
	belly.aq_acid = 100
	for(var/i in 1 to 200)
		belly.aq_ulcer_tick(eater)
	TEST_ASSERT(belly.aq_ulcer_stage() >= 1, "High acid for a long time makes no ulcer ([belly.aq_ulcer])")

	// Krwawiący wrzód: uszkodzenie żołądka z sufitem, ból, analizator
	belly.aq_ulcer = AQ_ULCER_STAGE_3 + 5
	belly.setOrganDamage(0)
	for(var/i in 1 to 100)
		belly.aq_ulcer_tick(eater)
	TEST_ASSERT(belly.damage > belly.low_threshold, "A bleeding ulcer does not damage the stomach")
	TEST_ASSERT(belly.damage < belly.high_threshold, "A bleeding ulcer damages the stomach past its cap")
	TEST_ASSERT(belly.aq_ulcer_pain() > 0, "An ulcer does not hurt")
	var/found_scan = FALSE
	for(var/line in eater.get_wound_scan_lines())
		if(findtext(line, "stadium 3"))
			found_scan = TRUE
	TEST_ASSERT(found_scan, "The health analyzer does not show a bleeding ulcer")

	// Gastrektomia jest dostępna przy krwawiącym wrzodzie i go usuwa bez podnoszenia uszkodzenia
	var/datum/surgery_operation/organ/repair/gastrectomy/operation = new
	TEST_ASSERT(operation.state_check(belly), "Gastrectomy is not available for a bleeding ulcer")
	var/damage_before = belly.damage
	operation.on_success(belly, eater, null, list())
	TEST_ASSERT_EQUAL(belly.aq_ulcer, 0, "Gastrectomy does not remove the ulcer")
	TEST_ASSERT(belly.damage <= damage_before, "Gastrectomy for an ulcer raised the stomach damage")
	qdel(operation)

	// Omeprazol zbija kwas i goi wrzód
	belly.aq_ulcer = AQ_ULCER_STAGE_2 + 5
	belly.aq_acid = 60
	eater.reagents.add_reagent(/datum/reagent/medicine/aq_omeprazole, 10)
	var/ulcer_before = belly.aq_ulcer
	for(var/i in 1 to 20)
		belly.aq_ulcer_tick(eater)
	TEST_ASSERT(belly.aq_acid < AQ_ULCER_STAGE_1, "Omeprazole does not lower stomach acid")
	TEST_ASSERT(belly.aq_ulcer < ulcer_before, "Omeprazole does not heal the ulcer")
	eater.reagents.clear_reagents()

	// Mleko osłania żołądek
	belly.aq_acid = 50
	eater.reagents.add_reagent(/datum/reagent/consumable/milk, 5)
	var/datum/reagent/consumable/milk/milk = eater.reagents.has_reagent(/datum/reagent/consumable/milk)
	milk.on_mob_life(eater)
	TEST_ASSERT(belly.aq_acid < 50, "Milk does not lower stomach acid")
	TEST_ASSERT(belly.aq_soothed_until > world.time, "Milk does not soothe the stomach")
	eater.reagents.clear_reagents()

	// Regresja: w stazie krwawiący wrzód nie postępuje i nie upuszcza krwi
	belly.aq_ulcer = AQ_ULCER_STAGE_3 + 5
	belly.aq_acid = 90
	eater.blood_volume = BLOOD_VOLUME_NORMAL
	eater.SetStasis(TRUE)
	for(var/i in 1 to 50)
		eater.aq_handle_needs()
	TEST_ASSERT_EQUAL(belly.aq_ulcer, AQ_ULCER_STAGE_3 + 5, "An ulcer progresses in stasis")
	TEST_ASSERT_EQUAL(eater.blood_volume, BLOOD_VOLUME_NORMAL, "A bleeding ulcer drains blood in stasis")
	eater.SetStasis(FALSE)

	// Regresja: syntetyczny tors nie czuje bólu wrzodu, jak w bazie
	var/obj/item/bodypart/chest/chest = eater.get_bodypart(BODY_ZONE_CHEST)
	chest.change_bodypart_status(BODYTYPE_ROBOTIC)
	TEST_ASSERT_EQUAL(eater.aq_compute_pain(), 0, "A synthetic chest feels ulcer pain")

	// Regresja: białko nie odbudowuje krwi bez bijącego serca
	var/mob/living/carbon/human/heartless = allocate(/mob/living/carbon/human)
	var/obj/item/organ/heart/heart = heartless.getorganslot(ORGAN_SLOT_HEART)
	heart.Remove(heartless)
	qdel(heart)
	heartless.blood_volume = BLOOD_VOLUME_SAFE
	heartless.aq_protein_blood_regen()
	TEST_ASSERT_EQUAL(heartless.blood_volume, BLOOD_VOLUME_SAFE, "Protein restores blood without a heart")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
