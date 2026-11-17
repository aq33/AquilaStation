// AQUILA - skąd bierze się sprzęt AquilaMed 5: projekty, technologie, automat NanoMed Plus, szafki szpitala, strój ratownika.

// --- Projekty ---

/datum/design/splint
	name = "Szyna"
	desc = "Modułowa szyna na złamaną kończynę."
	id = "aq_splint"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/plastic = 1000, /datum/material/iron = 500)
	build_path = /obj/item/stack/medical/splint/one
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/crutch
	name = "Kula medyczna"
	desc = "Kula dla kogoś ze złamaną nogą."
	id = "aq_crutch"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/cane/crutch
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/reflex_hammer
	name = "Młotek neurologiczny"
	desc = "Młotek do badania odruchów."
	id = "aq_reflex_hammer"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 75, /datum/material/plastic = 50)
	build_path = /obj/item/reflexhammer
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/inhaler
	name = "Inhalator"
	desc = "Inhalator na kanistry z lekiem w aerozolu."
	id = "aq_inhaler"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/plastic = 200)
	build_path = /obj/item/inhaler/medical
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/inhaler_canister
	name = "Kanister do inhalatora"
	desc = "Pusty kanister do inhalatora, napełnia się go jak zlewkę."
	id = "aq_inhaler_canister"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 400)
	build_path = /obj/item/reagent_containers/inhaler_canister
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medical_tape
	name = "Rolka taśmy medycznej"
	desc = "Taśma do odgradzania kwarantanny."
	id = "aq_medical_tape"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/barrier_tape_roll/medical
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/amputation_shears
	name = "Nożyce do amputacji"
	desc = "Ciężkie nożyce do odcinania kończyn."
	id = "aq_amputation_shears"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/titanium = 6000)
	build_path = /obj/item/shears
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/organbox
	name = "Chłodzony pojemnik na narządy"
	desc = "Walizka chłodząca narządy do przeszczepu."
	id = "aq_organbox"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/plastic = 2000, /datum/material/silver = 500)
	build_path = /obj/item/storage/organbox
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/nanopaste
	name = "Nanopasta"
	desc = "Tubka nanitów do naprawy protez i syntetyków."
	id = "aq_nanopaste"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000, /datum/material/gold = 250)
	build_path = /obj/item/stack/medical/nanopaste/one
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/base/New()
	. = ..()
	design_ids += list("aq_splint", "aq_crutch", "aq_reflex_hammer", "aq_inhaler", "aq_inhaler_canister", "aq_medical_tape", "aq_catheter")

/datum/techweb_node/biotech/New()
	. = ..()
	design_ids += list("aq_amputation_shears", "aq_organbox")

/datum/techweb_node/adv_biotech/New()
	. = ..()
	design_ids += "aq_nanopaste"

// --- Automat NanoMed Plus ---

/obj/machinery/vending/medical/Initialize(mapload)
	products[/obj/item/stack/medical/splint] = 4
	products[/obj/item/cane/crutch] = 2
	products[/obj/item/shears] = 1
	products[/obj/item/stack/medical/nanopaste] = 2
	products[/obj/item/reflexhammer] = 2
	products[/obj/item/storage/pill_bottle/paracetamol] = 3
	products[/obj/item/storage/pill_bottle/tramadol] = 2
	products[/obj/item/storage/pill_bottle/citalopram] = 2
	products[/obj/item/storage/pill_bottle/psicodine] = 2
	products[/obj/item/reagent_containers/hypospray/medipen/salacid] = 3
	products[/obj/item/reagent_containers/hypospray/medipen/oxandrolone] = 3
	products[/obj/item/reagent_containers/hypospray/medipen/salbutamol] = 3
	products[/obj/item/reagent_containers/hypospray/medipen/penacid] = 3
	products[/obj/item/reagent_containers/hypospray/medipen/ekit] = 2
	products[/obj/item/inhaler/albuterol] = 2
	products[/obj/item/reagent_containers/inhaler_canister/albuterol] = 3
	products[/obj/item/barrier_tape_roll/medical] = 2
	products[/obj/item/reagent_containers/hypospray/medipen/naloxone] = 2
	products[/obj/item/catheter] = 4
	return ..()

// --- Szafki szpitala ---

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	..()
	new /obj/item/storage/pill_bottle/paracetamol(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/citalopram(src)
	new /obj/item/stack/medical/splint(src)

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	..()
	new /obj/item/reflexhammer(src)
	new /obj/item/stack/medical/splint(src, 2)

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/storage/pill_bottle/oxycodone(src)
	new /obj/item/reagent_containers/glass/bottle/oxycodone(src)
	new /obj/item/reagent_containers/glass/bottle/naloxone(src)
	new /obj/item/storage/pill_bottle/paroxetine(src)
	new /obj/item/storage/pill_bottle/methylphenidate(src)
	new /obj/item/storage/pill_bottle/happiness(src)
	new /obj/item/storage/pill_bottle/pax(src)
	new /obj/item/storage/organbox/preloaded(src)
	new /obj/item/barrier_tape_roll/medical(src)
	new /obj/item/organ/cyberimp/brain/linkedsurgery(src) // procesor chirurgiczny (AquilaMed 5, etap 12)
	new /obj/item/organ/cortical_stack(src)
	new /obj/item/reflexhammer(src)

// --- Apteczki ---

/obj/item/storage/firstaid/regular/PopulateContents()
	. = ..()
	if(!empty)
		new /obj/item/reagent_containers/pill/paracetamol(src)

// --- Pas medyczny mieści nowe narzędzia ---

/obj/item/storage/belt/medical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold |= typecacheof(list(/obj/item/inhaler, /obj/item/reagent_containers/inhaler_canister, /obj/item/reflexhammer, /obj/item/shears))

// --- Ratownik ---

/datum/outfit/job/paramedic
	belt = /obj/item/storage/belt/medical/paramedic
	r_pocket = /obj/item/modular_computer/tablet/pda/paramedic
	pda_slot = ITEM_SLOT_RPOCKET
	box = /obj/item/storage/box/survival/medical
