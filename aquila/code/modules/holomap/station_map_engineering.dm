/**
 * AQUILA - inżynieryjna holomapa okrętu.
 *
 * Ścienna maszyna z NSV (`/obj/machinery/station_map/engineering`, nsv13/code/modules/holomap/station_holomap.dm)
 * pokazuje plan pokładu z aktywnymi alarmami pożarowymi i atmosferycznymi. Kod działał, ale płytka nie miała
 * projektu, a na mapach nie stała żadna. Tu: projekt płytki w węźle „Inżynieria przemysłowa” (tam, gdzie konsola
 * alarmów atmosferycznych). Zwykła holomapa ścienna zostaje bez projektu: dubluje holomapę z PDA.
 */

/datum/design/board/station_map_engineering
	name = "Projekt maszyny (inżynieryjna mapa okrętu)"
	desc = "Płytka ściennej holomapy pokładu, która pokazuje aktywne alarmy pożarowe i atmosferyczne."
	id = "station_map_engineering"
	build_path = /obj/item/circuitboard/machine/station_map/engineering
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "station_map_engineering"
