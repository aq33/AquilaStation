/*
	Fireproof, makes the fruit fire proof
	This doesn't make seeds fireproof anymore
*/

/datum/plant_trait/fruit/fireproof
	name = "Ognioodporność"
	desc = "Owoc jest ognioodporny i wytrzymuje temperatury, które normalnie by go zniszczyły. Dodatkowo stabilizuje jego skład genetyczny."
	genetic_cost = -1

/datum/plant_trait/fruit/fireproof/setup_fruit_parent()
	. = ..()
	fruit_parent.resistance_flags |= FIRE_PROOF
