// AQUILA - port BeeStation/BeeStation-Hornet#10703 (z poprawką BeeStation/BeeStation-Hornet#11770: olej to nasze fat/oil)

///It's gross, gets the name of it's owner, and is all kinds of fucked up
/datum/material/meat
	name = "meat"
	id = "meat"
	desc = "Mięso"
	color = rgb(214, 67, 67)
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/meat
	sheet_recipes_glob = "meat_recipes"
	value_per_unit = 0.05
	strength_modifier = 0.7
	item_sound_override = 'aquila/sound/blood_worm/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "meat"

/datum/material/meat/on_removed(atom/source, material_flags)
	. = ..()
	// Stos mięsa zmienia przy każdym use()/add() tylko ilość: komponent zostaje (z odczynnikami wstrzykniętymi graczom),
	// a odczynniki skalują się z liczbą arkuszy. Nowy komponent co zmianę dawał pełne odczynniki od nowa (darmowa odżywka).
	if(isstack(source))
		var/obj/item/stack/meat_stack = source
		var/new_meat = LAZYACCESS(meat_stack.mats_per_unit, src) * meat_stack.amount
		var/old_meat = LAZYACCESS(source.custom_materials, src)
		if(new_meat && source.GetComponent(/datum/component/edible))
			if(old_meat && source.reagents && new_meat != old_meat)
				source.reagents.multiply_reagents(new_meat / old_meat)
			return
	qdel(source.GetComponent(/datum/component/edible))

/datum/material/meat/on_applied_obj(obj/O, amount, material_flags)
	. = ..()
	O.obj_flags |= UNIQUE_RENAME //So you can name it after the person its made from, a depressing comprimise.
	make_edible(O, amount, material_flags)

/datum/material/meat/on_applied_turf(turf/T, amount, material_flags)
	. = ..()
	make_edible(T, amount, material_flags)

/datum/material/meat/proc/make_edible(atom/source, amount, material_flags)
	// Zostawiony przez on_removed() komponent stosu ma już odczynniki (AddComponent nie dodałby ich drugi raz, ale nie ma po co)
	if(source.GetComponent(/datum/component/edible))
		return
	var/nutriment_count = 3 * (amount / MINERAL_MATERIAL_AMOUNT)
	var/oil_count = 2 * (amount / MINERAL_MATERIAL_AMOUNT)
	source.AddComponent(/datum/component/edible, \
		initial_reagents = list(/datum/reagent/consumable/nutriment = nutriment_count, /datum/reagent/consumable/nutriment/fat/oil = oil_count), \
		foodtypes = RAW | MEAT | GORE, \
		eat_time = 30, \
		tastes = list("surowe mięso" = 1))
