// Circuit boards, spare parts, etc.

/datum/export/solar/assembly
	cost = 50
	unit_name = "zespół panelu słonecznego"
	export_types = list(/obj/item/solar_assembly)

/datum/export/solar/tracker_board
	cost = 100
	unit_name = "elektronika trackera słonecznego"
	export_types = list(/obj/item/electronics/tracker)

/datum/export/solar/control_board
	cost = 150
	unit_name = "płytka konsoli paneli słonecznych"
	export_types = list(/obj/item/circuitboard/computer/solar_control)

/datum/export/swarmer
	cost = 2000
	unit_name = "wyłączony rojowiec"
	export_types = list(/obj/item/deactivated_swarmer)
