/datum/test_chamber_kit/pr_499
	name = "PR 499: kable ethernet SI"
	pr = "aq33/AquilaStation#499"
	description = "Dwie sieci kabli: górny rząd (rdzeń, szafa, konsole, nadajnik A) i dolny rząd (szafa, nadajnik B). \
	Konsola dystrybucji ma pokazać 1 THz. Multitool na kablu (podważ płytkę łomem) pokazuje zasoby sieci. \
	Połącz nadajniki w ich oknie albo multitoolem, kluczem (obrót anteny) i śrubokrętem: CPU rośnie do 2 THz. \
	Przetnij połączenie nożycami albo przetnij kabel: zasoby wracają do 1 THz, a przydział SI zostaje obcięty. \
	Zwojem połóż nowy kabel między rzędami: sieci łączą się. Maszyna bez kabla pod sobą pokazuje „Brak połączenia z siecią”."
	items = list(
		/obj/machinery/ai/data_core/primary = 1,
		/obj/machinery/ai/server_cabinet/prefilled = 2,
		/obj/machinery/ai/networking = 2,
		/obj/machinery/computer/ai_resource_distribution = 1,
		/obj/machinery/computer/ai_server_console = 1,
		/obj/item/stack/ethernet_coil = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1,
		/obj/item/multitool = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
	)

/datum/test_chamber_kit/pr_499/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/machinery/ai/data_core/primary/core = locate() in spawned
	var/list/cabinets = list()
	var/list/obj/machinery/ai/networking/dishes = list()
	for(var/obj/machinery/ai/server_cabinet/cabinet in spawned)
		cabinets += cabinet
	for(var/obj/machinery/ai/networking/dish in spawned)
		dishes += dish
	var/obj/machinery/computer/ai_resource_distribution/distribution = locate() in spawned
	var/obj/machinery/computer/ai_server_console/overview = locate() in spawned

	// Rząd górny: sieć A, rząd dolny: sieć B. Między nimi wolny rząd bez kabla.
	var/list/top = list(core, cabinets[1], distribution, overview, dishes[1])
	var/list/bottom = list(cabinets[2], null, null, null, dishes[2])
	for(var/i in 1 to 5)
		var/turf/top_turf = locate(center.x - 3 + i, center.y + 1, center.z)
		var/turf/bottom_turf = locate(center.x - 3 + i, center.y - 1, center.z)
		for(var/turf/T in list(top_turf, bottom_turf))
			if(!locate(/obj/structure/ethernet_cable) in T)
				new /obj/structure/ethernet_cable(T)
		var/atom/movable/top_thing = top[i]
		top_thing?.forceMove(top_turf)
		var/atom/movable/bottom_thing = bottom[i]
		bottom_thing?.forceMove(bottom_turf)
	dishes[1].label = "Komora A"
	dishes[2].label = "Komora B"
	// Rdzeń z baterią, żeby działał też bez zasilania w komorze
	if(!core.integrated_battery)
		core.integrated_battery = new /obj/item/stock_parts/cell/high(core)
