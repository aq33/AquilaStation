// AQUILA - kuźnia amunicji: galwanizer (na wzór electroplater z Monkestation).
// Pokrywa zwykłą amunicję z cargo materiałem z silosu: wyrób dostaje materiał i jego cechy, ale tylko klasę I i bez wypełnienia.
// Sprite: goonstation przez Monkestation (goon/icons/obj/matsci.dmi), CC BY-NC-SA 3.0.

/obj/machinery/munitions_forge/electroplater
	name = "galwanizer amunicji"
	desc = "Pokrywa zwykłą amunicję warstwą materiału z silosu. Pobiera go przez pobliski piec łukowy. Wychodzi klasa I bez wypełnienia, za połowę kosztu odlewu."
	icon = 'goon/icons/obj/matsci.dmi'
	icon_state = "plater0"
	circuit = /obj/item/circuitboard/machine/munitions_electroplater
	operation_time = 10 SECONDS
	operation_sound = 'sound/machines/hiss.ogg'
	/// Amunicja w środku
	var/obj/item/plated_item
	var/datum/munition_material/pending_material
	/// Mnożnik zużycia materiału
	var/efficiency = 1

/obj/machinery/munitions_forge/electroplater/Destroy()
	if(plated_item)
		plated_item.forceMove(drop_location())
		plated_item = null
	return ..()

/obj/machinery/munitions_forge/electroplater/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == plated_item)
		plated_item = null
		update_icon()

/obj/machinery/munitions_forge/electroplater/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		rating += B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating += M.rating
	// pojemnik i manipulator: 2-8
	efficiency = 1.1 - rating * 0.05
	operation_time = max(initial(operation_time) - (rating - 2) * 1 SECONDS, 4 SECONDS)

/obj/machinery/munitions_forge/electroplater/update_icon_state()
	icon_state = operating ? "plater1" : "plater0"
	return ..()

/obj/machinery/munitions_forge/electroplater/examine(mob/user)
	. = ..()
	if(plated_item)
		. += "<span class='notice'>W środku jest [plated_item]. Alt+klik, żeby wyjąć.</span>"
	if(!find_forge())
		. += "<span class='warning'>W pobliżu nie ma pieca łukowego.</span>"

/obj/machinery/munitions_forge/electroplater/proc/find_forge()
	for(var/obj/machinery/munitions_forge/arc_forge/forge in range(4, src))
		return forge

/// Ile jednostek materiału (przed mnożnikiem materiału) idzie na pokrycie, 0 = nie da się pokryć
/obj/machinery/munitions_forge/electroplater/proc/plating_amount(obj/item/I)
	var/body_type = GLOB.munition_products[I.type]
	if(!body_type)
		return 0
	var/obj/item/munition_part/body/body = body_type
	return initial(body.material_amount) * 0.5 * efficiency

/obj/machinery/munitions_forge/electroplater/attackby(obj/item/I, mob/living/user, params)
	if(GLOB.munition_products[I.type])
		if(operating)
			to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
			return TRUE
		if(get_forged_munition(I))
			to_chat(user, "<span class='warning'>[I] już ma właściwości z kuźni.</span>")
			return TRUE
		var/obj/item/ammo_box/box = I
		if(istype(box) && !length(box.stored_ammo))
			to_chat(user, "<span class='warning'>[I] jest puste.</span>")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		if(plated_item)
			user.put_in_hands(plated_item)
		plated_item = I
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
		update_icon()
		return TRUE
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ship_weapon))
		to_chat(user, "<span class='warning'>[src] nie pokryje [I]. Pasuje tylko amunicja, którą umie zrobić kuźnia.</span>")
		return TRUE
	return ..()

/obj/machinery/munitions_forge/electroplater/AltClick(mob/living/user)
	if(!user_can_reach(user))
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return
	if(!plated_item)
		to_chat(user, "<span class='notice'>W [src] nic nie ma.</span>")
		return
	user.put_in_hands(plated_item)
	plated_item = null
	update_icon()

/obj/machinery/munitions_forge/electroplater/start_operation(mob/user)
	if(!can_operate(user))
		return FALSE
	if(!plated_item)
		to_chat(user, "<span class='warning'>W [src] nie ma amunicji.</span>")
		return FALSE
	var/obj/machinery/munitions_forge/arc_forge/forge = find_forge()
	var/datum/component/material_container/container = forge?.get_container()
	if(!container)
		to_chat(user, "<span class='warning'>W pobliżu nie ma pieca łukowego z materiałami.</span>")
		return FALSE
	if(forge.materials.on_hold())
		to_chat(user, "<span class='warning'>Silos jest zablokowany.</span>")
		return FALSE
	var/amount = plating_amount(plated_item)
	var/datum/munition_material/material = pending_material
	if(!material)
		material = choose_munition_material(user, container, amount, "Galwanizacja: [plated_item]")
		if(!material || QDELETED(src) || !user_can_reach(user) || !can_operate(user) || !plated_item)
			return FALSE
	var/list/cost = material.get_cost(amount)
	if(!container.has_materials(cost))
		to_chat(user, "<span class='warning'>W silosie zabrakło materiału.</span>")
		pending_material = null
		return FALSE
	container.use_materials(cost)
	forge.materials.silo_log(src, "pokryto", -1, "[plated_item]", cost)
	pending_material = material
	to_chat(user, "<span class='notice'>[src] zaczyna pokrywać [plated_item]: [material.name].</span>")
	return ..()

/obj/machinery/munitions_forge/electroplater/complete_operation(mob/user)
	if(!plated_item || !pending_material)
		pending_material = null
		return
	apply_forged_munition(plated_item, pending_material, get_munition_quality(/datum/munition_quality), null, TRUE)
	pending_material = null
	plated_item.forceMove(drop_location())
	ping()
