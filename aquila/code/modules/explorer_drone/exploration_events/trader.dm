/// Trader events - If drone is loaded with X exchanges it for Y, might require translator tool.
/datum/exploration_event/simple/trader
	abstract_type = /datum/exploration_event/simple/trader
	action_text = "Handluj"
	/// Obj path we'll take or list of paths ,one path will be picked from it at init
	var/required_path
	/// Obj path we'll give out or list of paths ,one path will be picked from it at init
	var/traded_path
	//How many times we'll allow the trade
	var/amount = 1
	var/requires_translator = TRUE

/datum/exploration_event/simple/trader/New()
	. = ..()
	if(islist(required_path))
		required_path = pick(required_path)
	if(islist(traded_path))
		traded_path = pick(traded_path)

/datum/exploration_event/simple/trader/get_discovery_message(obj/item/exodrone/drone)
	if(requires_translator && !drone.has_tool(EXODRONE_TOOL_TRANSLATOR))
		return "Natrafiono na: [name], ale bez tłumacza nie wiadomo, czego chce."
	var/obj/want = required_path
	var/obj/gives = traded_path
	return "Natrafiono na: [name]. Odda [initial(gives.name)] za [initial(want.name)]."

/datum/exploration_event/simple/trader/get_description(obj/item/exodrone/drone)
	if(requires_translator && !drone.has_tool(EXODRONE_TOOL_TRANSLATOR))
		return "Natrafiasz na: [name], ale bez tłumacza nie rozumiesz, czego chce."
	var/obj/want = required_path
	var/obj/gives = traded_path
	return "Natrafiasz na: [name]. Chętnie wymieni [initial(want.name)] na [initial(gives.name)][amount > 1 ? " (do [amount] razy)" : ""]."

/datum/exploration_event/simple/trader/is_targetable()
	return visited && (amount > 0)

/datum/exploration_event/simple/trader/action_enabled(obj/item/exodrone/drone)
	var/obj/trade_good = locate(required_path) in drone.contents
	return (amount > 0) && trade_good && (!requires_translator || drone.has_tool(EXODRONE_TOOL_TRANSLATOR))

/datum/exploration_event/simple/trader/fire(obj/item/exodrone/drone)
	if(!action_enabled(drone))
		end(drone)
		return
	amount--
	trade(drone)
	end(drone)

/datum/exploration_event/simple/trader/proc/trade(obj/item/exodrone/drone)
	var/obj/trade_good = locate(required_path) in drone.contents
	var/obj/loot = new traded_path()
	drone.drone_log("Wymieniono [trade_good.name] na [loot.name].")
	qdel(trade_good)
	drone.try_transfer(loot)


/// Trade events

/datum/exploration_event/simple/trader/vendor_ai
	name = "świadomy automat z narkotykami"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY)
	band_values = list(EXOSCANNER_BAND_TECH = 2)
	requires_translator = FALSE
	required_path = /obj/item/stock_parts/cell/high
	traded_path = /obj/item/storage/pill_bottle/happy
	amount = 3

/datum/exploration_event/simple/trader/farmer_market
	name = "targ rolniczy"
	deep_scan_description = "Wykryto obszar z niezwykle dużym stężeniem jedzenia."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE, EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_LIFE = 2)
	required_path = /obj/item/stock_parts/manipulator/nano
	traded_path = list(/obj/item/plant_seeds/preset/killer_tomato, /obj/item/plant_seeds/preset/orange, /obj/item/plant_seeds/preset/gat)
	amount = 1

/datum/exploration_event/simple/trader/fish
	name = "międzygwiezdny handlarz rybami"
	requires_translator = FALSE
	deep_scan_description = "Na miejscu widać ogromny szyld „ŚWIEŻE RYBY”."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE, EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_LIFE = 2)
	required_path = /obj/item/stock_parts/cell/high
	traded_path = /obj/item/storage/fish_case/random
	amount = 3

/datum/exploration_event/simple/trader/shady_merchant
	name = "podejrzany kupiec"
	requires_translator = FALSE
	required_site_traits = list(EXPLORATION_SITE_HABITABLE, EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_LIFE = 1)
	required_path = list(/obj/item/organ/heart, /obj/item/organ/liver, /obj/item/organ/stomach, /obj/item/organ/eyes)
	traded_path = list(/obj/item/implanter/explosive)
	amount = 1

/datum/exploration_event/simple/trader/surplus
	name = "handlarz demobilem"
	deep_scan_description = "Odszyfrowano transmisję reklamującą sprzedaż wojskowego demobilu."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE, EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_LIFE = 1)
	required_path = list(/obj/item/clothing/suit/armor, /obj/item/clothing/shoes/jackboots)
	traded_path = /obj/item/gun/energy/laser/retro/old
	amount = 3

/datum/exploration_event/simple/trader/flame_card
	name = "rzemieślnik od identyfikatorów"
	deep_scan_description = "Wypatrzono reklamę warsztatu przerabiającego identyfikatory."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE, EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_TECH = 1)
	required_path = list(/obj/item/card/id) //If you trade a better card for worse that's on you
	traded_path = null
	requires_translator = FALSE
	amount = 1
	// w tg jest tu "card_flames", którego nie ma w ich card.dmi; stany są w osobnym pliku Aquili
	var/static/list/possible_card_states = list("card_flame", "card_carp", "card_rainbow")

/datum/exploration_event/simple/trader/flame_card/get_discovery_message(obj/item/exodrone/drone)
	return "Natrafiono na: [name]. Przerobi każdy przyniesiony identyfikator."

/datum/exploration_event/simple/trader/flame_card/get_description(obj/item/exodrone/drone)
	return "Spotykasz miejscowego rzemieślnika, który za darmo przerobi ci identyfikator."

/datum/exploration_event/simple/trader/flame_card/trade(obj/item/exodrone/drone)
	var/obj/item/card/id/card = locate(required_path) in drone.contents
	card.icon = 'aquila/icons/obj/exploration_cards.dmi'
	card.icon_state = pick(possible_card_states)
	card.update_icon() //Refresh cached helper image
	drone.drone_log("Rzemieślnik przerobił: [card.name].")
