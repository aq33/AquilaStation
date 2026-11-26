// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Crystallizer recipes use registered gases, and a recipe held in its temperature window turns gas into its product
/datum/unit_test/aquila_crystallizer

/datum/unit_test/aquila_crystallizer/Run()
	// Every recipe uses gases we have and makes something that exists
	var/list/expected = list("diamond", "plasma_sheet", "ammonia_crystal", "fuel_basic", "fuel_advanced", "fuel_exotic", "crystal_shard")
	for(var/recipe_id in expected)
		TEST_ASSERT(GLOB.gas_recipe_meta[recipe_id], "Crystallizer recipe [recipe_id] is missing")
	for(var/recipe_id in GLOB.gas_recipe_meta)
		var/datum/gas_recipe/recipe = GLOB.gas_recipe_meta[recipe_id]
		TEST_ASSERT(length(recipe.requirements) && length(recipe.products), "Recipe [recipe_id] has no gases or no products")
		TEST_ASSERT(recipe.min_temp < recipe.max_temp, "Recipe [recipe_id] has an empty temperature window")
		for(var/gas_type in recipe.requirements)
			TEST_ASSERT(GLOB.gas_data.ids[gas_type], "Recipe [recipe_id] needs unregistered gas [gas_type]")
		for(var/path in recipe.products)
			TEST_ASSERT(ispath(path, /atom/movable), "Recipe [recipe_id] makes [path], which is not an object")

	var/obj/machinery/atmospherics/components/binary/crystallizer/crystallizer = allocate(/obj/machinery/atmospherics/components/binary/crystallizer)
	var/turf/output_turf = crystallizer.get_output_turf()

	// Plasma sheet: plasma on the inlet, the interior kept at 15 K (the middle of its 10-20 K window)
	var/datum/gas_mixture/inlet = crystallizer.airs[2]
	inlet.set_moles(GAS_PLASMA, 500)
	inlet.set_temperature(15)
	crystallizer.select_recipe(GLOB.gas_recipe_meta["plasma_sheet"])
	crystallizer.gas_input = 250
	crystallizer.set_on(TRUE)
	var/sheets_before = count_type(output_turf, /obj/item/stack/sheet/mineral/plasma)
	for(var/tick in 1 to 30)
		crystallizer.internal.set_temperature(15)
		crystallizer.process_atmos()
		if(count_type(output_turf, /obj/item/stack/sheet/mineral/plasma) > sheets_before)
			break
	TEST_ASSERT(count_type(output_turf, /obj/item/stack/sheet/mineral/plasma) > sheets_before, "The crystallizer held in the window made no plasma sheet (progress [crystallizer.progress_bar])")
	// Good quality never makes a product cheaper than its recipe (Yogstation and tg went down to 15%)
	TEST_ASSERT(crystallizer.internal.get_moles(GAS_PLASMA) + inlet.get_moles(GAS_PLASMA) <= 500 - 450 + 0.01, "Making a plasma sheet used less plasma than the recipe")
	TEST_ASSERT(crystallizer.progress_bar == 0, "Progress did not reset after a product")

	for(var/obj/item/stack/sheet/mineral/plasma/sheet in output_turf)
		qdel(sheet)

	// Outside the window the work goes backwards and nothing is made
	inlet.set_moles(GAS_PLASMA, 0)
	crystallizer.internal.set_moles(GAS_PLASMA, 500)
	crystallizer.progress_bar = 50
	crystallizer.internal.set_temperature(T20C)
	crystallizer.process_atmos()
	TEST_ASSERT(crystallizer.progress_bar < 50, "Progress grew with the interior far outside the temperature window")

	// Changing the recipe gives the interior gas back to the inlet
	var/plasma_total = crystallizer.internal.get_moles(GAS_PLASMA) + inlet.get_moles(GAS_PLASMA)
	crystallizer.select_recipe(GLOB.gas_recipe_meta["ammonia_crystal"])
	TEST_ASSERT(!crystallizer.internal.total_moles(), "Changing the recipe left gas inside the crystallizer")
	TEST_ASSERT(abs(inlet.get_moles(GAS_PLASMA) - plasma_total) < 0.01, "Changing the recipe lost plasma")
	TEST_ASSERT(crystallizer.progress_bar == 0, "Changing the recipe kept the progress")

	// The heat port moves the interior towards the coolant temperature
	inlet.set_moles(GAS_PLASMA, 0)
	crystallizer.internal.set_moles(GAS_N2, 100)
	crystallizer.internal.set_temperature(T20C)
	var/datum/gas_mixture/coolant = crystallizer.airs[1]
	coolant.set_moles(GAS_N2, 1000)
	coolant.set_temperature(100)
	crystallizer.heat_conduction()
	TEST_ASSERT(crystallizer.internal.return_temperature() < 200, "The cooling port barely cooled the interior ([crystallizer.internal.return_temperature()] K)")

	// Ammonia crystals grind into ammonia
	var/obj/item/stack/ammonia_crystals/crystals = allocate(/obj/item/stack/ammonia_crystals)
	TEST_ASSERT(crystals.grind_results[/datum/reagent/ammonia], "Ammonia crystals do not grind into ammonia")

	// A crystallized supermatter shard is announced and cannot be sold to cargo
	crystallizer.select_recipe(GLOB.gas_recipe_meta["crystal_shard"])
	for(var/gas_type in crystallizer.selected_recipe.requirements)
		crystallizer.internal.set_moles(gas_type, crystallizer.selected_recipe.requirements[gas_type])
	var/list/made = crystallizer.finish_product()
	var/obj/machinery/power/supermatter_crystal/shard/shard = locate() in made
	TEST_ASSERT(shard, "The supermatter recipe made no shard")
	TEST_ASSERT(shard.crystallized, "The crystallizer shard is not marked as crystallized")
	TEST_ASSERT(findtext(shard.name, "supermaterii"), "The crystallizer shard lost its name: [shard.name]")
	var/datum/export/large/supermatter/export = new
	TEST_ASSERT(!export.applies_to(shard, EXPORT_CARGO), "Cargo buys a supermatter shard made from gas")
	var/obj/machinery/power/supermatter_crystal/shard/bought = allocate(/obj/machinery/power/supermatter_crystal/shard)
	TEST_ASSERT(export.applies_to(bought, EXPORT_CARGO), "Cargo no longer buys an ordinary supermatter shard")
	qdel(export)
	for(var/atom/movable/product as anything in made)
		qdel(product)

	// Fractional quality still gets the right adjective (ranges with gaps fell through to the worst one)
	TEST_ASSERT(crystallizer_quality_name(94.3) == "dobry", "Quality 94.3 is named [crystallizer_quality_name(94.3)]")
	TEST_ASSERT(crystallizer_quality_name(99.5) == "znakomity", "Quality 99.5 is named [crystallizer_quality_name(99.5)]")
	TEST_ASSERT(crystallizer_quality_name(0.5) == "fatalny", "Quality 0.5 is named [crystallizer_quality_name(0.5)]")

	// The gas input is per second: half a second of work takes half of it
	crystallizer.select_recipe(GLOB.gas_recipe_meta["ammonia_crystal"])
	inlet.set_moles(GAS_H2, 100)
	inlet.set_moles(GAS_N2, 100)
	crystallizer.gas_input = 10
	crystallizer.process_atmos(0.5)
	TEST_ASSERT(abs(crystallizer.internal.get_moles(GAS_H2) - 5) < 0.01, "Half a second at 10 mol/s injected [crystallizer.internal.get_moles(GAS_H2)] moles of hydrogen instead of 5")

	// An endothermic recipe does not cool the interior below the coolant, so it cannot chill the red loop for free
	crystallizer.select_recipe(GLOB.gas_recipe_meta["fuel_basic"])
	crystallizer.internal.set_moles(GAS_O2, 50)
	crystallizer.internal.set_moles(GAS_PLASMA, 100)
	crystallizer.internal.set_temperature(T20C)
	coolant.set_moles(GAS_N2, 1000)
	coolant.set_temperature(T20C)
	crystallizer.heat_calculations()
	TEST_ASSERT(crystallizer.internal.return_temperature() >= T20C - 0.01, "An endothermic recipe cooled the interior to [crystallizer.internal.return_temperature()] K, below the [T20C] K coolant")

	// A destroyed crystallizer lets its gas out instead of deleting it
	var/obj/machinery/atmospherics/components/binary/crystallizer/doomed = allocate(/obj/machinery/atmospherics/components/binary/crystallizer)
	var/turf/open/doomed_turf = get_turf(doomed)
	var/datum/gas_mixture/original_air = doomed_turf.air.copy()
	var/plasma_before = doomed_turf.air.get_moles(GAS_PLASMA)
	doomed.internal.set_moles(GAS_PLASMA, 20)
	doomed.internal.set_temperature(T20C)
	qdel(doomed)
	TEST_ASSERT(doomed_turf.air.get_moles(GAS_PLASMA) >= plasma_before + 19.99, "A destroyed crystallizer deleted the gas inside it")
	doomed_turf.air.copy_from(original_air)
	crystallizer.set_on(FALSE)

/datum/unit_test/aquila_crystallizer/proc/count_type(turf/location, path)
	. = 0
	for(var/obj/item/stack/stack in location)
		if(istype(stack, path))
			. += stack.amount

#undef TEST_ASSERT
