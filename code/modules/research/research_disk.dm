
/obj/item/disk/tech_disk
	name = "dysk z technologiami"
	desc = "Dysk do przechowywania danych technologicznych do dalszych badań."
	icon_state = "datadisk0"
	materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/datum/techweb/stored_research

/obj/item/disk/tech_disk/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)
	stored_research = new /datum/techweb

/obj/item/disk/tech_disk/debug
	name = "dysk z technologiami Centrali"
	desc = "Przedmiot debugowy do badań"
	materials = list()

/obj/item/disk/tech_disk/debug/Initialize(mapload)
	. = ..()
	stored_research = new /datum/techweb/admin
