// AQUILA - Wiadomość gospodarcza w kanale informacyjnym i czasowa zmiana cen na jednej stacji handlowej (port z Baystation12 code/modules/economy/Events.dm)
// Bay picks a trade destination and changes the price of whole categories of goods there for a while. Our traders
// (nsv13/code/modules/overmap/traders.dm) keep their stock as /datum/trader_item with a price and no categories, so the
// event raises or lowers the price of everything one trader sells by 30-100% / 20-50% for 20-40 minutes and puts the prices
// back afterwards. Items the trader restocks during the event get the same change. Bay's random 1-100x jumps are capped.

/// Newscaster channel the economic news go to
#define AQUILA_HEX_ECONOMY_CHANNEL "Wiadomości Gospodarcze"

/datum/round_event_control/aquila_hex_economic_news
	name = "Economic News"
	typepath = /datum/round_event/aquila_hex_economic_news
	weight = 10
	max_occurrences = 4
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_economic_news
	fakeable = FALSE
	startWhen = 0
	announceWhen = 1
	/// Trader whose prices change
	var/datum/trader/affected_trader
	/// Price multiplier for the trader's goods
	var/price_multiplier = 1
	/// What happened there, one of the keys of the article list in article_body()
	var/news_type
	/// weakref to a trader item => its price before the event (weakrefs, because restocking deletes the items)
	var/list/original_prices = list()

/datum/round_event/aquila_hex_economic_news/setup()
	endWhen = rand(600, 1200) // 20-40 minutes in 2 second event ticks
	var/list/possible_traders = list()
	for(var/datum/trader/T as anything in SSstar_system.traders)
		if(QDELETED(T) || istype(T, /datum/trader/randy) || !T.system)
			continue
		possible_traders += T
	if(!length(possible_traders))
		log_game("Economic News: no trader stations, cancelling the event.")
		return
	affected_trader = pick(possible_traders)
	news_type = pick("riots", "animals", "accident", "biohazard", "pirates", "raid", "mourning", "festival", "breach")
	var/cheaper = (news_type in list("riots", "mourning"))
	price_multiplier = cheaper ? rand(50, 80) / 100 : rand(130, 200) / 100

/datum/round_event/aquila_hex_economic_news/start()
	if(!affected_trader)
		return kill()
	apply_price_change()
	log_game("Economic News: [affected_trader.name] ([affected_trader.system?.name]) prices x[price_multiplier] ([news_type]) for [endWhen * 2] seconds.")

/datum/round_event/aquila_hex_economic_news/announce(fake)
	if(!affected_trader)
		return
	ensure_news_channel()
	GLOB.news_network.submit_article(article_body(), "Galaktyczny Serwis Gospodarczy", AQUILA_HEX_ECONOMY_CHANNEL, null)

/datum/round_event/aquila_hex_economic_news/tick()
	if(activeFor % 5)
		return
	apply_price_change() // goods restocked during the event

/datum/round_event/aquila_hex_economic_news/end()
	restore_prices()

/// Changes the price of every trader item that was not changed yet
/datum/round_event/aquila_hex_economic_news/proc/apply_price_change()
	if(QDELETED(affected_trader))
		return
	for(var/datum/trader_item/item as anything in affected_trader.stonks)
		if(QDELETED(item))
			continue
		var/datum/weakref/item_ref = WEAKREF(item)
		if(!isnull(original_prices[item_ref]))
			continue
		original_prices[item_ref] = item.price
		item.price = max(1, round(item.price * price_multiplier))

/// Puts the prices of items the trader still sells back
/datum/round_event/aquila_hex_economic_news/proc/restore_prices()
	if(!QDELETED(affected_trader))
		for(var/datum/trader_item/item as anything in affected_trader.stonks)
			var/datum/weakref/item_ref = WEAKREF(item)
			if(item_ref && !isnull(original_prices[item_ref]))
				item.price = original_prices[item_ref]
	original_prices.Cut()

/datum/round_event/aquila_hex_economic_news/kill()
	if(length(original_prices)) // killed early (admin), do not leave the prices changed
		restore_prices()
	return ..()

/// Creates the economy channel of the newscaster network if it is missing
/datum/round_event/aquila_hex_economic_news/proc/ensure_news_channel()
	for(var/datum/feed_channel/FC as anything in GLOB.news_network.network_channels)
		if(FC.channel_name == AQUILA_HEX_ECONOMY_CHANNEL)
			return
	GLOB.news_network.create_feed_channel(AQUILA_HEX_ECONOMY_CHANNEL, "Galaktyczny Serwis Gospodarczy", "Wiadomości z rynków i stacji handlowych sektora.", locked = TRUE)

/// Text of the article
/datum/round_event/aquila_hex_economic_news/proc/article_body()
	var/place = "[affected_trader.name] w układzie [affected_trader.system?.name]"
	var/person = random_unique_name(MALE)
	var/body
	switch(news_type)
		if("riots")
			body = "Na stacji [place] wybuchły zamieszki. Władze wzywają do spokoju, a różne frakcje gromadzą broń i pancerze. Miejscowi kupcy w obawie przed grabieżą wyprzedają zapasy."
		if("animals")
			body = "Dzika fauna w pobliżu stacji [place] staje się coraz agresywniejsza i napada na odległe osady w poszukiwaniu pożywienia. Wezwano myśliwych, ale rannych jest już wielu."
		if("accident")
			body = "Wypadek przemysłowy w dokach stacji [place] spowodował poważne zniszczenia i wielu rannych. Naprawy trwają."
		if("biohazard")
			body = "Z powodu zagrożenia biologicznego stację [place] objęto kwarantanną, która wstrzymała ruch statków w okolicy. Kwarantannę zniesiono, ale władze proszą o dostawy leków."
		if("pirates")
			body = "Stacja [place] padła dziś ofiarą piratów. Ochronę wzmocniono, ale skradziono wiele cennych towarów."
		if("raid")
			body = "Niewielka flota najemników wyskoczyła z nadprzestrzeni tuż przy stacji [place] i przeprowadziła szybki napad rabunkowy. Zniszczenia są duże, a ochronę wzmocniono."
		if("mourning")
			body = "Znany badacz [person] zginął w niecodziennym wypadku na stacji [place]. Cała stacja pogrążyła się w żałobie, a morale pracowników spada."
		if("festival")
			body = "Administrator [person] ogłosił na stacji [place] tydzień świętowania. Wykupiono ogromne zapasy żywności."
		if("breach")
			body = "Dziś rano doszło do naruszenia zabezpieczeń w strefie o ograniczonym dostępie stacji [place]. Po incydencie zaostrzono kontrole."
	var/percent = abs(round((price_multiplier - 1) * 100))
	if(price_multiplier < 1)
		body += "<br><br>Ceny na stacji [affected_trader.name] spadły o około [percent]%."
	else
		body += "<br><br>Ceny na stacji [affected_trader.name] wzrosły o około [percent]%."
	return body

#undef AQUILA_HEX_ECONOMY_CHANNEL
