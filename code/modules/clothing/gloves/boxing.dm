/obj/item/clothing/gloves/boxing
	name = "rękawice bokserskie"
	desc = "Bo naprawdę potrzebujesz kolejnej wymówki, żeby okładać pięściami innych członków załogi."
	icon_state = "boxing"
	item_state = "boxing"
	worn_icon_state = "boxing"
	equip_delay_other = 60
	species_exception = list(/datum/species/golem) // now you too can be a golem boxing champion

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"
	worn_icon_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"
	worn_icon_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	worn_icon_state = "boxingyellow"

/obj/item/clothing/gloves/boxing/yellow/insulated
	name = "tanie rękawice bokserskie"
	desc = "Zwykłe rękawice bokserskie pokryte prowizoryczną warstwą izolacji. Nic nie może pójść nie tak."
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	worn_icon_state = "boxingyellow"
	siemens_coefficient = 1	//Set to a default of 1, gets overridden in Initialize()

/obj/item/clothing/gloves/boxing/yellow/insulated/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0,0.25,2)
