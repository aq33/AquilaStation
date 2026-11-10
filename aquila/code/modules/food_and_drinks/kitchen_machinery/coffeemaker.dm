// AQUILA - ekspres do kawy ze sprite'ami z tgstation (CC-BY-SA 3.0): dzbanek w ekspresie jest pusty, pełny
// albo bluespace'owy, jak w tg. Stan "coffeemaker_cartridge" dopisany do nsv13/icons/obj/coffee.dmi (w pliku była literówka).

/obj/machinery/coffeemaker/overlay_checks()
	. = ..()
	if(!coffeepot)
		return
	. -= "coffeemaker_pot"
	if(istype(coffeepot, /obj/item/reagent_containers/glass/coffeepot/bluespace))
		. += "coffeemaker_pot_bluespace"
	else
		. += "coffeemaker_pot_[coffeepot.reagents.total_volume ? "full" : "empty"]"

/obj/machinery/coffeemaker/pendulum/overlay_checks()
	. = ..()
	if(istype(coffeepot, /obj/item/reagent_containers/glass/coffeepot/bluespace))
		. -= list("pot_full", "pot_empty")
		. += "pot_bluespace"

/// Po zaparzeniu dzbanek w ekspresie jest pełny
/obj/machinery/coffeemaker/brew()
	. = ..()
	update_icon()
