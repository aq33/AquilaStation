/*
	Bioluminescence, makes the fruit glow
*/

/datum/plant_trait/fruit/biolight
	name = "Bioluminescencja"
	desc = "Owoc świeci."
	scales = "Zasięg i siła świecenia rosną z mocą cech."
	examine_line = span_info("Delikatnie świeci.")
///Glow characteristics
	var/glow_color = "#ffffff"
	//Minimums
	var/glow_range = 2
	var/glow_power = 3

/datum/plant_trait/fruit/biolight/setup_fruit_parent()
	. = ..()
	if(QDELETED(fruit_parent))
		return
	fruit_parent.light_system = MOVABLE_LIGHT
	fruit_parent.AddComponent(/datum/component/overlay_lighting, glow_range*trait_power, glow_power*trait_power, glow_color)

//Yellow
/datum/plant_trait/fruit/biolight/yellow
	name = "Żółta bioluminescencja"
	desc = "Owoc świeci na żółto."
	glow_color = "#FFFF66"

//Orange
/datum/plant_trait/fruit/biolight/orange
	name = "Pomarańczowa bioluminescencja"
	desc = "Owoc świeci na pomarańczowo."
	glow_color = "#D05800"


//Green
/datum/plant_trait/fruit/biolight/green
	name = "Zielona bioluminescencja"
	desc = "Owoc świeci na zielono."
	glow_color = "#99FF99"

//Red
/datum/plant_trait/fruit/biolight/red
	name = "Czerwona bioluminescencja"
	desc = "Owoc świeci na czerwono."
	glow_color = "#FF3333"

//Blue
/datum/plant_trait/fruit/biolight/blue
	//the best one - Pirill
	name = "Niebieska bioluminescencja"
	glow_color = "#6699FF"

//Purple
/datum/plant_trait/fruit/biolight/purple
	//did you know that Notepad++ doesnt think bioluminescence is a word - Pirill
	name = "Fioletowa bioluminescencja"
	glow_color = "#D966FF"

//Pink
/datum/plant_trait/fruit/biolight/pink
	//gay tide station pride - Pirill
	name = "Różowa bioluminescencja"
	glow_color = "#FFB3DA"

//White
/datum/plant_trait/fruit/biolight/white
	//gay tide station pride - Pirill
	name = "Biała bioluminescencja"
	glow_color = "#FFF"

//Shadow
/datum/plant_trait/fruit/biolight/dark
	name = "Emisja cienia"
	desc = "Owoc emituje cień."
	glow_color = "#AAD84B"
	glow_power = 0.04
