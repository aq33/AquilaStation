// AQUILA - Dym i zapachy, port z Monkestation 2.0
///Smoke coming from cigarettes and fires
/datum/pollutant/smoke //and mirrors
	name = "Dym"
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
	name = "Marihuana"
	smell_intensity = 2 //Stronger than the normal smoke
	scent = "marihuany"

/datum/pollutant/smoke/vape
	name = "Chmura z e-papierosa"
	thickness = 2
	scent = "miękkiej, przyjemnej pary"

///Dust from mining drills
/datum/pollutant/dust
	name = "Pył"
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
	name = "Siarka"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 5 //Very pronounced smell (and good too, sniff sniff)
	descriptor = SCENT_DESC_SMELL
	scent = "siarki"

///Organic waste and garbage makes this
/datum/pollutant/decaying_waste
	name = "Rozkładające się odpadki"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 3
	descriptor = SCENT_DESC_ODOR
	scent = "rozkładających się odpadków"
	smell_mood_event = /datum/mood_event/pollution_stench

///Splashing blood makes a tiny bit of this
/datum/pollutant/metallic_scent
	name = "Metaliczny zapach"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "metalu"

///A special "Quick Dispersal" smoke for special cigars
/datum/pollutant/bright_cosmos
	name = "Kosmiczny dym"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "orzeźwiającej mięty i łagodnego dymu"

///Green goo piles and medicine chemical reactions make this
/datum/pollutant/chemical_vapors
	name = "Opary chemiczne"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "chemikaliów"

///Dangerous fires release this from the waste they're burning
/datum/pollutant/carbon_air_pollution
	name = "Zanieczyszczenie węglowe"
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
	name = "Smażone mięso"
	scent = "smażonego mięsa"

/datum/pollutant/food/fried_bacon
	name = "Smażony bekon"
	scent = "smażonego bekonu"

/datum/pollutant/food/fried_fish
	name = "Smażona ryba"
	scent = "smażonej ryby"

/datum/pollutant/food/pancakes
	name = "Naleśniki"
	scent = "naleśników"

/datum/pollutant/food/coffee
	name = "Kawa"
	scent = "kawy"

/datum/pollutant/food/tea
	name = "Herbata"
	scent = "herbaty"

/datum/pollutant/food/chocolate
	name = "Czekolada"
	scent = "czekolady"

/datum/pollutant/food/spicy_noodles
	name = "Pikantny makaron"
	scent = "pikantnego makaronu"

//Fragrances that we spray on thing to make them smell nice
/datum/pollutant/fragrance
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_FRAGRANCE
	smell_mood_event = /datum/mood_event/pollution_fragrance

/datum/pollutant/fragrance/air_refresher
	name = "Odświeżacz powietrza"
	scent = "intensywnych kwiatów"
	smell_intensity = 3

//Simple fragrances
/datum/pollutant/fragrance/cologne
	name = "Woda kolońska"
	scent = "wody kolońskiej"

/datum/pollutant/fragrance/wood
	name = "Perfumy drzewne"
	scent = "starego drewna"

/datum/pollutant/fragrance/rose
	name = "Perfumy różane"
	scent = "róż"

/datum/pollutant/fragrance/jasmine
	name = "Perfumy jaśminowe"
	scent = "jaśminu"

/datum/pollutant/fragrance/mint
	name = "Perfumy miętowe"
	scent = "mięty"

/datum/pollutant/fragrance/vanilla
	name = "Perfumy waniliowe"
	scent = "wanilii"

/datum/pollutant/fragrance/pear
	name = "Perfumy gruszkowe"
	scent = "gruszki"

/datum/pollutant/fragrance/strawberry
	name = "Perfumy truskawkowe"
	scent = "truskawek"

/datum/pollutant/fragrance/cherry
	name = "Perfumy wiśniowe"
	scent = "wiśni"

/datum/pollutant/fragrance/amber
	name = "Perfumy bursztynowe"
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
