/obj/machinery/computer/shuttle_flight/labor
	name = "konsola promu Obozu Pracy"
	desc = "Służy do wzywania i odsyłania promu Obozu Pracy."
	circuit = /obj/item/circuitboard/computer/shuttle/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away;laborcamp_perma;laborcamp_arrival;laborcamp_bridge"
	req_access = list(ACCESS_BRIG)


/obj/machinery/computer/shuttle_flight/labor/one_way
	name = "konsola promu więziennego"
	desc = "Jednokierunkowa konsola promu, służy do wzywania promu do Obozu Pracy."
	recall_docking_port_id = "laborcamp_away"
	circuit = /obj/item/circuitboard/computer/shuttle/labor_shuttle/one_way
	req_access = list( )
