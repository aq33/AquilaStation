// AQUILA - Mechanik: węzeł techwebu „Inżynieria wsteczna” z projektami oraz narzędzia bez blokad w uplinku.

/datum/techweb_node/reverse_engineering
	id = "reverse_engineering"
	tech_tier = 2
	display_name = "Inżynieria wsteczna"
	description = "Skanowanie maszyn, odczyt schematów i pakowanie maszyn w paczki, które rozkłada się multitoolem."
	prereq_ids = list("adv_engi")
	design_ids = list("machine_scanner", "machine_packer", "flatpack_cart", "flatpacker", "schematic_reader")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/design/machine_scanner
	name = "Skaner maszyn"
	desc = "Zapisuje schematy maszyn razem z tierem części."
	id = "machine_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 250)
	build_path = /obj/item/machine_scanner
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/machine_packer
	name = "Pakownica maszyn"
	desc = "Składa maszynę w paczkę razem z płytką i częściami."
	id = "machine_packer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/machine_packer
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/flatpack_cart
	name = "Wózek na paczki"
	desc = "Wózek, na którym mieszczą się trzy paczki."
	id = "flatpack_cart"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 8)
	build_path = /obj/structure/flatpack_cart
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/design/board/flatpacker
	name = "Projekt maszyny (flatpacker)"
	desc = "Płytka drukowana: flatpacker."
	id = "flatpacker"
	build_path = /obj/item/circuitboard/machine/flatpacker
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/schematic_reader
	name = "Projekt maszyny (czytnik schematów)"
	desc = "Płytka drukowana: czytnik schematów."
	id = "schematic_reader"
	build_path = /obj/item/circuitboard/machine/schematic_reader
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/uplink_item/device_tools/machine_scanner
	name = "Skaner maszyn bez blokad"
	desc = "Skaner maszyn, który zapisuje też schematy uzbrojenia, konsol okrętu i sprzętu ochrony. Po wgraniu do czytnika schematów zhakowany emagiem flatpacker zrobi z nich paczki. Mieści 20 skanów."
	item = /obj/item/machine_scanner/syndicate
	cost = 2

/datum/uplink_item/device_tools/machine_packer
	name = "Pakownica maszyn bez blokad"
	desc = "Pakownica, która w 3 sekundy składa w paczkę każdą maszynę z płytką i otwartym włazem, także działa, konsole okrętu i sprzęt ochrony. Paczkę rozłożysz multitoolem gdzie indziej."
	item = /obj/item/machine_packer/syndicate
	cost = 4
