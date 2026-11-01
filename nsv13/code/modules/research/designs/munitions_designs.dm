//Missile factory
/datum/design/missilebuilder
	name = "Automatyczny klucz do rakiet"
	desc = "Maszyna, która wykonuje część procesu budowy rakiet."
	id = "missilebuilder"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missilewelder
	name = "Automatyczna spawarka do rakiet"
	desc = "Maszyna, która wykonuje część procesu budowy rakiet."
	id = "missilewelder"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/welder
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missilescrewer
	name = "Automatyczna wkrętarka do rakiet"
	desc = "Maszyna, która wykonuje część procesu budowy rakiet."
	id = "missilescrewer"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/screwdriver
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missilewirer
	name = "Automatyczny okablowywacz do rakiet"
	desc = "Maszyna, która wykonuje część procesu budowy rakiet."
	id = "missilewirer"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/wirer
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/missileassembler
	name = "Montażownica rakiet"
	desc = "Specjalistyczne ramię robotyczne, które montuje w obudowach rakiet podzespoły z magazynu."
	id = "missileassembler"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500, /datum/material/copper = 2500, /datum/material/plasma = 10000)
	build_path = /obj/item/circuitboard/machine/missile_builder/assembler
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/slowconveyor
	name = "Wolny taśmociąg"
	desc = "Specjalistyczny taśmociąg typu „odpal i zapomnij”, dostrojony dokładnie do tempa pracy maszyn budujących rakiety."
	id = "slowconveyor"
	build_type = PROTOLATHE|AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/stack/conveyor/slow
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO|DEPARTMENTAL_FLAG_MUNITIONS

//Parts that fit Torps and Missiles

/datum/design/guidance_system
	name = "Układ naprowadzania pocisku kierowanego"
	desc = "Standardowy projekt układu naprowadzania pocisków kierowanych."
	id = "guidance_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 250, /datum/material/gold = 300, /datum/material/copper = 250)
	build_path = /obj/item/ship_weapon/parts/missile/guidance_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/propulsion_system
	name = "Układ napędowy pocisku kierowanego"
	desc = "Standardowy projekt układu napędowego pocisków kierowanych."
	id = "propulsion_system"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/titanium = 250, /datum/material/plasma = 250)
	build_path = /obj/item/ship_weapon/parts/missile/propulsion_system
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/iff_card
	name = "Karta IFF pocisku kierowanego"
	desc = "Standardowy projekt karty IFF pocisków kierowanych."
	id = "iff_card"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 500, /datum/material/gold = 500)
	build_path = /obj/item/ship_weapon/parts/missile/iff_card
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Missile Parts

/datum/design/missile_warhead
	name = "Standardowa głowica rakiety"
	desc = "Standardowy projekt głowicy rakiety."
	id = "missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500, /datum/material/copper = 500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS


//Torp Parts

/datum/design/warhead
	name = "Głowica torpedy"
	desc = "Standardowy projekt głowicy torpedy."
	id = "warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/plasma = 4000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/torpedo
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/bb_warhead
	name = "Głowica torpedy przeciwbunkrowej"
	desc = "Projekt głowicy przeciwbunkrowej do torped."
	id = "bb_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/plasma = 5000, /datum/material/gold = 2000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/bunker_buster
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/decoy_warhead
	name = "Głowica torpedy-wabika"
	desc = "Projekt głowicy-wabika do torped."
	id = "decoy_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500, /datum/material/copper = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/decoy
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/freight_warhead
	name = "Głowica torpedy transportowej"
	desc = "Wydrążony stożek dziobowy, dzięki któremu torpeda może przewozić ładunek."
	id = "freight_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/copper = 500)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/freight
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/hellfire_warhead
	name = "Głowica torpedy Hellfire"
	desc = "Projekt zapalającej głowicy do torped."
	id = "hellfire_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/copper = 1000, /datum/material/plasma = 7500, /datum/material/gold = 1500, /datum/material/uranium = 5000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/hellfire
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/probe_warhead
	name = "Głowica sondy astrometrycznej"
	desc = "Zestaw czujników, który zamienia obudowę torpedy w zaawansowaną sondę do badań astrometrycznych."
	id = "probe_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/titanium= 1000, /datum/material/gold=1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/probe
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/proto_disruption_warhead
	name = "Głowica torpedy zakłócającej (prototyp)"
	desc = "Prototypowa głowica EMP do torped."
	id = "proto_disruption_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/plasma = 3000, /datum/material/gold = 1500, /datum/material/uranium = 10000, /datum/material/titanium = 2000, /datum/material/diamond = 200)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/proto_disruption
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Naval Cannons
/datum/design/naval_shell
	name = "Pocisk artylerii okrętowej"
	desc = "Pocisk dużego kalibru do działa pokładowego. (UWAGA: do przenoszenia potrzebny jest wózek!)"
	id = "naval_shell"
	materials = list(/datum/material/iron = 10000, /datum/material/titanium=5000, /datum/material/copper=500)
	build_path = /obj/item/ship_weapon/ammunition/naval_artillery
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/naval_shell_ap
	name = "Pocisk artylerii okrętowej (przeciwpancerny)"
	desc = "Przeciwpancerny pocisk z diamentowym czubkiem do działa pokładowego. (UWAGA: do przenoszenia potrzebny jest wózek!)"
	id = "naval_shell_ap"
	materials = list(/datum/material/iron = 10000, /datum/material/titanium=1000, /datum/material/diamond=2000)
	build_path = /obj/item/ship_weapon/ammunition/naval_artillery/ap
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/powder_bag
	name = "Worek prochu"
	desc = "Worek materiału wybuchowego do dział pokładowych."
	id = "powder_bag"
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/powder_bag
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/plasma_accelerant
	name = "Plazmowy przyspieszacz pocisków"
	desc = "Potężny ładunek prochowy do dział pokładowych, który rozpędza pocisk do szalonych prędkości."
	id = "plasma_accelerant"
	materials = list(/datum/material/iron = 500, /datum/material/plasma = 1500)
	build_path = /obj/item/powder_bag/plasma
	category = list("Advanced Munitions")
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Railgun Because you can still get the funny from missions
/datum/design/railgun_round
	name = "Wolframowy pocisk M4 NTRS 400 mm z powłoką teflonową"
	desc = "Pozwala wytwarzać amunicję do działa szynowego."
	id = "railgun_round"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=5000, /datum/material/titanium=5000, /datum/material/silver=1000,)
	build_path = /obj/item/ship_weapon/ammunition/railgun_ammo
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Broadside ammo parts!
/datum/design/broadside_casing
	name = "Wzmacniana tytanem łuska pocisku burtowego"
	desc = "Pozwala wytwarzać łuski pocisków burtowych."
	id = "broadside_casing"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=500, /datum/material/titanium=1500)
	build_path = /obj/item/ship_weapon/parts/broadside_casing
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/broadside_load
	name = "Ładunek pocisku burtowego 250 mm w powłoce uranowej"
	desc = "Pozwala wytwarzać ładunki pocisków burtowych."
	id = "broadside_load"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=1500, /datum/material/titanium=500)
	build_path = /obj/item/ship_weapon/parts/broadside_load
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/broadside_load/broadside_load_uranium
	name = "Ładunek pocisku burtowego 250 mm ze zubożonego uranu"
	desc = "Pozwala wytwarzać jądrowe ładunki pocisków burtowych."
	id = "broadside_load_uranium"
	build_type = PROTOLATHE
	materials = list(/datum/material/uranium=1500, /datum/material/titanium=500)
	build_path = /obj/item/ship_weapon/parts/broadside_load/uranium
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/swabber
	name = "Wycior do luf dział burtowych"
	desc = "Pozwala wytwarzać wycior do czyszczenia."
	id = "swabber"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=1000)
	build_path = /obj/item/swabber
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Plasma ball for plasma caster
/datum/design/plasma_core
	name = "Skondensowany rdzeń foronu"
	desc = "Pozwala syntetyzować skondensowane rdzenie foronu do MPAC."
	id = "plasma_core"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma=40000, /datum/material/iron=10000)
	build_path = /obj/item/ship_weapon/ammunition/plasma_core
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
