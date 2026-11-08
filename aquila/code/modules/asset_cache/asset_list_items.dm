// AQUILA - the vending spritesheet only had products of vendors that existed when assets loaded, so a vendor built
// from a board (e.g. the Donksoft vendor, mapped only on Aetherwhisp) showed broken icons. Build every vendor type once
// so its products land in GLOB.vending_products (initial() can't read list vars). Same approach as tgstation.
/datum/asset/spritesheet/vending/register()
	for(var/vendor_type in typesof(/obj/machinery/vending))
		if(ispath(vendor_type, /obj/machinery/vending/cola/random) || ispath(vendor_type, /obj/machinery/vending/snack/random))
			continue // they spawn a random sibling and delete themselves
		qdel(new vendor_type())
	return ..()

/datum/asset/spritesheet/research_designs
	/// Stany ikon per plik przy budowie arkusza: ponad 1300 projektów korzysta z dużo mniejszej liczby plików,
	/// a icon_states() dla każdego projektu kosztowało ok. 1 s startu. Czyszczone po register().
	var/list/aq_icon_states_cache

/// icon_states() pliku z pamięci; brak pliku daje pustą listę (jak icon_states(null))
/datum/asset/spritesheet/research_designs/proc/aq_cached_icon_states(icon_file)
	if(!icon_file)
		return list()
	if(!aq_icon_states_cache)
		aq_icon_states_cache = list()
	. = aq_icon_states_cache[icon_file]
	if(isnull(.))
		. = icon_states(icon_file)
		aq_icon_states_cache[icon_file] = .

/// Obrazki pustych slotów w oknie StripMenu (z tgstation, icons/ui/inventory)
/datum/asset/simple/inventory
	assets = list(
		"inventory-glasses.png" = 'icons/ui/inventory/glasses.png',
		"inventory-head.png" = 'icons/ui/inventory/head.png',
		"inventory-neck.png" = 'icons/ui/inventory/neck.png',
		"inventory-mask.png" = 'icons/ui/inventory/mask.png',
		"inventory-ears.png" = 'icons/ui/inventory/ears.png',
		"inventory-uniform.png" = 'icons/ui/inventory/uniform.png',
		"inventory-suit.png" = 'icons/ui/inventory/suit.png',
		"inventory-gloves.png" = 'icons/ui/inventory/gloves.png',
		"inventory-hand_l.png" = 'icons/ui/inventory/hand_l.png',
		"inventory-hand_r.png" = 'icons/ui/inventory/hand_r.png',
		"inventory-shoes.png" = 'icons/ui/inventory/shoes.png',
		"inventory-suit_storage.png" = 'icons/ui/inventory/suit_storage.png',
		"inventory-id.png" = 'icons/ui/inventory/id.png',
		"inventory-belt.png" = 'icons/ui/inventory/belt.png',
		"inventory-back.png" = 'icons/ui/inventory/back.png',
		"inventory-pocket.png" = 'icons/ui/inventory/pocket.png',
		"inventory-collar.png" = 'icons/ui/inventory/collar.png',
	)
