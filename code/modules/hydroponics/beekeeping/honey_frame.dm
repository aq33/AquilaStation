
/obj/item/honey_frame
	name = "ramka na miód"
	desc = "Rusztowanie, na którym pszczoły budują plastry miodu."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "honey_frame"
	var/honeycomb_capacity = 10 //10 Honeycomb per frame by default, researchable frames perhaps?


/obj/item/honey_frame/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(8,-8)
	pixel_y = base_pixel_y + rand(8,-8)
