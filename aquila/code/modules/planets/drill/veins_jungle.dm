// AQUILA - żyły rud planety dżunglowej, port /obj/structure/vein/jungle z Shiptesta (code/modules/mining/ore_veins.dm,
// AGPLv3). Fauna z wyrw: wilk (nasz basic), niedźwiedź jaskiniowy, nasze ogromne pająki (simple animal), a w wyższych
// klasach nasi mieszkańcy dżungli z Lavalandu (siewka, mega pajęczak, mook), jak w Shiptest.

/obj/structure/vein/jungle
	mob_types = list(
		/mob/living/basic/mining/wolf = 42, // wilk z szansą 15% na alfę, bez wolf/random (usuwa się w Initialize)
		/mob/living/basic/mining/wolf/alpha = 8,
		/mob/living/basic/bear/cave = 30,
		/mob/living/simple_animal/hostile/spider/giant = 5,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 50,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/silver = 15,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/titanium = 1,
	)

/obj/structure/vein/jungle/classtwo
	mining_charges = 8
	vein_class = 2
	mob_types = list(
		/mob/living/basic/mining/wolf = 64,
		/mob/living/basic/mining/wolf/alpha = 11,
		/mob/living/basic/bear/cave = 60,
		/mob/living/simple_animal/hostile/spider/giant = 45,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 20,
		/mob/living/simple_animal/hostile/jungle/seedling = 1,
		/mob/living/simple_animal/hostile/jungle/mega_arachnid = 1,
		/mob/living/simple_animal/hostile/jungle/mook = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 50,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/silver = 10,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/titanium = 4,
	)
	max_mobs = 2
	spawn_time = 15 SECONDS

/obj/structure/vein/jungle/classtwo/rare
	ore_list = list(
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/diamond = 5,
	)

/obj/structure/vein/jungle/classthree
	mining_charges = 10
	vein_class = 3
	mob_types = list(
		/mob/living/basic/mining/wolf = 17,
		/mob/living/basic/mining/wolf/alpha = 3,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 1,
		/mob/living/simple_animal/hostile/jungle/seedling = 5,
		/mob/living/simple_animal/hostile/jungle/mega_arachnid = 20,
		/mob/living/simple_animal/hostile/jungle/mook = 30,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/uranium = 10,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/silver = 10,
		/obj/item/stack/ore/titanium = 4,
	)
	max_mobs = 3
	spawn_time = 10 SECONDS

/obj/structure/vein/jungle/classthree/rare
	ore_list = list(
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/diamond = 10,
	)

/// Żyła klasy 4: cel Głębokiego odwiertu (wiertło głębinowe)
/obj/structure/vein/jungle/classfour
	vein_class = 4
	mining_charges = 10
	deep_vein = TRUE
	ore_list = list(
		/obj/item/stack/ore/bluespace_crystal = 10,
	)
	mob_types = list(
		/mob/living/basic/mining/wolf = 17,
		/mob/living/basic/mining/wolf/alpha = 3,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 1,
		/mob/living/simple_animal/hostile/jungle/seedling = 5,
		/mob/living/simple_animal/hostile/jungle/mega_arachnid = 20,
		/mob/living/simple_animal/hostile/jungle/mook = 30,
	)
	max_mobs = 4
	spawn_time = 10 SECONDS
