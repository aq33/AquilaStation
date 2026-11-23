// AQUILA - żyły planet morskich. Planeta wodna: /obj/structure/vein/waterplanet z Shiptesta (code/modules/mining/
// ore_veins.dm, AGPLv3) z naszą fauną (pająki-olbrzymy za giant_spider, basic karp i homarzysko plażowe). Plaża:
// Shiptest jej żył nie daje, więc są nasze, skromne (klasy 1-2, żelazo i plazma), żeby misje wiertnicze mogły
// tu wylądować.

/obj/structure/vein/waterplanet
	mob_types = list(
		/mob/living/basic/bear/cave = 60,
		/mob/living/basic/carp = 40,
		/mob/living/basic/mining/lobstrosity/beach = 20,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 10,
		/mob/living/simple_animal/hostile/spider/giant/hunter = 8,
		/mob/living/simple_animal/hostile/spider/giant/viper = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/plasma = 40,
		/obj/item/stack/ore/iron = 65,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/gold = 4,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/bluespace_crystal = 1,
	)

/obj/structure/vein/waterplanet/classtwo
	mining_charges = 8
	vein_class = 2
	max_mobs = 3
	spawn_time = 10 SECONDS
	mob_types = list(
		/mob/living/basic/bear/cave = 50,
		/mob/living/basic/carp = 30,
		/mob/living/basic/mining/lobstrosity/beach = 30,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 15,
		/mob/living/simple_animal/hostile/spider/giant/hunter = 10,
		/mob/living/simple_animal/hostile/spider/giant/viper = 1,
	)
	ore_list = list(
		/obj/item/stack/ore/plasma = 30,
		/obj/item/stack/ore/iron = 55,
		/obj/item/stack/ore/titanium = 7,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/bluespace_crystal = 3,
	)

/obj/structure/vein/waterplanet/classthree
	mining_charges = 10
	vein_class = 3
	max_mobs = 3
	spawn_time = 8 SECONDS
	mob_types = list(
		/mob/living/basic/bear/cave = 10,
		/mob/living/basic/carp = 20,
		/mob/living/basic/mining/lobstrosity/beach = 10,
		/mob/living/simple_animal/hostile/spider/giant/tarantula = 40,
		/mob/living/simple_animal/hostile/spider/giant/hunter = 25,
		/mob/living/simple_animal/hostile/spider/giant/viper = 5,
	)
	ore_list = list(
		/obj/item/stack/ore/plasma = 15,
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/gold = 7,
		/obj/item/stack/ore/uranium = 7,
		/obj/item/stack/ore/bluespace_crystal = 5,
	)

/// Żyła w jaskiniach plaży (nasza, Shiptest jej nie ma)
/obj/structure/vein/beach
	mob_types = list(
		/mob/living/basic/bear/cave = 50,
		/mob/living/basic/mining/lobstrosity/beach = 40,
		/mob/living/basic/crab = 10,
	)
	ore_list = list(
		/obj/item/stack/ore/iron = 60,
		/obj/item/stack/ore/plasma = 30,
		/obj/item/stack/ore/silver = 8,
		/obj/item/stack/ore/gold = 2,
	)

/obj/structure/vein/beach/classtwo
	mining_charges = 8
	vein_class = 2
	ore_list = list(
		/obj/item/stack/ore/iron = 45,
		/obj/item/stack/ore/plasma = 30,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/gold = 6,
		/obj/item/stack/ore/titanium = 5,
	)
