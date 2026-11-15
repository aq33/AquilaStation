// AQUILA - żyły księżyca i pola asteroid z Shiptesta (shiptest-ss13/Shiptest, AGPLv3, code/modules/mining/ore_veins.dm:
// /obj/structure/vein/moon i /obj/structure/vein/asteroid). Bilans Shiptesta, fauna na naszych basic mobach.
// Różnice: ruda lodu (ore/ice) nie istnieje u nas w tej partii, więc żyła księżyca klasy 4 daje kryształ bluespace
// (jak planeta wulkaniczna), a „rzadkie” żyły asteroid (w Shiptest sam lód) dają plazmę i złoto.
// TODO po scaleniu partii lodu: klasa 4 księżyca i rzadkie żyły asteroid -> /obj/item/stack/ore/ice.

/obj/structure/vein/moon
	mob_types = list(
		/mob/living/basic/mining/goliath = 5,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp = 20,
		)
	ore_list = list(
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/titanium = 20,
		/obj/item/stack/ore/gold = 2,
		/obj/item/stack/ore/uranium = 2,
		)

/obj/structure/vein/moon/classtwo
	mining_charges = 8
	vein_class = 2
	mob_types = list(
		/mob/living/basic/mining/goliath = 10,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp = 20,
		/mob/living/basic/carp/mega = 15,
		/mob/living/basic/mining/goliath/ancient = 1,
		)
	ore_list = list(
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/uranium = 5,
		)
	max_mobs = 3
	spawn_time = 10 SECONDS

/obj/structure/vein/moon/classthree
	mining_charges = 10
	vein_class = 3
	mob_types = list(
		/mob/living/basic/mining/goliath = 10,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp/mega = 20,
		/mob/living/basic/mining/goliath/ancient = 1,
		)
	ore_list = list(
		/obj/item/stack/ore/iron = 15,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/uranium = 7,
		)
	max_mobs = 3
	spawn_time = 8 SECONDS

/// Żyła klasy 4 księżyca: głębokie złoże, cel misji głębokiego odwiertu
/obj/structure/vein/moon/classfour
	mining_charges = 15
	vein_class = 4
	deep_vein = TRUE
	drop_rate_amount_min = 30
	drop_rate_amount_max = 40
	mob_types = list(
		/mob/living/basic/mining/goliath = 10,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp/mega = 20,
		/mob/living/basic/mining/goliath/crystal = 5,
		/mob/living/basic/mining/legion/crystal = 5,
		/mob/living/basic/mining/watcher/forgotten = 5,
		)
	ore_list = list(
		/obj/item/stack/ore/bluespace_crystal = 10,
		)
	max_mobs = 6
	spawn_time = 8 SECONDS

/obj/structure/vein/asteroid
	mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp = 20,
		)
	ore_list = list(
		/obj/item/stack/ore/plasma = 40,
		/obj/item/stack/ore/iron = 65,
		/obj/item/stack/ore/titanium = 5,
		/obj/item/stack/ore/gold = 4,
		/obj/item/stack/ore/uranium = 3,
		/obj/item/stack/ore/bluespace_crystal = 1,
		)

/obj/structure/vein/asteroid/classtwo
	mining_charges = 8
	vein_class = 2
	mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp = 20,
		/mob/living/basic/carp/mega = 15,
		/mob/living/basic/mining/goliath/ancient = 5,
		)
	ore_list = list(
		/obj/item/stack/ore/plasma = 30,
		/obj/item/stack/ore/iron = 55,
		/obj/item/stack/ore/titanium = 7,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/uranium = 5,
		/obj/item/stack/ore/bluespace_crystal = 3,
		)
	max_mobs = 3
	spawn_time = 10 SECONDS

/obj/structure/vein/asteroid/classtwo/rare
	ore_list = list(
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/gold = 10,
		)

/obj/structure/vein/asteroid/classthree
	mining_charges = 10
	vein_class = 3
	mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp/mega = 20,
		/mob/living/basic/mining/goliath/ancient = 10,
		)
	ore_list = list(
		/obj/item/stack/ore/plasma = 15,
		/obj/item/stack/ore/iron = 30,
		/obj/item/stack/ore/titanium = 10,
		/obj/item/stack/ore/gold = 7,
		/obj/item/stack/ore/uranium = 7,
		/obj/item/stack/ore/bluespace_crystal = 5,
		)
	max_mobs = 3
	spawn_time = 8 SECONDS

/obj/structure/vein/asteroid/classthree/rare
	ore_list = list(
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/diamond = 3,
		)
