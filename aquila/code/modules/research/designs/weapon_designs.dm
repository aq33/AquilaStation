/*********************************\
|*********** LASER GUNS **********|
\*********************************/
/datum/design/oldlasergun
	name = "Prototypowy karabin laserowy"
	desc = "Laser pierwszej generacji, czyli wskaźnik laserowy dużej mocy."
	id = "firstgenlasergun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 10000, /datum/material/silver = 10000, /datum/material/copper = 10000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/laser/retro/old/research

/datum/design/lasergun
	name = "Karabin laserowy"
	desc = "Standardowy wskaźnik laserowy dużej mocy."
	id = "lasergun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 5000, /datum/material/copper = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/laser/research

/datum/design/lasercannon
	name = "Działo laserowe"
	desc = "Broń laserowa trzeciej generacji. Nie tylko skupia i załamuje światło, ale jej wiązka w locie zyskuje też energię kinetyczną!"
	id = "lasercannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 10000, /datum/material/glass = 10000, /datum/material/silver = 10000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/lasercannon/research

/*********************************\
|*********** ENERGY GUNS **********|
\*********************************/
//egun taki drogi by nie zastąpił normalnej broni oraz nie dał tak łatwo dostępu do tasera
/datum/design/oldenergygun
	name = "Prototypowa broń energetyczna"
	desc = "Pierwsza próba stworzenia broni hybrydowej."
	id = "firstgenegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 15000, /datum/material/silver = 10000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/e_gun/old/research

/datum/design/energygun
	name = "Broń energetyczna"
	desc = "Standardowy wzór, który w trybie ogłuszania używa niższej częstotliwości, przez co oszczędniej zużywa energię."
	id = "energy_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 5000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/e_gun/research

/datum/design/tacticalegun
	name = "Taktyczna broń energetyczna"
	desc = "Wojskowa broń promieniowa do operacji taktycznych."
	id = "tacticalegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 5000, /datum/material/glass = 10000, /datum/material/silver = 5000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/e_gun/stun/research

/*********************************\
|*********** PULSE GUNS ***********|
\*********************************/
//i tak nie jest używany oprócz DS raz na nigdy, też nie będzie taki tani by nie było za dobrze
/datum/design/pulsegun
	name = "Karabin pulsacyjny"
	desc = "Najlepsza broń energetyczna, stworzona, by zabijać, niszczyć i obezwładniać."
	id = "pulsegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 20000, /datum/material/diamond = 10000, /datum/material/silver = 10000, /datum/material/plasma = 10000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/pulse/research

/*********************************\
|*********** STUN GUNS ***********|
\*********************************/
/datum/design/disabler
	name = "Disabler"
	desc = "Broń do samoobrony, która męczy organiczne cele, osłabiając je, aż padną."
	id = "disabler"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/disabler
