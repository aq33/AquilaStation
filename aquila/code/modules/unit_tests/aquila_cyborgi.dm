// AQUILA - nowe moduły i ulepszenia cyborgów (aquila/code/modules/mob/living/silicon/robot/cyborgi/)
// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Cyborg z założonym modułem: to samo co transform_to, ale bez animacji (ona śpi kilka sekund i zostałaby po teście)
/datum/unit_test/proc/aq_cyborg_with_module(module_type)
	var/mob/living/silicon/robot/cyborg = allocate(/mob/living/silicon/robot)
	// Mosiężna włócznia w modułach Standardowym i Ochrony woła przy tworzeniu pickup(), który wymaga umysłu
	// (bez dopisywania do SSticker.minds, żeby nie zostawał po teście)
	cyborg.mind = new /datum/mind()
	cyborg.mind.set_current(cyborg)
	var/obj/item/robot_module/old_module = cyborg.module
	var/obj/item/robot_module/new_module = new module_type(cyborg)
	new_module.robot = cyborg
	new_module.be_transformed_to(old_module, TRUE)
	cyborg.module = new_module
	cyborg.update_module_innate()
	new_module.rebuild_modules()
	qdel(old_module)
	return cyborg

/// Każdy nowy moduł zakłada się bez runtime'ów, daje swoje narzędzia, ma skiny z istniejących stanów ikon i trafia do kółka wyboru
/datum/unit_test/aquila_cyborg_modules

/datum/unit_test/aquila_cyborg_modules/Run()
	var/list/crew_modules = list()
	aquila_add_cyborg_modules(crew_modules)
	TEST_ASSERT(length(crew_modules) == 12, "Kółko wyboru dostało [length(crew_modules)] modułów Aquili zamiast 12")
	var/list/all_modules = list()
	for(var/key in crew_modules)
		all_modules += crew_modules[key]
	all_modules += list(/obj/item/robot_module/engineering/advanced, /obj/item/robot_module/medical/advanced, /obj/item/robot_module/miner/advanced, /obj/item/robot_module/lost)
	for(var/module_type in all_modules)
		var/obj/item/robot_module/module_path = module_type
		var/icon_file = initial(module_path.aq_base_icon_file) || 'icons/mob/robots.dmi'
		TEST_ASSERT(initial(module_path.cyborg_base_icon) in icon_states(icon_file), "[module_type]: brak stanu [initial(module_path.cyborg_base_icon)] w [icon_file]")
		var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(module_type)
		TEST_ASSERT(cyborg.module.type == module_type, "Cyborg nie dostał modułu [module_type]")
		TEST_ASSERT(length(cyborg.module.modules) >= 8, "[module_type] ma tylko [length(cyborg.module.modules)] narzędzi")
		for(var/obj/item/tool in cyborg.module.basic_modules)
			TEST_ASSERT(tool in cyborg.module.modules, "[module_type]: narzędzie [tool.type] nie trafiło do modułu")
			TEST_ASSERT(HAS_TRAIT(tool, TRAIT_NODROP), "[module_type]: narzędzie [tool.type] da się upuścić")
		for(var/skin in cyborg.module.borg_skins)
			var/list/details = cyborg.module.borg_skins[skin]
			var/skin_file = details[SKIN_ICON] || 'icons/mob/robots.dmi'
			TEST_ASSERT(details[SKIN_ICON_STATE] in icon_states(skin_file), "[module_type]: skin [skin] wskazuje brakujący stan [details[SKIN_ICON_STATE]]")

	// Eksploracyjny przeżyje pogodę planet, a po zmianie modułu odporność znika
	var/mob/living/silicon/robot/explorer = aq_cyborg_with_module(/obj/item/robot_module/exploration)
	TEST_ASSERT(("snow" in explorer.weather_immunities) && ("acid" in explorer.weather_immunities), "Eksploracyjny nie jest odporny na pogodę planet")
	var/obj/item/robot_module/old_module = explorer.module
	explorer.module = new /obj/item/robot_module/standard(explorer)
	qdel(old_module)
	TEST_ASSERT(!("snow" in explorer.weather_immunities), "Odporność eksploracyjnego została po zmianie modułu")

	// Zagubiony: bez praw okrętu, bez SI i bez dostępu poza tunelami
	// (typ /mob/living/silicon/robot/modules/lost zakłada moduł z animacją, więc test składa go ręcznie)
	var/mob/living/silicon/robot/lost = aq_cyborg_with_module(/obj/item/robot_module/lost)
	lost.aq_make_lost()
	TEST_ASSERT(istype(lost.laws, /datum/ai_laws/aquila_lost), "Zagubiony ma prawa okrętu")
	TEST_ASSERT(!lost.connected_ai && !lost.lawupdate, "Zagubiony jest połączony z SI")
	TEST_ASSERT(!(ACCESS_HEADS in lost.internal_id_card.access), "Zagubiony ma dostęp dowództwa")

/// Każde ulepszenie instaluje się w pasującym module, odmawia w niepasującym, a po wyjęciu zdejmuje narzędzia
/datum/unit_test/aquila_cyborg_upgrades

/datum/unit_test/aquila_cyborg_upgrades/Run()
	// ulepszenie => list(pasujący moduł, niepasujący moduł albo null, gdy pasuje do wszystkich)
	var/list/cases = list(
		/obj/item/borg/upgrade/aquila/toggle/magnetic_traction = list(/obj/item/robot_module/standard, null),
		/obj/item/borg/upgrade/aquila/power_saver = list(/obj/item/robot_module/research, null),
		/obj/item/borg/upgrade/aquila/power_connector = list(/obj/item/robot_module/exploration, null),
		/obj/item/borg/upgrade/aquila/gps = list(/obj/item/robot_module/medical, null),
		/obj/item/borg/upgrade/aquila/death_alarm = list(/obj/item/robot_module/engineering, null),
		/obj/item/borg/upgrade/aquila/toggle/autocleaner = list(/obj/item/robot_module/butler, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/inducer = list(/obj/item/robot_module/engineering, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/rld = list(/obj/item/robot_module/engineering, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/bluespace_rped = list(/obj/item/robot_module/research, /obj/item/robot_module/miner),
		/obj/item/borg/upgrade/aquila/engineering_omnitool = list(/obj/item/robot_module/engineering, /obj/item/robot_module/research),
		/obj/item/borg/upgrade/aquila/plating_repair = list(/obj/item/robot_module/janitor, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/nightvision_mesons = list(/obj/item/robot_module/miner, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/science_circuits = list(/obj/item/robot_module/research, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/xenobiology = list(/obj/item/robot_module/research, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/anomaly_vision = list(/obj/item/robot_module/research, /obj/item/robot_module/miner),
		/obj/item/borg/upgrade/aquila/advanced_analyzer = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/surgical_omnitool = list(/obj/item/robot_module/medical/surgeon, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/advanced_surgery = list(/obj/item/robot_module/medical, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/organ_synthesizer = list(/obj/item/robot_module/medical/surgeon, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/blood_synthesizer = list(/obj/item/robot_module/medical/rescue, /obj/item/robot_module/miner),
		/obj/item/borg/upgrade/aquila/holo_stretcher = list(/obj/item/robot_module/medical/rescue, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/breathing_bag = list(/obj/item/robot_module/medical/rescue, /obj/item/robot_module/security),
		/obj/item/borg/upgrade/aquila/medigripper = list(/obj/item/robot_module/medical, /obj/item/robot_module/cargo),
		/obj/item/borg/upgrade/aquila/chemistry_gripper = list(/obj/item/robot_module/medical, /obj/item/robot_module/research),
		/obj/item/borg/upgrade/aquila/bluespace_beaker = list(/obj/item/robot_module/medical/chemistry, /obj/item/robot_module/butler),
		/obj/item/borg/upgrade/aquila/spectro_scanner = list(/obj/item/robot_module/medical, /obj/item/robot_module/research),
		/obj/item/borg/upgrade/aquila/advanced_cutter = list(/obj/item/robot_module/miner, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/ore_processor = list(/obj/item/robot_module/exploration, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/nightvision = list(/obj/item/robot_module/exploration, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/toggle/floodlight = list(/obj/item/robot_module/exploration, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/cargo_teleporter = list(/obj/item/robot_module/cargo/logistics, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/lethal_unlock = list(/obj/item/robot_module/security, /obj/item/robot_module/peacekeeper),
		/obj/item/borg/upgrade/aquila/bola_launcher = list(/obj/item/robot_module/peacekeeper, /obj/item/robot_module/detective),
		/obj/item/borg/upgrade/aquila/toggle/personal_shield = list(/obj/item/robot_module/security, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/forensic_scanner = list(/obj/item/robot_module/brobocop, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/noir = list(/obj/item/robot_module/detective, /obj/item/robot_module/security),
		/obj/item/borg/upgrade/aquila/plunger = list(/obj/item/robot_module/janitor, /obj/item/robot_module/butler),
		/obj/item/borg/upgrade/aquila/push_broom = list(/obj/item/robot_module/janitor, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/cookbook = list(/obj/item/robot_module/butler, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/transform/aquila_advanced/engineering = list(/obj/item/robot_module/engineering, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/transform/aquila_advanced/medical = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/transform/aquila_advanced/miner = list(/obj/item/robot_module/miner, /obj/item/robot_module/engineering),
	)
	for(var/upgrade_type in cases)
		var/list/modules = cases[upgrade_type]
		// Niepasujący moduł: odmowa i żadne narzędzie nie przybywa
		if(modules[2])
			var/mob/living/silicon/robot/wrong = aq_cyborg_with_module(modules[2])
			var/tools_before = length(wrong.module.modules)
			var/obj/item/borg/upgrade/refused = allocate(upgrade_type)
			TEST_ASSERT(!refused.action(wrong, wrong), "[upgrade_type] zainstalował się w module [modules[2]]")
			TEST_ASSERT(wrong.module.type == modules[2], "[upgrade_type] zmienił niepasujący moduł")
			TEST_ASSERT(length(wrong.module.modules) == tools_before, "[upgrade_type] dodał narzędzia mimo odmowy")
		if(ispath(upgrade_type, /obj/item/borg/upgrade/transform))
			continue // zmiana modułu pokazuje cyborgowi kółko skinów, sam moduł sprawdza aquila_cyborg_modules
		var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(modules[1])
		var/obj/item/borg/upgrade/aquila/upgrade = allocate(upgrade_type)
		TEST_ASSERT(upgrade.action(cyborg, cyborg), "[upgrade_type] nie zainstalował się w module [modules[1]]")
		upgrade.forceMove(cyborg)
		cyborg.upgrades += upgrade
		if(length(upgrade.aq_items))
			var/first = upgrade.aq_items[1]
			TEST_ASSERT(cyborg.aq_find_module_item(first), "[upgrade_type] nie dał narzędzia [first]")
			var/obj/item/borg/upgrade/aquila/second = allocate(upgrade_type)
			TEST_ASSERT(!second.action(cyborg, cyborg), "[upgrade_type] dał się zainstalować drugi raz")
			for(var/replaced in upgrade.aq_replaces)
				for(var/obj/item/tool in cyborg.module.modules)
					TEST_ASSERT(tool.type != replaced, "[upgrade_type] zostawił zastąpione narzędzie [replaced]")
			var/list/removed = upgrade.aq_removed.Copy()
			TEST_ASSERT(upgrade.deactivate(cyborg, cyborg), "[upgrade_type] nie dał się wyjąć")
			cyborg.upgrades -= upgrade
			TEST_ASSERT(!cyborg.aq_find_module_item(first), "[upgrade_type] zostawił narzędzie [first] po wyjęciu")
			for(var/restored in removed)
				TEST_ASSERT(cyborg.aq_find_module_item(restored), "[upgrade_type] nie oddał narzędzia [restored]")

/// Tryb zabójczy działa tylko przy czerwonym alarmie (albo abordażu) i sam wraca na obezwładnianie
/datum/unit_test/aquila_cyborg_lethal_mode

/datum/unit_test/aquila_cyborg_lethal_mode/Run()
	var/old_level = GLOB.security_level
	var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(/obj/item/robot_module/security)
	var/obj/item/borg/upgrade/aquila/lethal_unlock/upgrade = allocate(/obj/item/borg/upgrade/aquila/lethal_unlock)
	TEST_ASSERT(upgrade.action(cyborg, cyborg), "Odblokowanie trybu zabójczego nie weszło do modułu ochrony")
	var/obj/item/gun/energy/e_gun/aquila_cyborg_lethal/gun = cyborg.aq_find_module_item(/obj/item/gun/energy/e_gun/aquila_cyborg_lethal)
	TEST_ASSERT(gun, "Brak broni z trybem zabójczym")

	GLOB.security_level = SEC_LEVEL_GREEN
	var/allowed_green = aquila_cyborg_lethal_allowed(cyborg)
	gun.select_fire(cyborg)
	var/lethal_at_green = gun.aq_lethal_selected()

	GLOB.security_level = SEC_LEVEL_BLUE
	var/allowed_blue = aquila_cyborg_lethal_allowed(cyborg)

	GLOB.security_level = SEC_LEVEL_RED
	var/allowed_red = aquila_cyborg_lethal_allowed(cyborg)
	gun.select_fire(cyborg)
	var/lethal_at_red = gun.aq_lethal_selected()

	// Alarm odwołany: strzał w trybie zabójczym nie wychodzi, broń wraca na obezwładnianie
	GLOB.security_level = SEC_LEVEL_GREEN
	var/fired = gun.process_fire(run_loc_floor_top_right, cyborg)
	var/lethal_after = gun.aq_lethal_selected()
	GLOB.security_level = old_level

	TEST_ASSERT(!allowed_green || !isnull(cyborg.get_overmap()), "Tryb zabójczy dozwolony przy zielonym alarmie")
	if(!allowed_green)
		TEST_ASSERT(!lethal_at_green, "Przy zielonym alarmie broń przełączyła się na tryb zabójczy")
		TEST_ASSERT(!allowed_blue, "Tryb zabójczy dozwolony przy niebieskim alarmie")
		TEST_ASSERT(!fired && !lethal_after, "Po odwołaniu alarmu broń dalej strzela zabójczo")
	TEST_ASSERT(allowed_red, "Tryb zabójczy zablokowany przy czerwonym alarmie")
	TEST_ASSERT(lethal_at_red, "Przy czerwonym alarmie nie da się wybrać trybu zabójczego")

/// Magnetyczne przyczepy blokują wysysanie przy dekompresji
/datum/unit_test/aquila_cyborg_magnetic_traction

/datum/unit_test/aquila_cyborg_magnetic_traction/Run()
	var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(/obj/item/robot_module/standard)
	var/obj/item/borg/upgrade/aquila/toggle/magnetic_traction/traction = allocate(/obj/item/borg/upgrade/aquila/toggle/magnetic_traction)
	TEST_ASSERT(traction.action(cyborg, cyborg), "Przyczepy nie weszły do cyborga")
	cyborg.upgrades += traction
	TEST_ASSERT(!cyborg.magpulse, "Przyczepy działają przed włączeniem")
	traction.aq_set_active(TRUE)
	TEST_ASSERT(cyborg.magpulse, "Włączone przyczepy nie trzymają podłogi")
	var/turf/start = get_turf(cyborg)
	for(var/i in 1 to 20)
		cyborg.last_high_pressure_movement_air_cycle = 0
		cyborg.experience_pressure_difference(800, EAST)
	TEST_ASSERT(get_turf(cyborg) == start, "Dekompresja wyssała cyborga mimo przyczep")
	traction.aq_set_active(FALSE)
	TEST_ASSERT(!cyborg.magpulse, "Przyczepy zostały po wyłączeniu")
	TEST_ASSERT(traction.deactivate(cyborg, cyborg), "Przyczepy nie dały się wyjąć")
	// Inżynieryjny ma przyczepy z modułu: wyjęcie ulepszenia ich nie zdejmuje
	var/mob/living/silicon/robot/engineer = aq_cyborg_with_module(/obj/item/robot_module/engineering)
	var/obj/item/borg/upgrade/aquila/toggle/magnetic_traction/engineer_traction = allocate(/obj/item/borg/upgrade/aquila/toggle/magnetic_traction)
	engineer_traction.action(engineer, engineer)
	engineer_traction.aq_set_active(TRUE)
	engineer_traction.aq_set_active(FALSE)
	TEST_ASSERT(engineer.magpulse, "Wyłączenie przyczep zdjęło magnesy modułu inżynieryjnego")

/// Narzędzia z nową logiką robią to, co mają: tabletki, sztabki, krew, teleport skrzyni, tarcza, oszczędzanie energii, alarm
/datum/unit_test/aquila_cyborg_tools

/datum/unit_test/aquila_cyborg_tools/Run()
	var/mob/living/silicon/robot/chemist = aq_cyborg_with_module(/obj/item/robot_module/medical/chemistry)
	chemist.cell.charge = chemist.cell.maxcharge
	var/obj/item/borg/chem_master/chem_master = chemist.aq_find_module_item(/obj/item/borg/chem_master)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/medicine/bicaridine, 20)
	TEST_ASSERT(chem_master.aq_make_items(chemist, beaker, "Tabletki", 10, 2) == 2, "Mini-CheMaster nie zrobił dwóch tabletek")
	TEST_ASSERT(!beaker.reagents.total_volume, "Mini-CheMaster nie zużył odczynników")
	var/pills = 0
	for(var/obj/item/reagent_containers/pill/pill in get_turf(chemist))
		pills++
		TEST_ASSERT(pill.reagents.has_reagent(/datum/reagent/medicine/bicaridine, 10), "Tabletka nie ma 10 j. bikarydyny")
		qdel(pill)
	TEST_ASSERT(pills == 2, "Pod cyborgiem leży [pills] tabletek")

	// Oszczędzacz energii: 30% mniej z ogniwa cyborga
	var/obj/item/borg/upgrade/aquila/power_saver/saver = allocate(/obj/item/borg/upgrade/aquila/power_saver)
	saver.action(chemist, chemist)
	var/charge_before = chemist.cell.charge
	chemist.cell.use(1000)
	TEST_ASSERT(round(charge_before - chemist.cell.charge) == 700, "Oszczędzacz energii pobrał [charge_before - chemist.cell.charge] zamiast 700")

	// Syntezator krwi
	var/obj/item/reagent_containers/blood/bag = allocate(/obj/item/reagent_containers/blood)
	var/obj/item/borg/blood_synthesizer/synth = allocate(/obj/item/borg/blood_synthesizer)
	TEST_ASSERT(synth.aq_fill(chemist, bag), "Syntezator krwi nie dolał krwi")
	var/datum/reagent/blood/blood = bag.reagents.has_reagent(/datum/reagent/blood)
	TEST_ASSERT(blood && blood.data["blood_type"] == "O-", "Syntezator nie zrobił krwi 0 Rh-")

	// Przenośna huta
	var/mob/living/silicon/robot/miner = aq_cyborg_with_module(/obj/item/robot_module/miner/advanced)
	miner.cell.charge = miner.cell.maxcharge
	var/obj/item/storage/bag/ore/ore_bag = miner.aq_find_module_item(/obj/item/storage/bag/ore)
	var/obj/item/stack/ore/iron/ore = new(ore_bag, 5)
	var/obj/item/borg/ore_processor/furnace = miner.aq_find_module_item(/obj/item/borg/ore_processor)
	TEST_ASSERT(furnace.aq_smelt(miner) == 5, "Przenośna huta nie przetopiła 5 rudy")
	TEST_ASSERT(QDELETED(ore), "Ruda została w torbie")
	var/obj/item/stack/sheet/iron/sheets = locate() in get_turf(miner)
	TEST_ASSERT(sheets?.amount == 5, "Huta nie dała 5 sztabek żelaza")
	qdel(sheets)

	// Teleporter ładunku
	var/mob/living/silicon/robot/porter = aq_cyborg_with_module(/obj/item/robot_module/cargo/logistics)
	porter.cell.charge = porter.cell.maxcharge
	var/obj/item/borg/cargo_teleporter/teleporter = allocate(/obj/item/borg/cargo_teleporter)
	teleporter.destination = WEAKREF(run_loc_floor_top_right)
	var/obj/structure/closet/crate/crate = allocate(/obj/structure/closet/crate)
	TEST_ASSERT(teleporter.aq_send(porter, crate), "Teleporter nie wysłał skrzyni")
	TEST_ASSERT(get_turf(crate) == run_loc_floor_top_right, "Skrzynia nie trafiła do celu")
	crate.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!teleporter.aq_send(porter, crate), "Teleporter nie ładuje się po wysyłce")

	// Osobista tarcza: trafienie za 30 ścięte do 4
	var/mob/living/silicon/robot/guard = aq_cyborg_with_module(/obj/item/robot_module/security)
	guard.cell.charge = guard.cell.maxcharge
	var/obj/item/borg/upgrade/aquila/toggle/personal_shield/shield = allocate(/obj/item/borg/upgrade/aquila/toggle/personal_shield)
	shield.action(guard, guard)
	shield.aq_set_active(TRUE)
	guard.apply_damage(30, BRUTE)
	TEST_ASSERT(guard.getBruteLoss() == 4, "Tarcza przepuściła [guard.getBruteLoss()] obrażeń zamiast 4")
	shield.aq_set_active(FALSE)

	// Alarm zniszczenia podaje, kto padł i gdzie
	var/obj/item/borg/upgrade/aquila/death_alarm/alarm = allocate(/obj/item/borg/upgrade/aquila/death_alarm)
	var/message = alarm.aq_message(guard)
	TEST_ASSERT(findtext(message, guard.real_name) && findtext(message, get_area_name(guard, TRUE)), "Alarm zniszczenia nie podaje nazwy albo miejsca: [message]")

#undef TEST_ASSERT
