////////////////////////////////////////
///////////Computer Parts///////////////
////////////////////////////////////////

/datum/design/disk/normal
	name = "Dysk twardy"
	id = "hdd_basic"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100, /datum/material/copper = 150)
	build_path = /obj/item/computer_hardware/hard_drive
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/disk/advanced
	name = "Zaawansowany dysk twardy"
	id = "hdd_advanced"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200, /datum/material/copper = 300)
	build_path = /obj/item/computer_hardware/hard_drive/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/disk/super
	name = "Superdysk twardy"
	id = "hdd_super"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1600, /datum/material/glass = 400, /datum/material/copper = 600)
	build_path = /obj/item/computer_hardware/hard_drive/super
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/disk/cluster
	name = "Klastrowy dysk twardy"
	id = "hdd_cluster"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3200, /datum/material/glass = 800, /datum/material/copper = 1000)
	build_path = /obj/item/computer_hardware/hard_drive/cluster
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/disk/small
	name = "Dysk SSD"
	id = "ssd_small"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200, /datum/material/copper = 200)
	build_path = /obj/item/computer_hardware/hard_drive/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/disk/micro
	name = "Mikrodysk SSD"
	id = "ssd_micro"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100, /datum/material/copper = 150)
	build_path = /obj/item/computer_hardware/hard_drive/micro
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Network cards
/datum/design/netcard/basic
	name = "Karta sieciowa"
	id = "netcard_basic"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 250, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/network_card
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/netcard/advanced
	name = "Zaawansowana karta sieciowa"
	id = "netcard_advanced"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200, /datum/material/copper = 200)
	build_path = /obj/item/computer_hardware/network_card/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/netcard/wired
	name = "Przewodowa karta sieciowa"
	id = "netcard_wired"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 400, /datum/material/copper = 400)
	build_path = /obj/item/computer_hardware/network_card/wired
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Data disks
/datum/design/portabledrive/basic
	name = "Dysk z danymi"
	id = "portadrive_basic"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 800, /datum/material/copper = 200)
	build_path = /obj/item/computer_hardware/hard_drive/portable
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/portabledrive/advanced
	name = "Zaawansowany dysk z danymi"
	id = "portadrive_advanced"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1600, /datum/material/copper = 300)
	build_path = /obj/item/computer_hardware/hard_drive/portable/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/portabledrive/super
	name = "Superdysk z danymi"
	id = "portadrive_super"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 3200, /datum/material/copper = 400)
	build_path = /obj/item/computer_hardware/hard_drive/portable/super
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Card slot
/datum/design/cardslot
	name = "Gniazdo na identyfikator"
	id = "cardslot"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/card_slot
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Intellicard slot
/datum/design/aislot
	name = "Gniazdo na intelliCard"
	id = "aislot"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/ai_slot
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Mini printer
/datum/design/miniprinter
	name = "Minidrukarka"
	id = "miniprinter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/printer/mini
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// APC Link
/datum/design/APClink
	name = "Złącze zasilania obszaru"
	id = "APClink"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/computer_hardware/recharger/APC
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Batteries
/datum/design/battery/controller
	name = "Kontroler ogniwa zasilającego"
	id = "bat_control"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400)
	build_path = /obj/item/computer_hardware/battery
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/battery/normal
	name = "Moduł baterii"
	id = "bat_normal"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400)
	build_path = /obj/item/stock_parts/cell/computer
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/battery/advanced
	name = "Zaawansowany moduł baterii"
	id = "bat_advanced"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 800)
	build_path = /obj/item/stock_parts/cell/computer/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/battery/super
	name = "Supermoduł baterii"
	id = "bat_super"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1600)
	build_path = /obj/item/stock_parts/cell/computer/super
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/battery/nano
	name = "Nanomoduł baterii"
	id = "bat_nano"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/stock_parts/cell/computer/nano
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/battery/micro
	name = "Mikromoduł baterii"
	id = "bat_micro"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400)
	build_path = /obj/item/stock_parts/cell/computer/micro
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Processor unit
/datum/design/cpu
	name = "Płytka procesora"
	id = "cpu_normal"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 200, /datum/material/copper = 1600)
	build_path = /obj/item/computer_hardware/processor_unit
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cpu/small
	name = "Mikroprocesor"
	id = "cpu_small"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 100, /datum/material/copper = 800)
	build_path = /obj/item/computer_hardware/processor_unit/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cpu/photonic
	name = "Fotoniczna płytka procesora"
	id = "pcpu_normal"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 6400, /datum/material/gold = 2000, /datum/material/copper = 800)
	build_path = /obj/item/computer_hardware/processor_unit/photonic
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/cpu/photonic/small
	name = "Fotoniczny mikroprocesor"
	id = "pcpu_small"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 3200, /datum/material/gold = 1000, /datum/material/copper = 400)
	build_path = /obj/item/computer_hardware/processor_unit/photonic/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

//antivirus. While not a computer bit, it makes more flavor-sense in here

/datum/design/antivirus1
	name = "Podstawowy antywirus"
	desc = "Licencjonowana kopia NTOS defender."
	id = "antivirus"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50, /datum/material/copper = 50)
	build_path = /obj/item/disk/antivirus
	category = list("Computer Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/antivirus2
	name = "Ulepszony antywirus"
	desc = "Licencjonowana kopia antywirusa Ahoy."
	id = "antivirus2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/antivirus/tier2
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/antivirus3
	name = "Wytrzymały antywirus"
	desc = "Licencjonowana kopia antywirusa McValosk."
	id = "antivirus3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 150, /datum/material/silver = 60, /datum/material/copper = 100)
	build_path = /obj/item/disk/antivirus/tier3
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/antivirus4
	name = "Luksusowy antywirus"
	desc = "Licencjonowana kopia antywirusa Nano-Ton."
	id = "antivirus4"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/diamond = 30, /datum/material/bluespace = 30, /datum/material/copper = 100)
	build_path = /obj/item/disk/antivirus/tier4
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/sensorpackage
	name = "Pakiet czujników"
	id = "sensorpackage"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 100, /datum/material/gold = 50, /datum/material/silver = 50)
	build_path = /obj/item/computer_hardware/sensorpackage
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/signaler_part
	name = "Zintegrowany sygnalizator"
	id = "signalpart"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100)
	build_path = /obj/item/computer_hardware/radio_card
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
