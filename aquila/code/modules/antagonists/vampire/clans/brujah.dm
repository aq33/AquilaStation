/datum/vampire_clan/brujah
	name = CLAN_BRUJAH
	description = "W dużej mierze niezależni od reguł Camarilli, Brujah przedkładają własne rady i uliczne sądy nad książęce salony.<br>\
		To upadły klan, lud, który z wojowników-uczonych stoczył się do roli zażartych, kłótliwych buntowników. A jednak pod gniewem wciąż tlą się iskry dyscypliny i mądrości.<br><br>\
		Zarazem wielu Brujah to pragmatycy. Szanują kompetencje, nagradzają siłę i przystają na układy, które pozwalają im zachować autonomię, a przy tym służyć jakiemuś celowi. Za odpowiednią cenę, w zamian za haki albo szansę na wyrównanie rachunków książęta werbowali Brujah na Biczów czy egzekutorów, byle tylko ci Brujah zachowali widoczną niezależność."
	join_icon_state = "brujah"
	default_humanity = 8
	princely_score_bonus = 2
	joinable_clan = TRUE

/datum/vampire_clan/brujah/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum.owned_disciplines += new /datum/discipline/celerity(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/potence/brujah(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)

/datum/vampire_clan/brujah/on_apply()
	. = ..()
	vampiredatum.antag_hud_name = "brujah"
	vampiredatum.add_team_hud(vampiredatum.owner.current)
