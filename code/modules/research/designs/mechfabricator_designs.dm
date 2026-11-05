//Cyborg
/datum/design/borg_suit
	name = "Endoszkielet cyborga"
	id = "borg_suit"
	build_type = MECHFAB
	build_path = /obj/item/robot_suit
	materials = list(/datum/material/iron=15000)
	construction_time = 500
	category = list("Cyborg")

/datum/design/borg_chest
	name = "Tułów cyborga"
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/robot
	materials = list(/datum/material/iron=40000)
	construction_time = 350
	category = list("Cyborg")

/datum/design/borg_head
	name = "Głowa cyborga"
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/robot
	materials = list(/datum/material/iron=5000)
	construction_time = 350
	category = list("Cyborg")

/datum/design/borg_l_arm
	name = "Lewa ręka cyborga"
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/l_arm/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_arm
	name = "Prawa ręka cyborga"
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/r_arm/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_l_leg
	name = "Lewa noga cyborga"
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/l_leg/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_leg
	name = "Prawa noga cyborga"
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/r_leg/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list("Cyborg")

//Ripley
/datum/design/ripley_chassis
	name = "Rama egzoszkieletu (APLU \"Ripley\")"
	id = "ripley_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list("Ripley")

//firefighter subtype
/datum/design/firefighter_chassis
	name = "Rama egzoszkieletu (APLU \"Firefighter\")"
	id = "firefighter_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list("Firefighter")

/datum/design/ripley_torso
	name = "Tors egzoszkieletu (APLU \"Ripley\")"
	id = "ripley_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 7500)
	construction_time = 200
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_arm
	name = "Lewe ramię egzoszkieletu (APLU \"Ripley\")"
	id = "ripley_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_arm
	name = "Prawe ramię egzoszkieletu (APLU \"Ripley\")"
	id = "ripley_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_leg
	name = "Lewa noga egzoszkieletu (APLU \"Ripley\")"
	id = "ripley_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_leg
	name = "Prawa noga egzoszkieletu (APLU \"Ripley\")"
	id = "ripley_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

//Odysseus
/datum/design/odysseus_chassis
	name = "Rama egzoszkieletu (\"Odysseus\")"
	id = "odysseus_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list("Odysseus")

/datum/design/odysseus_torso
	name = "Tors egzoszkieletu (\"Odysseus\")"
	id = "odysseus_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(/datum/material/iron=12000)
	construction_time = 180
	category = list("Odysseus")

/datum/design/odysseus_head
	name = "Głowa egzoszkieletu (\"Odysseus\")"
	id = "odysseus_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(/datum/material/iron=6000,/datum/material/glass = 10000)
	construction_time = 100
	category = list("Odysseus")

/datum/design/odysseus_left_arm
	name = "Lewe ramię egzoszkieletu (\"Odysseus\")"
	id = "odysseus_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(/datum/material/iron=6000)
	construction_time = 120
	category = list("Odysseus")

/datum/design/odysseus_right_arm
	name = "Prawe ramię egzoszkieletu (\"Odysseus\")"
	id = "odysseus_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(/datum/material/iron=6000)
	construction_time = 120
	category = list("Odysseus")

/datum/design/odysseus_left_leg
	name = "Lewa noga egzoszkieletu (\"Odysseus\")"
	id = "odysseus_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(/datum/material/iron=7000)
	construction_time = 130
	category = list("Odysseus")

/datum/design/odysseus_right_leg
	name = "Prawa noga egzoszkieletu (\"Odysseus\")"
	id = "odysseus_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(/datum/material/iron=7000)
	construction_time = 130
	category = list("Odysseus")

//Gygax
/datum/design/gygax_chassis
	name = "Rama egzoszkieletu (\"Gygax\")"
	id = "gygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list("Gygax")

/datum/design/gygax_torso
	name = "Tors egzoszkieletu (\"Gygax\")"
	id = "gygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 10000,/datum/material/gold=2000, /datum/material/silver=2000)
	construction_time = 300
	category = list("Gygax")

/datum/design/gygax_head
	name = "Głowa egzoszkieletu (\"Gygax\")"
	id = "gygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(/datum/material/iron=10000,/datum/material/glass = 5000, /datum/material/gold=2000, /datum/material/silver=2000)
	category = list("Gygax")

/datum/design/gygax_left_arm
	name = "Lewe ramię egzoszkieletu (\"Gygax\")"
	id = "gygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(/datum/material/iron=15000, /datum/material/gold=1000, /datum/material/silver=1000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_right_arm
	name = "Prawe ramię egzoszkieletu (\"Gygax\")"
	id = "gygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(/datum/material/iron=15000, /datum/material/gold=1000, /datum/material/silver=1000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_left_leg
	name = "Lewa noga egzoszkieletu (\"Gygax\")"
	id = "gygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(/datum/material/iron=15000, /datum/material/gold=2000, /datum/material/silver=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_right_leg
	name = "Prawa noga egzoszkieletu (\"Gygax\")"
	id = "gygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(/datum/material/iron=15000, /datum/material/gold=2000, /datum/material/silver=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_armor
	name = "Płyty pancerza egzoszkieletu (\"Gygax\")"
	id = "gygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armor
	materials = list(/datum/material/iron=15000,/datum/material/gold=10000, /datum/material/silver=10000, /datum/material/titanium=10000)
	construction_time = 600
	category = list("Gygax")

//Durand
/datum/design/durand_chassis
	name = "Rama egzoszkieletu (\"Durand\")"
	id = "durand_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(/datum/material/iron=25000)
	construction_time = 100
	category = list("Durand")

/datum/design/durand_torso
	name = "Tors egzoszkieletu (\"Durand\")"
	id = "durand_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(/datum/material/iron=25000, /datum/material/glass = 10000,/datum/material/silver=10000)
	construction_time = 300
	category = list("Durand")

/datum/design/durand_head
	name = "Głowa egzoszkieletu (\"Durand\")"
	id = "durand_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(/datum/material/iron=10000,/datum/material/glass = 15000,/datum/material/silver=2000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_left_arm
	name = "Lewe ramię egzoszkieletu (\"Durand\")"
	id = "durand_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(/datum/material/iron=10000,/datum/material/silver=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_right_arm
	name = "Prawe ramię egzoszkieletu (\"Durand\")"
	id = "durand_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(/datum/material/iron=10000,/datum/material/silver=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_left_leg
	name = "Lewa noga egzoszkieletu (\"Durand\")"
	id = "durand_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(/datum/material/iron=15000,/datum/material/silver=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_right_leg
	name = "Prawa noga egzoszkieletu (\"Durand\")"
	id = "durand_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(/datum/material/iron=15000,/datum/material/silver=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_armor
	name = "Płyty pancerza egzoszkieletu (\"Durand\")"
	id = "durand_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armor
	materials = list(/datum/material/iron=30000,/datum/material/uranium=25000,/datum/material/titanium=20000)
	construction_time = 600
	category = list("Durand")

//H.O.N.K
/datum/design/honk_chassis
	name = "Rama egzoszkieletu (\"H.O.N.K\")"
	id = "honk_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list("H.O.N.K")

/datum/design/honk_torso
	name = "Tors egzoszkieletu (\"H.O.N.K\")"
	id = "honk_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 10000,/datum/material/bananium=10000)
	construction_time = 300
	category = list("H.O.N.K")

/datum/design/honk_head
	name = "Głowa egzoszkieletu (\"H.O.N.K\")"
	id = "honk_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	materials = list(/datum/material/iron=10000,/datum/material/glass = 5000,/datum/material/bananium=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_left_arm
	name = "Lewe ramię egzoszkieletu (\"H.O.N.K\")"
	id = "honk_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	materials = list(/datum/material/iron=15000,/datum/material/bananium=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_right_arm
	name = "Prawe ramię egzoszkieletu (\"H.O.N.K\")"
	id = "honk_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	materials = list(/datum/material/iron=15000,/datum/material/bananium=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_left_leg
	name = "Lewa noga egzoszkieletu (\"H.O.N.K\")"
	id = "honk_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/honker_left_leg
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_right_leg
	name = "Prawa noga egzoszkieletu (\"H.O.N.K\")"
	id = "honk_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 200
	category = list("H.O.N.K")


//Phazon
/datum/design/phazon_chassis
	name = "Rama egzoszkieletu (\"Phazon\")"
	id = "phazon_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list("Phazon")

/datum/design/phazon_torso
	name = "Tors egzoszkieletu (\"Phazon\")"
	id = "phazon_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	materials = list(/datum/material/iron=35000,/datum/material/glass = 10000,/datum/material/plasma=20000)
	construction_time = 300
	category = list("Phazon")

/datum/design/phazon_head
	name = "Głowa egzoszkieletu (\"Phazon\")"
	id = "phazon_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	materials = list(/datum/material/iron=15000,/datum/material/glass = 5000,/datum/material/plasma=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_left_arm
	name = "Lewe ramię egzoszkieletu (\"Phazon\")"
	id = "phazon_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_right_arm
	name = "Prawe ramię egzoszkieletu (\"Phazon\")"
	id = "phazon_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_left_leg
	name = "Lewa noga egzoszkieletu (\"Phazon\")"
	id = "phazon_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_right_leg
	name = "Prawa noga egzoszkieletu (\"Phazon\")"
	id = "phazon_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_armor
	name = "Płyty pancerza egzoszkieletu (\"Phazon\")"
	id = "phazon_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_armor
	materials = list(/datum/material/iron=25000,/datum/material/plasma=20000,/datum/material/titanium=20000)
	construction_time = 300
	category = list("Phazon")

//Exosuit Equipment
/datum/design/ripleyupgrade
	name = "Zestaw konwersji Ripley MK-I na MK-II"
	id = "ripleyupgrade"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	materials = list(/datum/material/iron=10000,/datum/material/plasma=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_hydraulic_clamp
	name = "Inżynieria egzoszkieletu (chwytak hydrauliczny)"
	id = "mech_hydraulic_clamp"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_drill
	name = "Górnictwo egzoszkieletu (wiertło górnicze)"
	id = "mech_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_mining_scanner
	name = "Inżynieria egzoszkieletu (skaner górniczy)"
	id = "mech_mscanner"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	materials = list(/datum/material/iron=5000,/datum/material/glass = 2500)
	construction_time = 50
	category = list("Exosuit Equipment")

/datum/design/mech_extinguisher
	name = "Inżynieria egzoszkieletu (gaśnica)"
	id = "mech_extinguisher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/extinguisher
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_generator
	name = "Moduł egzoszkieletu (generator plazmowy)"
	id = "mech_generator"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(/datum/material/iron=10000,/datum/material/glass = 1000,/datum/material/silver=2000,/datum/material/plasma=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_mousetrap_mortar
	name = "Broń H.O.N.K (moździerz pułapek na myszy)"
	id = "mech_mousetrap_mortar"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/mech_banana_mortar
	name = "Broń H.O.N.K (moździerz bananowy)"
	id = "mech_banana_mortar"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/mech_honker
	name = "Broń H.O.N.K (HoNkER BlAsT 5000)"
	id = "mech_honker"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	materials = list(/datum/material/iron=20000,/datum/material/bananium=10000)
	construction_time = 500
	category = list("Exosuit Equipment")

/datum/design/mech_punching_glove
	name = "Broń H.O.N.K (Oingo Boingo Twarzobij)"
	id = "mech_punching_face"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	materials = list(/datum/material/iron=20000,/datum/material/bananium=7500)
	construction_time = 400
	category = list("Exosuit Equipment")

/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////

/datum/design/borg_upgrade_rename
	name = "Ulepszenie cyborga (płytka zmiany nazwy)"
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(/datum/material/iron = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_restart
	name = "Ulepszenie cyborga (płytka awaryjnego restartu)"
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(/datum/material/iron = 20000 , /datum/material/glass = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_vtec
	name = "Ulepszenie cyborga (moduł VTEC)"
	id = "borg_upgrade_vtec"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	materials = list(/datum/material/iron= 35000 , /datum/material/glass = 12000 , /datum/material/uranium = 10000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_thrusters
	name = "Ulepszenie cyborga (silniki jonowe)"
	id = "borg_upgrade_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/thrusters
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000, /datum/material/plasma = 5000, /datum/material/uranium = 6000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_disablercooler
	name = "Ulepszenie cyborga (moduł szybkiego chłodzenia disablera)"
	id = "borg_upgrade_disablercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/disablercooler
	materials = list(/datum/material/iron = 20000 , /datum/material/glass = 6000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_diamonddrill
	name = "Ulepszenie cyborga (diamentowe wiertło)"
	id = "borg_upgrade_diamonddrill"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ddrill
	materials = list(/datum/material/iron=10000, /datum/material/glass = 6000, /datum/material/diamond = 2000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_holding
	name = "Ulepszenie cyborga (torba na rudę bez dna)"
	id = "borg_upgrade_holding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/soh
	materials = list(/datum/material/iron = 10000, /datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_cutter
	name = "Ulepszenie cyborga (przecinak plazmowy)"
	id = "borg_upgrade_cutter"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/cutter
	materials = list(/datum/material/iron = 10000, /datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_lavaproof
	name = "Ulepszenie cyborga (gąsienice odporne na lawę)"
	id = "borg_upgrade_lavaproof"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/lavaproof
	materials = list(/datum/material/iron = 10000, /datum/material/plasma = 4000, /datum/material/titanium = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_syndicate_module
	name = "Ulepszenie cyborga (nielegalne moduły)"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/diamond = 10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_transform_clown
	name = "Ulepszenie cyborga (moduł klauna)"
	id = "borg_transform_clown"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/transform/clown
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/bananium = 1000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_transform_security
	name = "Ulepszenie cyborga (moduł ochrony)"
	id = "borg_transform_security"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/transform/security
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/diamond = 3000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_selfrepair
	name = "Ulepszenie cyborga (samonaprawa)"
	id = "borg_upgrade_selfrepair"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/selfrepair
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_expandedsynthesiser
	name = "Ulepszenie cyborga (rozszerzony syntezator hyposprayu)"
	id = "borg_upgrade_expandedsynthesiser"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray/expanded
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/plasma = 8000, /datum/material/uranium = 8000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_piercinghypospray
	name = "Ulepszenie cyborga (przebijający hypospray)"
	id = "borg_upgrade_piercinghypospray"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/piercing_hypospray
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/titanium = 5000, /datum/material/diamond = 3000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_defibrillator
	name = "Ulepszenie cyborga (defibrylator)"
	id = "borg_upgrade_defibrillator"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/defib
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 5000, /datum/material/silver = 4000, /datum/material/gold = 3000)
	construction_time = 80
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_surgicalprocessor
	name = "Ulepszenie cyborga (procesor chirurgiczny)"
	id = "borg_upgrade_surgicalprocessor"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/processor
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 4000, /datum/material/silver = 4000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_trashofholding
	name = "Ulepszenie cyborga (worek na śmieci bez dna)"
	id = "borg_upgrade_trashofholding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/tboh
	materials = list(/datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_advancedmop
	name = "Ulepszenie cyborga (zaawansowany mop)"
	id = "borg_upgrade_advancedmop"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/amop
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_expand
	name = "Ulepszenie cyborga (powiększenie)"
	id = "borg_upgrade_expand"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/expand
	materials = list(/datum/material/iron = 200000, /datum/material/titanium = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/boris_ai_controller
	name = "Moduł zdalnego sterowania cyborgiem przez SI B.O.R.I.S."
	id = "borg_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ai
	materials = list(/datum/material/iron = 1200, /datum/material/glass = 1500, /datum/material/gold = 200)
	construction_time = 50
	category = list("Control Interfaces")
	search_metadata = "boris"

/datum/design/borg_upgrade_rped
	name = "Ulepszenie cyborga (RPED)"
	id = "borg_upgrade_rped"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rped
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_circuit_app
	name = "Ulepszenie cyborga (manipulator obwodów)"
	id = "borg_upgrade_circuitapp"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/circuit_app
	materials = list(/datum/material/iron = 2000, /datum/material/titanium = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_beaker_app
	name = "Ulepszenie cyborga (schowek na zlewki)"
	id = "borg_upgrade_beakerapp"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/beaker_app
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2250) //Need glass for the new beaker too
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_pinpointer
	name = "Ulepszenie cyborga (pinpointer załogi)"
	id = "borg_upgrade_pinpointer"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/pinpointer
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

//Misc
/datum/design/mecha_tracking
	name = "Lokalizator egzoszkieletu (nadajnik lokalizacyjny egzoszkieletu)"
	id = "mecha_tracking"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(/datum/material/iron=500)
	construction_time = 50
	category = list("Exosuit Equipment")

/datum/design/mecha_tracking_ai_control
	name = "Nadajnik sterowania SI"
	id = "mecha_tracking_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 200)
	construction_time = 50
	category = list("Control Interfaces")

/datum/design/synthetic_flash
	name = "Flash"
	desc = "Gdy pojawia się problem, rozwiązaniem jest NAUKA."
	id = "sflash"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 750, /datum/material/glass = 750)
	construction_time = 100
	build_path = /obj/item/assembly/flash/handheld/weak
	category = list("Misc")

// IPC Replacement Parts

/datum/design/robotic_liver
	name = "Procesor substancji"
	id = "robotic_liver"
	build_type = MECHFAB
	build_path = /obj/item/organ/liver/cybernetic/upgraded/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_eyes
	name = "Podstawowe robotyczne oczy"
	id = "robotic_eyes"
	build_type = MECHFAB
	build_path = /obj/item/organ/eyes/robotic
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 2000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_tongue
	name = "Robotyczny syntezator mowy"
	id = "robotic_tongue"
	build_type = MECHFAB
	build_path = /obj/item/organ/tongue/robot
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_stomach
	name = "Mikroogniwo"
	id = "robotic_stomach"
	build_type = MECHFAB
	build_path = /obj/item/organ/stomach/battery/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000, /datum/material/plasma = 200)
	construction_time = 100
	category = list("IPC Components")

/datum/design/robotic_ears
	name = "Czujniki słuchowe"
	id = "robotic_ears"
	build_type = MECHFAB
	build_path = /obj/item/organ/ears/robot
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

/datum/design/power_cord
	name = "Elektronika ładująca"
	id = "power_cord"
	build_type = MECHFAB
	build_path = /obj/item/organ/cyberimp/arm/power_cord
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list("IPC Components")

//service modules

/datum/design/borg_upgrade_botany
	name = "Specjalizacja cyborga (botanika)"
	id = "borg_upgrade_botany"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/botany
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_kitchen
	name = "Specjalizacja cyborga (gotowanie)"
	id = "borg_upgrade_kitchen"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/kitchen
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_casino
	name = "Specjalizacja cyborga (kasyno)"
	id = "borg_upgrade_casino"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/casino
	materials = list(/datum/material/iron = 2000, /datum/material/gold = 500)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_party
	name = "Specjalizacja cyborga (impreza)"
	id = "borg_upgrade_party"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/party
	materials = list(/datum/material/iron = 2000, /datum/material/diamond = 500)
	construction_time = 40
	category = list("Cyborg Upgrade Modules")

//MODsuit stuff

/datum/design/mod_shell
	name = "Skorupa MOD"
	desc = "Skorupa modułowego skafandra zaprojektowana przez Nakamura Engineering."
	id = "mod_shell"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 10000, /datum/material/plasma = 5000)
	construction_time = 25 SECONDS
	build_path = /obj/item/mod/construction/shell
	category = list("MOD Construction")

/datum/design/mod_helmet
	name = "Hełm MOD"
	desc = "Hełm modułowego skafandra zaprojektowany przez Nakamura Engineering."
	id = "mod_helmet"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/helmet
	category = list("MOD Construction")

/datum/design/mod_chestplate
	name = "Napierśnik MOD"
	desc = "Napierśnik modułowego skafandra zaprojektowany przez Nakamura Engineering."
	id = "mod_chestplate"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/chestplate
	category = list("MOD Construction")

/datum/design/mod_gauntlets
	name = "Rękawice MOD"
	desc = "Rękawice modułowego skafandra zaprojektowane przez Nakamura Engineering."
	id = "mod_gauntlets"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/gauntlets
	category = list("MOD Construction")

/datum/design/mod_boots
	name = "Buty MOD"
	desc = "Buty modułowego skafandra zaprojektowane przez Nakamura Engineering."
	id = "mod_boots"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/boots
	category = list("MOD Construction")

/datum/design/mod_plating
	name = "Zewnętrzne poszycie MOD"
	desc = "Zewnętrzne poszycie MODsuitu."
	id = "mod_plating_standard"
	build_type = MECHFAB|PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3000, /datum/material/plasma = 1000)
	construction_time = 15 SECONDS
	build_path = /obj/item/mod/construction/plating
	category = list("MOD Construction", "Equipment")
	research_icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	research_icon_state = "standard-plating"

/datum/design/mod_plating/New()
	. = ..()
	var/obj/item/mod/construction/plating/armor_type = build_path
	var/datum/mod_theme/theme = GLOB.mod_themes[initial(armor_type.theme)]
	name = "Zewnętrzne poszycie MOD (model [theme.name])"
	desc = "Zewnętrzne poszycie MODsuitu. [theme.desc]"

/datum/design/mod_plating/civilian
	name = "Zewnętrzne poszycie MOD (model cywilny)"
	id = "mod_plating_civilian"
	build_path = /obj/item/mod/construction/plating/civilian
	materials = list(
		/datum/material/iron = 3000,
		/datum/material/glass = 1500,
		/datum/material/plasma = 1000,
	)
	research_icon_state = "civilian-plating"

/datum/design/mod_plating/engineering
	id = "mod_plating_engineering"
	build_path = /obj/item/mod/construction/plating/engineering
	materials = list(
		/datum/material/iron = 6000,
		/datum/material/gold = 2000,
		/datum/material/glass = 1000,
		/datum/material/plasma = 1000
	)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
	research_icon_state = "engineering-plating"

/datum/design/mod_plating/atmospheric
	id = "mod_plating_atmospheric"
	build_path = /obj/item/mod/construction/plating/atmospheric
	materials = list(/datum/material/iron = 6000, /datum/material/titanium = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
	research_icon_state = "atmospheric-plating"

/datum/design/mod_plating/medical
	id = "mod_plating_medical"
	build_path = /obj/item/mod/construction/plating/medical
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	research_icon_state = "medical-plating"

/datum/design/mod_plating/security
	id = "mod_plating_security"
	build_path = /obj/item/mod/construction/plating/security
	materials = list(/datum/material/iron = 6000, /datum/material/uranium = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	research_icon_state = "security-plating"

/datum/design/mod_plating/cosmohonk
	id = "mod_plating_cosmohonk"
	build_path = /obj/item/mod/construction/plating/cosmohonk
	materials = list(/datum/material/iron = 6000, /datum/material/bananium = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
	research_icon_state = "cosmohonk-plating"

/datum/design/mod_paint_kit
	name = "Zestaw do malowania MOD"
	desc = "Zestaw do malowania modułowych skafandrów."
	id = "mod_paint_kit"
	build_type = MECHFAB|PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/plastic = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mod/paint
	category = list("Misc")

/datum/design/module
	name = "Moduł MOD"
	build_type = MECHFAB
	construction_time = 1 SECONDS
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module
	category = list("MOD Modules")
	var/department_type = MODULE_GENERAL

/datum/design/module/New()
	. = ..()
	var/obj/item/mod/module/module = build_path
	desc = "[initial(module.desc)] Złożoność: [initial(module.complexity)]."

/datum/design/module/mod_storage
	name = "Moduł MODsuitu: schowek"
	id = "mod_storage"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/storage

/datum/design/module/mod_storage_expanded
	name = "Moduł MODsuitu: powiększony schowek"
	id = "mod_storage_expanded"
	materials = list(/datum/material/iron = 5000, /datum/material/uranium = 2000)
	build_path = /obj/item/mod/module/storage/large_capacity

/datum/design/module/mod_visor_medhud
	name = "Moduł MODsuitu: wizjer medyczny"
	id = "mod_visor_medhud"
	materials = list(/datum/material/silver = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/medhud
	department_type = MODULE_MEDICAL

/datum/design/module/mod_visor_diaghud
	name = "Moduł MODsuitu: wizjer diagnostyczny"
	id = "mod_visor_diaghud"
	materials = list(/datum/material/gold = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/diaghud
	department_type = MODULE_SCIENCE

/datum/design/module/mod_visor_sechud
	name = "Moduł MODsuitu: wizjer ochrony"
	id = "mod_visor_sechud"
	materials = list(/datum/material/titanium = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/sechud
	department_type = MODULE_SECURITY

/datum/design/module/mod_visor_meson
	name = "Moduł MODsuitu: wizjer mezonowy"
	id = "mod_visor_meson"
	materials = list(/datum/material/uranium = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/meson
	department_type = MODULE_SUPPLY

/datum/design/module/mod_visor_welding
	name = "Moduł MODsuitu: ochrona przy spawaniu"
	id = "mod_welding"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/welding
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_t_ray
	name = "Moduł MODsuitu: skaner T-ray"
	id = "mod_t_ray"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/t_ray
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_health_analyzer
	name = "Moduł MODsuitu: analizator zdrowia"
	id = "mod_health_analyzer"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/health_analyzer
	department_type = MODULE_MEDICAL

/datum/design/module/mod_stealth
	name = "Moduł MODsuitu: maskowanie"
	id = "mod_stealth"
	materials = list(/datum/material/iron = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/mod/module/stealth
	department_type = MODULE_SECURITY

/datum/design/module/mod_jetpack
	name = "Moduł MODsuitu: jonowy plecak odrzutowy"
	id = "mod_jetpack"
	materials = list(/datum/material/iron = 1500, /datum/material/plasma = 1000)
	build_path = /obj/item/mod/module/jetpack

/datum/design/module/mod_magboot
	name = "Moduł MODsuitu: stabilizacja magnetyczna"
	id = "mod_magboot"
	materials = list(/datum/material/iron = 1000, /datum/material/gold = 500)
	build_path = /obj/item/mod/module/magboot
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_mag_harness
	name = "Moduł MODsuitu: uprząż magnetyczna"
	id = "mod_mag_harness"
	materials = list(/datum/material/iron = 1500, /datum/material/silver = 500)
	build_path = /obj/item/mod/module/magnetic_harness
	department_type = MODULE_SECURITY

/datum/design/module/mod_tether
	name = "Moduł MODsuitu: awaryjna lina"
	id = "mod_tether"
	materials = list(/datum/material/iron = 1000, /datum/material/silver = 500)
	build_path = /obj/item/mod/module/tether
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_mouthhole
	name = "Moduł MODsuitu: aparat do jedzenia"
	id = "mod_mouthhole"
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/mod/module/mouthhole

/datum/design/module/mod_rad_protection
	name = "Moduł MODsuitu: ochrona przed promieniowaniem"
	id = "mod_rad_protection"
	materials = list(/datum/material/iron = 1000, /datum/material/uranium = 1000)
	build_path = /obj/item/mod/module/rad_protection
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_emp_shield
	name = "Moduł MODsuitu: osłona EMP"
	id = "mod_emp_shield"
	materials = list(/datum/material/iron = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/mod/module/emp_shield

/datum/design/module/mod_flashlight
	name = "Moduł MODsuitu: latarka"
	id = "mod_flashlight"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/flashlight

/datum/design/module/mod_reagent_scanner
	name = "Moduł MODsuitu: skaner odczynników"
	id = "mod_reagent_scanner"
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/mod/module/reagent_scanner
	department_type = MODULE_SCIENCE

/datum/design/module/mod_gps
	name = "Moduł MODsuitu: wewnętrzny GPS"
	id = "mod_gps"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/gps
	department_type = MODULE_SUPPLY

/datum/design/module/mod_constructor
	name = "Moduł MODsuitu: konstruktor"
	id = "mod_constructor"
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/mod/module/constructor
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_quick_carry
	name = "Moduł MODsuitu: szybkie noszenie"
	id = "mod_quick_carry"
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/mod/module/quick_carry
	department_type = MODULE_MEDICAL

/datum/design/module/mod_longfall
	name = "Moduł MODsuitu: bezpieczny upadek"
	id = "mod_longfall"
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/mod/module/longfall

/datum/design/module/mod_thermal_regulator
	name = "Moduł MODsuitu: regulator temperatury"
	id = "mod_thermal_regulator"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/thermal_regulator

/datum/design/module/mod_injector
	name = "Moduł MODsuitu: iniektor"
	id = "mod_injector"
	materials = list(/datum/material/iron = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/mod/module/injector
	department_type = MODULE_MEDICAL

/datum/design/module/mod_bikehorn
	name = "Moduł MODsuitu: trąbka rowerowa"
	id = "mod_bikehorn"
	materials = list(/datum/material/plastic = 500, /datum/material/iron = 500)
	build_path = /obj/item/mod/module/bikehorn
	department_type = MODULE_SERVICE

/datum/design/module/mod_microwave_beam
	name = "Moduł MODsuitu: wiązka mikrofalowa"
	id = "mod_microwave_beam"
	materials = list(/datum/material/iron = 1000, /datum/material/uranium = 500)
	build_path = /obj/item/mod/module/microwave_beam
	department_type = MODULE_SERVICE

/datum/design/module/mod_waddle
	name = "Moduł MODsuitu: kaczy chód"
	id = "mod_waddle"
	materials = list(/datum/material/plastic = 1000, /datum/material/iron = 1000)
	build_path = /obj/item/mod/module/waddle
	department_type = MODULE_SERVICE

/datum/design/module/mod_clamp
	name = "Moduł MODsuitu: chwytak hydrauliczny"
	id = "mod_clamp"
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/mod/module/clamp
	department_type = MODULE_SUPPLY

/datum/design/module/mod_drill
	name = "Moduł MODsuitu: wiertło"
	id = "mod_drill"
	materials = list(/datum/material/silver = 1000, /datum/material/iron = 2000)
	build_path = /obj/item/mod/module/drill
	department_type = MODULE_SUPPLY

/datum/design/module/mod_orebag
	name = "Moduł MODsuitu: torba na rudę"
	id = "mod_orebag"
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/mod/module/orebag
	department_type = MODULE_SUPPLY

/datum/design/module/mod_organ_thrower
	name = "Moduł MODsuitu: miotacz organów"
	id = "mod_organ_thrower"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/organ_thrower
	department_type = MODULE_MEDICAL

/datum/design/module/mod_pathfinder
	name = "Moduł MODsuitu: nawigator"
	id = "mod_pathfinder"
	materials = list(/datum/material/uranium = 1000, /datum/material/iron = 1000)
	build_path = /obj/item/mod/module/pathfinder

/datum/design/module/mod_dna_lock
	name = "Moduł MODsuitu: blokada DNA"
	id = "mod_dna_lock"
	materials = list(/datum/material/diamond = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/dna_lock

/datum/design/module/mod_plasma_stabilizer
	name = "Moduł MODsuitu: stabilizator plazmy"
	id = "mod_plasma"
	materials = list(/datum/material/plasma = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/plasma_stabilizer

/datum/design/module/mister_atmos
	name = "Moduł MODsuitu: zraszacz żywicy"
	id = "mod_mister_atmos"
	materials = list(/datum/material/glass = 1000, /datum/material/titanium = 1500)
	build_path = /obj/item/mod/module/mister/atmos
	department_type = MODULE_ENGINEERING

/datum/design/module/mod_holster
	name = "Moduł MODsuitu: kabura"
	id = "mod_holster"
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/holster
	department_type = MODULE_SECURITY

/datum/design/module/mod_sonar
	name = "Moduł MODsuitu: aktywny sonar"
	id = "mod_sonar"
	materials = list(/datum/material/titanium = 250, /datum/material/glass = 1000, /datum/material/gold = 500, /datum/material/uranium = 250)
	build_path = /obj/item/mod/module/active_sonar
	department_type = MODULE_SECURITY

/datum/design/module/projectile_dampener
	name = "Moduł MODsuitu: tłumik pocisków"
	id = "mod_projectile_dampener"
	materials = list(/datum/material/iron = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/mod/module/projectile_dampener
	department_type = MODULE_SECURITY

/datum/design/module/surgicalprocessor
	name = "Moduł MODsuitu: procesor chirurgiczny"
	id = "mod_surgicalprocessor"
	materials = list(/datum/material/titanium = 250, /datum/material/glass = 1000, /datum/material/silver = 1500)
	build_path = /obj/item/mod/module/surgical_processor
	department_type = MODULE_MEDICAL

/datum/design/module/threadripper
	name = "Moduł MODsuitu: rozpruwacz nici"
	id = "mod_threadripper"
	materials = list(/datum/material/titanium = 250, /datum/material/plastic = 1000, /datum/material/silver = 1500)
	build_path = /obj/item/mod/module/thread_ripper
	department_type = MODULE_MEDICAL

/datum/design/module/defibrillator
	name = "Moduł MODsuitu: defibrylator"
	id = "mod_defib"
	materials = list(/datum/material/titanium = 250, /datum/material/diamond = 1000, /datum/material/silver = 1500)
	build_path = /obj/item/mod/module/defibrillator
	department_type = MODULE_MEDICAL

/datum/design/module/statusreadout
	name = "Moduł MODsuitu: odczyt stanu"
	id = "mod_statusreadout"
	materials = list(
		/datum/material/iron = 1500,
		/datum/material/glass = 500,
		/datum/material/titanium = 800,
	)
	build_path = /obj/item/mod/module/status_readout

//MODsuit bepis modules

/datum/design/module/disposal
	name = "Moduł MODsuitu: złącze zsypu"
	id = "mod_disposal"
	materials = list(/datum/material/iron = 2500, /datum/material/titanium = 1000)
	build_path = /obj/item/mod/module/disposal_connector
	department_type = MODULE_SUPPLY

//MODsuit anomalock modules

/datum/design/module/mod_antigrav
	name = "Moduł MODsuitu: antygrawitacja"
	id = "mod_antigrav"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000, /datum/material/uranium = 2000)
	build_path = /obj/item/mod/module/anomaly_locked/antigrav
	department_type = MODULE_SCIENCE

/datum/design/module/mod_teleporter
	name = "Moduł MODsuitu: teleporter"
	id = "mod_teleporter"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000, /datum/material/bluespace = 2000)
	build_path = /obj/item/mod/module/anomaly_locked/teleporter
	department_type = MODULE_SCIENCE

/datum/design/module/mod_kinesis
	name = "Moduł MODsuitu: kineza"
	id = "mod_kinesis"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000, /datum/material/uranium = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/mod/module/anomaly_locked/kinesis
	department_type = MODULE_ENGINEERING
