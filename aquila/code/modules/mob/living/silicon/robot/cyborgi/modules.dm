// AQUILA - nowe moduły cyborgów (wzorowane na modułach z Baystation12, Aurory, CEV-Eris, Goonstation, Polarisa i Citadel RP).
// Zestawy narzędzi są przełożone na nasze przedmioty; brakujące zastępują najbliższe nasze (opis w raporcie PR-a).
// Skiny portowane do aquila/icons/mob/silicon/robots_aquila_modules.dmi (źródła: ATTRIBUTION_cyborgi.md).

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
	borg_skins = list(
		"Droid" = list(SKIN_ICON_STATE = "aq_sci_droid", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Dron" = list(SKIN_ICON_STATE = "aq_sci_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Sleek" = list(SKIN_ICON_STATE = "aq_sci_sleek", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Ciężki" = list(SKIN_ICON_STATE = "aq_sci_heavy", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Roomba" = list(SKIN_ICON_STATE = "zoomba_sci"),
	)

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
		/obj/item/evidencebag,
		/obj/item/evidencebag,
		/obj/item/reagent_containers/spray/cyborg/luminol,
		/obj/item/barrier_tape_roll,
		/obj/item/toy/crayon/white/chalk/cyborg,
		/obj/item/holosign_creator/detective,
		/obj/item/pen/cyborg,
		/obj/item/crowbar/cyborg)
	emag_modules = list(/obj/item/borg/stun)
	cyborg_base_icon = "aq_det_drone"
	aq_base_icon_file = AQ_CYBORG_ICON_MODULES
	moduleselect_icon = "security"
	hat_offset = -4
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
	borg_skins = list(
		"BroBot" = list(SKIN_ICON_STATE = "aq_bro_brobot", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Bro" = list(SKIN_ICON_STATE = "brobot", SKIN_LIGHT_KEY = "service"),
		"Securitron" = list(SKIN_ICON_STATE = "securitron"),
		"Woody" = list(SKIN_ICON_STATE = "woody"),
	)

/obj/item/robot_module/brobocop/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Brobocop pilnuje papierów: akt, mandatów i taśmy. Nadal przestrzegasz swoich praw, a NIE prawa kosmicznego.</span>")
