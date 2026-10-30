// Tomato
/obj/item/food/grown/tomato
	seed = /obj/item/plant_seeds/preset/tomato
	name = "pomidor"
	desc = "Ja mówię pomidor, ty mówisz pomidor."
	icon_state = "tomato"
	splat_type = /obj/effect/decal/cleanable/food/tomato_smudge
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/ketchup = 0)
	juice_typepath = /datum/reagent/consumable/tomatojuice
	distill_reagent = /datum/reagent/consumable/enzyme

// Blood Tomato
/obj/item/food/grown/tomato/blood
	name = "krwisty pomidor"
	desc = "Tak krwawy... tak... bardzo... krwawy... AAAA!!!!"
	icon_state = "bloodtomato"
	bite_consumption_mod = 3
	splat_type = /obj/effect/gibspawner/generic/bloodtomato
	foodtypes = FRUIT | GROSS
	grind_results = list(/datum/reagent/consumable/ketchup = 0, /datum/reagent/blood = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/bloody_mary
	discovery_points = 300

/obj/item/food/grown/tomato/blood/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(istype(thrower) && thrower.ckey)
		thrower.investigate_log("has thrown bloodtomatoes at [AREACOORD(thrower)].", INVESTIGATE_BOTANY)
	. = ..()

/obj/item/food/grown/tomato/blood/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(istype(thrower) && thrower.ckey)
		thrower.investigate_log("has thrown bloodtomatoes at [AREACOORD(thrower)].", INVESTIGATE_BOTANY)
	. = ..()

// Blue Tomato
/obj/item/food/grown/tomato/blue
	name = "niebieski pomidor"
	desc = "Ja mówię niebieski pomidor, ty mówisz niebieski pomidor."
	icon_state = "bluetomato"
	bite_consumption_mod = 2
	splat_type = /obj/effect/decal/cleanable/oil
	distill_reagent = /datum/reagent/consumable/laughter
	discovery_points = 300

// Bluespace Tomato
/obj/item/food/grown/tomato/blue/bluespace
	name = "bluespace'owy pomidor"
	desc = "Tak śliski, że można się poślizgnąć w czasoprzestrzeni."
	icon_state = "bluespacetomato"
	bite_consumption_mod = 3
	distill_reagent = null
	wine_power = 80
	discovery_points = 300

// Killer Tomato
/obj/item/food/grown/tomato/killer
	name = "pomidor zabójca"
	desc = "Ja mówię pomidor, ty mówisz pomidor... O BOŻE, ON MI JE NOGI!!"
	icon_state = "killertomato"
	var/awakening = FALSE
	filling_color = "#FF0000"
	distill_reagent = /datum/reagent/consumable/ethanol/demonsblood
	discovery_points = 300
