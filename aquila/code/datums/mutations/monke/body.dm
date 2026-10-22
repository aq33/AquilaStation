// AQUILA - port z Monkestation2.0 (code/datums/mutations/body.dm)

/datum/mutation/no_fingerprints
	name = "Invisible Fingerprints"
	desc = "Subjects finger tips melt into a singular smooth structure, causing their fingerprints to be impossible to detect."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Drętwieją ci opuszki palców.</span>"
	text_lose_indication = "<span class='notice'>Opuszki palców przestają drętwieć.</span>"
	instability = 10
	mutation_traits = list(TRAIT_NO_FINGERPRINTS)

/datum/mutation/bloodyhell
	name = "Polycythemia"
	desc = "A mutation that stimulates the subjects bone marrow's blood production capability and removes the subject's bone marrow's usual safeties against overproducing blood."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Przez chwilę czujesz ból w sercu, które zaczyna bić szybciej.</span>"
	text_lose_indication = "<span class='notice'>Serce zwalnia do zwykłego tempa.</span>"
	instability = 15
	conflicts = list(/datum/mutation/anemia)
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/bloodyhell/on_life()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H) || H.stat == DEAD || HAS_TRAIT(H, TRAIT_NO_BLOOD) || (NOBLOOD in H.dna.species.species_traits))
		return
	if(H.blood_volume > (BLOOD_VOLUME_NORMAL * 1.4))
		// Normalnie nadmiar krwi nic nie robi, więc tu są skutki uboczne
		var/blood_difference = (H.blood_volume / BLOOD_VOLUME_MAXIMUM) * 100
		if(MONKE_SPT_PROB(blood_difference, MONKE_LIFE_SECONDS))
			if(prob(20))
				to_chat(H, "<span class='warning'>Czujesz się wzdęty.</span>")
			H.adjustOxyLoss(round(blood_difference / 20))
	if(H.blood_volume < BLOOD_VOLUME_MAXIMUM)
		H.blood_volume = min(H.blood_volume + 2 * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src) * MONKE_LIFE_SECONDS, BLOOD_VOLUME_MAXIMUM)

/datum/mutation/anemia
	name = "Anemia"
	desc = "This mutation causes damage to the oxygen carrying properties of blood cells to a high degree in the subject."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Przez chwilę kręci ci się w głowie.</span>"
	instability = 10
	conflicts = list(/datum/mutation/bloodyhell)
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/anemia/on_life()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H) || H.stat == DEAD || HAS_TRAIT(H, TRAIT_NO_BLOOD) || (NOBLOOD in H.dna.species.species_traits))
		return
	if(H.blood_volume > BLOOD_VOLUME_SAFE - (75 * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src)))
		H.blood_volume -= MONKE_LIFE_SECONDS

/datum/mutation/fat
	name = "Obesity"
	desc = "A strange mutation that forces the body to rapidly produce lipid tissue."
	quality = NEGATIVE
	text_gain_indication = "<span class='notice'>Czujesz się tłusty i ociężały!</span>"
	text_lose_indication = "<span class='notice'>Czujesz się wysportowany!</span>"

/datum/mutation/fat/on_life()
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_NOHUNGER))
		return
	if(owner.nutrition <= NUTRITION_LEVEL_FAT)
		owner.nutrition += 25 * MONKE_LIFE_SECONDS

/datum/mutation/dizzy
	name = "Dizzy"
	desc = "Causes the subjects cerebellum to shut down in certain places causing dizzyness."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>Nagle zaczyna ci się mocno kręcić w głowie...</span>"
	text_lose_indication = "<span class='notice'>Odzyskujesz równowagę.</span>"
	instability = 15
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/dizzy/on_life()
	if(!MONKE_SPT_PROB(2.5 / GET_MUTATION_ENERGY(src), MONKE_LIFE_SECONDS))
		return
	to_chat(owner, "<span class='warning'>[pick("Kręci ci się w głowie.", "Wszystko wokół wiruje.")]</span>")
	// tg adjust_dizzy_up_to(1 minuta * sync * moc, 3 minuty)
	var/max_dizzy = MONKE_TIME_TO_LIFE_TICKS(3 MINUTES)
	if(owner.dizziness < max_dizzy)
		owner.dizziness = min(owner.dizziness + MONKE_TIME_TO_LIFE_TICKS(1 MINUTES * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src)), max_dizzy)

/datum/mutation/ear_cancer
	name = "Tinnitus"
	desc = "Causes the subjects to constantly hear a ringing noise."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='warning'>Zaczyna ci dzwonić w uszach.</span>"
	text_lose_indication = "<span class='notice'>Dzwonienie w uszach ustaje.</span>"
	instability = 5
	synchronizer_coeff = 1

/datum/mutation/ear_cancer/on_life()
	var/obj/item/organ/ears/ears = owner.getorganslot(ORGAN_SLOT_EARS) // wyrwij je, żeby przestało dzwonić
	if(ears && MONKE_SPT_PROB(5 * GET_MUTATION_SYNCHRONIZER(src), MONKE_LIFE_SECONDS))
		to_chat(owner, "<span class='warning'>Zaczyna ci dzwonić w uszach!</span>")
		SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg', 0, 1, 0, 250))
