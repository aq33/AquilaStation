// AQUILA - port z tgstation (code/datums/mutations/body.dm, rock_eater / rock_absorber)
// Samo jedzenie minerałów obsługuje golem_food.dm (komponent na rudach, arkuszach, żarówkach i gibtonicie).

// You eat rocks
/datum/mutation/rock_eater
	name = "Pożeracz kamieni"
	desc = "Organizm pacjenta potrafi trawić kamienie i minerały."
	quality = POSITIVE
	instability = 5
	text_gain_indication = "<span class='notice'>Masz ochotę na kamienie.</span>"
	text_lose_indication = "<span class='notice'>Zjadłbyś coś normalnego.</span>"
	difficulty = 12
	mutation_traits = list(TRAIT_ROCK_EATER)
	conflicts = list(/datum/mutation/rock_absorber)

// You eat rock but also get buffs from them
/datum/mutation/rock_absorber
	name = "Pochłaniacz kamieni"
	desc = "Organizm pacjenta potrafi trawić kamienie i minerały, a przy tym przejmuje ich właściwości."
	quality = POSITIVE
	instability = 35
	text_gain_indication = "<span class='notice'>Masz przemożną ochotę na kamienie.</span>"
	text_lose_indication = "<span class='notice'>Zjadłbyś coś normalnego.</span>"
	mutation_traits = list(TRAIT_ROCK_EATER, TRAIT_ROCK_METAMORPHIC)
	conflicts = list(/datum/mutation/rock_eater)
	locked = TRUE
