/obj/item/food/cake
	name = "ciasto bazowe"
	desc = "Albo zespawnowałeś to przez pomyłkę, albo zrobił to koder. Tak czy inaczej, ktoś coś zepsuł."
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "ERROR"
	bite_consumption = 3
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("ciasto" = 1)
	foodtypes = GRAIN | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2
	/// type is spawned 5 at a time and replaces this cake when processed by cutting tool
	var/obj/item/food/cakeslice/slice_type
	/// changes yield of sliced cake, default for cake is 5
	var/yield = 5

/obj/item/food/cake/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/food_storage)

/obj/item/food/cake/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, 3 SECONDS, table_required = TRUE)

/obj/item/food/cakeslice
	name = "kawałek ciasta bazowego"
	desc = "Albo zespawnowałeś to przez pomyłkę, albo zrobił to koder. Tak czy inaczej, ktoś coś zepsuł."
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "ERROR"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("ciasto" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cake/plain
	name = "zwykłe ciasto"
	desc = "Zwykłe ciasto, a nie kłamstwo." //Many of the cakes seem to follow this desc scheme, so I am going to try and put either a hint about its contents, or a fun fact. Lets try to follow this.
	icon_state = "plaincake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 30,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	tastes = list("słodycz" = 2, "ciasto" = 5)
	foodtypes = GRAIN | DAIRY | SUGAR
	slice_type = /obj/item/food/cakeslice/plain
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/plain
	name = "kawałek zwykłego ciasta"
	desc = "Po prostu kawałek ciasta, starczy dla wszystkich."
	icon_state = "plaincake_slice"
	tastes = list("słodycz" = 2,"ciasto" = 5)
	foodtypes = GRAIN | DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/carrot
	name = "ciasto marchewkowe"
	desc = "Naukowo udowodniono, że poprawia wzrok! To nie kłamstwo."
	icon_state = "carrotcake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "marchewka" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR
	slice_type = /obj/item/food/cakeslice/carrot
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/carrot
	name = "kawałek ciasta marchewkowego"
	desc = "Marchewkowy kawałek ciasta marchewkowego, marchewki są dobre na oczy! To też nie kłamstwo."
	icon_state = "carrotcake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "marchewka" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/brain
	name = "ciasto mózgowe"
	desc = "No tak... naprawdę jest zrobione z mózgu. Szkoda, że to nie kłamstwo."
	icon_state = "braincake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/medicine/mannitol = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "mózg" = 1)
	foodtypes = GRAIN | DAIRY | MEAT | GROSS | SUGAR
	slice_type = /obj/item/food/cakeslice/brain
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/brain
	name = "kawałek ciasta mózgowego"
	desc = "Powiem ci coś o prionach. SĄ PYSZNE. Przerażające nie-kłamstwo."
	icon_state = "braincakeslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/mannitol = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "mózg" = 1)
	foodtypes = GRAIN | DAIRY | MEAT | GROSS | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/cheese
	name = "sernik"
	desc = "NIEBEZPIECZNIE serowy."
	icon_state = "cheesecake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 8
	)
	tastes = list("ciasto" = 4, "serek śmietankowy" = 3)
	foodtypes = GRAIN | DAIRY
	slice_type = /obj/item/food/cakeslice/cheese
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/cheese
	name = "kawałek sernika"
	desc = "Kawałek czystej serosatysfakcji."
	icon_state = "cheesecake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1.3
	)
	tastes = list("ciasto" = 4, "serek śmietankowy" = 3)
	foodtypes = GRAIN | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/orange
	name = "ciasto pomarańczowe"
	desc = "Ciasto z dodatkiem pomarańczy."
	icon_state = "orangecake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "pomarańcze" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/orange
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/orange
	name = "kawałek ciasta pomarańczowego"
	desc = "Po prostu kawałek ciasta, starczy dla wszystkich."
	icon_state = "orangecake_slice"
	tastes = list("ciasto" = 5, "słodycz" = 2, "pomarańcze" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/lime
	name = "ciasto limonkowe"
	desc = "Ciasto z dodatkiem limonki."
	icon_state = "limecake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
		)
	tastes = list("ciasto" = 5, "słodycz" = 2, "nieznośna kwaśność" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/lime
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/lime
	name = "kawałek ciasta limonkowego"
	desc = "Po prostu kawałek ciasta, starczy dla wszystkich."
	icon_state = "limecake_slice"
	tastes = list("ciasto" = 5, "słodycz" = 2, "nieznośna kwaśność" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/lemon
	name = "ciasto cytrynowe"
	desc = "Ciasto z dodatkiem cytryny."
	icon_state = "lemoncake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
		)
	tastes = list("ciasto" = 5, "słodycz" = 3, "kwaśność" = 1) //lemon cake is never as sour as it is sweet, have you ever actually eaten it?
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/lemon
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/lemon
	name = "kawałek ciasta cytrynowego"
	desc = "Po prostu kawałek ciasta, starczy dla wszystkich."
	icon_state = "lemoncake_slice"
	tastes = list("ciasto" = 5, "słodycz" = 2, "kwaśność" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/chocolate
	name = "ciasto czekoladowe"
	desc = "Ciasto z dodatkiem czekolady."
	icon_state = "chocolatecake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "czekolada" = 4)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR
	slice_type = /obj/item/food/cakeslice/chocolate
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/chocolate
	name = "kawałek ciasta czekoladowego"
	desc = "Po prostu kawałek ciasta, starczy dla wszystkich."
	icon_state = "chocolatecake_slice"
	tastes = list("ciasto" = 5, "słodycz" = 1, "czekolada" = 4)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/birthday
	name = "tort urodzinowy"
	desc = "Wszystkiego najlepszego, mały klaunie..."
	icon_state = "birthdaycake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/sprinkles = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("ciasto" = 5, "słodycz" = 1)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR
	slice_type = /obj/item/food/cakeslice/birthday
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/birthday/microwave_act(obj/machinery/microwave/M) //super sekrit club
	new /obj/item/clothing/head/hardhat/cakehat(get_turf(src))
	qdel(src)

/obj/item/food/cakeslice/birthday
	name = "kawałek tortu urodzinowego"
	desc = "Kawałek twoich urodzin."
	icon_state = "birthdaycakeslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sprinkles = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("ciasto" = 5, "słodycz" = 1)
	foodtypes = GRAIN | DAIRY | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/birthday/energy
	name = "energetyczny tort"
	desc = "Akurat tyle kalorii, ile potrzeba całemu oddziałowi operatorów nuklearnych."
	icon_state = "energycake"
	force = 5
	hitsound = 'sound/weapons/blade1.ogg'
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/sprinkles = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/pwr_game = 10,
		/datum/reagent/consumable/liquidelectricity = 10
	)
	tastes = list("ciasto" = 3, "Sałatka Vlada" = 1)
	slice_type = /obj/item/food/cakeslice/birthday/energy
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cake/birthday/energy/microwave_act(obj/machinery/microwave/M) //super sekriter club
	new /obj/item/clothing/head/hardhat/cakehat/energycake(get_turf(src))
	qdel(src)

/obj/item/food/cake/birthday/energy/proc/energy_bite(mob/living/user)
	to_chat(user, "<font color='red' size='5'>Jedząc ciasto, przypadkiem kaleczysz się o ukryty w nim miecz energetyczny!</font>")
	user.apply_damage(30, BURN, BODY_ZONE_HEAD) // ITs an ENERGY sword, so it burns, duh
	playsound(user, 'sound/weapons/blade1.ogg', 5, TRUE)

/obj/item/food/cake/birthday/energy/attack(mob/living/target_mob, mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && target_mob != user) //Prevents pacifists from attacking others directly
		return
	energy_bite(target_mob, user)

/obj/item/food/cakeslice/birthday/energy
	name = "kawałek energetycznego tortu"
	desc = "Dla zdrajcy w biegu."
	icon_state = "energycakeslice"
	force = 2
	hitsound = 'sound/weapons/blade1.ogg'
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sprinkles = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/pwr_game = 2,
		/datum/reagent/consumable/liquidelectricity = 2
	)
	tastes = list("ciasto" = 3, "Sałatka Vlada" = 1)
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cakeslice/birthday/energy/proc/energy_bite(mob/living/user)
	to_chat(user, "<font color='red' size='5'>Jedząc kawałek ciasta, przypadkiem kaleczysz się o ukryty w nim sztylet energetyczny!</font>")
	user.apply_damage(18, BURN, BODY_ZONE_HEAD)
	playsound(user, 'sound/weapons/blade1.ogg', 5, TRUE)

/obj/item/food/cakeslice/birthday/energy/attack(mob/living/target_mob, mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && target_mob != user) //Prevents pacifists from attacking others directly
		return
	energy_bite(target_mob, user)

/obj/item/food/cake/apple
	name = "ciasto jabłkowe"
	desc = "Ciasto z jabłkiem w środku."
	icon_state = "applecake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "jabłko" = 1)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/apple
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/apple
	name = "kawałek ciasta jabłkowego"
	desc = "Kawałek niebiańskiego ciasta."
	icon_state = "applecakeslice"
	tastes = list("ciasto" = 5, "słodycz" = 1, "jabłko" = 1)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/slimecake
	name = "ciasto ze szlamu"
	desc = "Ciasto zrobione ze szlamów. Raczej nie jest pod napięciem."
	icon_state = "slimecake"
	tastes = list("ciasto" = 5, "słodycz" = 1, "szlam" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	slice_type = /obj/item/food/cakeslice/slimecake
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/slimecake
	name = "kawałek ciasta ze szlamu"
	desc = "Kawałek ciasta ze szlamu."
	icon_state = "slimecake_slice"
	tastes = list("ciasto" = 5, "słodycz" = 1, "szlam" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/pumpkinspice
	name = "ciasto dyniowe z przyprawami"
	desc = "Puste w środku ciasto z prawdziwą dynią."
	icon_state = "pumpkinspicecake"
	tastes = list("ciasto" = 5, "słodycz" = 1, "dynia" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR
	slice_type = /obj/item/food/cakeslice/pumpkinspice
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/pumpkinspice
	name = "kawałek ciasta dyniowego z przyprawami"
	desc = "Korzenny kawałek dyniowej rozkoszy."
	icon_state = "pumpkinspicecakeslice"
	tastes = list("ciasto" = 5, "słodycz" = 1, "dynia" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/berry_vanilla_cake // blackberry strawberries vanilla cake
	name = "waniliowe ciasto z jeżynami i truskawkami"
	desc = "Zwykłe ciasto wypełnione jeżynami i truskawkami!"
	icon_state = "blackberry_strawberries_cake_vanilla_cake"
	tastes = list("jeżyna" = 2, "truskawki" = 2, "wanilia" = 2, "słodycz" = 2, "ciasto" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/berry_vanilla_cake
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/berry_vanilla_cake
	name = "kawałek waniliowego ciasta z jeżynami i truskawkami"
	desc = "Po prostu kawałek ciasta wypełniony jeżynami i truskawkami!"
	icon_state = "blackberry_strawberries_cake_vanilla_slice"
	tastes = list("jeżyna" = 2, "truskawki" = 2, "wanilia" = 2, "słodycz" = 2,"ciasto" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/berry_chocolate_cake // blackbarry strawberries chocolate cake <- this is a relic from before resprite
	name = "czekoladowe ciasto z truskawkami"
	desc = "Czekoladowe ciasto z pięcioma truskawkami na wierzchu. Z jakiegoś powodu taki układ ciasta szczególnie zachwyca estetycznie SI z SELF."
	icon_state = "liars_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/cocoa = 5
	)
	tastes = list("jeżyna" = 2, "truskawki" = 2, "czekolada" = 4, "słodycz" = 2,"ciasto" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/berry_chocolate_cake
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cakeslice/berry_chocolate_cake
	name = "kawałek czekoladowego ciasta z truskawkami"
	desc = "Po prostu kawałek ciasta z pięcioma truskawkami na wierzchu. Z jakiegoś powodu taki układ ciasta szczególnie zachwyca estetycznie SI z SELF." //yes, I know the one referenced has cherries, but I'm not implementing a new cake today.
	icon_state = "liars_slice"
	tastes = list("truskawki" = 2, "czekolada" = 2, "słodycz" = 2,"ciasto" = 3)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cake/holy_cake
	name = "anielskie ciasto"
	desc = "Ciasto dla aniołów i kapłanów! Zawiera wodę święconą."
	icon_state = "holy_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/water/holywater = 10
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "chmury" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	slice_type = /obj/item/food/cakeslice/holy_cake_slice
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cakeslice/holy_cake_slice
	name = "kawałek anielskiego ciasta"
	desc = "Kawałek niebiańskiego ciasta."
	icon_state = "holy_cake_slice"
	tastes = list("ciasto" = 5, "słodycz" = 1, "chmury" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cake/pound_cake
	name = "ciasto funtowe"
	desc = "Zbite ciasto, które szybko syci."
	icon_state = "pound_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 60,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "ciasto naleśnikowe" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR | JUNKFOOD
	slice_type = /obj/item/food/cakeslice/pound_cake_slice
	yield = 10 //cause its so damn THICC (seriously these things are fucking huge a pound of each ingredient are you kidding)
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cakeslice/pound_cake_slice
	name = "kawałek ciasta funtowego"
	desc = "Kawałek zbitego ciasta, które szybko syci."
	icon_state = "pound_cake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 0.5
	)
	tastes = list("ciasto" = 5, "słodycz" = 5, "ciasto naleśnikowe" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR | JUNKFOOD
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cake/hardware_cake
	name = "ciasto sprzętowe"
	desc = "Tak zwane „ciasto” zrobione z płytek elektronicznych, z którego cieknie kwas..."
	icon_state = "hardware_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/toxin/acid = 15,
		/datum/reagent/oil = 15
		)
	tastes = list("kwas" = 3, "metal" = 4, "szkło" = 5)
	foodtypes = GRAIN | GROSS
	slice_type = /obj/item/food/cakeslice/hardware_cake_slice
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/hardware_cake_slice
	name = "kawałek ciasta sprzętowego"
	desc = "Kawałek płytek elektronicznych i trochę kwasu."
	icon_state = "hardware_cake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/toxin/acid = 3,
		/datum/reagent/oil = 3
	)
	tastes = list("kwas" = 3, "metal" = 4, "szkło" = 5)
	foodtypes = GRAIN | GROSS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/vanilla_cake
	name = "ciasto waniliowe"
	desc = "Ciasto z waniliowym lukrem."
	icon_state = "vanillacake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/vanilla = 15
	)
	tastes = list("ciasto" = 1, "cukier" = 1, "wanilia" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY
	slice_type = /obj/item/food/cakeslice/vanilla_slice
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/vanilla_slice
	name = "kawałek ciasta waniliowego"
	desc = "Kawałek ciasta z waniliowym lukrem."
	icon_state = "vanillacake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/vanilla = 3
	)
	tastes = list("ciasto" = 1, "cukier" = 1, "wanilia" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/clown_cake
	name = "ciasto klauna"
	desc = "Zabawne ciasto z twarzą klauna."
	icon_state = "clowncake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/banana = 15
	)
	tastes = list("ciasto" = 1, "cukier" = 1, "radość" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY
	slice_type = /obj/item/food/cakeslice/clown_slice
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/cakeslice/clown_slice
	name = "kawałek ciasta klauna"
	desc = "Kawałek kiepskich żartów i głupich rekwizytów."
	icon_state = "clowncake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/banana = 3
	)
	tastes = list("ciasto" = 1, "cukier" = 1, "radość" = 10)
	foodtypes = GRAIN | SUGAR | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/cake/trumpet
	name = "ciasto kosmonauty"
	desc = "Ciasto z lukrem z trąbki kosmonauty."
	icon_state = "trumpetcake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/berryjuice = 5
	)
	tastes = list("ciasto" = 4, "fiołki" = 2, "dżem" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/trumpet

/obj/item/food/cakeslice/trumpet
	name = "ciasto kosmonauty"
	desc = "Ciasto z lukrem z trąbki kosmonauty."
	icon_state = "trumpetcakeslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/cream = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/berryjuice = 1
	)
	tastes = list("ciasto" = 4, "fiołki" = 2, "dżem" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cake/brioche
	name = "wieniec z brioszek"
	desc = "Krąg słodkich, glazurowanych bułeczek."
	icon_state = "briochecake"
	tastes = list("ciasto" = 4, "masło" = 2, "śmietana" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	slice_type = /obj/item/food/cakeslice/brioche
	yield = 6
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cakeslice/brioche
	name = "kawałek wieńca z brioszek"
	desc = "Pyszny słodki chleb. Czego więcej trzeba?"
	icon_state = "briochecake_slice"
	crafting_complexity = FOOD_COMPLEXITY_2

/*
/obj/item/food/cake/pavlova
	name = "pavlova"
	desc = "Słodka pavlova z jagodami. Wymyślona w Nowej Zelandii, ale nazwana na cześć rosyjskiej baleriny... I naukowo udowodniono, że najlepiej sprawdza się na przyjęciach!"
	icon_state = "pavlova"
	tastes = list("beza" = 5, "kremowość" = 1, "jagody" = 1)
	foodtypes = DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/pavlova
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cake/pavlova/nuts
	name = "pavlova z orzechami"
	foodtypes = NUTS | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/pavlova/nuts
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cakeslice/pavlova
	name = "kawałek pavlovej"
	desc = "Popękany kawałek pavlovej obłożony jagodami. \
		Udało ci się nawet pokroić go tak, że na twoim kawałku wylądowało więcej jagód. Jak rozkosznie diabelskie."
	icon_state = "pavlova_slice"
	tastes = list("beza" = 5, "kremowość" = 1, "jagody" = 1)
	foodtypes = DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/pavlova/nuts
	foodtypes = NUTS | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cake/fruit
	name = "angielski keks"
	desc = "Porządne, dobre ciasto, co nie?"
	icon_state = "fruitcake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/cherryjelly = 5,
	)
	tastes = list("suszone owoce" = 5, "syrop" = 2, "Boże Narodzenie" = 2)
	force = 7
	throwforce = 7
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	slice_type = /obj/item/food/cakeslice/fruit
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/fruit
	name = "kawałek angielskiego keksu"
	desc = "Porządny, dobry kawałek, co nie?"
	icon_state = "fruitcake_slice1"
	base_icon_state = "fruitcake_slice"
	tastes = list("suszone owoce" = 5, "syrop" = 2, "Boże Narodzenie" = 2)
	force = 2
	throwforce = 2
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/fruit/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon_state][rand(1,3)]"

/obj/item/food/cake/plum
	name = "ciasto śliwkowe"
	desc = "Ciasto ze śliwkami w środku."
	icon_state = "plumcake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10,
		/datum/reagent/impurity/rosenol = 8,
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "śliwka" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	venue_value = FOOD_PRICE_CHEAP
	slice_type = /obj/item/food/cakeslice/plum
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cakeslice/plum
	name = "kawałek ciasta śliwkowego"
	desc = "Kawałek ciasta śliwkowego."
	icon_state = "plumcakeslice"
	tastes = list("ciasto" = 5, "słodycz" = 1, "śliwka" = 2)
	foodtypes = GRAIN | DAIRY | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3
*/
