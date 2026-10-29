GLOBAL_VAR_INIT(exploration_points, 0)

/obj/machinery/vendor/exploration
	name = "automat ze sprzętem odkrywców"
	desc = "Automat ze sprzętem dla zespołów odkrywców. Punkty zdobywa się, wykonując misje, i dzieli między członków zespołu."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/exploration_equipment_vendor

	icon_deny = "mining-deny"
	prize_list = list(
		new /datum/data/vendor_equipment("1 znacznik",				/obj/item/stack/marker_beacon,										50),
		new /datum/data/vendor_equipment("10 znaczników",			/obj/item/stack/marker_beacon/ten,									300),
		new /datum/data/vendor_equipment("30 znaczników",			/obj/item/stack/marker_beacon/thirty,								500),
		new /datum/data/vendor_equipment("Medipen przetrwania",			/obj/item/reagent_containers/hypospray/medipen/survival,			2000),
		new /datum/data/vendor_equipment("Zestaw leczenia obrażeń fizycznych",			/obj/item/storage/firstaid/brute,									3000),
		new /datum/data/vendor_equipment("Zestaw leczenia oparzeń",			/obj/item/storage/firstaid/fire,									3000),
		new /datum/data/vendor_equipment("Zaawansowany zestaw leczniczy",		/obj/item/storage/firstaid/advanced,								5000),
		new /datum/data/vendor_equipment("Oporządzenie odkrywcy",			/obj/item/storage/belt/mining,										2000),
		new /datum/data/vendor_equipment("Ładunek wyważający",			/obj/item/grenade/exploration,										1000),
		new /datum/data/vendor_equipment("Detonator ładunków",			/obj/item/exploration_detonator,									10000),
		new /datum/data/vendor_equipment("Wielofunkcyjna broń energetyczna",	/obj/item/gun/energy/e_gun/mini/exploration,						20000),
		new /datum/data/vendor_equipment("Powiększona awaryjna butla z tlenem",		/obj/item/tank/internals/emergency_oxygen/engi,						1000),
		new /datum/data/vendor_equipment("Nóż survivalowy",				/obj/item/kitchen/knife/combat/survival,							1000),
		new /datum/data/vendor_equipment("Pizza",						/obj/item/pizzabox/margherita,										200),
		new /datum/data/vendor_equipment("Whisky",						/obj/item/reagent_containers/food/drinks/bottle/whiskey,			1000),
		new /datum/data/vendor_equipment("Absynt",					/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,	1000),
		new /datum/data/vendor_equipment("Cygaro",						/obj/item/clothing/mask/cigarette/cigar/havana,						1500),
		new /datum/data/vendor_equipment("Mydło",						/obj/item/soap/nanotrasen,											2000),
		new /datum/data/vendor_equipment("Wskaźnik laserowy",				/obj/item/laser_pointer,											3000),
		new /datum/data/vendor_equipment("Zabawkowy obcy",					/obj/item/clothing/mask/facehugger/toy,								3000),
	)

/obj/machinery/vendor/exploration/subtract_points(obj/item/card/id/I, amount)
	GLOB.exploration_points -= amount

/obj/machinery/vendor/exploration/get_points(obj/item/card/id/I)
	if(!(ACCESS_EXPLORATION in I.access))
		return 0
	return GLOB.exploration_points
