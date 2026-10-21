/datum/test_chamber_kit/pr_478
	name = "PR 478: drony eksploracyjne"
	pr = "aq33/AquilaStation#478"
	description = "Postaw drona na wyrzutni i włóż pellet (w combat mode i bez), łomem wyjmij pellet. Konsola skanerów: skan szeroki, potem punktowy i głęboki wybranego miejsca \
	(zestaw od razu generuje kilka miejsc). Konsola dronów: przejmij drona, dodaj narzędzia, leć, eksploruj, przejdź zdarzenie i przygodę, wróć na wyrzutnię. \
	Wyrzuć ładunek z drona, autodestrukcja. Chip handlowy użyj na konsoli cargo, paczka ma się pojawić w zamówieniach. Admin: Debug -> Adventure Manager."
	items = list(
		/obj/machinery/exodrone_launcher = 1,
		/obj/item/exodrone = 1,
		/obj/item/fuel_pellet = 1,
		/obj/item/fuel_pellet/advanced = 1,
		/obj/item/fuel_pellet/exotic = 1,
		/obj/machinery/exoscanner = 2,
		/obj/machinery/computer/exodrone_control_console = 1,
		/obj/machinery/computer/exoscanner_control = 1,
		/obj/machinery/computer/cargo = 1,
		/obj/item/trade_chip = 1,
		/obj/item/crowbar = 1,
	)

/datum/test_chamber_kit/pr_478/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!length(GLOB.exploration_sites))
		generate_exploration_sites()
	var/datum/supply_pack/pack = /datum/supply_pack/exploration/scrapyard
	for(var/obj/item/trade_chip/chip in spawned)
		chip.unlocked_pack_type = pack
		chip.name = "[initial(chip.name)] - [initial(pack.name)]"
