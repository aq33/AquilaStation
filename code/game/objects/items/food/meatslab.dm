/obj/item/food/meat
	//custom_materials = list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT * 4)
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/meat.dmi'
	var/subjectname = ""
	var/subjectjob = null

/obj/item/food/meat/slab
	name = "mięso"
	desc = "Płat mięsa."
	icon_state = "meat"
	//dried_type = /obj/item/food//sosjerky/healthy
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/fat = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	) //Meat has fats that a food processor can process into cooking oil
	tastes = list("mięso" = 1)
	foodtypes = MEAT | RAW
	///Legacy code, handles the coloring of the overlay of the cutlets made from this.
	var/slab_color = "#FF0000"

/obj/item/food/meat/slab/Initialize(mapload)
	. = ..()
	make_dryable()

/obj/item/food/meat/slab/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/plain, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/food/meat/slab/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/plain, 3, 30)

/obj/item/food/meat/slab/proc/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy)

///////////////////////////////////// HUMAN MEATS //////////////////////////////////////////////////////

/obj/item/food/meat/slab/human
	name = "mięso"
	tastes = list("delikatne mięso" = 1)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/slab/human/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/plain/human, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/food/meat/slab/human/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/plain/human, 3, 30)

/obj/item/food/meat/slab/human/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/lean)

/obj/item/food/meat/slab/human/mutant/slime
	icon_state = "slimemeat"
	desc = "Bo galaretka nie obrażała wegan wystarczająco."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/toxin/slimejelly = 3
	)
	tastes = list("szlam" = 1, "galaretka" = 1)
	foodtypes = MEAT | RAW | TOXIC

/obj/item/food/meat/slab/human/mutant/slime/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/jelly)

/obj/item/food/meat/slab/human/mutant/golem
	icon_state = "golemmeat"
	desc = "Jadalne kamienie. Witaj w przyszłości."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/iron = 3
	)
	tastes = list("skała" = 1)
	foodtypes = MEAT | RAW | GROSS

/obj/item/food/meat/slab/human/mutant/golem/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/rock_candy)

/obj/item/food/meat/slab/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = "Z zagrody szlamów, przez runę, do kuchni. Nauka."
	foodtypes = MEAT | RAW | GROSS

/obj/item/food/meat/slab/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = "Pyszne dinoobrażenia."
	tastes = list("mięso" = 4, "łuski" = 1)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/slab/human/mutant/lizard/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/plain/human/lizard, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/human/mutant/lizard/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/lizard)

/obj/item/food/meat/slab/human/mutant/plant
	icon_state = "plantmeat"
	desc = "Wszystkie radości zdrowego odżywiania i cała frajda kanibalizmu."
	tastes = list("sałatka" = 1, "drewno" = 1)
	foodtypes = VEGETABLES

/obj/item/food/meat/slab/human/mutant/plant/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/plain/human/diona, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/human/mutant/plant/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/diona)

/obj/item/food/meat/slab/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = "Au, ostre."
	tastes = list("ciemność" = 1, "mięso" = 1)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/slab/human/mutant/fly
	icon_state = "flymeat"
	desc = "Nic nie mówi „smaczne” tak jak radioaktywne mięso mutanta pełne robaków."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/uranium = 3
	)
	tastes = list("czerwie" = 1, "wnętrze reaktora" = 1)
	foodtypes = MEAT | RAW | GROSS | BUGS | GORE

/obj/item/food/meat/slab/human/mutant/fly/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/bugs)

/obj/item/food/meat/slab/human/mutant/moth
	icon_state = "mothmeat"
	desc = "Nieprzyjemnie pyliste i suche. Choć całkiem ładne."
	tastes = list("kurz" = 1, "proszek" = 1, "mięso" = 2)
	foodtypes = MEAT | RAW | BUGS | GORE

/obj/item/food/meat/slab/human/mutant/moth/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/bugs)

/obj/item/food/meat/slab/human/mutant/skeleton
	name = "kość"
	icon_state = "skeletonmeat"
	desc = "Jest granica, na której trzeba przestać, i najwyraźniej ją przekroczyliśmy."
	tastes = list("kość" = 1)
	foodtypes = GROSS | GORE

/obj/item/food/meat/slab/human/mutant/skeleton/make_processable()
	return //skeletons dont have cutlets. Its a bone, Genius.

/obj/item/food/meat/slab/human/mutant/skeleton/make_dryable()
	return	//I agree. It's a bone, Genius.

/obj/item/food/meat/slab/human/mutant/zombie
	name = " mięso (zgniłe)"
	icon_state = "rottenmeat"
	desc = "W połowie drogi do zostania nawozem do twojego ogródka."
	tastes = list("mózg" = 1, "mięso" = 1)
	foodtypes = RAW | MEAT | TOXIC | GORE | GROSS // who the hell would eat this

/obj/item/food/meat/slab/human/mutant/ethereal
	icon_state = "etherealmeat"
	desc = "Tak lśniące, że masz wrażenie, że po zjedzeniu sam zaczniesz lśnić."
	food_reagents = list(/datum/reagent/consumable/liquidelectricity = 3)
	tastes = list("czysty prąd" = 2, "mięso" = 1)
	foodtypes = RAW | MEAT | TOXIC | GORE

/obj/item/food/meat/slab/human/mutant/ethereal/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/ethereal)

/obj/item/food/meat/slab/human/mutant/apid
	icon_state = "apidmeat"
	desc = "Pachnie kwiatami. Oby nimi nie smakowało."
	tastes = list("miód" = 1, "kwiaty" = 1, "mięso" = 2)
	foodtypes = MEAT | RAW | BUGS | GORE

/obj/item/food/meat/slab/human/mutant/apid/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/bees)

/obj/item/food/meat/slab/human/mutant/psyphoza
	icon_state = "psyphoza_meat"
	desc = "Psychicznie czeka na zjedzenie. Upiorne."
	food_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 3)
	tastes = list("strzelające cukierki" = 1, "mięso" = 1)
	foodtypes = VEGETABLES | RAW | GORE
	microwaved_type = /obj/item/food/meat/steak/plain/human/psyphoza

/obj/item/food/meat/slab/human/mutant/psyphoza/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/plain/human/psyphoza, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/human/mutant/psyphoza/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/mushroom)

////////////////////////////////////// OTHER MEATS ////////////////////////////////////////////////////////


/obj/item/food/meat/slab/synthmeat
	name = "syntetyczne mięso"
	desc = "Syntetyczny płat... etycznego* mięsa?"
	foodtypes = RAW | MEAT // If it looks like a duck, quacks like a duck, its probably...

/obj/item/food/meat/slab/synthmeat/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/plain/synth, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/synthmeat/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/synthmeat)

/obj/item/food/meat/slab/meatproduct
	name = "produkt mięsny"
	//icon_state = "meatproduct"
	desc = "Płat odzyskanego na stacji i chemicznie przetworzonego produktu mięsnego."
	tastes = list("aromat mięsny" = 2, "skrobia modyfikowana" = 2, "naturalne i sztuczne barwniki" = 1, "kwas masłowy" = 1) // its supposed to be various processed chemicals seen in very processed food. Butyric acid is a reference to how a certain North American Candymaker puts a chemical commonly seen in vomit into chocolate
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/meatproduct/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/pemmican)

/obj/item/food/meat/slab/monkey
	name = "mięso małpy"
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/monkey/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/monkey)

/obj/item/food/meat/slab/mouse
	name = "mięso myszy"
	desc = "Płat mięsa myszy. Lepiej nie jeść go na surowo."
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/mouse/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/mouse)

/obj/item/food/meat/slab/corgi
	name = "mięso corgiego"
	desc = "Smakuje jak... no, wiesz..."
	tastes = list("mięso" = 4, "zamiłowanie do kapeluszy" = 1)
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/pug
	name = "mięso mopsa"
	desc = "Smakuje jak... no, wiesz..."
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/hamster
	name = "mięso chomika"
	desc = "Hej, one zjadają się nawzajem, więc to usprawiedliwione... prawda..?"
	tastes = list("mięso" = 4, "puchata uroczość" = 1)
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/killertomato
	name = "mięso pomidora zabójcy"
	desc = "Plaster z ogromnego pomidora."
	icon_state = "tomatomeat"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pomidor" = 1)
	foodtypes = FRUIT // Yeah, tomatoes are FRUIT. Bite me.

/obj/item/food/meat/slab/killertomato/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/killertomato, rand(70 SECONDS, 85 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/killertomato/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/killertomato, 3, 30)

/obj/item/food/meat/slab/bear
	name = "mięso niedźwiedzia"
	desc = "Bardzo męski płat mięsa."
	icon_state = "bearmeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/medicine/morphine = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/fat = 6
	)
	tastes = list("mięso" = 1, "łosoś" = 1)
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/bear/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/bear, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/bear/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/bear, 3, 30)

/obj/item/food/meat/slab/xeno
	name = "mięso ksenomorfa"
	desc = "Płat mięsa."
	icon_state = "xenomeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 4
	tastes = list("mięso" = 1, "kwas" = 1)
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/xeno/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/xeno, 3, 30)

/obj/item/food/meat/slab/xeno/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/xeno, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/spider
	name = "mięso pająka"
	desc = "Płat mięsa pająka. Jakie to kafkowskie."
	icon_state = "spidermeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/toxin = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("pajęczyny" = 1)
	foodtypes = RAW | MEAT | TOXIC

/obj/item/food/meat/slab/spider/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/spider, 3, 30)

/obj/item/food/meat/slab/spider/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/spider, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE)

/obj/item/food/meat/slab/spider/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/bugs)

/obj/item/food/meat/slab/goliath
	name = "mięso goliata"
	desc = "Płat mięsa goliata. Na razie niezbyt jadalny, ale świetnie piecze się w lawie."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/toxin = 5,
		/datum/reagent/consumable/nutriment/fat = 3
	)
	icon_state = "goliathmeat"
	tastes = list("mięso" = 1)
	foodtypes = RAW | MEAT | TOXIC

/obj/item/food/meat/slab/goliath/burn()
	visible_message("<span class='notice'>[src] jest gotowy!</span>")
	new /obj/item/food/meat/steak/goliath(loc)
	qdel(src)

/obj/item/food/meat/slab/meatwheat
	name = "grudka mięsopszenicy"
	desc = "To nie wygląda jak mięso, ale twoje standardy i tak nie są <i>aż tak</i> wysokie."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/nutriment/fat = 1
	)
	icon_state = "meatwheat_clump"
	bite_consumption = 4
	tastes = list("mięso" = 1, "pszenica" = 1)
	foodtypes = GRAIN

/obj/item/food/meat/slab/gorilla
	name = "mięso goryla"
	desc = "Dużo bardziej mięsiste niż mięso małpy."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nutriment/fat = 5 //Plenty of fat!
	)

/obj/item/food/meat/slab/gorilla/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/monkey)

/obj/item/food/meat/rawbacon
	name = "surowy plaster boczku"
	desc = "Surowy plaster boczku."
	icon_state = "bacon"
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/fat = 3
	)
	tastes = list("bekon" = 1)
	foodtypes = RAW | MEAT | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/meat/rawbacon/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/bacon, rand(25 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/food/meat/bacon
	name = "plaster boczku"
	desc = "Pyszny plaster boczku."
	icon_state = "baconcooked"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/nutriment/fat = 2
	)
	tastes = list("bekon" = 1)
	foodtypes = MEAT | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/meat/slab/gondola
	name = "mięso gondoli"
	desc = "Według dawnych legend zjedzenie surowego mięsa gondoli daje wewnętrzny spokój."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/tranquility = 5,
		/datum/reagent/consumable/nutriment/fat = 3
	)
	tastes = list("mięso" = 4, "spokój" = 1)
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/gondola/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/gondola, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/food/meat/slab/gondola/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/gondola, 3, 30)

/obj/item/food/meat/slab/penguin
	name = "mięso pingwina"
	icon_state = "birdmeat"
	desc = "Płat mięsa pingwina."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/fat = 3
	)
	tastes = list("wołowina" = 1, "dorsz" = 1)

/obj/item/food/meat/slab/penguin/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/penguin, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/food/meat/slab/penguin/make_processable()
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/penguin, 3, 30)

/obj/item/food/meat/rawcrab
	name = "surowe mięso kraba"
	desc = "Kupka surowego mięsa kraba."
	icon_state = "crabmeatraw"
	microwaved_type = /obj/item/food/meat/crab
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/fat = 3
	)
	tastes = list("surowy krab" = 1)
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/rawcrab/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/crab, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/food/meat/crab
	name = "mięso kraba"
	desc = "Pysznie ugotowane mięso kraba."
	icon_state = "crabmeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/fat = 2
	)
	tastes = list("krab" = 1)
	foodtypes = MEAT
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/meat/slab/chicken
	name = "mięso kurczaka"
	icon_state = "birdmeat"
	desc = "Płat surowego kurczaka. Pamiętaj, żeby umyć ręce!"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6
	) //low fat
	tastes = list("kurczak" = 1)

/obj/item/food/meat/slab/chicken/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/lean)

/obj/item/food/meat/slab/chicken/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/chicken, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe? (no this is chicken)

/obj/item/food/meat/slab/chicken/make_processable()
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/chicken, 3, 30)

/obj/item/food/meat/slab/mothroach
	name = "mięso ćmokaralucha"
	desc = "Lekki płat mięsa ćmokaralucha."
	tastes = list("obrzydlistwo" = 1)
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/mothroach/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/sosjerky/healthy/bugs)

/obj/item/food/meat/slab/dolphinmeat
	name = "surowy filet z delfina"
	desc = "Filet z mięsa kosmicznego delfina."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("ryba" = 1,"okrucieństwo" = 2)
	foodtypes = MEAT | RAW


////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////
/obj/item/food/meat/steak
	name = "stek"
	desc = "Kawałek gorącego, pikantnego mięsa."
	icon_state = "meatsteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/fat = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	foodtypes = MEAT
	tastes = list("mięso" = 1)
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/meat/steak/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))

/obj/item/food/meat/steak/proc/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	name = "stek: [source_item.name]"

/obj/item/food/meat/steak/plain
	foodtypes = MEAT

/obj/item/food/meat/steak/plain/human
	tastes = list("delikatne mięso" = 1)
	foodtypes = MEAT | GORE

///Make sure the steak has the correct name
/obj/item/food/meat/steak/plain/human/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency = 1)
	. = ..()
	if(!istype(source_item, /obj/item/food/meat))
		return

	var/obj/item/food/meat/origin_meat = source_item
	subjectname = origin_meat.subjectname
	subjectjob = origin_meat.subjectjob
	if(subjectname)
		name = "stek ([origin_meat.subjectname])"
	else if(subjectjob)
		name = "stek ([origin_meat.subjectjob])"

/obj/item/food/meat/steak/killertomato
	name = "stek z pomidora zabójcy"
	tastes = list("pomidor" = 1)
	foodtypes = FRUIT // And dont let anybody tell you otherwise!

/obj/item/food/meat/steak/bear
	name = "stek z niedźwiedzia"
	tastes = list("mięso" = 1, "łosoś" = 1)

/obj/item/food/meat/steak/xeno
	name = "stek z ksenomorfa"
	tastes = list("mięso" = 1, "kwas" = 1)

/obj/item/food/meat/steak/spider
	name = "stek z pająka"
	tastes = list("pajęczyny" = 1)

/obj/item/food/meat/steak/goliath
	name = "stek z goliata"
	desc = "Pyszny stek upieczony w lawie."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash_type = null
	tastes = list("mięso" = 1, "skała" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/gondola
	name = "stek z gondoli"
	tastes = list("mięso" = 1, "spokój" = 1)

/obj/item/food/meat/steak/penguin
	name = "stek z pingwina"
	icon_state = "birdsteak"
	tastes = list("wołowina" = 1, "dorsz" = 1)

/obj/item/food/meat/steak/chicken
	name = "stek z kurczaka" //Can you have chicken steaks? Maybe this should be renamed once it gets new sprites. //I concur
	icon_state = "birdsteak"
	tastes = list("kurczak" = 1)

/obj/item/food/meat/steak/plain/human/lizard
	name = "stek z jaszczura"
	icon_state = "birdsteak" //cause they're birds. Get it?
	tastes = list("soczysty kurczak" = 3, "łuski" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/plain/human/psyphoza
	name = "stek z psyphozy"
	icon_state = "psyphoza_meat_cooked"
	tastes = list("brud" = 3, "drewno" = 1)
	foodtypes = VEGETABLES

/obj/item/food/meat/steak/plain/human/diona
	name = "stek z diony"
	tastes = list("sałatka" = 3, "włókno roślinne" = 1)
	foodtypes = VEGETABLES

/obj/item/food/meat/steak/meatproduct
	name = "termicznie przetworzony produkt mięsny"
	//icon_state = "meatproductsteak"
	tastes = list("wzmocniona spalenizna" = 2, "podejrzana delikatność" = 2, "naturalne i sztuczne barwniki" = 2, "emulgatory" = 1)

/obj/item/food/meat/steak/plain/synth
	name = "syntetyczny stek"
	desc = "Stek z syntetycznego mięsa. Nie wygląda do końca dobrze, prawda?"
	icon_state = "meatsteak"
	tastes = list("mięso" = 4, "kriooksadon" = 1)

/obj/item/food/meat/steak/ashflake
	name = "stek w popiele"
	desc = "Popularny przysmak wśród górników."
	icon_state = "ashsteak"
	food_reagents = list(
		/datum/reagent/consumable/vitfro = 2
	)
	tastes = list("twarde mięso" = 2, "guma balonowa" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/dolphinmeat
	name = "filet z delfina"
	desc = "Filet z mięsa kosmicznego delfina."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("ryba" = 1,"okrucieństwo" = 2)
	foodtypes = MEAT

//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////

//Raw cutlets

/obj/item/food/meat/rawcutlet
	name = "surowy kotlet"
	desc = "Surowy kotlet mięsny."
	icon_state = "rawcutlet"
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2
	)
	tastes = list("mięso" = 1)
	foodtypes = MEAT | RAW
	var/meat_type = "mięso"

/obj/item/food/meat/rawcutlet/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/plain, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/OnCreatedFromProcessing(mob/living/user, obj/item/work_tool, list/chosen_option, atom/original_atom)
	. = ..()
	if(istype(original_atom, /obj/item/food/meat/slab))
		var/obj/item/food/meat/slab/original_slab = original_atom
		var/mutable_appearance/filling = mutable_appearance(icon, "rawcutlet_coloration")
		filling.color = original_slab.slab_color
		add_overlay(filling)
		name = "surowy kotlet: [original_atom.name]"
		meat_type = original_atom.name

/obj/item/food/meat/rawcutlet/plain
	foodtypes = MEAT

/obj/item/food/meat/rawcutlet/plain/human
	tastes = list("delikatne mięso" = 1)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/rawcutlet/plain/human/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/plain/human, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/plain/human/OnCreatedFromProcessing(mob/living/user, obj/item/I, list/chosen_option, atom/original_atom)
	. = ..()
	if(istype(original_atom, /obj/item/food/meat))
		var/obj/item/food/meat/origin_meat = original_atom
		subjectname = origin_meat.subjectname
		subjectjob = origin_meat.subjectjob
		if(subjectname)
			name = "surowy kotlet ([origin_meat.subjectname])"
		else if(subjectjob)
			name = "surowy kotlet ([origin_meat.subjectjob])"

/obj/item/food/meat/rawcutlet/killertomato
	name = "surowy kotlet z pomidora zabójcy"
	tastes = list("pomidor" = 1)
	foodtypes = FRUIT

/obj/item/food/meat/rawcutlet/killertomato/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/killertomato, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/bear
	name = "surowy kotlet z niedźwiedzia"
	tastes = list("mięso" = 1, "łosoś" = 1)

/obj/item/food/meat/rawcutlet/bear/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/bear, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/xeno
	name = "surowy kotlet z ksenomorfa"
	tastes = list("mięso" = 1, "kwas" = 1)

/obj/item/food/meat/rawcutlet/xeno/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/xeno, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/spider
	name = "surowy kotlet z pająka"
	tastes = list("pajęczyny" = 1)

/obj/item/food/meat/rawcutlet/spider/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/spider, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/gondola
	name = "surowy kotlet z gondoli"
	tastes = list("mięso" = 1, "spokój" = 1)

/obj/item/food/meat/rawcutlet/gondola/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/gondola, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/penguin
	name = "surowy kotlet z pingwina"
	tastes = list("wołowina" = 1, "dorsz" = 1)

/obj/item/food/meat/rawcutlet/penguin/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/penguin, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/chicken
	name = "surowy kotlet z kurczaka"
	tastes = list("kurczak" = 1)

/obj/item/food/meat/rawcutlet/chicken/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/chicken, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/grub //grub meat is small, so its in cutlets
	name = "kotlet z czerwonego pędraka"
	desc = "Twardy, oślizgły kawałek surowego czerwonego pędraka. Bardzo toksyczny i pewnie zakaźny, ale po ugotowaniu pyszny. Nie dotykaj bez odpowiedniego sprzętu ochrony biologicznej."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "grubmeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/toxin/slimejelly = 2
	)
	bite_consumption = 1
	tastes = list("szlam" = 1, "robak" = 1)
	foodtypes = RAW | MEAT | TOXIC
	microwaved_type = /obj/item/food/meat/cutlet/grub

/obj/item/food/meat/rawcutlet/grub/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/grub, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

//Cooked cutlets

//Cooked cutlets

/obj/item/food/meat/cutlet
	name = "kotlet"
	desc = "Upieczony kotlet mięsny."
	icon_state = "cutlet"
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2
	)
	tastes = list("mięso" = 1)
	foodtypes = MEAT
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/meat/cutlet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))

///This proc handles setting up the correct meat name for the cutlet, this should definitely be changed with the food rework.
/obj/item/food/meat/cutlet/proc/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency)
	SIGNAL_HANDLER

	if(!istype(source_item, /obj/item/food/meat/rawcutlet))
		return

	var/obj/item/food/meat/rawcutlet/original_cutlet = source_item
	name = "kotlet: [original_cutlet.meat_type]"

/obj/item/food/meat/cutlet/plain

/obj/item/food/meat/cutlet/plain/human
	tastes = list("delikatne mięso" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/meat/cutlet/plain/human/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency)
	. = ..()
	if(!istype(source_item, /obj/item/food/meat))
		return

	var/obj/item/food/meat/origin_meat = source_item
	if(subjectname)
		name = "[initial(name)] ([origin_meat.subjectname])"
	else if(subjectjob)
		name = "[initial(name)] ([origin_meat.subjectjob])"

/obj/item/food/meat/cutlet/killertomato
	name = "kotlet z pomidora zabójcy"
	tastes = list("pomidor" = 1)
	foodtypes = FRUIT

/obj/item/food/meat/cutlet/bear
	name = "kotlet z niedźwiedzia"
	tastes = list("mięso" = 1, "łosoś" = 1)

/obj/item/food/meat/cutlet/xeno
	name = "kotlet z ksenomorfa"
	tastes = list("mięso" = 1, "kwas" = 1)

/obj/item/food/meat/cutlet/spider
	name = "kotlet z pająka"
	tastes = list("pajęczyny" = 1)

/obj/item/food/meat/cutlet/gondola
	name = "kotlet z gondoli"
	tastes = list("mięso" = 1, "spokój" = 1)

/obj/item/food/meat/cutlet/penguin
	name = "kotlet z pingwina"
	tastes = list("wołowina" = 1, "dorsz" = 1)

/obj/item/food/meat/cutlet/chicken
	name = "kotlet z kurczaka"
	tastes = list("kurczak" = 1)

/obj/item/food/meat/cutlet/grub
	name = "skórka czerwonego pędraka"
	desc = "Pod wpływem gotowania mięso czerwonego pędraka „pęka” i staje się nietoksyczne, chrupiące i pysznie słodkie."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "grubsteak"
	trash_type = null
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/medicine/regen_jelly = 1
	)
	tastes = list("galaretka" = 1, "słodkie mięso" = 1, "olej" = 1)
	foodtypes = MEAT
