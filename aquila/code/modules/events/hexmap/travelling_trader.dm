// AQUILA - Wędrowny handlarz: z kłębu dymu wychodzi postać z innego wymiaru, prosi o jedną rzecz i płaci temu, kto ją przyniesie w ciągu 15 minut, a potem znika (port z BlueMoon-Labs/BlueMoon-Station code/modules/events/travelling_trader.dm)
// BlueMoon has six traders (chef, gardener, bartender, animal specialist, artifact dealer, surgeon) whose rewards
// include bomb cherries, gatfruit seeds, neurotoxin kegs, hostile animals, an infinite pizza box and thermal or arm
// implants. Ours keeps the chef, gardener, bartender and collector (no animal or organ trade) and pays with a credit
// holochip plus, sometimes, one harmless item of the trade. The chef asks for a common dish from a short list (not any
// recipe, some need lavaland parts), the gardener for plants the botanists can grow, the bartender for a mixed drink
// made only from dispenser drinks, and the collector for nothing the old Vendotron sells. The trader stands on a free
// safe turf of a safe room, away from doors (event spawn landmarks first), cannot be swapped with or stripped, leaves
// by himself after 15 minutes even when the event is gone, talks without sleeping, and his speech is written anew in Polish.

/datum/round_event_control/aquila_hex_travelling_trader
	name = "Wędrowny handlarz"
	typepath = /datum/round_event/aquila_hex_travelling_trader
	weight = 10
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_travelling_trader
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	endWhen = 450 // 15 minut przy ticku co 2 sekundy
	/// Handlarz, póki stoi na statku
	var/mob/living/carbon/human/dummy/aquila_hex_trader/trader
	/// Pomieszczenie, w którym się pojawił
	var/trader_area_name

/datum/round_event/aquila_hex_travelling_trader/start()
	var/turf/spot = find_spot()
	if(!spot)
		log_game("Travelling Trader: no free safe turf away from doors, cancelling the event.")
		return kill()
	spawn_trader(spot, pick(subtypesof(/mob/living/carbon/human/dummy/aquila_hex_trader)))
	trader_area_name = get_area_name(spot, TRUE)
	announce_to_ghosts(trader)
	log_game("Travelling Trader: [trader.type] appeared at [AREACOORD(spot)], wants [trader.requested_name()].")

/datum/round_event/aquila_hex_travelling_trader/announce(fake)
	if(!trader_area_name)
		return
	priority_announce("Kamery zarejestrowały tajemniczą postać, która wyszła z kłębu dymu w: [trader_area_name]. Postać nie figuruje w rejestrze załogi i wygląda na kogoś, kto chce zrobić interes. Dział Bezpieczeństwa prosi o zachowanie spokoju i nieprzyjmowanie podejrzanych umów.", "Tajemnicza postać")

/// Punkt pojawiania się eventów, a gdy żaden nie jest wolny, wolne pole w bezpiecznym pomieszczeniu z dala od drzwi
/datum/round_event/aquila_hex_travelling_trader/proc/find_spot()
	var/list/spawns = list()
	for(var/obj/effect/landmark/event_spawn/landmark in GLOB.generic_event_spawns)
		var/turf/T = get_turf(landmark)
		if(T && is_station_level(T.z) && aquila_hex_dense_spot_ok(T))
			spawns += T
	if(length(spawns))
		return pick(spawns)
	var/list/room = aquila_hex_room_turfs(1, TRUE)
	return length(room) ? room[1] : null

/// Stawia handlarza danego rodzaju na polu spot, w dymie
/datum/round_event/aquila_hex_travelling_trader/proc/spawn_trader(turf/spot, trader_type)
	trader = new trader_type(spot)
	RegisterSignal(trader, COMSIG_PARENT_QDELETING, PROC_REF(on_trader_deleted))
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, spot)
	smoke.start()
	trader.visible_message("<b>[trader]</b> nagle wyłania się z kłębu dymu!")
	return trader

/datum/round_event/aquila_hex_travelling_trader/proc/on_trader_deleted(datum/source)
	SIGNAL_HANDLER
	trader = null

/datum/round_event/aquila_hex_travelling_trader/end()
	if(QDELETED(trader))
		return
	trader.lose_patience()
	trader = null

/datum/round_event/aquila_hex_travelling_trader/Destroy()
	if(trader)
		UnregisterSignal(trader, COMSIG_PARENT_QDELETING)
		trader = null
	return ..()

/**
 * Handlarz z innego wymiaru: nieśmiertelny, nie da się go przesunąć ani rozebrać. Przy dotknięciu mówi, czego chce;
 * kto poda mu tę rzecz, dostaje nagrodę, a handlarz znika.
 */
/mob/living/carbon/human/dummy/aquila_hex_trader
	status_flags = GODMODE
	move_resist = MOVE_FORCE_VERY_STRONG
	mob_size = MOB_SIZE_LARGE
	alpha = 200
	/// Imię nad głową
	var/trader_name = "Tajemniczy handlarz"
	var/datum/outfit/trader_outfit
	/// Typ żądanej rzeczy (przedmiot albo odczynnik)
	var/requested_item
	/// Pierwsza kwestia
	var/greeting = "Witaj."
	/// Kwestia po otrzymaniu rzeczy
	var/thanks_speech = "Dziękuję. Czas na mnie."
	/// Kwestia, gdy ktoś poda coś innego
	var/refusal_speech = "To nie to, czego szukam."
	/// Nagroda w kredytach (od, do)
	var/reward_min = 300
	var/reward_max = 700
	/// Przedmioty, z których jeden czasem dochodzi do nagrody (typ => waga)
	var/list/reward_items = list()
	/// Handlarz jeszcze czeka na rzecz
	var/active = TRUE
	/// Po jakim czasie handlarz sam znika (także gdy event już nie działa)
	var/lifetime = 15 MINUTES
	COOLDOWN_DECLARE(talk_cooldown)
	COOLDOWN_DECLARE(refusal_cooldown)

/mob/living/carbon/human/dummy/aquila_hex_trader/Initialize(mapload)
	. = ..()
	add_atom_colour("#570d6b", FIXED_COLOUR_PRIORITY)
	set_light(1, -0.7, "#AAD84B")
	ADD_TRAIT(src, TRAIT_PIERCEIMMUNE, type)
	ADD_TRAIT(src, TRAIT_NOMOBSWAP, type)
	real_name = trader_name
	name = trader_name
	if(trader_outfit)
		equipOutfit(trader_outfit, TRUE)
	// Strój zawodu nie wpisuje imienia na kartę, bo handlarz nie ma przydziału
	var/obj/item/card/id/card = wear_id?.GetID()
	if(card)
		card.registered_name = real_name
		card.update_label()
	for(var/obj/item/worn in get_equipped_items(TRUE))
		ADD_TRAIT(worn, TRAIT_NODROP, type)
		worn.resistance_flags |= INDESTRUCTIBLE
	requested_item ||= pick_request()
	addtimer(CALLBACK(src, PROC_REF(lose_patience)), lifetime)

/// Czas minął: handlarz znika bez zapłaty
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/lose_patience()
	if(QDELETED(src))
		return
	active = FALSE
	visible_message("<b>[src]</b> traci cierpliwość.")
	qdel(src)

/mob/living/carbon/human/dummy/aquila_hex_trader/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(1, T)
		smoke.start()
		visible_message("<b>[src]</b> znika w kłębie dymu.")
	return ..()

/mob/living/carbon/human/dummy/aquila_hex_trader/examine(mob/user)
	return list("<span class='warning'>Próbujesz przyjrzeć się twarzy tej postaci, ale widzisz tylko rozmazaną plamę.</span>")

/// Typ żądanej rzeczy, losowany przy pojawieniu się
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/pick_request()
	return null

/// Prośba z nazwą żądanej rzeczy
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/request_text()
	return "Przynieś mi [requested_name()]."

/// Nazwa żądanej rzeczy do kwestii
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/requested_name()
	if(ispath(requested_item, /datum/reagent))
		var/datum/reagent/wanted = requested_item
		return initial(wanted.name)
	if(ispath(requested_item, /atom))
		var/atom/wanted = requested_item
		return initial(wanted.name)
	return "coś"

/mob/living/carbon/human/dummy/aquila_hex_trader/attack_hand(mob/user, modifiers)
	if(!active || !COOLDOWN_FINISHED(src, talk_cooldown))
		return TRUE
	COOLDOWN_START(src, talk_cooldown, 3 SECONDS)
	say(greeting)
	say(request_text())
	return TRUE

/mob/living/carbon/human/dummy/aquila_hex_trader/attackby(obj/item/I, mob/living/user, params)
	if(!active)
		return TRUE
	if(!check_item(I))
		if(COOLDOWN_FINISHED(src, refusal_cooldown))
			COOLDOWN_START(src, refusal_cooldown, 3 SECONDS)
			say(refusal_speech)
		return TRUE
	accept(I, user)
	return TRUE

/// Czy podana rzecz jest tym, czego handlarz chce
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/check_item(obj/item/supplied)
	return supplied?.type == requested_item

/// Bierze rzecz, płaci i znika
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/accept(obj/item/supplied, mob/living/user)
	active = FALSE
	say(thanks_speech)
	log_game("Travelling Trader: [key_name(user)] gave [supplied] to [src] at [AREACOORD(src)].")
	qdel(supplied)
	give_reward(user)
	qdel(src)

/// Holoczip z kredytami i czasem jeden przedmiot; wręcza je temu, kto przyniósł rzecz
/mob/living/carbon/human/dummy/aquila_hex_trader/proc/give_reward(mob/living/user)
	. = list()
	var/turf/T = get_turf(src)
	var/obj/item/holochip/payment = new(T, rand(reward_min, reward_max))
	. += payment
	user?.put_in_hands(payment)
	if(length(reward_items) && prob(50))
		var/item_type = pickweight(reward_items)
		. += new item_type(T)

/mob/living/carbon/human/dummy/aquila_hex_trader/chef
	trader_name = "Kucharz z innego wymiaru"
	trader_outfit = /datum/outfit/job/cook
	greeting = "Na wszystkie przyprawy wszechświata! Przebyłem tysiąc wymiarów w poszukiwaniu prawdziwego smaku."
	thanks_speech = "Pachnie jak u babci w trzecim wymiarze. Dziękuję, przyjacielu!"
	refusal_speech = "To? Tym nie nakarmiłbym nawet kosmicznego karpia."
	reward_items = list(/obj/item/storage/box/ingredients/wildcard = 2, /obj/item/kitchen/rollingpin = 1, /obj/item/clothing/head/chefhat = 1)

/mob/living/carbon/human/dummy/aquila_hex_trader/chef/request_text()
	return "Przynieś mi danie zwane [requested_name()], a sowicie zapłacę."

/mob/living/carbon/human/dummy/aquila_hex_trader/chef/pick_request()
	return pick(
		/obj/item/food/burger/cheese,
		/obj/item/food/pizza/margherita,
		/obj/item/food/pizza/meat,
		/obj/item/food/grilled_cheese_sandwich,
		/obj/item/food/pie/applepie,
		/obj/item/food/pie/cream,
		/obj/item/food/cake/carrot,
		/obj/item/food/cake/chocolate,
		/obj/item/food/cookie/sugar,
		/obj/item/food/spaghetti/pastatomato,
		/obj/item/food/spaghetti/meatballspaghetti,
		/obj/item/food/salad/fruit,
		/obj/item/food/salad/caesar,
		/obj/item/food/omelette,
		/obj/item/food/pancakes,
		/obj/item/food/muffin/berry,
		/obj/item/food/khachapuri,
		/obj/item/food/burrito,
		/obj/item/food/taco/plain,
		/obj/item/food/baguette,
		/obj/item/food/eggplantparm,
		/obj/item/food/benedict,
		/obj/item/food/chawanmushi,
	)

/mob/living/carbon/human/dummy/aquila_hex_trader/gardener
	trader_name = "Ogrodnik z innego wymiaru"
	trader_outfit = /datum/outfit/job/botanist
	greeting = "Szukam w waszym świecie rzadkiej rośliny. Podobno na tym okręcie ktoś jeszcze dba o grządki."
	thanks_speech = "Wspaniała! W końcu dokończę swoją sałatkę. Do zobaczenia!"
	refusal_speech = "To? Czy nikt was nie nauczył podstaw ogrodnictwa?"
	reward_items = list(/obj/item/clothing/suit/hooded/bee_costume = 1, /obj/item/reagent_containers/glass/bottle/nutrient/rh = 2, /obj/item/storage/bag/plants/portaseeder = 1)

/mob/living/carbon/human/dummy/aquila_hex_trader/gardener/request_text()
	return "Czy przyniesiesz mi roślinę zwaną [requested_name()]? Wynagrodzę ci trud."

/mob/living/carbon/human/dummy/aquila_hex_trader/gardener/pick_request()
	return pick(
		/obj/item/food/grown/tomato/blue,
		/obj/item/food/grown/potato/sweet,
		/obj/item/food/grown/apple/gold,
		/obj/item/food/grown/grapes/green,
		/obj/item/food/grown/bluecherries,
		/obj/item/food/grown/pumpkin,
		/obj/item/food/grown/watermelon,
		/obj/item/food/grown/pineapple,
		/obj/item/food/grown/vanillapod,
		/obj/item/food/grown/cocoapod,
		/obj/item/food/grown/garlic,
		/obj/item/food/grown/citrus/lime,
	)

/mob/living/carbon/human/dummy/aquila_hex_trader/bartender
	trader_name = "Barman z innego wymiaru"
	trader_outfit = /datum/outfit/job/bartender
	greeting = "Witaj, mieszkańcu okrętu. Przybyłem do tego wymiaru w poszukiwaniu jednego trunku."
	thanks_speech = "Tak, to jest ten smak, którego szukałem. Dziękuję."
	refusal_speech = "Nie żartuj sobie ze mnie. Nie tego chcę."
	reward_items = list(/obj/item/reagent_containers/food/drinks/bottle/champagne = 2, /obj/item/reagent_containers/food/drinks/bottle/grappa = 2, /obj/item/reagent_containers/food/drinks/shaker = 1)

/mob/living/carbon/human/dummy/aquila_hex_trader/bartender/request_text()
	return "Przynieś mi trzydzieści jednostek napoju zwanego [requested_name()]."

/mob/living/carbon/human/dummy/aquila_hex_trader/bartender/pick_request()
	var/list/mixed = easy_drinks()
	return length(mixed) ? pick(mixed) : /datum/reagent/consumable/ethanol/beer

/**
 * Drinki, które barman zmiesza w jednym kroku z tego, co ma pod ręką: każdy składnik reakcji jest w dystrybutorze
 * napojów, dystrybutorze alkoholi albo w kuchennej lodówce (mleko, śmietanka, cukier), bez katalizatorów,
 * specjalnych naczyń i podgrzewania. Same napoje z dystrybutorów się nie liczą.
 */
/mob/living/carbon/human/dummy/aquila_hex_trader/bartender/proc/easy_drinks()
	var/static/list/drinks
	if(drinks)
		return drinks
	var/static/list/dispenser_drinks = typecacheof(list(
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/kahlua,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/wine,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/gin,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/tequila,
		/datum/reagent/consumable/ethanol/vermouth,
		/datum/reagent/consumable/ethanol/cognac,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/absinthe,
		/datum/reagent/consumable/ethanol/hcider,
		/datum/reagent/consumable/ethanol/creme_de_menthe,
		/datum/reagent/consumable/ethanol/creme_de_cacao,
		/datum/reagent/consumable/ethanol/creme_de_coconut,
		/datum/reagent/consumable/ethanol/triple_sec,
		/datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/applejack,
	), only_root_path = TRUE)
	var/static/list/soft_ingredients = typecacheof(list(
		/datum/reagent/water,
		/datum/reagent/consumable/ice,
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/cream,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/icetea,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/space_up,
		/datum/reagent/consumable/tonic,
		/datum/reagent/consumable/sodawater,
		/datum/reagent/consumable/lemon_lime,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/grenadine,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/lemonjuice,
		/datum/reagent/consumable/menthol,
		/datum/reagent/consumable/milk,
	), only_root_path = TRUE)
	drinks = list()
	for(var/reagent in GLOB.chemical_reactions_list)
		for(var/datum/chemical_reaction/reaction as anything in GLOB.chemical_reactions_list[reagent])
			if(length(reaction.required_catalysts) || reaction.required_container || reaction.required_other || reaction.is_cold_recipe || reaction.required_temp > T20C)
				continue
			var/easy = length(reaction.required_reagents) > 0
			for(var/ingredient in reaction.required_reagents)
				if(!dispenser_drinks[ingredient] && !soft_ingredients[ingredient])
					easy = FALSE
					break
			if(!easy)
				continue
			for(var/result in reaction.results)
				if(ispath(result, /datum/reagent/consumable/ethanol) && result != /datum/reagent/consumable/ethanol && !dispenser_drinks[result])
					drinks |= result
	return drinks

/mob/living/carbon/human/dummy/aquila_hex_trader/bartender/check_item(obj/item/supplied)
	return istype(supplied, /obj/item/reagent_containers) && supplied.reagents?.has_reagent(requested_item, 30)

/mob/living/carbon/human/dummy/aquila_hex_trader/collector
	trader_name = "Kolekcjoner z innego wymiaru"
	trader_outfit = /datum/outfit/aquila_hex_trader_collector
	greeting = "Wyczuwam na tym okręcie przedmiot wielkiej mocy. No, może średniej. Ale wciąż mocy."
	thanks_speech = "Godny mojej kolekcji. Dziękuję, wędrowcze."
	refusal_speech = "Ha! Bezwartościowe."
	reward_min = 600
	reward_max = 1200

/mob/living/carbon/human/dummy/aquila_hex_trader/collector/request_text()
	return "Daj mi przedmiot zwany [requested_name()], a nie pożałujesz."

/mob/living/carbon/human/dummy/aquila_hex_trader/collector/pick_request()
	return pick(request_pool())

/// Przedmioty, o które prosi kolekcjoner: nic, co sprzedaje stary Vendotron, żeby nie dało się kupić zlecenia w automacie
/mob/living/carbon/human/dummy/aquila_hex_trader/collector/proc/request_pool()
	return list(
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/instrument/saxophone,
		/obj/item/relic,
		/obj/item/flashlight/lamp/bananalamp,
		/obj/item/storage/box/hug,
		/obj/item/clothing/shoes/wheelys,
		/obj/item/slime_extract/green,
		/obj/item/clothing/head/crown,
	)

/mob/living/carbon/human/dummy/aquila_hex_trader/collector/check_item(obj/item/supplied)
	return istype(supplied, requested_item)

/mob/living/carbon/human/dummy/aquila_hex_trader/collector/Initialize(mapload)
	reward_items = list()
	for(var/hat_type in subtypesof(/obj/item/clothing/head/collectable))
		reward_items[hat_type] = 1
	return ..()

/datum/outfit/aquila_hex_trader_collector
	name = "Kolekcjoner z innego wymiaru"
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/that
	glasses = /obj/item/clothing/glasses/monocle
