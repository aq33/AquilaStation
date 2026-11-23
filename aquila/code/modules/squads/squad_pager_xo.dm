// Skąd brać pagery drużyn poza automatem: globalny pager w szafce XO i zwykły pager z autolatu.
// Pager z autolatu nie ma drużyny, dopóki nie założy go członek drużyny (equipped w squad_items.dm).

/obj/structure/closet/secure_closet/hop/PopulateContents()
	. = ..()
	new /obj/item/squad_pager/all_channels(src)

// Szafka z NSV nie woła ..(), więc dostaje pager osobno
/obj/structure/closet/secure_closet/hop/solgov/PopulateContents()
	. = ..()
	if(!(locate(/obj/item/squad_pager/all_channels) in src))
		new /obj/item/squad_pager/all_channels(src)

/datum/design/squad_pager
	name = "Pager drużyny"
	id = "squad_pager"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 120)
	build_path = /obj/item/squad_pager
	category = list("initial", "T-Comm")
