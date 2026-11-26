// AQUILA - wspólny kanał i helpery wiadomości z galaktyki dla eventów ciekawostek, wiadomości ze świata i wiadomości z sektora
// (trivial_news.dm, mundane_news.dm, news_report.dm). Bay and Shiptest post to their own news networks; ours go to one
// locked newscaster channel created on the first article, so the three events do not spam three new channels.

/// Locked newscaster channel of the galactic news events, created when the first article comes in
/proc/aquila_hex_news_channel()
	var/static/channel_name = "Wiadomości z Galaktyki"
	if(!GLOB.news_network)
		return null
	for(var/datum/feed_channel/FC as anything in GLOB.news_network.network_channels)
		if(FC.channel_name == channel_name)
			return channel_name
	GLOB.news_network.create_feed_channel(channel_name, "Galaktyczna Agencja Prasowa", "Najnowsze wiadomości, plotki i ciekawostki z całej galaktyki.", locked = TRUE)
	return channel_name

/// Posts an article to the galactic news channel. Returns TRUE when it was posted
/proc/aquila_hex_post_news(title, body, author)
	var/channel_name = aquila_hex_news_channel()
	if(!channel_name || !body)
		return FALSE
	var/text = title ? "<b>[title]</b><br><br>[body]" : body
	GLOB.news_network.submit_article(text, author, channel_name, null, allow_comments = FALSE)
	return TRUE

/// A place for a news article: a star system of our map, or a made up one
/proc/aquila_hex_news_place()
	var/list/names = list()
	for(var/datum/star_system/system as anything in SSstar_system.systems)
		if(system?.name)
			names += system.name
	if(length(names))
		return pick(names)
	return pick("Tortuga", "Rubikon", "Sol", "Argo", "Kepler", "Feliks")

/// Base of the three galactic news events: posts one article when it starts
/datum/round_event/aquila_hex_news
	fakeable = FALSE
	startWhen = 1
	announceWhen = 0
	/// Author shown under the article
	var/author = "Galaktyczna Agencja Prasowa"

/datum/round_event/aquila_hex_news/start()
	var/list/article = make_article()
	if(!length(article) || !aquila_hex_post_news(article[1], article[2], author))
		log_game("[type]: no article posted.")
		return
	log_game("[type]: posted \"[article[1]]\".")

/// list(title, body) of the article, null when there is nothing to post
/datum/round_event/aquila_hex_news/proc/make_article()
	return null
