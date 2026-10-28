// AQUILA - Dym i zapachy, port z Monkestation 2.0
///Smoke coming from cigarettes and fires
/datum/pollutant/smoke //and mirrors
	name = "Smoke"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_SMELL | POLLUTANT_BREATHE_ACT
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "dymu"

/datum/pollutant/smoke/breathe_act(mob/living/carbon/victim, amount)
	if(amount <= 50)
		return
	if(prob(20))
		victim.emote("cough")

	if(is_species(victim, /datum/species/apid))
		victim.drowsyness = min(victim.drowsyness + 1, 10)

///From smoking weed
/datum/pollutant/smoke/cannabis
	name = "Cannabis"
	smell_intensity = 2 //Stronger than the normal smoke
	scent = "marihuany"

/datum/pollutant/smoke/vape
	name = "Vape Cloud"
	thickness = 2
	scent = "miękkiej, przyjemnej pary"

///Dust from mining drills
/datum/pollutant/dust
	name = "Dust"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_BREATHE_ACT
	thickness = 2
	color = "#ffed9c"

/datum/pollutant/dust/breathe_act(mob/living/carbon/victim, amount)
	if(amount <= 10)
		return
	if(prob(40))
		victim.losebreath += 3 //Get in your lungs real bad
		victim.emote("cough")

///Sulphur coming from igniting matches
/datum/pollutant/sulphur
	name = "Sulphur"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 5 //Very pronounced smell (and good too, sniff sniff)
	descriptor = SCENT_DESC_SMELL
	scent = "siarki"

///Organic waste and garbage makes this
/datum/pollutant/decaying_waste
	name = "Decaying Waste"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 3
	descriptor = SCENT_DESC_ODOR
	scent = "rozkładających się odpadków"
	smell_mood_event = /datum/mood_event/pollution_stench

///Splashing blood makes a tiny bit of this
/datum/pollutant/metallic_scent
	name = "Metallic Scent"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "metalu"

///A special "Quick Dispersal" smoke for special cigars
/datum/pollutant/bright_cosmos
	name = "Cosmic Smoke"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "orzeźwiającej mięty i łagodnego dymu"

///Green goo piles and medicine chemical reactions make this
/datum/pollutant/chemical_vapors
	name = "Chemical Vapors"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "chemikaliów"

///Dangerous fires release this from the waste they're burning
/datum/pollutant/carbon_air_pollution
	name = "Carbon Air Pollution"
	pollutant_flags = POLLUTANT_BREATHE_ACT

// AQUILA - Monke dealt 5-10 oxy and 1 tox per breath, which outpaced any recovery. Now it is a nuisance you can still stand in for a while.
/datum/pollutant/carbon_air_pollution/breathe_act(mob/living/carbon/victim, amount)
	if(!(victim.mobility_flags & MOBILITY_STAND))
		amount *= 0.35 //The victim is inhaling roughly a third when laying down
	if(amount <= 10)
		return
	victim.adjustOxyLoss(rand(2, 4))
	if(amount > 40)
		victim.adjustToxLoss(0.5)
	if(prob(amount * 0.5))
		victim.losebreath += 1
	if(prob(15))
		victim.emote("cough")

//Food related smells
/datum/pollutant/food
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 0.5 //Low intensity because we want to carry it farther with more amounts
	descriptor = SCENT_DESC_SMELL
	smell_mood_event = /datum/mood_event/pollution_food

/datum/pollutant/food/fried_meat
	name = "Fried Meat"
	scent = "smażonego mięsa"

/datum/pollutant/food/fried_bacon
	name = "Fried Bacon"
	scent = "smażonego bekonu"

/datum/pollutant/food/fried_fish
	name = "Fried Fish"
	scent = "smażonej ryby"

/datum/pollutant/food/pancakes
	name = "Pancakes"
	scent = "naleśników"

/datum/pollutant/food/coffee
	name = "Coffee"
	scent = "kawy"

/datum/pollutant/food/tea
	name = "Tea"
	scent = "herbaty"

/datum/pollutant/food/chocolate
	name = "Chocolate"
	scent = "czekolady"

/datum/pollutant/food/spicy_noodles
	name = "Spicy Noodles"
	scent = "pikantnego makaronu"

//Fragrances that we spray on thing to make them smell nice
/datum/pollutant/fragrance
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_FRAGRANCE
	smell_mood_event = /datum/mood_event/pollution_fragrance

/datum/pollutant/fragrance/air_refresher
	name = "Air Refresher"
	scent = "intensywnych kwiatów"
	smell_intensity = 3

//Simple fragrances
/datum/pollutant/fragrance/cologne
	name = "Cologne Water"
	scent = "wody kolońskiej"

/datum/pollutant/fragrance/wood
	name = "Wood Perfume"
	scent = "starego drewna"

/datum/pollutant/fragrance/rose
	name = "Rose Perfume"
	scent = "róż"

/datum/pollutant/fragrance/jasmine
	name = "Jasmine Perfume"
	scent = "jaśminu"

/datum/pollutant/fragrance/mint
	name = "Mint Perfume"
	scent = "mięty"

/datum/pollutant/fragrance/vanilla
	name = "Vanilla Perfume"
	scent = "wanilii"

/datum/pollutant/fragrance/pear
	name = "Pear Perfume"
	scent = "gruszki"

/datum/pollutant/fragrance/strawberry
	name = "Strawberry Perfume"
	scent = "truskawek"

/datum/pollutant/fragrance/cherry
	name = "Cherry Perfume"
	scent = "wiśni"

/datum/pollutant/fragrance/amber
	name = "Amber Perfume"
	scent = "bursztynu, słodkiego i pudrowego"

/datum/mood_event/pollution_stench
	description = "<span class='warning'>Coś tu okropnie śmierdzi.</span>\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/pollution_food
	description = "<span class='nicegreen'>Coś tu smakowicie pachnie.</span>\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/pollution_fragrance
	description = "<span class='nicegreen'>Ale tu ładnie pachnie.</span>\n"
	mood_change = 2
	timeout = 3 MINUTES
