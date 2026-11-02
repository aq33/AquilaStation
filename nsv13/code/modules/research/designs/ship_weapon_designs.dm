//General weapons stuff
/datum/design/board/munitions_computer_circuit
	name = "Projekt komputera (komputer kontroli amunicji)"
	desc = "Pozwala zbudować konsolę kontroli amunicji."
	id = "munitions_computer_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/munitions_computer
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/ship_firing_electronics
	name = "Elektronika spustowa"
	desc = "Steruje mechanizmem spustowym broni okrętowej."
	id = "ship_firing_electronics"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 1000, /datum/material/diamond = 100, /datum/material/titanium = 300, /datum/material/copper = 100)
	construction_time = 100
	build_path = /obj/item/ship_weapon/parts/firing_electronics
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//50 Cal flavored PDC turrets
/datum/design/board/anti_air
	name = "Projekt maszyny (wieżyczka przeciwlotnicza)"
	desc = "Pozwala zbudować obsługiwaną przez załogę wieżyczkę przeciwlotniczą."
	id = "antiair"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 2000, /datum/material/gold = 5000)
	build_path = /obj/item/circuitboard/machine/anti_air
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/anti_air/heavy
	name = "Projekt maszyny (ciężka wieżyczka przeciwlotnicza)"
	desc = "Pozwala zbudować obsługiwaną przez załogę ciężką wieżyczkę przeciwlotniczą."
	id = "antiair_heavy"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 2000, /datum/material/gold = 5000)
	build_path = /obj/item/circuitboard/machine/anti_air/heavy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/antiaircomp
	name = "Projekt komputera (konsola wieżyczek przeciwlotniczych)"
	desc = "Pozwala zbudować konsolę sterowania działami przeciwlotniczymi."
	id = "antiaircomp"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 2000, /datum/material/gold = 5000)
	build_path = /obj/item/circuitboard/computer/anti_air
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Naval Artillery (Deck Gun)

/*Obsolete
/datum/design/board/naval_artillery
	name = "Projekt maszyny (rama działa pokładowego)"
	desc = "Pozwala zbudować ramę działa artylerii okrętowej."
	id = "deck_gun"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/titanium = 12000,/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/copper = 5000)
	build_path = /obj/structure/ship_weapon/mac_assembly/artillery_frame
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/naval_artillery_triple
	name = "Projekt maszyny (rama trzylufowego działa pokładowego)"
	desc = "Pozwala zbudować ramę trzylufowego działa okrętowego."
	id = "deck_gun_dual"
	materials = list(/datum/material/titanium = 30000,/datum/material/iron = 25000, /datum/material/diamond = 15000, /datum/material/copper = 35000)
	build_path = /obj/structure/ship_weapon/mac_assembly/artillery_frame/mega
	category = list("Advanced Munitions")
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
*/

/datum/design/board/deck_turret
	name = "Projekt maszyny (wieżyczka działa pokładowego)"
	desc = "Pozwala zbudować wieżyczkę działa artylerii okrętowej."
	id = "deck_gun"
	materials = list(/datum/material/titanium = 12000,/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/circuitboard/machine/deck_turret
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/multibarrel_upgrade/_3
	name = "Ulepszenie trzylufowe działa artylerii okrętowej (płytka)"
	desc = "Ulepszenie, które pozwala dodać dwie lufy do działa artylerii okrętowej."
	id = "deck_gun_triple"
	materials = list(/datum/material/titanium = 30000,/datum/material/iron = 25000, /datum/material/diamond = 15000, /datum/material/copper = 35000)
	build_path = /obj/item/circuitboard/multibarrel_upgrade/_3
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/naval_artillery_comp
	name = "Projekt maszyny (konsola sterowania działem pokładowym)"
	desc = "Pozwala zbudować konsolę sterowania artylerią okrętową."
	id = "naval_artillery_comp"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500, /datum/material/diamond=5000)
	build_path = /obj/item/circuitboard/computer/deckgun
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/artillery_loader
	name = "Projekt maszyny (rdzeń działa pokładowego)"
	desc = "Pozwala zbudować rdzeń artylerii okrętowej."
	id = "artillery_loader"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500, /datum/material/diamond=5000)
	build_path = /obj/item/circuitboard/machine/deck_gun/core
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/powder_loader
	name = "Projekt maszyny (bramka prochu działa pokładowego)"
	desc = "Pozwala zbudować bramkę prochu artylerii okrętowej."
	id = "powder_loader"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/powder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/payload_gate
	name = "Projekt maszyny (bramka ładunku działa pokładowego)"
	desc = "Pozwala zbudować bramkę ładunku artylerii okrętowej."
	id = "payload_gate"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/payload
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/deck_gun_autorepair
	name = "Projekt maszyny (moduł autonaprawy działa pokładowego)"
	desc = "Maszyna, która ulepsza działo pokładowe, pozwalając mu samodzielnie się naprawiać."
	id = "deck_gun_autorepair"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/deck_gun/autorepair
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/deck_gun_autoelevator
	name = "Projekt maszyny (automatyczny podnośnik działa pokładowego)"
	desc = "Maszyna, która ulepsza działo pokładowe i drastycznie skraca czas ładowania."
	id = "deck_gun_autoelevator"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 5000, /datum/material/titanium = 15000, /datum/material/diamond = 5000)
	build_path = /obj/item/circuitboard/machine/deck_gun/autoelevator
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Missile system (factory parts in munitions_designs.dm)
/datum/design/board/vls_tube
	name = "Projekt maszyny (wyrzutnia VLS)"
	desc = "Pozwala zbudować wyrzutnię pionową VLS (komputer sterujący sprzedawany osobno)."
	id = "vls_tube"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/silver = 500)
	build_path = /obj/item/circuitboard/machine/vls
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ams_console
	name = "Projekt maszyny (konsola sterowania AMS)"
	desc = "Pozwala zbudować konsolę sterowania AMS."
	id = "ams_console"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/silver = 500)
	build_path = /obj/item/circuitboard/computer/ams
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
//Gauss guns
/datum/design/board/gauss_dispenser_circuit
	name = "Projekt maszyny (dozownik amunicji do działa Gaussa)"
	desc = "Pozwala zbudować maszynę, która daje dostęp do wewnętrznych magazynów amunicji okrętu i wydaje amunicję do działa Gaussa."
	id = "gauss_dispenser_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/gauss_dispenser
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/gauss_turret
	name = "Projekt maszyny (wieżyczka Gaussa)"
	desc = "Pozwala zbudować wieżyczkę, która strzela we wroga pociskami Gaussa."
	id = "gauss_turret"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000, /datum/material/silver = 500)
	build_path = /obj/item/circuitboard/machine/gauss_turret
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Misc
/datum/design/railgun_rail
	name = "Szyna działa szynowego"
	desc = "Wzmocniona szyna elektromagnetyczna do działa szynowego."
	id = "railgun_rail"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 1000, /datum/material/plasma = 1000) //Duranium ingredients
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/railgun_rail
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Hybrid Railgun Ammo
/datum/design/slug_cold_iron
	name = "Wolframowy pocisk M4 NTRS 400 mm z powłoką teflonową"
	desc = "Standardowy pocisk szynowy."
	id = "slug_cold_iron"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plasma = 750)
	construction_time=10
	build_path = /obj/item/ship_weapon/ammunition/railgun_ammo
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/slug_uranium
	name = "Uranowy pocisk U4 NTRK 400 mm z powłoką teflonową"
	desc = "Ciężki pocisk szynowy."
	id = "slug_uranium"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/plasma = 750, /datum/material/uranium = 500)
	construction_time=10
	build_path = /obj/item/ship_weapon/ammunition/railgun_ammo/uranium
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
