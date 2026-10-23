// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Porty z Monkestation (PR aq33/AquilaStation#488) przeklikane jak w grze: akcje gracza zamiast wołania wewnętrznych procedur
/datum/unit_test/monke_ingame

/datum/unit_test/monke_ingame/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/next_to_user = locate(user.x + 1, user.y, user.z)

	// Sterta śmieci: chowanie przedmiotu, nurkowanie i wyjście ze sterty
	var/obj/structure/trash_pile/pile = allocate(/obj/structure/trash_pile, next_to_user)
	var/obj/item/stack/sheet/cardboard/hidden_item = allocate(/obj/item/stack/sheet/cardboard)
	user.put_in_active_hand(hidden_item)
	pile.attackby(hidden_item, user)
	TEST_ASSERT(hidden_item.loc == pile, "Przedmiot nie schował się w stercie")
	TEST_ASSERT(pile.attack_hand_secondary(user) == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN, "PPM na stercie przepuszcza zwykły attack_hand")
	TEST_ASSERT(user.loc == pile, "Gracz nie zanurkował w stercie")
	pile.attack_hand(user)
	TEST_ASSERT(isturf(user.loc), "Klik w środku sterty nie wyrzucił gracza")
	user.forceMove(run_loc_floor_bottom_left)
	qdel(pile)
	TEST_ASSERT(isturf(hidden_item.loc), "Rozbita sterta nie wyrzuciła schowanego przedmiotu")

	// Dzwonek działu: dzwonienie ręką wzywa dział i włącza odliczanie
	var/obj/structure/desk_bell/departmental/medical/bell = allocate(/obj/structure/desk_bell/departmental/medical, next_to_user)
	bell.attack_hand(user)
	TEST_ASSERT(!COOLDOWN_FINISHED(bell, announce_cooldown), "Dzwonek działu nie wezwał działu po kliknięciu")
	TEST_ASSERT(!bell.wrench_act(user, allocate(/obj/item/wrench)), "Dzwonek działu dał się odkręcić")
	qdel(bell)

	// Bartending: krojenie limonki nożem, drut z kabla, sól krystalizuje się w 600 K
	var/obj/item/food/grown/citrus/lime/lime = allocate(/obj/item/food/grown/citrus/lime, next_to_user)
	var/obj/item/kitchen/knife/knife = allocate(/obj/item/kitchen/knife)
	user.put_in_active_hand(knife)
	knife.melee_attack_chain(user, lime)
	var/slices = 0
	for(var/obj/item/garnish/lime/slice in next_to_user)
		slices++
	TEST_ASSERT(slices == 3, "Krojenie limonki dało [slices] plastrów zamiast 3")
	user.dropItemToGround(knife)

	var/obj/item/stack/cable_coil/coil = allocate(/obj/item/stack/cable_coil, next_to_user)
	var/obj/item/wirecutters/cutters = allocate(/obj/item/wirecutters)
	user.put_in_active_hand(cutters)
	coil.attackby(cutters, user)
	TEST_ASSERT(locate(/obj/item/garnish/wire) in next_to_user, "Przecinak na kablu nie dał drutu")
	user.dropItemToGround(cutters)

	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker, next_to_user)
	beaker.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 10)
	// Jak grzałka chemiczna: temperatura wprost, potem reakcja (fermichem może iść w kilku krokach)
	beaker.reagents.chem_temp = 700
	beaker.reagents.handle_reactions()
	for(var/i in 1 to 20)
		if(locate(/obj/item/garnish/salt) in next_to_user)
			break
		sleep(2)
	TEST_ASSERT(locate(/obj/item/garnish/salt) in next_to_user, "Podgrzana sól nie dała solnej krawędzi")

	var/obj/item/reagent_containers/food/drinks/modglass/glass = allocate(/obj/item/reagent_containers/food/drinks/modglass)
	var/obj/item/garnish/lime/one_slice = locate() in next_to_user
	glass.attackby(one_slice, user)
	glass.reagents.add_reagent(/datum/reagent/consumable/limejuice, 30)
	sleep(2) // nakładki dokleja SSoverlays w następnym ticku
	TEST_ASSERT(length(glass.overlays) >= 2, "Pełna szklanka z plastrem nie ma nakładek wypełnienia i dekoracji")

	var/obj/machinery/vending/boozeomat/booze = allocate(/obj/machinery/vending/boozeomat, next_to_user)
	var/found_glass = FALSE
	for(var/datum/data/vending_product/record as anything in booze.product_records)
		if(record.product_path == /obj/item/reagent_containers/food/drinks/modglass/large)
			found_glass = TRUE
	TEST_ASSERT(found_glass, "Booze-O-Mat nie sprzedaje dużych plastycznych szklanek")

	// Cybernetyka: autochirurg z parą implantów nóg daje cechę, zestaw kuchenny wysuwa narzędzie do ręki
	var/obj/item/autosurgeon/cyber_test/table_glider/surgeon = allocate(/obj/item/autosurgeon/cyber_test/table_glider)
	user.put_in_active_hand(surgeon)
	surgeon.attack_self(user)
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_FAST_CLIMBER), "Para implantów ślizgu z autochirurga nie dała cechy")
	user.dropItemToGround(surgeon)
	var/obj/item/organ/cyberimp/arm/cook/cook = allocate(/obj/item/organ/cyberimp/arm/cook)
	cook.Insert(user)
	var/obj/item/first_tool = cook.contents[1]
	cook.Extend(first_tool)
	TEST_ASSERT(user.is_holding(first_tool), "Zestaw kuchenny nie wysunął narzędzia do ręki")
	cook.Retract()
	TEST_ASSERT(first_tool.loc == cook, "Zestaw kuchenny nie schował narzędzia")

	// Transmisja: kamera w ręce zaczyna i kończy program na telewizorze
	var/obj/machinery/computer/security/telescreen/entertainment/tv = allocate(/obj/machinery/computer/security/telescreen/entertainment, next_to_user)
	var/obj/item/broadcast_camera/camera = allocate(/obj/item/broadcast_camera)
	user.put_in_active_hand(camera)
	camera.attack_self(user)
	TEST_ASSERT(camera.active, "Kamera reporterska nie zaczęła nadawać")
	TEST_ASSERT(length(camera.camera_networks & tv.network) == length(camera.camera_networks), "Telewizor nie złapał transmisji z kamery")
	camera.attack_self(user)
	TEST_ASSERT(!length(camera.camera_networks & tv.network), "Telewizor nadal pokazuje zakończoną transmisję")
	user.dropItemToGround(camera)

	// Lifeline: osoba z czujnikami na pełnym śledzeniu jest na liście, z wyłączonymi już nie
	var/obj/item/modular_computer/tablet/preset/advanced/tablet = allocate(/obj/item/modular_computer/tablet/preset/advanced, next_to_user)
	var/datum/computer_file/program/radar/lifeline/lifeline = new
	lifeline.computer = tablet
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, next_to_user)
	var/obj/item/clothing/under/uniform = allocate(/obj/item/clothing/under/color/grey)
	patient.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING)
	uniform.has_sensor = HAS_SENSORS
	uniform.sensor_mode = SENSOR_COORDS
	lifeline.trackable(patient) // rozgrzewka listy czujników
	var/listed = FALSE
	for(var/list/entry in lifeline.build_sensor_list())
		if(entry["ref"] == REF(patient))
			listed = TRUE
	TEST_ASSERT(listed, "Lifeline nie pokazuje osoby z czujnikami na pełnym śledzeniu")
	uniform.sensor_mode = SENSOR_OFF
	lifeline.sensors_cache = null
	for(var/list/entry in lifeline.build_sensor_list())
		TEST_ASSERT(entry["ref"] != REF(patient), "Lifeline pokazuje osobę z wyłączonymi czujnikami")
	qdel(lifeline)

#undef TEST_ASSERT
