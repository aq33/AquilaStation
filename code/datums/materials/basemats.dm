///Has no special properties.
/datum/material/iron
	name = "iron"
	id = "iron"
	desc = "Pospolita ruda żelaza, często spotykana w osadowych i magmowych warstwach skorupy."
	color = "#878687"
	greyscale_colors = "#878687"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/iron
	sheet_recipes_glob = "metal_recipes"
	value_per_unit = 0.0025

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	id = "glass"
	desc = "Szkło wytopione z piasku."
	color = "#88cdf1"
	greyscale_colors = "#88cdf196"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE/*, MAT_CATEGORY_BASE_RECIPES = TRUE*/) //Excluding glass for now
	integrity_modifier = 0.1
	sheet_type = /obj/item/stack/sheet/glass
	value_per_unit = 0.0025

/*
Color matrices are like regular colors but unlike with normal colors, you can go over 255 on a channel.
Unless you know what you're doing, only use the first three numbers. They're in RGB order.
*/


///Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	id = "silver"
	desc = "Srebro"
	color = list(255/255, 284/255, 302/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#e3f1f8"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	sheet_recipes_glob = "silver_recipes"
	value_per_unit = 0.025

///Slight force increase
/datum/material/gold
	name = "gold"
	id = "gold"
	desc = "Złoto"
	color = list(340/255, 240/255, 50/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //gold is shiny, but not as bright as bananium
	greyscale_colors = "#dbdd4c"
	strength_modifier = 1.2
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/gold
	sheet_recipes_glob = "gold_recipes"
	value_per_unit = 0.0625

///Has no special properties
/datum/material/diamond
	name = "diamond"
	id = "diamond"
	desc = "Węgiel pod ogromnym ciśnieniem"
	color = list(48/255, 272/255, 301/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#71c8f784"
	alpha = 132
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE/*, MAT_CATEGORY_BASE_RECIPES = TRUE*/)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	value_per_unit = 0.25

///Is slightly radioactive
/datum/material/uranium
	name = "uranium"
	id = "uranium"
	desc = "Uran"
	color = rgb(48, 237, 26)
	greyscale_colors = rgb(48, 237, 26)
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	sheet_recipes_glob = "uranium_recipes"
	value_per_unit = 0.05

/datum/material/uranium/on_applied(atom/source, amount, material_flags)
	. = ..()
	// AQ EDIT START - promieniowanie z Bee#13442: uranowe konstrukcje pulsują, przedmioty nie (górnik z rudą)
	if(isitem(source))
		return
	source.AddElement(/datum/element/radioactive)
	// AQ EDIT END

/datum/material/uranium/on_removed(atom/source, material_flags)
	. = ..()
	// AQ EDIT START - promieniowanie z Bee#13442
	if(isitem(source))
		return
	source.RemoveElement(/datum/element/radioactive)
	// AQ EDIT END


///Adds firestacks on hit (Still needs support to turn into gas on destruction)
/datum/material/plasma
	name = "plasma"
	id = "plasma"
	desc = "Czy plazma to nie jest przypadkiem stan skupienia? Zresztą nieważne."
	color = list(298/255, 46/255, 352/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#c162ec"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	sheet_recipes_glob = "plasma_recipes"
	value_per_unit = 0.1

/datum/material/plasma/on_applied(atom/source, amount, material_flags)
	. = ..()
	if(ismovableatom(source))
		source.AddElement(/datum/element/firestacker, amount=1)
		source.AddComponent(/datum/component/explodable, 0, 0, amount / 1000, amount / 500)

/datum/material/plasma/on_removed(atom/source, material_flags)
	. = ..()
	source.RemoveElement(/datum/element/firestacker, amount=1)
	qdel(source.GetComponent(/datum/component/explodable))

///Can cause bluespace effects on use. (Teleportation) (Not yet implemented)
/datum/material/bluespace
	name = "bluespace crystal"
	id = "bluespace_crystal"
	desc = "Kryształy o właściwościach bluespace"
	color = list(119/255, 217/255, 396/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#4e7dffC8"
	alpha = 200
	categories = list(MAT_CATEGORY_ORE = TRUE)
	sheet_type = /obj/item/stack/ore/bluespace_crystal/refined
	value_per_unit = 0.15

///Honks and slips
/datum/material/bananium
	name = "bananium"
	id = "bananium"
	desc = "Materiał o przezabawnych właściwościach"
	color = list(460/255, 464/255, 0, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //obnoxiously bright yellow
	greyscale_colors = "#ffff00"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	sheet_recipes_glob = "bananium_recipes"
	value_per_unit = 0.5

/datum/material/bananium/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.LoadComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)
	source.AddComponent(/datum/component/slippery, min(amount / 10, 80), null, min(amount / 20, 40), _force_drop = TRUE) //NSV13 - added stuns and accidents

/datum/material/bananium/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/slippery))
	qdel(source.GetComponent(/datum/component/squeak))


///Mediocre force increase
/datum/material/titanium
	name = "titanium"
	id = "titanium"
	desc = "Tytan"
	color = "#b3c0c7"
	greyscale_colors = "#b3c0c7"
	strength_modifier = 1.3
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	sheet_recipes_glob = "titanium_recipes"
	value_per_unit = 0.0625

///Force decrease
/datum/material/plastic
	name = "plastic"
	id = "plastic"
	desc = "Plastik"
	color = "#caccd9"
	greyscale_colors = "#caccd9"
	strength_modifier = 0.85
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/plastic
	sheet_recipes_glob = "plastic_recipes"
	value_per_unit = 0.0125

///Force decrease and mushy sound effect. (Not yet implemented)
/datum/material/biomass
	name = "biomass"
	id = "biomass"
	desc = "Materia organiczna"
	color = "#735b4d"
	greyscale_colors = "#735b4d"
	strength_modifier = 0.8
	value_per_unit = 0.025


///Stronk force increase
/datum/material/adamantine
	name = "adamantine"
	id = "adamantine"
	desc = "Potężny materiał zrobiony z magii, to znaczy z nauki!"
	color = "#6d7e8e"
	greyscale_colors = "#6d7e8e"
	strength_modifier = 1.5
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/adamantine
	sheet_recipes_glob = "adamantine_recipes"
	value_per_unit = 0.25

/datum/material/copper
	name = "copper"
	id = "copper"
	desc = "Miedź to miękki, kowalny i ciągliwy metal o bardzo wysokim przewodnictwie cieplnym i elektrycznym."
	color = "#d95802"
	greyscale_colors = "#d95802"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/copper
	sheet_recipes_glob = "copper_recipes"
