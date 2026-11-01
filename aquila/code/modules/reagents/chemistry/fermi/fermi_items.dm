// Butelki buforów, projekt analizatora i wyposażenie chemika pod fermichem (jak w tg)

/obj/item/reagent_containers/glass/bottle/acidic_buffer
	name = "butelka: mocny bufor kwaśny"
	desc = "Butelka mocnego buforu kwaśnego. Dolana do roztworu obniża jego pH i sama się zużywa."
	list_reagents = list(/datum/reagent/reaction_agent/acidic_buffer = 30)

/obj/item/reagent_containers/glass/bottle/basic_buffer
	name = "butelka: mocny bufor zasadowy"
	desc = "Butelka mocnego buforu zasadowego. Dolana do roztworu podnosi jego pH i sama się zużywa."
	list_reagents = list(/datum/reagent/reaction_agent/basic_buffer = 30)

/obj/item/reagent_containers/glass/bottle/inversing_buffer
	name = "butelka: chiralny bufor odwracający"
	desc = "Butelka chiralnego buforu odwracającego. Zamienia bardzo nieczyste odczynniki w ich odwrócone odpowiedniki."
	list_reagents = list(/datum/reagent/reaction_agent/inversing_buffer = 30)

/datum/design/ph_meter
	name = "Analizator chemiczny"
	desc = "Analizator chemiczny, który pokazuje pH, temperaturę i czystość każdego odczynnika w pojemniku."
	id = "ph_meter"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2500, /datum/material/gold = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/ph_meter
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

// tg: chemist's locker has a pH booklet and a hint that buffers exist
/obj/structure/closet/secure_closet/chemical/PopulateContents()
	. = ..()
	new /obj/item/ph_booklet(src)
	new /obj/item/reagent_containers/glass/bottle/acidic_buffer(src)
	new /obj/item/reagent_containers/glass/bottle/basic_buffer(src)
