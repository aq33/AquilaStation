// AQUILA - skąd wziąć implanty i augmenty z wdrożenia robotyki: projekty i węzły techwebu (medycyna, R&D, ochrona),
// uplink i czarny rynek.

// ===========================================================================
// PROJEKTY: implanty w etui

/datum/design/aq_implantcase
	name = "Etui z implantem"
	desc = "Szklane etui z implantem."
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_implantcase/antirot
	name = "Etui z implantem Rotbusttec"
	desc = "Po śmierci nosiciela konserwuje ciało formaldehydem."
	id = "aq_implant_antirot"
	build_path = /obj/item/implantcase/aq_antirot

/datum/design/aq_implantcase/robotalk
	name = "Etui z tłumaczem maszynowym"
	desc = "Język binarny i kanał silikonów bez słuchawek."
	id = "aq_implant_robotalk"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/gold = 300)
	build_path = /obj/item/implantcase/aq_robotalk
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_implantcase/empshield
	name = "Etui z tarczą EMP"
	desc = "Pochłania impulsy elektromagnetyczne, zanim dotrą do ciała."
	id = "aq_implant_empshield"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 500, /datum/material/uranium = 500)
	build_path = /obj/item/implantcase/aq_empshield
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

// Implanty ochrony: tylko protolathe ochrony
/datum/design/aq_implantcase/access
	name = "Etui z implantem elektronicznego dostępu"
	desc = "Karta identyfikacyjna w ciele, osiem otwarć. Dostępy zapisuje się kartą przyłożoną do etui."
	id = "aq_implant_access"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/gold = 500)
	build_path = /obj/item/implantcase/aq_access
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_implantcase/iff
	name = "Etui z implantem swój-obcy"
	desc = "Pociski strzelców z tym samym implantem omijają nosiciela."
	id = "aq_implant_iff"
	build_path = /obj/item/implantcase/aq_iff
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_implantcase/tacmap
	name = "Etui z implantem mapy taktycznej"
	desc = "Hologram okrętu z pozycjami innych nosicieli."
	id = "aq_implant_tacmap"
	build_path = /obj/item/implantcase/aq_tacmap
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_implantcase/teleport_blocker
	name = "Etui z implantem uziemienia bluespace"
	desc = "Blokuje teleportację więźnia."
	id = "aq_implant_teleport_blocker"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/bluespace = 250)
	build_path = /obj/item/implantcase/aq_teleport_blocker
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

// ===========================================================================
// PROJEKTY: augmenty

/datum/design/aq_augment
	name = "Augment"
	desc = "Augment cybernetyczny."
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 400)
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/aq_augment/wire_interface
	name = "Implant interfejsu kabli"
	desc = "Przy hakowaniu widać funkcję każdego kabla."
	id = "aq_ci_wire_interface"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 400, /datum/material/gold = 400)
	build_path = /obj/item/organ/cyberimp/brain/aq_wire_interface
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/aq_augment/diagnostics
	name = "Procesor diagnostyczny"
	desc = "Raport o stanie własnego ciała na żądanie."
	id = "aq_ci_diagnostics"
	build_path = /obj/item/organ/cyberimp/brain/aq_diagnostics

/datum/design/aq_augment/jumpstarter
	name = "Rozrusznik OUN"
	desc = "Budzi nosiciela z utraty przytomności."
	id = "aq_ci_jumpstarter"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500, /datum/material/uranium = 300)
	build_path = /obj/item/organ/cyberimp/brain/aq_jumpstarter

/datum/design/aq_augment/emotional_manipulator
	name = "Manipulator emocji"
	desc = "Szczęście albo spokój na żądanie."
	id = "aq_ci_emotional_manipulator"
	build_path = /obj/item/organ/cyberimp/brain/aq_emotional_manipulator
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_augment/binoculars
	name = "Adaptacyjna lornetka"
	desc = "Przybliżanie obrazu w oczach."
	id = "aq_ci_binoculars"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000, /datum/material/silver = 400)
	build_path = /obj/item/organ/cyberimp/eyes/aq_binoculars

/datum/design/aq_augment/meson_eyes
	name = "Oczy mezonowe"
	desc = "Cybernetyczne oczy z widzeniem mezonowym."
	id = "aq_ci_meson_eyes"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000, /datum/material/silver = 300)
	build_path = /obj/item/organ/eyes/robotic/aq_meson
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/aq_augment/map
	name = "Implant mapy okrętu"
	desc = "Hologram okrętu w polu widzenia."
	id = "aq_ci_map"
	build_path = /obj/item/organ/cyberimp/eyes/aq_map

/datum/design/aq_augment/gustatorial
	name = "Ośrodek smaku"
	desc = "Analizator chemii w języku."
	id = "aq_ci_gustatorial"
	build_path = /obj/item/organ/cyberimp/aq_gustatorial
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/aq_augment/service_jack
	name = "Port serwisowy EMSI"
	desc = "Port do diagnozy augmentów i protez multitoolem."
	id = "aq_ci_service_jack"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 300, /datum/material/copper = 300)
	build_path = /obj/item/organ/cyberimp/aq_service_jack

/datum/design/aq_augment/health_scanner
	name = "Zintegrowany skaner zdrowia"
	desc = "Analizator zdrowia wysuwany z dłoni."
	id = "aq_ci_health_scanner"
	build_path = /obj/item/organ/cyberimp/arm/aq_health_scanner
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_augment/cyborg_analyzer
	name = "Wysuwany analizator cyborgów"
	desc = "Analizator cyborgów i protez w palcu."
	id = "aq_ci_cyborg_analyzer"
	build_path = /obj/item/organ/cyberimp/arm/aq_cyborg_analyzer

/datum/design/aq_augment/embedded
	name = "Moduł wbudowanego przedmiotu"
	desc = "Dowolny przedmiot zwykłego rozmiaru wysuwany z ręki."
	id = "aq_ci_embedded"
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500, /datum/material/silver = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/organ/cyberimp/arm/aq_embedded

/datum/design/aq_augment/climbing_hook
	name = "Implant haka wspinaczkowego"
	desc = "Hak z liną do wspinania się na wyższe piętro."
	id = "aq_ci_climbing_hook"
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 300, /datum/material/silver = 300)
	build_path = /obj/item/organ/cyberimp/arm/aq_climbing_hook
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/aq_augment/magboot
	name = "Implant magnetycznych stóp"
	desc = "Magbuty w nodze. Działa w parze: potrzebne dwa, śrubokręt przestawia stronę."
	id = "aq_ci_magboot"
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 300, /datum/material/silver = 500)
	build_path = /obj/item/organ/cyberimp/leg/aq_magboot
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/aq_augment/air_sac
	name = "Wewnętrzny system powietrza"
	desc = "Zapas powietrza w ciele, uzupełniany z otoczenia."
	id = "aq_ci_air_sac"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/plastic = 500)
	build_path = /obj/item/organ/cyberimp/chest/aq_air_sac
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/aq_augment/platelets
	name = "Fabryki płytek krwi"
	desc = "Prawie bez krwawienia, za to ryzyko zakrzepów."
	id = "aq_ci_platelets"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/plasma = 500)
	build_path = /obj/item/organ/cyberimp/chest/aq_platelets
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_augment/exoframe
	name = "Egzoszkielet nośny"
	desc = "Implant kręgosłupa: więcej zdrowia i siły."
	id = "aq_ci_exoframe"
	construction_time = 100
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 2000, /datum/material/silver = 1000, /datum/material/glass = 500)
	build_path = /obj/item/organ/cyberimp/chest/spinal/aq_exoframe

/datum/design/aq_augment/herculean
	name = "Grawitonowy implant kręgosłupa Herculean"
	desc = "Implant kręgosłupa: rzuty, wspinaczka, siła ciosów."
	id = "aq_ci_herculean"
	construction_time = 100
	materials = list(/datum/material/iron = 3000, /datum/material/titanium = 1500, /datum/material/silver = 1000, /datum/material/uranium = 1000)
	build_path = /obj/item/organ/cyberimp/chest/spinal/aq_herculean

/datum/design/aq_augment/ai_uplink
	name = "Mózg z łączem SI"
	desc = "Cybernetyczny mózg, przez który SI steruje w pełni zrobotyzowanym ciałem."
	id = "aq_ci_ai_uplink"
	construction_time = 150
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000, /datum/material/gold = 2000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/organ/brain/aq_ai_uplink
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/aq_augment/v1_arm_shell
	name = "Obudowa ramienia ze sprzężeniem wirowym"
	desc = "Implant ramienia, który odbija pociski. Do działania potrzebuje rdzenia anomalii wiru."
	id = "aq_ci_v1_arm_shell"
	construction_time = 100
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 2000, /datum/material/silver = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/aq_v1_arm_shell
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/aq_augment/tacvisor
	name = "Taktyczny wizjer IFF"
	desc = "Oczy z HUD-em ochrony i oceną zagrożenia, bez rozpoznawania twarzy."
	id = "aq_ci_tacvisor"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 500)
	build_path = /obj/item/organ/eyes/robotic/aq_tacvisor
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_augment/monitor_eye
	name = "Cyberoko z monitorem"
	desc = "Podgląd sieci kamer z wbudowanego monitora."
	id = "aq_ci_monitor_eye"
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000, /datum/material/silver = 500, /datum/material/gold = 300)
	build_path = /obj/item/organ/eyes/robotic/aq_monitor
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

// ===========================================================================
// WĘZŁY TECHWEBU

/datum/techweb_node/aq_crew_implants
	id = "aq_crew_implants"
	tech_tier = 4
	display_name = "Implanty załogi"
	description = "Implanty medyczne, łącznościowe i więzienne: konserwant pośmiertny, bezpiecznik przedawkowania, tłumacz maszynowy, tarcza EMP i zestaw ochrony."
	prereq_ids = list("subdermal_implants", "datatheory")
	design_ids = list(
		"aq_implant_antirot",
		"aq_implant_robotalk",
		"aq_implant_empshield",
		"aq_implant_access",
		"aq_implant_iff",
		"aq_implant_tacmap",
		"aq_implant_teleport_blocker",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/aq_augments
	id = "aq_augments"
	tech_tier = 4
	display_name = "Augmenty użytkowe"
	description = "Augmenty do pracy: interfejs kabli, diagnostyka, lornetka i mezony w oczach, ośrodek smaku, port serwisowy, narzędzia w rękach i magnesy w stopach."
	prereq_ids = list("cyber_implants", "robotics")
	design_ids = list(
		"aq_ci_wire_interface",
		"aq_ci_diagnostics",
		"aq_ci_binoculars",
		"aq_ci_meson_eyes",
		"aq_ci_map",
		"aq_ci_gustatorial",
		"aq_ci_service_jack",
		"aq_ci_health_scanner",
		"aq_ci_cyborg_analyzer",
		"aq_ci_climbing_hook",
		"aq_ci_magboot",
		"aq_ci_air_sac",
		"aq_ci_emotional_manipulator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/datum/techweb_node/aq_adv_augments
	id = "aq_adv_augments"
	tech_tier = 5
	display_name = "Zaawansowane augmenty"
	description = "Augmenty zmieniające ciało: implanty kręgosłupa, fabryki płytek, rozrusznik OUN, moduł wbudowanego przedmiotu, oczy ochrony i mózg z łączem SI."
	prereq_ids = list("aq_augments", "adv_cyber_implants", "adv_robotics")
	design_ids = list(
		"aq_ci_jumpstarter",
		"aq_ci_embedded",
		"aq_ci_platelets",
		"aq_ci_exoframe",
		"aq_ci_herculean",
		"aq_ci_tacvisor",
		"aq_ci_monitor_eye",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 6000

/datum/techweb_node/aq_anomaly_augments
	id = "aq_anomaly_augments"
	tech_tier = 6
	display_name = "Augmenty anomalii i łącza SI"
	description = "Ramię ze sprzężeniem wirowym (z rdzeniem anomalii wiru) i mózg z łączem SI, przez który SI steruje w pełni zrobotyzowanym ciałem."
	prereq_ids = list("aq_adv_augments", "ai")
	design_ids = list(
		"aq_ci_v1_arm_shell",
		"aq_ci_ai_uplink",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 8000

// ===========================================================================
// UPLINK

/obj/item/autosurgeon/syndicate/aq_single
	uses = 1

/obj/item/autosurgeon/syndicate/aq_single/tacvisor
	name = "podejrzany autochirurg (taktyczny wizjer IFF)"
	starting_organ = list(/obj/item/organ/eyes/robotic/aq_tacvisor)

/obj/item/autosurgeon/syndicate/aq_single/hacking_deck
	name = "podejrzany autochirurg (Binyat)"
	starting_organ = list(/obj/item/organ/cyberimp/brain/aq_hacking_deck)

/obj/item/autosurgeon/syndicate/aq_single/doorjack
	name = "podejrzany autochirurg (doorjack)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/aq_doorjack)

/obj/item/autosurgeon/syndicate/aq_single/sandevistan
	name = "podejrzany autochirurg (Sandevistan)"
	starting_organ = list(/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan)

/obj/item/autosurgeon/syndicate/aq_single/optical_camo
	name = "podejrzany autochirurg (kamuflaż optyczny)"
	starting_organ = list(/obj/item/organ/cyberimp/chest/aq_optical_camo)

/obj/item/autosurgeon/syndicate/aq_single/overclocker
	name = "podejrzany autochirurg (neuronowy podkręcacz)"
	starting_organ = list(/obj/item/organ/cyberimp/chest/spinal/aq_overclocker)

/obj/item/autosurgeon/syndicate/aq_single/shell_launcher
	name = "podejrzany autochirurg (wyrzutnia nabojów)"
	starting_organ = list(/obj/item/organ/cyberimp/arm/aq_shell_launcher)

/obj/item/autosurgeon/syndicate/aq_single/laser_eyes
	name = "podejrzany autochirurg (laserowe cyberoczy)"
	starting_organ = list(/obj/item/organ/eyes/robotic/aq_laser)

/datum/uplink_item/implants/aq_mindslave
	name = "Implant zniewolenia umysłu"
	desc = "Implanter, który czyni ofiarę twoim lojalnym sługą. Nie działa na osoby z implantem ochrony umysłu, a jego wszczepienie znosi zniewolenie. Na sobie nie zadziała."
	item = /obj/item/implanter/aq_mindslave
	cost = 10
	surplus = 20
	player_minimum = 20

/datum/uplink_item/implants/aq_camouflage
	name = "Eksperymentalny implant kamuflażu"
	desc = "Po włączeniu czyni cię prawie niewidocznym, dopóki nie wyłączysz go sam albo nie zrobi tego EMP."
	item = /obj/item/implanter/aq_camouflage
	cost = 7

/datum/uplink_item/implants/aq_syndicate_iff
	name = "Implant znacznika Syndykatu"
	desc = "Wieżyczki, boty i automaty Syndykatu uznają cię za swojego."
	item = /obj/item/implanter/aq_syndicate_iff
	cost = 2

/datum/uplink_item/implants/aq_shock
	name = "Implant mocy"
	desc = "Po włączeniu środkowy przycisk myszy razi cel błyskawicą z kabla pod twoimi stopami: w trybie walki parzy, poza nim męczy."
	item = /obj/item/implanter/aq_shock
	cost = 8

/datum/uplink_item/implants/aq_revenge
	name = "Implant zemsty"
	desc = "Po twojej śmierci razi prądem wszystkich w pobliżu."
	item = /obj/item/implanter/aq_revenge
	cost = 3

/datum/uplink_item/implants/aq_hijack
	name = "Implant przejęcia"
	desc = "Włam się do APC, a potem steruj maszynami w całym pomieszczeniu jak SI. Naraz tylko jedno pomieszczenie; EMP zrywa połączenie."
	item = /obj/item/implanter/aq_hijack
	cost = 12
	player_minimum = 20

/datum/uplink_item/implants/aq_spying
	name = "Implant szpiegowski"
	desc = "Wszczep go celowi: słyszysz to, co cel słyszy obok siebie. Po minucie zgłasza wykonanie kontraktu."
	item = /obj/item/implanter/aq_spying
	cost = 2

/datum/uplink_item/implants/aq_warp
	name = "Implant cofnięcia"
	desc = "Przenosi cię tam, gdzie byłeś 10 sekund wcześniej. Odnowienie 30 s."
	item = /obj/item/implanter/aq_warp
	cost = 6

/datum/uplink_item/implants/aq_supercharge
	name = "Implant doładowania"
	desc = "Adrenalina dla IPC: trzy razy zdejmuje ogłuszenia, przywraca siły, przyspiesza i łata uszkodzenia. Na organicznych nie działa."
	item = /obj/item/implanter/aq_supercharge
	cost = 5

/datum/uplink_item/implants/aq_deniability
	name = "Implant taktycznego wyparcia się"
	desc = "Nie tracisz przytomności od ran, a w stanie krytycznym implant wybucha po 10 sekundach."
	item = /obj/item/implanter/aq_deniability
	cost = 6

/datum/uplink_item/implants/aq_fake_mindshield
	name = "Implant fałszywej ochrony umysłu"
	desc = "HUD ochrony pokazuje ci implant ochrony umysłu. Ikonę włączasz i wyłączasz sam."
	item = /obj/item/implanter/aq_fake_mindshield
	cost = 4

/datum/uplink_item/implants/aq_smoke
	name = "Implant dymny"
	desc = "Trzy razy wypuszcza gęstą chmurę dymu wokół ciebie."
	item = /obj/item/implanter/aq_smoke
	cost = 3

/datum/uplink_item/implants/aq_tacmap
	name = "Implant mapy taktycznej Syndykatu"
	desc = "Hologram okrętu z pozycjami innych agentów z tym implantem."
	item = /obj/item/implanter/aq_tacmap/syndicate
	cost = 1

/datum/uplink_item/implants/aq_tacvisor
	name = "Taktyczny wizjer IFF"
	desc = "Oczy z HUD-em ochrony i oceną zagrożenia. Nie rozpoznajesz za to twarzy ani imion. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/tacvisor
	cost = 5

/datum/uplink_item/implants/aq_hacking_deck
	name = "System hakowania bezprzewodowego Binyat"
	desc = "Czip neuronowy, który szarpie przypadkowymi kablami wskazanej maszyny z odległości. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/hacking_deck
	cost = 7

/datum/uplink_item/implants/aq_doorjack
	name = "Implant doorjacka"
	desc = "Łamacz zamków w ręce: przepala elektronikę drzwi w 3 sekundy. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/doorjack
	cost = 6

/datum/uplink_item/implants/aq_sandevistan
	name = "Implant kręgosłupa Sandevistan"
	desc = "Przez 15 sekund jesteś szybszy, a wszyscy wokół wolniejsi. Potem 45 s chłodzenia i uszkodzenia serca. Zajmuje slot kręgosłupa. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/sandevistan
	cost = 14
	player_minimum = 20

/datum/uplink_item/implants/aq_optical_camo
	name = "Implant kamuflażu optycznego"
	desc = "Prawie pełna niewidzialność na żądanie, kosztem jedzenia. EMP ją wyłącza. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/optical_camo
	cost = 10
	player_minimum = 20

/datum/uplink_item/implants/aq_overclocker
	name = "Neuronowy podkręcacz"
	desc = "Włączany: szybszy ruch i reakcje. Im dłużej działa, tym bardziej przegrzewa ciało i mózg. Zajmuje slot kręgosłupa. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/overclocker
	cost = 8

/datum/uplink_item/implants/aq_shell_launcher
	name = "Implant wyrzutni nabojów"
	desc = "Jednostrzałowe działko w ramieniu na naboje do strzelby, załadowane gumową kulą. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/shell_launcher
	cost = 6

/datum/uplink_item/implants/aq_laser_eyes
	name = "Laserowe cyberoczy"
	desc = "Oczy, które strzelają laserem co 6 sekund. Zasłonięte nie strzelają. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/aq_single/laser_eyes
	cost = 9

// ===========================================================================
// CZARNY RYNEK

/datum/market_item/shoddy_implant/aq_razorwing
	name = "Implant ostrych skrzydeł"
	desc = "Dla ćmoludzi: wiruje i tnie skrzydłami wszystkich obok. Implanter w zestawie."
	item = /obj/item/implanter/aq_razorwing
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3
	availability_prob = 40

/datum/market_item/shoddy_implant/aq_sponsorship
	name = "Implant sponsorski"
	desc = "Nosiciel mimowolnie wygłasza reklamy i dostaje za nie parę kredytów. Idealny prezent dla dłużnika."
	item = /obj/item/implanter/aq_sponsorship
	price_min = MARKET_CRATE_VALUE
	price_max = MARKET_CRATE_VALUE * 2
	stock_max = 3
	availability_prob = 60

/datum/market_item/shoddy_implant/aq_joywire
	name = "Ożywiacz przyjemności Midi-Sed"
	desc = "Cyfrowa używka: stała euforia za cenę smaku, na zawsze."
	item = /obj/item/organ/cyberimp/brain/aq_joywire
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	availability_prob = 50

/datum/market_item/shoddy_implant/aq_emotional_manipulator
	name = "Manipulator emocji"
	desc = "Szczęście albo spokój na żądanie. Kradziony z gabinetu psychiatry."
	item = /obj/item/organ/cyberimp/brain/aq_emotional_manipulator
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3
	availability_prob = 40

/datum/market_item/shoddy_implant/aq_overclocker
	name = "Neuronowy podkręcacz"
	desc = "Szybszy ruch i reakcje, dopóki mózg się nie ugotuje."
	item = /obj/item/organ/cyberimp/chest/spinal/aq_overclocker
	price_min = MARKET_CRATE_VALUE * 6
	price_max = MARKET_CRATE_VALUE * 8
	availability_prob = 15

/datum/market_item/shoddy_implant/aq_overclocker_toy
	name = "Neuronowy podkręcacz (z drugiej ręki)"
	desc = "Sprzedawca przysięga, że działa. Ładnie świeci."
	item = /obj/item/organ/cyberimp/chest/spinal/aq_overclocker/toy
	price_min = MARKET_CRATE_VALUE
	price_max = MARKET_CRATE_VALUE * 2
	availability_prob = 50
