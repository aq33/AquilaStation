// Shipbreaking - port z Monkestation 2.0 (code/datums/shipbreaker, code/game/objects/items/shipbreaker.dm).
// U nas wrak łapie magnes na asteroidy do swojej klatki (magnet.dm), a wraki biorą się z zestrzelonych okrętów na overmapie (wreck_overmap.dm).
// Ściany, dźwigary i maszyny w strefie złomowania dają złom (hooks.dm), który recykler zamienia na kredyty i materiały (recycler.dm).

/area/space/shipbreak
	name = "Strefa złomowania"
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/// Czy atom stoi w strefie złomowania
/proc/is_shipbreak_area(atom/A)
	return istype(get_area(A), /area/space/shipbreak)

/// Co dany przedmiot daje przy złomowaniu maszyny, null = zostaje jak jest
/obj/item/proc/get_shipbreaking_reward()
	return null

/obj/item/stock_parts/get_shipbreaking_reward()
	if(prob(rating * 10)) // lepsze części częściej dają lepszy złom
		switch(rand(1, 10))
			if(1 to 6)
				return /obj/item/stack/scrap/electronics
			if(7 to 9)
				return /obj/item/stack/scrap/plasma
			if(10)
				return /obj/item/stack/scrap/crystalline_matrix
	return /obj/item/stack/scrap/electronics

/obj/item/circuitboard/get_shipbreaking_reward()
	return /obj/item/stack/scrap/electronics

/obj/item/stack/scrap
	name = "złom"
	desc = "Jeśli to widzisz, coś poszło nie tak."
	icon = 'aquila/icons/obj/shipbreaking.dmi'
	icon_state = "ship_plating"
	singular_name = "kawałek złomu"
	merge_type = /obj/item/stack/scrap
	max_amount = 50
	novariants = TRUE
	/// Ile kredytów daje sztuka w recyklerze złomu
	var/scrap_value = 0

/obj/item/stack/scrap/plating
	name = "poszycie okrętu"
	singular_name = "płyta poszycia"
	desc = "Sztywne płyty poszycia, z których buduje się okręty."
	merge_type = /obj/item/stack/scrap/plating
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	scrap_value = 10

/obj/item/stack/scrap/electronics
	name = "złom elektroniczny"
	singular_name = "kawałek elektroniki"
	desc = "Kupa elektronicznego złomu wyrwanego łomem z okrętu. Płytki od maszynki do mięsa w tym bałaganie nie widać."
	icon_state = "scrap_electronics"
	merge_type = /obj/item/stack/scrap/electronics
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT, /datum/material/gold = MINERAL_MATERIAL_AMOUNT * 0.05)
	scrap_value = 20

/obj/item/stack/scrap/framing
	name = "szkielet okrętu"
	singular_name = "dźwigar szkieletu"
	desc = "Dwuteowniki ze stopu srebra i tytanu, z których składa się szkielet okrętu. Projektant musiał mieć własną planetę ze srebrem."
	icon_state = "ship_framing"
	merge_type = /obj/item/stack/scrap/framing
	materials = list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 0.05)
	scrap_value = 30

/obj/item/stack/scrap/plasma
	name = "zastygła plazma"
	singular_name = "grudka plazmy"
	desc = "Paskudna grudka zastygłej plazmy wydłubana z wnętrzności okrętu. Ładnie się klei!"
	icon_state = "congealed_plasma"
	merge_type = /obj/item/stack/scrap/plasma
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT)
	scrap_value = 50

/obj/item/stack/scrap/core
	name = "rdzeń napędu"
	singular_name = "rdzeń napędu"
	desc = "Radioaktywny rdzeń jądrowego silnika manewrowego. Lepiej, żeby żaden asystent nie stał wtedy pod statkiem z piłą."
	icon_state = "ship_core"
	merge_type = /obj/item/stack/scrap/core
	materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT * 0.05)
	scrap_value = 45

/obj/item/stack/scrap/crystalline_matrix
	name = "matryca krystaliczna"
	singular_name = "matryca krystaliczna"
	desc = "Krystaliczna matryca do ogromnych obliczeń przy nawigacji okrętu. AGI do 2520!"
	icon_state = "crystalline_matrix"
	merge_type = /obj/item/stack/scrap/crystalline_matrix
	materials = list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT, /datum/material/bluespace = MINERAL_MATERIAL_AMOUNT * 0.05)
	scrap_value = 100
