/obj/item/circuitboard/machine/centrifuge
	name = "Centrifuge"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/disease2/centrifuge
	req_components = list(
		/obj/item/stock_parts/manipulator = 3
	)

/obj/item/circuitboard/machine/diseaseanalyser
	name = "Disease Analyzer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/disease2/diseaseanalyser
	req_components = list(
		/obj/item/stock_parts/scanning_module = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/incubator
	name = "Pathogenic Incubator"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/disease2/incubator
	req_components = list(
		/obj/item/stock_parts/scanning_module = 4,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/item/circuitboard/machine/centrifuge/fullupgrade
	build_path = /obj/machinery/disease2/centrifuge/fullupgrade
	req_components = list(
		/obj/item/stock_parts/manipulator/femto = 3,
	)

/obj/item/circuitboard/machine/diseaseanalyser/fullupgrade
	build_path = /obj/machinery/disease2/diseaseanalyser/fullupgrade
	req_components = list(
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/manipulator/femto = 1,
		/obj/item/stock_parts/micro_laser/quadultra = 1,
	)

/obj/item/circuitboard/computer/diseasesplicer
	name = "Disease Splicer"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/diseasesplicer

/obj/item/circuitboard/computer/pathology_data
	name = "Pathology Data"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/records/pathology

// AQ: Monke trzyma te plytke w swoim module flatpackow, u nas idzie tutaj.
/obj/item/circuitboard/machine/vital_floor_scanner
	name = "Vitals Scanning Pad (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/health_scanner_floor
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/cable_coil = 1,
	)
