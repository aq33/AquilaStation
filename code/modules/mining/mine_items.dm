/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "emiter światła"
	anchored = TRUE
	invisibility = 101
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/Initialize(mapload)
	. = ..()
	set_light(set_luminosity, set_cap)

/obj/effect/light_emitter/singularity_pull()
	return

/obj/effect/light_emitter/singularity_act()
	return

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "szafa górnicza"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/PopulateContents()
	new /obj/item/storage/backpack/duffelbag(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "sprzęt górnika"
	icon_state = "mining"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/unlocked
	locked = FALSE

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/radio/headset/headset_cargo/shaft_miner(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/assault_pod/mining(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle_flight/mining
	name = "konsola promu górniczego"
	desc = "Służy do wzywania i odsyłania promu górniczego."
	circuit = /obj/item/circuitboard/computer/shuttle/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"
	req_access = list(ACCESS_MINING)
	var/static/list/dumb_rev_heads = list()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/machinery/computer/shuttle_flight/mining/attack_hand(mob/user, list/modifiers)
	if(is_station_level(user.z) && user.mind && is_head_revolutionary(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, "<span class='warning'>Masz przeczucie, że opuszczenie stacji może być NAPRAWDĘ głupim pomysłem...</span>")
		dumb_rev_heads += user.mind
		return
	. = ..()

//It is on lavaland, soooo....
/obj/machinery/computer/shuttle_flight/science
	name = "konsola promu placówki naukowej"
	desc = "Służy do wzywania i odsyłania promu naukowego."
	circuit = /obj/item/circuitboard/computer/shuttle/science_shuttle
	shuttleId = "science"
	possible_destinations = "science_station;science_outpost"

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "Wózek górniczy. Ten nie jeździ po szynach, trzeba go ciągnąć."
	name = "wózek górniczy (nie na szyny)"
	icon_state = "miningcar"
	door_anim_time = 0
