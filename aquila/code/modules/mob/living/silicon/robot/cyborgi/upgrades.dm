// AQUILA - nowe ulepszenia cyborgów. Źródła mechanik w komentarzach nad typami (tg, Monkestation, Yogstation, Paradise,
// SS220, Goonstation, /vg/station, Baystation12, Chaotic Onyx, CHOMPStation, Skyrat/Nova Sector, Tegustation).
// Ulepszenie z narzędziami dodaje je do modułu, a zastąpione narzędzia oddaje po wyjęciu ulepszenia.

#define AQ_BORG_ENGINEERING list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur)
#define AQ_BORG_MEDICAL list(/obj/item/robot_module/medical, /obj/item/robot_module/syndicate_medical)
#define AQ_BORG_MINING list(/obj/item/robot_module/miner, /obj/item/robot_module/exploration)
#define AQ_BORG_SECURITY list(/obj/item/robot_module/security, /obj/item/robot_module/peacekeeper)

/mob/living/silicon/robot
	/// AQUILA: mnożnik zużycia energii z ogniwa (oszczędzacz energii)
	var/aq_power_coefficient = 1
	/// AQUILA: włączona osobista tarcza
	var/obj/item/borg/upgrade/aquila/toggle/personal_shield/aq_personal_shield
	/// AQUILA: od kiedy wolno użyć kolejnego pakietu doładowania
	var/aq_recharge_pack_ready = 0

// ---------------------------------------------------------------- Podstawa: ulepszenie dodające narzędzia

/obj/item/borg/upgrade/aquila
	name = "ulepszenie cyborga"
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	/// Narzędzia dodawane do modułu; pierwsze decyduje, czy ulepszenie już jest (drugie ulepszenie tego typu odmawia)
	var/list/aq_items = list()
	/// Dokładne typy narzędzi, które ulepszenie zastępuje (wracają po wyjęciu)
	var/list/aq_replaces = list()
	/// Moduły, do których ulepszenie nie pasuje mimo module_type
	var/list/aq_excluded_modules = list()
	/// Dodane przedmioty (do zdjęcia przy wyjęciu)
	var/list/obj/item/aq_added = list()
	/// Typy usuniętych narzędzi (do przywrócenia)
	var/list/aq_removed = list()

/obj/item/borg/upgrade/aquila/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	if(is_type_in_list(R.module, aq_excluded_modules))
		to_chat(user, "<span class='warning'>[src] nie pasuje do modułu „[R.module.name]”.</span>")
		return FALSE
	if(length(aq_items))
		var/obj/item/first = aq_items[1]
		if(R.aq_find_module_item(first))
			to_chat(user, "<span class='warning'>Ta jednostka ma już [initial(first.name)].</span>")
			return FALSE
	aq_removed = list()
	for(var/replaced_type in aq_replaces)
		for(var/obj/item/module_item in R.module.modules.Copy())
			if(module_item.type == replaced_type)
				R.module.remove_module(module_item, TRUE)
				aq_removed += replaced_type
	aq_added = list()
	for(var/item_type in aq_items)
		if(item_type != aq_items[1] && R.aq_find_module_item(item_type))
			continue
		aq_added += R.aq_add_module_item(item_type)
	return TRUE

/obj/item/borg/upgrade/aquila/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	for(var/obj/item/added as anything in aq_added)
		if(!QDELETED(added) && R.module && (added in R.module.modules))
			R.module.remove_module(added, TRUE)
	aq_added = list()
	// Po resecie modułu nie ma już czego przywracać
	if(R.module && R.module.type != /obj/item/robot_module)
		for(var/restored_type in aq_removed)
			R.aq_add_module_item(restored_type)
	aq_removed = list()

/obj/item/borg/upgrade/aquila/Destroy()
	aq_added = null
	return ..()

// ---------------------------------------------------------------- Podstawa: ulepszenie przełączane przyciskiem akcji

/datum/action/item_action/aquila_borg_toggle
	name = "Przełącz ulepszenie"
	button_icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/aquila/toggle
	/// Czy działa
	var/active = FALSE
	/// Cyborg z tym ulepszeniem
	var/mob/living/silicon/robot/owner
	/// Koszt energii na sekundę, gdy włączone
	var/charge_per_second = 0
	var/datum/action/item_action/aquila_borg_toggle/toggle_action

/obj/item/borg/upgrade/aquila/toggle/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	owner = R
	toggle_action = new(src)
	toggle_action.name = "Przełącz: [name]"
	toggle_action.icon_icon = icon
	toggle_action.button_icon_state = icon_state
	toggle_action.Grant(R)

/obj/item/borg/upgrade/aquila/toggle/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	if(active)
		aq_set_active(FALSE)
	toggle_action?.Remove(R)
	QDEL_NULL(toggle_action)
	owner = null

/obj/item/borg/upgrade/aquila/toggle/Destroy()
	if(active)
		aq_set_active(FALSE)
	QDEL_NULL(toggle_action)
	owner = null
	return ..()

/obj/item/borg/upgrade/aquila/toggle/ui_action_click(mob/user, datum/actiontype)
	if(user != owner || owner.stat == DEAD)
		return
	if(!active && owner.cell?.charge < AQ_BORG_MIN_CHARGE)
		balloon_alert(owner, "za mało energii!")
		return
	aq_set_active(!active)
	balloon_alert(owner, "[name]: [active ? "włączone" : "wyłączone"]")

/// Włącza albo wyłącza działanie
/obj/item/borg/upgrade/aquila/toggle/proc/aq_set_active(state)
	if(state == active || !owner)
		return
	active = state
	if(active)
		aq_enable(owner)
		if(charge_per_second)
			START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
		aq_disable(owner)

/obj/item/borg/upgrade/aquila/toggle/process(delta_time)
	if(!active || QDELETED(owner) || owner.stat == DEAD || !owner.aq_use_charge(charge_per_second * delta_time))
		aq_set_active(FALSE)
		return PROCESS_KILL

/obj/item/borg/upgrade/aquila/toggle/proc/aq_enable(mob/living/silicon/robot/R)
	return

/obj/item/borg/upgrade/aquila/toggle/proc/aq_disable(mob/living/silicon/robot/R)
	return

// ================================================================ Wszystkie moduły

/// Magnetyczne przyczepy (Goonstation „magnetic traction”): bez poślizgu i wysysania przy dekompresji, wolniejszy ruch
/obj/item/borg/upgrade/aquila/toggle/magnetic_traction
	name = "magnetyczne przyczepy cyborga"
	desc = "Przełączane elektromagnesy w podwoziu: cyborg nie ślizga się i nie daje się wyssać przez dziurę w kadłubie, ale porusza się wolniej i zużywa energię."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "magboots1"
	charge_per_second = 2

/obj/item/borg/upgrade/aquila/toggle/magnetic_traction/aq_enable(mob/living/silicon/robot/R)
	R.magpulse = TRUE
	R.add_movespeed_modifier(MOVESPEED_ID_AQ_BORG_TRACTION, update = TRUE, priority = 100, multiplicative_slowdown = 1.5)

/obj/item/borg/upgrade/aquila/toggle/magnetic_traction/aq_disable(mob/living/silicon/robot/R)
	R.magpulse = R.module?.magpulsing
	R.remove_movespeed_modifier(MOVESPEED_ID_AQ_BORG_TRACTION)

/// Oszczędzacz energii (Goonstation „power saver”): mniejsze zużycie energii z ogniwa
/obj/item/borg/upgrade/aquila/power_saver
	name = "oszczędzacz energii cyborga"
	desc = "Optymalizuje zasilanie modułów i napędu: cyborg zużywa o 30% mniej energii z ogniwa."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"

/obj/item/borg/upgrade/aquila/power_saver/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	if(R.aq_power_coefficient < 1)
		to_chat(user, "<span class='warning'>Ta jednostka ma już oszczędzacz energii.</span>")
		return FALSE
	R.aq_power_coefficient = 0.7

/obj/item/borg/upgrade/aquila/power_saver/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		R.aq_power_coefficient = 1

/obj/item/stock_parts/cell/use(amount, force)
	if(amount > 0 && iscyborg(loc))
		var/mob/living/silicon/robot/cyborg = loc
		if(cyborg.cell == src)
			amount *= cyborg.aq_power_coefficient
	return ..()

/// Pakiet doładowania (Goonstation „recharge pack”): jednorazowo +15 000 ładunku, kolejny dopiero po 7 minutach
/obj/item/borg/upgrade/aquila/recharge_pack
	name = "pakiet doładowania cyborga"
	desc = "Jednorazowy pakiet: od razu dodaje 15 000 jednostek ładunku do ogniwa cyborga. Kolejny zadziała dopiero po 7 minutach."
	icon = 'icons/obj/module.dmi'
	icon_state = "cell"
	one_use = TRUE
	require_module = FALSE

/obj/item/borg/upgrade/aquila/recharge_pack/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	if(!R.cell)
		to_chat(user, "<span class='warning'>Ta jednostka nie ma ogniwa!</span>")
		return FALSE
	if(world.time < R.aq_recharge_pack_ready)
		to_chat(user, "<span class='warning'>Ogniwo jest jeszcze rozgrzane po poprzednim pakiecie ([DisplayTimeText(R.aq_recharge_pack_ready - world.time)]).</span>")
		return FALSE
	R.cell.give(15000)
	R.aq_recharge_pack_ready = world.time + 7 MINUTES
	R.diag_hud_set_borgcell()

/// Kabel zasilania (Monkestation „power connector”): ładowanie z APC i węzła sieci
/obj/item/borg/upgrade/aquila/power_connector
	name = "kabel zasilania cyborga"
	desc = "Kabel do ładowania z APC albo węzła sieci energetycznej, bez stacji ładującej."
	icon = 'icons/obj/module.dmi'
	icon_state = "charger_APC"
	aq_items = list(/obj/item/borg/charger/aquila_connector)

/// GPS cyborga (SS220/Monkestation): własny sygnał i lista innych sygnałów
/obj/item/borg/upgrade/aquila/gps
	name = "GPS cyborga"
	desc = "Wbudowany GPS z własnym sygnałem i listą innych sygnałów."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-b"
	aq_items = list(/obj/item/gps/cyborg)

/obj/item/borg/upgrade/aquila/gps/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gps/cyborg/gps in aq_added)
		gps.gpstag = "BORG[R.ident]"

/// Autoczyściciel (Yogstation „janitor autocleaner”, floor buffer z Paradise): czyści kafelek przy każdym kroku
/obj/item/borg/upgrade/aquila/toggle/autocleaner
	name = "autoczyściciel cyborga"
	desc = "Szczotki pod podwoziem czyszczą brud, krew i leżących przy każdym kroku, kosztem energii. Moduł porządkowy ma to wbudowane."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"
	charge_per_second = 1
	aq_excluded_modules = list(/obj/item/robot_module/janitor)

/obj/item/borg/upgrade/aquila/toggle/autocleaner/aq_enable(mob/living/silicon/robot/R)
	R.AddElement(/datum/element/cleaning)

/obj/item/borg/upgrade/aquila/toggle/autocleaner/aq_disable(mob/living/silicon/robot/R)
	if(!R.module?.clean_on_move)
		R.RemoveElement(/datum/element/cleaning)

// ================================================================ Inżynieria i budowa

/// Induktor (tg „inducer”)
/obj/item/borg/upgrade/aquila/inducer
	name = "induktor cyborga inżynieryjnego"
	desc = "Wbudowany induktor: ładuje APC, ogniwa urządzeń i egzoszkielety z ogniwa cyborga."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	module_type = AQ_BORG_ENGINEERING
	module_flags = BORG_MODULE_ENGINEERING
	aq_items = list(/obj/item/inducer/cyborg)

/// RPED bluespace (tg/Monkestation): zastępuje RPED cyborga i przejmuje jego części
/obj/item/borg/upgrade/aquila/bluespace_rped
	name = "RPED bluespace cyborga"
	desc = "Zastępuje RPED cyborga wersją bluespace: wymiana części z odległości i dużo większa pojemność."
	icon = 'icons/obj/storage.dmi'
	icon_state = "BS_RPED"
	module_type = list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur, /obj/item/robot_module/research)
	module_flags = BORG_MODULE_ENGINEERING
	aq_items = list(/obj/item/storage/part_replacer/bluespace/cyborg)
	aq_replaces = list(/obj/item/storage/part_replacer/cyborg)

/obj/item/borg/upgrade/aquila/bluespace_rped/action(mob/living/silicon/robot/R, user = usr)
	var/list/parts = list()
	var/obj/item/storage/part_replacer/cyborg/old_rped = R.aq_find_module_item(/obj/item/storage/part_replacer/cyborg)
	if(old_rped?.type == /obj/item/storage/part_replacer/cyborg)
		for(var/obj/item/part in old_rped.contents)
			part.forceMove(src)
			parts += part
	. = ..()
	var/obj/item/storage/part_replacer/new_rped = R.aq_find_module_item(/obj/item/storage/part_replacer/bluespace/cyborg)
	for(var/obj/item/part as anything in parts)
		part.forceMove(. && new_rped ? new_rped : (old_rped && !QDELETED(old_rped) ? old_rped : R.drop_location()))

/// Omni-tool inżynieryjny (tg)
/obj/item/borg/upgrade/aquila/engineering_omnitool
	name = "omni-tool inżynieryjny cyborga"
	desc = "Zastępuje śrubokręt, klucz, łom i przecinak jednym, szybszym narzędziem."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "multitool_cyborg"
	module_type = AQ_BORG_ENGINEERING
	module_flags = BORG_MODULE_ENGINEERING
	aq_items = list(/obj/item/borg/aquila_omnitool/engineering)
	aq_replaces = list(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg)

/// Noktowizyjne mezony (Yogstation)
/obj/item/borg/upgrade/aquila/nightvision_mesons
	name = "noktowizyjne mezony cyborga"
	desc = "Zastępuje widzenie mezonowe wersją z noktowizją: ściany i ruda widoczne także w ciemności."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "meson"
	module_type = list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur, /obj/item/robot_module/miner, /obj/item/robot_module/exploration)
	module_flags = BORG_MODULE_MINER
	aq_items = list(/obj/item/borg/sight/meson/aquila_nightvision)
	aq_replaces = list(/obj/item/borg/sight/meson)

// ================================================================ Nauka

/// Aparat naukowy: układy scalone (Monkestation)
/obj/item/borg/upgrade/aquila/science_circuits
	name = "aparat naukowy: układy scalone"
	desc = "Rozszerza aparat do płytek o części maszyn i komponenty układów scalonych, dokłada multitool układów."
	icon = 'icons/obj/module.dmi'
	icon_state = "integrated_circuit"
	module_type = list(/obj/item/robot_module/research)
	aq_items = list(/obj/item/borg/apparatus/circuit/aquila_science, /obj/item/multitool/circuit)
	aq_replaces = list(/obj/item/borg/apparatus/circuit)

/// Ksenobiologia (Monkestation)
/obj/item/borg/upgrade/aquila/xenobiology
	name = "zestaw ksenobiologiczny cyborga"
	desc = "Chwytak na ekstrakty, mikstury i małpie kostki oraz skaner śluzów dla cyborga naukowego."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	module_type = list(/obj/item/robot_module/research)
	aq_items = list(/obj/item/borg/apparatus/aquila/xenobio, /obj/item/slime_scanner)

/// Wzrok anomalii (CHOMPStation)
/obj/item/borg/upgrade/aquila/anomaly_vision
	name = "wzrok anomalii cyborga"
	desc = "Nakładka wzroku pokazująca anomalie, rdzenie anomalii, artefakty i źródła promieniowania przez ściany."
	icon = 'icons/obj/module.dmi'
	icon_state = "science"
	module_type = list(/obj/item/robot_module/research)
	aq_items = list(/obj/item/borg/sight/aquila_scanner/anomaly)

// ================================================================ Medycyna

/// Zaawansowany analizator zdrowia (Goonstation)
/obj/item/borg/upgrade/aquila/advanced_analyzer
	name = "zaawansowany analizator zdrowia cyborga"
	desc = "Zastępuje analizator zdrowia wersją, która pokazuje obrażenia części ciała, chemię i rany."
	icon = 'icons/obj/device.dmi'
	icon_state = "health_adv"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/healthanalyzer/advanced)
	aq_replaces = list(/obj/item/healthanalyzer)

/// Omni-tool chirurgiczny (tg), z nastawiaczem kości (był w usuniętym zaawansowanym module medycznym)
/obj/item/borg/upgrade/aquila/surgical_omnitool
	name = "omni-tool chirurgiczny cyborga"
	desc = "Zastępuje skalpel, hemostat, retraktor, kauter, piłę i wiertło jednym, szybszym narzędziem i dokłada nastawiacz kości."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/aquila_omnitool/surgical, /obj/item/bonesetter)
	aq_replaces = list(/obj/item/scalpel, /obj/item/hemostat, /obj/item/retractor, /obj/item/cautery, /obj/item/circular_saw, /obj/item/surgicaldrill)

/// Zaawansowane narzędzia chirurgiczne (Skyrat/Nova, /vg/): laserowy skalpel, mechaniczne szczypce, narzędzie przyżegające
/obj/item/borg/upgrade/aquila/advanced_surgery
	name = "zaawansowane narzędzia chirurgiczne cyborga"
	desc = "Zastępuje zwykłe narzędzia chirurgiczne laserowym skalpelem (skalpel i piła), mechanicznymi szczypcami (retraktor i hemostat) i narzędziem przyżegającym (wiertło i kauter)."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_a"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/scalpel/advanced, /obj/item/retractor/advanced, /obj/item/surgicaldrill/advanced)
	aq_replaces = list(/obj/item/scalpel, /obj/item/circular_saw, /obj/item/retractor, /obj/item/hemostat, /obj/item/surgicaldrill, /obj/item/cautery)

/// Syntezator organów (Chaotic Onyx)
/obj/item/borg/upgrade/aquila/organ_synthesizer
	name = "syntezator organów cyborga"
	desc = "Syntezuje proste narządy syntetyczne (serce, płuca, wątroba, żołądek) z energii ogniwa, powoli."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-c"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/organ_synthesizer)

/// Syntezator krwi (Chaotic Onyx)
/obj/item/borg/upgrade/aquila/blood_synthesizer
	name = "syntezator krwi cyborga"
	desc = "Napełnia worki krwią 0 Rh- z ogniwa cyborga, wolno i kosztem energii."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/blood_synthesizer)

/// Holograficzne nosze (Paradise) - zastępują dok łóżka
/obj/item/borg/upgrade/aquila/holo_stretcher
	name = "holograficzne nosze cyborga"
	desc = "Zastępuje dok łóżka na kółkach projektorem noszy z twardego światła."
	icon = 'icons/obj/beds_chairs/rollerbed.dmi'
	icon_state = "folded"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/roller/robo/holo)
	aq_replaces = list(/obj/item/roller/robo)

/// Worek oddechowy (Monkestation)
/obj/item/borg/upgrade/aquila/breathing_bag
	name = "worek oddechowy cyborga"
	desc = "Worek samorozprężalny do wentylacji nieoddychających ofiar dekompresji, także w masce gazowej."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "lungs-c"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/breathing_bag)

/// Chwytak medyczny (Yogstation)
/obj/item/borg/upgrade/aquila/medigripper
	name = "chwytak medyczny cyborga"
	desc = "Chwytak do tabletek, plastrów, butelek, strzykawek, worków z krwią i opatrunków."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/apparatus/aquila/medical)

/// Chwytak chemiczny (Nova Sector)
/obj/item/borg/upgrade/aquila/chemistry_gripper
	name = "chwytak chemiczny cyborga"
	desc = "Chwytak do zlewek, butelek, pojemników na tabletki i worków chemicznych."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/apparatus/aquila/chemistry)

/// Zlewka bluespace (SS220): aparat do zlewek ze zlewką 300 j.
/obj/item/borg/upgrade/aquila/bluespace_beaker
	name = "zlewka bluespace cyborga"
	desc = "Zastępuje aparat do zlewek takim, który trzyma zlewkę bluespace (300 j.)."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beakerbluespace"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/apparatus/beaker/bluespace)
	aq_replaces = list(/obj/item/borg/apparatus/beaker)

/// Zestaw chemiczny (Goonstation „ChemBot”, dawny moduł Chemiczny): mini-CheMaster i dozownik odczynników
/obj/item/borg/upgrade/aquila/chemistry_kit
	name = "zestaw chemiczny cyborga"
	desc = "Mini-CheMaster do tabletek, plastrów i butelek oraz mały dozownik podstawowych odczynników zasilany z ogniwa."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/chem_master, /obj/item/reagent_containers/borghypo/chem_dispenser)

/// Zestaw ratowniczy (Aurora/CEV-Eris „Rescue”, dawny moduł Ratowniczy): dopalacze i hydrauliczny rozwieracz drzwi
/obj/item/borg/upgrade/aquila/rescue_kit
	name = "zestaw ratowniczy cyborga"
	desc = "Dopalacze w podwoziu na szybki dojazd do rannych i hydrauliczny rozwieracz, który podważa także zasilane śluzy."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_pry"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/rescue_boosters, /obj/item/crowbar/cyborg/aquila_rescue)

/// Skaner widmowy (Goonstation)
/obj/item/borg/upgrade/aquila/spectro_scanner
	name = "skaner widmowy cyborga"
	desc = "Skaner spektroskopowy: skład odczynników w organizmie, jedzeniu i pojemnikach."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	module_type = AQ_BORG_MEDICAL
	module_flags = BORG_MODULE_MEDICAL
	aq_items = list(/obj/item/borg/spectro_scanner)

// ================================================================ Górnictwo i eksploracja

/// Zaawansowany przecinak plazmowy (Citadel/Yogstation)
/obj/item/borg/upgrade/aquila/advanced_cutter
	name = "zaawansowany przecinak plazmowy cyborga"
	desc = "Daje zaawansowany przecinak plazmowy (zamiast zwykłego, jeśli był): większy zasięg i obrażenia dla fauny."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "adv_plasmacutter"
	module_type = AQ_BORG_MINING
	module_flags = BORG_MODULE_MINER
	aq_items = list(/obj/item/gun/energy/plasmacutter/adv/cyborg)
	aq_replaces = list(/obj/item/gun/energy/plasmacutter/cyborg)

/// Przenośna huta (/vg/station)
/obj/item/borg/upgrade/aquila/ore_processor
	name = "przenośna huta cyborga"
	desc = "Przetapia rudę z torby w sztabki w terenie, wolniej niż huta i kosztem energii."
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher_lit"
	module_type = AQ_BORG_MINING
	module_flags = BORG_MODULE_MINER
	aq_items = list(/obj/item/borg/ore_processor)

/// Noktowizja (Chaotic Onyx)
/obj/item/borg/upgrade/aquila/nightvision
	name = "noktowizja cyborga"
	desc = "Przełączana noktowizja: ciemne wraki, planety nocą i statki bez zasilania."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "thermal"
	module_type = AQ_BORG_MINING
	module_flags = BORG_MODULE_MINER
	aq_items = list(/obj/item/borg/sight/aquila_nightvision)

/// Reflektor (Baystation12 „floodlight”): mocniejsza lampa za większy pobór energii
/obj/item/borg/upgrade/aquila/toggle/floodlight
	name = "reflektor cyborga"
	desc = "Mocny reflektor: lampa cyborga świeci dużo dalej, ale zużywa więcej energii."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight"
	module_type = AQ_BORG_MINING
	module_flags = BORG_MODULE_MINER
	/// Moc lampy przed włączeniem reflektora
	var/previous_intensity = 3

/obj/item/borg/upgrade/aquila/toggle/floodlight/aq_enable(mob/living/silicon/robot/R)
	previous_intensity = R.lamp_intensity
	R.lamp_intensity = 8
	if(R.lamp_enabled)
		R.set_light_range(R.lamp_intensity)
	else
		R.toggle_headlamp()

/obj/item/borg/upgrade/aquila/toggle/floodlight/aq_disable(mob/living/silicon/robot/R)
	R.lamp_intensity = previous_intensity
	if(R.lamp_enabled)
		R.set_light_range(R.lamp_intensity)

/// Teleporter ładunku (Skyrat-tg)
/obj/item/borg/upgrade/aquila/cargo_teleporter
	name = "teleporter ładunku cyborga"
	desc = "Wysyła skrzynię albo szafkę na wcześniej ustawiony cel, z długim czasem ładowania."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	module_type = list(/obj/item/robot_module/cargo, /obj/item/robot_module/exploration)
	aq_items = list(/obj/item/borg/cargo_teleporter)

/// Zestaw biurowy (Bay/Aurora „Clerical”, dawny moduł Biurowy): drukarka papieru i chwytak biurowy
/obj/item/borg/upgrade/aquila/paperwork_kit
	name = "zestaw biurowy cyborga"
	desc = "Drukarka papieru z tonera cyborga i chwytak do papieru, teczek, zdjęć i podkładek."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	module_type = list(/obj/item/robot_module/cargo)
	module_flags = BORG_MODULE_CARGO
	aq_items = list(/obj/item/borg/paper_dispenser, /obj/item/borg/apparatus/aquila/paperwork)

// ================================================================ Ochrona i śledztwo

/// Odblokowanie trybu zabójczego (Tegustation): broń z trybem zabójczym tylko przy czerwonym alarmie albo abordażu
/obj/item/borg/upgrade/aquila/lethal_unlock
	name = "odblokowanie trybu zabójczego"
	desc = "Daje cyborgowi ochrony broń energetyczną z trybem zabójczym, który działa tylko przy czerwonym alarmie albo w trakcie abordażu."
	icon = 'icons/obj/module.dmi'
	icon_state = "secmodschematic"
	module_type = list(/obj/item/robot_module/security)
	module_flags = BORG_MODULE_SECURITY
	aq_items = list(/obj/item/gun/energy/e_gun/aquila_cyborg_lethal)

/// Wyrzutnia bol (Tegustation)
/obj/item/borg/upgrade/aquila/bola_launcher
	name = "wyrzutnia bol energetycznych cyborga"
	desc = "Wyrzutnia bol z twardego światła zasilana z ogniwa: spowalnia i oplątuje uciekającego."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "dragnet"
	module_type = AQ_BORG_SECURITY
	module_flags = BORG_MODULE_SECURITY
	aq_items = list(/obj/item/gun/energy/aquila_bola_launcher)

/// Osobista tarcza (Goonstation „force shield”): każde trafienie zredukowane do 4 punktów kosztem ładunku
/obj/item/borg/upgrade/aquila/toggle/personal_shield
	name = "osobista tarcza cyborga"
	desc = "Pole siłowe, które ścina każde trafienie do 4 punktów obrażeń kosztem ładunku ogniwa (50 za każdy pochłonięty punkt). Gaśnie przy niskim stanie ogniwa."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade4"
	module_type = AQ_BORG_SECURITY
	module_flags = BORG_MODULE_SECURITY
	charge_per_second = 5
	/// Do ilu obrażeń tarcza ścina jedno trafienie
	var/damage_cap = 4
	/// Koszt ładunku za pochłonięty punkt
	var/charge_per_point = 50

/obj/item/borg/upgrade/aquila/toggle/personal_shield/aq_enable(mob/living/silicon/robot/R)
	R.aq_personal_shield = src
	R.update_icons()

/obj/item/borg/upgrade/aquila/toggle/personal_shield/aq_disable(mob/living/silicon/robot/R)
	if(R.aq_personal_shield == src)
		R.aq_personal_shield = null
	R.update_icons()

// update_icons() czyści nakładki, więc tarczę rysujemy po nim
/mob/living/silicon/robot/update_icons()
	. = ..()
	if(aq_personal_shield)
		add_overlay(mutable_appearance('icons/effects/effects.dmi', "shield-old"))

/// Zwraca obrażenia po tarczy
/obj/item/borg/upgrade/aquila/toggle/personal_shield/proc/aq_absorb(mob/living/silicon/robot/R, damage)
	if(!active || damage <= damage_cap)
		return damage
	var/absorbed = damage - damage_cap
	var/affordable = round(max(0, R.cell?.charge - AQ_BORG_MIN_CHARGE) / charge_per_point)
	absorbed = min(absorbed, affordable)
	if(absorbed <= 0)
		aq_set_active(FALSE)
		return damage
	R.cell.use(absorbed * charge_per_point)
	playsound(R, 'sound/weapons/tap.ogg', 30, TRUE)
	if(R.cell.charge <= AQ_BORG_MIN_CHARGE)
		aq_set_active(FALSE)
		to_chat(R, "<span class='warning'>Osobista tarcza gaśnie: za mało energii!</span>")
	return damage - absorbed

/mob/living/silicon/robot/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE)
	if(aq_personal_shield && !forced && damage > 0 && (damagetype == BRUTE || damagetype == BURN))
		damage = aq_personal_shield.aq_absorb(src, damage)
	return ..()

/// Skaner śledczy (/vg/station): daje skaner modułom ochrony bez detektywa (Detektyw ma go wbudowanego)
/obj/item/borg/upgrade/aquila/forensic_scanner
	name = "skaner śledczy cyborga"
	desc = "Wbudowany skaner śledczy: odciski, włókna, krew i ślady przedmiotów, z drukiem raportu."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensicnew"
	module_type = list(/obj/item/robot_module/security, /obj/item/robot_module/peacekeeper, /obj/item/robot_module/brobocop)
	module_flags = BORG_MODULE_SECURITY
	aq_items = list(/obj/item/detective_scanner)

/// N.O.I.R. (/vg/station)
/obj/item/borg/upgrade/aquila/noir
	name = "wzrok N.O.I.R. cyborga"
	desc = "Czarno-biały tryb wzroku, w którym krew, ślady i porzucone dowody są wyróżnione kolorem."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "securityhud"
	module_type = list(/obj/item/robot_module/detective)
	module_flags = BORG_MODULE_SECURITY
	aq_items = list(/obj/item/borg/sight/aquila_scanner/noir)

// ================================================================ Porządki i usługi

/// Przepychacz (tg)
/obj/item/borg/upgrade/aquila/plunger
	name = "przepychacz cyborga"
	desc = "Wbudowany przepychacz do zatkanych toalet, odpływów i kanalizacji."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "plunger"
	module_type = list(/obj/item/robot_module/janitor)
	module_flags = BORG_MODULE_JANITOR
	aq_items = list(/obj/item/plunger)

/// Eksperymentalna miotła (tg): nasza zwykła miotła w wersji dla cyborga
/obj/item/borg/upgrade/aquila/push_broom
	name = "eksperymentalna miotła cyborga"
	desc = "Wbudowana miotła: zgarnia śmieci z kafelka przed cyborgiem, także w ruchu (prosto do kosza, jeśli tam stoi)."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	module_type = list(/obj/item/robot_module/janitor)
	module_flags = BORG_MODULE_JANITOR
	aq_items = list(/obj/item/pushbroom/cyborg)

/// Książka kucharska (tg „cookbook”): nasz katalog przepisów w tablecie cyborga
/obj/item/borg/upgrade/aquila/cookbook
	name = "książka kucharska cyborga"
	desc = "Wgrywa do tabletu cyborga program „Książka kucharska” z przepisami i daje skrót do niego."
	icon = 'icons/obj/library.dmi'
	icon_state = "cooked_book"
	module_type = list(/obj/item/robot_module/butler)
	module_flags = BORG_MODULE_SPECIALITY
	aq_items = list(/obj/item/borg/cookbook)
	/// Program dodany przez to ulepszenie (do usunięcia przy wyjęciu)
	var/datum/computer_file/program/cookbook/installed_program

/obj/item/borg/upgrade/aquila/cookbook/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/computer_hardware/hard_drive/drive = R.modularInterface?.all_components[MC_HDD]
	if(drive && !drive.find_file_by_name("kucharz"))
		installed_program = new(drive)
		if(!drive.store_file(installed_program))
			QDEL_NULL(installed_program)

/obj/item/borg/upgrade/aquila/cookbook/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/computer_hardware/hard_drive/drive = R.modularInterface?.all_components[MC_HDD]
	if(installed_program && drive)
		drive.remove_file(installed_program)
	installed_program = null

#undef AQ_BORG_ENGINEERING
#undef AQ_BORG_MEDICAL
#undef AQ_BORG_MINING
#undef AQ_BORG_SECURITY
