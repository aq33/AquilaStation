// Port cybernetyki z Monkestation: projekty implantów i dwa węzły techwebu (designs/item_sets.dm, designs/security.dm, tech_nodes.dm)

/datum/design/cyberimp_set
	name = "Implant w rękę"
	desc = "Zestaw narzędzi w ręce."
	build_type = PROTOLATHE | MECHFAB
	construction_time = 30
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_set/cook
	name = "Implant kuchenny"
	desc = "Zestaw przyborów kuchennych ukryty za maskowanym panelem w ręce."
	id = "ci-set-cook"
	build_path = /obj/item/organ/cyberimp/arm/cook
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/cyberimp_set/detective
	name = "Implant detektywistyczny"
	desc = "Zestaw narzędzi detektywa ukryty za maskowanym panelem w ręce."
	id = "ci-set-detective"
	build_path = /obj/item/organ/cyberimp/arm/detective
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_set/paramedic
	name = "Implant ratowniczy"
	desc = "Zestaw narzędzi ratownika ukryty za maskowanym panelem w ręce."
	id = "ci-set-paramedic"
	build_path = /obj/item/organ/cyberimp/arm/paramedic

/datum/design/cyberimp_set/atmospherics
	name = "Implant atmosferyczny"
	desc = "Zestaw narzędzi atmosferycznych ukryty za maskowanym panelem w ręce."
	id = "ci-set-atmospherics"
	build_path = /obj/item/organ/cyberimp/arm/atmospherics
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cyberimp_set/barber
	name = "Implant fryzjerski"
	desc = "Zestaw narzędzi fryzjera ukryty za maskowanym panelem w ręce."
	id = "ci-set-barber"
	build_path = /obj/item/organ/cyberimp/arm/barber
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/cyberimp_set/mining
	name = "Implant wiertła górniczego"
	desc = "Po prostu duże wiertło wszczepione w rękę."
	id = "ci-set-mining"
	build_path = /obj/item/organ/cyberimp/arm/mining_drill
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_CARGO

/datum/design/cyberimp_set/flash
	name = "Zintegrowany projektor fotonów wysokiej intensywności"
	desc = "Implant z wbudowanym w rękę fleszem."
	id = "ci-set-flash"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1000)
	build_path = /obj/item/organ/cyberimp/arm/flash
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_set/science_hud
	name = "Implant HUD naukowego"
	desc = "Wszczepy oczne działające jak gogle naukowe."
	id = "ci-scihud"
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/science
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cyberimp_set/mantis
	name = "Implanty ostrzy modliszki C.H.R.O.M.A.T.A."
	desc = "Zaawansowane implanty z ostrzem modliszki. Poręczna broń, która zadaje paskudne rany."
	id = "ci-set-mantis"
	build_path = /obj/item/organ/cyberimp/arm/mantis
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_set/officer
	name = "Implant oficerski"
	desc = "Potężny implant z modułami bojowymi wbudowanymi w rękę."
	id = "ci-set-combat"
	build_path = /obj/item/organ/cyberimp/arm/officer
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cyberimp_set/taser
	name = "Implant paralizatora w ręce"
	desc = "Potężny implant z zaawansowanym paralizatorem wbudowanym w rękę."
	id = "ci-set-taser"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/titanium = 1500)
	build_path = /obj/item/organ/cyberimp/arm/gun/taser
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/techweb_node/job_itemsets
	id = "job_itemsets"
	tech_tier = 4
	display_name = "Zatwierdzone zestawy implantów zawodowych"
	description = "Zatwierdzone przez NT zestawy narzędzi, które można wszczepić załodze, żeby zawsze miała je pod ręką."
	prereq_ids = list("cyber_implants", "basic_tools")
	design_ids = list(
		"ci-set-cook",
		"ci-set-detective",
		"ci-set-paramedic",
		"ci-set-atmospherics",
		"ci-set-barber",
		"ci-set-mining",
		"ci-set-flash",
		"ci-scihud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 4000

/datum/techweb_node/job_itemsets_security
	id = "job_itemsets_sec"
	tech_tier = 5
	display_name = "Zatwierdzone implanty ochrony"
	description = "Zatwierdzone przez NT implanty dla funkcjonariuszy ochrony."
	prereq_ids = list("adv_cyber_implants", "high_efficiency")
	design_ids = list(
		"ci-set-mantis",
		"ci-set-combat",
		"ci-set-taser",
		"ci-ammo-counter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000
