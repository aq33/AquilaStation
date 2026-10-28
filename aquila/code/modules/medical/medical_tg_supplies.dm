// AQUILA - where the tgstation medical gear comes from: lathe designs, techweb, NanoMed Plus, surgical bags, survival box

// --- Designs ---

/datum/design/bonesetter
	name = "Bonesetter"
	desc = "Narzędzie chirurgiczne do nastawiania złamanych kości."
	id = "bonesetter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	build_path = /obj/item/bonesetter
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgical_tape
	name = "Surgical Tape"
	desc = "Taśma do łatania złamanych kości razem z żelem kostnym."
	id = "surgical_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 1000)
	build_path = /obj/item/stack/sticky_tape/surgical
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/blood_scanner
	name = "Hemoanalytic Scanner"
	desc = "Skaner, który igłą bada grupę krwi, niedotlenienie, ilość krwi i toksyny."
	id = "blood_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100)
	build_path = /obj/item/blood_scanner
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/stasis_bodybag
	name = "Stasis Body Bag"
	desc = "Jednorazowy worek, który utrzymuje pacjenta w stazie. Sam worek nie wytrzyma długo i w końcu się rozpadnie."
	id = "stasis_bodybag"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 20000, /datum/material/silver = 1000)
	build_path = /obj/item/bodybag/stasis
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/basic_tools/New()
	. = ..()
	design_ids += list("bonesetter", "surgical_tape", "blood_scanner")

/datum/techweb_node/biotech/New()
	. = ..()
	design_ids += "medipen_refiller"

/datum/techweb_node/adv_biotech/New()
	. = ..()
	design_ids += "stasis_bodybag"

// --- Where they lie ---

/obj/machinery/vending/medical/Initialize(mapload)
	products[/obj/item/stack/medical/bone_gel] = 4
	products[/obj/item/stack/sticky_tape/surgical] = 3
	products[/obj/item/blood_scanner] = 2
	return ..()

/obj/item/storage/backpack/duffelbag/med/surgery/PopulateContents()
	. = ..()
	new /obj/item/bonesetter(src)
	new /obj/item/stack/medical/bone_gel(src)
	new /obj/item/stack/sticky_tape/surgical(src)

/obj/item/storage/backpack/duffelbag/sec/surgery/PopulateContents()
	. = ..()
	new /obj/item/bonesetter(src)

/obj/item/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	. = ..()
	new /obj/item/bonesetter(src)

/// One bandage after the box is filled, only if it still fits (the radio and premium internals variants can be full)
/obj/item/storage/box/survival/Initialize(mapload)
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(!storage || length(contents) >= storage.max_items)
		return
	var/obj/item/bandage_type = /obj/item/stack/medical/bandage
	var/total_size = initial(bandage_type.w_class)
	for(var/obj/item/stored in contents)
		total_size += stored.w_class
	if(total_size <= storage.max_combined_w_class)
		new /obj/item/stack/medical/bandage(src)
