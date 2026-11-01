
/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/


/obj/machinery/computer/telecomms/monitor
	name = "konsola monitorowania telekomunikacji"
	icon_screen = "comm_monitor"
	desc = "Monitoruje szczegóły zsynchronizowanej z nią sieci telekomunikacyjnej."

	var/list/machinelist = list()	// the machines located by the computer
	var/obj/machinery/telecomms/SelectedMachine

	var/network = "NULL"		// the network to probe

	var/temp = ""				// temporary feedback messages
	circuit = /obj/item/circuitboard/computer/comm_monitor

// AQ EDIT - okno HTML usunięte; TGUI w aquila/code/game/machinery/telecomms/telecomms_monitors_ui.dm

/obj/machinery/computer/telecomms/monitor/attackby()
	. = ..()
	updateUsrDialog()
