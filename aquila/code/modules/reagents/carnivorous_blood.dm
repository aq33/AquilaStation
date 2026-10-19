// AQUILA - mięsożerna krew, chemikalium zdrajców (port z tgstation#95915)
// Zmieszana z krwią ofiary uczy się jej DNA (do trzech osób), a we krwi żre ją trzy razy szybciej.

/datum/reagent/toxin/carnivorousblood
	name = "Carnivorous Blood"
	description = "Opracowany przez Interdyne środek biologiczny, który pożera każdą krew podobną do tej, na której go wytrenowano."
	color = "#C80000"
	toxpwr = 0
	taste_description = "gazowana krew"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	chem_flags = CHEMICAL_NOT_SYNTH
	self_consuming = TRUE
	/// Do trzech unikalnych enzymów DNA, na których wytrenowano krew
	data = list()

/datum/reagent/toxin/carnivorousblood/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	. = ..()
	// Odparowanie zabija żywe organizmy
	if(method == VAPOR)
		data = list()

/datum/reagent/toxin/carnivorousblood/on_mob_life(mob/living/carbon/affected_mob)
	if(!affected_mob.blood_volume || !affected_mob.get_blood_id())
		affected_mob.reagents.remove_reagent(type, volume)
		return
	var/multiplier = 1
	if(affected_mob.stat == DEAD)
		multiplier *= 2
	if(affected_mob.dna && (affected_mob.dna.unique_enzymes in data))
		multiplier *= 3
	affected_mob.blood_volume = max(affected_mob.blood_volume - 4 * multiplier, 0)
	if(prob(20))
		to_chat(affected_mob, "<span class='danger'>Krew wije się w twoich żyłach!</span>")
		if(prob(25))
			affected_mob.emote("scream")
	return ..()

/datum/reagent/toxin/carnivorousblood/on_merge(list/mix_data, amount)
	. = ..()
	feed_dna_list(mix_data)

// Wlana do pojemnika z krwią od razu uczy się jej DNA, zanim ją zje
/datum/reagent/toxin/carnivorousblood/on_new(list/new_data)
	. = ..()
	if(!holder)
		return
	for(var/datum/reagent/blood/blood in holder.reagent_list)
		if(islist(blood.data) && blood.data["blood_DNA"])
			feed_dna_list(list(blood.data["blood_DNA"]))

/// Dopisuje nowe DNA, najwyżej trzy różne
/datum/reagent/toxin/carnivorousblood/proc/feed_dna_list(list/adding_list)
	if(!islist(data))
		data = list()
	for(var/dna in adding_list)
		if(length(data) >= 3)
			return
		if(!istext(dna) || (dna in data))
			continue
		data += dna

// Krew trafiająca do pojemnika z mięsożerną krwią uczy ją swojego DNA, zanim zostanie zjedzona
/datum/reagent/blood/on_new(list/data)
	. = ..()
	feed_carnivorous_blood(data)

/datum/reagent/blood/on_merge(list/mix_data, amount)
	. = ..()
	feed_carnivorous_blood(mix_data)

/datum/reagent/blood/proc/feed_carnivorous_blood(list/blood_data)
	if(!holder || !islist(blood_data) || !blood_data["blood_DNA"])
		return
	var/datum/reagent/toxin/carnivorousblood/hungry_blood = holder.has_reagent(/datum/reagent/toxin/carnivorousblood)
	hungry_blood?.feed_dna_list(list(blood_data["blood_DNA"]))

// Mięsożerna krew zjada zwykłą krew, ucząc się jej DNA (w on_new/on_merge krwi). Jako katalizator,
// żeby nie zniknęła z pojemnika razem z wyuczonym DNA.
/datum/chemical_reaction/pair_carnivorous_blood
	results = list()
	required_reagents = list(/datum/reagent/blood = 1)
	required_catalysts = list(/datum/reagent/toxin/carnivorousblood = 1)
	mix_message = "Mieszanina skacze i chlupocze."

/datum/chemical_reaction/feed_carnivorous_blood
	results = list(/datum/reagent/toxin/carnivorousblood = 1)
	required_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	required_catalysts = list(/datum/reagent/toxin/carnivorousblood = 1)
	mix_message = "Krew łapczywie pożera białko."

/obj/item/reagent_containers/glass/bottle/carnivorous_blood
	name = "butelka mięsożernej krwi"
	desc = "Mała butelka. Zawiera mięsożerną krew."
	list_reagents = list(/datum/reagent/toxin/carnivorousblood = 30)

/obj/item/storage/box/syndie_kit/carnivorous_blood
	name = "zestaw mięsożernej krwi"

/obj/item/storage/box/syndie_kit/carnivorous_blood/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/carnivorous_blood(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/food/meat/slab/human(src)

/datum/uplink_item/stealthy_weapons/carnivorous_blood
	name = "Carnivorous Blood"
	desc = "Butelka mięsożernej krwi, broni biologicznej Interdyne. Zmieszana z krwią ofiary i wprowadzona do jej krwiobiegu \
		szybko pożera jej zapas krwi. Karm ją mięsem bogatym w białko, żeby się namnażała."
	item = /obj/item/storage/box/syndie_kit/carnivorous_blood
	cost = 3
	surplus = 50
