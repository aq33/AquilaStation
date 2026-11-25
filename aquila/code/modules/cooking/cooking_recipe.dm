/// Typ naczynia => lista przepisów krokowych, które się w nim zaczynają
GLOBAL_LIST_EMPTY(cooking_recipes_by_container)
/// Kategoria => lista wpisów przepisów krokowych dla Książki kucharskiej
GLOBAL_LIST_EMPTY(cooking_cookbook_lookup)

/**
 * Przepis krokowy: lista kroków od pierwszego składnika do gotowego dania w jednym naczyniu.
 * Przepisy i kroki są singletonami tworzonymi przy starcie, gotowanie nigdy ich nie zmienia.
 */
/datum/cooking/recipe
	/// Typ naczynia, w którym robi się przepis
	var/obj/item/reagent_containers/cooking/container_type
	/// Typ powstającego dania
	var/product_type
	/// Ile sztuk powstaje
	var/product_count = 1
	/// Zamiast przedmiotu: odczynnik w naczyniu (np. sos)
	var/reagent_type
	var/reagent_amount
	/// Czy danie dostaje tylko odczynniki ze składników (bez własnych z definicji)
	var/replace_reagents = FALSE
	/// Kategoria w Książce kucharskiej
	var/catalog_category = COOK_CATEGORY_MISC
	var/appear_in_default_catalog = TRUE
	/// Lista [/datum/cooking/recipe_step]
	var/list/steps

/// Nazwa dania albo odczynnika, który powstaje
/datum/cooking/recipe/proc/product_name()
	if(product_type)
		var/atom/product = product_type
		return initial(product.name)
	var/datum/reagent/reagent = reagent_type
	return initial(reagent.name)

/// Indeks pierwszego zaliczonego kroku z odczynnikiem, którego w naczyniu już nie ma w potrzebnej ilości (0 = wszystko jest)
/datum/cooking/recipe/proc/first_missing_reagent_step(obj/item/reagent_containers/cooking/container, list/applied_steps)
	var/list/needed = list()
	for(var/index in 1 to length(steps))
		var/datum/cooking/recipe_step/add_reagent/reagent_step = steps[index]
		if(!istype(reagent_step) || reagent_step.optional || !(index in applied_steps))
			continue
		needed[reagent_step.reagent_type] += reagent_step.amount
		if(!container.reagents.has_reagent(reagent_step.reagent_type, needed[reagent_step.reagent_type] - 0.01))
			return index
	return 0

/// Tworzy danie. Zwraca utworzony przedmiot (albo null, gdy wynikiem jest odczynnik).
/datum/cooking/recipe/proc/create_product(datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = tracker.container
	if(!istype(container))
		return

	var/datum/reagents/slurry = new(1000000)
	slurry.my_atom = container

	var/list/applied_steps = tracker.recipes_all_applied_steps[src]
	var/quality = 0
	for(var/list/applied_step_data as anything in tracker.recipes_applied_step_data)
		if(applied_step_data["reagent_type"])
			var/amount_to_remove = applied_step_data["amount"] * (1 - applied_step_data["reagent_remain_percent"])
			if(amount_to_remove)
				container.reagents.remove_reagent(applied_step_data["reagent_type"], amount_to_remove)
		quality += applied_step_data["quality"] || 0
	for(var/index in applied_steps)
		var/datum/cooking/recipe_step/recipe_step = steps[index]
		if(recipe_step.optional)
			quality += 1
	quality -= tracker.penalty

	if(product_type)
		. = make_product_item(container, slurry, applied_steps, quality, tracker.cook_mind)
	else
		QDEL_LIST(container.contents)

	container.reagents.clear_reagents()
	if(reagent_type)
		container.reagents.add_reagent(reagent_type, reagent_amount)
	qdel(slurry)

/datum/cooking/recipe/proc/make_product_item(obj/item/reagent_containers/cooking/container, datum/reagents/slurry, list/applied_steps, quality, cook_mind)
	if(container.reagents.total_volume)
		container.reagents.trans_to(slurry, container.reagents.total_volume)

	// Odczynniki ze składników (bez odżywki, którą danie ma już we własnej definicji)
	for(var/obj/item/added_item in container.contents)
		var/can_add = TRUE
		var/list/exclude_specific_reagents = list()
		for(var/index in applied_steps)
			var/datum/cooking/recipe_step/recipe_step = steps[index]
			var/datum/cooking/recipe_step/add_item/add_step = recipe_step
			if(!istype(add_step))
				continue
			if(add_step.exclude_reagents)
				exclude_specific_reagents |= add_step.exclude_reagents
			if(add_step.skip_reagents)
				can_add = FALSE
				break
		if(can_add && added_item.reagents)
			for(var/reagent_path in exclude_specific_reagents)
				added_item.reagents.remove_reagent(reagent_path, added_item.reagents.get_reagent_amount(reagent_path))
			added_item.reagents.trans_to(slurry, added_item.reagents.total_volume)

	QDEL_LIST(container.contents)

	for(var/i in 1 to product_count)
		var/obj/item/new_item = new product_type(container)
		. = new_item
		if(replace_reagents)
			new_item.reagents?.clear_reagents()
		if(new_item.reagents)
			slurry.copy_to(new_item, slurry.total_volume / product_count)
		apply_cooking_quality(new_item, quality)
		if(cook_mind)
			ADD_TRAIT(new_item, TRAIT_FOOD_CHEF_MADE, cook_mind)

/// Wpisuje jakość do dania: lepsza = wyższa złożoność (mocniejsze bonusy i nastrój), zła = zepsuty żołądek
/proc/apply_cooking_quality(obj/item/new_item, quality)
	var/obj/item/food/food = new_item
	if(!istype(food))
		return
	if(quality < 0)
		food.reagents?.add_reagent(/datum/reagent/toxin/bad_food, 5)
		food.desc += " Wygląda na przyrządzone byle jak."
		food.cooking_quality = -1
	else if(quality >= 3)
		food.crafting_complexity = min(food.crafting_complexity + 2, FOOD_COMPLEXITY_5)
		food.desc += " Przyrządzone znakomicie."
		food.cooking_quality = 2
	else if(quality >= 1)
		food.crafting_complexity = min(food.crafting_complexity + 1, FOOD_COMPLEXITY_5)
		food.desc += " Dobrze przyrządzone."
		food.cooking_quality = 1

/// Jakość dania z gotowania krok po kroku: -1 złe, 0 zwykłe, 1 dobre, 2 znakomite
/obj/item/food/var/cooking_quality = 0

/proc/initialize_cooking_recipes()
	GLOB.cooking_recipes_by_container.Cut()
	GLOB.cooking_cookbook_lookup.Cut()
	for(var/path in subtypesof(/datum/cooking/recipe))
		var/datum/cooking/recipe/recipe = new path()
		if(!recipe.container_type || !length(recipe.steps))
			continue
		LAZYADD(GLOB.cooking_recipes_by_container[recipe.container_type], recipe)
		if(!recipe.appear_in_default_catalog || !(recipe.product_type || recipe.reagent_type))
			continue
		var/obj/item/reagent_containers/cooking/container_type = recipe.container_type
		var/list/entry = list()
		entry["name"] = recipe.product_name()
		entry["path"] = "[recipe.product_type || recipe.reagent_type]"
		entry["recipe"] = "[path]"
		entry["container"] = "[initial(container_type.preposition)] [initial(container_type.where_name)]"
		entry["instructions"] = list()
		for(var/datum/cooking/recipe_step/recipe_step as anything in recipe.steps)
			entry["instructions"] += "[recipe_step.get_pda_formatted_desc()][recipe_step.optional ? " (dodatkowo, poprawia jakość)" : ""]"
		LAZYADD(GLOB.cooking_cookbook_lookup[recipe.catalog_category], list(entry))

/// Przepisy dla danego typu naczynia (pierwsze wywołanie ładuje wszystkie przepisy)
/proc/cooking_recipes_for(container_type)
	if(!length(GLOB.cooking_recipes_by_container))
		initialize_cooking_recipes()
	return GLOB.cooking_recipes_by_container[container_type]

/// Dania (typy), które robi się krok po kroku; bez tworzenia przepisów, więc można wołać przy starcie świata
/proc/cooking_step_products()
	var/static/list/products
	if(!products)
		products = list()
		for(var/datum/cooking/recipe/recipe_type as anything in subtypesof(/datum/cooking/recipe))
			var/product = initial(recipe_type.product_type)
			if(product)
				products[product] = TRUE
	return products

/// Czy danie (albo jego upieczona wersja, gdy to surowa pizza) robi się krok po kroku
/proc/is_step_cooked(result_path)
	var/list/products = cooking_step_products()
	if(products[result_path])
		return TRUE
	var/text_path = "[result_path]"
	if(findtext(text_path, "/raw", -4))
		return !!products[text2path(copytext(text_path, 1, -4))]
	return FALSE

/// Przepisy krokowe dla Książki kucharskiej, w kategoriach
/proc/get_cooking_cookbook()
	if(!length(GLOB.cooking_recipes_by_container))
		initialize_cooking_recipes()
	return GLOB.cooking_cookbook_lookup

/// Restauracja robotów płaci więcej za dobrze przyrządzone danie (+25% za dobre, +50% za znakomite, -25% za złe)
/datum/venue/restaurant/get_order_price(obj/item/order_item, order)
	. = ..()
	var/obj/item/food/food = order_item
	if(istype(food) && food.cooking_quality)
		. = round(. * (1 + 0.25 * food.cooking_quality))
