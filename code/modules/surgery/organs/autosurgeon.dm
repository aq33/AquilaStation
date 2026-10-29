#define INFINITE -1

/obj/item/autosurgeon
	name = "autochirurg"
	desc = "Urządzenie, które samo wszczepia implant albo organ bez kłopotu z rozległą operacją. Ma otwór na implanty i organy oraz gniazdo na śrubokręt do wyjmowania przypadkowo włożonych przedmiotów."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/list/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/uses = INFINITE
	var/list/starting_organ

/obj/item/autosurgeon/syndicate
	name = "podejrzany autochirurg"
	icon_state = "syndicate_autoimplanter"

/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		storedorgan = list()
		for(var/each in starting_organ)
			insert_organ(new each(src))

/obj/item/autosurgeon/proc/insert_organ(var/obj/item/I)
	storedorgan += I
	I.forceMove(src)

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, "<span class='warning'>[src] zostało już użyte. Narzędzia są tępe i nie uruchomią się ponownie.</span>")
		return
	else if(!storedorgan)
		to_chat(user, "<span class='notice'>[src] nie zawiera obecnie żadnego implantu.</span>")
		return
	for(var/obj/item/organ/each in storedorgan)
		each.Insert(user)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] naciska przycisk na [src] i słyszysz krótki mechaniczny dźwięk.</span>", "<span class='notice'>Czujesz ostre ukłucie, gdy [src] wbija się w twoje ciało.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Wygląda na zużytego."

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] już zawiera implant.</span>")
			return
		else if(!uses)
			to_chat(user, "<span class='notice'>[src] zostało już zużyte.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = list(I)
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
	else
		return ..()

/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, "<span class='notice'>W [src] nie ma implantu do wyjęcia.</span>")
	else
		var/atom/drop_loc = user.drop_location()
		for(var/J in src)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)

		to_chat(user, "<span class='notice'>Wyjmujesz [storedorgan] z [src].</span>")
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Wygląda na zużytego."
	return TRUE

/obj/item/autosurgeon/cmo
	name = "medyczny autochirurg Nanotrasen"
	desc = "Jednorazowy autochirurg z augmentacją HUD medycznego. Można ją wyjąć śrubokrętem, ale implantów nie da się włożyć z powrotem."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/eyes/hud/medical)

/obj/item/autosurgeon/syndicate/laser_arm
	name = "podejrzany autochirurg (implant laserowy w ręce)"
	desc = "Jednorazowy autochirurg z bojową augmentacją laserową w ręce. Można ją wyjąć śrubokrętem, ale implantów nie da się włożyć z powrotem."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/gun/laser)

/obj/item/autosurgeon/syndicate/thermal_eyes
	name = "podejrzany autochirurg (oczy termowizyjne)"
	starting_organ = list(/obj/item/organ/eyes/robotic/thermals)

/obj/item/autosurgeon/syndicate/xray_eyes
	name = "podejrzany autochirurg (oczy rentgenowskie)"
	starting_organ = list(/obj/item/organ/eyes/robotic/xray/syndicate)

/obj/item/autosurgeon/syndicate/anti_stun
	name = "podejrzany autochirurg (implant restartu OUN)"
	starting_organ = list(/obj/item/organ/cyberimp/brain/anti_stun/syndicate)

/obj/item/autosurgeon/syndicate/reviver
	name = "podejrzany autochirurg (implant reanimacyjny)"
	starting_organ = list(/obj/item/organ/cyberimp/chest/reviver/syndicate)

/obj/item/autosurgeon/syndicate/esaw_arm
	name = "podejrzany autochirurg (piła energetyczna w ręce)"
	desc = "Jednorazowy autochirurg z implantem piły energetycznej w ręce."
	uses = 1
	starting_organ = list(/obj/item/organ/cyberimp/arm/esaw)
