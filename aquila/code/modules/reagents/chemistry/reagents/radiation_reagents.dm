// Promieniowanie z BeeStation/BeeStation-Hornet#13442: leki i drinki, które wstrzymują skutki napromieniowania.
// W Bee robi to metabolized_traits; u nas cecha jest dodawana na czas metabolizmu.

/datum/reagent/proc/add_radiation_halt(mob/living/L)
	ADD_TRAIT(L, TRAIT_HALT_RADIATION_EFFECTS, REF(src))

/datum/reagent/proc/remove_radiation_halt(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_HALT_RADIATION_EFFECTS, REF(src))

/datum/reagent/medicine/potass_iodide/on_mob_metabolize(mob/living/L)
	. = ..()
	add_radiation_halt(L)

/datum/reagent/medicine/potass_iodide/on_mob_end_metabolize(mob/living/L)
	remove_radiation_halt(L)
	return ..()

/datum/reagent/medicine/pen_acid/on_mob_metabolize(mob/living/L)
	. = ..()
	add_radiation_halt(L)

/datum/reagent/medicine/pen_acid/on_mob_end_metabolize(mob/living/L)
	remove_radiation_halt(L)
	return ..()

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_metabolize(mob/living/L)
	. = ..()
	add_radiation_halt(L)

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_end_metabolize(mob/living/L)
	remove_radiation_halt(L)
	return ..()

/datum/reagent/medicine/radioactive_disinfectant/on_mob_metabolize(mob/living/L)
	. = ..()
	add_radiation_halt(L)

/datum/reagent/medicine/radioactive_disinfectant/on_mob_end_metabolize(mob/living/L)
	remove_radiation_halt(L)
	return ..()
