/datum/vampire_clan/tremere
	name = CLAN_TREMERE
	description = "W (stosunkowo) krótkim czasie od swojego powstania Tremere zdobyli niesamowite wpływy w wampirzym społeczeństwie i są dziś zapewne najpotężniejszym klanem współczesnych nocy.<br><br>\
		Zawdzięczają to w niemałej mierze ścisłej hierarchii, skrytości i mistrzostwu w Taumaturgii - wszystko to budzi w innych Kainitach podejrzliwość, strach i szacunek.<br><br>\
		Tremere są filarem Camarilli i jednym z jej głównych obrońców, choć istnieją niemal jako odrębna podsekta."
	join_icon_state = "tremere"
	default_humanity = 7
	princely_score_bonus = 8
	joinable_clan = TRUE

/datum/vampire_clan/tremere/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/dominate(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/auspex(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/thaumaturgy(vampiredatum)
