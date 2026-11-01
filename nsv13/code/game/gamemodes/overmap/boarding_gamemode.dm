//Go to a place, board a ship, change the IFF

/datum/overmap_gamemode/boarding
	name = "Abordaż"
	config_tag = "boarding"
	desc = "Tryb abordażu – wejdź na pokład wskazanego okrętu i zhakuj IFF"
	brief = "Waszym zadaniem jest przejęcie jednostki Syndykatu. Zlokalizujcie cel, bezwzględnie wyeliminujcie siły Syndykatu, a następnie zmieńcie kody transpondera i sprowadźcie ją do domu."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 2 // Combat can postpone, but it's not the goal
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 10
	fixed_objectives = list(/datum/overmap_objective/board_ship)

//Go to a place, capture a station, hold it against the counterattack

/datum/overmap_gamemode/station_boarding
	name = "Abordaż stacji"
	config_tag = "station_boarding"
	desc = "Tryb abordażu stacji – zdobądź placówkę Syndykatu, a potem broń jej przed flotą abordażową"
	brief = "Waszym zadaniem jest przejęcie placówki Syndykatu. Zlokalizujcie ją, rozbijcie flotę obronną, wejdźcie na pokład i zmieńcie kody IFF, a potem utrzymajcie placówkę do odparcia kontrataku."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 2 // Combat can postpone, but it's not the goal
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 10
	fixed_objectives = list(/datum/overmap_objective/board_station)
