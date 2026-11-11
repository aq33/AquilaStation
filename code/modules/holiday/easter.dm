/datum/round_event_control/easter
	name = "Easter Eggselence"
	holidayID = EASTER
	typepath = /datum/round_event/easter
	weight = -1
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/easter/announce(fake)
	priority_announce(pick("Wskakuj w Wielkanoc!","Znajdź skrytkę zajączka!","Dziś Narodowy Dzień Polowania na Króliki.","Bądź miły, dawaj czekoladowe jajka!"), sound = SSstation.announcer.get_rand_alert_sound())


/datum/round_event_control/rabbitrelease
	name = "Release the Rabbits!"
	holidayID = EASTER
	typepath = /datum/round_event/rabbitrelease
	weight = 5
	max_occurrences = 10

/datum/round_event/rabbitrelease/announce(fake)
	priority_announce("Wykryto niezidentyfikowane puchate obiekty wchodzące na pokład [station_name()]. Uwaga na uroczość.", "Puchaty alarm", ANNOUNCER_ALIENS)


/datum/round_event/rabbitrelease/start()
	for(var/obj/effect/landmark/R in GLOB.landmarks_list)
		if(R.name != "blobspawn")
			if(prob(35))
				if(isspaceturf(R.loc))
					new /mob/living/basic/rabbit/easter/space(R.loc) // AQ EDIT - basic moby
				else
					new /mob/living/basic/rabbit/easter(R.loc) // AQ EDIT - basic moby

// AQ EDIT - króliki są basic mobami (aquila/code/modules/mob/living/basic/farm_animals/rabbit.dm)

//Easter Baskets
/obj/item/storage/bag/easterbasket
	name = "koszyczek wielkanocny"
	icon = 'icons/mob/easter.dmi'
	icon_state = "basket"

/obj/item/storage/bag/easterbasket/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/food/egg, /obj/item/food/chocolateegg, /obj/item/food/boiledegg))

/obj/item/storage/bag/easterbasket/proc/countEggs()
	cut_overlays()
	add_overlay("basket-grass")
	add_overlay("basket-egg[min(contents.len, 5)]")

/obj/item/storage/bag/easterbasket/Exited(atom/movable/gone, direction)
	. = ..()
	countEggs()

/obj/item/storage/bag/easterbasket/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	countEggs()

//Bunny Suit
/obj/item/clothing/head/bunnyhead
	name = "głowa zajączka wielkanocnego"
	icon_state = "bunnyhead"
	item_state = "bunnyhead"
	desc = "Znacznie słodsza niż „Frank”."
	slowdown = -1
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/bunnysuit
	name = "strój zajączka wielkanocnego"
	desc = "Hop, hop, hop!"
	icon_state = "bunnysuit"
	item_state = "bunnysuit"
	slowdown = -1
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

//Egg prizes and egg spawns!
/obj/item/suprise_egg // AQ EDIT - jedna ścieżka jajka niespodzianki (wcześniej wygląd był na surprise_egg, a procedury na suprise_egg)
	name = "zawinięte jajko"
	desc = "Czekoladowe jajko z małą niespodzianką w środku. Rozpakuj i ciesz się!"
	icon_state = "egg"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/food/egg.dmi'
	//lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	//righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME

/obj/item/suprise_egg/loaded/Initialize(mapload)
	. = ..()
	var/eggcolor = pick("blue","green","mime","orange","purple","rainbow","red","yellow")
	icon_state = "egg-[eggcolor]"

/obj/item/suprise_egg/proc/dispensePrize(turf/where)
	var/static/list/prize_list = list(/obj/item/clothing/head/bunnyhead,
	/obj/item/clothing/suit/bunnysuit,
	/obj/item/food/grown/carrot,
	/obj/item/food/chocolateegg,
	/obj/item/toy/balloon,
	/obj/item/toy/gun,
	/obj/item/toy/sword,
	/obj/item/toy/foamblade,
	/obj/item/toy/prize/ripley,
	/obj/item/toy/prize/honk,
	/obj/item/toy/plush/carpplushie,
	/obj/item/toy/redbutton,
	/obj/item/clothing/head/collectable/rabbitears)
	var/won = pick(prize_list)
	new won(where)
	new/obj/item/food/chocolateegg(where)

/obj/item/suprise_egg/attack_self(mob/user)
	..()
	to_chat(user, "<span class='notice'>Rozpakowujesz [src] i znajdujesz w środku nagrodę!</span>")
	dispensePrize(get_turf(user))
	qdel(src)

//Easter Recipes + food
/obj/item/food/hotcrossbun
	bite_consumption = 2
	name = "bułeczka z krzyżykiem"
	desc = "Krzyż symbolizuje asystentów, którzy zginęli za twoje grzechy."
	icon_state = "hotcrossbun"
	foodtypes = SUGAR | GRAIN
	tastes = list("Wielkanoc")
	crafting_complexity = FOOD_COMPLEXITY_1

/datum/crafting_recipe/food/hotcrossbun
	name = "bułeczka z krzyżykiem"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/datum/reagent/consumable/sugar = 1
	)
	result = /obj/item/food/hotcrossbun
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/briochecake
	name = "wieniec z brioszek"
	reqs = list(
		/obj/item/food/cake/plain = 1,
		/datum/reagent/consumable/sugar = 2
	)
	result = /obj/item/food/cake/brioche
	subcategory = CAT_MISCFOOD

/obj/item/food/scotchegg
	name = "jajko po szkocku"
	desc = "Jajko na twardo w pysznym, przyprawionym mielonym mięsie."
	icon = 'icons/obj/food/egg.dmi'
	icon_state = "scotchegg"
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	crafting_complexity = FOOD_COMPLEXITY_2

/datum/crafting_recipe/food/scotchegg
	name = "jajko po szkocku"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meatball = 1
	)
	result = /obj/item/food/scotchegg
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/mammi
	name = "mämmi"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/food/soup/mammi
	subcategory = CAT_MISCFOOD

/obj/item/food/chocolatebunny
	name = "czekoladowy zajączek"
	desc = "Zawiera mniej niż 10% prawdziwego królika!"
	icon_state = "chocolatebunny"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	crafting_complexity = FOOD_COMPLEXITY_1

/datum/crafting_recipe/food/chocolatebunny
	name = "czekoladowy zajączek"
	reqs = list(
		/datum/reagent/consumable/sugar = 2,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chocolatebunny
	subcategory = CAT_MISCFOOD
