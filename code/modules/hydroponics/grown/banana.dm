// Banana
/obj/item/food/grown/banana
	seed = /obj/item/plant_seeds/preset/banana
	name = "banan"
	desc = "Świetny rekwizyt dla klauna."
	icon_state = "banana"
	item_state = "banana"
	trash_type = /obj/item/grown/bananapeel
	bite_consumption_mod = 3
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/banana
	distill_reagent = /datum/reagent/consumable/ethanol/bananahonk

/* Wounds
/obj/item/food/grown/banana/generate_trash(atom/location)
	. = ..()
	var/obj/item/grown/bananapeel/peel = .
	if(istype(peel))
		peel.grind_results = list(/datum/reagent/medicine/coagulant/banana_peel = seed.potency * 0.2)
		peel.juice_typepath = /datum/reagent/medicine/coagulant/banana_peel
*/

/obj/item/food/grown/banana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] celuje [src] w siebie! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	sleep(25)
	if(!user)
		return (OXYLOSS)
	user.say("BUM!", forced = /datum/reagent/consumable/banana)
	sleep(25)
	if(!user)
		return (OXYLOSS)
	user.visible_message("<B>[user]</B> śmieje się tak mocno, że zaczyna się dusić!")
	return (OXYLOSS)

//Banana Peel
/obj/item/grown/bananapeel
	name = "skórka od banana"
	desc = "Skórka od banana."
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/grown/bananapeel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 40)

/obj/item/grown/bananapeel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] celowo poślizguje się na [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	return (BRUTELOSS)


// Mimana - invisible sprites are totally a feature!
/obj/item/food/grown/banana/mime
	name = "mimana"
	desc = "Świetny rekwizyt dla mima."
	icon_state = "mimana"
	trash_type = /obj/item/grown/bananapeel/mimanapeel
	distill_reagent = /datum/reagent/consumable/ethanol/silencer
	discovery_points = 300

/obj/item/grown/bananapeel/mimanapeel
	name = "skórka od mimany"
	desc = "Skórka od mimany."
	icon_state = "mimana_peel"
	item_state = "mimana_peel"

// Bluespace Banana
/obj/item/food/grown/banana/bluespace
	name = "bluespace'owy banan"
	icon_state = "banana_blue"
	item_state = "bluespace_peel"
	trash_type = /obj/item/grown/bananapeel/bluespace
	tastes = list("banan" = 1)
	wine_power = 60
	wine_flavor = "śliskie hipersześciany"
	discovery_points = 300

/obj/item/grown/bananapeel/bluespace
	name = "skórka od bluespace'owego banana"
	desc = "Skórka od bluespace'owego banana."
	icon_state = "banana_peel_blue"

// Other
/obj/item/grown/bananapeel/specialpeel //used by /obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "syntetyczna skórka od banana"
	desc = "Syntetyczna skórka od banana."

/obj/item/grown/bananapeel/specialpeel/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 40, null, 20, TRUE) //NSV13 - re-added stun and accidents
