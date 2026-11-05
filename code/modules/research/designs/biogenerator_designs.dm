///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10 j. mleka"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	make_reagents = list(/datum/reagent/consumable/milk = 10)
	category = list("initial","Food")

/datum/design/cream
	name = "10 j. śmietanki"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/cream = 10)
	category = list("initial","Food")

/datum/design/milk_carton
	name = "Karton mleka"
	id = "milk_carton"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 100)
	build_path = /obj/item/reagent_containers/food/condiment/milk
	category = list("initial","Food")

/datum/design/cream_carton
	name = "Karton śmietanki"
	id = "cream_carton"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/reagent_containers/food/drinks/bottle/cream
	category = list("initial","Food")

/datum/design/black_pepper
	name = "10 j. czarnego pieprzu"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	make_reagents = list(/datum/reagent/consumable/blackpepper = 10)
	category = list("initial","Food")

/datum/design/pepper_mill
	name = "Młynek do pieprzu"
	id = "pepper_mill"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/food/condiment/peppermill
	make_reagents = list()
	category = list("initial","Food")

/datum/design/enzyme
	name = "10 j. uniwersalnego enzymu"
	id = "enzyme"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/enzyme = 10)
	category = list("initial","Food")


/datum/design/flour_sack
	name = "Worek mąki"
	id = "flour_sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 150)
	build_path = /obj/item/reagent_containers/food/condiment/flour
	category = list("initial","Food")
/datum/design/sugar_sack
	name = "Worek cukru"
	id = "sugar_sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 200)
	build_path = /obj/item/reagent_containers/food/condiment/sugar
	category = list("initial","Food")

/datum/design/monkey_cube
	name = "Małpia kostka"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 250)
	build_path = /obj/item/food/monkeycube
	category = list("initial", "Food")

/datum/design/ez_nut
	name = "E-Z-Nutrient"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 10)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/ez
	category = list("initial","Botany Chemicals")

/datum/design/l4z_nut
	name = "Left 4 Zed"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/l4z
	category = list("initial","Botany Chemicals")

/datum/design/rh_nut
	name = "Robust Harvest"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/rh
	category = list("initial","Botany Chemicals")

/datum/design/weed_killer
	name = "Środek chwastobójczy"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/glass/bottle/killer/weedkiller
	category = list("initial","Botany Chemicals")

/datum/design/pest_spray
	name = "Pestycyd"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/glass/bottle/killer/pestkiller
	category = list("initial","Botany Chemicals")

/datum/design/botany_bottle
	name = "Pusta butelka"
	id = "botany_bottle"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 5)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/empty
	category = list("initial", "Botany Chemicals")

/datum/design/cloth
	name = "Rolka tkaniny"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/stack/sheet/cotton/cloth
	category = list("initial","Organic Materials")

/datum/design/cardboard
	name = "Arkusz tektury"
	id = "cardboard"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	build_path = /obj/item/stack/sheet/cardboard
	category = list("initial","Organic Materials")

/datum/design/leather
	name = "Arkusz skóry"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 150)
	build_path = /obj/item/stack/sheet/leather
	category = list("initial","Organic Materials")

/datum/design/toolbelt
	name = "Pas na narzędzia"
	id = "toolbelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/utility
	category = list("initial","Organic Materials")

/datum/design/secbelt
	name = "Pas policyjny"
	id = "secbelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/security
	category = list("initial","Organic Materials")

/datum/design/medbelt
	name = "Pas medyczny"
	id = "medbel"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/medical
	category = list("initial","Organic Materials")

/datum/design/janibelt
	name = "Pas woźnego"
	id = "janibelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/janitor
	category = list("initial","Organic Materials")

/datum/design/s_holster
	name = "Kabura naramienna"
	id = "s_holster"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 400)
	build_path = /obj/item/clothing/accessory/holster
	category = list("initial","Organic Materials")

/datum/design/rice_hat
	name = "Kapelusz ryżowy"
	id = "rice_hat"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/clothing/head/rice_hat
	category = list("initial","Organic Materials")

/datum/design/carton_soy_milk
	name = "Karton mleka sojowego"
	id = "soy_milk_carton"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 100)
	build_path = /obj/item/reagent_containers/food/condiment/soymilk
	category = list("initial","Food")

/datum/design/seaweed_sheet
	name = "Arkusz wodorostów"
	id = "seaweed_sheet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	build_path = /obj/item/food/seaweed_sheet
	category = list("initial","Food")

//Substrates
/datum/design/substrate_dirt
	name = "Podłoże: ziemia"
	id = "dirt_substrate"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/substrate_bag/dirt
	category = list("initial","Organic Materials")

/datum/design/substrate_clay
	name = "Podłoże: glina"
	id = "clay_substrate"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/substrate_bag/clay
	category = list("initial","Organic Materials")

/datum/design/substrate_sand
	name = "Podłoże: piasek"
	id = "sand_substrate"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/substrate_bag/sand
	category = list("initial","Organic Materials")

/datum/design/substrate_debris
	name = "Podłoże: gruz"
	id = "debris_substrate"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 300)
	build_path = /obj/item/substrate_bag/debris
	category = list("initial","Organic Materials")

/datum/design/substrate_fairy
	name = "Tajemnicze podłoże"
	id = "mysterious_substrate"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 10000)
	build_path = /obj/item/substrate_bag/fairy
	category = list("initial","Organic Materials")
