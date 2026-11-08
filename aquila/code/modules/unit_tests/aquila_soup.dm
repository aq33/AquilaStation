// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - port tgstation/tgstation#74205: woda i składniki w podgrzanym garnku dają zupę, a składniki znikają
/datum/unit_test/aquila_soup_pot

/datum/unit_test/aquila_soup_pot/Run()
	var/mob/living/carbon/human/chef = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/glass/soup_pot/pot = allocate(/obj/item/reagent_containers/glass/soup_pot, run_loc_floor_bottom_left)
	for(var/ingredient_type in list(/obj/item/food/meatball, /obj/item/food/grown/carrot, /obj/item/food/grown/potato))
		var/obj/item/ingredient = allocate(ingredient_type)
		chef.put_in_active_hand(ingredient, forced = TRUE)
		pot.attackby(ingredient, chef)
	TEST_ASSERT(LAZYLEN(pot.added_ingredients) == 3, "The pot did not take the ingredients")

	pot.reagents.add_reagent(/datum/reagent/water, 50, reagtemp = 480)
	for(var/step in 1 to 120)
		if(!pot.reagents.is_reacting)
			break
		pot.reagents.chem_temp = 480
		pot.reagents.process(1)
	TEST_ASSERT(!pot.reagents.is_reacting, "The soup reaction did not finish")
	TEST_ASSERT(pot.reagents.has_reagent(/datum/reagent/consumable/nutriment/soup/meatball_soup), "Water, a meatball, a carrot and a potato did not make meatball soup")
	TEST_ASSERT(!LAZYLEN(pot.added_ingredients), "The ingredients stayed in the pot after cooking")

	TEST_ASSERT(pot.managed_overlays, "A pot with soup has no liquid overlay")

	// Chochlą do miski (pusta chochla nabiera z garnka, pełna przelewa), miska przyjmuje wygląd zupy
	var/obj/item/reagent_containers/glass/soup_ladle/ladle = allocate(/obj/item/reagent_containers/glass/soup_ladle)
	var/obj/item/reagent_containers/glass/bowl/bowl = allocate(/obj/item/reagent_containers/glass/bowl, run_loc_floor_bottom_left)
	chef.put_in_active_hand(ladle, forced = TRUE)
	ladle.afterattack(pot, chef, TRUE)
	TEST_ASSERT(ladle.reagents.total_volume == SOUP_SERVING_SIZE, "An empty ladle did not scoop a serving from the pot ([ladle.reagents.total_volume] u)")
	TEST_ASSERT(ladle.icon_state == "ladle" && ladle.managed_overlays, "A full ladle lost its sprite (icon_state [ladle.icon_state]) or has no serving overlay")
	ladle.afterattack(bowl, chef, TRUE)
	TEST_ASSERT(!ladle.reagents.total_volume, "The ladle did not pour the serving into the bowl")
	TEST_ASSERT(bowl.icon_state == "meatballsoup", "A bowl of meatball soup does not look like one (icon_state [bowl.icon_state])")

/// AQUILA - port tgstation/tgstation#74205: bez składników albo w zwykłej zlewce zupa nie powstaje
/datum/unit_test/aquila_soup_needs_pot

/datum/unit_test/aquila_soup_needs_pot/Run()
	var/obj/item/reagent_containers/glass/soup_pot/pot = allocate(/obj/item/reagent_containers/glass/soup_pot, run_loc_floor_bottom_left)
	pot.reagents.add_reagent(/datum/reagent/water, 50, reagtemp = 480)
	for(var/step in 1 to 20)
		if(!pot.reagents.is_reacting)
			break
		pot.reagents.process(1)
	for(var/datum/reagent/reagent as anything in pot.reagents.reagent_list)
		TEST_ASSERT(!istype(reagent, /datum/reagent/consumable/nutriment/soup), "Plain hot water turned into [reagent.type]")

	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large, run_loc_floor_bottom_left)
	beaker.reagents.add_reagent(/datum/reagent/water, 50, reagtemp = 480)
	for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
		TEST_ASSERT(!istype(reagent, /datum/reagent/consumable/nutriment/soup), "Hot water in a beaker turned into soup")

/// AQUILA - port tgstation/tgstation#74205: kuchenka grzeje garnek i rysuje płomienie dopiero po włączeniu
/datum/unit_test/aquila_stove

/datum/unit_test/aquila_stove/Run()
	var/mob/living/carbon/human/chef = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/stove/stove = allocate(/obj/machinery/stove, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/glass/soup_pot/pot = allocate(/obj/item/reagent_containers/glass/soup_pot)
	pot.reagents.add_reagent(/datum/reagent/water, 50, reagtemp = 300)
	chef.put_in_active_hand(pot, forced = TRUE)
	stove.attackby(pot, chef)
	TEST_ASSERT(pot.loc == stove, "The pot was not placed on the stove")

	var/datum/component/stove/burners = stove.GetComponent(/datum/component/stove)
	TEST_ASSERT(!burners.on, "A new stove is lit")
	burners.toggle_burners(chef)
	TEST_ASSERT(burners.on || (stove.machine_stat & NOPOWER), "The stove did not light up")
	if(burners.on)
		// Komponent nie jest maszyną: w SSmachines sypał runtime o use_power i przerywał obsługę innych maszyn
		TEST_ASSERT(!(burners in SSmachines.processing), "The stove component processes in SSmachines")
		TEST_ASSERT(burners in SSobj.processing, "A lit stove does not process")
		var/start_temp = pot.reagents.chem_temp
		burners.process(2)
		TEST_ASSERT(pot.reagents.chem_temp > start_temp, "The stove did not heat the pot")
		burners.toggle_burners(chef)

#undef TEST_ASSERT
