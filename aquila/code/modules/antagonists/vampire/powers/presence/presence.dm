/datum/discipline/presence
	name = "Prezencja"
	discipline_explanation = "Prezencja to dyscyplina nadnaturalnej obecności i subtelnej manipulacji, która pozwala Spokrewnionym zawładnąć uwagą otoczenia."
	icon_state = "presence"
	level_1 = list(/datum/action/vampire/targeted/entrance)
	level_2 = list(/datum/action/vampire/targeted/entrance, /datum/action/vampire/targeted/summon)
	level_3 = list(/datum/action/vampire/awe, /datum/action/vampire/targeted/entrance, /datum/action/vampire/targeted/summon)
	level_4 = list(/datum/action/vampire/awe, /datum/action/vampire/targeted/entrance, /datum/action/vampire/targeted/summon, /datum/action/vampire/force_of_personality)
	level_5 = null
