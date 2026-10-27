/datum/symptom/acute/adaptation
	name = "Inorganic Biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate."
	max_count = 1
	stage = 4
	badness = EFFECT_DANGER_FLAVOR
	severity = 0
	var/list/biotypes = list(MOB_ROBOTIC)

/datum/symptom/acute/adaptation/OnAdd(datum/disease/acute/disease)
	disease.infectable_biotypes |= biotypes

/datum/symptom/acute/adaptation/OnRemove(datum/disease/acute/disease)
	disease.infectable_biotypes -= biotypes

/datum/symptom/acute/adaptation/undead
	name = "Necrotic Metabolism"
	desc = "The virus is able to thrive and act even within dead hosts."
	biotypes = list(MOB_UNDEAD)
	severity = 1

/datum/symptom/acute/adaptation/undead/OnAdd(datum/disease/acute/disease)
	. = ..()
	disease.process_dead = TRUE

/datum/symptom/acute/adaptation/undead/OnRemove(datum/disease/acute/disease)
	disease.process_dead = FALSE
	return ..()
