

/obj/machinery/computer/telecomms/server
	name = "konsola monitorowania serwerów telekomunikacji"
	icon_screen = "comm_logs"
	desc = "Ma pełny dostęp do wszystkich szczegółów i zapisów monitorowanej sieci telekomunikacyjnej."

	var/list/servers = list()	// the servers located by the computer
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/universal_translate = 0 // set to 1 if it can translate nonhuman speech

	req_access = list(ACCESS_TCOMSAT)
	circuit = /obj/item/circuitboard/computer/comm_server

// AQ EDIT - okno HTML usunięte; TGUI w aquila/code/game/machinery/telecomms/telecomms_monitors_ui.dm

/obj/machinery/computer/telecomms/server/attackby()
	. = ..()
	updateUsrDialog()
