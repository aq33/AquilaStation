/obj/machinery/turbolift_button
	name = "przycisk przywołania windy"
	desc = "Przycisk, którym przywołujesz turbowindę na swoje piętro. Masz ochotę wciskać go bez końca..."

/obj/machinery/door/airlock/turbolift/ship
	name = "drzwi przeciwwybuchowe turbowindy"
	icon = 'nsv13/goonstation/icons/turbolift_blast_door.dmi'
	desc = "Gródź, która się otwiera i zamyka."
	door_animation_speed = 1
	autoclose = FALSE //Door open/close is controlled by the lift box

 // Turbolifts
/datum/map_template/shuttle/turbolift/nsv/enterprise
	prefix = "_maps/shuttles/turbolifts/nsv/"
	port_id = "debug"
	suffix = "enterprise"
	name = "winda lotnicza (SGC Enterprise)"
	can_be_bought = FALSE

/datum/map_template/shuttle/turbolift/nsv/galactica
	prefix = "_maps/shuttles/turbolifts/nsv/"
	port_id = "turbolift"
	suffix = "galactica"
	name = "winda lotnicza (NSV Galactica)"
	can_be_bought = FALSE

/datum/map_template/shuttle/turbolift/nsv/galactica/secondary
	prefix = "_maps/shuttles/turbolifts/nsv/"
	port_id = "turbolift"
	suffix = "galactica_secondary"
	name = "winda lotnicza (NSV Galactica, zapasowa)"
	can_be_bought = FALSE
