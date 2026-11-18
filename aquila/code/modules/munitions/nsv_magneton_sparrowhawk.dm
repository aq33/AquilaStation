// AQUILA - pociski Magneton i Sparrowhawk wracają do gry (raport nsv_martwe_08, pkt 4).
// Oba istniały w NSV13 bez źródła. Teraz są w badaniach i u White Rapids, droższe i lepsze od zwykłej amunicji.
// - Magneton FTL-1301 (działo pokładowe): naprowadza się 2,5 s ze skrętem 30 jak dotąd, obrażenia 325 -> 450
//   (zwykły pocisk 400).
// - Sparrowhawk MS-1 (tylko VLS): był rekwizytem przykręconym do podłogi. Teraz to rakieta dalekiego zasięgu
//   (zasięg 500 zamiast 250, 260 obrażeń zamiast 175, wytrzymalsza na obronę punktową), do przewożenia wózkiem.
//   Składa się ją jak zwykłą rakietę, z własną głowicą.
// Rework amunicji: Magneton jest tylko do kupienia (bez projektu w protolathe). Sparrowhawk to ciężka rakieta:
// leci półtora raza szybciej niż zwykła, zajmuje całą tubę VLS (zamiast dwóch zwykłych), a głowica kosztuje więcej
// (dodatkowo złoto) i jest też w paczce cargo.

// ---------------------------------------------------------------- Magneton

/obj/item/projectile/bullet/mac_round/magneton
	damage = 450

/datum/trader_item/naval_shell_homing
	name = "Pocisk artylerii okrętowej FTL-1301 Magneton"
	desc = "Pocisk działa pokładowego, który naprowadza się na kadłub celu i uderza mocniej od zwykłego."
	price = 1500
	stock = 6
	unlock_path = /obj/item/ship_weapon/ammunition/naval_artillery/homing

// ---------------------------------------------------------------- Sparrowhawk

/obj/item/ship_weapon/ammunition/missile/cruise
	anchored = FALSE
	bound_width = 32
	pixel_x = -48
	projectile_type = /obj/item/projectile/guided_munition/missile/cruise

/obj/item/projectile/guided_munition/missile/cruise
	name = "pocisk manewrujący Sparrowhawk"
	damage = 260
	range = 500
	obj_integrity = 160
	max_integrity = 160
	// speed to czas na kratkę: zwykła rakieta ma 1, ciężka leci półtora raza szybciej
	speed = 1 / 1.5

/// Wyrzutnie rakiet myśliwców nie biorą Sparrowhawka: to rakieta tylko do VLS
/obj/item/fighter_component/secondary/ordnance_launcher/load(obj/structure/overmap/target, atom/movable/AM)
	if(istype(AM, /obj/item/ship_weapon/ammunition/missile/cruise))
		return FALSE
	return ..()

/obj/item/ship_weapon/parts/missile/warhead/cruise
	name = "głowica pocisku manewrującego MS-1"
	desc = "Ciężka głowica z dodatkowym zbiornikiem paliwa. Złożona w obudowie rakiety daje pocisk manewrujący „Sparrowhawk” dalekiego zasięgu, tylko do VLS."
	color = "#b8c7d9"
	build_path = /obj/item/ship_weapon/ammunition/missile/cruise

/datum/design/cruise_missile_warhead
	name = "Głowica pocisku manewrującego Sparrowhawk"
	desc = "Głowica rakiety dalekiego zasięgu do VLS."
	id = "cruise_missile_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000, /datum/material/copper = 1500, /datum/material/titanium = 2000, /datum/material/silver = 1000, /datum/material/plasma = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/ship_weapon/parts/missile/warhead/cruise
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/techweb_node/advanced_torpedo_components/New()
	. = ..()
	design_ids += "cruise_missile_warhead"

/datum/trader_item/cruise_missile
	name = "Pocisk manewrujący MS-1 „Sparrowhawk”"
	desc = "Rakieta dalekiego zasięgu do wyrzutni VLS: leci dwa razy dalej niż zwykła rakieta i uderza mocniej."
	price = 1500
	stock = 6
	unlock_path = /obj/item/ship_weapon/ammunition/missile/cruise

/// Ciężka rakieta zajmuje całą tubę VLS: nie wejdzie do tuby z inną amunicją, a do tuby z nią nic już nie wejdzie
/obj/machinery/ship_weapon/vls/load(obj/A, mob/user)
	if(length(ammo) && (istype(A, /obj/item/ship_weapon/ammunition/missile/cruise) || (locate(/obj/item/ship_weapon/ammunition/missile/cruise) in ammo)))
		if(user)
			to_chat(user, "<span class='warning'>Pocisk manewrujący zajmuje całą tubę [src]: w tubie nie zmieści się nic więcej.</span>")
		return FALSE
	return ..()

/datum/supply_pack/munitions/cruise_missile_warheads
	name = "Głowice pocisków manewrujących MS-1 (x5)"
	desc = "Pięć ciężkich głowic MS-1 z dodatkowym zbiornikiem paliwa. Złożone w obudowie rakiety dają pociski manewrujące „Sparrowhawk” do VLS."
	cost = 2500
	contains = list(/obj/item/ship_weapon/parts/missile/warhead/cruise,
					/obj/item/ship_weapon/parts/missile/warhead/cruise,
					/obj/item/ship_weapon/parts/missile/warhead/cruise,
					/obj/item/ship_weapon/parts/missile/warhead/cruise,
					/obj/item/ship_weapon/parts/missile/warhead/cruise)
	crate_name = "skrzynia z głowicami pocisków manewrujących"

/datum/trader/stock_items()
	if(type == /datum/trader/armsdealer)
		sold_items |= list(/datum/trader_item/naval_shell_homing, /datum/trader_item/cruise_missile)
	return ..()
