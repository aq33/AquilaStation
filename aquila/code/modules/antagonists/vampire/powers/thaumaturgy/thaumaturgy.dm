/datum/discipline/thaumaturgy
	name = "Taumaturgia"
	discipline_explanation = "Taumaturgia to pilnie strzeżona magia krwi, praktykowana przez wampirzy klan Tremere."
	icon_state = "thaumaturgy"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/targeted/bloodboil)
	level_2 = list(/datum/action/vampire/targeted/bloodboil/two, /datum/action/vampire/targeted/blooddrain)
	level_3 = list(/datum/action/vampire/targeted/bloodboil/three, /datum/action/vampire/targeted/blooddrain, /datum/action/vampire/bloodshield)
	level_4 = list(/datum/action/vampire/targeted/bloodboil/four, /datum/action/vampire/targeted/blooddrain, /datum/action/vampire/bloodshield, /datum/action/vampire/targeted/bloodbolt)
//	level_5 = null
