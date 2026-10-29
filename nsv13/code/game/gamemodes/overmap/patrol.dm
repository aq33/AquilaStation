//The default gamemode

//Acquire 1000 tickets for NT - you know the drill

/datum/overmap_gamemode/patrol
	name = "Patrol"
	config_tag = "patrol"
	desc = "Domyślny tryb gry – zdobądź 1000 punktów zwycięstwa dla Nanotrasen"
	brief = "Przydzielono wam standardowy patrol poza sektorem Foothold. Patrolujcie ten obszar, bezwzględnie eliminujcie siły Syndykatu, a potem wróćcie na Posterunek 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 1
	selection_weight = 5
	required_players = 10
	fixed_objectives = list(/datum/overmap_objective/tickets/nt)
