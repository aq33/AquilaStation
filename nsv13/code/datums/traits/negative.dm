/datum/quirk/seasick
	name = "Choroba morska"
	desc = "Twój organizm ma naturalną awersję do prądów i promieniowania bluespace. Gdy statek wykonuje skok FTL, może ci się zrobić niedobrze."
	value = -2
	mob_trait = TRAIT_SEASICK
	gain_text = "<span class='notice'>Myśl o podróży FTL budzi w tobie niepokój</span>"
	lose_text = "<span class='notice'>Myśl o podróży FTL nie wydaje się już taka zła.</span>"
	medical_record_text = "Pacjent jest wrażliwy na prądy bluespace i często choruje podczas podróży FTL."

/datum/quirk/junkie/coffee_addict
	name = "Uzależnienie od kawy"
	desc = "Jesteś silnie uzależniony od kofeiny. Na dłuższą metę to raczej nic dobrego."
	value = -1
	gain_text = "<span class='danger'>Masz ochotę na kubek kawy.</span>"
	lose_text = "<span class='notice'>Masz wrażenie, że nie potrzebujesz już tyle kofeiny.</span>"
	medical_record_text = "Pacjent jest uzależniony od kofeiny."
	reagent_type = /datum/reagent/consumable/coffee
	drug_container_type = /obj/item/reagent_containers/food/drinks/coffee
	process = TRUE

/datum/quirk/junkie/naval_coffee_Addict
	name = "Uzależnienie od kawy marynarki"
	desc = "Jesteś silnie uzależniony od tego zmywacza do farb, który marynarka nazywa kawą. Na dłuższą metę to raczej nic dobrego dla twojej wątroby i serca."
	value = -1
	gain_text = "<span class='danger'>Powieki ci ciążą, naprawdę potrzebujesz kubka kawy marynarki, żeby przetrwać ten patrol.</span>"
	lose_text = "<span class='notice'>Stres patrolu zelżał, nie czujesz już, że potrzebujesz tyle kofeiny.</span>"
	medical_record_text = "Pacjent jest silnie uzależniony od niebezpiecznego płynu, który marynarka nazywa kawą."
	reagent_type = /datum/reagent/consumable/navy_coffee
	drug_container_type = /obj/item/reagent_containers/food/drinks/coffee/navy_coffee
	process = TRUE
