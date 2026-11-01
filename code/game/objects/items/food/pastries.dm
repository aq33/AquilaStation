//Pastry is a food that is made from dough which is made from wheat or rye flour.
//This file contains pastries that don't fit any existing categories.
////////////////////////////////////////////MUFFINS////////////////////////////////////////////

/obj/item/food/muffin
	name = "muffinka"
	desc = "Pyszne, puszyste małe ciastko."
	icon_state = "muffin"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("muffinka" = 1)
	foodtypes = GRAIN | SUGAR | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/muffin/berry
	name = "muffinka jagodowa"
	icon_state = "berrymuffin"
	desc = "Pyszne, puszyste małe ciastko z jagodami."
	tastes = list("muffinka" = 3, "jagoda" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/muffin/booberry
	name = "upiorna muffinka"
	icon_state = "berrymuffin"
	alpha = 125
	desc = "Mój żołądek to cmentarz! Żadna żywa istota nie ugasi mojej żądzy krwi!"
	tastes = list("muffinka" = 3, "upiorność" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/muffin/moffin
	name = "ćmuffinka"
	icon_state = "moffin_1"
	desc = "Pyszne, puszyste małe ciastko."
	tastes = list("muffinka" = 3, "kurz" = 1, "kłaczki" = 1)
	foodtypes = CLOTH | GRAIN | SUGAR | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/muffin/moffin/Initialize(mapload)
	. = ..()
	icon_state = "moffin_[rand(1, 3)]"

/obj/item/food/muffin/moffin/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/moffin_observer = user
	var/obj/item/organ/tongue/tongue = moffin_observer.getorganslot(ORGAN_SLOT_TONGUE)

	if(!tongue) ///no tongue means no taste
		return

	if(tongue.liked_food & CLOTH)
		to_chat(moffin_observer,"<span class='nicegreen'>Oo! Są w nim nawet kawałki ubrań! Mniam!</span>")
	else
		to_chat(moffin_observer,"<span class='warning'>Nie jesteś jednak pewien, co jest na wierzchu...</span>")

////////////////////////////////////////////WAFFLES////////////////////////////////////////////

/obj/item/food/waffles
	name = "gofry"
	desc = "Mmm, gofry."
	icon_state = "waffles"
	trash_type = /obj/item/trash/waffles
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("gofry" = 1)
	foodtypes = GRAIN | SUGAR | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/soylentgreen
	name = "\improper Soylent Green"
	desc = "Nie są zrobione z ludzi. Słowo*." //Totally people.
	icon_state = "soylent_green"
	trash_type = /obj/item/trash/waffles
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("gofry" = 7, "ludzie" = 1)
	// The wafers are supposed to be flavorful and nutritious in the movie. They shouldn't be gross in a dystopian future where the chef regularly feeds people from the morgue to you.
	foodtypes = GRAIN | MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Nie są zrobione z ludzi. Słowo." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash_type = /obj/item/trash/waffles
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("gofry" = 7, "kolor zielony" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/rofflewaffles
	name = "gofry Roffle"
	desc = "Gofry od Roffle Co."
	icon_state = "rofflewaffles"
	trash_type = /obj/item/trash/waffles
	bite_consumption = 4
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/drug/mushroomhallucinogen = 2,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("gofry" = 1, "grzyby" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/food/cookie
	name = "ciasteczko"
	desc = "CIASTECZKO!!!"
	icon_state = "COOKIE!!!"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("ciasteczko" = 1)
	foodtypes = GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cookie/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/fortunecookie
	name = "ciasteczko z wróżbą"
	desc = "W każdym ciasteczku prawdziwa przepowiednia!"
	icon_state = "fortune_cookie"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("ciasteczko" = 1)
	foodtypes = GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fortunecookie/make_edible()
	AddComponent(/datum/component/edible, \
		initial_reagents = food_reagents, \
		food_flags = food_flags, \
		foodtypes = foodtypes, \
		volume = max_volume, \
		eat_time = eat_time, \
		tastes = tastes, \
		eatverbs = eatverbs,\
		bite_consumption = bite_consumption, \
		microwaved_type = microwaved_type, \
		junkiness = junkiness, \
		on_consume = CALLBACK(src, PROC_REF(on_consume)), \
	)

/obj/item/food/fortunecookie/proc/on_consume(mob/user)
	var/obj/item/paper/fortune = locate(/obj/item/paper) in src.contents
	if(fortune)
		if(user)
			user.put_in_hands(fortune)

/obj/item/food/cookie/sugar
	name = "ciasteczko cukrowe"
	desc = "Zupełnie jak te, które piekła twoja młodsza siostra."
	icon_state = "sugarcookie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 6,
	)
	tastes = list("słodycz" = 1)
	foodtypes = GRAIN | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cookie/oatmeal
	name = "ciasteczko owsiane"
	desc = "To, co najlepsze w ciasteczkach i owsie."
	icon_state = "oatmealcookie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("ciasteczko" = 2, "owies" = 1)
	foodtypes = GRAIN | BREAKFAST //these & raisin cookies were always served at breakfast at my university. Its basically breakfast in cookie
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cookie/raisin
	name = "ciasteczko z rodzynkami"
	desc = "Czemu nie dodać rodzynek do ciasteczka?"
	icon_state = "raisincookie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("ciasteczko" = 1, "rodzynki" = 1)
	foodtypes = GRAIN | FRUIT | BREAKFAST //these & oatmeal cookies were always served at breakfast at my university. Its basically breakfast in cookie
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/chococornet
	name = "rożek czekoladowy"
	desc = "Która strona to głowa, gruby koniec czy cienki?"
	icon_state = "chococornet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("herbatnik" = 3, "czekolada" = 1)
	foodtypes = GRAIN | JUNKFOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/poppypretzel
	name = "precel z makiem"
	desc = "Jest cały poskręcany!"
	icon_state = "poppypretzel"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("precel" = 1)
	foodtypes = GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/plumphelmetbiscuit
	name = "herbatnik z pulchnego hełmu"
	desc = "Starannie przygotowany herbatnik z pulchnego hełmu. Składniki to wyjątkowo drobno posiekany pulchny hełm i dobrze zmielona krasnoludzka mąka pszenna."
	icon_state = "phelmbiscuit"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("grzyb" = 1, "herbatnik" = 1)
	foodtypes = GRAIN | VEGETABLES
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/plumphelmetbiscuit/Initialize(mapload)
	var/fey = prob(10)
	if(fey)
		name = "wyjątkowy herbatnik z pulchnego hełmu"
		desc = "Mikrofalówkę ogarnia natchnienie! Upiekła wyjątkowy herbatnik z pulchnego hełmu!"
		food_reagents = list(
			/datum/reagent/medicine/omnizine = 5,
			/datum/reagent/consumable/nutriment = 1,
			/datum/reagent/consumable/nutriment/vitamin = 1,
		)
	. = ..()
	if(fey)
		reagents.add_reagent(/datum/reagent/medicine/omnizine, 5)

/obj/item/food/cracker
	name = "krakers"
	desc = "Solony krakers."
	icon_state = "cracker"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("krakers" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/khachapuri
	name = "chaczapuri"
	desc = "Chleb z jajkiem i serem?"
	icon_state = "khachapuri"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("chleb" = 1, "jajko" = 1, "ser" = 1)
	foodtypes = GRAIN | MEAT | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cherrycupcake
	name = "babeczka wiśniowa"
	desc = "Słodka babeczka z kawałkami wiśni."
	icon_state = "cherrycupcake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("ciasto" = 3, "wiśnia" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cherrycupcake/blue
	name = "babeczka z niebieską wiśnią"
	desc = "Niebieskie wiśnie w pysznej babeczce."
	icon_state = "bluecherrycupcake"
	tastes = list("ciasto" = 3, "niebieska wiśnia" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/jupitercupcake
	name = "babeczka jowiszowa"
	desc = "Deser naładowany elektrostatycznie."
	icon_state = "jupitercupcake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/caramel = 3,
		/datum/reagent/consumable/liquidelectricity = 3,
	)
	tastes = list("ciasto" = 3, "karmel" = 2, "porażenie" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3
	crafted_food_buff = /datum/status_effect/food/trait/shockimmune

/obj/item/food/honeybun
	name = "bułeczka miodowa"
	desc = "Lepka słodka bułeczka polana miodem."
	icon_state = "honeybun"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/honey = 6,
	)
	tastes = list("ciastko" = 1, "słodycz" = 1)
	foodtypes = GRAIN | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/ravtart
	name = "Rav'tart"
	desc = "Tarta w kolorze mosiądzu z czerwonym nadzieniem. Pierwotnie wypiekana przez TRNE Corp, podobno pobłogosławiona przez pewnego pradawnego boga."
	icon_state = "ravtart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/ratlight = 8
	)
	tastes = list("ciastko" = 1, "słodycz" = 1)
	foodtypes = GRAIN | FRUIT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
