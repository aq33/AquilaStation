// AQUILA - Ekwipunek na siatce kratek (opis w aquila/code/datums/components/storage/concrete/grid.dm)
// Siatkę mają plecaki, torby na ramię i torby podróżne oraz skrzynki z narzędziami, apteczki, aktówki i pudełka (te z dawnym limitem sztuk).
// Typy z własnym komponentem ustawionym w core (plecaki bluespace, hammerspace) zostają na nim, a wymienione niżej wracają do starego systemu.

/obj/item/storage/backpack
	component_type = /datum/component/storage/concrete/grid

/obj/item/storage/toolbox
	component_type = /datum/component/storage/concrete/grid/limited

/obj/item/storage/firstaid
	component_type = /datum/component/storage/concrete/grid/limited

/obj/item/storage/briefcase
	component_type = /datum/component/storage/concrete/grid/limited

/obj/item/storage/box
	component_type = /datum/component/storage/concrete/grid/limited

/obj/item/storage/Initialize(mapload)
	. = ..()
	// Większość schowków nie ma siatki: sprawdzamy typ komponentu, zanim szukamy go na przedmiocie
	if(!ispath(component_type, /datum/component/storage/concrete/grid))
		return
	// Po ..() wszystkie ComponentInitialize podtypów już ustawiły pojemność, więc siatkę można z niej policzyć
	var/datum/component/storage/concrete/grid/grid = GetComponent(/datum/component/storage/concrete/grid)
	grid?.setup_grid()

/obj/item/storage/examine(mob/user)
	. = ..()
	if(!ispath(component_type, /datum/component/storage/concrete/grid))
		return
	var/datum/component/storage/concrete/grid/grid = GetComponent(/datum/component/storage/concrete/grid)
	if(grid?.grid_width)
		. += "<span class='notice'>Ma siatkę [grid.grid_width]×[grid.grid_height] kratek[grid.grid_keep_item_limit ? " i mieści najwyżej [grid.max_items] przedmiotów" : ""]. Przeciągnij przedmiot na inną kratkę, żeby go przesunąć, a w trakcie przeciągania obróć go klawiszem E albo Q.</span>"

// Worek Mikołaja ma pojemność 60 i co chwilę dostaje nowe prezenty
/obj/item/storage/backpack/santabag
	component_type = /datum/component/storage/concrete

// Pudełka admina mają pojemność 1000: siatka urosłaby do 16×84 kratek, a zawartość leżałaby wysoko poza ekranem
/obj/item/storage/box/material
	component_type = /datum/component/storage/concrete

/obj/item/storage/box/debugtools
	component_type = /datum/component/storage/concrete

// Depozyt wygnańca musi przyjąć cały ekwipunek wygnanej osoby, niezależnie od kształtów
/obj/item/storage/backpack/duffelbag/exile_deposit
	component_type = /datum/component/storage/concrete
