// AQUILA - kuźnia amunicji: części wylewane w basenie, kształtowane młotem i składane w monterze.
// Na wzór /obj/item/smithed_item/component z Paradise (ciepło, chłodzenie, cykle młota, parzenie).
// Korpus niesie materiał, wypełnienie i zapalnik niosą tylko jakość.

/obj/item/munition_part
	name = "część amunicji"
	desc = "Odlew z kuźni amunicji."
	icon = 'aquila/icons/obj/munitions_forge/smithing.dmi'
	icon_state = "bit_head"
	w_class = WEIGHT_CLASS_NORMAL
	/// Ile materiału (jednostki silosu) zużywa odlew. Dla korpusu: wybranego materiału, dla reszty: base_cost.
	var/list/base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	var/datum/munition_quality/quality
	var/forge_heat = 0
	/// Ile jeszcze cykli młota potrzeba
	var/hammer_time = 3
	var/cool_time = 10 SECONDS

/obj/item/munition_part/Initialize(mapload)
	. = ..()
	if(!quality)
		quality = get_munition_quality(/datum/munition_quality)

/// Wołane przez basen zaraz po odlaniu.
/obj/item/munition_part/proc/cast_finished(datum/munition_quality/new_quality)
	quality = new_quality
	hammer_time = CEILING(initial(hammer_time) * quality.work_mult, 1)
	name = "[initial(name)] (klasa [quality.roman])"
	heat_up(5)

/obj/item/munition_part/update_icon_state()
	icon_state = forge_heat ? "[initial(icon_state)]_hot" : initial(icon_state)
	return ..()

/obj/item/munition_part/proc/heat_up(amount)
	var/was_cold = !forge_heat
	forge_heat += amount
	if(was_cold)
		addtimer(CALLBACK(src, PROC_REF(cool_off)), cool_time)
	update_icon()

/obj/item/munition_part/proc/cool_off()
	forge_heat = max(forge_heat - 1, 0)
	if(forge_heat)
		addtimer(CALLBACK(src, PROC_REF(cool_off)), cool_time)
	else
		update_icon()

/obj/item/munition_part/proc/hammer()
	hammer_time = max(hammer_time - 1, 0)

/obj/item/munition_part/proc/is_finished()
	return !hammer_time

/obj/item/munition_part/examine(mob/user)
	. = ..()
	if(quality)
		. += "<span class='notice'>Jakość: klasa [quality.roman] ([quality.name]).</span>"
	if(hammer_time)
		. += "Trzeba go jeszcze [hammer_time] razy przepuścić pod młotem pneumatycznym."
	else
		. += "Jest gotowy do montażu."
	if(forge_heat)
		. += "<span class='warning'>Jest rozgrzany do czerwoności!</span>"

/obj/item/munition_part/attack_hand(mob/user)
	if(forge_heat && burn_check(user))
		burn_user(user)
		return TRUE
	return ..()

/obj/item/munition_part/proc/burn_check(mob/user)
	if(!forge_heat)
		return FALSE
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/H = user
	if(HAS_TRAIT(H, TRAIT_RESISTHEAT) || HAS_TRAIT(H, TRAIT_RESISTHEATHANDS))
		return FALSE
	if(H.gloves)
		var/obj/item/clothing/gloves/G = H.gloves
		if(G.max_heat_protection_temperature > 360)
			return FALSE
	return TRUE

/obj/item/munition_part/proc/burn_user(mob/living/user)
	to_chat(user, "<span class='warning'>Parzysz sobie dłoń, próbując podnieść [src]!</span>")
	user.apply_damage(10, BURN, (user.active_hand_index % 2) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)

/// Wspólne dla maszyn: podaj część do ręki albo, jeśli parzy, wyrzuć ją pod nogi.
/obj/item/munition_part/proc/hand_over(mob/living/user)
	if(burn_check(user))
		burn_user(user)
		forceMove(user.drop_location())
		return
	if(!user.put_in_hands(src))
		forceMove(user.drop_location())

// ---------------------------------------------------------------- korpusy

/obj/item/munition_part/body
	name = "korpus"
	/// Ile jednostek wybranego materiału idzie na odlew (przed mnożnikami)
	var/material_amount = MINERAL_MATERIAL_AMOUNT * 2
	var/datum/munition_material/material
	/// Jaki zapalnik pasuje
	var/fuze_type = /obj/item/munition_part/fuze/impact
	/// Co powstaje w monterze
	var/product_path

/obj/item/munition_part/body/proc/set_material(datum/munition_material/new_material)
	material = new_material
	if(material.color_tint)
		add_atom_colour(material.color_tint, FIXED_COLOUR_PRIORITY)

/obj/item/munition_part/body/cast_finished(datum/munition_quality/new_quality)
	..()
	if(material)
		name = "[initial(name)] ([material.name], klasa [quality.roman])"

/// Tworzy wyrób. Zwraca listę rzeczy, które powstały.
/obj/item/munition_part/body/proc/create_product(atom/location, datum/munition_quality/final_quality, datum/munition_filler/filler)
	var/atom/movable/product = new product_path(location)
	product.AddComponent(/datum/component/forged_munition, material, final_quality, filler)
	return list(product)

// Łuski — wyrobem jest całe pudełko lub magazynek, a komponent dostaje każdy nabój.
/obj/item/munition_part/body/casings
	name = "łuski"
	icon_state = "bit_mount"
	fuze_type = /obj/item/munition_part/fuze/primer
	material_amount = MINERAL_MATERIAL_AMOUNT * 2

/obj/item/munition_part/body/casings/create_product(atom/location, datum/munition_quality/final_quality, datum/munition_filler/filler)
	var/obj/item/ammo_box/box = new product_path(location)
	for(var/obj/item/ammo_casing/casing in box.stored_ammo)
		casing.AddComponent(/datum/component/forged_munition, material, final_quality, filler)
	box.name = "[box.name] ([material.name][filler ? ", [filler.short_name]" : ""], klasa [final_quality.roman])"
	return list(box)

/obj/item/munition_part/body/casings/c9mm
	name = "łuski 9mm"
	product_path = /obj/item/ammo_box/c9mm

/obj/item/munition_part/body/casings/c10mm
	name = "łuski 10mm"
	product_path = /obj/item/ammo_box/c10mm

/obj/item/munition_part/body/casings/c45
	name = "łuski .45"
	product_path = /obj/item/ammo_box/c45

/obj/item/munition_part/body/casings/a357
	name = "łuski .357"
	product_path = /obj/item/ammo_box/a357
	material_amount = MINERAL_MATERIAL_AMOUNT

/obj/item/munition_part/body/casings/a762
	name = "łuski 7.62"
	product_path = /obj/item/ammo_box/a762
	material_amount = MINERAL_MATERIAL_AMOUNT

/obj/item/munition_part/body/casings/light_cannon
	name = "łuski lekkiego działka"
	product_path = /obj/item/ammo_box/magazine/nsv/light_cannon
	material_amount = MINERAL_MATERIAL_AMOUNT * 4

/obj/item/munition_part/body/casings/heavy_cannon
	name = "łuski ciężkiego działka"
	product_path = /obj/item/ammo_box/magazine/nsv/heavy_cannon
	material_amount = MINERAL_MATERIAL_AMOUNT * 6

// Pociski działowe
/obj/item/munition_part/body/shell
	name = "korpus pocisku"
	icon_state = "rod_core"
	w_class = WEIGHT_CLASS_BULKY
	material_amount = MINERAL_MATERIAL_AMOUNT * 5

/obj/item/munition_part/body/shell/naval
	name = "korpus pocisku artylerii"
	product_path = /obj/item/ship_weapon/ammunition/naval_artillery

/obj/item/munition_part/body/shell/broadside
	name = "korpus pocisku burtowego"
	product_path = /obj/item/ship_weapon/ammunition/broadside_shell
	material_amount = MINERAL_MATERIAL_AMOUNT * 3

/obj/item/munition_part/body/shell/gauss
	name = "korpus pocisku Gaussa"
	product_path = /obj/item/ship_weapon/ammunition/gauss
	material_amount = MINERAL_MATERIAL_AMOUNT * 2
	hammer_time = 2

// Obudowy głowic
/obj/item/munition_part/body/warhead
	name = "obudowa głowicy"
	icon_state = "rod_housing"
	w_class = WEIGHT_CLASS_BULKY
	material_amount = MINERAL_MATERIAL_AMOUNT * 8
	hammer_time = 4

/obj/item/munition_part/body/warhead/torpedo
	name = "obudowa głowicy torpedy"
	product_path = /obj/item/ship_weapon/parts/missile/warhead/torpedo

/obj/item/munition_part/body/warhead/missile
	name = "obudowa głowicy rakiety"
	product_path = /obj/item/ship_weapon/parts/missile/warhead
	material_amount = MINERAL_MATERIAL_AMOUNT * 5

// ---------------------------------------------------------------- wypełnienia

/obj/item/munition_part/filler
	name = "wypełnienie"
	icon_state = "insert_lining"
	hammer_time = 2
	var/filler_type

/obj/item/munition_part/filler/he
	name = "ładunek HE"
	filler_type = /datum/munition_filler/he
	base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = MINERAL_MATERIAL_AMOUNT * 0.5)

/obj/item/munition_part/filler/ap
	name = "rdzeń AP"
	filler_type = /datum/munition_filler/ap
	base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 2, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 0.5)

/obj/item/munition_part/filler/incendiary
	name = "ładunek zapalający"
	filler_type = /datum/munition_filler/incendiary
	base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = MINERAL_MATERIAL_AMOUNT)

/obj/item/munition_part/filler/emp
	name = "ładunek EMP"
	filler_type = /datum/munition_filler/emp
	base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/copper = MINERAL_MATERIAL_AMOUNT, /datum/material/uranium = MINERAL_MATERIAL_AMOUNT * 0.5)

// ---------------------------------------------------------------- zapalniki

/obj/item/munition_part/fuze
	name = "zapalnik"
	icon_state = "bit_head"
	w_class = WEIGHT_CLASS_SMALL
	hammer_time = 1

/obj/item/munition_part/fuze/primer
	name = "spłonki"
	base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/copper = MINERAL_MATERIAL_AMOUNT * 0.5)

/obj/item/munition_part/fuze/impact
	name = "zapalnik uderzeniowy"
	base_cost = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/copper = MINERAL_MATERIAL_AMOUNT * 0.5)
