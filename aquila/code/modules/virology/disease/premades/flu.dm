/datum/disease/acute/premade/cold
	name = "Common Cold"
	form = "Viral Infection"
	category = DISEASE_COLD

	symptoms = list(
		new /datum/symptom/acute/cough,
		new /datum/symptom/acute/sneeze,
		new /datum/symptom/acute/fridge,
	)
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	robustness = 45

	infectionchance = 70
	infectionchance_base = 86
	can_kill = list("Bacteria")
