// Archetypy załogi Syndykatu na wnętrzach statków (raport/zbiorczy1411_01_druzyny_knpc_sterowanie.md, część 2).
// Strzelec (pistol), szturmowiec, strzelba (shotgun), medyk polowy, saper, wartownik i dowódca. Dawny „smg” zostaje
// dla abordażu na nasz statek (spawn_knpcs). Wyposażenie mieści się w tym, co AI już umie: broń palna z magazynkiem
// albo pompką, medipen survival w plecaku, granaty odłamkowe i hukowe, przedmiot trzymany w ręce.
// Trudność overmapy i statki elitarne dokładają granaty i magazynki (aq_knpc_scale_gear).

/// Szansa na granat odłamkowy przy trudności 1, 2 i 3+ (wcześniej stałe 10%)
#define KNPC_FRAG_CHANCE_BY_DIFFICULTY list(10, 20, 30)
/// Dodatkowa szansa na granat odłamkowy na statku elitarnym
#define KNPC_ELITE_FRAG_BONUS 20

// ---------------------------------------------------------------- stroje

/datum/outfit/syndicate/knpc_assault
	name = "Szturmowiec Syndykatu (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/odst
	head = /obj/item/clothing/head/helmet/space/syndicate/odst
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	back = /obj/item/storage/backpack/duffelbag/syndie
	r_hand = /obj/item/gun/ballistic/automatic/c20r // w ręce: find_carried_gun przegląda kieszenie przed plecakiem
	backpack_contents = list(/obj/item/ammo_box/magazine/smgm45 = 4, /obj/item/grenade/flashbang = 1)
	tc = 0
	can_be_admin_equipped = FALSE

/datum/outfit/syndicate/knpc_medic
	name = "Medyk polowy Syndykatu (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/green
	head = /obj/item/clothing/head/helmet/space/syndicate/green
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	back = /obj/item/storage/backpack/duffelbag/syndie/med
	backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/survival = 4, /obj/item/ammo_box/magazine/m10mm = 3)
	tc = 0
	can_be_admin_equipped = FALSE

/datum/outfit/syndicate/knpc_sapper
	name = "Saper Syndykatu (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_hand = /obj/item/weldingtool/largetank
	belt = /obj/item/storage/belt/utility/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/orange
	head = /obj/item/clothing/head/helmet/space/syndicate/orange
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(/obj/item/grenade/frag = 2, /obj/item/ammo_box/magazine/m10mm = 3)
	tc = 0
	can_be_admin_equipped = FALSE

/datum/outfit/syndicate/knpc_sentry
	name = "Wartownik Syndykatu (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/black
	head = /obj/item/clothing/head/helmet/space/syndicate/black
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	r_hand = /obj/item/gun/ballistic/shotgun/automatic/combat // za duża do torby
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(/obj/item/ammo_box/magazine/m10mm = 3)
	tc = 0
	can_be_admin_equipped = FALSE

/datum/outfit/syndicate/knpc_commander
	name = "Dowódca okrętu Syndykatu (KNPC)"
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/odst
	head = /obj/item/clothing/head/helmet/space/syndicate/odst
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	back = /obj/item/storage/backpack/duffelbag/syndie
	r_hand = /obj/item/gun/ballistic/automatic/m90/xm29
	backpack_contents = list(/obj/item/ammo_box/magazine/m556 = 4, /obj/item/ammo_casing/a40mm = 2, /obj/item/reagent_containers/hypospray/medipen/survival = 2, /obj/item/documents/syndicate/red = 1)
	tc = 0
	can_be_admin_equipped = FALSE

// ---------------------------------------------------------------- typy KNPC

/mob/living/carbon/human/ai_boarder/syndicate/assault
	outfit = /datum/outfit/syndicate/knpc_assault
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/syndicate/medic
	outfit = /datum/outfit/syndicate/knpc_medic
	knpc_traits = KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/syndicate/sapper
	outfit = /datum/outfit/syndicate/knpc_sapper
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/syndicate/sentry
	outfit = /datum/outfit/syndicate/knpc_sentry
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

/mob/living/carbon/human/ai_boarder/syndicate/commander
	outfit = /datum/outfit/syndicate/knpc_commander
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC

// ---------------------------------------------------------------- trudność i statki elitarne

/// Szansa na granat odłamkowy według trudności overmapy (bez trybu overmapy: najniższa)
/proc/aq_knpc_frag_chance()
	var/list/chances = KNPC_FRAG_CHANCE_BY_DIFFICULTY
	var/difficulty = SSovermap_mode?.mode?.difficulty || 1
	return chances[clamp(difficulty, 1, length(chances))]

/// Przedmiot do plecaka, a bez plecaka do wolnej kieszeni
/mob/living/carbon/human/ai_boarder/proc/aq_knpc_stash(item_type)
	if(back)
		return new item_type(back)
	var/obj/item/thing = new item_type(src)
	if(!equip_to_slot_if_possible(thing, ITEM_SLOT_LPOCKET, disable_warning = TRUE) && !equip_to_slot_if_possible(thing, ITEM_SLOT_RPOCKET, disable_warning = TRUE))
		qdel(thing)
		return null
	return thing

/// Czy KNPC stoi na wnętrzu statku elitarnego (typ statku z /elite)
/mob/living/carbon/human/ai_boarder/proc/aq_on_elite_ship()
	var/obj/structure/overmap/ship = get_overmap()
	return istype(ship) && findtext("[ship.type]", "/elite")

/// Statek elitarny: dwa dodatkowe magazynki do głównej broni i większa szansa na granat odłamkowy
/mob/living/carbon/human/ai_boarder/proc/aq_knpc_elite_bonus()
	if(QDELETED(src) || stat == DEAD || !aq_on_elite_ship())
		return
	var/obj/item/gun/ballistic/gun = aq_knpc_main_gun()
	if(gun?.mag_type && !ispath(gun.mag_type, /obj/item/ammo_box/magazine/internal))
		for(var/i in 1 to 2)
			aq_knpc_stash(gun.mag_type)
	if(prob(KNPC_ELITE_FRAG_BONUS))
		aq_knpc_stash(/obj/item/grenade/frag)

/// Najlepsza broń z magazynkiem, którą KNPC ma przy sobie (plecak przed kieszenią: tam leży broń główna)
/mob/living/carbon/human/ai_boarder/proc/aq_knpc_main_gun()
	var/list/places = list()
	if(back)
		places += back.contents
	places += held_items
	places += list(l_store, r_store)
	for(var/obj/item/gun/ballistic/gun in places)
		if(gun.mag_type && !ispath(gun.mag_type, /obj/item/ammo_box/magazine/internal))
			return gun

#undef KNPC_FRAG_CHANCE_BY_DIFFICULTY
#undef KNPC_ELITE_FRAG_BONUS
