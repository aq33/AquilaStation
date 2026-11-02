////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/RPED
	name = "Urządzenie do szybkiej wymiany części"
	desc = "Specjalny moduł mechaniczny do przechowywania, sortowania i montowania standardowych części maszyn."
	id = "rped"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000) //hardcore
	build_path = /obj/item/storage/part_replacer
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/BS_RPED
	name = "RPED bluespace"
	desc = "Ten wariant RPED, zasilany technologią bluespace, ulepsza maszyny z odległości, bez zdejmowania panelu."
	id = "bs_rped"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/silver = 2500) //hardcore
	build_path = /obj/item/storage/part_replacer/bluespace
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Capacitors
/datum/design/basic_capacitor
	name = "Podstawowy kondensator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "basic_capacitor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/stock_parts/capacitor
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/adv_capacitor
	name = "Zaawansowany kondensator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "adv_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 150)
	build_path = /obj/item/stock_parts/capacitor/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/super_capacitor
	name = "Superkondensator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "super_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/gold = 100)
	build_path = /obj/item/stock_parts/capacitor/super
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quadratic_capacitor
	name = "Kondensator kwadratowy"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "quadratic_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/gold = 100, /datum/material/diamond = 100)
	build_path = /obj/item/stock_parts/capacitor/quadratic
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Scanning modules
/datum/design/basic_scanning
	name = "Podstawowy moduł skanujący"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "basic_scanning"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/scanning_module
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_scanning
	name = "Zaawansowany moduł skanujący"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "adv_scanning"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/stock_parts/scanning_module/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/phasic_scanning
	name = "Fazowy moduł skanujący"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "phasic_scanning"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 150, /datum/material/silver = 60, /datum/material/copper = 100)
	build_path = /obj/item/stock_parts/scanning_module/phasic
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/triphasic_scanning
	name = "Trójfazowy moduł skanujący"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "triphasic_scanning"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/diamond = 30, /datum/material/bluespace = 30, /datum/material/copper = 100)
	build_path = /obj/item/stock_parts/scanning_module/triphasic
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

//Maipulators
/datum/design/micro_mani
	name = "Mikromanipulator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "micro_mani"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/manipulator
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nano_mani
	name = "Nanomanipulator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "nano_mani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/manipulator/nano
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pico_mani
	name = "Pikomanipulator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "pico_mani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/manipulator/pico
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/femto_mani
	name = "Femtomanipulator"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "femto_mani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/diamond = 30, /datum/material/titanium = 30, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/manipulator/femto
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Micro-lasers
/datum/design/basic_micro_laser
	name = "Podstawowy mikrolaser"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "basic_micro_laser"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/micro_laser
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/high_micro_laser
	name = "Mikrolaser dużej mocy"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "high_micro_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/micro_laser/high
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/ultra_micro_laser
	name = "Mikrolaser ultrawysokiej mocy"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "ultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 150, /datum/material/uranium = 60, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/micro_laser/ultra
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quadultra_micro_laser
	name = "Mikrolaser quad-ultra"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "quadultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/uranium = 100, /datum/material/diamond = 60, /datum/material/copper = 50)
	build_path = /obj/item/stock_parts/micro_laser/quadultra
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/basic_matter_bin
	name = "Podstawowy zasobnik materii"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "basic_matter_bin"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100)
	build_path = /obj/item/stock_parts/matter_bin
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/adv_matter_bin
	name = "Zaawansowany zasobnik materii"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "adv_matter_bin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/stock_parts/matter_bin/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/super_matter_bin
	name = "Superzasobnik materii"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "super_matter_bin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/stock_parts/matter_bin/super
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespace_matter_bin
	name = "Zasobnik materii bluespace"
	desc = "Część zamienna używana do budowy różnych urządzeń."
	id = "bluespace_matter_bin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 250, /datum/material/diamond = 100, /datum/material/bluespace = 100)
	build_path = /obj/item/stock_parts/matter_bin/bluespace
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//T-Comms devices
/datum/design/subspace_ansible
	name = "Ansibl podprzestrzenny"
	desc = "Kompaktowy moduł wyczuwający aktywność międzywymiarową."
	id = "s-ansible"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/silver = 100)
	build_path = /obj/item/stock_parts/subspace/ansible
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hyperwave_filter
	name = "Filtr hiperfal"
	desc = "Maleńkie urządzenie, które filtruje i przetwarza bardzo silne fale radiowe."
	id = "s-filter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/silver = 100)
	build_path = /obj/item/stock_parts/subspace/filter
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_amplifier
	name = "Wzmacniacz podprzestrzenny"
	desc = "Kompaktowa mikromaszyna, która wzmacnia słabe transmisje podprzestrzenne."
	id = "s-amplifier"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/gold = 100, /datum/material/uranium = 100)
	build_path = /obj/item/stock_parts/subspace/amplifier
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_treatment
	name = "Dysk obróbki podprzestrzennej"
	desc = "Kompaktowa mikromaszyna, która rozciąga hiperskompresowane fale radiowe."
	id = "s-treatment"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/silver = 200)
	build_path = /obj/item/stock_parts/subspace/treatment
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_analyzer
	name = "Analizator podprzestrzenny"
	desc = "Wyrafinowany analizator, który bada zagadkowe długości fal podprzestrzennych."
	id = "s-analyzer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/gold = 100)
	build_path = /obj/item/stock_parts/subspace/analyzer
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_crystal
	name = "Kryształ ansibla"
	desc = "Wyrafinowany analizator, który bada zagadkowe długości fal podprzestrzennych."
	id = "s-crystal"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 800, /datum/material/silver = 100, /datum/material/gold = 100)
	build_path = /obj/item/stock_parts/subspace/crystal
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_transmitter
	name = "Nadajnik podprzestrzenny"
	desc = "Duże urządzenie, które otwiera okno do wymiaru podprzestrzeni."
	id = "s-transmitter"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 100, /datum/material/silver = 100, /datum/material/uranium = 100, /datum/material/copper = 100)
	build_path = /obj/item/stock_parts/subspace/transmitter
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE
