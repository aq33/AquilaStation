/obj/machinery/computer/shuttle_flight/white_ship
	name = "konsola Białego Statku"
	desc = "Służy do sterowania Białym Statkiem."
	circuit = /obj/item/circuitboard/computer/shuttle/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;whiteship_custom"

/obj/machinery/computer/shuttle_flight/white_ship/pod
	name = "konsola kapsuły ratowniczej"
	desc = "Służy do sterowania kapsułą ratowniczą."
	circuit = /obj/item/circuitboard/computer/shuttle/white_ship/pod
	shuttleId = "whiteship_pod"
	possible_destinations = "whiteship_pod_home;whiteship_pod_custom"

/obj/machinery/computer/shuttle_flight/white_ship/pod/recall
	name = "konsola przywołania kapsuły ratowniczej"
	desc = "Służy do przywoływania kapsuły ratowniczej."
	circuit = /obj/item/circuitboard/computer/shuttle/white_ship/pod/recall
	possible_destinations = "whiteship_pod_home"

/obj/effect/spawner/lootdrop/whiteship_cere_ripley
	name = "25% mech 75% wreckage ripley spawner"
	loot = list(/obj/mecha/working/ripley/mining = 1,
				/obj/structure/mecha_wreckage/ripley = 5)
	lootdoubles = FALSE
