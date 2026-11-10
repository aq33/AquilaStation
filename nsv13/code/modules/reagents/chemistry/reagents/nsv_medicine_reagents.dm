/datum/reagent/medicine/radioactive_disinfectant
	name = "Radioaktywny środek dezynfekujący"
	description = "Usuwa napromieniowanie u syntetyków."
	color = "#806F42"
	taste_description = "metal"
	process_flags = SYNTHETIC

/datum/reagent/medicine/radioactive_disinfectant/on_mob_life(mob/living/carbon/M)
	// Reskinned potassium iodide for synthetics
	// AQ EDIT START - promieniowanie z Bee#13442: jak jodek potasu
	var/datum/component/irradiated/irradiated_component = M.GetComponent(/datum/component/irradiated)
	if(irradiated_component)
		irradiated_component.adjust_intensity(-1)
		M.adjustToxLoss(-1 * REM, 0)
		. = TRUE
	// AQ EDIT END
	..()
