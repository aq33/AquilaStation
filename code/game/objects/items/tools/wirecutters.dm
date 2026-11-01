/obj/item/wirecutters
	name = "przecinak do drutu"
	desc = "Tnie przewody."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters_map"
	item_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 6
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=80)
	attack_verb = list("szczypie", "podgryza")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	drop_sound = 'sound/items/handling/wirecutter_drop.ogg'
	pickup_sound =  'sound/items/handling/wirecutter_pickup.ogg'
	tool_behaviour = TOOL_WIRECUTTER
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0, "bleed" = 0)
	var/random_color = TRUE
	var/static/list/wirecutter_colors = list(
		"blue" = "#1861d5",
		"red" = "#951710",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#d58c18"
	)


/obj/item/wirecutters/Initialize(mapload)
	. = ..()
	if(random_color) //random colors! AQUILA EDIT - Paradise sprites instead of tinting
		icon = 'icons/obj/tools.dmi' // AQ EDIT - pcutters_* live only in core tools.dmi, aquila/ overrides icon
		var/our_color = pick("", "_red", "_yellow")
		icon_state = "pcutters_cutters[our_color]"
		item_state = "cutters[our_color || "_red"]" // AQ EDIT - inhand/belt states exist only for red and yellow
		belt_icon_state = item_state

/obj/item/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/restraints/handcuffs/cable))
		user.visible_message("<span class='notice'>[user] przecina więzy [C] za pomocą [src]!</span>")
		qdel(C.handcuffed)
		return
	else if(istype(C) && C.has_status_effect(STATUS_EFFECT_CHOKINGSTRAND))
		to_chat(C, "<span class='notice'>Próbujesz zdjąć z szyi pasmo durathreadu.</span>")
		if(do_after(user, 15, null, C))
			to_chat(C, "<span class='notice'>Udaje ci się zdjąć pasmo durathreadu.</span>")
			C.remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)
	else
		..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] przecina sobie tętnice [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(loc, usesound, 50, 1, -1)
	return (BRUTELOSS)

/obj/item/wirecutters/brass
	name = "mosiężny przecinak do drutu"
	desc = "Przecinak do drutu z mosiądzu. Rękojeść jest lodowato zimna w dotyku."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "cutters_brass"
	random_color = FALSE
	toolspeed = 0.5

/obj/item/wirecutters/abductor
	name = "obcy przecinak do drutu"
	desc = "Niesamowicie ostry przecinak do drutu ze srebrzystozielonego metalu."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cutters"
	toolspeed = 0.1

	random_color = FALSE

/obj/item/wirecutters/cyborg
	name = "elektryczny przecinak do drutu"
	desc = "Tnie przewody mocą ELEKTRYCZNOŚCI. Szybszy od zwykłego przecinaka."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wirecutters_cyborg"
	toolspeed = 0.5
	random_color = FALSE
