/datum/vampire_clan/toreador
	name = CLAN_TOREADOR
	description = "Toreador to klan wampirów słynących z tego, że należą do najpiękniejszych, najbardziej zmysłowych, uwodzicielskich, uczuciowych i olśniewających spośród Spokrewnionych.<br><br>\
		To od nich wzięły się legendy o wampirach, które uwodzą i wabią ofiary pięknem, miłością i zmysłowością. Sławni i niesławni jako klan artystów i nowatorów, są jednym z bastionów Camarilli, bo samo ich przetrwanie zależy od fasady ogłady i wdzięku, z której sekta jest tak dumna. <br><br>\
		Z krwi są urodzonymi divami, a ich Człowieczeństwo i poczucie moralności potrafi spaść równie szybko, jak rośnie."
	join_icon_state = "toreador"
	default_humanity = 10
	princely_score_bonus = 10
	joinable_clan = TRUE

/datum/vampire_clan/toreador/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/celerity(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/auspex(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)
