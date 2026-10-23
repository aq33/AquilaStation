// aq33/AquilaStation#332 - pożary na podłogach (port Yogstation#19738) + aq33/AquilaStation#375 poprawka rozprzestrzeniania (Yogstation#19893)

/datum/test_chamber_kit/pr_332
	name = "PR 332/375: pożary na podłogach"
	pr = "aq33/AquilaStation#332"
	description = "Zestaw zamienia brzeg areny na pasy podłóg: drewno, dywan, trawa (palne), śnieg (gasi ogień) i wzmocnioną (niepalna). \
	Miotacz ognia: podpala podłogę zamiast wypuszczać plazmę, ma cooldown i nowe dźwięki; Alt+klik szybko wymienia butlę (do ręki ma trafić stara butla). \
	Mołotowy (wódka - mały pożar, paliwo - duży): podpal zapalniczką i rzuć. Pistolet z amunicją zapalającą też podpala podłogę. \
	#375: ogień na drewnie/trawie ma się rozprzestrzeniać, ale z czasem wygasnąć na zwykłej podłodze; śnieg gasi szybko. W panelu MC subsystem TF nie może rosnąć bez końca. \
	Kratka ma 80 fire armor - nie powinna szybko się topić. Gaś gaśnicą."
	items = list(
		/obj/item/flamethrower/full/tank = 1,
		/obj/item/tank/internals/plasma/full = 1,
		/obj/item/reagent_containers/food/drinks/bottle/molotov/pr_332_vodka = 1,
		/obj/item/reagent_containers/food/drinks/bottle/molotov/pr_332_fuel = 1,
		/obj/item/lighter = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm/fire = 2,
		/obj/structure/grille = 1,
		/obj/item/extinguisher = 2,
		/obj/item/analyzer = 1,
	)

/datum/test_chamber_kit/pr_332/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Najdalsze wolne turfy areny dostają różne podłogi; reset komory wczytuje szablon od nowa
	var/list/floor_types = list(
		/turf/open/floor/wood, /turf/open/floor/wood, /turf/open/floor/wood, /turf/open/floor/wood,
		/turf/open/floor/carpet, /turf/open/floor/carpet,
		/turf/open/floor/grass, /turf/open/floor/grass, /turf/open/floor/grass,
		/turf/open/floor/grass/snow, /turf/open/floor/grass/snow,
		/turf/open/floor/engine, /turf/open/floor/engine,
	)
	var/first = length(items) + 1
	var/available = length(turfs) - first + 1
	if(available <= 0)
		return
	for(var/i in 1 to min(length(floor_types), available))
		var/turf/T = turfs[length(turfs) - i + 1]
		if(!istype(T, /turf/open/floor))
			continue
		T.ChangeTurf(floor_types[i], flags = CHANGETURF_INHERIT_AIR)

/obj/item/reagent_containers/food/drinks/bottle/molotov/pr_332_vodka
	list_reagents = list(/datum/reagent/consumable/ethanol/vodka = 100)

/obj/item/reagent_containers/food/drinks/bottle/molotov/pr_332_fuel
	list_reagents = list(/datum/reagent/fuel = 100)
