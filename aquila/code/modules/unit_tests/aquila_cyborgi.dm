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
	TEST_ASSERT(length(crew_modules) == 4, "Kółko wyboru dostało [length(crew_modules)] modułów Aquili zamiast 4")
	var/list/all_modules = list()
	for(var/key in crew_modules)
		all_modules += crew_modules[key]
	all_modules += /obj/item/robot_module/lost
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

	// Skiny scalonych modułów (Chemiczny, Chirurgiczny, Ratowniczy, Budowlany, Biurowy, Magazynowy, Hydroponiczny) wskazują istniejące stany
	for(var/module_type in list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering, /obj/item/robot_module/cargo, /obj/item/robot_module/butler))
		var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(module_type)
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

/// Każde nowe ulepszenie ma projekt w fabrykatorze, który jest w sieci badań, i ikonę z istniejącym stanem
/datum/unit_test/aquila_cyborg_designs

/datum/unit_test/aquila_cyborg_designs/Run()
	var/list/in_nodes = list()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for(var/design_id in node.design_ids)
			in_nodes[design_id] = TRUE
	var/list/built = list()
	for(var/datum/design/design_type as anything in subtypesof(/datum/design))
		var/design_id = initial(design_type.id)
		if(!findtext(design_id, "aq_borg_"))
			continue
		TEST_ASSERT(in_nodes[design_id], "Projekt [design_id] nie jest w żadnym węźle badań")
		TEST_ASSERT(initial(design_type.build_type) & MECHFAB, "Projekt [design_id] nie jest z fabrykatora egzoszkieletów")
		built[initial(design_type.build_path)] = TRUE
	var/list/upgrades = subtypesof(/obj/item/borg/upgrade/aquila) - /obj/item/borg/upgrade/aquila/toggle
	for(var/obj/item/upgrade_type as anything in upgrades)
		TEST_ASSERT(built[upgrade_type], "Ulepszenia [upgrade_type] nie da się zbudować")
		TEST_ASSERT(initial(upgrade_type.icon_state) in icon_states(initial(upgrade_type.icon)), "Ulepszenie [upgrade_type] nie ma ikony [initial(upgrade_type.icon_state)]")
	TEST_ASSERT(length(upgrades) == 41, "Ulepszeń jest [length(upgrades)] zamiast 41")

/// Każde ulepszenie instaluje się w pasującym module, odmawia w niepasującym, a po wyjęciu zdejmuje narzędzia
/datum/unit_test/aquila_cyborg_upgrades

/datum/unit_test/aquila_cyborg_upgrades/Run()
	// ulepszenie => list(pasujący moduł, niepasujący moduł albo null, gdy pasuje do wszystkich)
	var/list/cases = list(
		/obj/item/borg/upgrade/aquila/toggle/magnetic_traction = list(/obj/item/robot_module/standard, null),
		/obj/item/borg/upgrade/aquila/power_saver = list(/obj/item/robot_module/research, null),
		/obj/item/borg/upgrade/aquila/power_connector = list(/obj/item/robot_module/exploration, null),
		/obj/item/borg/upgrade/aquila/gps = list(/obj/item/robot_module/medical, null),
		/obj/item/borg/upgrade/aquila/toggle/autocleaner = list(/obj/item/robot_module/butler, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/inducer = list(/obj/item/robot_module/engineering, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/lightreplacer = list(/obj/item/robot_module/engineering, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/bluespace_rped = list(/obj/item/robot_module/research, /obj/item/robot_module/miner),
		/obj/item/borg/upgrade/aquila/engineering_omnitool = list(/obj/item/robot_module/engineering, /obj/item/robot_module/research),
		/obj/item/borg/upgrade/aquila/nightvision_mesons = list(/obj/item/robot_module/miner, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/science_circuits = list(/obj/item/robot_module/research, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/xenobiology = list(/obj/item/robot_module/research, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/anomaly_vision = list(/obj/item/robot_module/research, /obj/item/robot_module/miner),
		/obj/item/borg/upgrade/aquila/advanced_analyzer = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/surgical_omnitool = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/advanced_surgery = list(/obj/item/robot_module/medical, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/organ_synthesizer = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/blood_synthesizer = list(/obj/item/robot_module/medical, /obj/item/robot_module/miner),
		/obj/item/borg/upgrade/aquila/holo_stretcher = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/breathing_bag = list(/obj/item/robot_module/medical, /obj/item/robot_module/security),
		/obj/item/borg/upgrade/aquila/chemistry_kit = list(/obj/item/robot_module/medical, /obj/item/robot_module/cargo),
		/obj/item/borg/upgrade/aquila/rescue_kit = list(/obj/item/robot_module/medical, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/medigripper = list(/obj/item/robot_module/medical, /obj/item/robot_module/cargo),
		/obj/item/borg/upgrade/aquila/chemistry_gripper = list(/obj/item/robot_module/medical, /obj/item/robot_module/research),
		/obj/item/borg/upgrade/aquila/bluespace_beaker = list(/obj/item/robot_module/medical, /obj/item/robot_module/butler),
		/obj/item/borg/upgrade/aquila/spectro_scanner = list(/obj/item/robot_module/medical, /obj/item/robot_module/research),
		/obj/item/borg/upgrade/aquila/advanced_cutter = list(/obj/item/robot_module/miner, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/ore_processor = list(/obj/item/robot_module/exploration, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/nightvision = list(/obj/item/robot_module/exploration, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/toggle/floodlight = list(/obj/item/robot_module/exploration, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/cargo_teleporter = list(/obj/item/robot_module/cargo, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/paperwork_kit = list(/obj/item/robot_module/cargo, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/lethal_unlock = list(/obj/item/robot_module/security, /obj/item/robot_module/peacekeeper),
		/obj/item/borg/upgrade/aquila/bola_launcher = list(/obj/item/robot_module/peacekeeper, /obj/item/robot_module/detective),
		/obj/item/borg/upgrade/aquila/toggle/personal_shield = list(/obj/item/robot_module/security, /obj/item/robot_module/janitor),
		/obj/item/borg/upgrade/aquila/forensic_scanner = list(/obj/item/robot_module/brobocop, /obj/item/robot_module/medical),
		/obj/item/borg/upgrade/aquila/noir = list(/obj/item/robot_module/detective, /obj/item/robot_module/security),
		/obj/item/borg/upgrade/aquila/plunger = list(/obj/item/robot_module/janitor, /obj/item/robot_module/butler),
		/obj/item/borg/upgrade/aquila/push_broom = list(/obj/item/robot_module/janitor, /obj/item/robot_module/engineering),
		/obj/item/borg/upgrade/aquila/cookbook = list(/obj/item/robot_module/butler, /obj/item/robot_module/janitor),
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

	// Pokój testowy nie jest wrogim okrętem: przy zielonym alarmie bez abordażu tryb zabójczy jest zablokowany
	TEST_ASSERT(!allowed_green, "Tryb zabójczy dozwolony przy zielonym alarmie")
	TEST_ASSERT(!lethal_at_green, "Przy zielonym alarmie broń przełączyła się na tryb zabójczy")
	TEST_ASSERT(!allowed_blue, "Tryb zabójczy dozwolony przy niebieskim alarmie")
	TEST_ASSERT(!fired && !lethal_after, "Po odwołaniu alarmu broń dalej strzela zabójczo")
	TEST_ASSERT(allowed_red, "Tryb zabójczy zablokowany przy czerwonym alarmie")
	TEST_ASSERT(lethal_at_red, "Przy czerwonym alarmie nie da się wybrać trybu zabójczego")

/// Abordaż to tylko wrogi okręt i wrodzy, nieskuci abordażyści: nie własny prom, planeta ani skuty jeniec
/datum/unit_test/aquila_cyborg_lethal_boarding

/datum/unit_test/aquila_cyborg_lethal_boarding/Run()
	var/old_level = GLOB.security_level
	GLOB.security_level = SEC_LEVEL_GREEN
	var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(/obj/item/robot_module/security)
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()

	// Własny prom (myśliwiec frakcji załogi) w locie
	var/obj/structure/overmap/small_craft/combat/light/craft = allocate(/obj/structure/overmap/small_craft/combat/light)
	craft.faction = main_ship ? main_ship.faction : "nanotrasen"
	cyborg.forceMove(craft)
	var/on_own_craft = aquila_cyborg_lethal_allowed(cyborg)
	// Ten sam kadłub, ale wrogiej frakcji
	craft.faction = "syndicate"
	var/on_enemy_craft = aquila_cyborg_lethal_allowed(cyborg)
	cyborg.forceMove(run_loc_floor_bottom_left)

	// Planeta ma własną frakcję „planet”, a i tak nie jest wrogim okrętem
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	var/planet_hostile = aquila_is_hostile_ship(planet)
	qdel(planet, TRUE)

	// Abordażysta KNPC na tym samym pokładzie: wrogi liczy się, skuty już nie
	var/mob/living/carbon/human/boarder = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	boarder.faction = list("Syndicate")
	boarder.AddComponent(/datum/component/knpc)
	var/with_boarder = aquila_cyborg_lethal_allowed(cyborg)
	boarder.handcuffed = new /obj/item/restraints/handcuffs(boarder)
	boarder.update_handcuffed()
	var/with_prisoner = aquila_cyborg_lethal_allowed(cyborg)
	qdel(boarder.GetComponent(/datum/component/knpc))
	GLOB.security_level = old_level

	TEST_ASSERT(!on_own_craft, "Tryb zabójczy odblokował się na własnym promie przy zielonym alarmie")
	TEST_ASSERT(!planet_hostile, "Planeta liczy się jako wrogi okręt")
	if(main_ship)
		TEST_ASSERT(on_enemy_craft, "Tryb zabójczy zablokowany na pokładzie wrogiego okrętu")
	TEST_ASSERT(with_boarder, "Tryb zabójczy zablokowany przy wrogim abordażyście na pokładzie")
	TEST_ASSERT(!with_prisoner, "Skuty jeniec KNPC odblokował tryb zabójczy")

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

/// Narzędzia z nową logiką robią to, co mają: tabletki, sztabki, krew, teleport skrzyni, tarcza, oszczędzanie energii
/datum/unit_test/aquila_cyborg_tools

/datum/unit_test/aquila_cyborg_tools/Run()
	var/mob/living/silicon/robot/chemist = aq_cyborg_with_module(/obj/item/robot_module/medical)
	chemist.cell.charge = chemist.cell.maxcharge
	var/obj/item/borg/upgrade/aquila/chemistry_kit/chem_kit = allocate(/obj/item/borg/upgrade/aquila/chemistry_kit)
	TEST_ASSERT(chem_kit.action(chemist, chemist), "Zestaw chemiczny nie wszedł do modułu medycznego")
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

	// Zestaw ratowniczy daje cały sprzęt dawnego modułu Ratowniczego
	var/obj/item/borg/upgrade/aquila/rescue_kit/rescue_kit = allocate(/obj/item/borg/upgrade/aquila/rescue_kit)
	TEST_ASSERT(rescue_kit.action(chemist, chemist), "Zestaw ratowniczy nie wszedł do modułu medycznego")
	for(var/rescue_tool in rescue_kit.aq_items)
		TEST_ASSERT(chemist.aq_find_module_item(rescue_tool), "Zestaw ratowniczy nie dał [rescue_tool]")

	// Specjalizacja Botanika daje somatopromiennik i zabiera go po wyjęciu
	var/mob/living/silicon/robot/gardener = aq_cyborg_with_module(/obj/item/robot_module/butler)
	var/obj/item/borg/upgrade/speciality/botany/botany = allocate(/obj/item/borg/upgrade/speciality/botany)
	TEST_ASSERT(botany.action(gardener, gardener), "Specjalizacja Botanika nie weszła do modułu usługowego")
	botany.forceMove(gardener)
	gardener.upgrades += botany
	TEST_ASSERT(gardener.aq_find_module_item(/obj/item/gun/energy/floragun/cyborg), "Specjalizacja Botanika nie dała somatopromiennika")
	TEST_ASSERT(botany.deactivate(gardener, gardener), "Specjalizacja Botanika nie dała się wyjąć")
	TEST_ASSERT(!gardener.aq_find_module_item(/obj/item/gun/energy/floragun/cyborg), "Somatopromiennik został po wyjęciu specjalizacji")

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
	var/mob/living/silicon/robot/miner = aq_cyborg_with_module(/obj/item/robot_module/miner)
	miner.cell.charge = miner.cell.maxcharge
	var/obj/item/borg/upgrade/aquila/ore_processor/furnace_upgrade = allocate(/obj/item/borg/upgrade/aquila/ore_processor)
	TEST_ASSERT(furnace_upgrade.action(miner, miner), "Przenośna huta nie weszła do modułu górniczego")
	var/obj/item/storage/bag/ore/ore_bag = miner.aq_find_module_item(/obj/item/storage/bag/ore)
	var/obj/item/stack/ore/iron/ore = new(ore_bag, 5)
	var/obj/item/borg/ore_processor/furnace = miner.aq_find_module_item(/obj/item/borg/ore_processor)
	TEST_ASSERT(furnace.aq_smelt(miner) == 5, "Przenośna huta nie przetopiła 5 rudy")
	TEST_ASSERT(QDELETED(ore), "Ruda została w torbie")
	var/obj/item/stack/sheet/iron/sheets = locate() in get_turf(miner)
	TEST_ASSERT(sheets?.amount == 5, "Huta nie dała 5 sztabek żelaza")
	qdel(sheets)

	// Teleporter ładunku
	var/mob/living/silicon/robot/porter = aq_cyborg_with_module(/obj/item/robot_module/cargo)
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

/// Miotła cyborga to nasza miotła: użyta w ręce zamiata w ruchu (jak chwycona oburącz), po ponownym użyciu przestaje
/datum/unit_test/aquila_cyborg_push_broom

/datum/unit_test/aquila_cyborg_push_broom/Run()
	var/mob/living/silicon/robot/janitor = aq_cyborg_with_module(/obj/item/robot_module/janitor)
	var/obj/item/borg/upgrade/aquila/push_broom/upgrade = allocate(/obj/item/borg/upgrade/aquila/push_broom)
	TEST_ASSERT(upgrade.action(janitor, janitor), "Miotła nie weszła do modułu porządkowego")
	var/obj/item/pushbroom/cyborg/broom = janitor.aq_find_module_item(/obj/item/pushbroom/cyborg)
	TEST_ASSERT(broom, "Ulepszenie nie dało miotły")
	TEST_ASSERT(!ISWIELDED(broom), "Miotła zamiata przed użyciem w ręce")
	broom.attack_self(janitor)
	TEST_ASSERT(ISWIELDED(broom), "Użyta w ręce miotła nie zamiata")
	// Krok na kafelek ze śmieciem przesuwa śmieć o kafelek dalej
	var/turf/start = run_loc_floor_bottom_left
	var/turf/middle = get_step(start, NORTH)
	var/turf/far = get_step(middle, NORTH)
	janitor.forceMove(start)
	var/obj/item/trash = allocate(/obj/item/trash/chips, middle)
	janitor.Move(middle, NORTH)
	TEST_ASSERT(get_turf(trash) == far, "Miotła nie zgarnęła śmiecia w ruchu")
	broom.attack_self(janitor)
	TEST_ASSERT(!ISWIELDED(broom) && !broom.sweeper, "Miotła zamiata po wyłączeniu")

/// Glock-13BR cyborga ochrony: ostra amunicja tylko przy czerwonym alarmie albo abordażu, zhakowany bez ograniczeń
/datum/unit_test/aquila_cyborg_glock_lock

/datum/unit_test/aquila_cyborg_glock_lock/Run()
	var/old_level = GLOB.security_level
	var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(/obj/item/robot_module/security)
	var/obj/item/gun/energy/printer/glock/glock = cyborg.aq_find_module_item(/obj/item/gun/energy/printer/glock)
	TEST_ASSERT(glock, "Moduł ochrony nie ma Glocka")
	TEST_ASSERT(!glock.aq_lethal_selected(), "Glock nie startuje na gumowych kulach")

	GLOB.security_level = SEC_LEVEL_GREEN
	var/allowed_green = aquila_cyborg_lethal_allowed(cyborg)
	glock.select_fire(cyborg)
	var/lethal_at_green = glock.aq_lethal_selected()

	GLOB.security_level = SEC_LEVEL_RED
	glock.select_fire(cyborg)
	var/lethal_at_red = glock.aq_lethal_selected()

	GLOB.security_level = SEC_LEVEL_GREEN
	var/fired = glock.process_fire(run_loc_floor_top_right, cyborg)
	var/lethal_after = glock.aq_lethal_selected()

	cyborg.emagged = TRUE
	glock.select_fire(cyborg)
	var/lethal_emagged = glock.aq_lethal_selected()
	cyborg.emagged = FALSE
	GLOB.security_level = old_level

	TEST_ASSERT(lethal_at_red, "Przy czerwonym alarmie Glock nie przełączył się na ostrą amunicję")
	TEST_ASSERT(lethal_emagged, "Zhakowany cyborg nie może strzelać ostrą amunicją")
	TEST_ASSERT(!allowed_green, "Ostra amunicja dozwolona przy zielonym alarmie")
	TEST_ASSERT(!lethal_at_green, "Przy zielonym alarmie Glock przełączył się na ostrą amunicję")
	TEST_ASSERT(!fired, "Glock strzelił ostrą amunicją po odwołaniu alarmu")
	TEST_ASSERT(!lethal_after, "Po odwołaniu alarmu Glock nie wrócił do gumowych kul")

/// Skiny modułów Aquili wzięte z robots.dmi (Roomba, Noir, Securitron...) zostają w pliku core, a nie lądują w pliku modułu bez tego stanu
/datum/unit_test/aquila_cyborg_skin_icons

/datum/unit_test/aquila_cyborg_skin_icons/Run()
	var/mob/living/silicon/robot/cyborg = allocate(/mob/living/silicon/robot)
	var/obj/item/robot_module/old_module = cyborg.module
	var/list/crew_modules = list()
	aquila_add_cyborg_modules(crew_modules)
	for(var/key in crew_modules)
		var/module_type = crew_modules[key]
		// Bez skina (moduł z wybieraka albo od admina): wygląd z pliku modułu Aquili
		var/obj/item/robot_module/plain = new module_type(cyborg)
		var/list/skins = plain.borg_skins.Copy()
		cyborg.icon = 'icons/mob/robots.dmi'
		plain.be_transformed_to(old_module, TRUE)
		TEST_ASSERT(plain.cyborg_base_icon in icon_states(cyborg.icon), "[module_type] bez skina: brak stanu [plain.cyborg_base_icon] w [cyborg.icon]")
		qdel(plain)
		// Każdy skin tak, jak ustawia go core po wyborze z kółka (SKIN_ICON albo zostaje robots.dmi z transform_to)
		for(var/skin in skins)
			var/list/details = skins[skin]
			var/obj/item/robot_module/skinned = new module_type(cyborg)
			skinned.cyborg_base_icon = details[SKIN_ICON_STATE]
			cyborg.icon = details[SKIN_ICON] || 'icons/mob/robots.dmi'
			skinned.be_transformed_to(old_module, TRUE)
			TEST_ASSERT(skinned.cyborg_base_icon in icon_states(cyborg.icon), "[module_type], skin [skin]: cyborg niewidzialny, brak stanu [skinned.cyborg_base_icon] w [cyborg.icon]")
			qdel(skinned)

/// Event „Zagubiony cyborg” stawia uśpioną skorupę na statku
/datum/unit_test/aquila_lost_cyborg_event

/datum/unit_test/aquila_lost_cyborg_event/Run()
	var/list/before = list()
	for(var/spawner_name in GLOB.mob_spawners)
		for(var/obj/effect/mob_spawn/aquila_lost_cyborg/shell in GLOB.mob_spawners[spawner_name])
			before += shell
	var/datum/round_event/aquila_lost_cyborg/event = new(FALSE)
	event.kill()
	// W grze event zawsze ma control z runEvent (announce_to_ghosts czyta control.alert_observers)
	event.control = locate(/datum/round_event_control/aquila_lost_cyborg) in SSevents.control
	TEST_ASSERT(event.control, "Brak sterowania eventu zagubionego cyborga w SSevents")
	event.start()
	var/obj/effect/mob_spawn/aquila_lost_cyborg/new_shell
	for(var/spawner_name in GLOB.mob_spawners)
		for(var/obj/effect/mob_spawn/aquila_lost_cyborg/shell in GLOB.mob_spawners[spawner_name])
			if(!(shell in before))
				new_shell = shell
	TEST_ASSERT(new_shell, "Event zagubionego cyborga nie postawił skorupy")
	TEST_ASSERT(is_station_level(new_shell.z), "Skorupa zagubionego cyborga stoi poza statkiem")
	qdel(new_shell)

/// Ulepszenia: odmowa przed wyborem modułu, odmowa drugiego przełącznika tego samego typu, przełączniki gasną po zmianie modułu
/datum/unit_test/aquila_cyborg_upgrade_guards

/datum/unit_test/aquila_cyborg_upgrade_guards/Run()
	// Moduł domyślny znika przy wyborze modułu razem z narzędziami ulepszeń
	var/mob/living/silicon/robot/fresh = allocate(/mob/living/silicon/robot)
	var/obj/item/borg/upgrade/aquila/gps/early_gps = allocate(/obj/item/borg/upgrade/aquila/gps)
	TEST_ASSERT(!early_gps.action(fresh, fresh), "GPS zamontował się przed wyborem modułu")
	TEST_ASSERT(!fresh.aq_find_module_item(/obj/item/gps/cyborg), "GPS dodał narzędzie do modułu domyślnego")
	var/obj/item/borg/upgrade/aquila/toggle/magnetic_traction/early_traction = allocate(/obj/item/borg/upgrade/aquila/toggle/magnetic_traction)
	TEST_ASSERT(!early_traction.action(fresh, fresh), "Przyczepy zamontowały się przed wyborem modułu")
	TEST_ASSERT(!early_traction.owner && !early_traction.toggle_action, "Odrzucone przyczepy dały przycisk akcji")

	// Drugi naświetlacz odmawia, a lampa wraca do poprzedniej mocy po wyłączeniu
	var/mob/living/silicon/robot/explorer = aq_cyborg_with_module(/obj/item/robot_module/exploration)
	var/intensity_before = explorer.lamp_intensity
	var/obj/item/borg/upgrade/aquila/toggle/floodlight/light = allocate(/obj/item/borg/upgrade/aquila/toggle/floodlight)
	TEST_ASSERT(light.action(explorer, explorer), "Naświetlacz nie wszedł do modułu eksploracyjnego")
	light.forceMove(explorer)
	explorer.upgrades += light
	var/obj/item/borg/upgrade/aquila/toggle/floodlight/second_light = allocate(/obj/item/borg/upgrade/aquila/toggle/floodlight)
	TEST_ASSERT(!second_light.action(explorer, explorer), "Drugi naświetlacz dał się zamontować")
	light.aq_set_active(TRUE)
	light.aq_set_active(FALSE)
	TEST_ASSERT(explorer.lamp_intensity == intensity_before, "Lampa została na [explorer.lamp_intensity] po wyłączeniu naświetlacza")

	// Zmiana modułu kasuje magnesy, więc włączone przyczepy gasną i przestają pobierać energię
	var/mob/living/silicon/robot/walker = aq_cyborg_with_module(/obj/item/robot_module/standard)
	var/obj/item/borg/upgrade/aquila/toggle/magnetic_traction/traction = allocate(/obj/item/borg/upgrade/aquila/toggle/magnetic_traction)
	TEST_ASSERT(traction.action(walker, walker), "Przyczepy nie weszły do modułu standardowego")
	traction.forceMove(walker)
	walker.upgrades += traction
	traction.aq_set_active(TRUE)
	var/obj/item/robot_module/old_module = walker.module
	var/obj/item/robot_module/new_module = new /obj/item/robot_module/medical(walker)
	new_module.robot = walker
	new_module.be_transformed_to(old_module, TRUE)
	walker.module = new_module
	walker.update_module_innate()
	new_module.rebuild_modules()
	qdel(old_module)
	TEST_ASSERT(!traction.active, "Przyczepy zostały włączone po zmianie modułu")
	TEST_ASSERT(!walker.magpulse, "Po zmianie modułu zostały magnesy")

/// Detektyw: kreda się nie zużywa, a w module nie ma wyciora do luf działa
/datum/unit_test/aquila_cyborg_detective_tools

/datum/unit_test/aquila_cyborg_detective_tools/Run()
	var/mob/living/silicon/robot/detective = aq_cyborg_with_module(/obj/item/robot_module/detective)
	TEST_ASSERT(!detective.aq_find_module_item(/obj/item/swabber), "Moduł Detektywa ma wycior do luf działa")
	var/obj/item/toy/crayon/white/chalk/chalk = detective.aq_find_module_item(/obj/item/toy/crayon/white/chalk)
	TEST_ASSERT(chalk, "Moduł Detektywa nie ma kredy")
	for(var/i in 1 to 60)
		TEST_ASSERT(chalk.use_charges(detective, 1), "Kreda cyborga skończyła się po [i - 1] użyciach")
		chalk.check_empty(detective)
	TEST_ASSERT(!QDELETED(chalk) && (chalk in detective.module.modules), "Kreda cyborga zniknęła z modułu")

/// Holonosze złożone przez człowieka gasną i wracają do doku cyborga, zamiast dawać człowiekowi nowy pełny dok
/datum/unit_test/aquila_cyborg_holo_stretcher

/datum/unit_test/aquila_cyborg_holo_stretcher/Run()
	var/mob/living/silicon/robot/medic = aq_cyborg_with_module(/obj/item/robot_module/medical)
	var/obj/item/borg/upgrade/aquila/holo_stretcher/upgrade = allocate(/obj/item/borg/upgrade/aquila/holo_stretcher)
	TEST_ASSERT(upgrade.action(medic, medic), "Holonosze nie weszły do modułu medycznego")
	var/obj/item/roller/robo/holo/dock = medic.aq_find_module_item(/obj/item/roller/robo/holo)
	var/turf/spot = run_loc_floor_top_right
	var/obj/structure/bed/roller/holo/bed = dock.loaded
	dock.deploy_roller(medic, spot)
	TEST_ASSERT(bed.loc == spot && !dock.loaded, "Holonosze się nie rozłożyły")
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, spot)
	usr = helper
	bed.MouseDrop(helper)
	usr = null
	TEST_ASSERT(QDELETED(bed), "Człowiek nie złożył holonoszy")
	for(var/obj/item/held in helper.held_items)
		TEST_ASSERT(!istype(held, /obj/item/roller), "Złożone holonosze dały człowiekowi [held]")
	TEST_ASSERT(!(locate(/obj/item/roller) in spot), "Złożone holonosze zostawiły złożone nosze na podłodze")
	TEST_ASSERT(istype(dock.loaded, /obj/structure/bed/roller/holo), "Zgaszone holonosze nie wróciły do doku cyborga")

/// Kabel zasilania daje tyle, ile zabrał z APC, a oszczędzacz nie działa przy przekazywaniu energii (bez energii z niczego)
/datum/unit_test/aquila_cyborg_power_transfer

/datum/unit_test/aquila_cyborg_power_transfer/Run()
	var/mob/living/silicon/robot/cyborg = aq_cyborg_with_module(/obj/item/robot_module/engineering)
	cyborg.aq_power_coefficient = 0.7 // oszczędzacz energii
	var/obj/item/stock_parts/cell/own_cell = cyborg.cell
	own_cell.charge = own_cell.maxcharge / 2

	// APC z 30% ładunku i progiem 25%: do wzięcia jest tylko 5% jego pojemności
	var/obj/machinery/power/apc/apc = allocate(/obj/machinery/power/apc, run_loc_floor_top_right)
	apc.end_processing()
	if(apc.terminal)
		apc.terminal.master = null
		QDEL_NULL(apc.terminal)
	QDEL_NULL(apc.cell)
	apc.cell = new /obj/item/stock_parts/cell/high(apc)
	apc.cell.charge = apc.cell.maxcharge * 0.3
	var/obj/item/borg/charger/aquila_connector/connector = allocate(/obj/item/borg/charger/aquila_connector)
	var/apc_before = apc.cell.charge
	var/cyborg_before = own_cell.charge
	var/got = connector.aq_draw(cyborg, apc)
	var/apc_lost = apc_before - apc.cell.charge
	var/cyborg_gained = own_cell.charge - cyborg_before
	TEST_ASSERT(got > 0 && got == apc_lost, "Kabel zgłosił [got] przy poborze [apc_lost] z APC")
	TEST_ASSERT(cyborg_gained == apc_lost, "Cyborg dostał [cyborg_gained], a APC straciło [apc_lost]")

	// Induktor: cyborg traci dokładnie tyle, ile dostało ogniwo, mimo oszczędzacza
	var/obj/item/inducer/cyborg/inducer = allocate(/obj/item/inducer/cyborg)
	inducer.cell = own_cell
	var/obj/item/stock_parts/cell/target = allocate(/obj/item/stock_parts/cell/high)
	target.charge = 0
	cyborg_before = own_cell.charge
	inducer.induce(target, 1)
	inducer.cell = null
	TEST_ASSERT(target.charge > 0, "Induktor nie naładował ogniwa")
	TEST_ASSERT(cyborg_before - own_cell.charge == target.charge, "Induktor zabrał cyborgowi [cyborg_before - own_cell.charge] za [target.charge] energii")
	TEST_ASSERT(!cyborg.aq_power_transfers, "Licznik przekazywania energii nie wrócił do zera")
	// Zużycie własne dalej z oszczędzaczem
	cyborg_before = own_cell.charge
	own_cell.use(1000)
	TEST_ASSERT(round(cyborg_before - own_cell.charge) == 700, "Oszczędzacz przestał działać przy zużyciu własnym")

	// Ogniwo wyjęte w trakcie pobierania: cykl kończy się bez błędu
	cyborg.cell = null
	TEST_ASSERT(!connector.aq_draw(cyborg, apc), "Kabel pobrał energię do cyborga bez ogniwa")
	cyborg.cell = own_cell

#undef TEST_ASSERT
