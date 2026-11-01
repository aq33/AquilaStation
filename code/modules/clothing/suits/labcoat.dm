/obj/item/clothing/suit/toggle/labcoat
	name = "fartuch laboratoryjny"
	desc = "Strój chroniący przed drobnymi chemicznymi rozlaniami."
	icon_state = "labcoat"
	item_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/soap, /obj/item/sensor_device, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 0, "bleed" = 5)
	togglename = "guziki"
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "fartuch laboratoryjny Ordynatora"
	desc = "Bardziej niebieski niż standardowy model. Wydawany Ordynatorom, żeby zawsze byli widoczni w morzu rannych i innych lekarzy."
	icon_state = "labcoat_cmo"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/toggle/labcoat/paramedic
	name = "\improper kurtka ratownika medycznego"
	desc = "Granatowa kurtka z odblaskowymi paskami dla ratowników medycznych."
	icon_state = "labcoat_emt"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/toggle/labcoat/brig_physician
	name = "fartuch laboratoryjny lekarza policyjnego"
	icon_state = "labcoat_sec"
	item_state = "labcoat_sec"
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 50, acid = 50, stamina = 30, "bleed" = 10)

/obj/item/clothing/suit/toggle/labcoat/mad
	name = "\proper fartuch laboratoryjny Szaleńca"
	desc = "Wyglądasz w nim na kogoś, kto potrafi trzasnąć kogoś w łeb i wystrzelić go w kosmos."
	icon_state = "labgreen"
	item_state = "labgreen"

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "fartuch laboratoryjny genetyka"
	desc = "Strój chroniący przed drobnymi chemicznymi rozlaniami. Ma niebieski pasek na ramieniu."
	icon_state = "labcoat_gen"

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "fartuch laboratoryjny chemika"
	desc = "Strój chroniący przed drobnymi chemicznymi rozlaniami. Ma pomarańczowy pasek na ramieniu."
	icon_state = "labcoat_chem"

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "fartuch laboratoryjny wirologa"
	desc = "Strój chroniący przed drobnymi chemicznymi rozlaniami. Chroni przed zagrożeniami biologicznymi nieco lepiej niż standardowy model. Ma zielony pasek na ramieniu."
	icon_state = "labcoat_vir"

/obj/item/clothing/suit/toggle/labcoat/science
	name = "fartuch laboratoryjny naukowca"
	desc = "Strój chroniący przed drobnymi chemicznymi rozlaniami. Ma fioletowy pasek na ramieniu."
	icon_state = "labcoat_tox"

/obj/item/clothing/suit/toggle/labcoat/research_director
	name = "fartuch laboratoryjny Dyrektora Naukowego"
	desc = "Postawiony kołnierz, prastary medal z gimnazjalnego festiwalu nauki... wytarte guziki, które ledwo trzymają poły? O tak, czas na badania nad plazmą. Wzdłuż pleców ma tradycyjny fioletowy pasek w kształcie litery U."
	icon_state = "labcoat_rd"
	item_state = "labcoat_tox"
