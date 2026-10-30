
/obj/item/food/pie
	icon = 'icons/obj/food/piecake.dmi'
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("placek" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2
	/// type is spawned 5 at a time and replaces this pie when processed by cutting tool
	var/obj/item/food/pieslice/slice_type
	/// so that the yield can change if it isnt 5
	var/yield = 5

/obj/item/food/pie/make_processable()
	if (slice_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, slice_type, yield, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/pieslice
	name = "kawałek placka"
	icon = 'icons/obj/food/piecake.dmi'
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("placek" = 1, "niepewność" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pie/plain
	name = "zwykły placek"
	desc = "Prosty placek, ale wciąż pyszny."
	icon_state = "pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("placek" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pie/cream
	name = "tort z kremem bananowym"
	desc = "Zupełnie jak w domu, na planecie klaunów! HONK!"
	icon_state = "pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("placek" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	var/stunning = TRUE
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/cream/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if we're not being caught
		splat(hit_atom)

/obj/item/food/pie/cream/proc/splat(atom/movable/hit_atom)
	if(isliving(loc)) //someone caught us!
		return
	var/turf/T = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/food/pie_smudge(T)
	if(reagents?.total_volume)
		reagents.reaction(hit_atom, TOUCH)
	//NSV13 - we use creampie overlays instead of the creamed component
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		var/mutable_appearance/creamoverlay = mutable_appearance('icons/effects/creampie.dmi')
		if(istype(H.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/lizard))
			creamoverlay.icon_state = "creampie_lizard"
		else
			creamoverlay.icon_state = "creampie_human"
		if(stunning)
			H.Paralyze(20) //splat!
		H.adjust_blurriness(1)
		H.visible_message("<span class='warning'>[src] obrzuca [H] kremem!</span>", "<span class='userdanger'>Zostajesz obrzucony kremem przez [src]!</span>")
		playsound(H, "desecration", 50, TRUE)
		if(!H.creamed) // one layer at a time
			H.add_overlay(creamoverlay)
			H.creamed = TRUE
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "creampie", /datum/mood_event/creampie)
	qdel(src)

/obj/item/food/pie/cream/nostun
	stunning = FALSE


/obj/item/food/pie/cream/body

/obj/item/food/pie/cream/body/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
		A.throw_at(T, 1, 1)
	. = ..()

/*
/obj/item/food/pie/cream/body/proc/on_consume(mob/living/carbon/M)
	if(!reagents.total_volume) //so that it happens on the last bite
		if(iscarbon(M) && contents.len)
			var/turf/T = get_turf(src)
			for(var/atom/movable/A in contents)
				A.forceMove(T)
				A.throw_at(T, 1, 1)
				M.visible_message("[src] wyrywa się z [M]!</span>")
			M.emote("scream")
			M.Knockdown(40)
			M.adjustBruteLoss(60)
	return ..()
*/

/obj/item/food/pie/berryclafoutis
	name = "clafoutis jagodowe"
	desc = "Żadnych kosów w środku, to dobry znak."
	icon_state = "berryclafoutis"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/berryjuice = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	slice_type = /obj/item/food/pieslice/berry
	tastes = list("placek" = 1, "jeżyny" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/berry
	name = "kawałek clafoutis jagodowego"
	desc = "Kawałek jagodowego clafoutis."
	icon_state = "berryclafoutis_slice"
	tastes = list("placek" = 1, "jeżyny" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/bearypie
	name = "placek z niedźwiedziem"
	desc = "Żadnych niedźwiedzi brunatnych, to dobry znak."
	icon_state = "bearypie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	slice_type = /obj/item/food/pieslice/beary
	tastes = list("placek" = 1, "mięso" = 1, "łosoś" = 1)
	foodtypes = GRAIN | SUGAR | MEAT | FRUIT // so weird
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pieslice/beary
	name = "kawałek placka z niedźwiedziem"
	desc = "Kawałek placka z niedźwiedziem."
	icon_state = "bearypie_slice"
	tastes = list("placek" = 1, "mięso" = 1, "łosoś" = 1)
	foodtypes = GRAIN | SUGAR | MEAT | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pie/meatpie
	name = "placek z mięsem"
	icon_state = "meatpie"
	desc = "Stary przepis pewnego golibrody, bardzo smaczny!"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	slice_type = /obj/item/food/pieslice/meat
	tastes = list("placek" = 1, "mięso" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/meat
	name = "kawałek placka z mięsem"
	desc = "O, super, placek z mięsem!"
	icon_state = "meatpie_slice"
	tastes = list("placek" = 1, "mięso" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/tofupie
	name = "placek z tofu"
	icon_state = "meatpie"
	desc = "Pyszny placek z tofu."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/protein = 1, // yeah. Theres 'technically' protein in this thing.
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	slice_type = /obj/item/food/pieslice/tofu
	tastes = list("placek" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/tofu
	name = "kawałek placka z tofu"
	desc = "O, super, placek z mięsem... ZARAZ, CHWILECZKĘ!!"
	icon_state = "meatpie_slice"
	tastes = list("placek" = 1, "tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/amanita_pie
	name = "placek z muchomorem"
	desc = "Słodki i smaczny placek z trucizną."
	icon_state = "amanita_pie"
	bite_consumption = 4
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/amatoxin = 3,
		/datum/reagent/drug/mushroomhallucinogen = 1,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("placek" = 1, "grzyb" = 1)
	foodtypes = GRAIN | VEGETABLES | TOXIC | GROSS
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/plump_pie
	name = "placek z pulchnym hełmem"
	desc = "Założę się, że uwielbiasz rzeczy z pulchnych hełmów!"
	icon_state = "plump_pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("placek" = 1, "grzyb" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/plump_pie/Initialize(mapload)
	var/fey = prob(10)
	if(fey)
		name = "wyjątkowy placek z pulchnym hełmem"
		desc = "Mikrofalówkę ogarnia natchnienie! Upiekła wyjątkowy placek z pulchnym hełmem!"
		food_reagents = list(
			/datum/reagent/consumable/nutriment = 11,
			/datum/reagent/medicine/omnizine = 5,
			/datum/reagent/consumable/nutriment/vitamin = 4,
		)
	. = ..()

/obj/item/food/pie/xemeatpie
	name = "ksenoplacek"
	icon_state = "xenomeatpie"
	desc = "Pyszny placek z mięsem. Prawdopodobnie heretycki."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	slice_type = /obj/item/food/pieslice/xeno
	tastes = list("placek" = 1, "mięso" = 1, "kwas" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/xeno
	name = "kawałek ksenoplacka"
	desc = "O Boże... To się jeszcze rusza?"
	icon_state = "xenopie_slice"
	tastes = list("placek" = 1, "mięso" = 1, "kwas" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/applepie
	name = "szarlotka"
	desc = "Placek pełen słodkiej, słodkiej miłości... albo jabłek."
	icon_state = "applepie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	slice_type = /obj/item/food/pieslice/apple
	tastes = list("placek" = 1, "jabłko" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/apple
	name = "kawałek szarlotki"
	desc = "Kawałek przytulnej szarlotki, na horyzoncie ciepłe jesienne wspomnienia."
	icon_state = "applepie_slice"
	tastes = list("placek" = 1, "jabłka" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/cherrypie
	name = "placek wiśniowy"
	desc = "Tak dobry, że dorosły mężczyzna zapłacze."
	icon_state = "cherrypie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	slice_type = /obj/item/food/pieslice/cherry
	tastes = list("placek" = 7, "Nicole Paige Brooks" = 2)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/cherry
	name = "kawałek placka wiśniowego"
	desc = "Kawałek pysznego placka wiśniowego, oby z morelli!"
	icon_state = "cherrypie_slice"
	tastes = list("placek" = 1, "wiśnie" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/pumpkinpie
	name = "placek dyniowy"
	desc = "Pyszny przysmak na jesienne miesiące."
	icon_state = "pumpkinpie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("placek" = 1, "dynia" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR
	slice_type = /obj/item/food/pieslice/pumpkin
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/pumpkin
	name = "kawałek placka dyniowego"
	desc = "Kawałek placka dyniowego z bitą śmietaną na wierzchu. Perfekcja."
	icon_state = "pumpkinpieslice"
	tastes = list("placek" = 1, "dynia" = 1)
	foodtypes = GRAIN | VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/appletart
	name = "tarta kruszonkowa ze złotym jabłkiem"
	desc = "Smaczny deser, który nie przejdzie przez wykrywacz metali."
	icon_state = "gappletart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/gold = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("placek" = 1, "jabłko" = 1, "drogi metal" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pie/grapetart
	name = "tarta winogronowa"
	desc = "Smaczny deser, który przypomina ci wino, którego nie zrobiłeś."
	icon_state = "grapetart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("placek" = 1, "winogrono" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pie/mimetart
	name = "tarta mima"
	desc = "..."
	icon_state = "mimetart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/nothing = 10,
	)
	tastes = list("nic" = 3)
	foodtypes = GRAIN
	crafted_food_buff = /datum/status_effect/food/trait/mute

/obj/item/food/pie/berrytart
	name = "tarta jagodowa"
	desc = "Smaczny deser z wieloma różnymi drobnymi jagodami na cienkim kruchym spodzie."
	icon_state = "berrytart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("placek" = 1, "jagody" = 2)
	foodtypes = GRAIN | FRUIT

/obj/item/food/pie/cocoalavatart
	name = "czekoladowa tarta lawowa"
	desc = "Smaczny czekoladowy deser z płynnym środkiem." //But it doesn't even contain chocolate...
	icon_state = "cocolavatart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("placek" = 1, "gorzka czekolada" = 3)
	foodtypes = GRAIN | SUGAR

/obj/item/food/pie/blumpkinpie
	name = "placek z niebieskiej dyni"
	desc = "Dziwny niebieski placek z toksycznej niebieskiej dyni."
	icon_state = "blumpkinpie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 13,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("placek" = 1, "haust wody z basenu" = 1)
	foodtypes = GRAIN | VEGETABLES
	slice_type = /obj/item/food/pieslice/blumpkin
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/blumpkin
	name = "kawałek placka z niebieskiej dyni"
	desc = "Kawałek placka z niebieskiej dyni z bitą śmietaną na wierzchu. To w ogóle jadalne?"
	icon_state = "blumpkinpieslice"
	tastes = list("placek" = 1, "haust wody z basenu" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/dulcedebatata
	name = "dulce de batata"
	desc = "Pyszna galaretka z batatów."
	icon_state = "dulcedebatata"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 14,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("galaretka" = 1, "batat" = 1)
	foodtypes = VEGETABLES | SUGAR
	slice_type = /obj/item/food/pieslice/dulcedebatata
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/dulcedebatata
	name = "kawałek dulce de batata"
	desc = "Kawałek słodkiej galaretki dulce de batata."
	icon_state = "dulcedebatataslice"
	tastes = list("galaretka" = 1, "batat" = 1)
	foodtypes = VEGETABLES | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/frostypie
	name = "mroźny placek"
	desc = "Smakuje jak błękit i chłód."
	icon_state = "frostypie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 14,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	slice_type = /obj/item/food/pieslice/frosty
	tastes = list("mięta" = 1, "placek" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pieslice/frosty
	name = "kawałek mroźnego placka"
	desc = "Smaczny błękit, jak moja ulubiona kredka!"
	icon_state = "frostypie_slice"
	tastes = list("placek" = 1, "mięta" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/baklava
	name = "baklawa"
	desc = "Przepyszna, zdrowa przekąska z warstw orzechów i cienkiego ciasta."
	icon_state = "baklava"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("orzechy" = 1, "placek" = 1)
	foodtypes = /*NUTS | */SUGAR
	slice_type = /obj/item/food/pieslice/baklava
	yield = 6
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pieslice/baklava
	name = "porcja baklawy"
	desc = "Porcja przepysznej, zdrowej przekąski z warstw orzechów i cienkiego ciasta"
	icon_state = "baklavaslice"
	tastes = list("orzechy" = 1, "placek" = 1)
	foodtypes = /*NUTS | */SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4
