////////////////////////////////////////////OTHER////////////////////////////////////////////
/obj/item/food/watermelonslice
	name = "plaster arbuza"
	desc = "Plaster wodnistej rozkoszy."
	icon_state = "watermelonslice"
	food_reagents = list(
		/datum/reagent/water = 1,
		/datum/reagent/consumable/nutriment/vitamin = 0.2,
		/datum/reagent/consumable/nutriment = 1,
	)
	tastes = list("arbuz" = 1)
	foodtypes = FRUIT
	food_flags = FOOD_FINGER_FOOD
	juice_typepath = /datum/reagent/consumable/watermelonjuice
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/hugemushroomslice
	name = "plaster ogromnego grzyba"
	desc = "Plaster z ogromnego grzyba."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "hugemushroomslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("grzyb" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/popcorn
	name = "popcorn"
	desc = "Teraz poszukajmy jakiegoś kina."
	icon_state = "popcorn"
	trash_type = /obj/item/trash/popcorn
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bite_consumption = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	tastes = list("popcorn" = 3, "masło" = 1)
	foodtypes = JUNKFOOD
	eatverbs = list("gryzie", "skubie", "obgryza", "pochłania", "chrupie")
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/soydope
	name = "sojowy odlot"
	desc = "Odlot z soi."
	icon_state = "soydope"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
	)
	tastes = list("soja" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/badrecipe
	name = "spalona breja"
	desc = "Ktoś powinien za to wylecieć ze stanowiska kucharza."
	icon_state = "badrecipe"
	food_reagents = list(/datum/reagent/toxin/bad_food = 30)
	foodtypes = GROSS
	w_class = WEIGHT_CLASS_SMALL
	preserved_food = TRUE //Can't decompose any more than this

/obj/item/food/badrecipe/moldy
	name = "spleśniała breja"
	desc = "Zjełczała, obrzydliwa hodowla pleśni i mrówek. Gdzieś tam pod spodem, <i>kiedyś,</i> było jedzenie."
	food_reagents = list(/datum/reagent/consumable/mold = 30)
	preserved_food = FALSE
	ant_attracting = TRUE
	decomp_type = null
	decomposition_time = 30 SECONDS

/obj/item/food/badrecipe/moldy/bacteria
	name = "spleśniała breja pełna bakterii"
	desc = "Ta zjełczała bryła obrzydliwej żółci nie tylko roi się od owadów, ale też kipi od różnych mikroskopijnych kultur. <i>Rusza się, kiedy nie patrzysz.</i>"

/obj/item/food/badrecipe/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_GRILLED, PROC_REF(OnGrill))

///Prevents grilling burnt shit from well, burning.
/obj/item/food/badrecipe/proc/OnGrill()
	SIGNAL_HANDLER
	return COMPONENT_HANDLED_GRILLING

/obj/item/food/badrecipe/burn()
	if(QDELETED(src))
		return
	var/turf/T = get_turf(src)
	var/obj/effect/decal/cleanable/ash/A = new /obj/effect/decal/cleanable/ash(T)
	A.desc += "\nWygląda na to, że kiedyś to było [name]."
	if(resistance_flags & ON_FIRE)
		SSfire_burning.processing -= src
	qdel(src)

// We override the parent procs here to prevent burned messes from cooking into burned messes.
/obj/item/food/badrecipe/make_grillable()
	return

/obj/item/food/spidereggs
	name = "pajęcze jaja"
	desc = "Grono soczystych pajęczych jaj. Świetny dodatek, gdy nie dbasz o zdrowie."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spidereggs"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/toxin = 2,
	)
	tastes = list("pajęczyny" = 1)
	foodtypes = MEAT | TOXIC | BUGS
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/spiderling
	name = "pajączek"
	desc = "Lekko drga ci w dłoni. Fuj..."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spiderling"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/toxin = 4,
	)
	tastes = list("pajęczyny" = 1, "flaki" = 2)
	foodtypes = MEAT | TOXIC | BUGS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/melonfruitbowl
	name = "arbuzowa misa owoców"
	desc = "Dla ludzi, którzy chcą jadalnych mis na owoce."
	icon_state = "melonfruitbowl"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("melon" = 1)
	foodtypes = FRUIT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/melonkeg
	name = "arbuzowa beczka"
	desc = "Kto by pomyślał, że wódka to owoc?"
	icon_state = "melonkeg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/ethanol/vodka = 15,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	max_volume = 80
	bite_consumption = 5
	tastes = list("spirytus zbożowy" = 1, "owoce" = 1)
	foodtypes = FRUIT | ALCOHOL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/honeybar
	name = "baton miodowo-orzechowy"
	desc = "Owies i orzechy sprasowane w baton i sklejone miodową glazurą."
	icon_state = "honeybar"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/honey = 5,
	)
	tastes = list("owies" = 3, "orzechy" = 2, "miód" = 1)
	foodtypes = GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/powercrepe
	name = "supernaleśnik"
	desc = "Z wielką mocą przychodzi wielki naleśnik. Wygląda jak naleśnik z dżemem, ale ma niezłego kopa."
	icon_state = "powercrepe"
	item_state = "powercrepe"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/cherryjelly = 5,
	)
	force = 30
	throwforce = 15
	block_level = 2
	block_upgrade_walk = 1
	block_power = 55
	attack_weight = 2
	armour_penetration = 80
	//wound_bonus = -50
	attack_verb = list("policzkuje", "smaruje")
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("wiśnia" = 1, "naleśnik" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/branrequests
	name = "płatki Otrębowe Życzenia"
	desc = "Suche płatki, które spełniają twoje życzenia co do otrębów. Smakują wyjątkowo jak rodzynki i sól."
	icon_state = "bran_requests"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/sodiumchloride = 8,
	)
	tastes = list("otręby" = 4, "rodzynki" = 3, "sól" = 1)
	foodtypes = GRAIN | FRUIT | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butter
	name = "kostka masła"
	desc = "Kostka pysznej, złocistej, tłustej rozkoszy."
	icon_state = "butter"
	food_reagents = list(/datum/reagent/consumable/nutriment/fat = 5)
	tastes = list("masło" = 1)
	foodtypes = DAIRY
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/butter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Gdybyś miał pręt, mógłbyś zrobić <b>masło na patyku</b>.</span>"

/obj/item/food/butter/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = item
		if(!rods.use(1))//borgs can still fail this if they have no metal
			to_chat(user, "<span class='warning'>Masz za mało metalu, by nabić [src] na patyk!</span>")
			return ..()
		to_chat(user, "<span class='notice'>Wbijasz pręt w kostkę masła.</span>")
		var/obj/item/food/butter/on_a_stick/new_item = new(usr.loc)
		var/replace = (user.get_inactive_held_item() == rods)
		if(!rods && replace)
			user.put_in_hands(new_item)
		qdel(src)
		return TRUE
	..()

/obj/item/food/butter/on_a_stick //there's something so special about putting it on a stick.
	name = "masło na patyku"
	desc = "Pyszna, złocista, tłusta rozkosz na patyku."
	icon_state = "butteronastick"
	trash_type = /obj/item/stack/rods
	food_flags = FOOD_FINGER_FOOD

/obj/item/food/onionrings
	name = "krążki cebulowe"
	desc = "Plastry cebuli w cieście."
	icon_state = "onionrings"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	gender = PLURAL
	tastes = list("ciasto naleśnikowe" = 3, "cebula" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/pineappleslice
	name = "plaster ananasa"
	desc = "Pokrojony kawałek soczystego ananasa."
	icon_state = "pineapple_slice"
	juice_typepath = /datum/reagent/consumable/pineapplejuice
	tastes = list("ananas" = 1)
	foodtypes = FRUIT | PINEAPPLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/crab_rangoon
	name = "krab rangoon"
	desc = "Ma wiele nazw: krabowe ptysie, serowe wontony, pierożki z krabem? Jakkolwiek je nazwiesz, to wspaniała eksplozja kraba z serkiem śmietankowym."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "crabrangoon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("serek śmietankowy" = 4, "krab" = 3, "chrupkość" = 2)
	foodtypes = MEAT | DAIRY | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cornchips
	name = "chipsy kukurydziane Boritos"
	desc = "Trójkątne chipsy kukurydziane. Wydają się trochę mdłe, ale pewnie dobrze pasowałyby do jakiegoś dipu."
	icon_state = "boritos"
	trash_type = /obj/item/trash/boritos
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/fat/oil = 2,
		/datum/reagent/consumable/sodiumchloride = 3
	)
	junkiness = 20
	tastes = list("smażona kukurydza" = 1)
	foodtypes = JUNKFOOD | FRIED

/obj/item/food/pingles
	name = "pingles"
	desc = "Idealne połączenie kwaśnej śmietany i cebuli na chipsie ziemniaczanym. Może powodować kosmiczny lag."
	icon_state = "pingles"
	trash_type = /obj/item/c_tube
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/fat/oil = 2,
		/datum/reagent/consumable/sodiumchloride = 2
	)

	tastes = list("kwaśna śmietana" = 2, "cebula" = 1)
	foodtypes = FRIED

/obj/item/food/rationpack
	name = "racja żywnościowa"
	desc = "Kwadratowy baton, który niestety tylko <i>wygląda</i> jak czekolada, w nijakim szarym opakowaniu. Nieraz uratował życie żołnierzom – zwykle zatrzymując kule."
	icon_state = "rationpack"
	bite_consumption = 3
	junkiness = 15
	tastes = list("karton" = 3, "smutek" = 3)
	foodtypes = null //Don't ask what went into them. You're better off not knowing.
	food_reagents = list(/datum/reagent/consumable/nutriment/stabilized = 10, /datum/reagent/consumable/nutriment = 2) //Won't make you fat. Will make you question your sanity.

///Override for checkliked callback
/obj/item/food/rationpack/make_edible()
	. = ..()
	AddComponent(/datum/component/edible, check_liked = CALLBACK(src, PROC_REF(check_liked)))

/obj/item/food/rationpack/proc/check_liked(mob/M)	//Nobody likes rationpacks. Nobody.
	return FOOD_DISLIKED


/obj/item/food/onigiri
	name = "onigiri"
	desc = "Kulka ugotowanego ryżu wokół nadzienia, uformowana w trójkąt i owinięta wodorostami. Można dodać nadzienie!"
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = "onigiri"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		)
	tastes = list("ryż" = 1, "suszone wodorosty" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/onigiri/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/onigiri/empty, CUSTOM_INGREDIENT_ICON_NOCHANGE, max_ingredients = 4)

/obj/item/food/onigiri/empty //for custom onigiri creation
	name = "onigiri"
	foodtypes = VEGETABLES
	tastes = list()
	icon_state = "onigiri"
	desc = "Kulka ugotowanego ryżu wokół nadzienia, uformowana w trójkąt i owinięta wodorostami."
