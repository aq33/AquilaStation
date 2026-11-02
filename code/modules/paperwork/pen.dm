/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Edaggers
 *		Screwdriver pen
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "Zwykły długopis z czarnym tuszem."
	name = "długopis"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black"	//what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT

/obj/item/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] gryzmoli sobie cyfry po całym ciele za pomocą [src]! Wygląda na to, że próbuje popełnić sudoku...</span>")
	return(BRUTELOSS)

/obj/item/pen/blue
	desc = "Zwykły długopis z niebieskim tuszem."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "Zwykły długopis z czerwonym tuszem."
	icon_state = "pen_red"
	colour = "red"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "Marker z niewidzialnym tuszem."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/fourcolor
	desc = "Elegancki długopis czterokolorowy, ustawiony na czarny tusz."
	name = "długopis czterokolorowy"
	colour = "black"

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
			throw_speed++
		if("red")
			colour = "green"
			throw_speed = initial(throw_speed)
		if("green")
			colour = "blue"
		else
			colour = "black"
	to_chat(user, "<span class='notice'>[src] będzie teraz pisać kolorem: [colour].</span>")
	desc = "Elegancki długopis czterokolorowy, ustawiony na kolor: [colour]."

/obj/item/pen/fountain
	name = "pióro wieczne"
	desc = "Zwykłe pióro wieczne z obudową imitującą drewno."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/charcoal
	name = "rysik węglowy"
	desc = "To tylko drewniany patyk ze sprasowanym popiołem na końcu. Przynajmniej da się nim pisać."
	icon_state = "pen-charcoal"
	colour = "dimgray"
	font = CHARCOAL_FONT
	custom_materials = null

/datum/crafting_recipe/charcoal_stylus
	name = "Rysik węglowy"
	result = /obj/item/pen/charcoal
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1, /datum/reagent/ash = 30)
	time = 30
	category = CAT_PRIMAL


/obj/item/pen/fountain/captain
	name = "pióro wieczne kapitana"
	desc = "Drogie pióro wieczne w wykończeniu dębowym. Stalówka jest dość ostra."
	icon_state = "pen-fountain-o"
	force = 5
	bleed_force = BLEED_SURFACE
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	materials = list(/datum/material/gold = 750)
	sharpness = IS_SHARP
	resistance_flags = FIRE_PROOF
	unique_reskin = list("dąb" = "pen-fountain-o",
						"złoto" = "pen-fountain-g",
						"palisander" = "pen-fountain-r",
						"czerń i srebro" = "pen-fountain-b",
						"błękit dowództwa" = "pen-fountain-cb"
						)
	embedding = list("embed_chance" = 75, "armour_block" = 40)

/obj/item/pen/fountain/captain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 200, 115) //the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "Drogie pióro wieczne (wykończenie: [current_skin]). Stalówka jest dość ostra."

/obj/item/pen/attack_self(mob/living/carbon/user)
	var/deg = input(user, "O jaki kąt chcesz obrócić główkę pióra? (1-360)", "Obróć główkę pióra") as null|num
	if(deg && (deg > 0 && deg <= 360))
		degrees = deg
		to_chat(user, "<span class='notice'>Obracasz górę pióra o [degrees] stopni.</span>")
		SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)

/obj/item/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			to_chat(user, "<span class='warning'>Dźgasz [M] długopisem.</span>")
			if(!stealth)
				to_chat(M, "<span class='danger'>Czujesz maleńkie ukłucie!</span>")
			. = 1

		log_combat(user, M, "stabbed", src)

	else
		. = ..()

/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()
	//Changing Name/Description of items. Only works if they have the 'unique_rename' flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = input(user, "Co chcesz edytować?", "Zmienić nazwę czy opis?") as null|anything in list("Zmień nazwę","Zmień opis")
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		if(penchoice == "Zmień nazwę")
			var/input = stripped_input(user,"Jak chcesz nazwać [O.name]?", ,"", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(oldname == input)
				to_chat(user, "Zmieniasz [O.name] na... cóż... [O.name].")
			else
				O.name = input
				to_chat(user, "Zmieniono nazwę [oldname] na [input].")
				O.renamedByPlayer = TRUE

		if(penchoice == "Zmień opis")
			var/input = stripped_input(user,"Opisz tutaj [O.name]", ,"", 100)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			O.desc = input
			to_chat(user, "Zmieniono opis [O.name].")

/obj/item/pen/get_writing_implement_details()
	return list(
		interaction_mode = MODE_WRITING,
		font = font,
		color = colour,
		use_bold = FALSE,
	)

/*
 * Sleepypens
 */

/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)
				reagents.trans_to(M, reagents.total_volume, transfered_by = user, method = INJECT)


/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb = list("ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie") //these wont show up if the pen is off
	var/on = FALSE

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 60, 100, 0, 'sound/weapons/blade1.ogg', TRUE)

/obj/item/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		throw_speed = initial(throw_speed)
		w_class = initial(w_class)
		name = initial(name)
		hitsound = initial(hitsound)
		embedding = list(embed_chance = EMBED_CHANCE, armour_block = 30)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] można teraz ukryć.</span>")
	else
		on = TRUE
		force = 18
		throw_speed = 4
		w_class = WEIGHT_CLASS_NORMAL
		name = "sztylet energetyczny"
		hitsound = 'sound/weapons/blade1.ogg'
		embedding = list(embed_chance = 200, max_damage_mult = 15, armour_block = 40) //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] jest teraz aktywny.</span>")
	updateEmbedding()
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on
	update_icon()

/obj/item/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)


/*
 * Screwdriver Pen
 */

/obj/item/pen/screwdriver
	var/extended = FALSE
	desc = "Długopis z wysuwaną końcówką śrubokręta. Ten ma żółtą skuwkę."
	icon_state = "pendriver"
	toolspeed = 1.20  // gotta have some downside

/obj/item/pen/screwdriver/attack_self(mob/living/user)
	if(extended)
		extended = FALSE
		w_class = initial(w_class)
		tool_behaviour = initial(tool_behaviour)
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		throw_range = initial(throw_range)
		to_chat(user, "Chowasz śrubokręt.")

	else
		extended = TRUE
		tool_behaviour = TOOL_SCREWDRIVER
		w_class = WEIGHT_CLASS_SMALL  // still can fit in pocket
		force = 4  // copies force from screwdriver
		throwforce = 5
		throw_speed = 3
		throw_range = 5
		to_chat(user, "Wysuwasz śrubokręt.")
	playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE) // click
	update_icon()

/obj/item/pen/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!extended)
		return ..()
	if(!istype(M))
		return ..()
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_HEAD)
		return ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>Nie chcesz zrobić krzywdy [M]!</span>")
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/pen/screwdriver/update_icon()
	if(extended)
		icon_state = "pendriverout"
	else
		icon_state = initial(icon_state)
