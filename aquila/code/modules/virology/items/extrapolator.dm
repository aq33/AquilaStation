// Ekstrapolator — dodatki z Monkestation2.0 (items/extrapolator.dm).
// Nasz ekstrapolator (code/game/objects/items/devices/scanners.dm) zostaje: skanuje nasze
// choroby advance i izoluje z nich objawy. Tutaj dokładamy tryb sondy z disease2:
// na człowieku odpala minigrę symptom crackera, a na szalce/chorym pozwala wszczepić
// warient objawu przez okno Extrapolator.

/mob/living/carbon/human/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(!created_symptoms)
		create_symptoms()
		created_symptoms = TRUE
	return ..()

/obj/item/extrapolator
	/// Cel ostatniego kliknięcia sondą — czyta go okno TGUI.
	var/atom/last_attacked_target
	/// Ostatnio zeskanowany żywy cel (do ponownego użycia bez klikania).
	var/datum/weakref/user_data

/obj/item/extrapolator/Destroy()
	user_data = null
	last_attacked_target = null
	return ..()

/obj/item/extrapolator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && isliving(target) && target != user)
		user_data = WEAKREF(target)
	if(proximity_flag && !scan)
		try_disease_modification(user, target)
		return
	return ..()

/obj/item/extrapolator/proc/try_disease_modification(mob/user, atom/target)
	if(!isliving(target) && !isvirusdish(target))
		return

	if(isvirusdish(target))
		var/obj/item/weapon/virusdish/dish = target
		if(!dish.contained_virus)
			to_chat(user, "<span class='warning'>Szalka jest pusta.</span>")
			return

	last_attacked_target = target
	ui_interact(user)

/obj/item/extrapolator/proc/try_symptom_change(mob/user, datum/weakref/choice_ref, datum/symptom_varient/new_varient, datum/weakref/symptom_ref)
	var/datum/symptom/acute/symptom = symptom_ref?.resolve()
	if(!symptom || !new_varient)
		return
	var/datum/disease/choice = choice_ref?.resolve()

	if(symptom.attached_varient)
		to_chat(user, "<span class='warning'>[src] brzęczy: ten objaw już jest szczepem wariantowym.</span>")
		return

	symptom.attached_varient = new new_varient(symptom, choice)
	symptom.update_name()

/obj/item/extrapolator/proc/generate_varient()
	var/list/weighted_list = list()
	for(var/datum/symptom_varient/varient as anything in subtypesof(/datum/symptom_varient))
		var/weight = initial(varient.weight)
		if(weight > 0)
			weighted_list[varient] = weight
	if(!length(weighted_list))
		return null
	return pickweight(weighted_list)

/obj/item/extrapolator/ui_interact(mob/user, datum/tgui/ui = null)
	. = ..()
	if(!last_attacked_target)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Extrapolator")
		ui.open()

/obj/item/extrapolator/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/extrapolator/ui_data(mob/user)
	var/list/data = list()
	var/list/diseases = list()

	if(isvirusdish(last_attacked_target))
		var/obj/item/weapon/virusdish/dish = last_attacked_target
		if(dish.contained_virus)
			diseases += list(disease_entry(dish.contained_virus))
	else if(isliving(last_attacked_target))
		var/mob/living/target = last_attacked_target
		for(var/datum/disease/acute/disease in target.diseases)
			if(istype(disease))
				diseases += list(disease_entry(disease))

	data["diseases"] = diseases
	data["varients"] = list()
	return data

/obj/item/extrapolator/proc/disease_entry(datum/disease/acute/disease)
	var/list/symptom_data = list()
	for(var/datum/symptom/acute/symptom as anything in disease.symptoms)
		symptom_data += list(list("name" = symptom.name, "ref" = REF(symptom)))
	return list("name" = disease.name(), "ref" = REF(disease), "symptoms" = symptom_data)

/obj/item/extrapolator/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("add_varient")
			var/datum/symptom_varient/new_varient = generate_varient()
			var/datum/weakref/disease_ref = WEAKREF(locate(params["disease_ref"]))
			var/datum/weakref/symptom_ref = WEAKREF(locate(params["symptom_ref"]))
			try_symptom_change(usr, disease_ref, new_varient, symptom_ref)
			return TRUE
