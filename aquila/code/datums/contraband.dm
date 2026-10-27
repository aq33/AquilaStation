// Kontrabanda dla skanera N-spect i bramki skanującej (tg `is_contraband`, `get_all_contents_skipping_traits`).

/**
 * Czy przedmiot liczy się jako kontrabanda dla skanera N-spect lub bramki.
 * U nas przedmioty z uplinka mają flagę ILLEGAL, więc nie trzeba przeszukiwać listy uplinka jak w tg.
 */
/obj/item/proc/is_contraband()
	if(HAS_TRAIT(src, TRAIT_CONTRABAND))
		return TRUE
	return !!(item_flags & ILLEGAL)

/// Zwraca src i całą zawartość rekurencyjnie, ale nie wchodzi głębiej w atomy z danym traitem.
/atom/proc/get_all_contents_skipping_traits(skipped_trait)
	. = list(src)
	if(!skipped_trait)
		CRASH("get_all_contents_skipping_traits called without a skipped_trait")
	var/i = 0
	while(i < length(.))
		var/atom/checked_atom = .[++i]
		if(HAS_TRAIT(checked_atom, skipped_trait))
			continue
		. += checked_atom.contents

/// Czy w atomie (albo w nim samym) jest kontrabanda, z pominięciem schowków z TRAIT_CONTRABAND_BLOCKER.
/atom/proc/contains_contraband()
	for(var/obj/item/content in get_all_contents_skipping_traits(TRAIT_CONTRABAND_BLOCKER))
		if(content.is_contraband())
			return TRUE
	return FALSE

/// Oznacza atom (i opcjonalnie całą jego zawartość) jako kontrabandę. Wołane z rdzenia, gdzie define traitu jeszcze nie istnieje.
/atom/proc/mark_contraband(include_contents = FALSE)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)
	if(!include_contents)
		return
	for(var/atom/movable/contained as anything in GetAllContents())
		ADD_TRAIT(contained, TRAIT_CONTRABAND, INNATE_TRAIT)

// Paczki kontrabandy z cargo: zawartość skrzyni jest nielegalna, sama skrzynia nie.
/datum/supply_pack/generate(atom/A, datum/bank_account/paying_account)
	. = ..()
	if(!contraband)
		return
	var/obj/structure/closet/crate/crate = .
	for(var/atom/movable/item_within as anything in crate.contents)
		item_within.mark_contraband(TRUE)

// Schowki, które ukrywają zawartość przed skanerami.
/obj/item/storage/backpack/satchel/flat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/storage/backpack/chameleon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/implant/storage/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)
