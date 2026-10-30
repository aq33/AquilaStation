//////////////////////////////////////////////
//////////     SLIME CROSSBREEDS    //////////
//////////////////////////////////////////////
// A system of combining two extract types. //
// Performed by feeding a slime 10 of an    //
// extract color.                           //
//////////////////////////////////////////////
/*==========================================*\
To add a crossbreed:
	The file name is automatically selected
	by the crossbreeding effect, which uses
	the format slimecross/[modifier]/[color].

	If a crossbreed doesn't exist, don't
	worry. If no file is found at that
	location, it will simple display that
	the crossbreed was too unstable.

	As a result, do not feel the need to
	try to add all of the crossbred
	effects at once, if you're here and
	trying to make a new slime type. Just
	get your slimetype in the codebase and
	get around to the crossbreeds eventually!
\*==========================================*/

/obj/item/slimecross //The base type for crossbred extracts. Mostly here for posterity, and to set base case things.
	name = "krzyżówkowy ekstrakt szlamu"
	desc = "Niezwykle silny ekstrakt szlamu powstały przez krzyżowanie."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "base"
	var/colour = "null"
	var/effect = "null"
	var/effect_desc = "null"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6

/obj/item/slimecross/examine(mob/user)
    . = ..()
    if(effect_desc)
        . += "<span class='notice'>[effect_desc]</span>"

/obj/item/slimecross/Initialize(mapload)
	. = ..()
	var/static/list/effect_pl = list("burning" = "płonący", "charged" = "naładowany", "chilling" = "mrożący", "consuming" = "pożerający", "crystalline" = "krystaliczny", "gentle" = "łagodny", "industrial" = "przemysłowy", "prismatic" = "pryzmatyczny", "recurring" = "odnawialny", "regenerative" = "regeneracyjny", "reproductive" = "rozrodczy", "self-sustaining" = "samowystarczalny", "stabilized" = "ustabilizowany", "transformative" = "przemieniający", "warping" = "zakrzywiający")
	var/static/list/colour_pl = list("grey" = "szary", "orange" = "pomarańczowy", "purple" = "fioletowy", "blue" = "niebieski", "metal" = "metalowy", "yellow" = "żółty", "dark purple" = "ciemnofioletowy", "dark blue" = "ciemnoniebieski", "silver" = "srebrny", "bluespace" = "bluespace", "sepia" = "sepiowy", "cerulean" = "lazurowy", "pyrite" = "pirytowy", "red" = "czerwony", "green" = "zielony", "pink" = "różowy", "gold" = "złoty", "oil" = "naftowy", "black" = "czarny", "light pink" = "jasnoróżowy", "adamantine" = "adamantytowy", "rainbow" = "tęczowy")
	name = "[effect_pl[effect] || effect] ekstrakt ([colour_pl[colour] || colour])"
	var/itemcolor = "#FFFFFF"
	switch(colour)
		if("orange")
			itemcolor = "#FFA500"
		if("purple")
			itemcolor = "#B19CD9"
		if("blue")
			itemcolor = "#ADD8E6"
		if("metal")
			itemcolor = "#7E7E7E"
		if("yellow")
			itemcolor = "#FFFF00"
		if("dark purple")
			itemcolor = "#551A8B"
		if("dark blue")
			itemcolor = "#0000FF"
		if("silver")
			itemcolor = "#D3D3D3"
		if("bluespace")
			itemcolor = "#32CD32"
		if("sepia")
			itemcolor = "#704214"
		if("cerulean")
			itemcolor = "#2956B2"
		if("pyrite")
			itemcolor = "#FAFAD2"
		if("red")
			itemcolor = "#FF0000"
		if("green")
			itemcolor = "#00FF00"
		if("pink")
			itemcolor = "#FF69B4"
		if("gold")
			itemcolor = "#FFD700"
		if("oil")
			itemcolor = "#505050"
		if("black")
			itemcolor = "#000000"
		if("light pink")
			itemcolor = "#FFB6C1"
		if("adamantine")
			itemcolor = "#008B8B"
	add_atom_colour(itemcolor, FIXED_COLOUR_PRIORITY)

/obj/item/slimecrossbeaker //To be used as a result for extract reactions that make chemicals.
	name = "ekstrakt wynikowy"
	desc = "Nie powinieneś tego widzieć."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "base"
	var/del_on_empty = TRUE
	var/list/list_reagents

/obj/item/slimecrossbeaker/Initialize(mapload)
	. = ..()
	create_reagents(50, INJECTABLE | DRAWABLE)
	if(list_reagents)
		for(var/reagent in list_reagents)
			reagents.add_reagent(reagent, list_reagents[reagent])
	if(del_on_empty)
		START_PROCESSING(SSobj,src)

/obj/item/slimecrossbeaker/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/slimecrossbeaker/process()
	if(!reagents.total_volume)
		visible_message("<span class='notice'>[src] został całkowicie wyczerpany i się rozpływa.</span>")
		qdel(src)

/obj/item/slimecrossbeaker/bloodpack //Pack of 50u blood. Deletes on empty.
	name = "ekstrakt krwi"
	desc = "Kula płynnej krwi, która jakimś cudem się nie rozpada."
	color = "#FF0000"
	list_reagents = list(/datum/reagent/blood = 50)

/obj/item/slimecrossbeaker/pax //5u synthpax.
	name = "ekstrakt pokoju"
	desc = "Mała kropla syntetycznego paksu."
	color = "#FFCCCC"
	list_reagents = list(/datum/reagent/pax/peaceborg = 5)

/obj/item/slimecrossbeaker/omnizine //15u omnizine.
	name = "ekstrakt leczniczy"
	desc = "Galaretowaty ekstrakt czystej omnizyny."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/medicine/omnizine = 15)

/obj/item/slimecrossbeaker/autoinjector //As with the above, but automatically injects whomever it is used on with contents.
	var/ignore_flags = FALSE
	var/self_use_only = FALSE

/obj/item/slimecrossbeaker/autoinjector/Initialize(mapload)
	. = ..()
	reagents.flags = DRAWABLE // Cannot be refilled, since it's basically an autoinjector!

/obj/item/slimecrossbeaker/autoinjector/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
		return
	if(!iscarbon(M))
		return
	if(self_use_only && M != user)
		to_chat(user, "<span class='warning'>Możesz tego użyć tylko na sobie.</span>")
		return
	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1)))
		reagents.trans_to(M, reagents.total_volume, transfered_by = user)
		if(user != M)
			to_chat(M, "<span class='warning'>[user] przyciska do ciebie [src]!</span>")
			to_chat(user, "<span class='notice'>Przyciskasz [src] do [M], wstrzykując zawartość.</span>")
		else
			to_chat(user, "<span class='notice'>Przyciskasz [src] do siebie, a on się do ciebie przykleja!</span>")
	else
		to_chat(user, "<span class='warning'>Nie ma gdzie przykleić [src]!</span>")

/obj/item/slimecrossbeaker/autoinjector/regenpack
	ignore_flags = TRUE //It is, after all, intended to heal.
	name = "roztwór gojący"
	desc = "Dziwna grudka słodko pachnącej półpłynnej mazi, która bardzo łatwo przykleja się do skóry."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/medicine/regen_jelly = 20)

/obj/item/slimecrossbeaker/autoinjector/slimejelly //Primarily for slimepeople, but you do you.
	self_use_only = TRUE
	ignore_flags = TRUE
	name = "bańka galaretki ze szlamu"
	desc = "Kula galaretki ze szlamu. Przykleja się do skóry, ale omija inne powierzchnie."
	color = "#00FF00"
	list_reagents = list(/datum/reagent/toxin/slimejelly = 50)

/obj/item/slimecrossbeaker/autoinjector/peaceandlove
	name = "destylat spokoju"
	desc = "Jasnoróżowa, lepka kula. Samo dotknięcie przyprawia o lekkie zawroty głowy."
	color = "#DDAAAA"
	list_reagents = list(/datum/reagent/pax/peaceborg = 10, /datum/reagent/drug/space_drugs = 15) //Peace, dudes

/obj/item/slimecrossbeaker/autoinjector/peaceandlove/Initialize(mapload)
	. = ..()
	reagents.flags = NONE // It won't be *that* easy to get your hands on pax.

/obj/item/slimecrossbeaker/autoinjector/slimestimulant
	name = "żel orzeźwiający"
	desc = "Bulgocząca fioletowa mieszanka, która leczy i przyspiesza ruchy."
	color = "#FF00FF"
	list_reagents = list(/datum/reagent/medicine/regen_jelly = 30, /datum/reagent/drug/methamphetamine = 9)
