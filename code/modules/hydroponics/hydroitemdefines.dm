// *************************************
// Hydroponics Tools
// *************************************

/obj/item/reagent_containers/spray/weedspray // -- Skie
	desc = "Toksyczna mieszanina w sprayu do zwalczania drobnych chwastów."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "spray na chwasty"
	icon_state = "weedspray"
	item_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 100)

/obj/item/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] wącha [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (TOXLOSS)

/obj/item/reagent_containers/spray/pestspray // -- Skie
	desc = "Spray do zwalczania szkodników! <I>Nie wdychać!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "spray na szkodniki"
	icon_state = "pestspray"
	item_state = "plantbgone"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	volume = 100
	list_reagents = list(/datum/reagent/toxin/pestkiller = 100)

/obj/item/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] wącha [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (TOXLOSS)

/obj/item/cultivator
	name = "pazurki ogrodnicze"
	desc = "Służą do usuwania chwastów albo drapania się po plecach."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cultivator"
	item_state = "cultivator"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=50)
	attack_verb = list("ciacha", "kroi", "tnie", "drapie")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/cultivator/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] drapie się [src] po plecach z całej siły! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (BRUTELOSS)

/obj/item/hatchet
	name = "toporek"
	desc = "Bardzo ostre ostrze topora na krótkim trzonku z włóknometalu. Ma długą historię rąbania różnych rzeczy, ale teraz służy do rąbania drewna."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "hatchet"
	item_state = "hatchet"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 12
	bleed_force = BLEED_CUT
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 15
	throw_speed = 3
	throw_range = 4
	materials = list(/datum/material/iron = 15000)
	attack_verb = list("rąbie", "rozdziera", "tnie")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/hatchet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 70, 100)

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] rąbie samego siebie [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/scythe
	icon_state = "scythe0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "kosa"
	desc = "Ostre, zakrzywione ostrze na długim trzonku z włóknometalu. Z tym narzędziem łatwo zebrać to, co się zasiało."
	force = 13
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	armour_penetration = 20
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("rąbie", "kroi", "tnie", "żnie")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/swiping = FALSE

/obj/item/scythe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 90, 105)

/obj/item/scythe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] ścina sobie głowę [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
		if(BP)
			BP.drop_limb()
			playsound(src,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, 1, -1)
	return (BRUTELOSS)

/obj/item/scythe/pre_attack(atom/A, mob/living/user, params)
	if(swiping || !istype(A, /obj/structure/spacevine) || get_turf(A) == get_turf(user))
		return ..()
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(A))
		swiping = TRUE
		var/static/list/scythe_slash_angles = list(0, 45, 90, -45, -90)
		for(var/i in scythe_slash_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/obj/structure/spacevine/V in T)
				if(user.Adjacent(V))
					melee_attack_chain(user, V)
		swiping = FALSE

// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/reagent_containers/glass/bottle/nutrient
	name = "butelka nawozu"
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "butelka E-Z-Nutrient"
	desc = "Zawiera nawóz, który przy każdym zbiorze powoduje łagodne mutacje."
	list_reagents = list(/datum/reagent/plantnutriment/eznutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/l4z
	name = "butelka Left 4 Zed"
	desc = "Zawiera nawóz, który ogranicza plon do jednej sztuki i powoduje znaczne mutacje roślin."
	list_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/rh
	name = "butelka Robust Harvest"
	desc = "Zawiera nawóz, który zwiększa plon rośliny o 30% bez wywoływania mutacji."
	list_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 50)

/obj/item/reagent_containers/glass/bottle/nutrient/empty
	name = "butelka"

/obj/item/reagent_containers/glass/bottle/killer
	volume = 50
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/reagent_containers/glass/bottle/killer/weedkiller
	name = "butelka środka chwastobójczego"
	desc = "Zawiera herbicyd."
	list_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 50)

/obj/item/reagent_containers/glass/bottle/killer/pestkiller
	name = "butelka pestycydu"
	desc = "Zawiera pestycyd."
	list_reagents = list(/datum/reagent/toxin/pestkiller = 50)
