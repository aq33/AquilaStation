// AQUILA - port z Yogstation (code/datums/mutations/body.dm, radproof.dm, sapblood.dm, ravenous.dm)

// Radproof: odporność na promieniowanie kosztem gorszej tolerancji toksyn
/datum/mutation/radproof
	name = "Odporność na promieniowanie"
	desc = "Przystosowuje organizm nosiciela do zapobiegania nowotworom wywołanym promieniowaniem kosztem gorszego radzenia sobie z toksynami."
	quality = POSITIVE
	text_gain_indication = "<span class='warning'>Nie czujesz tego w kościach!</span>"
	text_lose_indication = "<span class='notice'>Znów czujesz promieniowanie w kościach.</span>"
	instability = 35
	difficulty = 8
	mutation_traits = list(TRAIT_RADIMMUNE)

/datum/mutation/radproof/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.tox_mod *= 1.5

/datum/mutation/radproof/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.tox_mod /= 1.5

// Thick skin: mniej obrażeń fizycznych i od poparzeń
/datum/mutation/thickskin
	name = "Gruba skóra"
	desc = "Skóra nosiciela staje się skórzasta i odporniejsza na obrażenia."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja skóra robi się sucha i ciężka.</span>"
	text_lose_indication = "<span class='notice'>Twoja skóra znów jest miękka...</span>"
	difficulty = 18
	instability = 30

/datum/mutation/thickskin/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 0.8
		H.physiology.burn_mod *= 0.9

/datum/mutation/thickskin/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod /= 0.8
		H.physiology.burn_mod /= 0.9

// Hyperactive Bone Marrow: szybciej odnawia krew, kosztem głodu
/datum/mutation/hypermarrow
	name = "Nadaktywny szpik kostny"
	desc = "Mutacja, która pobudza szpik kostny pacjenta do pracy trzy razy szybszej niż zwykle."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Przez chwilę bolą cię kości.</span>"
	text_lose_indication = "<span class='notice'>Coś w twoich kościach się uspokaja.</span>"
	difficulty = 12
	instability = 20
	power_coeff = 1

/datum/mutation/hypermarrow/on_life()
	if(HAS_TRAIT(owner, TRAIT_NO_BLOOD) || HAS_TRAIT(owner, TRAIT_HUSK))
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(NOBLOOD in H.dna.species.species_traits)
			return // nie ma szpiku, który robiłby krew
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(BLOOD_VOLUME_NORMAL, owner.blood_volume + GET_MUTATION_POWER(src) * 2 - 1)
		owner.adjust_nutrition(-(GET_MUTATION_POWER(src) * 2 - 0.8) * HUNGER_FACTOR)

// Bone Densification: trochę pancerza przeciw ciosom i mniej ran
/datum/mutation/densebones
	name = "Zagęszczenie kości"
	desc = "Mutacja, która daje pacjentowi rzadką postać zwiększonej gęstości kości, przez co całe jego ciało lepiej znosi słabe uderzenia."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Czujesz, jak twoje kości gęstnieją.</span>"
	text_lose_indication = "<span class='notice'>Czujesz, jak twoje kości lżeją.</span>"
	difficulty = 16
	instability = 25
	power_coeff = 1
	mutation_traits = list(TRAIT_YOG_DENSE_BONES)
	/// Czy daliśmy TRAIT_HARDLY_WOUNDED (chromosom mocy)
	var/hardly_wounded = FALSE

/datum/mutation/densebones/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor = H.physiology.armor.modifyRating(melee = 5)
	update_hardly_wounded()

/datum/mutation/densebones/modify()
	..()
	update_hardly_wounded()

/datum/mutation/densebones/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor = H.physiology.armor.modifyRating(melee = -5)
	if(hardly_wounded)
		REMOVE_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)
		hardly_wounded = FALSE

/datum/mutation/densebones/proc/update_hardly_wounded()
	if(!owner || hardly_wounded || GET_MUTATION_POWER(src) <= 1)
		return
	ADD_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)
	hardly_wounded = TRUE

// Cerebral Neuroplasticity: mniej obrażeń wytrzymałości i krótsze ogłuszenia
/datum/mutation/cerebral
	name = "Neuroplastyczność mózgu"
	desc = "Mutacja, która przebudowuje mózg pacjenta. Daje mu więcej wytrzymałości i nieco szybszy powrót do sił po wyczerpaniu."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Czujesz, jak twój mózg robi się wytrzymalszy.</span>"
	text_lose_indication = "<span class='notice'>Czujesz, jak twój mózg słabnie.</span>"
	instability = 70

/datum/mutation/cerebral/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.stamina_mod *= 0.7
		H.physiology.stun_mod *= 0.85

/datum/mutation/cerebral/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.stamina_mod /= 0.7
		H.physiology.stun_mod /= 0.85

// Sap blood: gęsta krew, mniej krwawi i krwawienie szybciej się zatrzymuje
/datum/mutation/sapblood
	name = "Krew jak żywica"
	desc = "Mutacja, przez którą krew nosiciela gęstnieje niemal jak żywica. Mniej krwawi i szybciej krzepnie."
	quality = POSITIVE
	difficulty = 16
	locked = TRUE
	text_gain_indication = "<span class='notice'>Czujesz, jak gęstnieje ci krew w tętnicach!</span>"
	text_lose_indication = "<span class='notice'>Twoja krew znów płynie swobodnie.</span>"
	instability = 20
	/// O tyle co cykl życia spada krwawienie
	var/clot_rate = 0.2
	/// Mnożnik całego krwawienia
	var/passive_bleed_modifier = 0.6

/datum/mutation/sapblood/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.bleed_mod *= passive_bleed_modifier

/datum/mutation/sapblood/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.bleed_mod /= passive_bleed_modifier

/datum/mutation/sapblood/on_life()
	if(!owner.blood_volume || !owner.is_bleeding())
		return
	owner.cauterise_wounds(clot_rate)

// Ravenous: ciągły głód
/datum/mutation/ravenous
	name = "Wilczy głód"
	desc = "Uciążliwa mutacja, która tak przyspiesza metabolizm nosiciela, że ciągle jest głodny."
	quality = MINOR_NEGATIVE
	difficulty = 16
	locked = TRUE
	text_gain_indication = "<span class='notice'>Potrzebujesz więcej i więcej, i WIĘCEJ!</span>"
	text_lose_indication = "<span class='notice'>Na razie wystarczy.</span>"
	instability = 10
	mutation_traits = list(TRAIT_EAT_MORE, TRAIT_BOTTOMLESS_STOMACH, TRAIT_VORACIOUS)

// Przepisy

/datum/generecipe/cerebral
	required = "/datum/mutation/insulated; /datum/mutation/unintelligible"
	result = /datum/mutation/cerebral
