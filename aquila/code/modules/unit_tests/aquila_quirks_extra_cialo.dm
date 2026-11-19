// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Cechy z grupy „ciało” (aquila/code/datums/traits/extra/cialo.dm): każda daje się dodać i usunąć i robi to, co zapowiada
/datum/unit_test/aquila_quirks_extra_cialo

/datum/unit_test/aquila_quirks_extra_cialo/Run()
	var/list/quirk_types = list(
		/datum/quirk/allergic, /datum/quirk/narcolepsy, /datum/quirk/glass_jaw, /datum/quirk/asthma,
		/datum/quirk/hemophilia, /datum/quirk/hemiplegic, /datum/quirk/food_allergic, /datum/quirk/numb,
		/datum/quirk/prosthetic_organ, /datum/quirk/quadruple_amputee, /datum/quirk/tin_man, /datum/quirk/chronic_illness,
		/datum/quirk/immunodeficiency, /datum/quirk/strong_stomach, /datum/quirk/limper, /datum/quirk/hardened_soles,
		/datum/quirk/hungry, /datum/quirk/death_mimicry,
	)
	// Każda cecha jest w oknie postaci, dodaje się z efektami startowymi i usuwa bez błędów
	for(var/quirk_type in quirk_types)
		var/datum/quirk/quirk_path = quirk_type
		TEST_ASSERT_EQUAL(SSquirks.quirks[initial(quirk_path.name)], quirk_type, "Quirk [quirk_type] is not registered under its name")
		TEST_ASSERT(initial(quirk_path.icon), "Quirk [quirk_type] has no icon")
		var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
		TEST_ASSERT(H.add_quirk(quirk_type, TRUE), "Quirk [quirk_type] could not be added")
		TEST_ASSERT(H.has_quirk(quirk_type), "Quirk [quirk_type] is missing after adding it")
		TEST_ASSERT(H.remove_quirk(quirk_type), "Quirk [quirk_type] could not be removed")
		TEST_ASSERT(!H.has_quirk(quirk_type), "Quirk [quirk_type] is still there after removing it")

	// Alergia na leki: alergen daje histaminę i toksyny, epinefryna wstrzymuje reakcję
	var/mob/living/carbon/human/allergic = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	allergic.add_quirk(/datum/quirk/allergic)
	var/datum/quirk/allergic/allergy = locate() in allergic.roundstart_quirks
	TEST_ASSERT(length(allergy.allergies), "Medicine allergy picked no allergens")
	var/allergen = allergy.allergies[1]
	allergic.reagents.add_reagent(allergen, 5)
	allergy.on_process(1)
	TEST_ASSERT(allergic.reagents.has_reagent(/datum/reagent/toxin/histamine), "An allergen gave no histamine")
	allergic.reagents.clear_reagents()
	allergic.reagents.add_reagent(allergen, 5)
	allergic.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	allergy.on_process(1)
	TEST_ASSERT(!allergic.reagents.has_reagent(/datum/reagent/toxin/histamine), "Epinephrine did not stop the allergic reaction")

	// Narkolepsja: trwały uraz mózgu, znika z cechą
	var/mob/living/carbon/human/sleepy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	sleepy.add_quirk(/datum/quirk/narcolepsy)
	TEST_ASSERT(sleepy.has_trauma_type(/datum/brain_trauma/severe/narcolepsy/aq_permanent, TRAUMA_RESILIENCE_ABSOLUTE), "Narcolepsy gave no trauma")
	sleepy.remove_quirk(/datum/quirk/narcolepsy)
	TEST_ASSERT(!sleepy.has_trauma_type(/datum/brain_trauma/severe/narcolepsy/aq_permanent, TRAUMA_RESILIENCE_ABSOLUTE), "Narcolepsy trauma stayed after removing the quirk")

	// Szklana szczęka: mocny cios w głowę nokautuje, w nogę nie
	var/mob/living/carbon/human/boxer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	boxer.add_quirk(/datum/quirk/glass_jaw)
	boxer.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	TEST_ASSERT(!boxer.IsUnconscious(), "A kick to the leg knocked out a glass jaw")
	boxer.apply_damage(100, BRUTE, BODY_ZONE_HEAD)
	TEST_ASSERT(boxer.IsUnconscious(), "A 100 damage blow to the head did not knock out a glass jaw")

	// Hemofilia: więcej utraconej krwi i wolniejsze krzepnięcie
	var/mob/living/carbon/human/bleeder = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	bleeder.add_quirk(/datum/quirk/hemophilia)
	TEST_ASSERT_EQUAL(bleeder.physiology.bleed_mod, 1.5, "Hemophilia does not raise the blood loss")
	bleeder.add_bleeding(BLEED_SURFACE, BODY_ZONE_CHEST)
	var/datum/status_effect/bleeding/bleed = bleeder.get_bleed_status()
	TEST_ASSERT(bleed, "The hemophiliac did not start bleeding")
	bleed.tick()
	TEST_ASSERT(bleed.bleed_heal_multiplier < initial(bleed.bleed_heal_multiplier), "Hemophilia does not slow the clotting")
	bleeder.remove_quirk(/datum/quirk/hemophilia)
	TEST_ASSERT_EQUAL(bleeder.physiology.bleed_mod, 1, "The blood loss stayed raised after removing hemophilia")

	// Porażenie połowicze: sparaliżowana dokładnie jedna strona ciała
	var/mob/living/carbon/human/half = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	half.add_quirk(/datum/quirk/hemiplegic)
	var/left = HAS_TRAIT(half, TRAIT_PARALYSIS_L_ARM) && HAS_TRAIT(half, TRAIT_PARALYSIS_L_LEG)
	var/right = HAS_TRAIT(half, TRAIT_PARALYSIS_R_ARM) && HAS_TRAIT(half, TRAIT_PARALYSIS_R_LEG)
	TEST_ASSERT(left != right, "Hemiplegia did not paralyse exactly one side")
	half.remove_quirk(/datum/quirk/hemiplegic)
	TEST_ASSERT(!HAS_TRAIT(half, TRAIT_PARALYSIS_L_ARM) && !HAS_TRAIT(half, TRAIT_PARALYSIS_R_ARM), "Paralysis stayed after removing hemiplegia")

	// Alergia pokarmowa: tylko alergen daje histaminę
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	eater.add_quirk(/datum/quirk/food_allergic)
	var/datum/quirk/food_allergic/food_allergy = locate() in eater.roundstart_quirks
	TEST_ASSERT(food_allergy.target_foodtypes, "Food allergy picked no allergen")
	SEND_SIGNAL(eater, COMSIG_LIVING_EAT_FOOD, null, TOXIC)
	TEST_ASSERT(!eater.reagents.has_reagent(/datum/reagent/toxin/histamine), "Food without the allergen caused a reaction")
	SEND_SIGNAL(eater, COMSIG_LIVING_EAT_FOOD, null, food_allergy.target_foodtypes)
	TEST_ASSERT(eater.reagents.has_reagent(/datum/reagent/toxin/histamine), "Eating the allergen caused no reaction")

	// Nieczuły na ból: rany nie bolą
	var/mob/living/carbon/human/numb = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	numb.adjustBruteLoss(40)
	TEST_ASSERT(numb.aq_compute_pain() > 0, "Wounds do not hurt without the quirk, the check proves nothing")
	numb.add_quirk(/datum/quirk/numb)
	TEST_ASSERT_EQUAL(numb.aq_compute_pain(), 0, "A numb character still feels pain")

	// Protetyczny organ, Blaszany drwal, Poczwórna amputacja: tanie protezy na starcie
	var/mob/living/carbon/human/one_organ = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	one_organ.add_quirk(/datum/quirk/prosthetic_organ, TRUE)
	var/surplus_organs = 0
	for(var/slot in GLOB.aq_surplus_organs)
		if(istype(one_organ.getorganslot(slot), GLOB.aq_surplus_organs[slot]))
			surplus_organs++
	TEST_ASSERT_EQUAL(surplus_organs, 1, "Prosthetic organ did not replace exactly one organ")

	var/mob/living/carbon/human/tin = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	tin.add_quirk(/datum/quirk/tin_man, TRUE)
	for(var/slot in GLOB.aq_surplus_organs)
		TEST_ASSERT(istype(tin.getorganslot(slot), GLOB.aq_surplus_organs[slot]), "Tin Man did not replace the [slot]")

	var/mob/living/carbon/human/amputee = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	amputee.add_quirk(/datum/quirk/quadruple_amputee, TRUE)
	TEST_ASSERT(istype(amputee.get_bodypart(BODY_ZONE_L_ARM), /obj/item/bodypart/l_arm/robot/surplus), "Quadruple amputee kept the left arm")
	TEST_ASSERT(istype(amputee.get_bodypart(BODY_ZONE_R_ARM), /obj/item/bodypart/r_arm/robot/surplus), "Quadruple amputee kept the right arm")
	TEST_ASSERT(istype(amputee.get_bodypart(BODY_ZONE_L_LEG), /obj/item/bodypart/l_leg/robot/surplus), "Quadruple amputee kept the left leg")
	TEST_ASSERT(istype(amputee.get_bodypart(BODY_ZONE_R_LEG), /obj/item/bodypart/r_leg/robot/surplus), "Quadruple amputee kept the right leg")

	// Choroba przewlekła: choroba na start, sansufentanyl cofa stadium, usunięcie cechy leczy
	var/mob/living/carbon/human/chronic = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	chronic.add_quirk(/datum/quirk/chronic_illness)
	var/datum/disease/aq_chronic_illness/illness = locate() in chronic.diseases
	TEST_ASSERT(illness, "Chronic illness gave no disease")
	illness.cure_chance = 100
	illness.update_stage(3)
	chronic.reagents.add_reagent(/datum/reagent/medicine/sansufentanyl, 5)
	illness.stage_act()
	TEST_ASSERT_EQUAL(illness.stage, 2, "Sansufentanyl did not push the illness back")
	chronic.remove_quirk(/datum/quirk/chronic_illness)
	TEST_ASSERT(!(locate(/datum/disease/aq_chronic_illness) in chronic.diseases), "The illness stayed after removing the quirk")

	// Niedobór odporności: choroby rozwijają się szybciej
	var/mob/living/carbon/human/sickly = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	sickly.add_quirk(/datum/quirk/immunodeficiency)
	TEST_ASSERT(HAS_TRAIT(sickly, TRAIT_IMMUNODEFICIENCY), "Immunodeficiency gave no trait")
	var/datum/disease/cold/cold = new
	sickly.ForceContractDisease(cold, FALSE, TRUE)
	var/datum/disease/cold/sick_cold = locate() in sickly.diseases
	TEST_ASSERT(sick_cold, "The immunodeficient character could not catch a cold")
	sick_cold.stage_prob = 100
	sick_cold.stage_act()
	TEST_ASSERT_EQUAL(sick_cold.stage, 3, "A disease did not advance twice as fast with immunodeficiency")

	// Mocny żołądek: wymioty zabierają połowę jedzenia
	var/mob/living/carbon/human/glutton = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	glutton.add_quirk(/datum/quirk/strong_stomach)
	glutton.set_nutrition(500)
	glutton.vomit(20)
	TEST_ASSERT_EQUAL(glutton.nutrition, 490, "A strong stomach lost the full nutrition when vomiting")

	// Kulawy: bez laski spowolniony, z laską w ręce nie
	var/mob/living/carbon/human/limper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	limper.add_quirk(/datum/quirk/limper, TRUE)
	var/datum/quirk/limper/limp = locate() in limper.roundstart_quirks
	var/obj/item/cane/cane = locate() in limper.held_items
	TEST_ASSERT(cane, "The limper did not start with a cane in hand")
	limp.on_process(1)
	TEST_ASSERT(!limper.has_movespeed_modifier("aq_limper"), "The limper limps with a cane")
	qdel(cane)
	limp.on_process(1)
	TEST_ASSERT(limper.has_movespeed_modifier("aq_limper"), "The limper does not limp without a cane")
	limper.remove_quirk(/datum/quirk/limper)
	TEST_ASSERT(!limper.has_movespeed_modifier("aq_limper"), "The limp stayed after removing the quirk")

	// Twarde stopy: boso po kolcach bez obrażeń
	var/obj/item/spikes = allocate(/obj/item/dice/d4, run_loc_floor_bottom_left)
	var/datum/component/caltrop/caltrop = spikes.GetComponent(/datum/component/caltrop)
	if(!caltrop)
		caltrop = spikes.AddComponent(/datum/component/caltrop, 5, 5, 100)
	caltrop.probability = 100
	caltrop.min_damage = 5
	caltrop.max_damage = 5
	var/mob/living/carbon/human/barefoot = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	caltrop.on_entered(get_turf(spikes), barefoot)
	TEST_ASSERT(barefoot.getBruteLoss() > 0, "Spikes did not hurt bare feet, the check proves nothing")
	var/mob/living/carbon/human/hard_feet = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	hard_feet.add_quirk(/datum/quirk/hardened_soles)
	caltrop.on_entered(get_turf(spikes), hard_feet)
	TEST_ASSERT_EQUAL(hard_feet.getBruteLoss(), 0, "Spikes hurt hardened soles")

	// Wiecznie głodny: mnożnik fizjologii wraca po usunięciu
	var/mob/living/carbon/human/hungry = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	hungry.add_quirk(/datum/quirk/hungry)
	TEST_ASSERT_EQUAL(hungry.physiology.hunger_mod, 2, "Hungry does not double the hunger")
	hungry.remove_quirk(/datum/quirk/hungry)
	TEST_ASSERT_EQUAL(hungry.physiology.hunger_mod, 1, "The hunger stayed doubled after removing the quirk")

	// Udawanie śmierci: deathgasp usypia i udaje śmierć
	var/mob/living/carbon/human/actor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	actor.add_quirk(/datum/quirk/death_mimicry)
	actor.emote("deathgasp", intentional = TRUE)
	TEST_ASSERT(HAS_TRAIT(actor, TRAIT_FAKEDEATH), "Death mimicry did not fake death")
	TEST_ASSERT(actor.IsUnconscious(), "Death mimicry did not knock the actor out")
	TEST_ASSERT(actor.stat != DEAD, "Death mimicry killed the actor")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
