// AQUILA - odczynniki przyspieszające operacje w nowym szkielecie (tg: add_surgery_speed_mod w reaction_mob).
// Stare wersje zmieniają speed_modifier trwających /datum/surgery i zostają, dopóki stary szkielet nie zniknie.
// Wartości i czas działania jak w tg: mnożnik czasu na pacjencie, min(objętość * 1 min, 5 min).

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/carbon/C, method = TOUCH, reac_volume)
	. = ..()
	if(isliving(C) && (method in list(TOUCH, VAPOR, PATCH)))
		C.add_surgery_speed_mod(type, 0.8, min(reac_volume * 1 MINUTES, 5 MINUTES))

/datum/reagent/consumable/honey/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	. = ..()
	if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
		M.add_surgery_speed_mod(type, 0.6, min(reac_volume * 1 MINUTES, 5 MINUTES))

/datum/reagent/medicine/mine_salve/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1)
	. = ..()
	if(iscarbon(M) && M.stat != DEAD && !(method in list(INGEST, VAPOR, INJECT)))
		M.add_surgery_speed_mod(type, 0.9, min(reac_volume * 1 MINUTES, 5 MINUTES))

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	. = ..()
	if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
		M.add_surgery_speed_mod("alcohol", round(1 - (boozepwr / 650), 0.05), min(reac_volume * 1 MINUTES, 5 MINUTES)) // słaby alkohol słabiej odkaża
