// AQUILA - nowe moduły cyborgów (wzorowane na modułach z Baystation12, Aurory, CEV-Eris, Goonstation, Polarisa i Citadel RP).
// Zestawy narzędzi są przełożone na nasze przedmioty; brakujące zastępują najbliższe nasze (opis w raporcie PR-a).
// Skiny portowane do aquila/icons/mob/silicon/robots_aquila_modules.dmi (źródła: ATTRIBUTION_cyborgi.md).
// Moduły zaawansowane (Inżynieryjny, Medyczny, Górniczy) wybiera się ulepszeniem z badań, jak w Chaotic Onyx.

// ---------------------------------------------------------------- Naukowy (Bay/Aurora/Eris „Research”)

/obj/item/robot_module/research
	name = "Naukowy"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/borg/apparatus/circuit,
		/obj/item/borg/apparatus/beaker,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/analyzer,
		/obj/item/slime_scanner,
		/obj/item/xenoarchaeology_labeler,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/stack/cable_coil/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/sentinels_compromise)
	cyborg_base_icon = "aq_sci_droid"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "standard"
	hat_offset = -2
	aq_department_channel = RADIO_CHANNEL_SCIENCE
	borg_skins = list(
		"Droid" = list(SKIN_ICON_STATE = "aq_sci_droid", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Dron" = list(SKIN_ICON_STATE = "aq_sci_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Sleek" = list(SKIN_ICON_STATE = "aq_sci_sleek", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Ciężki" = list(SKIN_ICON_STATE = "aq_sci_heavy", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Roomba" = list(SKIN_ICON_STATE = "zoomba_sci"),
	)

// ---------------------------------------------------------------- Chemiczny (Goonstation „Science”/chemik)

/obj/item/robot_module/medical/chemistry
	name = "Chemiczny"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/borg/chem_master,
		/obj/item/reagent_containers/borghypo/chem_dispenser,
		/obj/item/borg/apparatus/aquila/chemistry,
		/obj/item/borg/apparatus/beaker,
		/obj/item/borg/apparatus/beaker/extra,
		/obj/item/borg/spectro_scanner,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/healthanalyzer)
	emag_modules = list(/obj/item/reagent_containers/borghypo/medical/hacked)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sentinels_compromise)
	cyborg_base_icon = "aq_chem_chembot"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "medical"
	can_be_pushed = TRUE
	hat_offset = 0
	borg_skins = list(
		"ChemBot" = list(SKIN_ICON_STATE = "aq_chem_chembot", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Normal" = list(SKIN_ICON_STATE = "medical"),
		"Arachne" = list(SKIN_ICON_STATE = "arachne"),
		"Sleek" = list(SKIN_ICON_STATE = "sleekmedic"),
		"Servbot" = list(SKIN_ICON_STATE = "servbot-medi"),
		"Roomba" = list(SKIN_ICON_STATE = "zoomba_med"),
	)

// ---------------------------------------------------------------- Chirurgiczny (Baystation12 „Surgeon”)

/obj/item/robot_module/medical/surgeon
	name = "Chirurgiczny"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/healthanalyzer,
		/obj/item/borg/sight/hud/med,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/surgical_processor,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/bonesetter,
		/obj/item/blood_filter,
		/obj/item/organ_storage,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical/bandage/cyborg,
		/obj/item/crowbar/cyborg)
	emag_modules = list(/obj/item/reagent_containers/borghypo/medical/hacked)
	cyborg_base_icon = "aq_surg_standard"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	borg_skins = list(
		"Standard" = list(SKIN_ICON_STATE = "aq_surg_standard", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Podstawowy" = list(SKIN_ICON_STATE = "aq_surg_basic", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Igły" = list(SKIN_ICON_STATE = "aq_surg_needles", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Needles" = list(SKIN_ICON_STATE = "needles"),
		"Gibbs" = list(SKIN_ICON_STATE = "gibbs"),
		"Eve" = list(SKIN_ICON_STATE = "eve"),
	)

// ---------------------------------------------------------------- Ratowniczy (Aurora/CEV-Eris „Rescue”)

/obj/item/robot_module/medical/rescue
	name = "Ratowniczy"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher,
		/obj/item/borg/rescue_boosters,
		/obj/item/roller/robo,
		/obj/item/crowbar/cyborg/aquila_rescue,
		/obj/item/holosign_creator/atmos,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/stack/medical/bandage/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/borg/cyborghug/medical)
	emag_modules = list(/obj/item/reagent_containers/borghypo/medical/hacked)
	cyborg_base_icon = "aq_resc_droid"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	borg_skins = list(
		"Droid" = list(SKIN_ICON_STATE = "aq_resc_droid", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Sleek" = list(SKIN_ICON_STATE = "aq_resc_sleek", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Ciężki" = list(SKIN_ICON_STATE = "aq_resc_heavy", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Dron" = list(SKIN_ICON_STATE = "aq_resc_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Roomba ERT" = list(SKIN_ICON_STATE = "zoomba_crisis"),
	)

// ---------------------------------------------------------------- Budowlany (Aurora/CEV-Eris/Goon „Construction”)

/obj/item/robot_module/engineering/construction
	name = "Budowlany"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher,
		/obj/item/borg/sight/meson,
		/obj/item/construction/rcd/borg,
		/obj/item/construction/rld/cyborg,
		/obj/item/borg/plating_repair,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/lightreplacer/cyborg,
		/obj/item/stack/sheet/iron/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "aq_cons_tread"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	magpulsing = TRUE
	borg_skins = list(
		"Gąsienice" = list(SKIN_ICON_STATE = "aq_cons_tread", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Landmate" = list(SKIN_ICON_STATE = "aq_cons_landmate", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Ciężki" = list(SKIN_ICON_STATE = "aq_cons_heavy", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Pająk" = list(SKIN_ICON_STATE = "aq_cons_spider", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"ConBot" = list(SKIN_ICON_STATE = "aq_cons_conbot", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Wall-e" = list(SKIN_ICON_STATE = "wall-e"),
	)

/// Budowlany ma dwa razy większe magazyny materiałów (Aurora: metal 80k, szkło 60k)
/obj/item/robot_module/engineering/construction/Initialize(mapload)
	. = ..()
	aq_scale_storages(2)

/obj/item/robot_module/engineering/construction/rebuild_modules()
	. = ..()
	aq_scale_storages(2)

// ---------------------------------------------------------------- Eksploracyjny (Polaris/CHOMP „Exploration”, Bay „Surveyor”)

/obj/item/robot_module/exploration
	name = "Eksploracyjny"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/kitchen/knife/combat/cyborg,
		/obj/item/flashlight/seclite,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/analyzer,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/stack/medical/bandage/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/storage/bag/ore/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "aq_expl_drone"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "miner"
	hat_offset = -4
	aq_department_channel = RADIO_CHANNEL_SUPPLY
	borg_skins = list(
		"Dron zwiadowczy" = list(SKIN_ICON_STATE = "aq_expl_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Eyebot" = list(SKIN_ICON_STATE = "aq_expl_eyebot", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Droid" = list(SKIN_ICON_STATE = "droid-miner"),
		"Kodiak" = list(SKIN_ICON_STATE = "kodiak-miner"),
		"Ishimura" = list(SKIN_ICON_STATE = "ishimura"),
	)
	/// Pogoda planet, której cyborg zwiadowczy się nie boi (rakotwórczy deszcz, burze śnieżne i piaskowe, promieniowanie)
	var/static/list/aq_planet_immunities = list("snow", "acid", "rad")

/obj/item/robot_module/exploration/aq_on_install(mob/living/silicon/robot/cyborg)
	cyborg.weather_immunities += aq_planet_immunities

/obj/item/robot_module/exploration/aq_on_remove(mob/living/silicon/robot/cyborg)
	for(var/immunity in aq_planet_immunities)
		cyborg.weather_immunities -= immunity

/obj/item/robot_module/exploration/do_transform_animation()
	..()
	to_chat(loc, "<span class='notice'>Moduł eksploracyjny jest szczelny i odporny na pogodę planet: deszcz, śnieżyce, burze piaskowe i promieniowanie. Ładuj się złączem z ładowarek promu albo stacji ładującej, zanim wyruszysz daleko.</span>")

// ---------------------------------------------------------------- Detektyw (Bay „Forensics”, nasz system detektywa)

/obj/item/robot_module/detective
	name = "Detektyw"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/borg/sight/hud/sec,
		/obj/item/detective_scanner,
		/obj/item/swabber,
		/obj/item/evidencebag,
		/obj/item/evidencebag,
		/obj/item/reagent_containers/spray/cyborg/luminol,
		/obj/item/barrier_tape_roll,
		/obj/item/toy/crayon/white/chalk,
		/obj/item/holosign_creator/detective,
		/obj/item/pen/cyborg,
		/obj/item/crowbar/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "aq_det_drone"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "security"
	hat_offset = -4
	aq_department_channel = RADIO_CHANNEL_SECURITY
	borg_skins = list(
		"Dron śledczy" = list(SKIN_ICON_STATE = "aq_det_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Eyebot" = list(SKIN_ICON_STATE = "aq_det_eyebot", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Noir" = list(SKIN_ICON_STATE = "peaceborg-noir"),
		"Noir czarno-biały" = list(SKIN_ICON_STATE = "peaceborg-noirbw"),
	)

/obj/item/robot_module/detective/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Moduł detektywa to śledztwo, nie egzekwowanie prawa. Nadal przestrzegasz swoich praw, a NIE prawa kosmicznego.</span>")

// ---------------------------------------------------------------- Brobocop (Goonstation)

/obj/item/robot_module/brobocop
	name = "Brobocop"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/borg/sight/hud/sec,
		/obj/item/borg/record_scanner,
		/obj/item/citationinator/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/barrier_tape_roll,
		/obj/item/pen/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "aq_bro_brobot"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "brobot"
	hat_offset = 0
	aq_department_channel = RADIO_CHANNEL_SECURITY
	borg_skins = list(
		"BroBot" = list(SKIN_ICON_STATE = "aq_bro_brobot", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Bro" = list(SKIN_ICON_STATE = "brobot", SKIN_LIGHT_KEY = "service"),
		"Securitron" = list(SKIN_ICON_STATE = "securitron"),
		"Woody" = list(SKIN_ICON_STATE = "woody"),
	)

/obj/item/robot_module/brobocop/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Brobocop pilnuje papierów: akt, mandatów i taśmy. Nadal przestrzegasz swoich praw, a NIE prawa kosmicznego.</span>")

// ---------------------------------------------------------------- Hydroponiczny (Bay „Cultivator”, Goon)

/obj/item/robot_module/hydroponics
	name = "Hydroponiczny"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/plant_scanner,
		/obj/item/cultivator,
		/obj/item/hatchet,
		/obj/item/shovel/spade,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/storage/bag/plants/portaseeder,
		/obj/item/gun/energy/floragun/cyborg,
		/obj/item/reagent_containers/spray/cyborg/plantbgone,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "aq_hydro_drone"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "hydroponics"
	hat_offset = -4
	aq_department_channel = RADIO_CHANNEL_SERVICE
	borg_skins = list(
		"Dron ogrodnik" = list(SKIN_ICON_STATE = "aq_hydro_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Hydrobot" = list(SKIN_ICON_STATE = "hydrobot"),
		"Roomba" = list(SKIN_ICON_STATE = "zoomba_green"),
	)

// ---------------------------------------------------------------- Biurowy (Bay/Aurora „Clerical”) - papierologia bez magazynu

/obj/item/robot_module/cargo/clerical
	name = "Biurowy"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/stamp,
		/obj/item/stamp/denied,
		/obj/item/pen/cyborg,
		/obj/item/clipboard/cyborg,
		/obj/item/borg/paper_dispenser,
		/obj/item/borg/apparatus/aquila/paperwork,
		/obj/item/hand_labeler/cyborg,
		/obj/item/crowbar/cyborg)
	emag_modules = list(/obj/item/stamp/chameleon)
	cyborg_base_icon = "aq_cler_service"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "service"
	canDispose = FALSE
	borg_skins = list(
		"Kelnerka" = list(SKIN_ICON_STATE = "aq_cler_service", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Domyślny" = list(SKIN_ICON_STATE = "aq_cler_service2", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Bogacz" = list(SKIN_ICON_STATE = "aq_cler_rich", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Kent" = list(SKIN_ICON_STATE = "toiletbot"),
	)

// ---------------------------------------------------------------- Magazynowy (Citadel RP „Logistics”) - zacisk i paczki bez papierologii

/obj/item/robot_module/cargo/logistics
	name = "Magazynowy"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher,
		/obj/item/borg/hydraulic_clamp/better,
		/obj/item/borg/hydraulic_clamp/mail,
		/obj/item/stack/package_wrap/cyborg,
		/obj/item/dest_tagger,
		/obj/item/export_scanner,
		/obj/item/crowbar/cyborg,
		/obj/item/wrench/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	can_be_pushed = FALSE
	borg_skins = list(
		"Technician" = list(SKIN_ICON_STATE = "cargoborg", SKIN_ICON = CYBORG_ICON_CARGO),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_cargo", SKIN_ICON = CYBORG_ICON_CARGO, SKIN_FEATURES = list(R_TRAIT_UNIQUEWRECK), SKIN_HAT_OFFSET = -13),
		"Noble" = list(SKIN_ICON_STATE = "noble-sup"),
		"Kodiak" = list(SKIN_ICON_STATE = "kodiak-miner"),
	)

// ---------------------------------------------------------------- Wielozadaniowy (Citadel RP „Multirole”)

/obj/item/robot_module/standard/multirole
	name = "Wielozadaniowy"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/weldingtool/mini,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/stack/medical/bandage/cyborg,
		/obj/item/mop/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/hand_labeler/cyborg,
		/obj/item/pen/cyborg)
	emag_modules = list(/obj/item/melee/transforming/energy/sword/cyborg)

// ---------------------------------------------------------------- Zaawansowane moduły (Chaotic Onyx), wybierane ulepszeniem z badań

/obj/item/robot_module/engineering/advanced
	name = "Zaawansowany inżynieryjny"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/borg/charger,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/borg/aquila_omnitool/engineering,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/storage/part_replacer/bluespace/cyborg,
		/obj/item/stack/sheet/iron/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/holosign_creator/atmos)

/obj/item/robot_module/engineering/advanced/Initialize(mapload)
	. = ..()
	aq_scale_storages(2)

/obj/item/robot_module/engineering/advanced/rebuild_modules()
	. = ..()
	aq_scale_storages(2)

/obj/item/robot_module/medical/advanced
	name = "Zaawansowany medyczny"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer/advanced,
		/obj/item/borg/charger,
		/obj/item/reagent_containers/borghypo/medical,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/borg/aquila_omnitool/surgical,
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/extinguisher/mini,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/bandage/cyborg,
		/obj/item/organ_storage,
		/obj/item/borg/lollipop)

/obj/item/robot_module/miner/advanced
	name = "Zaawansowany górniczy"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg/diamond,
		/obj/item/borg/charger,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gun/energy/plasmacutter/adv/cyborg,
		/obj/item/borg/ore_processor,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon)

