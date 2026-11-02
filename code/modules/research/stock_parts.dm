/*Power cells are in code\modules\power\cell.dm

If you create T5+ please take a pass at gene_modder.dm [L40]. Max_values MUST fit with the clamp to not confuse the user or cause possible exploits.*/
/obj/item/storage/part_replacer
	name = "urządzenie do szybkiej wymiany części"
	desc = "Specjalny moduł mechaniczny do przechowywania, sortowania i montowania standardowych części maszyn."
	icon_state = "RPED"
	item_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	component_type = /datum/component/storage/concrete/rped
	var/works_from_distance = FALSE
	var/pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/rped.ogg'
	var/alt_sound = null

/obj/item/storage/part_replacer/pre_attack(obj/attacked_object, mob/living/user, params)
	if(!istype(attacked_object, /obj/machinery) && !istype(attacked_object, /obj/structure/frame/machine))
		return ..()

	if(!user.Adjacent(attacked_object)) // no TK upgrading.
		return ..()

	if(istype(attacked_object, /obj/machinery))
		var/obj/machinery/attacked_machinery = attacked_object

		if(!attacked_machinery.component_parts)
			return ..()

		if(works_from_distance)
			user.Beam(attacked_machinery, icon_state = "rped_upgrade", time = 5)
		attacked_machinery.exchange_parts(user, src)
		return FALSE

	var/obj/structure/frame/machine/attacked_frame = attacked_object

	if(!attacked_frame.components)
		return ..()

	if(works_from_distance)
		user.Beam(attacked_frame, icon_state = "rped_upgrade", time = 5)
	attacked_frame.attackby(src, user)
	return TRUE

/obj/item/storage/part_replacer/afterattack(obj/attacked_object, mob/living/user, adjacent, params)
	if(!istype(attacked_object, /obj/machinery) && !istype(attacked_object, /obj/structure/frame/machine))
		return ..()

	if(adjacent)
		return ..()

	if(istype(attacked_object, /obj/machinery))
		var/obj/machinery/attacked_machinery = attacked_object

		if(!attacked_machinery.component_parts)
			return ..()

		if(works_from_distance)
			user.Beam(attacked_machinery, icon_state = "rped_upgrade", time = 5)
			attacked_machinery.exchange_parts(user, src)
		return

	var/obj/structure/frame/machine/attacked_frame = attacked_object

	if(!attacked_frame.components)
		return ..()

	if(works_from_distance)
		user.Beam(attacked_frame, icon_state = "rped_upgrade", time = 5)
	attacked_frame.attackby(src, user)

/obj/item/storage/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exhanging or installing parts.
	if(alt_sound && prob(1))
		playsound(src, alt_sound, 40, 1)
	else
		playsound(src, pshoom_or_beepboopblorpzingshadashwoosh, 40, 1)

/obj/item/storage/part_replacer/bluespace
	name = "urządzenie do szybkiej wymiany części bluespace"
	desc = "Wersja RPED, która wymienia części i skanuje z odległości, a do tego mieści więcej części."
	icon_state = "BS_RPED"
	item_state = "BS_RPED"
	w_class = WEIGHT_CLASS_NORMAL
	works_from_distance = TRUE
	pshoom_or_beepboopblorpzingshadashwoosh = 'sound/items/pshoom.ogg'
	alt_sound = 'sound/items/pshoom_2.ogg'
	component_type = /datum/component/storage/concrete/bluespace/rped

/obj/item/storage/part_replacer/bluespace/tier1

/obj/item/storage/part_replacer/bluespace/tier1/PopulateContents()
	for(var/i in 1 to 50)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)
		new /obj/item/stock_parts/cell/high(src)

/obj/item/storage/part_replacer/bluespace/tier2

/obj/item/storage/part_replacer/bluespace/tier2/PopulateContents()
	for(var/i in 1 to 50)
		new /obj/item/stock_parts/capacitor/adv(src)
		new /obj/item/stock_parts/scanning_module/adv(src)
		new /obj/item/stock_parts/manipulator/nano(src)
		new /obj/item/stock_parts/micro_laser/high(src)
		new /obj/item/stock_parts/matter_bin/adv(src)
		new /obj/item/stock_parts/cell/super(src)

/obj/item/storage/part_replacer/bluespace/tier3

/obj/item/storage/part_replacer/bluespace/tier3/PopulateContents()
	for(var/i in 1 to 50)
		new /obj/item/stock_parts/capacitor/super(src)
		new /obj/item/stock_parts/scanning_module/phasic(src)
		new /obj/item/stock_parts/manipulator/pico(src)
		new /obj/item/stock_parts/micro_laser/ultra(src)
		new /obj/item/stock_parts/matter_bin/super(src)
		new /obj/item/stock_parts/cell/hyper(src)

/obj/item/storage/part_replacer/bluespace/tier4

/obj/item/storage/part_replacer/bluespace/tier4/PopulateContents()
	for(var/i in 1 to 50)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
		new /obj/item/stock_parts/cell/bluespace(src)

/obj/item/storage/part_replacer/cargo //used in a cargo crate

/obj/item/storage/part_replacer/cargo/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

/obj/item/storage/part_replacer/cyborg
	name = "urządzenie do szybkiej wymiany części"
	desc = "Specjalny moduł mechaniczny do przechowywania, sortowania i montowania standardowych części maszyn."
	icon_state = "borgrped"
	item_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

/proc/cmp_rped_sort(obj/item/A, obj/item/B)
	return B.get_part_rating() - A.get_part_rating()

/obj/item/stock_parts
	name = "część zamienna"
	desc = "Co?"
	icon = 'icons/obj/stock_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/rating = 1

/obj/item/stock_parts/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/stock_parts/get_part_rating()
	return rating

//Rating 1

/obj/item/stock_parts/capacitor
	name = "kondensator"
	desc = "Podstawowy kondensator używany do budowy wielu urządzeń."
	icon_state = "capacitor"
	materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module
	name = "moduł skanujący"
	desc = "Kompaktowy moduł skanujący wysokiej rozdzielczości, używany do budowy niektórych urządzeń."
	icon_state = "scan_module"
	materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator
	name = "mikromanipulator"
	desc = "Malutki manipulator używany do budowy niektórych urządzeń."
	icon_state = "micro_mani"
	materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser
	name = "mikrolaser"
	desc = "Maleńki laser używany w niektórych urządzeniach."
	icon_state = "micro_laser"
	materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin
	name = "zasobnik materii"
	desc = "Pojemnik na skompresowaną materię czekającą na odtworzenie."
	icon_state = "matter_bin"
	materials = list(/datum/material/iron=80)

//Rating 2

/obj/item/stock_parts/capacitor/adv
	name = "zaawansowany kondensator"
	desc = "Zaawansowany kondensator używany do budowy wielu urządzeń."
	icon_state = "adv_capacitor"
	rating = 2
	materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module/adv
	name = "zaawansowany moduł skanujący"
	desc = "Kompaktowy moduł skanujący wysokiej rozdzielczości, używany do budowy niektórych urządzeń."
	icon_state = "adv_scan_module"
	rating = 2
	materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator/nano
	name = "nanomanipulator"
	desc = "Malutki manipulator używany do budowy niektórych urządzeń."
	icon_state = "nano_mani"
	rating = 2
	materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser/high
	name = "mikrolaser dużej mocy"
	desc = "Maleńki laser używany w niektórych urządzeniach."
	icon_state = "high_micro_laser"
	rating = 2
	materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin/adv
	name = "zaawansowany zasobnik materii"
	desc = "Pojemnik na skompresowaną materię czekającą na odtworzenie."
	icon_state = "advanced_matter_bin"
	rating = 2
	materials = list(/datum/material/iron=80)

//Rating 3

/obj/item/stock_parts/capacitor/super
	name = "superkondensator"
	desc = "Kondensator o bardzo dużej pojemności używany do budowy wielu urządzeń."
	icon_state = "super_capacitor"
	rating = 3
	materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module/phasic
	name = "fazowy moduł skanujący"
	desc = "Kompaktowy fazowy moduł skanujący wysokiej rozdzielczości, używany do budowy niektórych urządzeń."
	icon_state = "super_scan_module"
	rating = 3
	materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator/pico
	name = "pikomanipulator"
	desc = "Malutki manipulator używany do budowy niektórych urządzeń."
	icon_state = "pico_mani"
	rating = 3
	materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser/ultra
	name = "mikrolaser ultrawysokiej mocy"
	icon_state = "ultra_high_micro_laser"
	desc = "Maleńki laser używany w niektórych urządzeniach."
	rating = 3
	materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin/super
	name = "superzasobnik materii"
	desc = "Pojemnik na skompresowaną materię czekającą na odtworzenie."
	icon_state = "super_matter_bin"
	rating = 3
	materials = list(/datum/material/iron=80)

//Rating 4

/obj/item/stock_parts/capacitor/quadratic
	name = "kondensator kwadratowy"
	desc = "Kondensator o ogromnej pojemności używany do budowy wielu urządzeń."
	icon_state = "quadratic_capacitor"
	rating = 4
	materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module/triphasic
	name = "trójfazowy moduł skanujący"
	desc = "Kompaktowy trójfazowy moduł skanujący ultrawysokiej rozdzielczości, używany do budowy niektórych urządzeń."
	icon_state = "triphasic_scan_module"
	rating = 4
	materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator/femto
	name = "femtomanipulator"
	desc = "Malutki manipulator używany do budowy niektórych urządzeń."
	icon_state = "femto_mani"
	rating = 4
	materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser/quadultra
	name = "mikrolaser quad-ultra"
	icon_state = "quadultra_micro_laser"
	desc = "Maleńki laser używany w niektórych urządzeniach."
	rating = 4
	materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin/bluespace
	name = "zasobnik materii bluespace"
	desc = "Pojemnik na skompresowaną materię czekającą na odtworzenie."
	icon_state = "bluespace_matter_bin"
	rating = 4
	materials = list(/datum/material/iron=80)

// Subspace stock parts

/obj/item/stock_parts/subspace/ansible
	name = "ansibl podprzestrzenny"
	icon_state = "subspace_ansible"
	desc = "Kompaktowy moduł wyczuwający aktywność międzywymiarową."
	materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/filter
	name = "filtr hiperfal"
	icon_state = "hyperwave_filter"
	desc = "Maleńkie urządzenie, które filtruje i przetwarza bardzo silne fale radiowe."
	materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/amplifier
	name = "wzmacniacz podprzestrzenny"
	icon_state = "subspace_amplifier"
	desc = "Kompaktowa mikromaszyna, która wzmacnia słabe transmisje podprzestrzenne."
	materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/treatment
	name = "dysk obróbki podprzestrzennej"
	icon_state = "treatment_disk"
	desc = "Kompaktowa mikromaszyna, która rozciąga hiperskompresowane fale radiowe."
	materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/analyzer
	name = "analizator fal podprzestrzennych"
	icon_state = "wavelength_analyzer"
	desc = "Wyrafinowany analizator, który bada zagadkowe długości fal podprzestrzennych."
	materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/crystal
	name = "kryształ ansibla"
	icon_state = "ansible_crystal"
	desc = "Kryształ z czystego szkła, który przesyła laserowe pakiety danych do podprzestrzeni."
	materials = list(/datum/material/glass=50)

/obj/item/stock_parts/subspace/transmitter
	name = "nadajnik podprzestrzenny"
	icon_state = "subspace_transmitter"
	desc = "Duże urządzenie, które otwiera okno do wymiaru podprzestrzeni."
	materials = list(/datum/material/iron=50)

/obj/item/research//Makes testing much less of a pain -Sieve
	name = "badania"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "Przedmiot debugowy do badań."
