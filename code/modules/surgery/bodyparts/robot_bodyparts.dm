#define ROBOTIC_LIGHT_BRUTE_MSG "marred"
#define ROBOTIC_MEDIUM_BRUTE_MSG "dented"
#define ROBOTIC_HEAVY_BRUTE_MSG "falling apart"

#define ROBOTIC_LIGHT_BURN_MSG "scorched"
#define ROBOTIC_MEDIUM_BURN_MSG "charred"
#define ROBOTIC_HEAVY_BURN_MSG "smoldering"

//For ye whom may venture here, split up arm / hand sprites are formatted as "l_hand" & "l_arm".
//The complete sprite (displayed when the limb is on the ground) should be named "borg_l_arm".
//Failure to follow this pattern will cause the hand's icons to be missing due to the way get_limb_icon() works to generate the mob's icons using the aux_zone var.

/obj/item/bodypart/l_arm/robot
	name = "lewa ręka cyborga"
	desc = "Szkieletowa kończyna owinięta pseudomięśniami, w obudowie o niskim przewodnictwie."
	limb_id = "robotic"
	attack_verb = list("policzkuje", "uderza pięścią")
	item_state = "buildpipe"
	static_icon =  'icons/mob/augmentation/augments.dmi'
	icon = null
	flags_1 = CONDUCT_1
	icon_state = "borg_l_arm"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/r_arm/robot
	name = "prawa ręka cyborga"
	desc = "Szkieletowa kończyna owinięta pseudomięśniami, w obudowie o niskim przewodnictwie."
	attack_verb = list("policzkuje", "uderza pięścią")
	item_state = "buildpipe"
	static_icon =  'icons/mob/augmentation/augments.dmi'
	icon = null
	limb_id = "robotic"
	flags_1 = CONDUCT_1
	icon_state = "borg_r_arm"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/l_leg/robot
	name = "lewa noga cyborga"
	desc = "Szkieletowa kończyna owinięta pseudomięśniami, w obudowie o niskim przewodnictwie."
	attack_verb = list("kopie", "depcze")
	item_state = "buildpipe"
	static_icon =  'icons/mob/augmentation/augments.dmi'
	icon = null
	limb_id = "robotic"
	flags_1 = CONDUCT_1
	icon_state = "borg_l_leg"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/r_leg/robot
	name = "prawa noga cyborga"
	desc = "Szkieletowa kończyna owinięta pseudomięśniami, w obudowie o niskim przewodnictwie."
	attack_verb = list("kopie", "depcze")
	item_state = "buildpipe"
	static_icon =  'icons/mob/augmentation/augments.dmi'
	icon = null
	limb_id = "robotic"
	flags_1 = CONDUCT_1
	icon_state = "borg_r_leg"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/chest/robot
	name = "tułów cyborga"
	desc = "Mocno wzmocniona obudowa z płytami logicznymi cyborga i miejscem na standardowe ogniwo zasilające."
	item_state = "buildpipe"
	static_icon =  'icons/mob/augmentation/augments.dmi'
	icon = null
	limb_id = "robotic"
	flags_1 = CONDUCT_1
	icon_state = "borg_chest"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	var/wired = FALSE
	var/obj/item/stock_parts/cell/cell = null

/obj/item/bodypart/chest/robot/get_cell()
	return cell

/obj/item/bodypart/chest/robot/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
	return ..()

/obj/item/bodypart/chest/robot/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/bodypart/chest/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='warning'>Ogniwo jest już włożone!</span>")
			return
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>Wkładasz ogniwo.</span>")
	else if(istype(W, /obj/item/stack/cable_coil))
		if(wired)
			to_chat(user, "<span class='warning'>Przewód jest już włożony!</span>")
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			wired = TRUE
			to_chat(user, "<span class='notice'>Wkładasz przewód.</span>")
		else
			to_chat(user, "<span class='warning'>Do okablowania potrzebujesz odcinka kabla!</span>")
	else
		return ..()

/obj/item/bodypart/chest/robot/wirecutter_act(mob/living/user, obj/item/I)
	if(!wired)
		return
	. = TRUE
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>Wycinasz przewody z [src].</span>")
	new /obj/item/stack/cable_coil(drop_location(), 1)
	wired = FALSE

/obj/item/bodypart/chest/robot/screwdriver_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(!cell)
		to_chat(user, "<span class='warning'>W [src] nie ma zainstalowanego ogniwa zasilającego!</span>")
		return
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>Wyjmij [cell] z [src].</span>")
	cell.forceMove(drop_location())
	cell = null


/obj/item/bodypart/chest/robot/examine(mob/user)
	. = ..()
	if(cell)
		. += "Ma włożone [cell].\n"+\
		"<span class='info'>Możesz wyjąć [cell] <b>śrubokrętem</b>.</span>"
	else
		. += "<span class='info'>Ma pusty port na <b>ogniwo zasilające</b>.</span>"
	if(wired)
		. += "Jest w pełni okablowany[cell ? " i gotowy do użycia" : ""].\n"+\
		"<span class='info'>Możesz usunąć okablowanie <b>nożycami do drutu</b>.</span>"
	else
		. += "<span class='info'>Ma kilka miejsc, które wciąż trzeba <b>okablować</b>.</span>"

/obj/item/bodypart/chest/robot/drop_organs(mob/user, violent_removal)
	if(wired)
		new /obj/item/stack/cable_coil(drop_location(), 1)
		wired = FALSE
	if(cell)
		cell.forceMove(drop_location())
		cell = null
	..()


/obj/item/bodypart/head/robot
	name = "głowa cyborga"
	desc = "Standardowa wzmocniona puszka mózgowa z gniazdem neuronowym podłączanym do kręgosłupa i przegubami czujników."
	item_state = "buildpipe"
	static_icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = "robotic"
	icon = null
	flags_1 = CONDUCT_1
	icon_state = "borg_head"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	var/obj/item/assembly/flash/handheld/flash1 = null
	var/obj/item/assembly/flash/handheld/flash2 = null


/obj/item/bodypart/head/robot/handle_atom_del(atom/A)
	if(A == flash1)
		flash1 = null
	if(A == flash2)
		flash2 = null
	return ..()

/obj/item/bodypart/head/robot/Destroy()
	QDEL_NULL(flash1)
	QDEL_NULL(flash2)
	return ..()

/obj/item/bodypart/head/robot/examine(mob/user)
	. = ..()
	if(!flash1 && !flash2)
		. += "<span class='info'>Ma dwa puste oczodoły na <b>flashe</b>.</span>"
	else
		var/single_flash = FALSE
		if(!flash1 || !flash2)
			single_flash = TRUE
			. += "Jeden z oczodołów jest zajęty przez flash.\n"+\
			"<span class='info'>Ma pusty oczodół na kolejny <b>flash</b>.</span>"
		else
			. += "Oba oczodoły są zajęte przez flashe."
		. += "<span class='notice'>[single_flash ? "Osadzony flash możesz" : "Osadzone flashe możesz"] wyjąć <b>łomem</b>.</span>"

/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/F = W
		if(flash1 && flash2)
			to_chat(user, "<span class='warning'>Oczy są już włożone!</span>")
			return
		else if(F.burnt_out || !F.bulb)
			to_chat(user, "<span class='warning'>Potrzebujesz sprawnego flasha!</span>")
			return
		else
			if(!user.transferItemToLoc(F, src))
				return
			if(flash1)
				flash2 = F
			else
				flash1 = F
			to_chat(user, "<span class='notice'>Wkładasz flash do oczodołu.</span>")
			return
	return ..()

/obj/item/bodypart/head/robot/crowbar_act(mob/living/user, obj/item/I)
	if(flash1 || flash2)
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>Wyjmujesz flash z [src].</span>")
		if(flash1)
			flash1.forceMove(drop_location())
			flash1 = null
		if(flash2)
			flash2.forceMove(drop_location())
			flash2 = null
	else
		to_chat(user, "<span class='warning'>W [src] nie ma flasha do wyjęcia.</span>")
	return TRUE


/obj/item/bodypart/head/robot/drop_organs(mob/user, violent_removal)
	if(flash1)
		flash1.forceMove(user.loc)
		flash1 = null
	if(flash2)
		flash2.forceMove(user.loc)
		flash2 = null
	..()




/obj/item/bodypart/l_arm/robot/surplus
	name = "tania proteza lewej ręki"
	desc = "Szkieletowa, robotyczna kończyna. Przestarzała i krucha, ale wciąż lepsza niż nic."
	static_icon =  'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20

/obj/item/bodypart/r_arm/robot/surplus
	name = "tania proteza prawej ręki"
	desc = "Szkieletowa, robotyczna kończyna. Przestarzała i krucha, ale wciąż lepsza niż nic."
	static_icon =  'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20

/obj/item/bodypart/l_leg/robot/surplus
	name = "tania proteza lewej nogi"
	desc = "Szkieletowa, robotyczna kończyna. Przestarzała i krucha, ale wciąż lepsza niż nic."
	static_icon =  'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20

/obj/item/bodypart/r_leg/robot/surplus
	name = "tania proteza prawej nogi"
	desc = "Szkieletowa, robotyczna kończyna. Przestarzała i krucha, ale wciąż lepsza niż nic."
	static_icon =  'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20


#undef ROBOTIC_LIGHT_BRUTE_MSG
#undef ROBOTIC_MEDIUM_BRUTE_MSG
#undef ROBOTIC_HEAVY_BRUTE_MSG

#undef ROBOTIC_LIGHT_BURN_MSG
#undef ROBOTIC_MEDIUM_BURN_MSG
#undef ROBOTIC_HEAVY_BURN_MSG
