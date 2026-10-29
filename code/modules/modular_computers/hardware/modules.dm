//This item doesn't do much on its own, but is required by apps such as AtmoZphere.
/obj/item/computer_hardware/sensorpackage
	name = "pakiet czujników"
	desc = "Zintegrowany pakiet czujników, dzięki któremu komputer odczytuje parametry otoczenia. Wymagany przez niektóre programy."
	icon_state = "servo"
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_SENSORS
	expansion_hw = TRUE

/obj/item/computer_hardware/radio_card
	name = "zintegrowana karta radiowa"
	desc = "Zintegrowany zespół sygnałowy, dzięki któremu komputer wysyła sygnał na wybranej częstotliwości. Wymagany przez niektóre programy."
	icon_state = "signal_card"
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_SIGNALLER
	expansion_hw = TRUE
	power_usage = 10
