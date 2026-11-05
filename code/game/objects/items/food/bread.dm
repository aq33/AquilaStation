
/obj/item/food/bread
	name = "chleb?"
	desc = "To nie powinno istnieć, zgłoś to koderom."
	icon = 'icons/obj/food/burgerbread.dmi'
	max_volume = 80
	tastes = list("chleb" = 10)
	foodtypes = GRAIN
	eat_time = 3 SECONDS
	crafting_complexity = FOOD_COMPLEXITY_2
	/// type is spawned 5 at a time and replaces this bread loaf when processed by cutting tool
	var/obj/item/food/breadslice/slice_type
	/// so that the yield can change if it isnt 5
	var/yield = 5

/obj/item/food/bread/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)
	AddComponent(/datum/component/food_storage)

/obj/item/food/bread/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, 3 SECONDS, table_required = TRUE)
		AddElement(/datum/element/processable, TOOL_SAW, slice_type, yield, 4 SECONDS, table_required = TRUE)

/obj/item/food/breadslice
	name = "kromka chleba?"
	desc = "To nie powinno istnieć, zgłoś to koderom."
	icon = 'icons/obj/food/burgerbread.dmi'
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	eat_time = 0.5 SECONDS
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/breadslice/Initialize()
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/bread/plain
	name = "chleb"
	desc = "Zwykły, stary, ziemski chleb."
	icon_state = "bread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10
	)
	tastes = list("chleb" = 10)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	slice_type = /obj/item/food/breadslice/plain
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/bread/plain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/bread/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/breadslice/plain
	name = "kromka chleba"
	desc = "Kromka domu."
	icon_state = "breadslice"
	foodtypes = GRAIN
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2
	)
	decomp_type = /obj/item/food/breadslice/moldy
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/breadslice/plain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_STACK)

/obj/item/food/breadslice/moldy
	name = "spleśniała kromka „chleba”"
	desc = "Całe stacje rozpadały się w sporach o to, czy to jeszcze nadaje się do jedzenia."
	icon_state = "moldybreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/mold = 10,
	)
	tastes = list("gnijący grzyb" = 1)
	foodtypes = GROSS
	preserved_food = TRUE
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/breadslice/moldy/bacteria
	name = "spleśniała kromka „chleba” pełna bakterii"
	desc = "Coś (pewnie nekrodrożdże) sprawiło, że ten chleb wyrósł w makabrycznym stanie nieżycia. \
		Pełza, gdy nikt nie patrzy. Jeśli to widzisz, lepiej poszukaj kapłana. Albo miotacza ognia."

/obj/item/food/bread/meat
	name = "bochenek chleba mięsnego"
	desc = "Kulinarna podstawa każdego szanującego się elokwentnego /tg/entlemana."
	icon_state = "meatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("chleb" = 10, "mięso" = 10)
	foodtypes = GRAIN | MEAT
	slice_type = /obj/item/food/breadslice/meat
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/meat
	name = "kromka chleba mięsnego"
	desc = "Kromka pysznego chleba mięsnego."
	icon_state = "meatbreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("chleb" = 1, "mięso" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/xenomeat
	name = "bochenek chleba z mięsem ksenomorfa"
	desc = "Wyjątkowo heretycki."
	icon_state = "xenomeatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("chleb" = 10, "kwas" = 10)
	foodtypes = GRAIN | MEAT
	slice_type = /obj/item/food/breadslice/xenomeat
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/xenomeat
	name = "kromka chleba z mięsem ksenomorfa"
	desc = "Kromka pysznego chleba mięsnego. Wyjątkowo heretycka."
	icon_state = "xenobreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("chleb" = 10, "kwas" = 10)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/spidermeat
	name = "pieczeń z mięsa pająka"
	desc = "Uspokajająco zielona pieczeń z mięsa pająka."
	icon_state = "spidermeatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/toxin = 15,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("chleb" = 10, "pajęczyny" = 5)
	foodtypes = GRAIN | MEAT | TOXIC
	slice_type = /obj/item/food/breadslice/spidermeat
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/spidermeat
	name = "plaster pieczeni z mięsa pająka"
	desc = "Plaster pieczeni ze zwierzęcia, które najpewniej nadal chce twojej śmierci."
	icon_state = "spidermeatslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/toxin = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("chleb" = 10, "pajęczyny" = 5)
	foodtypes = GRAIN | MEAT | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/banana
	name = "chlebek bananowo-orzechowy"
	desc = "Niebiański i sycący przysmak."
	icon_state = "bananabread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/banana = 20
	)
	tastes = list("chleb" = 10) // bananjuice will also flavour
	foodtypes = GRAIN | FRUIT
	slice_type = /obj/item/food/breadslice/banana
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/banana
	name = "kromka chlebka bananowo-orzechowego"
	desc = "Kromka pysznego chlebka bananowego."
	icon_state = "bananabreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/banana = 4
	)
	tastes = list("chleb" = 10)
	foodtypes = GRAIN | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/tofu
	name = "chleb z tofu"
	desc = "Jak chleb mięsny, tylko dla wegetarian. Supermoce niegwarantowane."
	icon_state = "tofubread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("chleb" = 10, "tofu" = 10)
	foodtypes = GRAIN | VEGETABLES
	slice_type = /obj/item/food/breadslice/tofu
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/tofu
	name = "kromka chleba z tofu"
	desc = "Kromka pysznego chleba z tofu."
	icon_state = "tofubreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("chleb" = 10, "tofu" = 10)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/creamcheese
	name = "chleb z serkiem śmietankowym"
	desc = "Tylko odrobina do posmarowania."
	icon_state = "creamcheesebread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("chleb" = 10, "ser" = 10)
	foodtypes = GRAIN | DAIRY
	slice_type = /obj/item/food/breadslice/creamcheese
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/creamcheese
	name = "kromka chleba z serkiem śmietankowym"
	desc = "Kromka braterskiej miłości!"
	icon_state = "creamcheesebreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("chleb" = 10, "ser" = 10)
	foodtypes = GRAIN | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/mimana
	name = "chleb z mimany"
	desc = "Najlepiej jeść w ciszy."
	icon_state = "mimanabread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/toxin/mutetoxin = 10,
		/datum/reagent/consumable/nothing = 10,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("chleb" = 10, "cisza" = 10)
	foodtypes = GRAIN | FRUIT
	slice_type = /obj/item/food/breadslice/mimana
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/breadslice/mimana
	name = "kromka chleba z mimany"
	desc = "Kromka ciszy!"
	icon_state = "mimanabreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/toxin/mutetoxin = 2,
		/datum/reagent/consumable/nothing = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/empty
	name = "chleb"
	icon_state = "tofubread"
	desc = "To chleb skrojony na miarę twoich najśmielszych marzeń."
	slice_type = /obj/item/food/breadslice/empty

// What you get from cutting a custom bread. Different from custom sliced bread.
/obj/item/food/breadslice/empty
	name = "kromka chleba"
	icon_state = "tofubreadslice"
	foodtypes = GRAIN
	desc = "To kromka chleba skrojona na miarę twoich najśmielszych marzeń."

/obj/item/food/breadslice/empty/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 8)

/obj/item/food/baguette
	name = "bagietka"
	desc = "Bon appétit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	item_state = null
	worn_icon_state = "baguette"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	attack_verb = list("trafia (touché)")
	tastes = list("chleb" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/baguette/mime
	name = "francuska bagietka"
	desc = "Szkoda by było, gdyby zjadł ją ktoś niegodny..."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nothing = 2
	)
	bite_consumption = null

/obj/item/food/garlicbread
	name = "chleb czosnkowy"
	desc = "Niestety, jest go niewiele."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "garlicbread"
	item_state = null
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/garlic = 2
	)
	bite_consumption = 3
	tastes = list("chleb" = 1, "czosnek" = 1, "masło" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butterbiscuit
	name = "maślane ciastko"
	desc = "A niech mnie masłem posmarują!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterbiscuit"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("masło" = 1, "herbatnik" = 1)
	foodtypes = GRAIN | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butterdog
	name = "maślany hot dog"
	desc = "Zrobiony z egzotycznych maseł."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("masło" = 1, "egzotyczne masło" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butterdog/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 8 SECONDS)
