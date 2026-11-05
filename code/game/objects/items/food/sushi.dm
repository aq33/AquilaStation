/obj/item/food/sushi_roll
	name = "rodzic sushi"
	desc = "Albo ty zespawnowałeś to przez pomyłkę, albo zrobił to koder. Tak czy siak, ktoś coś zepsuł."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "ERROR"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		)
	tastes = list("sushi" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/food/sushi_slice/slice_type /// type is spawned 4 at a time and replaces this cake when processed by cutting tool
	var/yield = 4 /// yield of sliced sushi, default is 4

/obj/item/food/sushi_roll/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, 3 SECONDS, table_required = TRUE)

/obj/item/food/sushi_slice
	name = "rodzic kawałka sushi"
	desc = "Albo ty zespawnowałeś to przez pomyłkę, albo zrobił to koder. Tak czy siak, ktoś coś zepsuł."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "ERROR"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		)
	tastes = list("sushi" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/seaweed_sheet
	name = "arkusz wodorostów"
	desc = "Suszony arkusz wodorostów do robienia sushi. Użyj na nim składnika, żeby zacząć robić własne sushi!"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "seaweed_sheet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("wodorosty" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/seaweed_sheet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/sushi_roll/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

/obj/item/food/sushi_roll/empty //for custom sushi creation
	name = "sushi"
	desc = "Rolka sushi według własnego pomysłu."
	icon_state = "vegetariansushiroll"
	tastes = list()
	foodtypes = NONE
	slice_type = /obj/item/food/sushi_slice/empty

/obj/item/food/sushi_slice/empty
	name = "kawałek sushi"
	desc = "Kawałek sushi według własnego pomysłu."
	icon_state = "vegetariansushislice"
	tastes = list()
	foodtypes = NONE

/obj/item/food/sushi_roll/vegetarian
	name = "wegetariańska rolka sushi"
	desc = "Rolka prostego wegetariańskiego sushi z ryżem, marchewką i kapustą. Można ją pokroić na kawałki!"
	icon_state = "vegetariansushiroll"
	tastes = list("gotowany ryż" = 4, "marchewki" = 2, "kapusta" = 2)
	foodtypes = VEGETABLES
	slice_type = /obj/item/food/sushi_slice/vegetarian

/obj/item/food/sushi_slice/vegetarian
	name = "kawałek wegetariańskiego sushi"
	desc = "Kawałek prostego wegetariańskiego sushi z ryżem, marchewką i kapustą."
	icon_state = "vegetariansushislice"
	foodtypes = VEGETABLES
	tastes = list("gotowany ryż" = 4, "marchewki" = 2, "kapusta" = 2)

/obj/item/food/sushi_roll/spicyfilet
	name = "pikantna rolka sushi z filetem"
	desc = "Rolka smacznego, pikantnego sushi z rybą i warzywami. Można ją pokroić na kawałki!"
	icon_state = "spicyfiletroll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		)
	tastes = list("gotowany ryż" = 4, "ryba" = 2, "ostrość" = 2)
	foodtypes = MEAT
	slice_type = /obj/item/food/sushi_slice/spicyfilet

/obj/item/food/sushi_slice/spicyfilet
	name = "kawałek pikantnego sushi z filetem"
	desc = "Kawałek smacznego, pikantnego sushi z rybą i warzywami."
	icon_state = "spicyfiletslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		)
	tastes = list("gotowany ryż" = 4, "ryba" = 2, "ostrość" = 2)
	foodtypes = MEAT

/obj/item/food/sushi_roll/futomaki
	name = "rolka sushi futomaki"
	desc = "Rolka sushi futomaki z jajkiem na twardo, rybą i kapustą. Można ją pokroić"
	icon_state = "futomaki_sushi_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("gotowany ryż" = 4, "ryba" = 5, "jajko" = 3, "suszone wodorosty" = 2)
	foodtypes = MEAT
	slice_type = /obj/item/food/sushi_slice/futomaki

/obj/item/food/sushi_slice/futomaki
	name = "kawałek sushi futomaki"
	desc = "Kawałek sushi futomaki z jajkiem na twardo, rybą i kapustą."
	icon_state = "futomaki_sushi_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("gotowany ryż" = 4, "ryba" = 5, "jajko" = 3, "suszone wodorosty" = 2, "kapusta" = 2)
	foodtypes = MEAT

/obj/item/food/sushi_roll/philadelphia
	name = "rolka sushi Philadelphia"
	desc = "Rolka sushi Philadelphia z serem, rybą i kapustą. Można ją pokroić"
	icon_state = "philadelphia_sushi_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("gotowany ryż" = 4, "ryba" = 5, "kremowy ser" = 3, "suszone wodorosty" = 2, "kapusta" = 2)
	foodtypes = MEAT | DAIRY
	slice_type = /obj/item/food/sushi_slice/philadelphia

/obj/item/food/sushi_slice/philadelphia
	name = "kawałek sushi Philadelphia"
	desc = "Kawałek sushi Philadelphia z serem, rybą i kapustą."
	icon_state = "philadelphia_sushi_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("gotowany ryż" = 4, "ryba" = 5, "kremowy ser" = 3, "suszone wodorosty" = 2, "kapusta" = 2)
	foodtypes = MEAT | DAIRY

/obj/item/food/nigiri_sushi
	name = "sushi nigiri"
	desc = "Proste nigiri z rybą na zbitej kulce ryżu, owinięte wodorostem, z sosem sojowym."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "nigiri_sushi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
		)
	tastes = list("gotowany ryż" = 4, "filet rybny" = 2, "sos sojowy" = 2)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL

