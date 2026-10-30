//caravan ambush

/obj/item/wrench/caravan
	color = "#ff0000"
	desc = "Prototyp nowego modelu klucza. Podobno czerwony kolor sprawia, że działa szybciej."
	name = "eksperymentalny klucz"
	toolspeed = 0.3

/obj/item/screwdriver/caravan
	color = "#ff0000"
	desc = "Prototyp nowego modelu śrubokręta. Podobno czerwony kolor sprawia, że działa szybciej."
	name = "eksperymentalny śrubokręt"
	toolspeed = 0.3
	random_color = FALSE

/obj/item/wirecutters/caravan
	color = "#ff0000"
	desc = "Prototyp nowego modelu przecinaka. Podobno czerwony kolor sprawia, że działa szybciej."
	name = "eksperymentalny przecinak"
	toolspeed = 0.3
	random_color = FALSE

/obj/item/crowbar/red/caravan
	color = "#ff0000"
	desc = "Prototyp nowego modelu łomu. Podobno czerwony kolor sprawia, że działa szybciej."
	name = "eksperymentalny łom"
	toolspeed = 0.3

/obj/machinery/computer/shuttle_flight/caravan

/obj/item/circuitboard/computer/shuttle/caravan
	build_path = /obj/machinery/computer/shuttle_flight/caravan

/obj/item/circuitboard/computer/shuttle/caravan/trade1
	build_path = /obj/machinery/computer/shuttle_flight/caravan/trade1

/obj/item/circuitboard/computer/shuttle/caravan/pirate
	build_path = /obj/machinery/computer/shuttle_flight/caravan/pirate

/obj/item/circuitboard/computer/shuttle/caravan/syndicate1
	build_path = /obj/machinery/computer/shuttle_flight/caravan/syndicate1

/obj/item/circuitboard/computer/shuttle/caravan/syndicate2
	build_path = /obj/machinery/computer/shuttle_flight/caravan/syndicate2

/obj/item/circuitboard/computer/shuttle/caravan/syndicate3
	build_path = /obj/machinery/computer/shuttle_flight/caravan/syndicate3

/obj/machinery/computer/shuttle_flight/caravan/trade1
	name = "konsola promu małego frachtowca"
	desc = "Służy do sterowania małym frachtowcem."
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/trade1
	shuttleId = "caravantrade1"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;caravantrade1_custom;caravantrade1_ambush"

/obj/machinery/computer/shuttle_flight/caravan/pirate
	name = "konsola promu pirackiego kutra"
	desc = "Służy do sterowania pirackim kutrem."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/pirate
	shuttleId = "caravanpirate"
	possible_destinations = "caravanpirate_custom;caravanpirate_ambush"

/obj/machinery/computer/shuttle_flight/caravan/syndicate1
	name = "konsola myśliwca Syndykatu"
	desc = "Służy do sterowania myśliwcem Syndykatu."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/syndicate1
	shuttleId = "caravansyndicate1"
	possible_destinations = "caravansyndicate1_custom;caravansyndicate1_ambush;caravansyndicate1_listeningpost"

/obj/machinery/computer/shuttle_flight/caravan/syndicate2
	name = "konsola myśliwca Syndykatu"
	desc = "Służy do sterowania myśliwcem Syndykatu."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE)
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/syndicate2
	shuttleId = "caravansyndicate2"
	possible_destinations = "caravansyndicate2_custom;caravansyndicate2_ambush;caravansyndicate1_listeningpost"

/obj/machinery/computer/shuttle_flight/caravan/syndicate3
	name = "konsola statku desantowego Syndykatu"
	desc = "Służy do sterowania statkiem desantowym Syndykatu."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE)
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/computer/shuttle/caravan/syndicate3
	shuttleId = "caravansyndicate3"
	possible_destinations = "caravansyndicate3_custom;caravansyndicate3_ambush;caravansyndicate3_listeningpost"
