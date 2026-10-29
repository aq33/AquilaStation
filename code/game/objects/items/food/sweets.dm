//Miscellaneous Sweets
/obj/item/food/candy_corn
	name = "cukierkowa kukurydza"
	desc = "Garść cukierkowej kukurydzy. Można ją trzymać w kapeluszu detektywa."
	icon_state = "candy_corn"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 2
	)
	tastes = list("cukierki kukurydziane" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/candy_corn/prison
	name = "wysuszona cukierkowa kukurydza"
	desc = "Gdyby ta cukierkowa kukurydza była choć trochę twardsza, policja skonfiskowałaby ją jako potencjalną kosę."
	force = 1 // the description isn't lying
	throwforce = 1 // if someone manages to bust out of jail with candy corn god bless them
	tastes = list("gorzki wosk" = 1)
	foodtypes = JUNKFOOD | GROSS

/obj/item/food/candiedapple
	name = "jabłko w karmelu"
	desc = "Jabłko oblane cukrową słodyczą."
	icon_state = "candiedapple"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/caramel = 5,
	)
	tastes = list("jabłko" = 2, "karmel" = 3)
	foodtypes = JUNKFOOD | FRUIT | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/mint
	name = "miętówka"
	desc = "Jest cieniutka jak wafelek."
	icon_state = "mint"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/toxin/minttoxin = 2)
	foodtypes = TOXIC | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/ant_candy
	name = "cukierek z mrówkami"
	desc = "Kolonia mrówek zatopiona w twardym cukrze. One nie żyją, prawda?"
	icon_state = "ant_pop"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/ants = 3,
	)
	tastes = list("cukierki" = 1, "owady" = 1)
	foodtypes = JUNKFOOD | SUGAR | BUGS
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

//Chocolates
/obj/item/food/chocolatebar
	name = "tabliczka czekolady"
	desc = "Jakie słodkie, tuczące jedzenie."
	icon_state = "chocolatebar"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/cocoa = 2,
	)
	tastes = list("czekolada" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/chococoin
	name = "czekoladowa moneta"
	desc = "Całkowicie jadalna, ale nienadająca się do rzucania świąteczna moneta."
	icon_state = "chococoin"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/cocoa = 1,
		/datum/reagent/consumable/sugar = 1,
	)
	tastes = list("czekolada" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fudgedice
	name = "kostka do gry z krówki"
	desc = "Mała czekoladowa kostka, która smakuje słabiej, jeśli zjesz ich za dużo naraz."
	icon_state = "chocodice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/cocoa = 1,
		/datum/reagent/consumable/sugar = 1,
	)
	trash_type = /obj/item/dice/fudge
	tastes = list("krówki" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/chocoorange
	name = "czekoladowa pomarańcza"
	desc = "Świąteczna czekoladowa pomarańcza."
	icon_state = "chocoorange"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 1,
	)
	tastes = list("czekolada" = 3, "pomarańcze" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/bonbon
	name = "czekoladka"
	desc = "Malutka, słodka czekoladka."
	icon_state = "tiny_chocolate"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("czekolada" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

// Gum

///obj/item/food/bubblegum Need to port this some time

/obj/item/food/gumball
	name = "kulka gumy do żucia"
	desc = "Kolorowa, słodka kulka gumy do żucia."
	icon = 'icons/obj/food/lollipop.dmi'
	icon_state = "gumball"
	worn_icon_state = "bubblegum"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/bicaridine = 2,
		/datum/reagent/medicine/kelotane = 2
	)	//Kek
	tastes = list("cukierki")
	foodtypes = JUNKFOOD
	food_flags = FOOD_FINGER_FOOD
	slot_flags = ITEM_SLOT_MASK
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/gumball/Initialize(mapload)
	. = ..()
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

/obj/item/food/gumball/cyborg
	var/spamchecking = TRUE

/obj/item/food/gumball/cyborg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spamcheck)), 1200)

/obj/item/food/gumball/cyborg/equipped(mob/living/user, slot)
	. = ..(user, slot)
	spamchecking = FALSE

/obj/item/food/gumball/cyborg/proc/spamcheck()
	if(spamchecking)
		qdel(src)

// Lollipop
/obj/item/food/lollipop
	name = "lizak"
	desc = "Pyszny lizak. Świetny prezent na walentynki."
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick"
	item_state = null
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/iron = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/omnizine = 2
	)
	tastes = list("cukierki" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	slot_flags = ITEM_SLOT_MASK
	w_class = WEIGHT_CLASS_TINY
	var/mutable_appearance/head
	var/headcolor = rgb(0, 0, 0)
	///Essentially IsEquipped
	var/chewing = TRUE
	///Time between bites
	var/bite_frequency = 30 SECONDS
	///ID for timer
	var/timer_id

/obj/item/food/lollipop/Initialize(mapload)
	. = ..()
	head = mutable_appearance('icons/obj/lollipop.dmi', "lollipop_head")
	change_head_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))

/obj/item/food/lollipop/proc/change_head_color(C)
	headcolor = C
	cut_overlay(head)
	head.color = C
	add_overlay(head)

/obj/item/food/lollipop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..(hit_atom)
	throw_speed = 1
	throwforce = 0

/obj/item/food/lollipop/Destroy()
	if(timer_id)
		deltimer(timer_id)
	..()

/obj/item/food/lollipop/equipped(mob/user, slot)
	. = ..()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	chewing = (slot == ITEM_SLOT_MASK ? TRUE : FALSE)
	if(chewing) //Set a timer to chew(), instead of calling chew for the convenience of being able to equip/unequip our pop
		timer_id = addtimer(CALLBACK(src, PROC_REF(chew)), bite_frequency, TIMER_STOPPABLE)

/obj/item/food/lollipop/dropped(mob/user)
	. = ..()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/obj/item/food/lollipop/proc/chew()
	if(iscarbon(loc) && chewing)
		var/mob/living/carbon/M = loc
		if(M.health <= 0)
			return
		attack(M, M)
		timer_id = addtimer(CALLBACK(src, PROC_REF(chew)), bite_frequency, TIMER_STOPPABLE)

/obj/item/food/lollipop/long
	name = "długi lizak"
	desc = "Dwa razy większy, o połowę mniej smaku!"
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick_long"

/obj/item/food/lollipop/long/equipped(mob/user, slot)
	..()
	if(chewing)
		RegisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_trip), user)
	else
		UnregisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN)

/obj/item/food/lollipop/long/proc/on_trip(mob/living/carbon/user)
	visible_message("<span class='danger'>[src] przebija [user]!</span>", "<span class='danger'>[src] cię przebija!</span>")
	user.adjustBruteLoss(50)
	user.adjustOxyLoss(50)

/obj/item/food/lollipop/cyborg
	var/spamchecking = TRUE

/obj/item/food/lollipop/cyborg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spamcheck)), 1200)

/obj/item/food/lollipop/cyborg/equipped(mob/living/user, slot)
	. = ..(user, slot)
	spamchecking = FALSE

/obj/item/food/lollipop/cyborg/proc/spamcheck()
	if(spamchecking)
		qdel(src)

/obj/item/food/spiderlollipop
	name = "pajęczy lizak"
	desc = "Wciąż obrzydliwy, ale przynajmniej ma na sobie górę cukru."
	icon_state = "spiderlollipop"
	worn_icon_state = "lollipop_stick"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/toxin = 1,
		/datum/reagent/iron = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/omnizine = 2,
	) //lollipop, but vitamins = toxins
	tastes = list("pajęczyny" = 1, "cukier" = 2)
	foodtypes = JUNKFOOD | SUGAR | BUGS
	food_flags = FOOD_FINGER_FOOD
	slot_flags = ITEM_SLOT_MASK
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/rock_candy
	name = "cukier kandyzowany"
	desc = "Garść słodkich kryształków na patyku. Dobre dla krwi!\n Ostrzeżenie dla mieszkańców Kalifornii: ten produkt może zawierać ołów, o którym Stan Kalifornia wie, że powoduje raka, wady wrodzone i inne szkody dla zdrowia rozrodczego."
	icon_state = "rock_candy"
	food_reagents = list(
		/datum/reagent/iron = 10,
		/datum/reagent/mercury/lead_acetate = 5, //One couldn't hurt, am I right?
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/omnizine = 2
	)
	tastes = list("marzenia o plażach Kalifornii" = 1, "adamant" = 2)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	crafting_complexity = FOOD_COMPLEXITY_1
