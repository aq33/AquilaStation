/datum/vampire_clan/ventrue
	name = CLAN_VENTRUE
	description = "Ventrue od dawna należą do najdumniejszych wampirzych rodów. Członkowie klanu usilnie dbają o reputację ludzi honoru, dobrych manier i przywództwa.<br><br>\
		Klan od dawna przenika poczucie noblesse oblige, połączone ze szczerym przekonaniem, że Ventrue wiedzą, co jest najlepsze dla wszystkich.<br><br>\
		Uważają się nie tylko za najstarszy klan, ale też za strażników tradycji i prawowitych przywódców społeczności Spokrewnionych. "
	join_icon_state = "ventrue"
	blood_drink_type = VAMPIRE_DRINK_SNOBBY
	default_humanity = 9
	princely_score_bonus = 15	// IT'S OVER NIN- ten. It's over ten.
	joinable_clan = TRUE

/datum/vampire_clan/ventrue/New(datum/antagonist/vampire/owner_datum)
	. = ..()

	vampiredatum.owned_disciplines += new /datum/discipline/presence(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/dominate/ventrue(vampiredatum)
	vampiredatum.owned_disciplines += new /datum/discipline/fortitude(vampiredatum)
