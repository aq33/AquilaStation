/datum/discipline/obfuscate
	name = "Ukrycie"
	discipline_explanation = "Ukrycie to dyscyplina, która pozwala wampirom się ukrywać, zwodzić umysły innych albo sprawiać, że ignorują to, czego wampir nie chce im pokazać."
	icon_state = "obfuscate"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/cloak)
	level_2 = list(/datum/action/vampire/cloak, /datum/action/vampire/targeted/trespass)
	level_3 = list(/datum/action/vampire/cloak, /datum/action/vampire/targeted/trespass/two)
	level_4 = list(/datum/action/vampire/cloak, /datum/action/vampire/targeted/trespass/three, /datum/action/vampire/veil)
	level_5 = null
