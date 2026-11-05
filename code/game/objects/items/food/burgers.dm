/obj/item/food/burger
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1
		)
	tastes = list("bułka" = 2, "kotlet wołowy" = 4)
	foodtypes = GRAIN | MEAT //lettuce doesn't make burger a vegetable.
	eat_time = 15 //Quick snack
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/plain
	name = "burger"
	desc = "Fundament każdego pożywnego śniadania."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/plain/Initialize(mapload)
	. = ..()
	if(prob(1))
		new/obj/effect/particle_effect/smoke(get_turf(src))
		playsound(src, 'sound/effects/smoke.ogg', 50, TRUE)
		visible_message("<span class='warning'>O bogowie! [src] jest zrujnowany! Ale może...?</span>")
		name = "hamburger na parze"
		desc = pick("Ach, Starszy Oficerze, witam. Mam nadzieję, że jesteś gotów na niezapomniany obiad!",
		"I nazywasz to hamburgerami na parze, mimo że ewidentnie są z mikrofalówki?",
		"Stacja Aurora 13? O tej porze zmiany, o tej porze roku, w tym sektorze kosmosu, w całości w twojej zamrażarce?",
		"Wiesz, te hamburgery smakują całkiem podobnie do tych z Maltańskiego Sokoła.")
		tastes = list("hamburger z fast foodu" = 1)

/obj/item/food/burger/human
	name = "ludzki burger"
	desc = "Krwawy burger."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("bułka" = 2, "długa świnia" = 4)
	foodtypes = MEAT | GRAIN | GORE
	var/subjectname = ""
	var/subjectjob = null
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/human/CheckParts(list/parts_list)
	..()
	var/obj/item/food/meat/M = locate(/obj/item/food/meat/steak/plain/human) in contents
	if(M)
		subjectname = M.subjectname
		subjectjob = M.subjectjob
		if(subjectname)
			name = "burger ([subjectname])"
		else if(subjectjob)
			name = "burger ([subjectjob])"
		qdel(M)


/obj/item/food/burger/corgi
	name = "burger z corgiego"
	desc = "Ty potworze."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | MEAT | GORE
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/appendix
	name = "burger z wyrostka"
	desc = "Smakuje jak zapalenie wyrostka."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	icon_state = "appendixburger"
	tastes = list("bułka" = 4, "trawa" = 2)
	foodtypes = GRAIN | MEAT | GORE
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/fish
	name = "kanapka fillet-o-karp"
	desc = "Jakby gdzieś krzyczał karp... Oddaj mi ten fillet-o-karp, oddaj mi tego karpia."
	icon_state = "fishburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bułka" = 4, "ryba" = 4)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/tofu
	name = "burger z tofu"
	desc = "Co... to za mięso?"
	icon_state = "tofuburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("bułka" = 4, "tofu" = 4)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/roburger
	name = "roburger"
	desc = "Sałata to jedyny organiczny składnik. Bip."
	icon_state = "roburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/nanomachines = 7,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("bułka" = 4, "sałata" = 2, "breja" = 1)
	foodtypes = GRAIN | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/roburgerbig
	name = "roburger"
	desc = "Ten ogromny kotlet wygląda jak trucizna. Bip."
	icon_state = "roburger"
	max_volume = 120
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/nanomachines = 140,
		/datum/reagent/consumable/nutriment/vitamin = 15
	)
	tastes = list("bułka" = 4, "sałata" = 2, "breja" = 1)
	foodtypes = GRAIN | TOXIC

/obj/item/food/burger/xeno
	name = "ksenoburger"
	desc = "Pachnie żrąco. Smakuje jak herezja."
	icon_state = "xburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	tastes = list("bułka" = 4, "kwas" = 4)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/bearger
	name = "niedźwiburger"
	desc = "Najlepiej podawać na wrrrrrr."
	icon_state = "bearger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/clown
	name = "burger klauna"
	desc = "Smakuje zabawnie..."
	icon_state = "clownburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/mime
	name = "burger mima"
	desc = "Jego smak wymyka się słowom."
	icon_state = "mimeburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/nothing = 6
	)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/brain
	name = "mózgoburger"
	desc = "Dziwnie wyglądający burger. Wygląda niemal na świadomy."
	icon_state = "brainburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/medicine/mannitol = 11,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("bułka" = 4, "mózg" = 2)
	foodtypes = GRAIN | MEAT | GORE
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/ghost
	name = "upiorny burger"
	desc = "Zbyt straszny!"
	icon_state = "ghostburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 13,
		/datum/reagent/consumable/sodiumchloride = 5
	)
	tastes = list("bułka" = 2, "ektoplazma" = 4)
	foodtypes = GRAIN
	alpha = 170
	verb_say = "jęczy"
	verb_yell = "zawodzi"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/ghost/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/food/burger/ghost/process()
	if(!isturf(loc)) //no floating out of bags
		return
	var/paranormal_activity = rand(100)
	switch(paranormal_activity)
		if(97 to 100)
			audible_message("[src] pobrzękuje łańcuchem.")
			playsound(loc,'sound/spookoween/chain_rattling.ogg', 300, TRUE)
		if(91 to 96)
			say(pick("OoOoOoo.", "OoooOOooOoo!!"))
		if(84 to 90)
			dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step(src, dir)
		if(71 to 83)
			step(src, dir)
		if(65 to 70)
			var/obj/machinery/light/L = locate(/obj/machinery/light) in view(4, src)
			if(L)
				L.flicker()
		if(62 to 64)
			playsound(loc,pick('sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg'), 50, TRUE, ignore_walls = FALSE)
		if(61)
			visible_message("[src] wypluwa grudę ektoplazmy!")
			new /obj/effect/decal/cleanable/greenglow/ecto(loc)
			playsound(loc,'sound/effects/splat.ogg', 200, TRUE)

		//If i was less lazy i would make the burger forcefeed itself to a nearby mob here.

/obj/item/food/burger/ghost/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/food/burger/red
	name = "czerwony burger"
	desc = "Idealny, żeby ukryć, że jest spalony na węgiel."
	icon_state = "cburger"
	color = COLOR_RED
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/red = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/orange
	name = "pomarańczowy burger"
	desc = "Zawiera 0% soku."
	icon_state = "cburger"
	color = COLOR_ORANGE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/orange = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/yellow
	name = "żółty burger"
	desc = "Jasny do ostatniego kęsa."
	icon_state = "cburger"
	color = COLOR_YELLOW
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/yellow = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/green
	name = "zielony burger"
	desc = "To nie zepsute mięso, to pomalowane mięso!"
	icon_state = "cburger"
	color = COLOR_GREEN
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/green = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/blue
	name = "niebieski burger"
	desc = "Czy to jest „blue rare”?"
	icon_state = "cburger"
	color = COLOR_BLUE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/blue = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/purple
	name = "fioletowy burger"
	desc = "Królewski i pospolity jednocześnie."
	icon_state = "cburger"
	color = COLOR_PURPLE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/purple = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/black
	name = "czarny burger"
	desc = "Jest rozgotowany."
	icon_state = "cburger"
	color = COLOR_ALMOST_BLACK
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/black = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/white
	name = "biały burger"
	desc = "Pyszny tytan!"
	icon_state = "cburger"
	color = COLOR_WHITE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/white = 10
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/spell
	name = "zaklęty burger"
	desc = "To jest absolutnie Ei Nath."
	icon_state = "spellburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 11
	)
	tastes = list("bułka" = 4, "magia" = 2)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/bigbite
	name = "burger Wielki Kęs"
	desc = "Zapomnij o Big Macu. TO jest przyszłość!"
	icon_state = "bigbiteburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = GRAIN | MEAT | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/jelly
	name = "burger z galaretką"
	desc = "Kulinarna rozkosz..?"
	icon_state = "jellyburger"
	tastes = list("bułka" = 4, "galaretka" = 2)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/jelly/slime
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/slimejelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/jelly/cherry
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/cherryjelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | FRUIT

/obj/item/food/burger/superbite
	name = "burger Super Kęs"
	desc = "To nie burger, to góra. JEDZENIE!"
	icon_state = "superbiteburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 42,
		/datum/reagent/consumable/nutriment/vitamin = 15
	)
	w_class = WEIGHT_CLASS_NORMAL
	bite_consumption = 7
	max_volume = 100
	tastes = list("bułka" = 4, "cukrzyca typu drugiego" = 10)
	foodtypes = GRAIN | MEAT | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_5

/obj/item/food/burger/fivealarm
	name = "burger na pięć alarmów"
	desc = "GORĄCE! GORĄCE!"
	icon_state = "fivealarmburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/condensedcapsaicin = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/rat
	name = "szczurzy burger"
	desc = "Mniej więcej to, czego się spodziewasz..."
	icon_state = "ratburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | MEAT | GORE
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/baseball
	name = "burger home run"
	desc = "Wciąż ciepły. Para, która z niego bucha, wygląda jak piłka baseballowa."
	icon_state = "baseball"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | GROSS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/baconburger
	name = "burger z boczkiem"
	desc = "Idealne połączenie wszystkiego, co amerykańskie."
	icon_state = "baconburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("bekon" = 4, "bułka" = 2)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/empoweredburger
	name = "naładowany burger"
	desc = "Porażająco dobry, o ile żywisz się prądem."
	icon_state = "empoweredburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/liquidelectricity = 5
	)
	tastes = list("bułka" = 2, "czysty prąd" = 4)
	foodtypes = GRAIN | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/crab
	name = "krabburger"
	desc = "Pyszny kotlet z kraba, wciśnięty w bułkę."
	icon_state = "crabburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bułka" = 2, "mięso kraba" = 4)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/soylent
	name = "burger z soylentu"
	desc = "Ekologiczny burger z przetworzonej biomasy niskiej wartości."
	icon_state = "soylentburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bułka" = 2, "majtek" = 4)
	foodtypes = GRAIN | MEAT | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/burger/rib
	name = "mcrib"
	desc = "Nieuchwytny burger w kształcie żeberek, dostępny tylko przez chwilę w całej galaktyce. Nie tak dobry, jak go pamiętasz."
	icon_state = "mcrib"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/bbqsauce = 1
	)
	tastes = list("bułka" = 2, "kotlet wieprzowy" = 4)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/mcguffin
	name = "mcguffin"
	desc = "Tania i tłusta imitacja jajek po benedyktyńsku."
	icon_state = "mcguffin"
	tastes = list("muffinka" = 2, "bekon" = 3)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/eggyolk = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	foodtypes = GRAIN | MEAT | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/chicken
	name = "kanapka z kurczakiem" //Apparently the proud people of Americlapstan object to this thing being called a burger. Apparently McDonald's just calls it a burger in Europe as to not scare and confuse us.
	desc = "Tak zwana klasyczna drobiowa klatka z chleba. Jak na tak przetworzony produkt smakuje całkiem nieźle."
	icon_state = "chickenburger"
	tastes = list("bułka" = 2, "kurczak" = 4)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/mayonnaise = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nutriment/fat/oil = 2
	)
	foodtypes = GRAIN | MEAT | FRIED
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/cheese
	name = "cheeseburger"
	desc = "Ten szlachetny burger stoi dumnie, odziany w złocisty ser."
	icon_state = "cheeseburger"
	tastes = list("bułka" = 2, "kotlet wołowy" = 4, "ser" = 3)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | MEAT | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/cheese/Initialize(mapload)
	. = ..()
	if(prob(33))
		icon_state = "cheeseburgeralt"

/obj/item/food/burger/crazy
	name = "szalony hamburger"
	desc = "Szalony hamburger! Jest okropny!"
	icon_state = "crazyhamburger"
	tastes = list("chleb z Turcji" = 2, "konina" = 4, "ser z São Paulo w Brazylii" = 3, "ostre papryczki chili" = 3, "ropa z Iraku" = 2, "trawa śmierci" = 3)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN | MEAT | DAIRY | TOXIC | GROSS | FRUIT
	w_class = WEIGHT_CLASS_NORMAL // The crazy hamburger in the video was bigger than joker's hand therefore i think this weight class is adequate.
	crafting_complexity = FOOD_COMPLEXITY_4

// empty burger you can customize
/obj/item/food/burger/empty
	name = "burger"
	desc = "Szalony burger na zamówienie, zrobiony przez obłąkanego kucharza."
	icon_state = "custburg"
	tastes = list("bułka")
	foodtypes = GRAIN
