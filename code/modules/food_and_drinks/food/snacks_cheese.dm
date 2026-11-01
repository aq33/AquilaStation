///////////////////////////////////////////CHEESE////////////////////////////////////////////
// Our cheese varieties (ser, #202) on top of newfood /obj/item/food/cheese.
// Every wheel slices into its own wedge through slice_type (see cheese.dm).

//cheesemix
/obj/item/food/cheesemix
	name = "masa serowa"
	icon_state = "cheesemix"
	icon = 'icons/obj/food/cheese.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("gorzkie mleko" = 1)
	desc = "Masa serowa gotowa do podgrzania."
	foodtypes = DAIRY

/obj/item/food/cheesemix_heated
	name = "podgrzana masa serowa"
	icon_state = "cheesemix_heated"
	icon = 'icons/obj/food/cheese.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("gorzki ser" = 1)
	desc = "Podgrzana masa serowa, w której pływają grudki twarogu."
	foodtypes = DAIRY

//american cheese
/obj/item/food/cheese/wheel/american
	name = "blok sera amerykańskiego"
	desc = "Blok amerykańskiego plastikowego sera."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "american_block"
	slice_type = /obj/item/food/cheese/wedge/american
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("plastik" = 1)

/obj/item/food/cheese/wedge/american
	name = "plaster sera amerykańskiego"
	desc = "Plaster amerykańskiego plastikowego sera. Nic nie może być bardziej sztuczne."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "american_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("plastik" = 1)

//blue
/obj/item/food/cheese/wheel/blue
	name = "krąg sera pleśniowego"
	desc = "Duży krąg sera pleśniowego."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "blue_wheel"
	slice_type = /obj/item/food/cheese/wedge/blue
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("pleśń" = 1)

/obj/item/food/cheesemix/blue
	name = "masa na ser pleśniowy"
	microwaved_type = /obj/item/food/cheesemix_heated/blue

/obj/item/food/cheesemix_heated/blue
	name = "podgrzana masa na ser pleśniowy"

/obj/item/food/cheese/wedge/blue
	name = "kawałek sera pleśniowego"
	desc = "Kawałek sera pleśniowego. Pleśń wyraźnie odcina się od białego, kremowego sera."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "blue_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pleśń" = 1)

//brie
/obj/item/food/cheese/wheel/brie
	name = "krąg brie"
	desc = "Duży krąg brie."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "brie_wheel"
	slice_type = /obj/item/food/cheese/wedge/brie
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("kremowa pleśń" = 1)

/obj/item/food/cheesemix/brie
	name = "masa na brie"
	microwaved_type = /obj/item/food/cheesemix_heated/brie

/obj/item/food/cheesemix_heated/brie
	name = "podgrzana masa na brie"

/obj/item/food/cheese/wedge/brie
	name = "kawałek brie"
	desc = "Kawałek brie. Idealny z krakersem."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "brie_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("kremowa pleśń" = 1)

//cheddar
/obj/item/food/cheese/wheel/cheddar
	name = "krąg cheddara"
	desc = "Duży krąg pysznego cheddara."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "cheesewheel"
	slice_type = /obj/item/food/cheese/wedge/cheddar
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cheddar" = 1)

/obj/item/food/cheese/wheel/cheddar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_SCATTER, max_ingredients = 6)

/obj/item/food/cheese/wheel/cheddar/welder_act(mob/living/user, obj/item/W)
	if(W.use_tool(src, user, 0, volume=40))
		var/obj/item/stack/sheet/cheese/NR = new (user.loc, 5)
		to_chat(user, "<span class='notice'>Za pomocą [W] formujesz z [src] ser o solidniejszym wyglądzie.")
		for(var/obj/item/stack/sheet/cheese/R in user.loc)
			if(R == NR)
				continue
			if(R.amount >= R.max_amount)
				continue
		qdel(src)
	return TRUE

/obj/item/food/cheesemix/cheddar
	name = "masa na cheddar"
	microwaved_type = /obj/item/food/cheesemix_heated/cheddar

/obj/item/food/cheesemix_heated/cheddar
	name = "podgrzana masa na cheddar"

/obj/item/food/cheese/wedge/cheddar
	name = "kawałek cheddara"
	desc = "Kawałek pysznego cheddara. Krąg, z którego go odkrojono, nie mógł uciec daleko."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "cheesewheel_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cheddar" = 1)

//feta
/obj/item/food/cheese/wheel/feta
	name = "blok fety"
	desc = "Duży blok fety."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "feta_block"
	slice_type = /obj/item/food/cheese/wedge/feta
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("owca" = 1)

/obj/item/food/cheesemix/feta
	name = "masa na fetę"
	microwaved_type = /obj/item/food/cheesemix_heated/feta

/obj/item/food/cheesemix_heated/feta
	name = "podgrzana masa na fetę"

/obj/item/food/cheese/wedge/feta
	name = "plaster fety"
	desc = "Plaster fety. Łatwo kruszy się w dłoniach."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "feta_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("owca" = 1)

//goat
/obj/item/food/cheese/wheel/goat
	name = "krąg koziego sera"
	desc = "Duży krąg koziego sera."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "goat_wheel"
	slice_type = /obj/item/food/cheese/wedge/goat
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("koza" = 1)

/obj/item/food/cheesemix/goat
	name = "masa na kozi ser"
	microwaved_type = /obj/item/food/cheesemix_heated/goat

/obj/item/food/cheesemix_heated/goat
	name = "podgrzana masa na kozi ser"

/obj/item/food/cheese/wedge/goat
	name = "kawałek koziego sera"
	desc = "Kawałek koziego sera. Mocno pachnie kozą."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "goat_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("koza" = 1)

//halloumi
/obj/item/food/cheese/wheel/halloumi
	name = "blok halloumi"
	desc = "Duży blok sera halloumi."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "halloumi_block"
	slice_type = /obj/item/food/cheese/wedge/halloumi
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("mięso" = 1)

/obj/item/food/cheesemix/halloumi
	name = "masa na halloumi"
	microwaved_type = /obj/item/food/cheesemix_heated/halloumi

/obj/item/food/cheesemix_heated/halloumi
	name = "podgrzana masa na halloumi"

/obj/item/food/cheese/wedge/halloumi
	name = "plaster halloumi"
	desc = "Plaster sera halloumi. Zamiennik mięsa dla wegetarian."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "halloumi_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("mięso" = 1)

//mozzarella
/obj/item/food/cheese/wheel/mozzarella
	name = "kula mozzarelli"
	desc = "Duża kula mozzarelli."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "mozzarella_ball"
	slice_type = /obj/item/food/cheese/wedge/mozzarella
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("śmietana" = 1)

/obj/item/food/cheesemix/mozzarella
	name = "masa na mozzarellę"
	microwaved_type = /obj/item/food/cheesemix_heated/mozzarella

/obj/item/food/cheesemix_heated/mozzarella
	name = "podgrzana masa na mozzarellę"

/obj/item/food/cheese/wedge/mozzarella
	name = "kawałek mozzarelli"
	desc = "Kawałek mozzarelli. Musi jak najszybciej trafić na pizzę."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "mozzarella_piece"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("śmietana" = 1)

//parmesan
/obj/item/food/cheese/wheel/parmesan
	name = "krąg parmezanu"
	desc = "Duży krąg parmezanu."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "parmesan_wheel"
	bite_consumption = 5
	max_volume = 200
	slice_type = /obj/item/food/cheese/wedge/parmesan
	food_reagents = list(/datum/reagent/consumable/nutriment = 100, /datum/reagent/consumable/nutriment/vitamin = 30, /datum/reagent/consumable/parmesan_delight = 20)
	tastes = list("sól" = 1, "wspaniałość" = 1, "Włochy" = 1)

/obj/item/food/cheese/preparmesan
	name = "krąg niedojrzałego parmezanu"
	desc = "Duży krąg niedojrzałego parmezanu."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "preparmesan_wheel"
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("gorzka sól" = 1)

/obj/item/food/cheese/preparmesan/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(ageCheese)), 20 MINUTES)

/obj/item/food/cheese/preparmesan/proc/ageCheese()
	new /obj/item/food/cheese/wheel/parmesan(loc)
	qdel(src)

/obj/item/food/cheesemix/parmesan
	name = "masa na parmezan"
	microwaved_type = /obj/item/food/cheesemix_heated/parmesan

/obj/item/food/cheesemix_heated/parmesan
	name = "podgrzana masa na parmezan"

/obj/item/food/cheese/wedge/parmesan
	name = "kawałek parmezanu"
	desc = "Kawałek parmezanu. Trzymając go, czujesz się niesamowicie rzemieślniczo."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "parmesan_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/parmesan_delight = 4)
	tastes = list("sól" = 1, "wspaniałość" = 1, "Włochy" = 1)

//swiss
/obj/item/food/cheese/wheel/swiss
	name = "krąg sera szwajcarskiego"
	desc = "Duży krąg sera szwajcarskiego."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "swiss_wheel"
	slice_type = /obj/item/food/cheese/wedge/swiss
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("dziury" = 1)

/obj/item/food/cheesemix/swiss
	name = "masa na ser szwajcarski"
	microwaved_type = /obj/item/food/cheesemix_heated/swiss

/obj/item/food/cheesemix_heated/swiss
	name = "podgrzana masa na ser szwajcarski"

/obj/item/food/cheese/wedge/swiss
	name = "kawałek sera szwajcarskiego"
	desc = "Kawałek sera szwajcarskiego. Dziury odpowiadają ci echem: „zjedz mnie”."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "swiss_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("dziury" = 1)

//bug cheese
/obj/item/food/cheese/wheel/bug
	name = "kula robaczego sera"
	desc = "Duża kula „miodu” gutlunchów o konsystencji podobnej do sera."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "bug_ball"
	foodtypes = SUGAR | MEAT //honey made by a carnivorous scavenging bug
	slice_type = /obj/item/food/cheese/wedge/bug
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("spora porcja cukru" = 1, "mięso" = 1)

/obj/item/food/cheese/wedge/bug
	name = "kawałek robaczego sera"
	desc = "Kawałek „miodu” gutlunchów."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "bug_piece"
	foodtypes = SUGAR | MEAT
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("spora porcja cukru" = 1, "mięso" = 1)

//Regal rat cheese
/obj/item/food/royalcheese
	name = "królewski ser"
	desc = "Wstąp na tron. Pochłoń krąg. Poczuj MOC."
	icon_state = "royalcheese"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/gold = 20, /datum/reagent/toxin/mutagen = 5)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("ser" = 4, "królewskość" = 1)
	foodtypes = DAIRY
