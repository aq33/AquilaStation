// AQUILA - sprite szklanki z innego pliku niż icons/obj/drinks.dmi (drinki z tg mają swoje w aquila/icons/obj/drinks/tg_drinks.dmi)

/// Plik ikon ze stanem glass_icon_state; puste = icons/obj/drinks.dmi szklanki
/datum/reagent/var/glass_icon

/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change(changetype)
	var/datum/reagent/master = length(reagents?.reagent_list) ? reagents.get_master_reagent() : null
	icon = master?.glass_icon || initial(icon)
	return ..()
