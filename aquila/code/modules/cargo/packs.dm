/datum/supply_pack/emergency/syndicate
	name = "NULL_ENTRY"
	desc = "(#@&^$TA PACZKA ZAWIERA SPRZĘT SYNDYKATU WART 30 TC, KTÓRY WALAŁ SIĘ PO MAGAZYNIE. DAJ IM POPALIĆ, AGENCIE, ALE NIE BĄDŹ CHCIWY - ZAMÓW ZA DUŻO, A WYŚLEMY NASZYCH NAJGROŹNIEJSZYCH EGZEKUTORÓW, ŻEBY TO ZBADALI@&!*() "
	hidden = TRUE
	cost = 20000
	contains = list()
	crate_name = "skrzynia awaryjna"
	crate_type = /obj/structure/closet/crate/internals
	dangerous = TRUE
	var/beepsky_chance = -1
	var/level = 1

/datum/supply_pack/emergency/syndicate/fill(obj/structure/closet/crate/C)
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(UPLINK_TRAITORS)
	beepsky_chance += min(level, 5) //1% chance per crate an item will be replaced with a beepsky and the crate stops spawning items. Doesnt act as a hardcap, making nullcrates far riskier and less predictable
	while(crate_value)
		if(prob(beepsky_chance) && prob(50))
			new /mob/living/simple_animal/bot/secbot/grievous/nullcrate(C)
			crate_value = 0
			beepsky_chance = 0
			level += 1
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]
		if(!I.surplus_nullcrates || prob(100 - I.surplus_nullcrates))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		new I.item(C)
	var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	if(istype(loneop))
		loneop.weight += 7
		message_admins("Wysłano skrzynię NULL_ENTRY, waga eventu Lone Operative rośnie do [loneop.weight]")
		log_game("a NULL_ENTRY crate has shipped, increasing the weight of the Lone Operative event to [loneop.weight]")

/datum/supply_pack/organic/kremowka
	name = "Kremówki"
	desc = "Skrzynia pełna kremówek prosto z piekarni w Wadowicach."
	cost = 2137
	crate_type = /obj/structure/closet/crate
	contains = list(
		/obj/item/food/pie/kremowka,
		/obj/item/food/pie/kremowka,
		/obj/item/food/pie/kremowka,
		/obj/item/food/pie/kremowka,
		/obj/item/food/pie/kremowka
		)
	crate_name = "skrzynia kremówek"

/datum/supply_pack/service/party
	contains = list(/obj/item/storage/box/drinkingglasses,
				/obj/item/reagent_containers/food/drinks/shaker,
				/obj/item/reagent_containers/food/drinks/bottle/patron,
				/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
				/obj/item/reagent_containers/food/drinks/ale,
				/obj/item/reagent_containers/food/drinks/ale,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/flashlight/glowstick,
				/obj/item/flashlight/glowstick/red,
				/obj/item/flashlight/glowstick/blue,
				/obj/item/flashlight/glowstick/cyan,
				/obj/item/flashlight/glowstick/orange,
				/obj/item/flashlight/glowstick/yellow,
				/obj/item/flashlight/glowstick/pink,
				/obj/item/survivalcapsule/party,
				/obj/item/survivalcapsule/party,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull,
				/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull)

/datum/supply_pack/science/monkey_helmets
	name = "Hełmy wzmacniające umysł małpy"
	desc = "Niektóre badania najlepiej prowadzić na małpach, ale czasem są po prostu za głupie na bardziej złożone zadania. Te hełmy powinny pomóc."
	cost = 1500
	contains = list(/obj/item/clothing/head/monkey_sentience_helmet,
					/obj/item/clothing/head/monkey_sentience_helmet)
	crate_name = "skrzynia hełmów wzmacniających umysł małpy"

/datum/supply_pack/security/armory/cling_test
	name = "Zestaw do wykrywania zmiennokształtnych"
	desc = "Zawiera jedną butelkę stężonego BZ, który służy do wykrywania i obezwładniania zmiennokształtnych. Ta substancja jest rzadka, więc cena jest zdzierska i ochronie zaleca się w miarę możliwości odwiedzić najbliższe laboratorium chemiczne. Otwarcie wymaga dostępu do zbrojowni."
	cost = 10000
	contains = list(/obj/item/reagent_containers/glass/bottle/concentrated_bz)
	crate_name = "skrzynia zestawu do wykrywania zmiennokształtnych"

/datum/supply_pack/engineering/rtg
	name = "Radioizotopowy generator termoelektryczny"
	desc = "Skrzynia z prostym jądrowym generatorem prądu, którego małe placówki używają, by przez dziesięciolecia mieć niezawodne zasilanie."
	cost = 5000
	contains = list(/obj/machinery/power/rtg)
	crate_name = "skrzynia RTG"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/misc/maluch
	name = "Oryginalny Fiat 126p 'Maluch'"
	desc = "Skrzynia zawierająca delikatnie opakowany egzemplarz oryginalnego Fiata 126p zachowanego w perfekcyjnym stanie. Jeden z niewielu jeszcze istniejących egzemplarzy."
	cost = 69000
	contains = list(/obj/vehicle/sealed/car/maluch,
					/obj/item/key)
	crate_name = "oryginalny Fiat 126p 'Maluch'"

// AQUILA EDIT - amp stacki do jukeboxa
/datum/supply_pack/service/amp_stacks
	name = "Amp stacki"
	desc = "Dwa amp stacki - głośniki, które multitoolem podłącza się do jukeboxa albo radia. Do przykręcenia kluczem na miejscu."
	cost = 1500
	contains = list(/obj/machinery/jukebox_speaker/unanchored,
					/obj/machinery/jukebox_speaker/unanchored)
	crate_name = "skrzynia amp stacków"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/toilet
	name = "Toaleta"
	desc = "Fabrycznie nowa toaleta HT-451 z odzyskiem wody. Przykręć ją kluczem tam, gdzie natura wzywa."
	cost = 1000
	contains = list(/obj/structure/toilet/unanchored)
	crate_name = "skrzynia z toaletą"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/toilets
	name = "Toalety (3 szt.)"
	desc = "Trzy toalety HT-451 w hurtowej cenie. Na nowe łazienki, cele albo dla bardzo zajętej załogi."
	cost = 2500
	contains = list(/obj/structure/toilet/unanchored, /obj/structure/toilet/unanchored, /obj/structure/toilet/unanchored)
	crate_name = "skrzynia z toaletami"
	crate_type = /obj/structure/closet/crate/large
