// AQUILA - działa z trybu trudnego jako osobne, drogie badanie i towar handlarzy (raport nsv_martwe_08, pkt 2).
// Bez tych projektów nie dało się dobudować nowej wieżyczki Gaussa, wyrzutni VLS, działa pokładowego ani
// elektroniki spustowej (potrzebna do railguna, MAC, wyrzutni torped i dział burtowych). Dawniej dodawał je
// tylko tryb trudny (`hardmode_tech_enable()`, nsv13/code/modules/research/techweb/_techweb.dm).
// Tryb trudny nic w zamian nie dostaje, a jego lista jest pusta, żeby wyłączenie trybu nie zdejmowało
// projektów z badań. Bez limitu dobudowywania.

/datum/techweb_node/ship_armament
	id = "ship_armament"
	tech_tier = 5
	display_name = "Uzbrojenie okrętowe"
	description = "Pełne plany dział okrętowych: wieżyczka Gaussa z podajnikiem, wyrzutnia VLS, działo pokładowe i elektronika spustowa. Dobudujesz tyle broni, ile zmieści się na pokładzie."
	prereq_ids = list("macro_ballistics", "basic_torpedo_components")
	design_ids = list("gauss_dispenser_circuit", "gauss_turret", "ship_firing_electronics", "deck_gun", "vls_tube")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 10000

/datum/controller/subsystem/research
	gun_techdesigns = list()

/datum/trader_item/gauss_turret_circuit
	name = "Płytka drukowana wieżyczki Gaussa"
	desc = "Wieżyczka Gaussa z własnym strzelcem. Podajnik amunicji sprzedawany osobno."
	price = 6000
	stock = 2
	unlock_path = /obj/item/circuitboard/machine/gauss_turret

/datum/trader_item/gauss_dispenser_circuit
	name = "Płytka drukowana dozownika amunicji Gaussa"
	desc = "Dozownik, który podaje wieżyczce Gaussa amunicję z magazynów okrętu."
	price = 3000
	stock = 2
	unlock_path = /obj/item/circuitboard/machine/gauss_dispenser

/datum/trader_item/deck_turret_circuit
	name = "Płytka drukowana wieżyczki działa pokładowego"
	desc = "Wieżyczka działa pokładowego „Hood”. Rdzeń, bramki i konsola są w badaniach balistyki."
	price = 8000
	stock = 1
	unlock_path = /obj/item/circuitboard/machine/deck_turret

/// White Rapids sprzedaje płytki dział, a Minsky elektronikę spustową i płytkę VLS (u White Rapids to oferty specjalne)
/datum/trader/stock_items()
	if(type == /datum/trader/armsdealer)
		sold_items |= list(/datum/trader_item/gauss_turret_circuit, /datum/trader_item/gauss_dispenser_circuit, /datum/trader_item/deck_turret_circuit)
	if(istype(src, /datum/trader/minsky))
		sold_items |= list(/datum/trader_item/firing_electronics, /datum/trader_item/vls_circuit)
	return ..()
