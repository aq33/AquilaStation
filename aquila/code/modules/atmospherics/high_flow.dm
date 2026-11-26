// AQUILA - pompy i filtr wysokiego przepływu (plan maszynowni, etap E4; liczby z Einstein Engines, ×3 zwykłych).
// Osobne urządzenia z RPD, zwykłe pompy i filtry na mapach zostają bez zmian. Limity są zmiennymi instancji
// (AQ EDIT w pump.dm, volume_pump.dm i filter.dm), a okna TGUI biorą je z danych.
// Złota obwódka odróżnia je od zwykłych.

#define AQ_HIGH_FLOW_OUTLINE outline_filter(1, "#d9a400")

/obj/machinery/atmospherics/components/binary/pump/aq_high_flow
	name = "pompa wysokiego ciśnienia"
	desc = "Wzmocniona pompa gazu do pętli silników: tłoczy do 13 500 kPa. Zwykłe rury pękają dopiero przy 50 000 kPa, ale kanistry i zbiorniki lepiej trzymać niżej."
	aq_max_pressure = MAX_OUTPUT_PRESSURE * 3

/obj/machinery/atmospherics/components/binary/pump/aq_high_flow/Initialize(mapload)
	. = ..()
	add_filter("aq_high_flow", 1, AQ_HIGH_FLOW_OUTLINE)

/obj/machinery/atmospherics/components/binary/volume_pump/aq_high_flow
	name = "pompa objętościowa wysokiego przepływu"
	desc = "Pompa objętościowa z większą komorą: przetłacza do 600 L/s i pracuje do 27 000 kPa na wyjściu."
	startingvolume = MAX_TRANSFER_RATE * 3
	transfer_rate = MAX_TRANSFER_RATE * 3
	aq_max_rate = MAX_TRANSFER_RATE * 3
	aq_stall_pressure = 27000

/obj/machinery/atmospherics/components/binary/volume_pump/aq_high_flow/Initialize(mapload)
	. = ..()
	add_filter("aq_high_flow", 1, AQ_HIGH_FLOW_OUTLINE)

/obj/machinery/atmospherics/components/trinary/filter/aq_high_flow
	name = "filtr gazów wysokiego przepływu"
	desc = "Filtr z większą komorą do pętli supermaterii i TEG: do 600 L/s, wyjście do 13 500 kPa."
	startingvolume = MAX_TRANSFER_RATE * 3
	transfer_rate = MAX_TRANSFER_RATE * 3
	aq_max_rate = MAX_TRANSFER_RATE * 3
	aq_max_output_pressure = MAX_OUTPUT_PRESSURE * 3
	aq_stall_pressure = 27000

/obj/machinery/atmospherics/components/trinary/filter/aq_high_flow/Initialize(mapload)
	. = ..()
	add_filter("aq_high_flow", 1, AQ_HIGH_FLOW_OUTLINE)

#undef AQ_HIGH_FLOW_OUTLINE
