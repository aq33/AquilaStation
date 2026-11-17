// AQUILA - żyły rud planet skalistych, białych piasków, pustynnych i mglistych: port /obj/structure/vein/rockplanet,
// /sand, /desert i /shrouded z Shiptesta (code/modules/mining/ore_veins.dm, AGPLv3). Rudy i liczby jak w Shiptest,
// fauna to nasze moby z portu fauny (shiptest_fauna/): gruboid i młody gruboid, stwór i migo z basic mobów,
// goliat i bazyliszek białych piasków, legion z wyrwy, mrówkolwy, cragenoy i obcy.

// Planeta skalista (klasy 1-4; klasa 4 to cel Głębokiego odwiertu)

/obj/structure/vein/rockplanet
	mob_types = list(
		/mob/living/basic/mining/goliath/rockplanet = 20,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 30,
		/mob/living/basic/migo = 10,
		/mob/living/basic/creature = 10,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 60,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/silver = 10,
	)

/obj/structure/vein/rockplanet/classtwo
	mining_charges = 8
	vein_class = 2
	mob_types = list(
		/mob/living/basic/mining/goliath/rockplanet = 50,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 30,
		/mob/living/basic/migo = 5,
		/mob/living/basic/creature = 5,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 50,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/silver = 15,
	)
	spawn_time = 10 SECONDS

/obj/structure/vein/rockplanet/classthree
	mining_charges = 10
	vein_class = 3
	mob_types = list(
		/mob/living/basic/mining/goliath/rockplanet = 50,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 40,
		/mob/living/basic/migo = 5,
		/mob/living/basic/creature = 5,
		/mob/living/basic/wumborian_fugu = 5,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/uranium = 15,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/silver = 20,
		/obj/item/stack/ore/bluespace_crystal = 10,
	)
	spawn_time = 8 SECONDS

/obj/structure/vein/rockplanet/classthree/rare
	ore_list = list(
		/obj/item/stack/ore/uranium = 10,
	)

/obj/structure/vein/rockplanet/classfour
	mining_charges = 30
	vein_class = 4
	deep_vein = TRUE
	mob_types = list(
		/mob/living/basic/mining/goliath/rockplanet = 50,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 40,
		/mob/living/basic/migo = 5,
		/mob/living/basic/creature = 5,
		/mob/living/basic/wumborian_fugu = 5,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 25,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/gold = 15,
		/obj/item/stack/ore/silver = 20,
		/obj/item/stack/ore/bluespace_crystal = 15,
	)
	max_mobs = 6
	spawn_time = 8 SECONDS

// Białe piaski (klasy 1-3)

/obj/structure/vein/sand
	mob_types = list(
		/mob/living/basic/mining/goliath/whitesands/nest = 60,
		/mob/living/basic/mining/legion/spawner_made = 20,
		/mob/living/basic/mining/basilisk/whitesands = 30,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 45,
		/obj/item/stack/ore/titanium = 20,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/uranium = 1,
	)

/obj/structure/vein/sand/classtwo
	mining_charges = 8
	vein_class = 2
	ore_list = list(
		/obj/item/stack/ore/iron = 35,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/uranium = 4,
	)
	max_mobs = 6
	spawn_time = 10 SECONDS

/obj/structure/vein/sand/classtwo/rare
	mining_charges = 12
	ore_list = list(
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/diamond = 2,
	)

/obj/structure/vein/sand/classthree
	mining_charges = 10
	vein_class = 3
	ore_list = list(
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/plasma = 5,
		/obj/item/stack/ore/uranium = 6,
	)
	max_mobs = 6
	spawn_time = 8 SECONDS

/obj/structure/vein/sand/classthree/rare
	mining_charges = 14
	ore_list = list(
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/diamond = 4,
	)

// Pustynia (klasy 1-3)

/obj/structure/vein/desert
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

/obj/structure/vein/desert/classtwo
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
	spawn_time = 10 SECONDS

/obj/structure/vein/desert/classthree
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
	spawn_time = 8 SECONDS

// Planeta mglista (klasy 1-3): z czasem żyła może obudzić całe gniazdo (greed_chance)

/obj/structure/vein/shrouded
	mining_charges = 8
	faction = list("mining", ROLE_ALIEN)
	mob_types = list(
		/mob/living/basic/mining/royalcrab = 50,
		/mob/living/basic/alien = 5,
		/mob/living/basic/alien/drone = 5,
		/mob/living/basic/alien/sentinel = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/uranium = 30,
		/obj/item/stack/ore/plasma = 25,
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/bluespace_crystal = 10,
		/obj/item/stack/ore/titanium = 6,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/diamond = 1,
	)
	spawn_time = 5 SECONDS
	/// Szansa, że wyrwy wypuszczą całe gniazdo (do 15 mobów naraz)
	var/greed_chance = 20

/obj/structure/vein/shrouded/Initialize(mapload)
	. = ..()
	if(prob(greed_chance))
		max_mobs = 15

/obj/structure/vein/shrouded/classtwo
	mining_charges = 10
	vein_class = 2
	mob_types = list(
		/mob/living/basic/mining/royalcrab = 30,
		/mob/living/basic/alien = 5,
		/mob/living/basic/alien/drone = 5,
		/mob/living/basic/alien/sentinel = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/uranium = 20,
		/obj/item/stack/ore/plasma = 15,
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/bluespace_crystal = 10,
		/obj/item/stack/ore/titanium = 6,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/diamond = 1,
	)
	spawn_time = 8 SECONDS
	greed_chance = 30

/obj/structure/vein/shrouded/classthree
	mining_charges = 12
	vein_class = 3
	mob_types = list(
		/mob/living/basic/mining/royalcrab = 10,
		/mob/living/basic/alien = 5,
		/mob/living/basic/alien/drone = 5,
		/mob/living/basic/alien/sentinel = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/bluespace_crystal = 10,
		/obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/gold = 7,
		/obj/item/stack/ore/diamond = 5,
	)
	spawn_time = 6 SECONDS
	greed_chance = 40
