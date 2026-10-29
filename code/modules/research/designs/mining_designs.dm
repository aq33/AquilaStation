
/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/cargo_express
	name = "Projekt komputera (ekspresowa konsola zaopatrzenia)"//shes beautiful
	desc = "Pozwala wykonać płytki drukowane do budowy ekspresowej konsoli zaopatrzenia."//who?
	id = "cargoexpress"//the coder reading this
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/circuitboard/computer/cargo/express
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/bluespace_pod
	name = "Dysk ulepszenia kapsuł zrzutowych"
	desc = "Pozwala ekspresowej konsoli zaopatrzenia wzywać kapsułę zrzutową bluespace, co znacznie zwiększa bezpieczeństwo użytkownika."//who?
	id = "bluespace_pod"//the coder reading this
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/disk/cargo/bluespace_pod
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/drill
	name = "Wiertło górnicze"
	desc = "Oto wiertło, które przebije skalne ściany."
	id = "drill"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1000) //expensive, but no need for miners.
	build_path = /obj/item/pickaxe/drill
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/drill_diamond
	name = "Diamentowe wiertło górnicze"
	desc = "Oto wiertło, które przebije niebiosa!"
	id = "drill_diamond"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1000, /datum/material/diamond = 2000) //Yes, a whole diamond is needed.
	build_path = /obj/item/pickaxe/drill/diamonddrill
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmacutter
	name = "Przecinak plazmowy"
	desc = "Można nim odcinać kończyny ksenomorfom! Albo, no wiesz, kopać."
	id = "plasmacutter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 500, /datum/material/plasma = 400)
	build_path = /obj/item/gun/energy/plasmacutter
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmacutter_adv
	name = "Zaawansowany przecinak plazmowy"
	desc = "To zaawansowany przecinak plazmowy, o mój Boże."
	id = "plasmacutter_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/plasma = 2000, /datum/material/gold = 500)
	build_path = /obj/item/gun/energy/plasmacutter/adv
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/jackhammer
	name = "Soniczny młot pneumatyczny"
	desc = "W zasadzie ręczny rozłupywacz planet. Bez trudu przewierca się też przez ściany."
	id = "jackhammer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 2000, /datum/material/silver = 2000, /datum/material/diamond = 6000)
	build_path = /obj/item/pickaxe/drill/jackhammer
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/superresonator
	name = "Ulepszony rezonator"
	desc = "Ulepszona wersja rezonatora, która pozwala utrzymać więcej aktywnych pól naraz."
	id = "superresonator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/silver = 1000, /datum/material/uranium = 1000)
	build_path = /obj/item/resonator/upgraded
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/trigger_guard_mod
	name = "Moduł kinetycznego akceleratora: kabłąk spustu"
	desc = "Urządzenie, które pozwala każdemu organizmowi posługiwać się kinetycznym akceleratorem."
	id = "triggermod"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/damage_mod
	name = "Moduł kinetycznego akceleratora: obrażenia"
	desc = "Urządzenie, które pozwala kinetycznym akceleratorom zadawać więcej obrażeń."
	id = "damagemod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/damage
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/cooldown_mod
	name = "Moduł kinetycznego akceleratora: przeładowanie"
	desc = "Urządzenie, które skraca czas przeładowania kinetycznego akceleratora."
	id = "cooldownmod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/range_mod
	name = "Moduł kinetycznego akceleratora: zasięg"
	desc = "Urządzenie, które zwiększa zasięg strzału kinetycznego akceleratora."
	id = "rangemod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/range
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/hyperaccelerator
	name = "Moduł kinetycznego akceleratora: górniczy obszarowy"
	desc = "Zestaw modyfikacyjny kinetycznego akceleratora, dzięki któremu broń strzela obszarowymi wybuchami kruszącymi skałę."
	id = "hypermod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 1500, /datum/material/silver = 2000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
