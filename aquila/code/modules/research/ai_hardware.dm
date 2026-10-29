// Zdecentralizowane AI: płytki, projekty i węzły badań (port Monkestation/Monkestation2.0#11862)

//////////////////////// Płytki ////////////////////////

/obj/item/circuitboard/machine/server_cabinet
	name = "szafa serwerowa (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/ai/server_cabinet
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 1,
	)

/obj/item/circuitboard/machine/rack_creator
	name = "składarka racków (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rack_creator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
	)

/obj/item/circuitboard/machine/ai_data_core
	name = "rdzeń danych SI (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/ai/data_core
	req_components = list(
		/obj/item/stock_parts/capacitor = 4,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/machine/ai_data_core/primary
	name = "główny rdzeń danych SI (płytka maszyny)"
	build_path = /obj/machinery/ai/data_core/primary

/obj/item/circuitboard/machine/ai_core_display
	name = "ekran rdzenia SI (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/ai_core_display
	req_components = list(/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/computer/ai_upload_download
	name = "konsola sterowania SI (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/ai_control_console

/obj/item/circuitboard/computer/ai_server_overview
	name = "konsola przeglądu serwerów SI (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/ai_server_console

/obj/item/circuitboard/computer/ai_overclocking
	name = "stanowisko podkręcania (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/ai_overclocking

/obj/item/circuitboard/computer/ai_resource_distribution
	name = "konsola dystrybucji zasobów SI (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/ai_resource_distribution

//////////////////////// Projekty płytek ////////////////////////

/datum/design/board/server_cabinet
	name = "Projekt maszyny (szafa serwerowa)"
	desc = "Płytka szafy serwerowej dla sieci SI."
	id = "server_cabinet"
	build_path = /obj/item/circuitboard/machine/server_cabinet
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/rack_creator
	name = "Projekt maszyny (składarka racków)"
	desc = "Płytka składarki racków serwerowych."
	id = "rack_creator"
	build_path = /obj/item/circuitboard/machine/rack_creator
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/ai_data_core
	name = "Projekt maszyny (rdzeń danych SI)"
	desc = "Płytka rdzenia danych, w którym może działać SI."
	id = "ai_data_core"
	build_path = /obj/item/circuitboard/machine/ai_data_core
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/ai_core_display
	name = "Projekt maszyny (ekran rdzenia SI)"
	desc = "Płytka ekranu, na którym SI pokazuje swój wizerunek."
	id = "ai_core_display"
	build_path = /obj/item/circuitboard/machine/ai_core_display
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/ai_upload_download
	name = "Projekt komputera (konsola sterowania SI)"
	desc = "Płytka konsoli wgrywania i pobierania SI."
	id = "ai_upload_download"
	build_path = /obj/item/circuitboard/computer/ai_upload_download
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/ai_server_overview
	name = "Projekt komputera (konsola przeglądu serwerów SI)"
	desc = "Płytka konsoli przeglądu serwerów SI."
	id = "ai_server_overview"
	build_path = /obj/item/circuitboard/computer/ai_server_overview
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/ai_overclocking
	name = "Projekt komputera (stanowisko podkręcania)"
	desc = "Płytka stanowiska podkręcania procesorów SI."
	id = "ai_overclocking"
	build_path = /obj/item/circuitboard/computer/ai_overclocking
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/ai_resource_distribution
	name = "Projekt komputera (konsola dystrybucji zasobów SI)"
	desc = "Płytka konsoli dystrybucji zasobów SI."
	id = "ai_resource_distribution"
	build_path = /obj/item/circuitboard/computer/ai_resource_distribution
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

//////////////////////// Procesory ////////////////////////

/datum/design/cpu_basic
	name = "Neural Processing Unit"
	desc = "Podstawowy procesor do racków serwerowych SI."
	id = "basic_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 4000, /datum/material/iron = 4000)
	build_path = /obj/item/ai_cpu
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cpu_advanced
	name = "Advanced Neural Processing Unit"
	desc = "Szybszy procesor do racków serwerowych SI."
	id = "advanced_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 8000, /datum/material/iron = 8000, /datum/material/gold = 4000)
	build_path = /obj/item/ai_cpu/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cpu_experimental
	name = "Experimental Neural Processing Unit"
	desc = "Procesor o zmiennych parametrach podkręcania."
	id = "experimental_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 12000, /datum/material/iron = 8000, /datum/material/gold = 12000)
	build_path = /obj/item/ai_cpu/experimental
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cpu_bluespace
	name = "Bluespace Neural Processing Unit"
	desc = "Najszybszy procesor do racków serwerowych SI."
	id = "bluespace_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 16000, /datum/material/iron = 8000, /datum/material/gold = 8000, /datum/material/bluespace = 4000)
	build_path = /obj/item/ai_cpu/bluespace
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

//////////////////////// Pamięć RAM (składarka racków) ////////////////////////

/datum/design/ram
	id = DESIGN_ID_IGNORE
	build_type = RACK_CREATOR
	category = list()
	materials = list()
	var/capacity = 0
	var/list/ram_materials

/datum/design/ram/ram1
	name = "Pamięć standardowa"
	desc = "Pamięć z wycofanych eksperymentów NT-CONLAB. Drukuje ją składarka racków."
	id = "ram1"
	research_icon = 'icons/obj/module.dmi'
	research_icon_state = "ram"
	ram_materials = list(/datum/material/glass = 2000, /datum/material/iron = 2000)
	capacity = 1

/datum/design/ram/ram2
	name = "Pamięć dużej pojemności"
	desc = "Pamięć o dużej pojemności przy normalnej wydajności."
	id = "ram2"
	research_icon = 'icons/obj/module.dmi'
	research_icon_state = "ram"
	ram_materials = list(/datum/material/glass = 4000, /datum/material/iron = 4000, /datum/material/silver = 2000)
	capacity = 2

/datum/design/ram/ram3
	name = "Pamięć ultrawysokiej pojemności"
	desc = "Manipulacja materią niemal na poziomie atomów zwiększa pojemność bez spadku wydajności."
	id = "ram3"
	research_icon = 'icons/obj/module.dmi'
	research_icon_state = "ram"
	ram_materials = list(/datum/material/glass = 8000, /datum/material/iron = 8000, /datum/material/silver = 4000, /datum/material/gold = 2000)
	capacity = 3

/datum/design/ram/ram4
	name = "Pamięć bluespace"
	desc = "Technologia bluespace zwiększa pojemność RAM bez spadku szybkości."
	id = "ram4"
	research_icon = 'icons/obj/module.dmi'
	research_icon_state = "ram"
	ram_materials = list(/datum/material/glass = 16000, /datum/material/iron = 16000, /datum/material/silver = 8000, /datum/material/gold = 4000, /datum/material/bluespace = 2000)
	capacity = 4

//////////////////////// Węzły badań ////////////////////////

/datum/techweb_node/ai/New() // appended so upstream changes to this node's designs still apply
	. = ..()
	design_ids += list("server_cabinet", "ai_data_core", "ai_core_display", "ai_server_overview", "ai_overclocking", "ai_upload_download", "ai_resource_distribution", "rack_creator", "ram1", "basic_ai_cpu", "server_chiller", "networking_machine")

/datum/techweb_node/ai_cpu_advanced
	id = "ai_cpu_advanced"
	tech_tier = 3
	display_name = "Zaawansowane przetwarzanie neuronowe"
	description = "Wydajniejsza produkcja pozwala znacznie przyspieszyć jednostki neuronowe kosztem poboru mocy."
	design_ids = list("advanced_ai_cpu")
	prereq_ids = list("high_efficiency", "ai")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 80)
	export_price = 2000

/datum/techweb_node/ai_cpu_experimental
	id = "ai_cpu_experimental"
	tech_tier = 4
	display_name = "Eksperymentalne przetwarzanie neuronowe"
	description = "Odrzucone wcześniej jednostki można przerobić. Więcej mocy, ale lepsze możliwości podkręcania."
	design_ids = list("experimental_ai_cpu")
	prereq_ids = list("ai_cpu_advanced")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

/datum/techweb_node/ai_cpu_bluespace
	id = "ai_cpu_bluespace"
	tech_tier = 5
	display_name = "Bluespace'owe przetwarzanie neuronowe"
	description = "Bluespace pozwala zrobić ultraszybkie jednostki neuronowe kosztem dużo większego poboru mocy."
	design_ids = list("bluespace_ai_cpu")
	prereq_ids = list("ai_cpu_advanced", "practical_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 200)
	export_price = 2000

/datum/techweb_node/ai_ram_high_cap
	id = "ai_ram_high_cap"
	tech_tier = 3
	display_name = "Kości pamięci dużej pojemności"
	description = "Postęp w produkcji pamięci pozwala na gęstsze kości."
	design_ids = list("ram2")
	prereq_ids = list("high_efficiency", "ai")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 80)
	export_price = 2000

/datum/techweb_node/ai_ram_hyper
	id = "ai_ram_hyper"
	tech_tier = 4
	display_name = "Kości pamięci ultrawysokiej pojemności"
	description = "Dalsze dopracowanie pamięci daje niewyobrażalną wcześniej gęstość danych."
	design_ids = list("ram3")
	prereq_ids = list("ai_ram_high_cap")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

/datum/techweb_node/ai_ram_bluespace
	id = "ai_ram_bluespace"
	tech_tier = 5
	display_name = "Bluespace'owe kości pamięci"
	description = "Dane przechowywane w kieszeniach bluespace mocno zwiększają gęstość kosztem droższej produkcji."
	design_ids = list("ram4")
	prereq_ids = list("ai_ram_hyper", "practical_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 160)
	export_price = 2000

// Gniazda w racku: zbadanie węzła odblokowuje kolejne miejsce na CPU/RAM w składarce racków
/datum/techweb_node/ai_cpu_2
	id = "ai_cpu_2"
	tech_tier = 3
	display_name = "Lepsze gniazda CPU"
	description = "Dopracowanie teorii danych pozwala zamontować drugi procesor w każdym racku SI."
	design_ids = list()
	prereq_ids = list("ai")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

/datum/techweb_node/ai_cpu_3
	id = "ai_cpu_3"
	tech_tier = 4
	display_name = "Zaawansowane gniazda CPU"
	description = "Obliczenia 256-bitowe pozwalają dodać trzeci procesor."
	design_ids = list()
	prereq_ids = list("ai_arch_256")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

/datum/techweb_node/ai_cpu_4
	id = "ai_cpu_4"
	tech_tier = 5
	display_name = "Bluespace'owe gniazda CPU"
	description = "Natychmiastowe przesyłanie danych między pamięciami podręcznymi pozwala dodać czwarty procesor."
	design_ids = list()
	prereq_ids = list("ai_arch_bluespace", "ai_cpu_3")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 200)
	export_price = 2000

/datum/techweb_node/ai_ram_2
	id = "ai_ram_2"
	tech_tier = 3
	display_name = "Lepsza magistrala pamięci"
	description = "Dopracowanie teorii danych pozwala dodać drugą kość pamięci w każdym racku SI."
	design_ids = list()
	prereq_ids = list("ai")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

/datum/techweb_node/ai_ram_3
	id = "ai_ram_3"
	tech_tier = 4
	display_name = "Zaawansowana magistrala pamięci"
	description = "Obliczenia 256-bitowe pozwalają dodać trzecią kość pamięci."
	design_ids = list()
	prereq_ids = list("ai_arch_256")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

/datum/techweb_node/ai_ram_4
	id = "ai_ram_4"
	tech_tier = 5
	display_name = "Bluespace'owa magistrala pamięci"
	description = "Teleportacja bluespace usuwa wąskie gardła. Pozwala dodać czwartą kość pamięci."
	design_ids = list()
	prereq_ids = list("ai_ram_3", "ai_arch_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 160)
	export_price = 2000

/datum/techweb_node/ai_architecture_256
	id = "ai_arch_256"
	tech_tier = 4
	display_name = "Obliczenia 256-bitowe"
	description = "Doświadczenie z budową sprzętu pokazuje potrzebę większej liczby rdzeni i kości w racku. Otwiera drogę do tych technologii."
	design_ids = list()
	prereq_ids = list("ai_ram_2", "ai_cpu_2")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 160)
	export_price = 2000

/datum/techweb_node/ai_architecture_bluespace
	id = "ai_arch_bluespace"
	tech_tier = 5
	display_name = "Obliczenia bluespace'owe"
	description = "Bluespace pozwala natychmiast przesyłać dane w obrębie racka. Otwiera drogę do ostatniego poziomu obliczeń."
	design_ids = list()
	prereq_ids = list("ai_arch_256", "practical_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = 120)
	export_price = 2000

//////////////////////// Projekt „Przyspieszenie badań” ////////////////////////

/datum/controller/subsystem/research/source_code_multiplier()
	. = ..()
	if(GLOB.ai_research_booster)
		. *= 1.2

//////////////////////// Tech storage ////////////////////////

/obj/effect/spawner/lootdrop/techstorage/AI/Initialize(mapload)
	loot += list(
		/obj/item/circuitboard/computer/ai_upload_download,
		/obj/item/circuitboard/computer/ai_resource_distribution,
		/obj/item/circuitboard/computer/ai_server_overview,
		/obj/item/circuitboard/computer/ai_overclocking,
		/obj/item/circuitboard/machine/rack_creator,
	)
	return ..()
