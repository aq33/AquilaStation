// AQUILA - kuźnia amunicji: formy odlewnicze (na wzór /obj/item/smithing_cast/component z Paradise).
// Użycie w ręce wybiera wyrób, Alt+klik wybiera klasę jakości.

/obj/item/munition_cast
	name = "forma odlewnicza"
	desc = "Forma do basenu odlewniczego kuźni amunicji."
	icon = 'aquila/icons/obj/munitions_forge/smithing.dmi'
	icon_state = "bit_head_cast"
	w_class = WEIGHT_CLASS_SMALL
	/// Z czego forma wybiera wyroby (wszystkie podtypy)
	var/product_root
	var/list/possible_products
	var/obj/item/munition_part/selected_product
	var/datum/munition_quality/quality = /datum/munition_quality
	/// Nakładka na basenie
	var/basin_state = "error"

/obj/item/munition_cast/Initialize(mapload)
	. = ..()
	possible_products = subtypesof(product_root)
	for(var/path in possible_products)
		var/obj/item/munition_part/body/B = path
		if(ispath(path, /obj/item/munition_part/body) && !initial(B.product_path))
			possible_products -= path
	if(length(possible_products))
		selected_product = possible_products[1]

/obj/item/munition_cast/examine(mob/user)
	. = ..()
	if(selected_product)
		. += "<span class='notice'>Ustawiona na: <b>[initial(selected_product.name)]</b>.</span>"
	. += "<span class='notice'>Klasa jakości: [initial(quality.roman)] ([initial(quality.name)]). Zmienisz ją Alt+klikiem.</span>"
	if(length(possible_products) > 1)
		. += "<span class='notice'>Użyj formy w ręce, żeby wybrać wyrób.</span>"

/obj/item/munition_cast/attack_self(mob/user)
	if(length(possible_products) < 2)
		return
	var/list/names = list()
	for(var/path in possible_products)
		var/obj/item/munition_part/P = path
		names[initial(P.name)] = path
	var/choice = tgui_input_list(user, "Co odlewać?", name, names)
	if(!choice || QDELETED(src) || !user.is_holding(src))
		return
	selected_product = names[choice]
	to_chat(user, "<span class='notice'>Ustawiasz [src] na: [choice].</span>")

/obj/item/munition_cast/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	var/list/names = list()
	for(var/path in typesof(/datum/munition_quality))
		var/datum/munition_quality/Q = path
		names["klasa [initial(Q.roman)] ([initial(Q.name)])"] = path
	var/choice = tgui_input_list(user, "Jaka klasa jakości?", name, names)
	if(!choice || QDELETED(src))
		return
	quality = names[choice]
	to_chat(user, "<span class='notice'>Ustawiasz [src] na [choice].</span>")

/obj/item/munition_cast/casings
	name = "forma łusek"
	desc = "Forma na łuski do broni palnej i działek myśliwców. Wylany komplet starcza na całe pudełko."
	icon_state = "bit_mount_cast"
	product_root = /obj/item/munition_part/body/casings
	basin_state = "cast_bitmount"

/obj/item/munition_cast/shell
	name = "forma pocisków działowych"
	desc = "Forma na korpusy pocisków artylerii, dział burtowych i działa Gaussa."
	icon_state = "rod_core_cast"
	product_root = /obj/item/munition_part/body/shell
	basin_state = "cast_rod_core"

/obj/item/munition_cast/warhead
	name = "forma obudów głowic"
	desc = "Forma na obudowy głowic torped i rakiet."
	icon_state = "rod_housing_cast"
	product_root = /obj/item/munition_part/body/warhead
	basin_state = "cast_rod_housing"

/obj/item/munition_cast/filler
	name = "forma wypełnień"
	desc = "Forma na ładunki: HE, przeciwpancerny, zapalający i EMP."
	icon_state = "insert_lining_cast"
	product_root = /obj/item/munition_part/filler
	basin_state = "cast_mesh"

/obj/item/munition_cast/fuze
	name = "forma zapalników"
	desc = "Forma na spłonki do łusek i zapalniki uderzeniowe do pocisków i głowic."
	icon_state = "bit_head_cast"
	product_root = /obj/item/munition_part/fuze
	basin_state = "cast_bithead"

/// Startowy zestaw form dla działu uzbrojenia. Forma obudów głowic jest w techwebie.
/obj/item/storage/box/munition_casts
	name = "pudełko form odlewniczych"
	desc = "Podstawowe formy do kuźni amunicji."

/obj/item/storage/box/munition_casts/PopulateContents()
	new /obj/item/munition_cast/casings(src)
	new /obj/item/munition_cast/shell(src)
	new /obj/item/munition_cast/filler(src)
	new /obj/item/munition_cast/fuze(src)
