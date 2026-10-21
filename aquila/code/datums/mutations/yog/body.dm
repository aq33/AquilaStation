// AQUILA - port z Yogstation (code/datums/mutations/body.dm, radproof.dm, sapblood.dm, ravenous.dm)

// Radproof: odporność na promieniowanie kosztem gorszej tolerancji toksyn
/datum/mutation/radproof
	name = "Radproof"
	desc = "Adapts the host's body to be better suited at preventing cancer caused by radioactivity at the expense of it's ability to handle toxic matter."
	quality = POSITIVE
	text_gain_indication = "<span class='warning'>Nie czujesz tego w kościach!</span>"
	text_lose_indication = "<span class='notice'>Znów czujesz promieniowanie w kościach.</span>"
	instability = 35
	difficulty = 8
	mutation_traits = list(TRAIT_RADIMMUNE)

/datum/mutation/radproof/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
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
	name = "Thick skin"
	desc = "The user's skin acquires a leathery texture, and becomes more resilient to harm."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja skóra robi się sucha i ciężka.</span>"
	text_lose_indication = "<span class='notice'>Twoja skóra znów jest miękka...</span>"
	difficulty = 18
	instability = 30

/datum/mutation/thickskin/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
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
	name = "Hyperactive Bone Marrow"
	desc = "A mutation that stimulates the subject's bone marrow causes it to work three times faster than usual."
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
	name = "Bone Densification"
	desc = "A mutation that gives the subject a rare form of increased bone density, making their entire body slightly more resilient to low kinetic blows."
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
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor.melee += 5
	update_hardly_wounded()

/datum/mutation/densebones/modify()
	..()
	update_hardly_wounded()

/datum/mutation/densebones/on_losing(mob/living/carbon/owner)
	if(..())
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor.melee -= 5
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
	name = "Cerebral Neuroplasticity"
	desc = "A mutation that reorganizes the subject's brain, giving them more stamina while allowing for a slightly quicker recovery speed if exhausted."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Czujesz, jak twój mózg robi się wytrzymalszy.</span>"
	text_lose_indication = "<span class='notice'>Czujesz, jak twój mózg słabnie.</span>"
	instability = 70

/datum/mutation/cerebral/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
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
	name = "Sap blood"
	desc = "A mutation that causes the host's blood to thicken, almost like sap, bleeding less and coagulating faster."
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
		return
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
	name = "Ravenous"
	desc = "An inconvenient mutation that greatly increases the host's metabolism to the point of constant hunger."
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
