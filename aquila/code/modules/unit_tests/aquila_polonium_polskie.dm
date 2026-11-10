// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - aq33/AquilaStation#607: broń, jedzenie i szyld z Polonium mają swoje stany ikon, a podtypy Walthera, które zostały przy starych sprite'ach, nie zgubiły swoich.
/datum/unit_test/aquila_polonium_polskie

/datum/unit_test/aquila_polonium_polskie/Run()
	var/list/items = list(
		/obj/item/gun/ballistic/automatic/pistol/glock,
		/obj/item/gun/ballistic/automatic/pistol/glock/security,
		/obj/item/gun/ballistic/automatic/pistol/glock/makarov,
		/obj/item/gun/ballistic/automatic/pistol/glock/command,
		/obj/item/gun/ballistic/automatic/pistol/glock/security/hos,
		/obj/item/gun/ballistic/automatic/sniper_rifle,
		/obj/item/gun/ballistic/automatic/sniper_rifle/syndicate,
		/obj/item/food/kabanosy,
		/obj/item/trash/kabanosy,
		/obj/item/food/parowka,
		/obj/item/food/peto_parowek,
	)
	for(var/obj/item/path as anything in items)
		var/icon_file = initial(path.icon)
		var/state = initial(path.icon_state)
		TEST_ASSERT(state in icon_states(icon_file), "[path]: brak stanu [state] w [icon_file]")
		var/item_state = initial(path.item_state)
		if(!ispath(path, /obj/item/gun))
			continue
		TEST_ASSERT(item_state in icon_states(initial(path.lefthand_file)), "[path]: brak stanu w ręce [item_state] w [initial(path.lefthand_file)]")
		TEST_ASSERT(item_state in icon_states(initial(path.righthand_file)), "[path]: brak stanu w ręce [item_state] w [initial(path.righthand_file)]")

	// Nakładki zamka i magazynka, które dokłada /obj/item/gun/ballistic/update_icon()
	var/list/vis_states = icon_states('aquila/icons/obj/guns/polskie.dmi')
	for(var/overlay in list("vis_mag", "vis_bolt", "vis_bolt_locked", "bor_mag"))
		TEST_ASSERT(overlay in vis_states, "Brak nakładki [overlay]")
	TEST_ASSERT("bor" in icon_states('aquila/icons/mob/clothing/back_polskie.dmi'), "Brak sprite'a Alexis-BOR na plecach")

	for(var/datum/barsign/sign_type as anything in list(/datum/barsign/zabkacafe))
		TEST_ASSERT(initial(sign_type.icon) in icon_states(initial(sign_type.icon_file)), "[sign_type]: brak stanu szyldu")

	var/obj/machinery/vending/snack/snack = allocate(/obj/machinery/vending/snack)
	TEST_ASSERT(snack.products[/obj/item/food/kabanosy], "Kabanosów nie ma w automacie z przekąskami")

	for(var/recipe_type in list(/datum/crafting_recipe/food/peto_parowek, /datum/crafting_recipe/food/hotdog_parowka))
		var/found = FALSE
		for(var/datum/crafting_recipe/recipe as anything in GLOB.cooking_recipes)
			if(recipe.type == recipe_type)
				found = TRUE
				break
		TEST_ASSERT(found, "Przepisu [recipe_type] nie ma w GLOB.cooking_recipes")

#undef TEST_ASSERT
