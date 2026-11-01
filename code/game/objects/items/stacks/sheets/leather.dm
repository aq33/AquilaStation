/obj/item/stack/sheet/animalhide
	name = "skóra"
	desc = "Coś poszło nie tak."
	icon_state = "sheet-hide"
	item_state = "sheet-hide"
	novariants = TRUE

/obj/item/stack/sheet/animalhide/human
	name = "ludzka skóra"
	desc = "Produkt uboczny hodowli ludzi."
	singular_name = "kawałek ludzkiej skóry"
	novariants = FALSE

GLOBAL_LIST_INIT(human_recipes, list( \
	new/datum/stack_recipe("kostium napuchniętego człowieka", /obj/item/clothing/suit/hooded/bloated_human, 5), \
	))

/obj/item/stack/sheet/animalhide/human/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.human_recipes
	return ..()

/obj/item/stack/sheet/animalhide/generic
	name = "skóra"
	desc = "Kawałek skóry."
	singular_name = "kawałek skóry"
	novariants = FALSE

/obj/item/stack/sheet/animalhide/corgi
	name = "skóra corgiego"
	desc = "Produkt uboczny hodowli corgi."
	singular_name = "kawałek skóry corgiego"
	icon_state = "sheet-corgi"
	item_state = "sheet-corgi"

/obj/item/stack/sheet/animalhide/mothroach
	name = "skóra ćmokaralucha"
	desc = "Cienka warstwa skóry ćmokaralucha."
	singular_name = "kawałek skóry ćmokaralucha"
	icon_state = "sheet-mothroach"
	item_state = "sheet-mothroach"

GLOBAL_LIST_INIT(gondola_recipes, list ( \
	new/datum/stack_recipe("maska gondoli", /obj/item/clothing/mask/gondola, 1), \
	new/datum/stack_recipe("strój gondoli", /obj/item/clothing/under/costume/gondola, 2), \
	))

/obj/item/stack/sheet/animalhide/gondola
	name = "skóra gondoli"
	desc = "Niezwykle cenny produkt polowania na gondole."
	singular_name = "kawałek skóry gondoli"
	icon_state = "sheet-gondola"
	item_state = "sheet-gondola"

/obj/item/stack/sheet/animalhide/gondola/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.gondola_recipes
	return ..()

GLOBAL_LIST_INIT(corgi_recipes, list ( \
	new/datum/stack_recipe("kostium corgiego", /obj/item/clothing/suit/hooded/ian_costume, 3), \
	))

/obj/item/stack/sheet/animalhide/corgi/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.corgi_recipes
	return ..()

/obj/item/stack/sheet/animalhide/cat
	name = "kocia skóra"
	desc = "Produkt uboczny hodowli kotów."
	singular_name = "kawałek kociej skóry"
	icon_state = "sheet-cat"
	item_state = "sheet-cat"

/obj/item/stack/sheet/animalhide/monkey
	name = "małpia skóra"
	desc = "Produkt uboczny hodowli małp."
	singular_name = "kawałek małpiej skóry"
	icon_state = "sheet-monkey"
	icon_state = "sheet-monkey"

GLOBAL_LIST_INIT(monkey_recipes, list ( \
	new/datum/stack_recipe("maska małpy", /obj/item/clothing/mask/gas/monkeymask, 1), \
	new/datum/stack_recipe("strój małpy", /obj/item/clothing/suit/monkeysuit, 2), \
	))

/obj/item/stack/sheet/animalhide/monkey/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.monkey_recipes
	return ..()

/obj/item/stack/sheet/animalhide/lizard
	name = "jaszczurcza skóra"
	desc = "Sssssss..."
	singular_name = "kawałek jaszczurczej skóry"
	icon_state = "sheet-lizard"
	item_state = "sheet-lizard"

/obj/item/stack/sheet/animalhide/xeno
	name = "skóra obcego"
	desc = "Skóra straszliwej istoty."
	singular_name = "kawałek skóry obcego"
	icon_state = "sheet-xeno"
	item_state = "sheet-xeno"

GLOBAL_LIST_INIT(xeno_recipes, list ( \
	new/datum/stack_recipe("hełm ksenomorfa", /obj/item/clothing/head/xenos, 1), \
	new/datum/stack_recipe("strój ksenomorfa", /obj/item/clothing/suit/xenos, 2), \
	))

/obj/item/stack/sheet/animalhide/xeno/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.xeno_recipes
	return ..()

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "chityna obcego"
	desc = "Kawałek skóry straszliwej istoty."
	singular_name = "kawałek skóry obcego"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	novariants = TRUE

/obj/item/xenos_claw
	name = "pazur obcego"
	desc = "Pazur straszliwej istoty."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/weed_extract
	name = "ekstrakt z chwastów"
	desc = "Kawałek oślizgłego, fioletowawego chwastu."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"

/obj/item/stack/sheet/hairlesshide
	name = "oskubana skóra"
	desc = "Z tej skóry usunięto sierść, ale wciąż trzeba ją wyprać i wygarbować."
	singular_name = "kawałek oskubanej skóry"
	icon_state = "sheet-hairlesshide"
	item_state = "sheet-hairlesshide"

/obj/item/stack/sheet/wetleather
	name = "mokra skóra"
	desc = "Tę skórę wyczyszczono, ale wciąż trzeba ją wysuszyć."
	singular_name = "kawałek mokrej skóry"
	icon_state = "sheet-wetleather"
	item_state = "sheet-wetleather"
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

/*
 * Leather SHeet
 */
/obj/item/stack/sheet/leather
	name = "skóra garbowana"
	desc = "Produkt uboczny mielenia stworzeń."
	singular_name = "kawałek skóry garbowanej"
	icon_state = "sheet-leather"
	item_state = "sheet-leather"

GLOBAL_LIST_INIT(leather_recipes, list ( \
	new/datum/stack_recipe("portfel", /obj/item/storage/wallet, 1), \
	new/datum/stack_recipe("kaganiec", /obj/item/clothing/mask/muzzle, 2), \
	new/datum/stack_recipe("skórzane rękawice botanika", /obj/item/clothing/gloves/botanic_leather, 3), \
	new/datum/stack_recipe("pas na narzędzia", /obj/item/storage/belt/utility, 4), \
	new/datum/stack_recipe("skórzana torba na ramię", /obj/item/storage/backpack/satchel/leather, 5), \
	new/datum/stack_recipe("bandolier", /obj/item/storage/belt/bandolier, 5), \
	new/datum/stack_recipe("skórzana kurtka", /obj/item/clothing/suit/jacket/leather, 7), \
	new/datum/stack_recipe("sznurowane półbuty", /obj/item/clothing/shoes/laceup, 2), \
	new/datum/stack_recipe("skórzany płaszcz", /obj/item/clothing/suit/jacket/leather/overcoat, 10), \
	new/datum/stack_recipe("kubek do kości", /obj/item/storage/pill_bottle/dice_cup, 2), \
))

/obj/item/stack/sheet/leather/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.leather_recipes
	return ..()

/*
 * Sinew
 */
/obj/item/stack/sheet/sinew
	name = "ścięgna obserwatora"
	icon = 'icons/obj/mining.dmi'
	desc = "Długie, żylaste włókna, które zapewne pochodzą ze skrzydeł obserwatora."
	singular_name = "ścięgno obserwatora"
	icon_state = "sinew"
	novariants = TRUE


GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("więzy ze ścięgien", /obj/item/restraints/handcuffs/cable/sinew, 1), \
))

/obj/item/stack/sheet/sinew/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sinew_recipes
	return ..()

		/*
 * Plates
 		*/
/obj/item/stack/sheet/animalhide/goliath_hide
	name = "płyty ze skóry goliata"
	desc = "Kawałki skalistej skóry goliata. Mogą sprawić, że twój strój będzie nieco odporniejszy na ataki miejscowej fauny."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	singular_name = "płyta ze skóry"
	max_amount = 6
	novariants = FALSE
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER


/obj/item/stack/sheet/animalhide/ashdrake
	name = "skóra popielnego smoka"
	desc = "Mocna, łuskowata skóra popielnego smoka."
	icon = 'icons/obj/mining.dmi'
	icon_state = "dragon_hide"
	singular_name = "płyta ze smoka"
	max_amount = 10
	novariants = FALSE
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER


//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("[user] zaczyna ścinać sierść z [src].", "<span class='notice'>Zaczynasz ścinać sierść z [src]...</span>", "<span class='italics'>Słyszysz dźwięk noża ocierającego się o ciało.</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>Ścinasz sierść z tego kawałka ([src.singular_name]).</span>")
			new /obj/item/stack/sheet/hairlesshide(user.drop_location(), 1)
			use(1)
	else
		return ..()


//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/sheet/wetleather/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			new /obj/item/stack/sheet/leather(drop_location(), 1)
			wetness = initial(wetness)
			use(1)

/obj/item/stack/sheet/wetleather/microwave_act(obj/machinery/microwave/MW)
	..()
	new /obj/item/stack/sheet/leather(drop_location(), amount)
	qdel(src)

/obj/item/stack/sheet/wetleather/Initialize(mapload, new_amount, merge)
	. = ..()
	AddElement(/datum/element/dryable, /obj/item/stack/sheet/leather)
