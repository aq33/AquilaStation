/datum/overmap_objective/cargo/donation/blood
	name = "Przekaż krew"
	desc = "Przekaż co najmniej jedną grupę krwi"
	var/list/possible_blood_types = list(
		"O-",
		"O+",
		"B-",
		"B+",
		"A-",
		"A+",
		"L",
		// We don't have enough ethereal or oozling players to donate blood if the ship does not spawn with any
		// "LE",
		// "OZ",
	)
	crate_name = "Skrzynia z workami krwi"

/datum/overmap_objective/cargo/donation/blood/New()
	var/datum/freight_type/single/reagent/blood/C = new( pick( possible_blood_types ) )
	freight_type_group = new( list( C ) )

