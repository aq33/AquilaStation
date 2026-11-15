// AQUILA - żyły rud planety lodowej, port /obj/structure/vein/ice z Shiptesta (code/modules/mining/ore_veins.dm, AGPLv3).
// Fauna z wyrw na naszych basic mobach (shiptest_fauna/): wilk, niedźwiedź polarny, śnieżny legion z wyrwy, demon
// lodowy, młody smok lodowy, homarzysko. Rudy jak w Shiptest, z rudą lodu (shiptest_flora/ice.dm).

/obj/structure/vein/ice
	mob_types = list(
		/mob/living/basic/mining/wolf = 40,
		/mob/living/basic/mining/polarbear = 40,
		/mob/living/basic/mining/legion/snow/spawner_made = 20,
		/mob/living/basic/mining/ice_demon = 5,
		/mob/living/basic/mining/ice_whelp = 1,
		/mob/living/basic/mining/lobstrosity = 25,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/titanium = 15,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/silver = 10,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/ice = 7,
	)

/obj/structure/vein/ice/classtwo
	mining_charges = 8
	vein_class = 2
	ore_list = list(
		/obj/item/stack/ore/iron = 15,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/silver = 10,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/ice = 8,
	)
	max_mobs = 6
	spawn_time = 10 SECONDS

/obj/structure/vein/ice/classtwo/rare
	ore_list = list(
		/obj/item/stack/ore/ice = 10,
	)

/obj/structure/vein/ice/classthree
	mining_charges = 10
	vein_class = 3
	ore_list = list(
		/obj/item/stack/ore/iron = 2,
		/obj/item/stack/ore/gold = 2,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/silver = 5,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/ice = 8,
	)
	max_mobs = 6
	spawn_time = 8 SECONDS

/obj/structure/vein/ice/classthree/rare
	ore_list = list(
		/obj/item/stack/ore/ice = 10,
	)

/// Żyła klasy 4: cel Głębokiego odwiertu (wiertło głębinowe)
/obj/structure/vein/ice/classfour
	mining_charges = 30
	vein_class = 4
	deep_vein = TRUE
	ore_list = list(
		/obj/item/stack/ore/iron = 2,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/silver = 5,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/bluespace_crystal = 4,
		/obj/item/stack/ore/ice = 8,
	)
	max_mobs = 6
	spawn_time = 8 SECONDS

/// Bogate żyły śnieżnych planet karłowatych: więcej ładunków
/obj/structure/vein/ice/dwarf
	mining_charges = 10

/obj/structure/vein/ice/classtwo/dwarf
	mining_charges = 12

/obj/structure/vein/ice/classthree/dwarf
	mining_charges = 15
