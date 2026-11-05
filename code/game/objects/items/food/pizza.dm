
// Pizza (Whole)
/obj/item/food/pizza
	icon = 'icons/obj/food/pizza.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 28,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2
	/// type is spawned 6 at a time and replaces this pizza when processed by cutting tool
	var/obj/item/food/pizzaslice/slice_type
	///What label pizza boxes use if this pizza spawns in them.
	var/boxtag = ""

/obj/item/food/pizza/raw
	foodtypes =  GRAIN | DAIRY | VEGETABLES | RAW
	slice_type = null
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/make_processable()
	if(slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")
		AddElement(/datum/element/processable, TOOL_SAW, slice_type, 6, 4.5 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")
		AddElement(/datum/element/processable, TOOL_SCALPEL, slice_type, 6, 6 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

// Pizza Slice
/obj/item/food/pizzaslice
	icon = 'icons/obj/food/pizza.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	decomp_type = /obj/item/food/pizzaslice/moldy
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, 1, 1 SECONDS, table_required = TRUE, /*screentip_verb = "Flatten"*/)

/obj/item/food/pizza/margherita
	name = "pizza margherita"
	desc = "Najbardziej serowa pizza w galaktyce."
	icon_state = "pizzamargherita"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/margherita
	boxtag = "Margherita Deluxe"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/margherita/raw
	name = "surowa pizza margherita"
	icon_state = "pizzamargherita_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/margherita/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/margherita, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/margherita/robo
	food_reagents = list(
		/datum/reagent/nanomachines = 70,
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)

/obj/item/food/pizzaslice/margherita
	name = "kawałek pizzy margherita"
	desc = "Kawałek najbardziej serowej pizzy w galaktyce."
	icon_state = "pizzamargheritaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizzaslice/margherita/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 12)

/obj/item/food/pizza/meat
	name = "pizza mięsna"
	desc = "Tłusta pizza z pysznym mięsem."
	icon_state = "meatpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 8
	)
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT
	slice_type = /obj/item/food/pizzaslice/meat
	boxtag = "Mięsny Supreme"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/meat/raw
	name = "surowa pizza mięsna"
	icon_state = "meatpizza_raw"
	foodtypes =  GRAIN | VEGETABLES| DAIRY | MEAT | RAW
	slice_type = null

/obj/item/food/pizza/meat/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/meat, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/meat
	name = "kawałek pizzy mięsnej"
	desc = "Pożywny kawałek pizzy mięsnej."
	icon_state = "meatpizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/mushroom
	name = "pizza grzybowa"
	desc = "Bardzo wyjątkowa pizza."
	icon_state = "mushroompizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 28,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "grzyb" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/mushroom
	boxtag = "Grzybowa Specjalna"
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/mushroom/raw
	name = "surowa pizza grzybowa"
	icon_state = "mushroompizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/mushroom/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mushroom, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/mushroom
	name = "kawałek pizzy grzybowej"
	desc = "Może to ostatni kawałek pizzy w twoim życiu."
	icon_state = "mushroompizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "grzyb" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/vegetable
	name = "pizza wegetariańska"
	desc = "Podczas robienia tej pizzy nie ucierpiał ani jeden Tomatos Sapiens."
	icon_state = "vegetablepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("skórka" = 1, "pomidor" = 2, "ser" = 1, "marchewka" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/vegetable
	boxtag = "Warzywna dla Smakoszy"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/vegetable/raw
	name = "surowa pizza wegetariańska"
	icon_state = "vegetablepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/vegetable/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/vegetable, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/vegetable
	name = "kawałek pizzy wegetariańskiej"
	desc = "Kawałek najbardziej zielonej ze wszystkich pizz bez zielonych składników."
	icon_state = "vegetablepizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 2, "ser" = 1, "marchewka" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/donkpocket
	name = "pizza pierogowa"
	desc = "Kto pomyślał, że to dobry pomysł?"
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1, "lenistwo" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	slice_type = /obj/item/food/pizzaslice/donkpocket
	boxtag = "Bangin' Donk"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/donkpocket/raw
	name = "surowa pizza pierogowa"
	icon_state = "donkpocketpizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD | RAW
	slice_type = null

/obj/item/food/pizza/donkpocket/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/donkpocket, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/donkpocket
	name = "kawałek pizzy pierogowej"
	desc = "Pachnie pierogiem."
	icon_state = "donkpocketpizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1, "lenistwo" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/dank
	name = "pizza ziołowa"
	desc = "Ulubiona pizza hipisów."
	icon_state = "dankpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/doctor_delight = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/dank
	boxtag = "Świeże Zioła"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/dank/raw
	name = "surowa pizza ziołowa"
	icon_state = "dankpizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	slice_type = null

/obj/item/food/pizza/dank/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/dank, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/dank
	name = "kawałek pizzy ziołowej"
	desc = "Taka dobra, stary..."
	icon_state = "dankpizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/sassysage
	name = "pizza z kiełbasą"
	desc = "Niemal czujesz smak tej zadziorności."
	icon_state = "sassysagepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	slice_type = /obj/item/food/pizzaslice/sassysage
	boxtag = "Dla Miłośników Kiełbasy"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/sassysage/raw
	name = "surowa pizza z kiełbasą"
	icon_state = "sassysagepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | RAW
	slice_type = null

/obj/item/food/pizza/sassysage/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/sassysage, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/sassysage
	name = "kawałek pizzy z kiełbasą"
	desc = "Pysznie zadziorna."
	icon_state = "sassysagepizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "mięso" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/pineapple
	name = "\improper pizza hawajska"
	desc = "Pizzowy odpowiednik zagadki Einsteina."
	icon_state = "pineapplepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/pineapplejuice = 8
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "ananas" = 2, "szynka" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	slice_type = /obj/item/food/pizzaslice/pineapple
	boxtag = "Smak Honolulu"
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizza/pineapple/raw
	name = "surowa pizza hawajska"
	icon_state = "pineapplepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE | RAW
	slice_type = null

/obj/item/food/pizza/pineapple/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/pineapple, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/pineapple
	name = "\improper kawałek pizzy hawajskiej"
	desc = "Kawałek pysznej kontrowersji."
	icon_state = "pineapplepizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "ananas" = 2, "szynka" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	crafting_complexity = FOOD_COMPLEXITY_4

// Moldly Pizza
// NOT Used in cytobiology.
/obj/item/food/pizzaslice/moldy
	name = "spleśniały kawałek pizzy"
	desc = "Kiedyś był to całkiem dobry kawałek pizzy, ale teraz leży tu zjełczały i pękający od zarodników. \
		Co za szkoda! Ale nie rozpamiętujmy przeszłości, patrzmy w przyszłość."
	icon_state = "moldy_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/toxin/amatoxin = 2,
	)
	tastes = list("czerstwa skórka" = 1, "zjełczały ser" = 2, "grzyb" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
	preserved_food = TRUE

/obj/item/food/pizzaslice/moldy/bacteria
	name = "spleśniały kawałek pizzy pełen bakterii"
	desc = "Ta niegdyś pyszna pizza nie tylko pokryła się warstwą plującego zarodnikami grzyba, ale też zdaje się pełzać, gdy nikt nie patrzy, tętniąc nowym życiem."

/obj/item/food/pizza/arnold
	name = "\improper pizza Arnolda"
	desc = "Dzień dobry, dodzwoniłeś się do pizzerii Arnolda. Nie ma mnie teraz, jestem na mieście, zabijam pepperoni."
	icon_state = "arnoldpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/iron = 10,
		/datum/reagent/medicine/omnizine = 30
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "pepperoni" = 2, "naboje 9 mm" = 2)
	slice_type = /obj/item/food/pizzaslice/arnold
	boxtag = "9mm Pepperoni"
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizza/arnold/raw
	name = "surowa pizza Arnolda"
	icon_state = "arnoldpizza_raw"
	foodtypes =  GRAIN | DAIRY | VEGETABLES | RAW
	slice_type = null

/obj/item/food/pizza/arnold/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/arnold, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/proc/try_break_off(mob/living/M, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	if(prob(50) || (M != user) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/obj/item/bodypart/l_arm = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = user.get_bodypart(BODY_ZONE_R_ARM)
	var/did_the_thing = (l_arm?.dismember() || r_arm?.dismember()) //not all limbs can be removed, so important to check that we did. the. thing.
	if(!did_the_thing)
		return
	to_chat(user, "<span class='userdanger'>Może dam ci pizzę, a może urwę ci rękę.</span>") //makes the reference more obvious
	user.visible_message("<span class='warning'>[src] urywa [user] rękę!</span>", "<span class='warning'>[src] urywa ci rękę!</span>")
	playsound(user,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, TRUE, -1)

/obj/item/food/proc/i_kill_you(obj/item/I, mob/user)
	if(istype(I, /obj/item/food/pineappleslice))
		to_chat(user, "<font color='red' size='7'>Jak będziesz chciał czegoś szalonego, na przykład ananasa, to cię zabiję.</font>") //this is in bigger text because it's hard to spam something that gibs you, and so that you're perfectly aware of the reason why you died
		user.gib() //if you want something crazy like pineapple, i'll kill you
	else if(istype(I, /obj/item/food/grown/mushroom) && iscarbon(user))
		to_chat(user, "<span class='userdanger'>Więc jak chcesz grzyby, to się zamknij.</span>") //not as large as the pineapple text, because you could in theory spam it
		var/mob/living/carbon/shutup = user
		shutup.gain_trauma(/datum/brain_trauma/severe/mute)

/obj/item/food/pizza/arnold/attack(mob/living/M, mob/living/user)
	. = ..()
	try_break_off(M, user)

/obj/item/food/pizza/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

/obj/item/food/pizzaslice/arnold
	name = "\improper kawałek pizzy Arnolda"
	desc = "Przychodzę, może dam ci pizzę, a może urwę ci rękę."
	icon_state = "arnoldpizzaslice"
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "pepperoni" = 2, "naboje 9 mm" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizzaslice/arnold/attack(mob/living/M, mob/living/user)
	. =..()
	try_break_off(M, user)

/obj/item/food/pizzaslice/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

// Ant Pizza, now with more ants.
/obj/item/food/pizzaslice/ants
	name = "\improper kawałek pizzy Mrówcza Impreza"
	desc = "Klucz do idealnego kawałka pizzy to nie przesadzić z mrówkami."
	icon_state = "antpizzaslice"
	food_reagents = list(
		/datum/reagent/ants = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1, "owady" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | BUGS
