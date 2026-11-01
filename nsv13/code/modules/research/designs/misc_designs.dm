/////////////////////////////////////////
/////////Coffeemaker Stuff///////////////
/////////////////////////////////////////

/datum/design/coffeepot
	name = "Dzbanek do kawy"
	id = "coffeepot"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/plastic = 500)
	build_path = /obj/item/reagent_containers/glass/coffeepot
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/coffeepot_bluespace
	name = "Bluespace'owy dzbanek do kawy"
	id = "bluespace_coffeepot"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/plastic = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/reagent_containers/glass/coffeepot/bluespace
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/coffee_cartridge
	name = "Pusty wkład na kawę"
	id = "coffee_cartridge"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 1000)
	build_path = /obj/item/blank_coffee_cartridge
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/syrup_bottle
	name = "Butelka syropu"
	id = "syrup_bottle"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 1000)
	build_path = /obj/item/reagent_containers/glass/bottle/syrup_bottle
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
