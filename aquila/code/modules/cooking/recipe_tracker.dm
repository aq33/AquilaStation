/// Jedna próba wykonania kroku, tworzona tylko na czas sprawdzenia
/datum/cooking/step_attempt
	var/current_step_index
	var/datum/cooking/recipe/recipe
	var/datum/cooking/recipe_step/recipe_step

/datum/cooking/step_attempt/New(datum/cooking/recipe/recipe, datum/cooking/recipe_step/recipe_step, current_step_index)
	src.recipe = recipe
	src.recipe_step = recipe_step
	src.current_step_index = current_step_index

/**
 * Postęp naczynia względem wszystkich przepisów, które jeszcze pasują.
 *
 * Każdy użyty przedmiot (albo maszyna, na której stoi naczynie) jest sprawdzany z następnym krokiem każdego
 * pasującego przepisu (krok opcjonalny można pominąć). Przepisy, które przestają pasować, odpadają.
 * Gdy któryś przepis dojdzie do ostatniego kroku, powstaje danie.
 */
/datum/cooking/recipe_tracker
	var/obj/item/reagent_containers/cooking/container
	var/recipe_started = FALSE
	/// Przepis => indeks ostatniego wykonanego kroku
	var/list/recipes_last_completed_step = list()
	/// Przepis => lista indeksów wykonanych kroków
	var/list/recipes_all_applied_steps = list()
	/// Dane zwrócone przez wykonane kroki (komunikat, jakość, odczynnik)
	var/list/recipes_applied_step_data = list()
	var/step_reaction_message
	/// Kara do jakości (zdjęcie naczynia z ognia w trakcie kroku)
	var/penalty = 0
	/// REF() umysłu kucharza, żeby danie liczyło się jako zrobione przez niego
	var/cook_mind

/datum/cooking/recipe_tracker/New(obj/item/reagent_containers/cooking/container)
	src.container = container
	for(var/datum/cooking/recipe/recipe as anything in cooking_recipes_for(container.type))
		recipes_last_completed_step[recipe] = 0

/datum/cooking/recipe_tracker/Destroy(force)
	container = null
	recipes_last_completed_step.Cut()
	recipes_all_applied_steps.Cut()
	recipes_applied_step_data.Cut()
	return ..()

/// Czy któryś z pasujących przepisów czeka teraz na gotowanie na tym urządzeniu (wtedy danie się nie przypala)
/datum/cooking/recipe_tracker/proc/waiting_for_cooker(cooker_id)
	for(var/datum/cooking/recipe/recipe as anything in recipes_last_completed_step)
		var/index = recipes_last_completed_step[recipe]
		while(index < length(recipe.steps))
			index++
			var/datum/cooking/recipe_step/use_machine/machine_step = recipe.steps[index]
			if(istype(machine_step) && machine_step.cooker_id == cooker_id)
				return TRUE
			var/datum/cooking/recipe_step/any_step = recipe.steps[index]
			if(!any_step.optional)
				break
	return FALSE

/datum/cooking/recipe_tracker/proc/process_item(mob/user, obj/used)
	if(user?.mind && !cook_mind)
		cook_mind = REF(user.mind)
	var/list/completed_recipes = list()
	var/list/step_datas = list()
	var/list/step_attempts = list()
	var/completed_steps = 0

	for(var/datum/cooking/recipe/recipe as anything in recipes_last_completed_step)
		var/current_index = recipes_last_completed_step[recipe]
		while(current_index < length(recipe.steps))
			current_index++
			var/datum/cooking/recipe_step/next_step = recipe.steps[current_index]
			var/conditions_met = next_step.check_conditions_met(used, src)
			if(conditions_met == COOK_CHECK_VALID || conditions_met == COOK_CHECK_SILENT)
				step_attempts += new /datum/cooking/step_attempt(recipe, next_step, current_index)
			if(!next_step.optional)
				break

	if(!length(step_attempts))
		return COOK_NO_STEPS

	for(var/datum/cooking/step_attempt/step_attempt as anything in step_attempts)
		// Każdy rodzaj kroku wykonujemy raz (nie wrzucamy przedmiotu dwa razy), sprawdzamy wszystkie przepisy
		if(!(step_attempt.recipe_step.type in step_datas))
			var/step_data = step_attempt.recipe_step.follow_step(used, src, user)
			if(islist(step_data))
				step_datas[step_attempt.recipe_step.type] = step_data
				step_reaction_message = step_data["message"]

		var/previous_step = recipes_last_completed_step[step_attempt.recipe]
		if(step_attempt.recipe_step.is_complete(used, src, step_datas[step_attempt.recipe_step.type]))
			recipes_last_completed_step[step_attempt.recipe] = step_attempt.current_step_index
			LAZYOR(recipes_all_applied_steps[step_attempt.recipe], step_attempt.current_step_index)
			completed_steps++
			if(step_attempt.current_step_index == length(step_attempt.recipe.steps))
				completed_recipes |= step_attempt.recipe
		else
			recipes_last_completed_step[step_attempt.recipe] = previous_step

	if(!completed_steps)
		return COOK_PARTIAL_SUCCESS

	recipe_started = TRUE
	var/list/first_applied_step_data = length(step_datas) ? step_datas[step_datas[1]] : list()
	recipes_applied_step_data += list(first_applied_step_data)
	// Czas gotowania liczy się od nowa do następnego kroku, żeby nie gotować „na zapas”
	container.clear_cooking_data()
	if(first_applied_step_data["signal"])
		SEND_SIGNAL(container, first_applied_step_data["signal"])

	if(length(completed_recipes))
		var/datum/cooking/recipe/recipe_to_complete = completed_recipes[1]
		var/atom/result = recipe_to_complete.create_product(src)
		if(user && result && user.Adjacent(container))
			to_chat(user, span_notice("Gotowe: [result]!"))
		return COOK_COMPLETE

	// Przepisy, które mają mniej wykonanych kroków niż już zrobiliśmy, odpadają
	var/completed_step_count = length(recipes_applied_step_data)
	for(var/recipe in recipes_last_completed_step.Copy())
		if(!(recipe in recipes_all_applied_steps) || length(recipes_all_applied_steps[recipe]) < completed_step_count)
			recipes_last_completed_step -= recipe

	return COOK_SUCCESS
