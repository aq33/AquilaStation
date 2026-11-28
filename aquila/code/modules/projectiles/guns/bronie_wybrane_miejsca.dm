// AQUILA - skąd w grze biorą się bronie z bronie_wybrane.dm: cargo, uplink, handlarz Syndykatu, sklep złomiarzy,
// abordażyści KNPC i ERT. Zrzut gangu (Atreides zamiast Uzi) jest w antagonists/gang/gang_drops.dm, a sklep złomiarzy
// w antagonists/salvager/salvager_magpie.dm.

// ---------------------------------------------------------------- cargo

/datum/supply_pack/security/armory/m44a_single
	name = "Karabin pulsacyjny NT M44A (pojedynczy)"
	desc = "Pojedynczy karabin M44A z magazynkiem na 99 bezłuskowych naboi .300. Strzela tylko w rękach osoby z implantem mindshield."
	cost = 4500
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/automatic/m44a)

/datum/supply_pack/security/armory/m44a_ammo
	name = "Magazynki M44A (x2)"
	desc = "Dwa magazynki na 99 bezłuskowych naboi .300 do karabinu M44A."
	cost = 2000
	small_item = TRUE
	contains = list(/obj/item/ammo_box/magazine/m44a,
					/obj/item/ammo_box/magazine/m44a)

/datum/supply_pack/security/armory/xl8
	name = "Karabiny XL8 (x3)"
	desc = "Trzy karabiny szturmowe XL8 z wbudowaną optyką, każdy z magazynkiem 5,56 mm."
	cost = 9000
	contains = list(/obj/item/gun/ballistic/automatic/xl8,
					/obj/item/gun/ballistic/automatic/xl8,
					/obj/item/gun/ballistic/automatic/xl8)
	crate_name = "skrzynia z karabinami XL8"

/datum/supply_pack/security/armory/xl8_single
	name = "Karabin XL8 (pojedynczy)"
	desc = "Pojedynczy karabin szturmowy XL8 z wbudowaną optyką i magazynkiem 5,56 mm."
	cost = 3500
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/automatic/xl8)

// ---------------------------------------------------------------- uplink

/datum/uplink_item/dangerous/karabin_bojowy
	name = "Karabin bojowy"
	desc = "Ciężki karabin 7,62 mm z 18-nabojowym magazynkiem. Strzela tylko pojedynczo, ale każdy strzał powala."
	item = /obj/item/gun/ballistic/automatic/karabin_bojowy
	cost = 12
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/p90
	name = "PDW P90K"
	desc = "Zwarty pistolet maszynowy 9 mm z 50-nabojowym magazynkiem ładowanym od góry. Strzela seriami po trzy i przyjmuje tłumik."
	item = /obj/item/gun/ballistic/automatic/p90/unrestricted
	cost = 12
	surplus = 40
	purchasable_from = UPLINK_TRAITORS | UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/xm29
	name = "SG-XM29 „Determinator”"
	desc = "Karabin 5,56 mm strzelający seriami z podlufowym bębnem na pięć granatów 40 mm. Granatnik odpalasz ogniem alternatywnym."
	item = /obj/item/gun/ballistic/automatic/m90/xm29
	cost = 18
	surplus = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/karabin_bojowy
	name = "Magazynek karabinu bojowego 7,62 mm"
	desc = "Dodatkowy 18-nabojowy magazynek 7,62 mm do karabinu bojowego."
	item = /obj/item/ammo_box/magazine/karabin_bojowy
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/p90
	name = "Magazynek P90 9 mm"
	desc = "Dodatkowy 50-nabojowy magazynek 9 mm do PDW P90K."
	item = /obj/item/ammo_box/magazine/p90
	cost = 2
	purchasable_from = UPLINK_TRAITORS | UPLINK_NUKE_OPS
	illegal_tech = FALSE

// ---------------------------------------------------------------- handlarz Syndykatu (DonkCo)

/datum/trader_item/akms
	name = "Karabin AKMS"
	desc = "Sfatygowany, ale niezawodny karabin 7,62×39 mm. Ulubiona broń przemytników."
	price = 6000
	stock = 4
	unlock_path = /obj/item/gun/ballistic/automatic/akms

/datum/trader_item/akms_mag
	name = "Magazynek AKMS"
	desc = "30 naboi 7,62×39 mm do AKMS."
	price = 800
	stock = 10
	unlock_path = /obj/item/ammo_box/magazine/akms

/datum/trader_item/p90
	name = "PDW P90K"
	desc = "Zwarty pistolet maszynowy 9 mm z magazynkiem na 50 naboi."
	price = 8000
	stock = 3
	unlock_path = /obj/item/gun/ballistic/automatic/p90/unrestricted

/datum/trader/armsdealer/syndicate/New()
	. = ..()
	sold_items |= list(/datum/trader_item/akms, /datum/trader_item/akms_mag, /datum/trader_item/p90)

// ---------------------------------------------------------------- abordażyści KNPC

// Abordażysta Syndykatu z pistoletem maszynowym losuje P90 albo C-20r
/datum/outfit/syndicate/knpc_smg/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(prob(50))
		backpack_contents = list(/obj/item/storage/box/syndie = 1, /obj/item/gun/ballistic/automatic/p90 = 1, /obj/item/ammo_box/magazine/p90 = 3)

/datum/outfit/syndicate/knpc_rifle
	name = "Abordażysta Syndykatu - karabin bojowy (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/odst
	head = /obj/item/clothing/head/helmet/space/syndicate/odst
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	back = /obj/item/storage/backpack/duffelbag/syndie
	r_hand = /obj/item/gun/ballistic/automatic/karabin_bojowy // za duży do torby
	backpack_contents = list(/obj/item/storage/box/syndie = 1, /obj/item/ammo_box/magazine/karabin_bojowy = 4)
	tc = 0
	can_be_admin_equipped = FALSE

/mob/living/carbon/human/ai_boarder/syndicate/rifle
	outfit = /datum/outfit/syndicate/knpc_rifle

/datum/outfit/space_pirate/knpc_rifle
	name = "Abordażysta kosmicznych piratów - AKMS (KNPC)"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/brown
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/pirate
	id = /obj/item/card/id
	suit = /obj/item/clothing/suit/space/pirate/boarder
	head = /obj/item/clothing/head/helmet/space/pirate/bandana/boarder
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol/glock/makarov/lethal
	r_hand = /obj/item/gun/ballistic/automatic/akms // za duży do torby
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(/obj/item/ammo_box/magazine/akms = 3)

/mob/living/carbon/human/ai_boarder/space_pirate/rifle
	outfit = /datum/outfit/space_pirate/knpc_rifle

// ---------------------------------------------------------------- ERT

// ERT ochrony nosi wojskowy karabin pulsacyjny M19C4 zamiast taktycznej broni energetycznej (BULKY, nie mieści się
// w plecaku), a do obezwładniania ma w plecaku disabler
/datum/outfit/ert/security
	suit_store = /obj/item/gun/energy/laser/m19c4
	backpack_contents = list(/obj/item/storage/box/engineer = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/melee/baton/loaded = 1,
		/obj/item/gun/energy/disabler = 1)
