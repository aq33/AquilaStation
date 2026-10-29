/* This file contains standalone items for debug purposes. */

/obj/item/debug/human_spawner
	name = "spawner ludzi"
	desc = "Wyceluj w pole i kliknij, by stworzyć człowieka. Użyj w ręce, by zmienić gatunek."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "nothingwand"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species

/obj/item/debug/human_spawner/afterattack(atom/target, mob/user, proximity)
	..()
	if(isturf(target))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
		if(selected_species)
			H.set_species(selected_species)

/obj/item/debug/human_spawner/attack_self(mob/user)
	..()
	var/choice = input("Wybierz gatunek", "Spawner ludzi", null) in GLOB.species_list
	selected_species = GLOB.species_list[choice]


/obj/item/debug/omnitool
	name = "omnitool"
	desc = "Oryginalne hipernarzędzie, zrodzone przed wszystkimi innymi. Użyj w ręce, by uwolnić jego prawdziwą moc."
	icon = 'icons/obj/device.dmi'
	icon_state = "hypertool"
	toolspeed = 0.1
	tool_behaviour = null

/obj/item/debug/omnitool/examine()
	. = ..()
	. += " Tryb: [tool_behaviour]"

/obj/item/debug/omnitool/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

///NSV13 - Removed Surgical Drapes from Omnitool, removes attack proc too
/obj/item/debug/omnitool/attack_self(mob/user)
	if(!user)
		return
	var/list/tool_list = list(
		"Łom" = image(icon = 'icons/obj/tools.dmi', icon_state = "crowbar"),
		"Multitool" = image(icon = 'icons/obj/device.dmi', icon_state = "multitool"),
		"Śrubokręt" = image(icon = 'icons/obj/tools.dmi', icon_state = "screwdriver_map"),
		"Przecinak" = image(icon = 'icons/obj/tools.dmi', icon_state = "cutters_map"),
		"Klucz" = image(icon = 'icons/obj/tools.dmi', icon_state = "wrench"),
		"Spawarka" = image(icon = 'icons/obj/tools.dmi', icon_state = "welder"),
		"Analizator" = image(icon = 'icons/obj/device.dmi', icon_state = "analyzer"),
		"Rozwieracz" = image(icon = 'icons/obj/surgery.dmi', icon_state = "retractor"),
		"Szczypce chirurgiczne" = image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat"),
		"Kauter" = image(icon = 'icons/obj/surgery.dmi', icon_state = "cautery"),
		"Wiertło chirurgiczne" = image(icon = 'icons/obj/surgery.dmi', icon_state = "drill"),
		"Skalpel" = image(icon = 'icons/obj/surgery.dmi', icon_state = "scalpel"),
		"Piła chirurgiczna" = image(icon = 'icons/obj/surgery.dmi', icon_state = "saw"),
		"Kilof" = image(icon = 'icons/obj/mining.dmi', icon_state = "minipick"),
		"Łopatka" = image(icon = 'icons/obj/mining.dmi', icon_state = "spade"),
		"Filtr krwi" = image(icon = 'icons/obj/surgery.dmi', icon_state = "bloodfilter"),
		"Szczotka druciana" = image(icon = 'icons/obj/tools.dmi', icon_state = "wirebrush")
	) //NSV13 - Removed surgical drapes

	var/tool_result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(tool_result)
		if("Łom")
			tool_behaviour = TOOL_CROWBAR
		if("Multitool")
			tool_behaviour = TOOL_MULTITOOL
		if("Śrubokręt")
			tool_behaviour = TOOL_SCREWDRIVER
		if("Przecinak")
			tool_behaviour = TOOL_WIRECUTTER
		if("Klucz")
			tool_behaviour = TOOL_WRENCH
		if("Spawarka")
			tool_behaviour = TOOL_WELDER
		if("Analizator")
			tool_behaviour = TOOL_ANALYZER
		//NSV13 - Removed Surgical Drapes from Omnitool
		if("Rozwieracz")
			tool_behaviour = TOOL_RETRACTOR
		if("Szczypce chirurgiczne")
			tool_behaviour = TOOL_HEMOSTAT
		if("Kauter")
			tool_behaviour = TOOL_CAUTERY
		if("Filtr krwi")
			tool_behaviour = TOOL_BLOODFILTER
		if("Wiertło chirurgiczne")
			tool_behaviour = TOOL_DRILL
		if("Skalpel")
			tool_behaviour = TOOL_SCALPEL
		if("Piła chirurgiczna")
			tool_behaviour = TOOL_SAW
		if("Kilof")
			tool_behaviour = TOOL_MINING
		if("Łopatka")
			tool_behaviour = TOOL_SHOVEL
		if("Szczotka druciana")
			tool_behaviour = TOOL_RUSTSCRAPER
