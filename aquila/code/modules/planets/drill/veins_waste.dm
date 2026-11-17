// AQUILA - żyły rud planety-śmietniska i pola bitwy (do laserowego wiertła i misji wiertniczych).
// Shiptest nie ma żył na planetach-śmietniskach (WasteGenerator nie ustawia vein_type), więc te są nasze: skromne złoża
// z dużym udziałem uranu i żelaza ze złomu, a z wyrw zamiast fauny wychodzą hivebota i automaty wysypiska (frakcja
// hivebot). Pole bitwy dziedziczy w Shiptest żyły pustyni (biom dry_seafloor/battlefield), więc ma je tutaj pod własnym
// rodzicem: rudy i mrówkolwy z /obj/structure/vein/desert (code/modules/mining/ore_veins.dm, AGPLv3).

/obj/structure/vein/waste
	faction = list("hivebot")
	ore_list = list(
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/uranium = 20,
		/obj/item/stack/ore/glass = 10,
		/obj/item/stack/ore/silver = 5,
		)
	mob_types = list(
		/mob/living/basic/hivebot = 40,
		/mob/living/basic/hivebot/range = 30,
		/mob/living/basic/automaton/walkmine/waste = 10,
		)

/obj/structure/vein/waste/classtwo
	mining_charges = 8
	vein_class = 2
	ore_list = list(
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/uranium = 20,
		/obj/item/stack/ore/silver = 10,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/titanium = 5,
		)
	max_mobs = 3
	mob_types = list(
		/mob/living/basic/hivebot/range = 30,
		/mob/living/basic/hivebot/rapid = 20,
		/mob/living/basic/hivebot/strong = 10,
		/mob/living/basic/automaton/quadrotor/cybersun/waste = 10,
		/mob/living/basic/automaton/walkmine/waste = 10,
		)

/obj/structure/vein/waste/classthree
	mining_charges = 10
	vein_class = 3
	ore_list = list(
		/obj/item/stack/ore/uranium = 20,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/bluespace_crystal = 3,
		)
	max_mobs = 3
	spawn_time = 8 SECONDS
	mob_types = list(
		/mob/living/basic/hivebot/strong = 20,
		/mob/living/basic/hivebot/rapid = 20,
		/mob/living/basic/automaton/quadrotor/makosso/waste = 10,
		/mob/living/basic/automaton/agrav/cybersun/waste = 3,
		/mob/living/basic/automaton/walkmine/waste = 10,
		)

/obj/structure/vein/battlefield
	mob_types = list(
		/mob/living/basic/mining/antlion = 100,
		/mob/living/basic/mining/antlion/mega = 10,
		)
	ore_list = list(
		/obj/item/stack/ore/gold = 20,
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/titanium = 4,
		)

/obj/structure/vein/battlefield/classtwo
	mining_charges = 8
	vein_class = 2
	mob_types = list(
		/mob/living/basic/mining/antlion = 70,
		/mob/living/basic/mining/antlion/mega = 10,
		)
	ore_list = list(
		/obj/item/stack/ore/gold = 30,
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/plasma = 7,
		/obj/item/stack/ore/diamond = 7,
		/obj/item/stack/ore/titanium = 5,
		)
	max_mobs = 3
	spawn_time = 10 SECONDS

/obj/structure/vein/battlefield/classthree
	mining_charges = 10
	vein_class = 3
	mob_types = list(
		/mob/living/basic/mining/antlion = 50,
		/mob/living/basic/mining/antlion/mega = 5,
		)
	ore_list = list(
		/obj/item/stack/ore/gold = 15,
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/plasma = 7,
		/obj/item/stack/ore/diamond = 7,
		/obj/item/stack/ore/titanium = 7,
		)
	max_mobs = 3
	spawn_time = 8 SECONDS
