// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - chemia z sugestii graczy: bufory pH mają objętość, oczyszczanie w ChemMasterze, nazwy w lodówce, grzanie bez reakcji
/datum/unit_test/aquila_chemia_ulepszenia

/datum/unit_test/aquila_chemia_ulepszenia/Run()
	// A pH buffer shifts the pH and its volume stays in the beaker as the spent buffer
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)
	beaker.reagents.add_reagent(/datum/reagent/water, 50)
	var/obj/item/reagent_containers/glass/bottle/acidic_buffer/buffer = allocate(/obj/item/reagent_containers/glass/bottle/acidic_buffer)
	buffer.reagents.trans_to(beaker, 5)
	TEST_ASSERT(beaker.reagents.ph < 6, "Bufor kwaśny nie obniżył pH ([beaker.reagents.ph])")
	TEST_ASSERT(beaker.reagents.total_volume == 55, "Bufor nie dodał objętości do zlewki ([beaker.reagents.total_volume]u zamiast 55u)")
	TEST_ASSERT(beaker.reagents.get_reagent_amount(/datum/reagent/spent_buffer) == 5, "W zlewce nie ma 5u zużytego buforu")
	TEST_ASSERT(!beaker.reagents.has_reagent(/datum/reagent/reaction_agent/acidic_buffer), "Aktywny bufor trafił do zlewki")
	var/ph_after_buffer = beaker.reagents.ph
	// Pouring the solution further does not shift the pH of the poured part again
	var/obj/item/reagent_containers/glass/beaker/other = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.trans_to(other, 20)
	TEST_ASSERT(abs(other.reagents.ph - ph_after_buffer) < 0.01, "Przelany roztwór zmienił pH z [ph_after_buffer] na [other.reagents.ph]")

	// ChemMaster purification: 100u at 30% purity become 30u at 100%
	var/obj/machinery/chem_master/chem_master = allocate(/obj/machinery/chem_master)
	chem_master.reagents.maximum_volume = 200
	chem_master.reagents.add_reagent(/datum/reagent/medicine/oculine, 100, added_purity = 0.3)
	chem_master.reagents.add_reagent(/datum/reagent/water, 20)
	TEST_ASSERT(chem_master.purify_buffer_reagent(/datum/reagent/medicine/oculine), "ChemMaster odmówił oczyszczenia nieczystej okuliny")
	TEST_ASSERT(chem_master.reagents.get_reagent_amount(/datum/reagent/medicine/oculine) == 30, "Po oczyszczeniu zostało [chem_master.reagents.get_reagent_amount(/datum/reagent/medicine/oculine)]u okuliny zamiast 30u")
	TEST_ASSERT(chem_master.reagents.get_reagent_purity(/datum/reagent/medicine/oculine) == 1, "Okulina po oczyszczeniu ma czystość [chem_master.reagents.get_reagent_purity(/datum/reagent/medicine/oculine)]")
	TEST_ASSERT(chem_master.reagents.get_reagent_amount(/datum/reagent/water) == 20, "Oczyszczanie ruszyło inny odczynnik w buforze")
	TEST_ASSERT(!chem_master.purify_buffer_reagent(/datum/reagent/water), "ChemMaster oczyścił odczynnik, który już był czysty")

	// The chemistry fridge shows the substance first and the container in brackets
	var/obj/machinery/smartfridge/fridge = allocate(/obj/machinery/smartfridge)
	var/obj/item/reagent_containers/pill/charcoal/pill = allocate(/obj/item/reagent_containers/pill/charcoal)
	pill.name = "pigułka: węgiel aktywny"
	TEST_ASSERT(fridge.smartfridge_display_name(pill) == "Węgiel aktywny (pigułka)", "Lodówka pokazuje [fridge.smartfridge_display_name(pill)]")
	pill.name = "pigułka: węgiel aktywny (10 j.)"
	TEST_ASSERT(fridge.smartfridge_display_name(pill) == "Węgiel aktywny (pigułka, 10 j.)","Lodówka pokazuje [fridge.smartfridge_display_name(pill)]")
	var/obj/item/reagent_containers/glass/beaker/plain = allocate(/obj/item/reagent_containers/glass/beaker)
	TEST_ASSERT(fridge.smartfridge_display_name(plain) == capitalize(plain.name), "Lodówka zmieniła nazwę bez dwukropka: [fridge.smartfridge_display_name(plain)]")

	// The chem heater heats plain water, without any reaction going on
	var/obj/machinery/chem_heater/heater = allocate(/obj/machinery/chem_heater)
	heater.machine_stat &= ~NOPOWER
	var/obj/item/reagent_containers/glass/beaker/water_beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	water_beaker.reagents.add_reagent(/datum/reagent/water, 30, reagtemp = 300)
	water_beaker.forceMove(heater)
	heater.replace_beaker(null, water_beaker)
	heater.target_temperature = 400
	heater.on = TRUE
	heater.process(2)
	TEST_ASSERT(!water_beaker.reagents.is_reacting, "Woda w grzałce zaczęła reagować")
	TEST_ASSERT(water_beaker.reagents.chem_temp > 310, "Grzałka nie podgrzała wody bez reakcji ([water_beaker.reagents.chem_temp] K)")
	heater.target_temperature = 200
	var/hot = water_beaker.reagents.chem_temp
	heater.process(2)
	TEST_ASSERT(water_beaker.reagents.chem_temp < hot, "Grzałka nie schłodziła wody bez reakcji ([water_beaker.reagents.chem_temp] K)")

#undef TEST_ASSERT
