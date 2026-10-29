GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))
/proc/get_uplink_items(uplink_flag, allow_sales = TRUE, allow_restricted = TRUE)
	var/list/filtered_uplink_items = list()
	var/list/sale_items = list()

	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/I = new path
		if(!I.item)
			continue
		if (!(I.purchasable_from & uplink_flag))
			continue
		if(I.player_minimum && I.player_minimum > GLOB.joined_player_list.len)
			continue
		if (I.restricted && !allow_restricted)
			continue
		if(!filtered_uplink_items[I.category])
			filtered_uplink_items[I.category] = list()
		filtered_uplink_items[I.category][I.name] = I
		if(I.limited_stock < 0 && !I.cant_discount && I.item)
			sale_items += I

	if(allow_sales)
		var/datum/team/nuclear/nuclear_team
		if (uplink_flag & UPLINK_NUKE_OPS) 					// uplink code kind of needs a redesign
			nuclear_team = locate() in GLOB.antagonist_teams	// the team discounts could be a in a GLOB with this design but it would make sense for them to be team specific...
		if (!nuclear_team)
			create_uplink_sales(3, "Discounted Gear", 1, sale_items, filtered_uplink_items)
		else
			if (!nuclear_team.team_discounts)
				// create 5 unlimited stock discounts
				create_uplink_sales(5, "Discounted Team Gear", -1, sale_items, filtered_uplink_items)
				// Create 10 limited stock discounts
				create_uplink_sales(10, "Limited Stock Team Gear", 1, sale_items, filtered_uplink_items)
				nuclear_team.team_discounts = list("Discounted Team Gear" = filtered_uplink_items["Discounted Team Gear"], "Limited Stock Team Gear" = filtered_uplink_items["Limited Stock Team Gear"])
			else
				for(var/cat in nuclear_team.team_discounts)
					for(var/item in nuclear_team.team_discounts[cat])
						var/datum/uplink_item/D = nuclear_team.team_discounts[cat][item]
						var/datum/uplink_item/O = filtered_uplink_items[initial(D.category)][initial(D.name)]
						O.refundable = FALSE

				filtered_uplink_items["Discounted Team Gear"] = nuclear_team.team_discounts["Discounted Team Gear"]
				filtered_uplink_items["Limited Stock Team Gear"] = nuclear_team.team_discounts["Limited Stock Team Gear"]


	return filtered_uplink_items

/proc/create_uplink_sales(num, category_name, limited_stock, sale_items, uplink_items)
	if (num <= 0)
		return

	if(!uplink_items[category_name])
		uplink_items[category_name] = list()

	for (var/i in 1 to num)
		var/datum/uplink_item/I = pick_n_take(sale_items)
		var/datum/uplink_item/A = new I.type
		var/list/disclaimer = list("Nieważne tam, gdzie zabronione.", "Niezalecane dla dzieci.", "Zawiera drobne elementy.", "Sprawdź legalność w lokalnych przepisach.", "Nie drażnić.", "Nie odpowiadamy za bezpośrednie, pośrednie, przypadkowe ani wtórne szkody wynikające z jakiejkolwiek wady, błędu lub awarii.", "Trzymać z dala od ognia i płomieni.", "Produkt dostarczany „tak jak jest”, bez jakichkolwiek dorozumianych lub wyraźnych gwarancji.", "Znane z telewizji.", "Wyłącznie do użytku rekreacyjnego.", "Używać wyłącznie zgodnie z zaleceniami.", "Od zamówień z Kosmicznej Nebraski pobierany jest 16% podatek od sprzedaży.")
		A.limited_stock = limited_stock
		A.category = category_name
		I.refundable = FALSE //THIS MAN USES ONE WEIRD TRICK TO GAIN FREE TC, CODERS HATES HIM!
		A.refundable = FALSE
		switch(A.cost == 1 ? 1 : rand(1, 5))
			if(1 to 3)
				if(A.cost <= 3)
					//Bulk discount
					var/count = rand(3,7)
					var/discount = A.get_discount()
					A.name += " (Rabat hurtowy – [count] za [((1-discount)*100)]% taniej!)"
					A.cost = max(round(A.cost*count*discount), 1)
					A.desc += " Normalnie kosztuje [initial(A.cost)*count] TC. Sprzedaż ostateczna. [pick(disclaimer)]"
					A.spawn_amount = count
				else
					//X% off!
					var/discount = A.get_discount()
					if(A.cost >= 20) //Tough love for nuke ops
						discount *= 0.5
					A.cost = max(round(A.cost * discount), 1)
					A.name += " ([round(((initial(A.cost)-A.cost)/initial(A.cost))*100)]% taniej!)"
					A.desc += " Normalnie kosztuje [initial(A.cost)] TC. Sprzedaż ostateczna. [pick(disclaimer)]"
			if(4)
				//Buy 1 get 1 free!
				A.name += " (Kup 1, drugi gratis!)"
				A.desc += " Dwa w cenie jednego. Sprzedaż ostateczna. [pick(disclaimer)]"
				A.spawn_amount = 2
			if(5)
				//Get 2 items with their combined price reduced.
				var/datum/uplink_item/second_I = pick_n_take(sale_items)
				var/total_cost = second_I.cost + I.cost
				var/discount = A.get_discount()
				var/final_cost = max(round(total_cost * discount), 1)
				//Setup the item
				A.cost = final_cost
				A.name += " + [second_I.name] (pakiet promocyjny – [100-(round((final_cost / total_cost)*100))]% taniej!)"
				A.desc += " Zawiera też [second_I.name]. Normalnie kosztuje [total_cost] TC przy zakupie razem. Sprzedaż ostateczna. [pick(disclaimer)]"
				A.bonus_items = list(second_I.item)
		A.discounted = TRUE
		A.item = I.item
		uplink_items[category_name][A.name] = A



/**
 * Uplink Items
 *
 * Items that can be spawned from an uplink. Can be limited by gamemode.
**/
/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null // Path to the item to spawn.
	var/refund_path = null // Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/cost = 0
	var/refund_amount = 0 // specified refund amount in case there needs to be a TC penalty for refunds.
	var/refundable = FALSE
	var/surplus = 100 // Chance of being included in the surplus crate.
	var/cant_discount = FALSE
	var/murderbone_type = FALSE
	var/limited_stock = -1 //Setting this above zero limits how many times this item can be bought by the same traitor in a round, -1 is unlimited
	var/purchasable_from = ALL
	var/list/restricted_roles = list() //If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/player_minimum //The minimum crew size needed for this item to be added to uplinks.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	var/restricted = FALSE // Adds restrictions for VR/Events
	var/list/restricted_species //Limits items to a specific species. Hopefully.
	var/illegal_tech = TRUE // Can this item be deconstructed to unlock certain techweb research nodes?
	var/discounted = FALSE
	var/spawn_amount = 1	//How many times we should run the spawn
	var/bonus_items	= null	//Bonus items you gain if you purchase it

/datum/uplink_item/proc/get_discount()
	return pick(4;0.75,2;0.5,1;0.25)

/datum/uplink_item/proc/purchase(mob/user, datum/component/uplink/U)
	//Spawn base items
	for(var/i in 1 to spawn_amount)
		var/atom/A = spawn_item(item, user, U)
		if(purchase_log_vis && U.purchase_log)
			U.purchase_log.LogPurchase(A, src, cost)
	//Spawn bonust items
	if(islist(bonus_items))
		for(var/bonus in bonus_items)
			var/atom/A = spawn_item(bonus, user, U)
			if(purchase_log_vis && U.purchase_log)
				U.purchase_log.LogPurchase(A, src, cost)

/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	if(istype(A, /obj/item))
		var/obj/item/I = A
		I.item_flags |= ILLEGAL
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.put_in_hands(A))
				to_chat(H, "[A] materializuje się w twoich rękach!")
				return A
	to_chat(user, "[A] materializuje się na podłodze.")
	return A

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = "Discounts"

//All bundles and telecrystals
/datum/uplink_item/bundles_TC
	category = "Bundles"
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/bundles_TC/chemical
	name = "Pakiet bioterrorysty"
	desc = "Dla szaleńca: zawiera ręczny rozpylacz chemiczny Bioterror, granat pianowy Bioterror, pudełko zabójczych chemikaliów, pistolet na strzałki, pudełko strzykawek, karabin szturmowy Donksoft i trochę strzałek do tłumienia zamieszek. Pamiętaj: przed użyciem uszczelnij skafander i włącz butlę."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	cost = 30 // normally 42
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

// NSV13 - added taser drum
/datum/uplink_item/bundles_TC/bulldog
	name = "Pakiet Bulldog"
	desc = "Smukły i groźny: dla tych, którzy lubią walczyć z bliska. Zawiera popularną strzelbę Bulldog, bęben śrutu 12g, bęben pocisków paralizujących 12g i gogle termowizyjne."
	item = /obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	cost = 13 // normally 16
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/c20r
	name = "Pakiet C-20r"
	desc = "Stary, wierny druh: klasyczny C-20r z dwoma magazynkami i (używanym) tłumikiem w promocyjnej cenie."
	item = /obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	cost = 14 // normally 16
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Pakiet implantów cybernetycznych"
	desc = "Losowy wybór implantów cybernetycznych. Gwarantowane 5 implantów wysokiej jakości. W zestawie autochirurg."
	item = /obj/item/storage/box/cyber_implants
	cost = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/medical
	name = "Pakiet medyczny"
	desc = "Specjalista wsparcia: pomóż kolegom operatorom dzięki temu pakietowi medycznemu. Zawiera taktyczną apteczkę, LKM Donksoft, pudełko strzałek do tłumienia zamieszek i buty magnetyczne do ratowania przyjaciół w miejscach bez grawitacji."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	cost = 15 // normally 20
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/sniper
	name = "Pakiet snajperski"
	desc = "Elegancki i wyrafinowany: zawiera złożony karabin snajperski w drogiej walizce, dwa magazynki z pociskami usypiającymi, darmowy używany tłumik i szykowny taktyczny garnitur z golfem. Zamów TERAZ, a dorzucimy gratis czerwony krawat."
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 20 // normally 26
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/firestarter
	name = "Pakiet piromana Specnazu"
	desc = "Do systematycznego tłumienia węglowych form życia w ciasnych pomieszczeniach: zawiera zabójczy plecakowy rozpylacz Nowej Rosji, elitarny hardsuit, pistolet Stieczkin APS, dwa magazynki, minibombę i strzykawkę ze stymulantem. Zamów TERAZ, a towarzysz Borys dorzuci dodatkowy dres."
	item = /obj/item/storage/backpack/duffelbag/syndie/firestarter
	cost = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/contract_kit
	name = "Zestaw kontraktora"
	desc = "Syndykat daje ci szansę zostać kontraktorem i przyjmować zlecenia porwań za TC i gotówkę. Po zakupie dostajesz własny uplink kontraktowy wbudowany w dołączony tablet. Do tego dostajesz standardowy sprzęt kontraktora, który pomoże ci w misji: tablet, specjalny skafander kosmiczny, kombinezon i maskę kameleona, kartę agenta, specjalną pałkę kontraktora i trzy losowo wybrane tanie przedmioty. Może zawierać przedmioty niedostępne w inny sposób."
	item = /obj/item/storage/box/syndie_kit/contract_kit
	cost = 20
	player_minimum = 15
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/bundle_A
	name = "Syndi-zestaw taktyczny"
	desc = "Pakiety Syndykatu, zwane też syndi-zestawami, to wyspecjalizowane grupy przedmiotów dostarczane w zwykłym pudełku. Razem są warte ponad 20 telekryształów, ale nie wiesz, jaką specjalizację dostaniesz. Mogą zawierać wycofane albo egzotyczne przedmioty."
	item = /obj/item/storage/box/syndie_kit/bundle_A
	cost = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/bundle_B
	name = "Syndi-zestaw specjalny"
	desc = "Pakiety Syndykatu, zwane też syndi-zestawami, to wyspecjalizowane grupy przedmiotów dostarczane w zwykłym pudełku. W syndi-zestawie specjalnym dostajesz przedmioty, których używali słynni agenci Syndykatu z przeszłości. Razem są warte ponad 20 telekryształów – Syndykat uwielbia powroty do przeszłości."
	item = /obj/item/storage/box/syndie_kit/bundle_B
	cost = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/surplus
	name = "Skrzynia nadwyżek Syndykatu"
	desc = "Zakurzona skrzynia z zaplecza magazynu Syndykatu. Podobno zawiera cenny asortyment przedmiotów, ale nigdy nie wiadomo. Zawartość jest zawsze dobierana tak, by była warta 50 TC."
	item = /obj/structure/closet/crate
	cost = 20
	player_minimum = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	var/starting_crate_value = 50
	var/uplink_contents = UPLINK_TRAITORS

/datum/uplink_item/bundles_TC/surplus/super
	name = "Superskrzynia nadwyżek"
	desc = "Zakurzona skrzynia w rozmiarze SUPER z zaplecza magazynu Syndykatu. Podobno zawiera cenny asortyment przedmiotów, ale nigdy nie wiadomo. Zawartość jest zawsze dobierana tak, by była warta 125 TC."
	cost = 40
	player_minimum = 30
	starting_crate_value = 125
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/surplus/purchase(mob/user, datum/component/uplink/U)
	var/list/uplink_items = get_uplink_items(uplink_contents, FALSE)

	var/crate_value = starting_crate_value
	var/obj/structure/closet/crate/C = spawn_item(/obj/structure/closet/crate, user, U)
	if(U.purchase_log)
		U.purchase_log.LogPurchase(C, src, cost)
	while(crate_value)
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]

		if(!I.surplus || prob(100 - I.surplus))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		var/obj/goods = new I.item(C)
		if(U.purchase_log)
			U.purchase_log.LogPurchase(goods, I, 0)
	return C

//Will either give you complete crap or overpowered as fuck gear
/datum/uplink_item/bundles_TC/surplus/random
	name = "Lootbox Syndykatu"
	desc = "Zakurzona skrzynia z zaplecza magazynu Syndykatu. Podobno zawiera cenny asortyment przedmiotów. W nowym zestawie o kryptonimie „scam” Syndykat próbował wydobyć energię kości losu, by zbudować system lootboxów, ale mu się nie udało, więc udaje losowość – corgi wywąchuje przedmioty, które trafiają do środka. Cena przedmiotów niegwarantowana. Może zawierać przedmioty normalnie niedostępne."
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	uplink_contents = (UPLINK_TRAITORS | UPLINK_NUKE_OPS)
	player_minimum = 30

/datum/uplink_item/bundles_TC/surplus/random/purchase(mob/user, datum/component/uplink/U)
	var/index = rand(1, 20)
	starting_crate_value = index * 5
	if(index == 1)
		to_chat(user, "<span class='warning'><b>Transmisja przychodząca od Syndykatu.</b></span>")
		to_chat(user, "<span class='warning'>Ogarnia cię przytłaczające poczucie dumy i spełnienia.</span>")
		var/obj/item/clothing/mask/joy/funny_mask = new(get_turf(user))
		ADD_TRAIT(funny_mask, TRAIT_NODROP, CURSED_ITEM_TRAIT)
		var/obj/item/I = user.get_item_by_slot(ITEM_SLOT_MASK)
		if(I)
			user.dropItemToGround(I, TRUE)
		user.equip_to_slot_if_possible(funny_mask, ITEM_SLOT_MASK)
	else if(index == 20)
		starting_crate_value = 200
		print_command_report("Gratulacje dla [user], [rand(4, 9)]. szczęśliwego zwycięzcy loterii Syndykatu! Straszliwy Admirał Szablozęby zezwolił na natychmiastowe przesłanie twojego specjalnego wyposażenia! Udanych łowów, agencie.",
		"Naczelne Dowództwo Wydziału Hazardu Syndykatu", TRUE)
	var/obj/item/implant/weapons_auth/W = new
	W.implant(user)	//Gives them the ability to use restricted weapons
	. = ..()

/datum/uplink_item/bundles_TC/random
	name = "Losowy przedmiot (cena zmienna)" //nsv13 - indicate varying cost
	desc = "Wybranie tej opcji kupuje losowy przedmiot. Przydaje się, gdy masz trochę zbędnych TC albo jeszcze nie wybrałeś strategii."
	item = /obj/effect/gibspawner/generic // non-tangible item because techwebs use this path to determine illegal tech
	cost = 0

/datum/uplink_item/bundles_TC/random/purchase(mob/user, datum/component/uplink/U)
	var/list/uplink_items = U.uplink_items
	var/list/possible_items = list()
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			if(src == I || !I.item)
				continue
			if(U.telecrystals < I.cost)
				continue
			if(I.limited_stock == 0)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		SSblackbox.record_feedback("tally", "traitor_random_uplink_items_gotten", 1, initial(I.name))
		U.MakePurchase(user, I)

/datum/uplink_item/bundles_TC/telecrystal
	name = "1 surowy telekryształ"
	desc = "Telekryształ w najbardziej surowej i czystej postaci. Można go użyć na aktywnym uplinku, by zwiększyć liczbę telekryształów."
	item = /obj/item/stack/telecrystal
	cost = 1
	// Don't add telecrystals to the purchase_log since
	// it's just used to buy more items (including itself!)
	purchase_log_vis = FALSE

/datum/uplink_item/bundles_TC/telecrystal/five
	name = "5 surowych telekryształów"
	desc = "Pięć telekryształów w najbardziej surowej i czystej postaci. Można ich użyć na aktywnym uplinku, by zwiększyć liczbę telekryształów."
	item = /obj/item/stack/telecrystal/five
	cost = 5

/datum/uplink_item/bundles_TC/telecrystal/twenty
	name = "20 surowych telekryształów"
	desc = "Dwadzieścia telekryształów w najbardziej surowej i czystej postaci. Można ich użyć na aktywnym uplinku, by zwiększyć liczbę telekryształów."
	item = /obj/item/stack/telecrystal/twenty
	cost = 20

/datum/uplink_item/bundles_TC/crate
	name = "Hurtowy pakiet hardsuitów"
	desc = "Skrzynia z 4 cennymi hardsuitami Syndykatu."
	cost = 18
	purchasable_from = UPLINK_INCURSION
	item = /obj/effect/gibspawner/generic
	var/list/contents = list(
		/obj/item/clothing/suit/space/hardsuit/syndi = 4,
		/obj/item/clothing/mask/gas/syndicate = 4,
		/obj/item/tank/internals/oxygen = 4
	)

/datum/uplink_item/bundles_TC/crate/purchase(mob/user, datum/component/uplink/U)
	var/obj/structure/closet/crate/C = spawn_item(/obj/structure/closet/crate, user, U)
	if(U.purchase_log)
		U.purchase_log.LogPurchase(C, src, cost)
	for(var/I in contents)
		var/count = contents[I]
		for(var/index in 1 to count)
			new I(C)
	return C

/datum/uplink_item/bundles_TC/crate/medical
	name = "Medyczny pakiet Syndykatu"
	desc = "Zawiera asortyment sprzętu medycznego Syndykatu dla ciebie i twojej drużyny. W zestawie różne apteczki, pojemniki z pigułkami, kompaktowy defibrylator i 4 stymulatory."
	cost = 12
	contents = list(
		/obj/item/storage/firstaid/tactical = 2,	//8 TC
		/obj/item/storage/firstaid/brute = 2,
		/obj/item/storage/firstaid/fire = 2,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/o2 = 1,
		/obj/item/storage/pill_bottle/mutadone = 1,
		/obj/item/storage/pill_bottle/neurine = 1,
		/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor = 4
	)

/datum/uplink_item/bundles_TC/crate/shuttle
	name = "Zestaw do budowy kradzionego promu"
	desc = "Każda drużyna Syndykatu potrzebuje własnego promu. Szkoda, że nie dostaliście żadnego, ale to nie problem, jeśli macie trochę zbędnych TC! Nowy zestaw do budowy promu (produkcji Syndykatu) zawiera wszystko, czego potrzebujesz, by wzbić się w przestrzeń! Wszystkim agentom Syndykatu zaleca się ignorowanie etykiet Nanotrasen na produktach. Skafandry kosmiczne nie są dołączone."
	cost = 15	//There are multiple uses for the RCD and plasma canister, but both are easilly accessible for items that cost less than all of their TC.
	contents = list(
		/obj/machinery/portable_atmospherics/canister/toxins = 1,
		/obj/item/construction/rcd/combat = 1,
		/obj/item/rcd_ammo/large = 2,
		/obj/item/shuttle_creator = 1,
		/obj/item/pipe_dispenser = 2,
		/obj/item/storage/toolbox/syndicate = 2,
		/obj/item/storage/toolbox/electrical = 1,
		/obj/item/circuitboard/computer/shuttle/flight_control = 1,
		/obj/item/circuitboard/machine/shuttle/engine/plasma = 2,
		/obj/item/circuitboard/machine/shuttle/heater = 2,
		/obj/item/storage/part_replacer/cargo = 1,
		/obj/item/electronics/apc = 1,
		/obj/item/wallframe/apc = 1
	)

// Dangerous Items
/datum/uplink_item/dangerous
	category = "Conspicuous Weapons"

/datum/uplink_item/dangerous/poisonknife
	name = "Zatruty nóż"
	desc = "Nóż z dwóch ostrzy ostrych jak brzytwa. W rękojeści ma ukrytą komorę na płyny, które wstrzykuje przy każdym pchnięciu."
	item = /obj/item/kitchen/knife/poison
	cost = 8 // all in all it's not super stealthy and you have to get some chemicals yourself

/datum/uplink_item/dangerous/rawketlawnchair
	name = "Granatnik rakietowy 84 mm"
	desc = "Granatnik rakietowy wielokrotnego użytku, załadowany pociskiem odłamkowo-burzącym 84 mm o niskiej mocy. Gwarantujemy, że twój cel odejdzie z hukiem, albo zwrot pieniędzy!"
	item = /obj/item/gun/ballistic/rocketlauncher
	cost = 8
	surplus = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/grenadelauncher
	name = "Uniwersalny granatnik"
	desc = "Granatnik wielokrotnego użytku. Mieści 3 pociski, ale nie jest załadowany. Działa z granatami i kilkoma innymi rodzajami materiałów wybuchowych."
	item = /obj/item/gun/grenadelauncher
	cost = 6
	surplus = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/pie_cannon
	name = "Działo na torty z kremem bananowym"
	desc = "Specjalne działo na torty dla specjalnego klauna. Mieści do 20 tortów i co dwie sekundy samo wytwarza nowy!"
	cost = 10
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/bananashield
	name = "Bananiumowa tarcza energetyczna"
	desc = "Najpotężniejsza broń obronna klauna. Ta osobista tarcza daje niemal całkowitą odporność na energetyczne ataki z dystansu, odbijając je w strzelających. Można nią też rzucić – odbija się od ludzi, przewraca ich i wraca do ciebie, nawet jeśli spudłujesz. UWAGA: NIE PRÓBUJ STAWAĆ NA ROZŁOŻONEJ TARCZY, NAWET W BUTACH ANTYPOŚLIZGOWYCH."
	item = /obj/item/shield/energy/bananium
	cost = 16
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/clownsword
	name = "Bananiumowy miecz energetyczny"
	desc = "Miecz energetyczny, który nie zadaje obrażeń, ale przewraca każdego, kogo dotknie – w walce wręcz, po rzucie albo gdy ktoś na niego nadepnie. Uważaj na bratobójczy ogień, bo nawet buty antypoślizgowe przed nim nie chronią."
	item = /obj/item/melee/transforming/energy/sword/bananium
	cost = 3
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/bioterror
	name = "Rozpylacz chemikaliów biologicznie niebezpiecznych"
	desc = "Ręczny rozpylacz, który rozprasza wybrane chemikalia na dużym obszarze. Zabójcza mieszanka, którą jest napełniony, specjalnie przygotowana przez Spółdzielnię Tygrysa, dezorientuje, rani i obezwładnia wrogów... Używaj z najwyższą ostrożnością, by nie wystawić na nią siebie i kolegów operatorów."
	item = /obj/item/reagent_containers/spray/chemsprayer/bioterror
	cost = 20
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/throwingweapons
	name = "Pudełko broni miotanej"
	desc = "Pudełko shurikenów i wzmocnionych bol z dawnych ziemskich sztuk walki. To bardzo skuteczna broń miotana. Bola potrafi powalić cel, a shurikeny wbijają się w kończyny."
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3
	illegal_tech = FALSE

/datum/uplink_item/dangerous/shotgun
	name = "Strzelba Bulldog"
	desc = "W pełni załadowana półautomatyczna strzelba z magazynkiem bębnowym. Pasuje do niej każda amunicja 12g. Zaprojektowana do walki z ludźmi na krótkim dystansie."
	item = /obj/item/gun/ballistic/shotgun/bulldog
	cost = 8
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/smg
	name = "Pistolet maszynowy C-20r"
	desc = "W pełni załadowany pistolet maszynowy bullpup Scarborough Arms. C-20r strzela nabojami .45 z 24-nabojowego magazynka i pasuje do niego tłumik."
	item = /obj/item/gun/ballistic/automatic/c20r
	cost = 10
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/superechainsaw
	name = "Superenergetyczna piła łańcuchowa"
	desc = "Niezwykle zabójcza zmodyfikowana piła łańcuchowa z plazmowymi ostrzami energetycznymi zamiast metalowych i eleganckim czarno-czerwonym wykończeniem. Rozrywa materię z ogromną skutecznością, ale jest ciężka, duża i potwornie głośna. Jej ostrze wzmocniono, by zadawało jeszcze więcej obrażeń i na chwilę powalało ofiary."
	item = /obj/item/chainsaw/energy/doom
	cost = 22
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/doublesword
	name = "Podwójny miecz energetyczny"
	desc = "Podwójny miecz energetyczny zadaje nieco więcej obrażeń niż zwykły miecz energetyczny i odbija wszystkie pociski energetyczne, ale trzeba go trzymać oburącz."
	item = /obj/item/dualsaber
	player_minimum = 25
	cost = 18
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/doublesword/get_discount()
	return pick(4;0.8,2;0.65,1;0.5)

/datum/uplink_item/dangerous/sword
	name = "Miecz energetyczny"
	desc = "Miecz energetyczny to broń sieczna z ostrzem z czystej energii. Po wyłączeniu jest na tyle mały, że mieści się w kieszeni. Włączenie wydaje głośny, charakterystyczny dźwięk."
	item = /obj/item/melee/transforming/energy/sword/saber
	cost = 8
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/shield
	name = "Tarcza energetyczna"
	desc = "Niezwykle przydatny osobisty projektor tarczy, który odbija pociski energetyczne i chroni przed innymi atakami. Połącz z mieczem energetycznym, a dostaniesz zabójczy duet."
	item = /obj/item/shield/energy
	cost = 16
	surplus = 20
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/flamethrower
	name = "Miotacz ognia"
	desc = "Miotacz ognia zasilany porcją wysoce łatwopalnych biotoksyn ukradzionych wcześniej ze stacji Nanotrasen. Pokaż swoje zdanie, piekąc tę hołotę w jej własnej chciwości. Używaj ostrożnie."
	item = /obj/item/flamethrower/full/tank
	cost = 4
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/dangerous/rapid
	name = "Rękawice Gwiazdy Północnej"
	desc = "Te rękawice pozwalają bardzo szybko okładać ludzi pięściami. Nie przyspieszają ataków bronią ani mięsistych pięści hulka."
	item = /obj/item/clothing/gloves/rapid
	cost = 8

/datum/uplink_item/dangerous/guardian
	name = "Holoparazyty"
	desc = "Choć dzięki hologramom z twardego światła i nanomaszynom potrafią dokonywać niemal czarodziejskich wyczynów, potrzebują organicznego nosiciela jako bazy i źródła paliwa. Holoparazyty występują w różnych odmianach i dzielą obrażenia z nosicielem."
	item = /obj/item/guardiancreator/tech
	cost = 18
	surplus = 10
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	player_minimum = 25
	restricted = TRUE

/datum/uplink_item/dangerous/machinegun
	name = "Ręczny karabin maszynowy L6"
	desc = "W pełni załadowany karabin maszynowy zasilany taśmą, produkcji Aussec Armoury. Ta zabójcza broń ma ogromny, 50-nabojowy magazynek niszczycielskiej amunicji 7,12x82 mm."
	item = /obj/item/gun/ballistic/automatic/l6_saw
	cost = 18
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/carbine
	name = "Karabinek M-90gl"
	desc = "W pełni załadowany, specjalistyczny karabinek strzelający seriami po trzy naboje 5,56 mm z 30-nabojowego magazynka, z podlufowym granatnikiem 40 mm. Granatnik odpalasz ogniem alternatywnym."
	item = /obj/item/gun/ballistic/automatic/m90
	cost = 14
	surplus = 50
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/powerfist
	name = "Pięść mocy"
	desc = "Pięść mocy to metalowa rękawica z wbudowanym taranem tłokowym zasilanym z zewnętrznej butli z gazem. Po trafieniu taran wysuwa się do przodu i zadaje poważne obrażenia. Kluczem na zaworze tłoka regulujesz ilość gazu na cios, by zadawać więcej obrażeń i odrzucać cele dalej. Śrubokrętem wyjmiesz podłączone butle."
	item = /obj/item/melee/powerfist
	cost = 6

/datum/uplink_item/dangerous/sniper
	name = "Karabin snajperski"
	desc = "Furia na odległość w stylu Syndykatu. Gwarantowany szok i przerażenie albo zwrot TC!"
	item = /obj/item/gun/ballistic/automatic/sniper_rifle/syndicate
	cost = 16
	surplus = 25
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/pistol
	name = "Pistolet Stieczkin"
	desc = "Mały, łatwy do ukrycia pistolet na naboje 10 mm auto w 8-nabojowych magazynkach. Pasuje do niego tłumik."
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = 7
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/bolt_action
	name = "Używany karabin"
	desc = "Okropnie przestarzały karabin powtarzalny. Trzeba być zdesperowanym, żeby go używać."
	item = /obj/item/gun/ballistic/rifle/boltaction
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/dangerous/revolver
	name = "Rewolwer Syndykatu"
	desc = "Brutalnie prosty rewolwer Syndykatu na naboje .357 Magnum, z 7 komorami."
	item = /obj/item/gun/ballistic/revolver
	cost = 12
	surplus = 50
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/foamsmg
	name = "Zabawkowy pistolet maszynowy"
	desc = "W pełni załadowany pistolet maszynowy bullpup Donksoft, który strzela strzałkami do tłumienia zamieszek z 20-nabojowego magazynka."
	item = /obj/item/gun/ballistic/automatic/c20r/toy
	cost = 5
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/foammachinegun
	name = "Zabawkowy karabin maszynowy"
	desc = "W pełni załadowany karabin maszynowy Donksoft zasilany taśmą. Ta broń ma ogromny, 50-nabojowy magazynek niszczycielskich strzałek do tłumienia zamieszek, które jedną serią potrafią na chwilę obezwładnić przeciwnika."
	item = /obj/item/gun/ballistic/automatic/l6_saw/toy
	cost = 10
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/foampistol
	name = "Zabawkowy pistolet ze strzałkami prewencyjnymi"
	desc = "Niewinnie wyglądający pistolet zabawkowy na piankowe strzałki. Załadowany strzałkami do tłumienia zamieszek, które skutecznie obezwładniają cel."
	item = /obj/item/gun/ballistic/automatic/toy/pistol/riot
	cost = 2
	surplus = 10

/datum/uplink_item/dangerous/semiautoturret
	name = "Półautomatyczna wieżyczka"
	desc = "Autowieżyczka strzelająca półautomatycznie pociskami balistycznymi. Wieżyczka jest masywna i nie da się jej przenieść. Po zamówieniu dostajesz mniejszy nadajnik, który po aktywacji teleportuje do siebie właściwą wieżyczkę."
	item = /obj/item/sbeacondrop/semiautoturret
	cost = 8
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/heavylaserturret
	name = "Ciężka wieżyczka laserowa"
	desc = "Autowieżyczka strzelająca ciężkimi laserami. Wieżyczka jest masywna i nie da się jej przenieść. Po zamówieniu dostajesz mniejszy nadajnik, który po aktywacji teleportuje do siebie właściwą wieżyczkę."
	item = /obj/item/sbeacondrop/heavylaserturret
	cost = 12
	purchasable_from = UPLINK_NUKE_OPS


// Stealthy Weapons
/datum/uplink_item/stealthy_weapons
	category = "Stealthy Weapons"

/datum/uplink_item/stealthy_weapons/combatglovesplus
	name = "Rękawice bojowe plus"
	desc = "Ognioodporne rękawice odporne na porażenie prądem. W przeciwieństwie do zwykłych rękawic bojowych dzięki nanotechnologii uczą noszącego krav magi."
	item = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	cost = 5
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	surplus = 0

/datum/uplink_item/stealthy_weapons/cqc
	name = "Podręcznik CQC"
	desc = "Podręcznik, który uczy jednego użytkownika taktycznej walki w bliskim kontakcie (CQC), a potem się samozniszcza."
	item = /obj/item/book/granter/martial/cqc
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	cost = 12
	surplus = 0

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Pistolet na strzałki"
	desc = "Miniaturowa wersja zwykłej wyrzutni strzykawek. Strzela bardzo cicho i mieści się wszędzie tam, gdzie mały przedmiot."
	item = /obj/item/gun/syringe/syndicate
	cost = 3
	surplus = 50

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Odwodniony kosmiczny karp"
	desc = "Wygląda jak pluszowy karp, ale wystarczy dodać wody, a staje się prawdziwym kosmicznym karpiem! Przed użyciem aktywuj go w dłoni, żeby wiedział, że nie ma cię zabijać."
	item = /obj/item/toy/plush/carpplushie/dehy_carp
	cost = 1

/datum/uplink_item/stealthy_weapons/edagger
	name = "Sztylet energetyczny"
	desc = "Sztylet z energii, który po wyłączeniu wygląda i działa jak długopis."
	item = /obj/item/pen/edagger
	cost = 3

/datum/uplink_item/stealthy_weapons/martialartskarate
	name = "Zwój karate"
	desc = "Ten zwój skrywa sekrety dawnej sztuki walki – karate. Poznasz różne sposoby obezwładniania i dobijania powalonych wrogów."
	item = /obj/item/book/granter/martial/karate
	cost = 4
	surplus = 40

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Zwój sztuk walki"
	desc = "Ten zwój skrywa sekrety dawnej sztuki walki. Opanujesz walkę wręcz i będziesz odbijać wszystkie pociski z broni dystansowej, ale odmówisz używania niehonorowej broni dystansowej."
	item = /obj/item/book/granter/martial/carp
	cost = 16
	player_minimum = 20
	surplus = 10
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_weapons/radbow
	name = "Gamma-łuk"
	desc = "Nowo opracowany, zabójczy kuzyn kuszy energetycznej. Jest znacznie bardziej zabójczy kosztem siły obezwładniania. Syntetyzuje i wystrzeliwuje bełty z groźnymi toksynami, które dezorientują i napromieniowują cele. Wytwarza nieskończenie wiele bełtów, a po każdym strzale sam ładuje się w około 25 sekund."
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow/radbow
	cost = 8
	surplus = 50

//NSV13 - ebow does paralyze
/datum/uplink_item/stealthy_weapons/crossbow
	name = "Miniaturowa kusza energetyczna"
	desc = "Krótki łuk zamontowany w miniaturowym łożu. Na tyle mały, że niezauważony zmieści się w kieszeni albo torbie. Syntetyzuje i wystrzeliwuje bełty z obezwładniającą toksyną, która na chwilę ogłusza i dezorientuje cele, a ich mowa staje się bełkotliwa jak po alkoholu. Wytwarza nieskończenie wiele bełtów, ale po każdym strzale potrzebuje chwili na naładowanie."
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow
	cost = 12
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)


/datum/uplink_item/stealthy_weapons/origami_kit
	name = "Zestaw do origami w pudełku"
	desc = "W pudełku jest poradnik tworzenia mistrzowskich dzieł origami, dzięki któremu zwykłe kartki papieru zmienisz w idealnie aerodynamiczne (i potencjalnie zabójcze) papierowe samolociki."
	item = /obj/item/storage/box/syndie_kit/origami_bundle
	cost = 6
	surplus = 20
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_weapons/traitor_chem_bottle
	name = "Zestaw trucizn"
	desc = "Asortyment zabójczych chemikaliów zapakowany w kompaktowe pudełko. W zestawie strzykawka do precyzyjniejszego podawania."
	item = /obj/item/storage/box/syndie_kit/chemical
	cost = 7
	surplus = 50

/datum/uplink_item/stealthy_weapons/romerol_kit
	name = "Romerol"
	desc = "Wysoce eksperymentalny środek bioterrorystyczny, który tworzy uśpione guzki wżerające się w istotę szarą mózgu. Po śmierci guzki przejmują kontrolę nad ciałem i częściowo je ożywiają – z bełkotliwą mową, agresją i zdolnością zarażania tym środkiem innych."
	item = /obj/item/storage/box/syndie_kit/romerol
	cost = 20
	cant_discount = TRUE
	murderbone_type = TRUE
	surplus = 0

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Usypiający długopis"
	desc = "Strzykawka udająca działający długopis, napełniona silną mieszanką leków, w tym mocnym środkiem znieczulającym i substancją, która nie pozwala ofierze mówić. Długopis mieści jedną dawkę mieszanki i można go napełnić dowolnymi chemikaliami. Pamiętaj, że zanim cel zaśnie, może się jeszcze ruszać i działać."
	item = /obj/item/pen/sleepy
	cost = 5
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_weapons/suppressor
	name = "Tłumik"
	desc = "Ten tłumik wycisza strzały broni, na którą go założysz, co poprawia skrytość i ułatwia zasadzki. Pasuje do wielu małych broni palnych, w tym do Stieczkina i C-20r, ale nie do rewolwerów ani broni energetycznej."
	item = /obj/item/suppressor
	cost = 2
	surplus = 10
	purchasable_from = ~UPLINK_CLOWN_OPS

// Ammunition
/datum/uplink_item/ammo
	category = "Ammunition"
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "Magazynek pistoletowy 10 mm"
	desc = "Dodatkowy 8-nabojowy magazynek 10 mm do pistoletu Stieczkin."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistolap
	name = "Magazynek przeciwpancerny 10 mm"
	desc = "Dodatkowy 8-nabojowy magazynek 10 mm do pistoletu Stieczkin. Te naboje słabiej ranią cel, ale przebijają osłony."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistolhp
	name = "Magazynek z pociskami wydrążonymi 10 mm"
	desc = "Dodatkowy 8-nabojowy magazynek 10 mm do pistoletu Stieczkin. Te naboje zadają więcej obrażeń, ale są bezużyteczne przeciw pancerzom."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/pistolfire
	name = "Magazynek zapalający 10 mm"
	desc = "Dodatkowy 8-nabojowy magazynek 10 mm do pistoletu Stieczkin. Naboje zapalające zadają niewiele obrażeń, ale podpalają cel."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/shotgun
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/shotgun/bag
	name = "Torba z amunicją 12g"
	desc = "Torba z ilością amunicji 12g wystarczającą dla całej drużyny, w obniżonej cenie."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun
	cost = 14

/datum/uplink_item/ammo/shotgun/buck
	name = "Bęben śrutu 12g"
	desc = "Dodatkowy 8-nabojowy magazynek ze śrutem do strzelby Bulldog. Przodem do wroga."
	item = /obj/item/ammo_box/magazine/m12g

/datum/uplink_item/ammo/shotgun/dragon
	name = "Bęben smoczego oddechu 12g"
	desc = "Alternatywny 8-nabojowy magazynek ze smoczym oddechem do strzelby Bulldog. „Jestem podpalaczem, pokręconym podpalaczem!”"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/shotgun/meteor
	name = "Naboje meteorytowe 12g"
	desc = "Alternatywny 8-nabojowy magazynek z brenekami meteorytowymi do strzelby Bulldog. Świetne do wyrywania śluz z futryn i powalania wrogów."
	item = /obj/item/ammo_box/magazine/m12g/meteor
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/shotgun/slug
	name = "Bęben brenek 12g"
	desc = "Dodatkowy 8-nabojowy magazynek z brenekami do strzelby Bulldog. Teraz 8 razy mniejsza szansa, że postrzelisz kumpli."
	cost = 3
	item = /obj/item/ammo_box/magazine/m12g/slug

/datum/uplink_item/ammo/shotgun/breacher
	name = "Bęben brenek wyważających 12g"
	desc = "Alternatywny 8-nabojowy magazynek z brenekami wyważającymi do strzelby Bulldog. Świetne do szybkiego niszczenia lekkich przeszkód, takich jak śluzy i okna."
	item = /obj/item/ammo_box/magazine/m12g/breacher

//NSV13 - readded stun slugs
/datum/uplink_item/ammo/shotgun/stun
	name = "Bęben brenek paralizujących 12g"
	desc = "Alternatywny 8-nabojowy magazynek z brenekami paralizującymi do strzelby Bulldog. Mówienie, że są całkowicie nieśmiercionośne, byłoby kłamstwem."
	item = /obj/item/ammo_box/magazine/m12g/stun
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/revolver
	name = "Szybkoładowacz .357"
	desc = "Szybkoładowacz z siedmioma dodatkowymi nabojami .357 Magnum do rewolweru Syndykatu. Na czas, gdy naprawdę potrzebujesz wielu trupów."
	item = /obj/item/ammo_box/a357
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/a40mm
	name = "Pudełko granatów 40 mm"
	desc = "Pudełko granatów odłamkowo-burzących 40 mm do podlufowego granatnika M-90gl. Koledzy z drużyny poproszą cię, żebyś nie strzelał nimi w wąskich korytarzach."
	item = /obj/item/ammo_box/a40mm
	cost = 6
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/smg/bag
	name = "Torba z amunicją .45"
	desc = "Torba z ilością amunicji .45 wystarczającą dla całej drużyny, w obniżonej cenie."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/smg
	cost = 22 //instead of 27 TC
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/smg
	name = "Magazynek .45 do PM"
	desc = "Dodatkowy 24-nabojowy magazynek .45 do pistoletu maszynowego C-20r."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/sniper
	cost = 4
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/sniper/basic
	name = "Magazynek .50"
	desc = "Dodatkowy standardowy 6-nabojowy magazynek do karabinów snajperskich .50."
	item = /obj/item/ammo_box/magazine/sniper_rounds

/datum/uplink_item/ammo/sniper/penetrator
	name = "Magazynek przebijający .50"
	desc = "5-nabojowy magazynek z amunicją przebijającą do karabinów snajperskich .50. Przebija ściany i wielu wrogów naraz."
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 5

/datum/uplink_item/ammo/sniper/soporific
	name = "Magazynek usypiający .50"
	desc = "3-nabojowy magazynek z amunicją usypiającą do karabinów snajperskich .50. Uśpij swoich wrogów już dziś!"
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific
	cost = 6

/datum/uplink_item/ammo/carbine
	name = "Magazynek 5,56 mm ładowany od góry"
	desc = "Dodatkowy 30-nabojowy magazynek 5,56 mm do karabinka M-90gl. Te pociski mają mniejszą siłę niż naboje 7,12x82 mm, ale wciąż są mocniejsze od amunicji .45."
	item = /obj/item/ammo_box/magazine/m556
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/machinegun
	cost = 6
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/machinegun/basic
	name = "Magazynek pudełkowy 7,12x82 mm"
	desc = "50-nabojowy magazynek amunicji 7,12x82 mm do RKM L6. Zanim będziesz go potrzebować, i tak będziesz stać na stosie trupów."
	item = /obj/item/ammo_box/magazine/mm712x82

/datum/uplink_item/ammo/machinegun/ap
	name = "Magazynek pudełkowy 7,12x82 mm (przeciwpancerny)"
	desc = "50-nabojowy magazynek amunicji 7,12x82 mm do RKM L6, o specjalnych właściwościach, które przebijają nawet najwytrzymalsze pancerze."
	item = /obj/item/ammo_box/magazine/mm712x82/ap
	cost = 9

/datum/uplink_item/ammo/machinegun/hollow
	name = "Magazynek pudełkowy 7,12x82 mm (wydrążony)"
	desc = "50-nabojowy magazynek amunicji 7,12x82 mm do RKM L6, z wydrążonymi czubkami, które pomagają w starciu z nieopancerzonymi masami załogi."
	item = /obj/item/ammo_box/magazine/mm712x82/hollow

/datum/uplink_item/ammo/machinegun/incen
	name = "Magazynek pudełkowy 7,12x82 mm (zapalający)"
	desc = "50-nabojowy magazynek amunicji 7,12x82 mm do RKM L6, z czubkami pokrytymi specjalną łatwopalną mieszanką, która podpala każdego trafionego. Niektórzy po prostu chcą patrzeć, jak świat płonie."
	item = /obj/item/ammo_box/magazine/mm712x82/incen

/datum/uplink_item/ammo/machinegun/match
	name = "Magazynek pudełkowy 7,12x82 mm (wyczynowy)"
	desc = "50-nabojowy magazynek amunicji 7,12x82 mm do RKM L6. Nie wiedziałeś, że ktoś potrzebuje wyczynowej precyzji w amunicji do sikawki z kulami, ale te naboje są dopracowane i idealne do efektownych rykoszetów od ścian."
	item = /obj/item/ammo_box/magazine/mm712x82/match
	cost = 10

/datum/uplink_item/ammo/rocket
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/rocket/basic
	name = "Rakieta odłamkowo-burząca 84 mm"
	desc = "Przeciwpiechotna rakieta odłamkowo-burząca o niskiej mocy. Załatwi cię z klasą!"
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 3

/datum/uplink_item/ammo/rocket/hedp
	name = "Rakieta HEDP 84 mm"
	desc = "Rakieta HEDP o dużej mocy. Niezwykle skuteczna przeciw opancerzonym celom i otaczającemu je personelowi. Zasiej strach w sercach wrogów."
	item = /obj/item/ammo_casing/caseless/rocket/hedp
	cost = 5

/datum/uplink_item/ammo/pistolaps
	name = "Magazynek pistoletowy 9 mm"
	desc = "Dodatkowy 15-nabojowy magazynek 9 mm do pistoletu Stieczkin APS z pakietu piromana Specnazu."
	item = /obj/item/ammo_box/magazine/pistolm9mm
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/toydarts
	name = "Pudełko strzałek prewencyjnych"
	desc = "Pudełko 40 strzałek prewencyjnych Donksoft do uzupełniania każdego pasującego magazynka na piankowe strzałki. Nie zapomnij się podzielić!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	surplus = 0
	illegal_tech = FALSE

/datum/uplink_item/ammo/bioterror
	name = "Pudełko strzykawek bioterrorysty"
	desc = "Pudełko pełne napełnionych strzykawek z różnymi chemikaliami, które paraliżują ośrodki ruchu i mowy ofiary, przez co na jakiś czas nie może się ruszać ani mówić."
	item = /obj/item/storage/box/syndie_kit/bioterror
	cost = 6
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/bolt_action
	name = "Łódka do używanego karabinu"
	desc = "Łódka nabojowa do szybkiego ładowania karabinów powtarzalnych. Zawiera 5 nabojów."
	item = 	/obj/item/ammo_box/a762
	cost = 1
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

//Grenades and Explosives
/datum/uplink_item/explosives
	category = "Explosives"

/datum/uplink_item/explosives/bioterrorfoam
	name = "Granat pianowy bioterrorysty"
	desc = "Potężny granat z pianą chemiczną, który wyrzuca zabójczy potok piany: ogłusza, oślepia, dezorientuje, wywołuje mutacje i podrażnia węglowe formy życia. Specjalnie przyrządzony przez specjalistów od broni chemicznej ze Spółdzielni Tygrysa z dodatkiem toksyny z zarodników. Przed użyciem upewnij się, że skafander jest szczelny."
	item = /obj/item/grenade/chem_grenade/bioterrorfoam
	cost = 7
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/bombanana
	name = "Bombanan"
	desc = "Banan o wybuchowym smaku! Szybko pozbądź się skórki, bo kilka sekund po zjedzeniu banana wybucha z siłą minibomby Syndykatu."
	item = /obj/item/food/grown/banana/bombanana
	cost = 4 //it is a bit cheaper than a minibomb because you have to take off your helmet to eat it, which is how you arm it
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/buzzkill
	name = "Pudełko granatów Buzzkill"
	desc = "Pudełko z trzema granatami, które po aktywacji wypuszczają rój wściekłych pszczół. Pszczoły atakują bez wyjątku przyjaciół i wrogów, wstrzykując losowe toksyny. Dzięki uprzejmości BLF i Spółdzielni Tygrysa."
	item = /obj/item/storage/box/syndie_kit/bee_grenades
	cost = 16
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/c4
	name = "Materiał C-4"
	desc = "C-4 to plastyczny materiał wybuchowy z popularnej rodziny Composition C. Możesz nim wysadzać ściany, sabotować sprzęt albo podłączyć do niego zespół, by zmienić sposób detonacji. Da się go przyczepić niemal do wszystkiego i ma regulowany zapalnik czasowy z minimalnym ustawieniem 10 sekund."
	item = /obj/item/grenade/plastic/c4
	cost = 1

/datum/uplink_item/explosives/c4bag
	name = "Torba ładunków C-4"
	desc = "Bo czasem ilość to jakość. Zawiera 10 plastycznych ładunków C-4."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	cost = 8 //20% discount!
	cant_discount = TRUE

/datum/uplink_item/explosives/x4bag
	name = "Torba ładunków X-4"
	desc = "Zawiera 3 kształtowane plastyczne ładunki X-4. Podobne do C4, ale wybuchają mocniej i kierunkowo zamiast we wszystkie strony. X-4 można umieścić na twardej powierzchni, np. ścianie albo oknie – przebija się przez nią, raniąc wszystko po drugiej stronie, a dla użytkownika jest bezpieczniejszy. Gdy chcesz kontrolowanego wybuchu, który zostawi szerszą i głębszą dziurę."
	item = /obj/item/storage/backpack/duffelbag/syndie/x4
	cost = 4 //
	cant_discount = TRUE

/datum/uplink_item/explosives/clown_bomb_clownops
	name = "Bomba klauna"
	desc = "Bomba klauna to przezabawne urządzenie do potężnych psikusów. Ma regulowany zapalnik czasowy z minimum 60 sekund i można ją przykręcić kluczem do podłogi, żeby nikt jej nie przesunął. Bomba jest masywna i nie da się jej przenieść. Po zamówieniu dostajesz mniejszy nadajnik, który po aktywacji teleportuje do siebie właściwą bombę. Pamiętaj, że bombę da się rozbroić i część załogi może tego spróbować."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 15
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/detomatix
	name = "Dysk PDA Detomatix"
	desc = "Po włożeniu do osobistego asystenta cyfrowego ten dysk daje ci cztery okazje do zdetonowania PDA członków załogi, którzy mają włączone wiadomości. Fala uderzeniowa na chwilę ogłusza odbiorcę i na dłużej odbiera mu słuch."
	item = /obj/item/computer_hardware/hard_drive/role/virus/syndicate
	cost = 6
	restricted = TRUE

/datum/uplink_item/explosives/emp
	name = "Zestaw granatów EMP i implantera"
	desc = "Pudełko z pięcioma granatami EMP i implantem EMP na trzy użycia. Przydaje się do zakłócania łączności, broni energetycznej ochrony i krzemowych form życia, gdy jesteś w tarapatach."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 4

/datum/uplink_item/explosives/ducky
	name = "Wybuchowa gumowa kaczka"
	desc = "Z pozoru niewinna gumowa kaczka. Po położeniu uzbraja się i gwałtownie wybucha, gdy ktoś na nią nadepnie."
	item = /obj/item/deployablemine/traitor
	cost = 4

/datum/uplink_item/explosives/doorCharge
	name = "Ładunek do śluzy"
	desc = "Mały ładunek wybuchowy do sabotowania śluz – wybucha przy otwarciu. Żeby go założyć, zdejmij panel serwisowy śluzy i umieść go w środku."
	item = /obj/item/doorCharge
	cost = 4

/datum/uplink_item/explosives/virus_grenade
	name = "Granat z gruźlicą grzybiczą"
	desc = "Uzbrojony biogranat w kompaktowym pudełku. W zestawie pięć autostrzykawek z zestawem antidotum na wirusy biologiczne (BVAK), każda do szybkiego podania nawet dwóm osobom, strzykawka i butelka roztworu BVAK."
	item = /obj/item/storage/box/syndie_kit/tuberculosisgrenade
	cost = 14
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE

/datum/uplink_item/explosives/grenadier
	name = "Pas grenadiera"
	desc = "Pas z 26 śmiertelnie niebezpiecznymi i niszczycielskimi granatami. W zestawie dodatkowy multitool i śrubokręt."
	item = /obj/item/storage/belt/grenade/full
	purchasable_from = UPLINK_NUKE_OPS
	cost = 24
	surplus = 0

/datum/uplink_item/explosives/bigducky
	name = "Wybuchowa gumowa kaczka o dużej mocy"
	desc = "Z pozoru niewinna gumowa kaczka. Po położeniu uzbraja się i gwałtownie wybucha, gdy ktoś na nią nadepnie. Ten wariant ma ładunki X4 o dużej mocy, więc wybuch jest większy."
	item = /obj/item/deployablemine/traitor/bigboom
	cost = 10

/datum/uplink_item/explosives/pizza_bomb
	name = "Bomba w pizzy"
	desc = "Pudełko po pizzy ze sprytnie przymocowaną do wieczka bombą. Zapalnik czasowy ustawiasz, otwierając pudełko. Ponowne otwarcie uruchamia detonację po upływie czasu. W zestawie darmowa pizza – dla ciebie albo twojego celu!"
	item = /obj/item/pizzabox/bomb
	cost = 3
	surplus = 8

/datum/uplink_item/explosives/soap_clusterbang
	name = "Granat kasetowy Ślizgokalipsa"
	desc = "Tradycyjny granat kasetowy, którego ładunek składa się wyłącznie z mydła Syndykatu. Przydatny w każdej sytuacji!"
	item = /obj/item/grenade/clusterbuster/soap
	cost = 4

/datum/uplink_item/explosives/syndicate_bomb
	name = "Bomba Syndykatu"
	desc = "Bomba Syndykatu to przerażające urządzenie zdolne do ogromnych zniszczeń. Ma regulowany zapalnik czasowy z minimum 60 sekund i można ją przykręcić kluczem do podłogi, żeby nikt jej nie przesunął. Bomba jest masywna i nie da się jej przenieść. Po zamówieniu dostajesz mniejszy nadajnik, który po aktywacji teleportuje do siebie właściwą bombę. Pamiętaj, że bombę da się rozbroić i część załogi może tego spróbować. Rdzeń bomby można wyważyć i zdetonować ręcznie innymi materiałami wybuchowymi."
	item = /obj/item/sbeacondrop/bomb
	cost = 12

/datum/uplink_item/explosives/syndicate_detonator
	name = "Detonator Syndykatu"
	desc = "Detonator Syndykatu to urządzenie towarzyszące bombie Syndykatu. Wystarczy wcisnąć dołączony przycisk, a zaszyfrowana częstotliwość radiowa każe wszystkim uzbrojonym bombom Syndykatu wybuchnąć. Przydaje się, gdy liczy się szybkość albo chcesz zsynchronizować kilka wybuchów. Zanim użyjesz detonatora, odsuń się poza zasięg wybuchu."
	item = /obj/item/syndicatedetonator
	cost = 1
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Minibomba Syndykatu"
	desc = "Minibomba to granat z pięciosekundowym zapalnikiem. Po detonacji robi małą dziurę w kadłubie i zadaje duże obrażenia pobliskiemu personelowi."
	item = /obj/item/grenade/syndieminibomb
	cost = 5
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/tearstache
	name = "Granat łzawowąsowy"
	desc = "Granat z gazem łzawiącym, który przykleja wąsy do twarzy każdego, kto nie ma maski klauna albo mima. Wąsy trzymają się twarzy wszystkich celów przez minutę i nie pozwalają używać masek oddechowych ani podobnych urządzeń."
	item = /obj/item/grenade/chem_grenade/teargas/moustache
	cost = 3
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/viscerators
	name = "Granat zrzutowy z wisceratorami"
	desc = "Wyjątkowy granat, który po aktywacji wypuszcza rój wisceratorów. Ścigają one i szatkują każdego w okolicy, kto nie jest operatorem."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 6
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/explosive_flashbulbs
	name = "Wybuchowa żarówka flasha"
	desc = "Żarówka flasha napchana materiałem wybuchowym. Gdy niczego nieświadomy funkcjonariusz ochrony jej użyje, nastąpi gwałtowny wybuch."
	item = /obj/item/flashbulb/bomb
	cost = 1
	surplus = 8

//Support and Mechs
/datum/uplink_item/support
	category = "Support and Exosuits"
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/support/clown_reinforcement
	name = "Posiłki klaunów"
	desc = "Wezwij dodatkowego klauna, żeby dzielić się zabawą. Ma pełne wyposażenie startowe, ale żadnych telekryształów."
	item = /obj/item/antag_spawner/nuke_ops/clown
	cost = 18
	purchasable_from = UPLINK_CLOWN_OPS
	restricted = TRUE

/datum/uplink_item/support/reinforcement
	name = "Posiłki"
	desc = "Wezwij dodatkowego członka drużyny. Nie przyjdzie z żadnym sprzętem, więc musisz zostawić trochę telekryształów, żeby go uzbroić."
	item = /obj/item/antag_spawner/nuke_ops
	cost = 24
	refundable = TRUE
	purchasable_from = UPLINK_NUKE_OPS
	restricted = TRUE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Szturmowy cyborg Syndykatu"
	desc = "Cyborg zaprojektowany i zaprogramowany do systematycznej eksterminacji personelu spoza Syndykatu. Wyposażony w samouzupełniający się LKM, granatnik, miecz energetyczny, emag, pinpointer, flash i łom."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refundable = TRUE
	cost = 64
	restricted = TRUE

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Medyczny cyborg Syndykatu"
	desc = "Bojowy cyborg medyczny. Ma ograniczony potencjał ofensywny, ale z nawiązką nadrabia to możliwościami wsparcia. Wyposażony w hypospray z nanitami, medyczny emiter wiązki, bojowy defibrylator, pełny zestaw chirurgiczny z piłą energetyczną, emag, pinpointer i flash. Dzięki torbie na organy operuje tak samo dobrze jak każdy humanoid."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refundable = TRUE
	cost = 32
	restricted = TRUE

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Sabotażowy cyborg Syndykatu"
	desc = "Usprawniony cyborg inżynieryjny z ukrytymi modułami. Nie potrafi też zostawić spawarki na promie. Oprócz zwykłego sprzętu inżynieryjnego ma specjalny znakownik adresowy, który pozwala mu poruszać się po sieci zsypów. Projektor kameleona pozwala mu udawać cyborga Nanotrasen, a do tego ma widzenie termowizyjne i pinpointer."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refundable = TRUE
	cost = 32
	restricted = TRUE

/datum/uplink_item/support/gygax
	name = "Egzoszkielet Dark Gygax"
	desc = "Lekki egzoszkielet w ciemnym malowaniu. Szybkość i dobór wyposażenia czynią go świetnym do ataków typu uderz i uciekaj. Ma karabinek zapalający, wyrzutnię granatów hukowo-błyskowych, teleporter, silniki jonowe i układ energetyczny Tesli."
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 80

/datum/uplink_item/support/honker
	name = "Mroczny H.O.N.K."
	desc = "Bojowy mech klauna z wyrzutniami skórek bombananów i granatów łzawowąsowych oraz wszechobecnym HoNkER BlAsT 5000."
	item = /obj/mecha/combat/honker/dark/loaded
	cost = 80
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/support/mauler
	name = "Egzoszkielet Mauler"
	desc = "Ogromny i niezwykle zabójczy egzoszkielet klasy wojskowej. Ma celowanie dalekiego zasięgu, wektorowanie ciągu i wyrzutnię dymu. Wyposażony w LKM, karabinek śrutowy, wyrzutnię rakiet, wzmacniacz pancerza przeciwpociskowego i układ energetyczny Tesli."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 140

// Stealth Items
/datum/uplink_item/stealthy_tools
	category = "Stealth Gadgets"

/datum/uplink_item/stealthy_tools/agent_card
	name = "Karta identyfikacyjna agenta"
	desc = "Karta agenta nie pozwala sztucznej inteligencji śledzić jej właściciela i potrafi kopiować dostępy z innych kart identyfikacyjnych. Dostępy się sumują, więc zeskanowanie jednej karty nie kasuje dostępów z innej. Można ją też podrobić, by pokazywała nowe stanowisko i nazwisko – dowolnie wiele razy. Do niektórych miejsc i urządzeń Syndykatu wejdziesz tylko z taką kartą."
	item = /obj/item/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/ai_detector
	name = "Wykrywacz sztucznej inteligencji"
	desc = "Działający multitool, który czerwienieje, gdy wykryje obserwującą go sztuczną inteligencję. Po aktywacji pokazuje dokładnie, skąd SI patrzy, i martwe pola pobliskich kamer ochrony. Wiedza o tym, kiedy obserwuje cię SI, pomaga ci wiedzieć, kiedy się kryć, a martwe pola pomagają znaleźć drogi ucieczki."
	item = /obj/item/multitool/ai_detect
	cost = 1

/datum/uplink_item/stealthy_tools/chameleon
	name = "Zestaw kameleona"
	desc = "Zestaw przedmiotów z technologią kameleona, dzięki której przebierzesz się za prawie wszystko na stacji, i nie tylko! Z powodu cięć budżetowych buty nie chronią przed poślizgnięciem."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Projektor kameleona"
	desc = "Rzuca na użytkownika obraz, który upodabnia go do zeskanowanego przedmiotu, dopóki trzyma projektor w dłoni. Przebrani poruszają się powoli, a pociski przelatują nad nimi."
	item = /obj/item/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/codespeak_manual
	name = "Podręcznik Codespeak"
	desc = "Agentów Syndykatu można wyszkolić w używaniu zestawu słów kodowych do przekazywania złożonych informacji. Dla postronnych brzmi to jak losowe pojęcia i nazwy drinków. Ten podręcznik uczy cię Codespeaku. Możesz też uderzyć nim kogoś, żeby go nauczyć. To wydanie deluxe z nieograniczoną liczbą użyć."
	item = /obj/item/codespeak_manual/unlimited
	cost = 2

/datum/uplink_item/stealthy_tools/combatbananashoes
	name = "Bojowe bananowe buty"
	desc = "Tak jak zwykłe bojowe buty klauna chronią noszącego przed większością poślizgnięć, a do tego przy chodzeniu wytwarzają mnóstwo syntetycznych skórek od banana, o które potykają się ewentualni pościgowcy. Piszczą też dużo głośniej."
	item = /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	cost = 8
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/stealthy_tools/taeclowndo_shoes
	name = "Buty tae-klaun-do"
	desc = "Buty dla najbardziej elitarnych agentów z ojczyzny Honkmatki. Dopóki je nosisz, dają ci mistrzostwo w tae-klaun-do z kilkoma ruchami honk-fu."
	cost = 12
	item = /obj/item/clothing/shoes/clown_shoes/taeclowndo
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/stealthy_tools/emplight
	name = "Latarka EMP"
	desc = "Mały, samoładujący się emiter EMP krótkiego zasięgu udający działającą latarkę. Przydaje się do zakłócania słuchawek, kamer, drzwi, szafek i borgów podczas cichych operacji. Uderzenie celu tą latarką kieruje w niego impuls elektromagnetyczny i zużywa ładunek."
	item = /obj/item/flashlight/emp
	cost = 3
	surplus = 30

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Coś zawaliłeś i ochrona depcze ci po piętach? Ta poręczna strzykawka da ci zupełnie nową tożsamość i wygląd."
	item = /obj/item/reagent_containers/syringe/mulligan
	cost = 3
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "Antypoślizgowe buty kameleona"
	desc = "Te buty pozwalają biegać po mokrej podłodze i śliskich przedmiotach bez przewracania się. Nie działają na powierzchniach mocno pokrytych smarem."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 3
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 4
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_tools/chambowman
	name = "Słuchawki kameleona chroniące przed hukiem"
	desc = "Słuchawki wzmocnione tak, by chroniły uszy przed granatami hukowo-błyskowymi, z technologią kameleona do przebrania."
	item = /obj/item/radio/headset/chameleon/bowman
	cost = 2

/datum/uplink_item/stealthy_tools/chamweldinggoggles
	name = "Okulary kameleona chroniące przed błyskiem"
	desc = "Okulary wzmocnione tak, by chroniły oczy przed błyskami spawania, z technologią kameleona do przebrania."
	item = /obj/item/clothing/glasses/chameleon/flashproof
	cost = 2

/datum/uplink_item/stealthy_tools/chaminsuls
	name = "Rękawice bojowe kameleona"
	desc = "Rękawice odporne na ogień i porażenie prądem, z technologią kameleona do przebrania."
	item = /obj/item/clothing/gloves/chameleon/combat
	cost = 1

/datum/uplink_item/stealthy_tools/chambowman
	name = "Słuchawki kameleona chroniące przed hukiem"
	desc = "Słuchawki wzmocnione tak, by chroniły uszy przed granatami hukowo-błyskowymi, z technologią kameleona do przebrania."
	item = /obj/item/radio/headset/chameleon/bowman
	cost = 2

/datum/uplink_item/stealthy_tools/chamweldinggoggles
	name = "Okulary kameleona chroniące przed błyskiem"
	desc = "Okulary wzmocnione tak, by chroniły oczy przed błyskami spawania, z technologią kameleona do przebrania."
	item = /obj/item/clothing/glasses/chameleon/flashproof
	cost = 2

/datum/uplink_item/stealthy_tools/chaminsuls
	name = "Rękawice bojowe kameleona"
	desc = "Rękawice odporne na ogień i porażenie prądem, z technologią kameleona do przebrania."
	item = /obj/item/clothing/gloves/chameleon/combat
	cost = 1

/datum/uplink_item/stealthy_tools/jammer
	name = "Zagłuszacz sygnału"
	desc = "Po włączeniu to urządzenie zakłóca wszystkie pobliskie wychodzące sygnały bezprzewodowe."
	item = /obj/item/jammer
	cost = 5

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Torba przemytnika"
	desc = "Ta torba jest na tyle cienka, że zmieści się w szczelinie między poszyciem a płytkami podłogi. Świetna do chowania kradzionych łupów. W środku łom, płytka podłogowa i trochę kontrabandy."
	item = /obj/item/storage/backpack/satchel/flat/with_tools
	cost = 1
	surplus = 30
	illegal_tech = FALSE

//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = "Space Suits"
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Skafander kosmiczny Syndykatu"
	desc = "Ten czerwono-czarny skafander kosmiczny Syndykatu krępuje ruchy mniej niż wersje Nanotrasen, mieści się w torbie i ma miejsce na broń. Załoga Nanotrasen jest jednak szkolona, by zgłaszać każdy widziany czerwony skafander."
	item = /obj/item/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/suits/hardsuit
	name = "Hardsuit Syndykatu"
	desc = "Budzący grozę skafander nuklearnego agenta Syndykatu. Ma nieco lepsze opancerzenie, wbudowany plecak odrzutowy zasilany ze standardowych butli i zaawansowany system lokalizacji drużyny. Przełączanie trybu bojowego daje ci swobodę ruchu luźnego munduru bez utraty opancerzenia. Do tego skafander się składa, więc zmieści się w plecaku. Załoga Nanotrasen na widok tych skafandrów zwykle wpada w panikę."
	item = /obj/item/clothing/suit/space/hardsuit/syndi
	cost = 7
	purchasable_from = ~UPLINK_NUKE_OPS //you can't buy it in nuke, because the elite hardsuit costs the same while being better

/datum/uplink_item/suits/hardsuit/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	var/obj/item/clothing/suit/space/hardsuit/suit = ..()
	var/datum/component/tracking_beacon/beacon = suit.GetComponent(/datum/component/tracking_beacon)
	var/datum/component/team_monitor/hud = suit.helmet.GetComponent(/datum/component/team_monitor)

	var/datum/antagonist/nukeop/nukie = is_nuclear_operative(user)
	if(nukie?.nuke_team?.team_frequency)
		if(hud)
			hud.set_frequency(nukie.nuke_team.team_frequency)
		if(beacon)
			beacon.set_frequency(nukie.nuke_team.team_frequency)
	return suit

/datum/uplink_item/suits/hardsuit/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	var/obj/item/clothing/suit/space/hardsuit/suit = ..()
	var/datum/component/tracking_beacon/beacon = suit.GetComponent(/datum/component/tracking_beacon)
	var/datum/component/team_monitor/hud = suit.helmet.GetComponent(/datum/component/team_monitor)

	var/datum/antagonist/nukeop/nukie = is_nuclear_operative(user)
	if(nukie?.nuke_team?.team_frequency)
		if(hud)
			hud.set_frequency(nukie.nuke_team.team_frequency)
		if(beacon)
			beacon.set_frequency(nukie.nuke_team.team_frequency)
	return suit

/datum/uplink_item/suits/hardsuit/elite
	name = "Elitarny hardsuit Syndykatu"
	desc = "Ulepszona, elitarna wersja hardsuitu Syndykatu. Jest ognioodporna i daje lepszy pancerz oraz swobodę ruchu niż standardowy hardsuit Syndykatu."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	cost = 8
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/suits/hardsuit/shielded
	name = "Hardsuit Syndykatu z osłoną"
	desc = "Ulepszona wersja standardowego hardsuitu Syndykatu z wbudowanym systemem osłon energetycznych. Osłony wytrzymują do trzech trafień w krótkim czasie i szybko się ładują, gdy nikt do ciebie nie strzela."
	item = /obj/item/clothing/suit/space/hardsuit/shielded/syndi
	cost = 30
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/suits/infiltrator_bundle
	name = "MODsuit infiltratora"
	desc = "Opracowany przez Gildię Aktorów Roseus Galactic wspólnie z Maruderami Gorlexa jako funkcjonalny skafander do operacji miejskich. Jest tańszy od standardowego MODsuitu i nie ma ograniczeń ruchu skafandrów kosmicznych używanych przez firmę. Większa swoboda ma jednak swoją cenę – skafander nie chroni przed próżnią kosmosu. Ma za to fabrycznie zamontowany specjalny moduł maskujący z emiterem psi, przez który nie da się rozpoznać noszącego, a załoga Nanotrasen mocno traci morale."
	item = /obj/item/mod/control/pre_equipped/infiltrator
	cost = 6

/datum/uplink_item/suits/modsuit
	name = "MODsuit Syndykatu"
	desc = "Budzący grozę MODsuit agenta Syndykatu. Ma opancerzenie i zestaw wbudowanych modułów."
	item = /obj/item/mod/control/pre_equipped/traitor
	cost = 7
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS) //you can't buy it in nuke, because the elite modsuit costs the same while being better

/datum/uplink_item/suits/modsuit/elite
	name = "Elitarny MODsuit Syndykatu"
	desc = "Ulepszona, elitarna wersja MODsuitu Syndykatu. Jest ognioodporna i daje lepszy pancerz oraz swobodę ruchu niż standardowy MODsuit Syndykatu."
	item = /obj/item/mod/control/pre_equipped/traitor_elite
	cost = 8
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/suits/emp_shield
	name = "Moduł MODsuitu: zaawansowana osłona EMP"
	desc = "Zaawansowany moduł osłony EMP do MODsuitu. Chroni całe ciało przed impulsami elektromagnetycznymi."
	item = /obj/item/mod/module/emp_shield/advanced
	cost = 5
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/suits/injector
	name = "Moduł MODsuitu: iniektor"
	desc = "Moduł iniektora do MODsuitu. To wysuwany, przebijający iniektor o pojemności 30 j."
	item = /obj/item/mod/module/injector
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/suits/holster
	name = "Moduł MODsuitu: kabura"
	desc = "Moduł kabury do MODsuitu. Po cichu schowasz w nim każdą niezbyt ciężką broń."
	item = /obj/item/mod/module/holster
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/suits/thermal
	name = "Moduł MODsuitu: wizjer termowizyjny"
	desc = "Wizjer do MODsuitu. Pozwala widzieć żywe istoty przez ściany."
	item = /obj/item/mod/module/visor/thermal
	cost = 3

/datum/uplink_item/suits/night
	name = "Moduł MODsuitu: wizjer noktowizyjny"
	desc = "Wizjer do MODsuitu. Pozwala lepiej widzieć w ciemności."
	item = /obj/item/mod/module/visor/night
	cost = 2

/datum/uplink_item/suits/chameleon
	name = "Moduł MODsuitu: kameleon"
	desc = "Moduł MODsuitu, który pozwala skafandrowi udawać inne przedmioty."
	item = /obj/item/mod/module/chameleon
	cost = 2

/datum/uplink_item/suits/plate_compression
	name = "Moduł MODsuitu: kompresja płyt"
	desc = "Moduł MODsuitu, który pozwala ścisnąć skafander do mniejszego rozmiaru. Niezgodny z modułami schowka i MODsuitem infiltratora."
	item = /obj/item/mod/module/plate_compression
	cost = 2

/datum/uplink_item/suits/noslip
	name = "Moduł MODsuitu: antypoślizg"
	desc = "Moduł MODsuitu, który chroni przed poślizgnięciem się na wodzie."
	item = /obj/item/mod/module/noslip
	cost = 2

// Devices and Tools
/datum/uplink_item/device_tools
	category = "Misc. Gadgets"

/datum/uplink_item/device_tools/cutouts
	name = "Adaptacyjne kartonowe sylwetki"
	desc = "Te kartonowe sylwetki pokrywa cienka warstwa materiału, który zapobiega blaknięciu i sprawia, że postacie na nich wyglądają bardziej realistycznie. W paczce są trzy sylwetki i kredka do zmiany ich wyglądu."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/device_tools/assault_pod
	name = "Urządzenie celownicze kapsuły desantowej"
	desc = "Służy do wybrania miejsca lądowania twojej kapsuły desantowej."
	item = /obj/item/assault_pod
	cost = 30
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE

/datum/uplink_item/device_tools/binary
	name = "Klucz tłumacza binarnego"
	desc = "Klucz, który po włożeniu do słuchawek pozwala słuchać krzemowych form życia, takich jak SI i cyborgi, i rozmawiać z nimi na ich prywatnym kanale binarnym. Zachowaj ostrożność, bo jeśli nie są twoimi sojusznikami, mają zaprogramowany obowiązek zgłaszania takich włamań."
	item = /obj/item/encryptionkey/binary
	cost = 4
	surplus = 75
	restricted = TRUE

/datum/uplink_item/device_tools/compressionkit
	name = "Zestaw kompresji bluespace"
	desc = "Zmodyfikowana wersja BSRPED, która zmniejsza rozmiar większości przedmiotów bez utraty ich funkcji! Nie działa na pojemnikach. Ładujesz go kryształami bluespace. Na start ma 5 ładunków."
	item = /obj/item/compressionkit
	cost = 5

/datum/uplink_item/device_tools/shuttlecapsule
	name = "Kapsuła z promem bluespace"
	desc = "Potrzebujesz mobilnej bazy operacyjnej? Te uciążliwe ekipy eksploracyjne ciągle ci odlatują? Chcesz szybko uderzyć w policję i zniknąć? Ten produkt jest dla ciebie! Zupełnie nowa kapsuła z promem bluespace mieści CAŁY prom w kapsule, którą trzymasz w dłoni! Prom to nowoczesny statek wyposażony w zhakowany autolat, skrzynkę narzędziową Syndykatu, karty do gry na długie podróże, wbudowany interdyktor promów i jeden kanister plazmy na twoje przygody! Ten innowacyjny prom mieści do 4 pasażerów, chętnych lub nie! Prom trzeba rozłożyć w kosmosie albo na Lavalandzie, skafandry kosmiczne nie są w zestawie."
	item = /obj/item/survivalcapsule/shuttle/traitor
	cost = 8
	purchasable_from = (UPLINK_INCURSION | UPLINK_TRAITORS)

/datum/uplink_item/device_tools/magboots
	name = "Krwistoczerwone buty magnetyczne"
	desc = "Para butów magnetycznych w barwach Syndykatu, które ułatwiają poruszanie się w kosmosie albo na stacji podczas awarii generatora grawitacji. Te podróbki „zaawansowanych butów magnetycznych” Nanotrasen spowalniają cię w sztucznej grawitacji tak samo jak zwykły model."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 2
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/brainwash_disk
	name = "Program operacji prania mózgu"
	desc = "Dysk z procedurą operacji prania mózgu, która pozwala wszczepić ofierze cel do wykonania. Włóż go do komputera operacyjnego, żeby udostępnić procedurę."
	item = /obj/item/disk/surgery/brainwashing
	cost = 5

/datum/uplink_item/device_tools/brainwash_disk
	name = "Program operacji prania mózgu"
	desc = "Dysk z procedurą operacji prania mózgu, która pozwala wszczepić ofierze cel do wykonania. Włóż go do komputera operacyjnego, żeby udostępnić procedurę."
	item = /obj/item/disk/surgery/brainwashing
	cost = 5

/datum/uplink_item/device_tools/briefcase_launchpad
	name = "Wyrzutnia w teczce"
	desc = "Teczka z wyrzutnią, czyli urządzeniem, które teleportuje przedmioty i ludzi do i z celów oddalonych od teczki o maksymalnie osiem pól. W zestawie jest też pilot udający zwykłą teczkę na dokumenty. Dotknij teczki pilotem, żeby go połączyć."
	surplus = 30
	item = /obj/item/storage/briefcase/launchpad
	cost = 5

/datum/uplink_item/device_tools/camera_bug
	name = "Pluskwa kamerowa"
	desc = "Pozwala podglądać wszystkie kamery w głównej sieci, ustawiać alarmy ruchu i śledzić cel. Założenie pluskwy na kamerę pozwala ją potem zdalnie wyłączyć."
	item = /obj/item/camera_bug
	cost = 1

/datum/uplink_item/device_tools/military_belt
	name = "Kamizelka taktyczna"
	desc = "Solidne oporządzenie z siedmioma miejscami, które pomieści wszelkiego rodzaju sprzęt taktyczny."
	item = /obj/item/storage/belt/military
	cost = 1

/datum/uplink_item/device_tools/emag
	name = "Sekwencer kryptograficzny"
	desc = "Sekwencer kryptograficzny, karta elektromagnetyczna albo po prostu emag to mała karta, która odblokowuje ukryte funkcje urządzeń elektronicznych, wypacza ich przeznaczenie i z łatwością łamie zabezpieczenia."
	item = /obj/item/card/emag
	cost = 6

/datum/uplink_item/device_tools/fakenucleardisk
	name = "Fałszywy dysk nuklearny"
	desc = "To zwykły dysk. Wygląda identycznie jak prawdziwy, ale nie przejdzie dokładniejszej kontroli Kapitana. Nie próbuj dawać go nam, żeby zaliczyć cel – nie damy się nabrać!"
	item = /obj/item/disk/nuclear/fake
	cost = 1
	surplus = 1
	illegal_tech = FALSE

/datum/uplink_item/device_tools/syndicate_teleporter
	name = "Eksperymentalny teleporter Syndykatu"
	desc = "Teleporter Syndykatu to ręczne urządzenie, które teleportuje użytkownika o 4–8 metrów do przodu. Uwaga: teleportacja w ścianę uruchamia równoległą teleportację awaryjną, ale jeśli i ona się nie powiedzie, zginiesz na miejscu. Ma 4 ładunki i sam się doładowuje. Gwarancja traci ważność po wystawieniu na EMP."
	item = /obj/item/storage/box/syndie_kit/teleporter
	cost = 8

/datum/uplink_item/device_tools/frame
	name = "Dysk PDA F.R.A.M.E."
	desc = "Po włożeniu do PDA ten dysk daje ci pięć wirusów PDA, które zamieniają docelowe PDA w nowy uplink z zerem TC i od razu go odblokowują. Kod odblokowania dostajesz po aktywacji wirusa, a nowy uplink można normalnie ładować telekryształami."
	item = /obj/item/computer_hardware/hard_drive/role/virus/frame
	cost = 4
	restricted = TRUE

/datum/uplink_item/device_tools/failsafe
	name = "Awaryjny kod uplinka"
	desc = "Po wpisaniu tego kodu uplink natychmiast ulega samozniszczeniu."
	item = /obj/effect/gibspawner/generic
	cost = 1
	surplus = 0
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/failsafe/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!U)
		return
	U.failsafe_code = U.generate_code()
	var/code = "[islist(U.failsafe_code) ? english_list(U.failsafe_code) : U.failsafe_code]"
	to_chat(user, "<span class='warning'>Nowy kod awaryjny tego uplinka to: [code].</span>")
	if(user.mind)
		user.mind.store_memory("Kod awaryjny dla [U.parent]: [code]")
	return U.parent //For log icon

/datum/uplink_item/device_tools/toolbox
	name = "Pełna skrzynka narzędziowa Syndykatu"
	desc = "Skrzynka narzędziowa Syndykatu w podejrzanych barwach czerni i czerwieni. Zawiera pełny zestaw narzędzi, w tym multitool i rękawice bojowe odporne na prąd i wysoką temperaturę."
	item = /obj/item/storage/toolbox/syndicate
	cost = 1
	illegal_tech = FALSE

/datum/uplink_item/device_tools/syndie_glue
	name = "Klej"
	desc = "Tania buteleczka jednorazowego superkleju marki Syndykatu. Użyj na dowolnym przedmiocie, żeby nie dało się go upuścić. Uważaj, żeby nie przykleić przedmiotu, który już trzymasz!"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/syndie_glue
	cost = 2

/datum/uplink_item/device_tools/hacked_module
	name = "Zhakowany moduł praw SI"
	desc = "Użyty z konsolą wgrywania praw pozwala wgrać sztucznej inteligencji prawa o najwyższym priorytecie. Uważaj na sformułowania, bo sztuczna inteligencja może szukać luk."
	item = /obj/item/aiModule/syndicate
	cost = 3

/datum/uplink_item/device_tools/hypnotic_flash
	name = "Hipnotyczny flash"
	desc = "Zmodyfikowany flash, który hipnotyzuje cele. Jeśli cel nie jest psychicznie podatny, flash tylko na chwilę go zdezorientuje i uspokoi."
	item = /obj/item/assembly/flash/hypnotic
	cost = 7

/datum/uplink_item/device_tools/medgun
	name = "Działo medbeam"
	desc = "Cud inżynierii Syndykatu – działo medbeam, czyli medi-gun, pozwala medykowi utrzymać towarzyszy w walce nawet pod ostrzałem. Nie krzyżuj strumieni!"
	item = /obj/item/gun/medbeam
	cost = 14
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/device_tools/singularity_beacon
	name = "Nadajnik energetyczny"
	desc = "Przykręcone do kabli sieci elektrycznej i aktywowane, to duże urządzenie przyciąga każdą aktywną osobliwość grawitacyjną albo kulę tesli. Nie działa, dopóki silnik jest jeszcze w zabezpieczeniu. Przez swój rozmiar nie da się go nosić. Po zamówieniu dostajesz mały nadajnik, który po aktywacji teleportuje do ciebie ten duży."
	item = /obj/item/sbeacondrop
	cost = 10

/datum/uplink_item/device_tools/powersink
	name = "Pochłaniacz energii"
	desc = "Przykręcone do kabli sieci energetycznej i aktywowane, to duże urządzenie zapala się i nadmiernie obciąża sieć, wywołując blackout na całej stacji. Pochłaniacz jest duży i nie mieści się w większości zwykłych toreb i pudełek. Uwaga: wybucha, jeśli w sieci zgromadzi się dość energii."
	item = /obj/item/powersink
	cost = 10
	player_minimum = 35

/datum/uplink_item/device_tools/stimpack
	name = "Stimpack"
	desc = "Stimpacki, narzędzie wielu wielkich bohaterów, czynią cię niemal odpornym na wszelkie spowolnienie (także od obrażeń) i obrażenia wytrzymałościowe przez około 5 minut od wstrzyknięcia."
	item = /obj/item/reagent_containers/hypospray/medipen/stimulants
	cost = 5
	surplus = 90

/datum/uplink_item/device_tools/medkit
	name = "Apteczka bojowego medyka Syndykatu"
	desc = "Ta apteczka ma podejrzane brązowo-czerwone barwy. W środku jest bojowy iniektor stymulantów do szybkiego leczenia, medyczny HUD z noktowizją do szybkiego rozpoznawania rannych i inne zapasy przydatne medykowi polowemu."
	item = /obj/item/storage/firstaid/tactical
	cost = 4
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/soap
	name = "Mydło Syndykatu"
	desc = "Złowrogo wyglądający środek powierzchniowo czynny do zmywania plam krwi, ukrywania morderstw i utrudniania analizy DNA. Możesz też rzucić je komuś pod nogi, żeby się poślizgnął."
	item = /obj/item/soap/syndie
	cost = 1
	surplus = 50
	illegal_tech = FALSE

/datum/uplink_item/device_tools/surgerybag
	name = "Chirurgiczna torba podróżna Syndykatu"
	desc = "Chirurgiczna torba podróżna Syndykatu to zestaw ze wszystkimi narzędziami chirurgicznymi, serwetą chirurgiczną, MMI marki Syndykatu, kaftanem bezpieczeństwa i kagańcem."
	item = /obj/item/storage/backpack/duffelbag/syndie/surgery
	cost = 3

/datum/uplink_item/device_tools/encryptionkey
	name = "Uniwersalny klucz deszyfrujący"
	desc = "Klucz, który po włożeniu do słuchawek pozwala słuchać wszystkich kanałów działów stacji oraz rozmawiać na szyfrowanym kanale Syndykatu z innymi agentami, którzy mają taki sam klucz."
	item = /obj/item/encryptionkey/hearall
	cost = 2
	surplus = 75
	purchasable_from = ~UPLINK_INCURSION
	restricted = TRUE

/datum/uplink_item/device_tools/syndietome
	name = "Księga Syndykatu"
	desc = "Dzięki rzadkim artefaktom zdobytym wielkim kosztem Syndykat odtworzył pozornie magiczne księgi pewnego kultu. Choć brakuje im ezoterycznych zdolności oryginałów, te gorsze kopie wciąż są bardzo przydatne i na polu bitwy potrafią przynieść zarówno pomyślność, jak i nieszczęście, nawet jeśli od czasu do czasu odgryzą komuś palec."
	item = /obj/item/storage/book/bible/syndicate
	cost = 3

/datum/uplink_item/device_tools/potion
	name = "Mikstura świadomości Syndykatu"
	item = /obj/item/slimepotion/slime/sentience/nuclear
	desc = "Mikstura zdobyta z wielkim ryzykiem przez tajnych agentów Syndykatu, a potem zmodyfikowana technologią Syndykatu. Daje świadomość dowolnemu zwierzęciu i wiąże je służbą tobie, a do tego wszczepia mu wewnętrzne radio do komunikacji i wewnętrzną kartę identyfikacyjną do otwierania drzwi."
	cost = 4
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE

/datum/uplink_item/device_tools/suspiciousphone
	name = "Telefon protokołu CRAB-17"
	desc = "Telefon protokołu CRAB-17, pożyczony od nieznanej strony trzeciej, pozwala wywołać krach na kosmicznym rynku i przelać straty załogi na twoje konto bankowe. Załoga może jednak przenieść środki do nowego banku, chyba że trzyma (HODL) – wtedy sama sobie winna."
	item = /obj/item/suspiciousphone
	restricted = TRUE
	cost = 8

/datum/uplink_item/device_tools/thermal
	name = "Gogle termowizyjne"
	desc = "Te gogle można przerobić tak, by wyglądały jak zwykłe okulary spotykane na stacji. Pozwalają widzieć organizmy przez ściany, wychwytując górną część widma podczerwieni, emitowaną przez obiekty jako ciepło i światło. Cieplejsze obiekty, takie jak ciepłe ciała, organizmy cybernetyczne i rdzenie sztucznej inteligencji, emitują więcej tego światła niż chłodniejsze, takie jak ściany i śluzy."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 3

// Implants
/datum/uplink_item/implants
	category = "Implants"
	surplus = 50

/datum/uplink_item/implants/adrenal
	name = "Implant adrenalinowy"
	desc = "Implant wstrzykiwany do ciała i aktywowany później na życzenie użytkownika. Wstrzykuje chemiczny koktajl, który usuwa wszystkie efekty obezwładniające, pozwala szybciej biegać i lekko leczy."
	item = /obj/item/storage/box/syndie_kit/imp_adrenal
	cost = 8
	player_minimum = 20

/datum/uplink_item/implants/antistun
	name = "Implant restartu OUN"
	desc = "Ten implant pomaga szybciej stanąć na nogi po ogłuszeniu. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/anti_stun
	cost = 12
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/freedom
	name = "Implant wolności"
	desc = "Implant wstrzykiwany do ciała i aktywowany później na życzenie użytkownika. Próbuje uwolnić użytkownika z typowych więzów, takich jak kajdanki."
	item = /obj/item/storage/box/syndie_kit/imp_freedom
	cost = 4

/datum/uplink_item/implants/microbomb
	name = "Implant mikrobomby"
	desc = "Implant wstrzykiwany do ciała, aktywowany później ręcznie albo automatycznie po śmierci. Im więcej takich implantów w tobie, tym silniejszy wybuch. Trwale niszczy jednak twoje ciało."
	item = /obj/item/storage/box/syndie_kit/imp_microbomb
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/macrobomb
	name = "Implant makrobomby"
	desc = "Implant wstrzykiwany do ciała, aktywowany później ręcznie albo automatycznie po śmierci. Po śmierci wywołuje potężną eksplozję, która zmiata wszystko w pobliżu."
	item = /obj/item/storage/box/syndie_kit/imp_macrobomb
	cost = 20
	purchasable_from = UPLINK_NUKE_OPS
	restricted = TRUE

/datum/uplink_item/implants/radio
	name = "Implant wewnętrznego radia Syndykatu"
	desc = "Implant wstrzykiwany do ciała, który pozwala korzystać z wewnętrznego radia Syndykatu. Działa jak zwykłe słuchawki, ale można go wyłączyć, żeby normalnie używać zewnętrznych słuchawek i uniknąć wykrycia."
	item = /obj/item/storage/box/syndie_kit/imp_radio
	cost = 4
	purchasable_from = ~UPLINK_INCURSION //To prevent traitors from immediately outing the hunters to security.
	restricted = TRUE

/datum/uplink_item/implants/reviver
	name = "Implant reanimacyjny"
	desc = "Ten implant próbuje cię ocucić i uleczyć, gdy tracisz przytomność. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/reviver
	cost = 7
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/stealthimplant
	name = "Implant kamuflażu"
	desc = "Ten jedyny w swoim rodzaju implant czyni cię niemal niewidzialnym, jeśli dobrze rozegrasz swoje karty. Po aktywacji ukrywa cię w kartonowym pudle kameleona, które zdradza cię dopiero wtedy, gdy ktoś na nie wpadnie."
	item = /obj/item/storage/box/syndie_kit/imp_stealth
	cost = 7

/datum/uplink_item/implants/storage
	name = "Implant schowka"
	desc = "Implant wstrzykiwany do ciała i aktywowany później na życzenie użytkownika. Otwiera małą kieszeń bluespace, która mieści dwa przedmioty zwykłego rozmiaru."
	item = /obj/item/storage/box/syndie_kit/imp_storage
	cost = 7

/datum/uplink_item/implants/thermals
	name = "Oczy termowizyjne"
	desc = "Te cybernetyczne oczy dają ci widzenie termiczne. W zestawie darmowy autochirurg."
	item = /obj/item/autosurgeon/syndicate/thermal_eyes
	cost = 7
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/uplink
	name = "Implant uplinka"
	desc = "Implant wstrzykiwany do ciała i aktywowany później na życzenie użytkownika. Nie zawiera telekryształów i trzeba go ładować fizycznymi telekryształami. Niewykrywalny (poza operacją), świetny do ucieczki z zamknięcia."
	item = /obj/item/storage/box/syndie_kit // the actual uplink implant is generated later on in spawn_item
	cost = UPLINK_IMPLANT_TELECRYSTAL_COST
	// An empty uplink is kinda useless.
	surplus = 0
	restricted = TRUE

/datum/uplink_item/implants/uplink/spawn_item(spawn_path, mob/user, datum/component/uplink/purchaser_uplink)
	var/obj/item/storage/box/syndie_kit/uplink_box = ..()
	uplink_box.name = "pudełko z implantem uplinka"
	new /obj/item/implanter/uplink(uplink_box, purchaser_uplink.uplink_flag)
	return uplink_box


/datum/uplink_item/implants/xray
	name = "Implant wzroku rentgenowskiego"
	desc = "Te cybernetyczne oczy dają ci wzrok rentgenowski. W zestawie autochirurg."
	item = /obj/item/autosurgeon/syndicate/xray_eyes
	cost = 9
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS


//Race-specific items
/datum/uplink_item/race_restricted
	category = "Species-Restricted"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	surplus = 0

/datum/uplink_item/race_restricted/syndilamp
	name = "Superjasna latarenka"
	desc = "Słyszeliśmy, że ćmy takie jak ty bardzo lubią lampy, więc postanowiliśmy dać ci wczesny dostęp do prototypu „Superjasnej latarenki™” marki Syndykatu. Miłego użytkowania."
	cost = 2
	item = /obj/item/flashlight/lantern/syndicate
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/race_restricted/ethereal_grenade
	name = "Granat tańca eteryków"
	desc = "Naukowcy Syndykatu sprytnie upchnęli ciała kilku eteryków w specjalnej paczce! Po aktywacji każdy w pobliżu zaczyna tańczyć, z wyjątkiem eteryków, którzy mogą się po prostu obrazić."
	cost = 4
	item = /obj/item/grenade/discogrenade
	restricted_species = list(SPECIES_ETHEREAL)

/datum/uplink_item/race_restricted/plasmachameleon
	name = "Zestaw kameleona dla plazmamanów"
	desc = "Zestaw przedmiotów z technologią kameleona, które pozwalają ci przebrać się za praktycznie wszystko na stacji, i nie tylko! Przez cięcia budżetowe buty nie chronią przed poślizgnięciem. Zwykłe bajery kombinezonu i hełmu plazmamana wycięto, żeby zrobić miejsce na mechanizm kameleona."
	item = /obj/item/storage/box/syndie_kit/plasmachameleon
	cost = 2
	restricted_species = list(SPECIES_PLASMAMAN)

/datum/uplink_item/race_restricted/tribal_claw
	name = "Stary zwój plemienny"
	desc = "Znaleźliśmy ten zwój w opuszczonej osadzie jaszczurów z klanu Knoises. Uczy, jak dzięki pazurom i ogonowi zdobyć przewagę w walce. Nie kupuj go, jeśli nie jesteś jaszczurem albo nie chcesz go żadnemu dać, bo tylko jaszczury rozumieją dawne smocze słowa."
	item = /obj/item/book/granter/martial/tribal_claw
	cost = 14
	surplus = 0
	restricted_species = list(SPECIES_LIZARD)

/datum/uplink_item/race_restricted/tribal_claw
	name = "Stary zwój plemienny"
	desc = "Znaleźliśmy ten zwój w opuszczonej osadzie jaszczurów z klanu Knoises. Uczy, jak dzięki pazurom i ogonowi zdobyć przewagę w walce. Nie kupuj go, jeśli nie jesteś jaszczurem albo nie chcesz go żadnemu dać, bo tylko jaszczury rozumieją dawne smocze słowa."
	item = /obj/item/book/granter/martial/tribal_claw
	cost = 14
	surplus = 0
	restricted_species = list("lizard")

// Role-specific items
/datum/uplink_item/role_restricted
	category = "Role-Restricted"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	surplus = 0

/datum/uplink_item/role_restricted/ancient_jumpsuit
	name = "Starożytny kombinezon"
	desc = "Podarty, stary kombinezon, który nie da ci absolutnie żadnej korzyści. Noszący go czuje dziwny przymus wykrzykiwania „glorf”."
	item = /obj/item/clothing/under/color/grey/glorf
	cost = 20
	restricted_roles = list(JOB_NAME_ASSISTANT)
	surplus = 1

/datum/uplink_item/role_restricted/oldtoolboxclean
	name = "Starożytna skrzynka narzędziowa"
	desc = "Kultowy wzór skrzynki narzędziowej, z którego słyną asystenci na całym świecie. Ten egzemplarz zaprojektowano tak, by był tym mocniejszy, im więcej telekryształów ma w środku! Narzędzia i izolowane rękawice w zestawie."
	item = /obj/item/storage/toolbox/mechanical/old/clean
	cost = 2
	restricted_roles = list(JOB_NAME_ASSISTANT)
	surplus = 0

/datum/uplink_item/role_restricted/pie_cannon
	name = "Działo na torty bananowe z kremem"
	desc = "Specjalne działo na torty dla specjalnego klauna. Mieści do 20 tortów i co dwie sekundy samo wytwarza nowy!"
	cost = 11
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	restricted_roles = list(JOB_NAME_CLOWN)
	surplus = 0 //No fun unless you're the clown!

/datum/uplink_item/role_restricted/blastcannon
	name = "Działo podmuchowe"
	desc = "Działo podmuchowe to wysoce wyspecjalizowana broń, choć w rzeczywistości dość prosta. Ma mocowanie na zawór przelewowy zbiorników, osadzone na zakrzywionej rurze specjalnie skonstruowanej, by wytrzymać ekstremalne ciśnienie i temperaturę, oraz mechaniczny spust, który uruchamia zawór. W praktyce zamienia siłę wybuchu bomby w wąską falę uderzeniową – „pocisk”. Ambitni naukowcy mogą uznać je za niezwykle przydatne, bo skupienie fali ciśnienia w wąskim kącie najwyraźniej omija dziwactwo fizyki, które nie pozwala wybuchom przekroczyć pewnego zasięgu. Dzięki temu urządzenie wykorzystuje teoretyczną moc bomby z zaworem przelewowym zamiast rzeczywistej."
	item = /obj/item/gun/blastcannon
	cost = 14							//High cost because of the potential for extreme damage in the hands of a skilled scientist.
	restricted_roles = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST)

/datum/uplink_item/role_restricted/crushmagboots
	name = "Miażdżące buty magnetyczne"
	desc = "Para wzmocnionych butów magnetycznych, które miażdżą każdego, po kim przejdziesz."
	cost = 7
	item = /obj/item/clothing/shoes/magboots/crushing
	restricted_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

/datum/uplink_item/role_restricted/gorillacubes
	name = "Pudełko gorylich kostek"
	desc = "Pudełko z trzema gorylimi kostkami marki Waffle Co. Jedz dużo, żeby urosnąć. Uwaga: produkt może się nawodnić w kontakcie z wodą."
	item = /obj/item/storage/box/gorillacubes
	cost = 6
	restricted_roles = list(JOB_NAME_GENETICIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/rad_laser
	name = "Radioaktywny mikrolaser"
	desc = "Radioaktywny mikrolaser ukryty w standardowym analizatorze zdrowia Nanotrasen. Po użyciu emituje silny impuls promieniowania, który po krótkiej chwili potrafi obezwładnić każdego humanoida poza najlepiej chronionymi. Ma dwa ustawienia: intensywność, która decyduje o sile promieniowania, i długość fali, która decyduje o opóźnieniu efektu."
	item = /obj/item/healthanalyzer/rad_laser
	restricted_roles = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_ROBOTICIST, JOB_NAME_PARAMEDIC, JOB_NAME_BRIGPHYSICIAN)
	cost = 3

/datum/uplink_item/role_restricted/syndicate_mmi
	name = "MMI Syndykatu"
	desc = "MMI, które automatycznie nadaje prawa Syndimov każdemu borgowi, w którym się znajdzie. Świetne, gdy chcesz mieć do pomocy znanych sojuszników i zachować przy tym więcej dyskrecji niż z w pełni zemagowanym borgiem."
	item = /obj/item/mmi/syndie
	restricted_roles = list(JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)
	cost = 2

/datum/uplink_item/role_restricted/upgrade_wand
	name = "Różdżka ulepszająca"
	desc = "Potężna jednorazowa różdżka z nanomaszynami, które kalibrują zaawansowane gadżety magików i niemal podwajają ich możliwości."
	item = /obj/item/upgradewand
	restricted_roles = list(JOB_NAME_STAGEMAGICIAN)
	cost = 5

/datum/uplink_item/role_restricted/floorpill_bottle
	name = "Pojemnik tajemniczych pigułek"
	desc = "Znaleźliśmy je w Magazynie R1O-GN, który wycofano z użytku wiele lat temu. Chcieliśmy je wyrzucić, ale słyszeliśmy, że mogą cię zainteresować."
	item = /obj/item/storage/pill_bottle/floorpill/full
	restricted_roles = list(JOB_NAME_ASSISTANT)
	cost = 2

/datum/uplink_item/role_restricted/clown_bomb
	name = "Bomba klauna"
	desc = "Bomba klauna to przezabawne urządzenie do potężnych psikusów. Ma regulowany zapalnik czasowy z minimum 60 sekund i można ją przykręcić kluczem do podłogi, żeby nikt jej nie przesunął. Bomba jest masywna i nie da się jej przenieść. Po zamówieniu dostajesz mniejszy nadajnik, który po aktywacji teleportuje do siebie właściwą bombę. Pamiętaj, że bombę da się rozbroić i część załogi może tego spróbować."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 10
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/clown_grenade
	name = "C.L.U.W.N.E"
	desc = "C.L.U.W.N.E tworzy zupełnie losowe dziecię Honkmatki! Atakuje tylko wtedy, gdy samo zostanie zaatakowane, i nie jest ci wierne, więc uważaj!"
	item = /obj/item/grenade/spawnergrenade/clown
	cost = 3
	restricted_roles = list(JOB_NAME_CLOWN)


/datum/uplink_item/role_restricted/clown_grenade_broken
	name = "Nadziany C.L.U.W.N.E"
	desc = "C.L.U.W.N.E tworzy zupełnie losowe dziecię Honkmatki! Atakuje tylko wtedy, gdy samo zostanie zaatakowane, i nie jest ci wierne, więc uważaj! Ten egzemplarz jest wypchany po brzegi dodatkową klaunową akcją! Używaj ostrożnie!"
	item = /obj/item/grenade/spawnergrenade/clown_broken
	cost = 5
	restricted_roles = list(JOB_NAME_CLOWN)


/datum/uplink_item/role_restricted/spider_injector
	name = "Mutator szlamu z Australicusa"
	desc = "Kurde, kolego, podróż z sektora Australicus była szalona, ale udało nam się zdobyć specjalny wyciąg pajęczy z tamtejszych olbrzymich pająków. Użyj tego iniektora na złotym rdzeniu szlamu, żeby stworzyć kilka pająków takiego typu, jaki znaleźliśmy na tamtejszych planetach. Są dość potulne, dopóki nie dasz im też odrobiny świadomości."
	item = /obj/item/reagent_containers/syringe/spider_extract
	cost = 10
	restricted_roles = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST)

/datum/uplink_item/role_restricted/clowncar
	name = "Klaunowóz"
	desc = "Klaunowóz to ostateczny środek transportu dla każdego godnego klauna! Po prostu włóż trąbkę, wsiądź i szykuj się na najzabawniejszą jazdę w życiu! Możesz taranować napotkanych kosmonautów i upychać ich w aucie, porywając ich i zamykając w środku, dopóki ktoś ich nie uratuje albo sami się nie wyczołgają. Nie wjeżdżaj w ściany ani w automaty, bo sprężynowe siedzenia są bardzo czułe. Teraz z mechanizmem obrony lubrykantem, który ochroni cię przed każdą wściekłą psiarnią! Funkcje premium odblokujesz sekwencerem kryptograficznym!"
	item = /obj/vehicle/sealed/car/clowncar
	cost = 20
	restricted_roles = list(JOB_NAME_CLOWN)
	purchasable_from = ~UPLINK_INCURSION

/datum/uplink_item/role_restricted/taeclowndo_shoes
	name = "Buty tae-klaun-do"
	desc = "Buty dla najbardziej elitarnych agentów z ojczyzny Honkmatki. Dopóki je nosisz, dają ci mistrzostwo w tae-klaun-do z kilkoma ruchami honk-fu."
	cost = 12
	item = /obj/item/clothing/shoes/clown_shoes/taeclowndo
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/superior_honkrender
	name = "Wyższy rozdzieracz honku"
	desc = "Starożytny artefakt wydobyty ze starożytnej jaskini. Otwiera drogę do Mrocznego Karnawału."
	item = /obj/item/veilrender/honkrender
	cost = 8
	restricted = TRUE
	restricted_roles = list(JOB_NAME_CLOWN, JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/superior_honkrender
	name = "Wyższy rozdzieracz honku"
	desc = "Starożytny artefakt wydobyty z -. Otwiera drogę do TRANSMISJA PRZERWANA. Chwała Honkmatce."
	item = /obj/item/veilrender/honkrender/honkhulkrender
	cost = 20
	restricted = TRUE
	restricted_roles = list(JOB_NAME_CLOWN, JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/concealed_weapon_bay
	name = "Ukryta komora na broń"
	desc = "Modyfikacja dla niebojowych mechów, która pozwala zamontować jeden element wyposażenia przeznaczony dla mechów bojowych. Ukrywa też zamontowaną broń przed wzrokiem. Na mecha mieści się tylko jedna."
	item = /obj/item/mecha_parts/concealed_weapon_bay
	cost = 3
	restricted_roles = list(JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)

/datum/uplink_item/role_restricted/haunted_magic_eightball
	name = "Nawiedzona magiczna kula ósemka"
	desc = "Większość magicznych kul ósemek to zabawki z kostką w środku. Choć wygląda identycznie jak niewinna zabawka, to okultystyczne urządzenie sięga po odpowiedzi do świata duchów. Uważaj, bo duchy bywają kapryśne albo są po prostu małymi dupkami. Żeby jej użyć, zadaj pytanie na głos i zacznij potrząsać."
	item = /obj/item/toy/eightball/haunted
	cost = 2
	restricted_roles = list(JOB_NAME_CURATOR)
	limited_stock = 1 //please don't spam deadchat

/datum/uplink_item/role_restricted/voodoo
	name = "Wiklinowa lalka"
	desc = "Wiklinowa lalka voodoo ze schowkiem na mały przedmiot. Gdy schowasz w niej przedmiot, lalką można sterować działaniami innej osoby, która wcześniej miała z tym przedmiotem kontakt."
	item = /obj/item/voodoo
	cost = 12
	restricted_roles = list(JOB_NAME_CURATOR, JOB_NAME_STAGEMAGICIAN)

/datum/uplink_item/role_restricted/prison_cube
	name = "Kostka więzienna"
	desc = "Bardzo dziwny artefakt z wulkanicznej planety, przydatny do trzymania ludzi pod kluczem, ale niezbyt przydatny do ukrywania ich zniknięcia."
	item = /obj/item/prisoncube
	cost = 6
	restricted_roles = list(JOB_NAME_CURATOR)

/datum/uplink_item/role_restricted/his_grace
	name = "Jego Łaska"
	desc = "Niezwykle niebezpieczna broń odzyskana ze stacji opanowanej przez szary przypływ. Po aktywacji On łaknie krwi i trzeba Nim zabijać, by zaspokoić to pragnienie. Jego Łaska daje stopniową regenerację i pełną odporność na ogłuszenie temu, kto Go dzierży, ale uważaj: jeśli zbytnio zgłodnieje, nie da się Go upuścić, a jeśli Go nie nakarmisz, w końcu cię zabije. Jeśli jednak zostawisz Go w spokoju wystarczająco długo, znów zapadnie w sen. Żeby aktywować Jego Łaskę, po prostu Go odepnij."
	item = /obj/item/his_grace
	cost = 20
	restricted_roles = list(JOB_NAME_CHAPLAIN)
	murderbone_type = TRUE
	surplus = 0

/datum/uplink_item/role_restricted/cultconstructkit
	name = "Zestaw konstruktów kultu"
	desc = "W opuszczonej kryjówce kultu Nar'Sie znaleziono dwie skorupy konstruktów i zapas pustych kamieni dusz. Oczyściliśmy je, żeby zapobiec skażeniu okultystycznemu, i włożyliśmy do pasa, żeby służyły jako łatwo dostępne źródło jednorazowych sług. Skorupy konstruktów zapakowano w dwa nadajniki do szybkiego rozmieszczenia w dowolnym miejscu."
	item = /obj/item/storage/box/syndie_kit/cultconstructkit
	cost = 20
	restricted_roles = list(JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/spanish_flu
	name = "Kultura hiszpanki"
	desc = "Butelka przeklętej krwi, pełnej gniewnych duchów, które spalą wszystkich heretyków ogniem piekielnym. Przynajmniej tak głosi etykieta."
	item = /obj/item/reagent_containers/glass/bottle/fluspanish
	cost = 14
	restricted_roles = list(JOB_NAME_CHAPLAIN, JOB_NAME_VIROLOGIST)

/datum/uplink_item/role_restricted/retrovirus
	name = "Butelka z kulturą retrowirusa"
	desc = "Butelka zaraźliwych robali DNA, które ręcznie przestawiają DNA nosicieli. Przynajmniej tak głosi etykieta."
	item = /obj/item/reagent_containers/glass/bottle/retrovirus
	cost = 14
	restricted_roles = list(JOB_NAME_VIROLOGIST, JOB_NAME_GENETICIST)

/datum/uplink_item/role_restricted/random_disease
	name = "Eksperymentalna choroba"
	desc = "Losowa choroba. Może trafi ci się kolejna dziewiątego poziomu."
	item = /obj/item/reagent_containers/glass/bottle/random_virus
	cost = 5
	restricted_roles = list(JOB_NAME_VIROLOGIST)
	surplus = 20

/datum/uplink_item/role_restricted/anxiety
	name = "Butelka z kulturą lęku"
	desc = "Butelka czystego, zaraźliwego autyzmu. Przynajmniej tak głosi etykieta."
	item = /obj/item/reagent_containers/glass/bottle/anxiety
	cost = 4
	restricted_roles = list(JOB_NAME_VIROLOGIST)

/datum/uplink_item/role_restricted/explosive_hot_potato
	name = "Wybuchowy gorący ziemniak"
	desc = "Ziemniak naszpikowany materiałami wybuchowymi. Po aktywacji włącza się specjalny mechanizm, który nie pozwala go upuścić. Jeśli go trzymasz, jedyny sposób, żeby się go pozbyć, to zaatakować nim kogoś innego – wtedy przyczepia się do tej osoby."
	item = /obj/item/hot_potato/syndicate
	cost = 3
	surplus = 0
	restricted_roles = list(JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_CLOWN, JOB_NAME_MIME)

/datum/uplink_item/role_restricted/echainsaw
	name = "Energetyczna piła łańcuchowa"
	desc = "Niezwykle zabójcza, zmodyfikowana piła łańcuchowa z energetycznymi ostrzami na bazie plazmy zamiast metalowych i z eleganckim czarno-czerwonym wykończeniem. Choć rozrywa materię z ogromną skutecznością, jest ciężka, duża i potwornie głośna."
	item = /obj/item/chainsaw/energy
	cost = 10
	player_minimum = 25
	restricted_roles = list(JOB_NAME_BOTANIST, JOB_NAME_COOK, JOB_NAME_BARTENDER)

/datum/uplink_item/role_restricted/holocarp
	name = "Holokarpie parazyty"
	desc = "Paluszki rybne przyrządzone rytualnie na cześć boga Karp-sie. Potrafią związać z nosicielem holokarpia, który mu służy i go strzeże."
	item = /obj/item/guardiancreator/carp
	cost = 18
	surplus = 5
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	player_minimum = 25
	restricted = TRUE
	restricted_roles = list(JOB_NAME_COOK, JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/ez_clean_bundle
	name = "Zestaw granatów EZ Clean"
	desc = "Pudełko z trzema granatami czyszczącymi według firmowej receptury Waffle Co. Czyszczą i zadają obrażenia od kwasu każdemu w pobliżu. Kwas działa tylko na istoty węglowe."
	item = /obj/item/storage/box/syndie_kit/ez_clean
	cost = 6
	surplus = 20
	restricted_roles = list(JOB_NAME_JANITOR)

/datum/uplink_item/role_restricted/mimery
	name = "Seria poradników zaawansowanej sztuki mima"
	desc = "Klasyczna dwuczęściowa seria o doskonaleniu umiejętności mima. Po jej przestudiowaniu potrafisz stawiać niewidzialne ściany 3x1 i strzelać pociskami z palców. Oczywiście działa tylko na mimów."
	cost = 11
	item = /obj/item/storage/box/syndie_kit/mimery
	restricted_roles = list(JOB_NAME_MIME)
	surplus = 0

/datum/uplink_item/role_restricted/mimesabrekit
	name = "Zestaw ostrza w bagietce"
	desc = "Bardzo dyskretne ostrze ukryte w jeszcze dyskretniejszej pochwie w kształcie bagietki."
	cost = 	12
	item = /obj/item/storage/box/syndie_kit/mimesabrekit
	restricted_roles = list(JOB_NAME_MIME)
	surplus = 5

/datum/uplink_item/role_restricted/pressure_mod
	name = "Moduł ciśnieniowy kinetycznego akceleratora"
	desc = "Zestaw modyfikacyjny, dzięki któremu kinetyczne akceleratory zadają w pomieszczeniach znacznie większe obrażenia. Zajmuje 35% pojemności modułów." //NSV13 removed mention of damage reduction for shooting in a vacuum
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 5 //you need two for full damage, so total of 10 for maximum damage
	limited_stock = 2 //you can't use more than two!
	restricted_roles = list(JOB_NAME_SHAFTMINER)

/datum/uplink_item/role_restricted/esaw
	name = "Piła energetyczna"
	desc = "Zabójcza piła energetyczna w eleganckim czarnym wykończeniu."
	cost = 5
	item = /obj/item/melee/transforming/energy/sword/esaw
	restricted_roles = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_PARAMEDIC, JOB_NAME_BRIGPHYSICIAN)

/datum/uplink_item/role_restricted/esaw_arm
	name = "Implant piły energetycznej w ramieniu"
	desc = "Implant, który umieszcza w twoim ramieniu zabójczą piłę energetyczną. W zestawie autochirurg Syndykatu do natychmiastowego samodzielnego wszczepienia."
	cost = 8
	item = /obj/item/autosurgeon/syndicate/esaw_arm
	restricted_roles = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_PARAMEDIC, JOB_NAME_BRIGPHYSICIAN)

/datum/uplink_item/role_restricted/magillitis_serum
	name = "Autoinjektor z serum Magillitis"
	desc = "Jednorazowy autoinjektor z eksperymentalnym serum, które wywołuje u człowiekowatych gwałtowny wzrost mięśni. Skutki uboczne mogą obejmować nadmierne owłosienie, wybuchy agresji i niekończące się upodobanie do bananów."
	item = /obj/item/reagent_containers/hypospray/medipen/magillitis
	cost = 15
	restricted_roles = list(JOB_NAME_GENETICIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/modified_syringe_gun
	name = "Zmodyfikowana wyrzutnia strzykawek"
	desc = "Wyrzutnia strzykawek, która zamiast zwykłych strzykawek wystrzeliwuje iniektory DNA."
	item = /obj/item/gun/syringe/dna
	cost = 14
	restricted_roles = list(JOB_NAME_GENETICIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/chemical_gun
	name = "Wyrzutnia strzałek z reagentami"
	desc = "Mocno zmodyfikowana wyrzutnia strzykawek, która sama syntetyzuje strzałki chemiczne z dostarczonych reagentów. Mieści 100 j. reagentów."
	item = /obj/item/gun/chem
	cost = 12
	restricted_roles = list(JOB_NAME_CHEMIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/reverse_bear_trap
	name = "Odwrócone wnyki"
	desc = "Pomysłowe urządzenie egzekucyjne zakładane na głowę (albo wciskane na nią siłą). Uzbrojenie uruchamia minutowy minutnik kuchenny przymocowany do wnyków. Gdy czas minie, szczęki pułapki gwałtownie się otwierają i zabijają noszącego na miejscu, rozrywając mu szczękę na pół. Żeby je uzbroić, zaatakuj nimi kogoś bez nakrycia głowy – po trzech sekundach bez przerwy wciśniesz mu je na głowę."
	cost = 4
	item = /obj/item/reverse_bear_trap
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/reverse_revolver
	name = "Odwrócony rewolwer"
	desc = "Rewolwer, który zawsze strzela w swojego użytkownika. „Przypadkiem” upuść broń, a potem patrz, jak chciwe korporacyjne świnie rozbryzgują sobie mózgi po ścianie. Sam rewolwer jest prawdziwy. Normalnie strzelać z niego mogą tylko niezdary i klauni. Dostarczany w pudełku uścisków. Honk."
	cost = 13
	item = /obj/item/storage/box/hug/reverse_revolver
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/laser_arm
	name = "Implant lasera w ramieniu"
	desc = "Implant, który umieszcza w twoim ramieniu samoładującą się broń laserową. Wrażliwy na EMP. W zestawie autochirurg Syndykatu do natychmiastowego samodzielnego wszczepienia."
	cost = 12
	item = /obj/item/autosurgeon/syndicate/laser_arm
	restricted_roles = list(JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)

/datum/uplink_item/role_restricted/plasma_control_rod  //NSV13
	name = "Plazmowy pręt sterujący reaktora w osłonie z nanowęgla"
	desc = "Pręt sterujący z rdzeniem plazmowym, przeznaczony do sabotowania reaktorów napędu burzowego."
	cost = 10
	item = /obj/item/control_rod/plasma
	restricted_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

// Pointless
/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	surplus = 0


/datum/uplink_item/badass/costumes
	surplus = 0
	cost = 4
	cant_discount = TRUE
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/badass/costumes/obvious_chameleon
	name = "Zepsuty zestaw kameleona"
	desc = "Zestaw przedmiotów z technologią kameleona, które pozwalają ci przebrać się za praktycznie wszystko na stacji, i nie tylko! Pamiętaj, że ten zestaw NIE przeszedł kontroli jakości."
	item = /obj/item/storage/box/syndie_kit/chameleon/broken
	cost = 2
	purchasable_from = ALL

/datum/uplink_item/badass/costumes/centcom_official
	name = "Kostium przedstawiciela Centrali"
	desc = "Poproś załogę o „inspekcję” dysku nuklearnego i systemów uzbrojenia, a gdy odmówią, wyciągnij w pełni automatyczny karabin i zastrzel Kapitana. Słuchawki nie mają klucza szyfrującego. Broń nie jest w zestawie."
	item = /obj/item/storage/box/syndie_kit/centcom_costume

/datum/uplink_item/badass/costumes/clown
	name = "Kostium klauna"
	desc = "Nie ma nic straszniejszego niż klauni z w pełni automatyczną bronią."
	item = /obj/item/storage/backpack/duffelbag/clown/syndie

/datum/uplink_item/badass/balloon
	name = "Balon Syndykatu"
	desc = "Żeby pokazać, że to TY JESTEŚ SZEFEM: bezużyteczny czerwony balon z logo Syndykatu. Potrafi zdemaskować nawet najgłębszą przykrywkę."
	item = /obj/item/toy/syndicateballoon
	cost = 20
	cant_discount = TRUE
	illegal_tech = FALSE
	surplus = 0

/datum/uplink_item/badass/syndiebeer
	name = "Piwo Syndykatu"
	desc = "„Piwo” marki Syndykatu, które wypłukuje toksyny z organizmu. Uwaga: nie pij więcej niż jednego!"
	item = /obj/item/reagent_containers/food/drinks/syndicatebeer
	cost = 4
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiecash
	name = "Aktówka Syndykatu pełna gotówki"
	desc = "Zabezpieczona aktówka z 5000 kosmicznych kredytów. Przydaje się do przekupywania personelu albo kupowania towarów i usług po atrakcyjnych cenach. Aktówka jest też trochę cięższa – zaprojektowano ją tak, żeby mocniej uderzała, gdyby twój klient potrzebował przekonania."
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 1
	restricted = TRUE
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiecards
	name = "Karty do gry Syndykatu"
	desc = "Specjalna talia kosmicznych kart do gry z monomolekularną krawędzią i metalowym wzmocnieniem, przez co są nieco groźniejsze od zwykłej talii. Możesz też w nie grać albo zostawiać je na swoich ofiarach."
	item = /obj/item/toy/cards/deck/syndicate
	cost = 1
	surplus = 40
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiecigs
	name = "Papierosy Syndykatu"
	desc = "Mocny smak, gęsty dym, nasycone omnizyną."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2
	illegal_tech = FALSE

/datum/uplink_item/stealthy_tools/babelfish //NSV13
	 name = "Ryba babel"
	 desc = "Włóż ją do ucha, żeby rozumieć wszystkie języki."
	 item = /obj/item/clothing/ears/babelfish
	 cost = 3

/datum/uplink_item/badass/toy_box
	name = "Pudełko zabawek DonkCo."
	desc = "Specjalne pudełko pełne zabawek DonkCo. dla dzieci, które chcą dostać od rodziców wspaniałe prezenty. Zabawki w pudełku są całkowicie bezpieczne i nieszkodliwe, zatwierdzone nawet przez dział bezpieczeństwa Nanotrasen – można je dosłownie nazwać towarem legalnym. Ta paczka będzie wyjątkowa, gdy zechcesz podarować zabawne zabawki ukochanemu dziecku. Nie pytaj, czemu pudełko jest czerwone."
	item = /obj/item/storage/box/syndie_kit/toy_box
	cost = 2
	surplus = 0

/datum/uplink_item/implants/deathrattle
	name = "Pudełko implantów pośmiertnych"
	desc = "Zestaw implantów (i jeden implanter wielokrotnego użytku) do wszczepienia drużynie. Gdy ktoś z drużyny zginie, wszyscy pozostali nosiciele implantu dostają wiadomość mentalną z imieniem towarzysza i miejscem jego śmierci. W przeciwieństwie do większości implantów te zaprojektowano tak, by dało się je wszczepić każdej istocie, biologicznej lub mechanicznej."
	item = /obj/item/storage/box/syndie_kit/imp_deathrattle
	cost = 4
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/device_tools/antag_lasso
	name = "Lasso zniewolenia"
	desc = "Nowoczesne urządzenie do oswajania.\n Złap prawie dowolne zwierzę na lasso, a potem je odwiąż, żeby je oswoić.\n Oswojone zwierzęta można dosiadać i wydawać im rozkazy!"
	item = /obj/item/mob_lasso/antag
	cost = 3
	surplus = 0
