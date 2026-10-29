/obj/item/food/pancakes
	name = "naleśnik"
	desc = "Puszysty naleśnik. Miększy i lepszy krewny gofra."
	icon_state = "pancakes_1"
	item_state = "pancakes"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("naleśniki" = 1)
	foodtypes = GRAIN | SUGAR | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	///Used as a base name while generating the icon states when stacked
	var/stack_name = "pancakes"
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pancakes/blueberry
	name = "naleśnik z borówkami"
	desc = "Puszysty i pyszny naleśnik z borówkami."
	icon_state = "bbpancakes_1"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("naleśniki" = 1, "borówki" = 1)
	stack_name = "bbpancakes"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pancakes/chocolatechip
	name = "naleśnik z kawałkami czekolady"
	desc = "Puszysty i pyszny naleśnik z kawałkami czekolady."
	icon_state = "ccpancakes_1"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("naleśniki" = 1, "czekolada" = 1)
	stack_name = "ccpancakes"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pancakes/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/food/pancakes/update_name()
	name = contents.len ? "stos naleśników" : initial(name)
	return ..()

/obj/item/food/pancakes/update_icon(updates = ALL)
	if(!(updates & UPDATE_OVERLAYS))
		return ..()

	updates &= ~UPDATE_OVERLAYS
	. = ..() // Don't update overlays. We're doing that here

	if(contents.len < LAZYLEN(overlays))
		overlays-=overlays[overlays.len]
	. |= UPDATE_OVERLAYS

/obj/item/food/pancakes/examine(mob/user)
	var/ingredients_listed = ""
	var/pancakeCount = contents.len
	switch(pancakeCount)
		if(0)
			desc = initial(desc)
		if(1 to 2)
			desc = "Stos puszystych naleśników."
		if(3 to 6)
			desc = "Gruby stos puszystych naleśników!"
		if(7 to 9)
			desc = "Wielka wieża puszystych, pysznych naleśników!"
		if(10 to INFINITY)
			desc = "Ogromna, strzelista iglica puszystych, pysznych naleśników. Wygląda, jakby mogła się przewrócić!"
	. = ..()
	if (pancakeCount)
		for(var/obj/item/food/pancakes/ING in contents)
			ingredients_listed += "[ING.name], "
		. += "Zawiera [contents.len?"[ingredients_listed]":"brak dodatków, "]na [initial(name)]."

/obj/item/food/pancakes/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/food/pancakes))
		var/obj/item/food/pancakes/pancake = item
		if(!user.transferItemToLoc(pancake, src))
			return
		to_chat(user, "<span class='notice'>Dodajesz [pancake] do [src].</span>")
		pancake.name = initial(pancake.name)
		contents += pancake
		update_snack_overlays(pancake)
		if (pancake.contents.len)
			for(var/pancake_content in pancake.contents)
				pancake = pancake_content
				pancake.name = initial(pancake.name)
				contents += pancake
				update_snack_overlays(pancake)
		pancake = item
		pancake.contents.Cut()
		return
	else if(contents.len)
		var/obj/O = contents[contents.len]
		return O.attackby(item, user, params)
	..()

/obj/item/food/pancakes/proc/update_snack_overlays(obj/item/food/pancakes/pancake)
	var/mutable_appearance/pancake_visual = mutable_appearance(icon, "[pancake.stack_name]_[rand(1, 3)]")
	pancake_visual.pixel_x = rand(-1, 1)
	pancake_visual.pixel_y = 3 * contents.len - 1
	add_overlay(pancake_visual)
	update_appearance()

/obj/item/food/pancakes/attack(mob/target, mob/living/user, params, stacked = TRUE)
	if(user.combat_mode || !contents.len || !stacked)
		return ..()
	var/obj/item/item = contents[contents.len]
	. = item.attack(target, user, params, FALSE)
	update_appearance()
