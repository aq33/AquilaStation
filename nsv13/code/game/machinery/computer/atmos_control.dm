/obj/machinery/computer/atmos_control/tank/nucleium_tank //NSV added nucleium tank console
	name = "sterowanie dopływem nukleium"
	input_tag = ATMOS_GAS_MONITOR_INPUT_NUCLEIUM
	output_tag = ATMOS_GAS_MONITOR_OUTPUT_NUCLEIUM
	sensors = list(ATMOS_GAS_MONITOR_SENSOR_NUCLEIUM = "Zbiornik nukleium")
	circuit = /obj/item/circuitboard/computer/atmos_control/tank/nucleium_tank

/obj/machinery/air_sensor/atmos/nucleium_tank //nucleium stuff
	name = "czujnik gazu zbiornika nukleium"
	id_tag = ATMOS_GAS_MONITOR_SENSOR_NUCLEIUM

