// Koszty: tg TECHWEB_TIER_*_POINTS przeliczone na skalę naszego drzewa (tier 1 = 2500 punktów)

/datum/techweb_node/basic_microfusion
	id = "basic_microfusion"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Podstawowa technologia microfusion"
	description = "Podstawy technologii microfusion i najprostsze projekty."
	prereq_ids = list("base")
	design_ids = list(
		"basic_microfusion_cell",
	)

//Enhanced microfusion
/datum/techweb_node/enhanced_microfusion
	id = "enhanced_microfusion"
	tech_tier = 2
	display_name = "Ulepszona technologia microfusion"
	description = "Ulepszona technologia microfusion, czyli podstawy, tylko lepsze!"
	prereq_ids = list(
		"basic_microfusion",
		"engineering",
		"weaponry",
		"high_efficiency",
	)
	design_ids = list(
		"enhanced_microfusion_cell",
		"enhanced_microfusion_phase_emitter",
		"microfusion_gun_attachment_black_camo",
		"microfusion_gun_attachment_nt_camo",
		"microfusion_gun_attachment_heatsink",
		"microfusion_gun_attachment_rgb",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

//Advanced microfusion
/datum/techweb_node/advanced_microfusion
	id = "advanced_microfusion"
	tech_tier = 3
	display_name = "Zaawansowana technologia microfusion"
	description = "Zaawansowana technologia microfusion!"
	prereq_ids = list(
		"enhanced_microfusion",
		"adv_engi",
		"adv_weaponry",
		"adv_power",
		"adv_plasma",
	)
	design_ids = list(
		"advanced_microfusion_cell",
		"microfusion_cell_attachment_overcapacity",
		"microfusion_cell_attachment_stabiliser",
		"microfusion_gun_attachment_scatter",
		"microfusion_gun_attachment_hellfire",
		"advanced_microfusion_phase_emitter",
		"microfusion_gun_attachment_lance",
		"microfusion_gun_attachment_grip",
		"microfusion_gun_attachment_rail",
		"microfusion_gun_attachment_scope",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

// Bluespace microfusion
/datum/techweb_node/bluespace_microfusion
	id = "bluespace_microfusion"
	tech_tier = 4
	display_name = "Bluespace'owa technologia microfusion"
	description = "Majstrowanie przy bluespace plus technologia microfusion!"
	prereq_ids = list(
		"advanced_microfusion",
		"bluespace_power",
		"beam_weapons",
	)
	design_ids = list(
		"bluespace_microfusion_cell",
		"microfusion_cell_attachment_selfcharging",
		"microfusion_gun_attachment_repeater",
		"bluespace_microfusion_phase_emitter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

// Quantum microfusion
/datum/techweb_node/quantum_microfusion
	id = "quantum_microfusion"
	tech_tier = 5
	display_name = "Kwantowa technologia microfusion"
	description = "Najnowsza technologia microfusion na najlepszych materiałach i podzespołach, bluespace'owych i nie tylko."
	prereq_ids = list(
		"bluespace_microfusion",
		"alientech",
	)
	design_ids = list(
		"microfusion_gun_attachment_xray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	export_price = 5000

// Warcrime microfusion
/datum/techweb_node/illegal_microfusion
	id = "illegal_microfusion"
	tech_tier = 4
	display_name = "Nielegalna technologia microfusion"
	description = "Technologia microfusion zakazana kiedyś przez SolFed. Kocham zapach plazmy o poranku."
	prereq_ids = list(
		"advanced_microfusion",
		"syndicate_basic",
	)
	design_ids = list(
		"microfusion_gun_attachment_superheat",
		"microfusion_gun_attachment_scattermax",
		"microfusion_gun_attachment_penetrator",
		"microfusion_gun_attachment_syndi_camo",
		"microfusion_gun_attachment_suppressor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

// clown microfusion. | This exists to not make this non modular
/datum/techweb_node/clown_microfusion
	id = "clown_microfusion"
	tech_tier = 2
	display_name = "Technologia Honkicron Clownery Systems"
	description = "Zastrzeżona technologia microfusion firmy Honkicron Clownery Systems. HONK!!"
	prereq_ids = list(
		"basic_microfusion",
		"clown",
	)
	design_ids = list(
		"microfusion_gun_attachment_honk",
		"microfusion_gun_attachment_honk_camo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 625) //Its normally supposed to be in clown tech so
	export_price = 5000
