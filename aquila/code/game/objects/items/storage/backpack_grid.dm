// AQUILA - Ekwipunek na siatce kratek: plecaki, torby na ramię i torby podróżne (opis w aquila/code/datums/components/storage/concrete/grid.dm)
// Plecaki bluespace (component_type ustawiony w core) zostają na swoim komponencie, a wymienione niżej typy wracają do starego systemu.

/obj/item/storage/backpack
	component_type = /datum/component/storage/concrete/grid

/obj/item/storage/backpack/Initialize(mapload)
	. = ..()
	// Po ..() wszystkie ComponentInitialize podtypów już ustawiły pojemność, więc siatkę można z niej policzyć
	var/datum/component/storage/concrete/grid/grid = GetComponent(/datum/component/storage/concrete/grid)
	grid?.setup_grid()

/obj/item/storage/backpack/examine(mob/user)
	. = ..()
	var/datum/component/storage/concrete/grid/grid = GetComponent(/datum/component/storage/concrete/grid)
	if(grid?.grid_width)
		. += "<span class='notice'>Ma siatkę [grid.grid_width]×[grid.grid_height] kratek. Przeciągnij przedmiot na inną kratkę, żeby go przesunąć, albo upuść go na nim samym, żeby go obrócić.</span>"

// Worek Mikołaja ma pojemność 60 i co chwilę dostaje nowe prezenty
/obj/item/storage/backpack/santabag
	component_type = /datum/component/storage/concrete

// Depozyt wygnańca musi przyjąć cały ekwipunek wygnanej osoby, niezależnie od kształtów
/obj/item/storage/backpack/duffelbag/exile_deposit
	component_type = /datum/component/storage/concrete
