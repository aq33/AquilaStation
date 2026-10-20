/obj/effect/spawner/lootdrop/random_seeds
	name = "random seed spawner"
	lootcount = 10
	fan_out_items = TRUE
	loot = list(
				/obj/item/plant_seeds/preset/ambrosia,
				/obj/item/plant_seeds/preset/apple,
				/obj/item/plant_seeds/preset/cotton,
				/obj/item/plant_seeds/preset/banana,
				/obj/item/plant_seeds/preset/berry,
				/obj/item/plant_seeds/preset/cabbage,
				/obj/item/plant_seeds/preset/carrot,
				/obj/item/plant_seeds/preset/cherry,
				/obj/item/plant_seeds/preset/chanterelle,
				/obj/item/plant_seeds/preset/chili,
				/obj/item/plant_seeds/preset/cocoa,
				/obj/item/plant_seeds/preset/coffee,
				/obj/item/plant_seeds/preset/corn,
				/obj/item/plant_seeds/preset/eggplant,
				/obj/item/plant_seeds/preset/garlic,
				/obj/item/plant_seeds/preset/grape,
				/obj/item/plant_seeds/preset/grass,
				/obj/item/plant_seeds/preset/lemon,
				/obj/item/plant_seeds/preset/lime,
				/obj/item/plant_seeds/preset/onion,
				/obj/item/plant_seeds/preset/orange,
				/obj/item/plant_seeds/preset/pineapple,
				/obj/item/plant_seeds/preset/potato,
				/obj/item/plant_seeds/preset/poppy,
				/obj/item/plant_seeds/preset/pumpkin,
				/obj/item/plant_seeds/preset/diona_pod,
				/obj/item/plant_seeds/preset/rice,
				/obj/item/plant_seeds/preset/soybean,
				/obj/item/plant_seeds/preset/sunflower,
				/obj/item/plant_seeds/preset/sugarcane,
				/obj/item/plant_seeds/preset/tea,
				/obj/item/plant_seeds/preset/tobacco,
				/obj/item/plant_seeds/preset/tomato,
				/obj/item/plant_seeds/preset/tower,
				/obj/item/plant_seeds/preset/watermelon,
				/obj/item/plant_seeds/preset/wheat,
				/obj/item/plant_seeds/preset/whitebeet
				)
/obj/effect/spawner/lootdrop/anti_air
	name = "anti-air gun supplies spawner"
	loot = list(
		/obj/item/ammo_box/magazine/nsv/anti_air = 15,
		/obj/machinery/computer/anti_air = 2,
		/obj/machinery/ship_weapon/anti_air = 1,
		/obj/machinery/ship_weapon/anti_air/heavy = 1
		)
	lootcount = 1

/obj/effect/spawner/lootdrop/pdc
	name = "\improper PDC supplies spawner"
	loot = list(
		/obj/item/ammo_box/magazine/nsv/pdc = 10,
		/obj/machinery/ship_weapon/pdc_mount = 2
	)
	lootcount = 1

/obj/effect/spawner/lootdrop/railgun
	name = "railgun supplies spawner"
	loot = list(
		/obj/item/ship_weapon/ammunition/railgun_ammo = 15,
		/obj/item/circuitboard/computer/ship/munitions_computer = 2,
		/obj/machinery/ship_weapon/railgun = 1
		)
	lootcount = 2

/obj/effect/spawner/lootdrop/nac_ammo
	name = "\improper NAC ammo spawner"
	loot = list(
		/obj/item/ship_weapon/ammunition/naval_artillery = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/ap = 1,
		/obj/item/powder_bag = 1,
		/obj/item/powder_bag/plasma = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/cannonball = 1
		)
	lootcount = 3

/obj/effect/spawner/lootdrop/nac_supplies
	name = "\improper NAC stuff spawner"
	loot = list(
		/obj/item/powder_bag = 10,
		/obj/machinery/computer/deckgun = 1,
		/obj/machinery/deck_turret/core = 1,
		/obj/machinery/deck_turret/payload_gate = 1,
		/obj/machinery/deck_turret/autoelevator = 1,
		/obj/machinery/deck_turret/powder_gate = 1
		)
	lootcount = 1

/obj/effect/spawner/lootdrop/syndicate_fighter
	name = "syndicate fighter / raptor / frame spawner"
	loot = list(
		/obj/structure/overmap/small_craft/combat/light/syndicate = 2,
		/obj/structure/overmap/small_craft/transport/sabre/syndicate = 1,
		/obj/structure/fighter_frame = 1
		)
	lootcount = 1

/obj/effect/spawner/lootdrop/fighter
	name = "nanotrasen fighter / raptor / frame spawner"
	loot = list(
		/obj/structure/overmap/small_craft/combat/light = 2,
		/obj/structure/overmap/small_craft/transport/sabre = 1,
		/obj/structure/overmap/small_craft/combat/heavy = 1,
		/obj/structure/fighter_frame = 1
		)
	lootcount = 1
