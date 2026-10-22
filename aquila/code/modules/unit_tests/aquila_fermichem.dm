// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - fermichem z tg: reakcje w czasie, czystość z pH, bufory pH, rozdzielanie nieczystych chemów w ciele
/datum/unit_test/aquila_fermichem

/datum/unit_test/aquila_fermichem/Run()
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)

	// Ammonia reacts over time (tg: /datum/chemical_reaction/ammonia, no REACTION_INSTANT)
	var/datum/chemical_reaction/ammonia_recipe = get_chemical_reaction(/datum/chemical_reaction/ammonia)
	TEST_ASSERT(ammonia_recipe && !(ammonia_recipe.reaction_flags & REACTION_INSTANT), "Amoniak nie dostał parametrów fermichemu z tg")
	beaker.reagents.add_reagent(/datum/reagent/hydrogen, 30, reagtemp = 400, no_react = TRUE)
	beaker.reagents.add_reagent(/datum/reagent/nitrogen, 10, reagtemp = 400)
	TEST_ASSERT(beaker.reagents.is_reacting, "Reakcja amoniaku nie wystartowała jako reakcja w czasie")
	TEST_ASSERT(beaker.reagents.get_reagent_amount(/datum/reagent/ammonia) < 30, "Amoniak powstał od razu, a nie w czasie")
	for(var/step in 1 to 60)
		if(!beaker.reagents.is_reacting)
			break
		beaker.reagents.process(1)
	TEST_ASSERT(!beaker.reagents.is_reacting, "Reakcja amoniaku nie skończyła się w 60 krokach")
	var/datum/reagent/ammonia = beaker.reagents.get_reagent(/datum/reagent/ammonia)
	TEST_ASSERT(ammonia && ammonia.volume >= 29, "Powstało za mało amoniaku ([ammonia?.volume])")
	TEST_ASSERT(ammonia.purity > 0.9, "Amoniak zrobiony w optymalnym pH jest nieczysty ([ammonia.purity])")
	TEST_ASSERT(beaker.reagents.chem_temp > 400, "Egzotermiczna reakcja amoniaku nie podgrzała zlewki")

	// Acidic buffer is used up and lowers the pH
	beaker.reagents.clear_reagents()
	beaker.reagents.add_reagent(/datum/reagent/water, 50)
	var/start_ph = beaker.reagents.ph
	var/obj/item/reagent_containers/glass/bottle/acidic_buffer/buffer = allocate(/obj/item/reagent_containers/glass/bottle/acidic_buffer)
	buffer.reagents.trans_to(beaker, 5)
	TEST_ASSERT(beaker.reagents.ph < start_ph - 1, "Bufor kwaśny nie obniżył pH (z [start_ph] na [beaker.reagents.ph])")
	TEST_ASSERT(!beaker.reagents.has_reagent(/datum/reagent/reaction_agent/acidic_buffer), "Bufor kwaśny trafił do zlewki zamiast się zużyć")
	TEST_ASSERT(buffer.reagents.total_volume == 25, "Bufor nie ubył z butelki ([buffer.reagents.total_volume])")

	// Purity comes from the pH: below the optimal window (1-12 for ammonia) the product comes out impure
	beaker.reagents.clear_reagents()
	beaker.reagents.add_reagent(/datum/reagent/hydrogen, 30, reagtemp = 400, no_react = TRUE, added_ph = 0.1)
	beaker.reagents.add_reagent(/datum/reagent/nitrogen, 10, reagtemp = 400, added_ph = 0.1)
	for(var/step in 1 to 60)
		if(!beaker.reagents.is_reacting)
			break
		beaker.reagents.process(1)
	var/datum/reagent/acidic_ammonia = beaker.reagents.get_reagent(/datum/reagent/ammonia)
	TEST_ASSERT(acidic_ammonia && acidic_ammonia.purity < 0.9, "Amoniak zrobiony przy pH ~0 jest czysty ([acidic_ammonia?.purity])")

	// Holders flagged for instant reactions (grenades, smoke) react right away
	var/datum/reagents/instant = new(100, REAGENT_HOLDER_INSTANT_REACT)
	instant.my_atom = beaker
	instant.add_reagent(/datum/reagent/hydrogen, 30, reagtemp = 400, no_react = TRUE)
	instant.add_reagent(/datum/reagent/nitrogen, 10, reagtemp = 400)
	TEST_ASSERT(instant.get_reagent_amount(/datum/reagent/ammonia) >= 29, "Holder z REAGENT_HOLDER_INSTANT_REACT nie zareagował od razu")
	qdel(instant)

	// A very impure reagent turns into its inverse when it enters a body
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.reagents.add_reagent(/datum/reagent/medicine/oculine, 10, added_purity = 0.1)
	TEST_ASSERT(!patient.reagents.has_reagent(/datum/reagent/medicine/oculine), "Nieczysta okulina nie odwróciła się w ciele")
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/inverse/oculine), "Z nieczystej okuliny nie powstał Oculater")
	// ...but a pure one stays as it is
	patient.reagents.add_reagent(/datum/reagent/medicine/oculine, 10)
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/oculine), "Czysta okulina też się odwróciła")

	// Purity is kept when moving reagents around
	beaker.reagents.clear_reagents()
	beaker.reagents.add_reagent(/datum/reagent/medicine/oculine, 10, added_purity = 0.5)
	var/obj/item/reagent_containers/glass/beaker/other = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.trans_to(other, 5)
	TEST_ASSERT(other.reagents.get_reagent_purity(/datum/reagent/medicine/oculine) == 0.5, "Przelewanie zmieniło czystość ([other.reagents.get_reagent_purity(/datum/reagent/medicine/oculine)])")

#undef TEST_ASSERT
