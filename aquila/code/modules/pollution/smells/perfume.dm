// AQUILA - Dym i zapachy, port z Monkestation 2.0
/obj/item/perfume
	name = "perfumy"
	desc = "Buteleczka przyjemnie pachnących perfum."
	icon = 'aquila/icons/monke/pollution/perfume.dmi'
	icon_state = "perfume"
	item_state = "cleaner"
	worn_icon_state = "spraybottle"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	/// What type of the pollutant will this perfume be using
	var/fragrance_type
	/// How many uses remaining has it got
	var/uses_remaining = 10
	/// Whether the cap of the perfume is on or off
	var/cap = TRUE
	/// Whether we have a cap or not
	var/has_cap = TRUE

/obj/item/perfume/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/perfume/update_icon_state()
	icon_state = (has_cap && cap) ? "[initial(icon_state)]_cap" : initial(icon_state)
	return ..()

/obj/item/perfume/examine(mob/user)
	. = ..()
	if(uses_remaining)
		. += "Zostało psiknięć: [uses_remaining]."
	else
		. += "Są puste."
	if(has_cap)
		. += span_notice("Alt-klik, żeby [cap ? "zdjąć" : "założyć"] nakrętkę.")

/obj/item/perfume/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE))
		return
	toggle_cap(user)

/obj/item/perfume/attack_self(mob/user)
	toggle_cap(user)

/// Proc to handle removing the cap of the perfume bottle.
/obj/item/perfume/proc/toggle_cap(mob/user)
	if(!has_cap)
		return
	cap = !cap
	to_chat(user, span_notice("[cap ? "Zakładasz" : "Zdejmujesz"] nakrętkę [src]."))
	update_icon()

/obj/item/perfume/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !ismovable(target))
		return
	if(has_cap && cap)
		to_chat(user, span_warning("Najpierw zdejmij nakrętkę!"))
		return
	if(uses_remaining <= 0)
		to_chat(user, span_warning("[src] są puste!"))
		return
	uses_remaining--
	var/turf/my_turf = get_turf(user)
	my_turf.pollute_turf(fragrance_type, 20)
	user.visible_message(span_notice("[user] spryskuje [target] z [src]."), span_notice("Spryskujesz [target] z [src]."))
	user.changeNext_move(CLICK_CD_RANGE*2)
	playsound(my_turf, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	target.AddComponent(/datum/component/temporary_pollution_emission, fragrance_type, 5, 10 MINUTES)

/obj/item/perfume/cologne
	name = "woda kolońska"
	desc = "Ta na pewno przyciągnie uwagę."
	fragrance_type = /datum/pollutant/fragrance/cologne

/obj/item/perfume/wood
	name = "perfumy drzewne"
	fragrance_type = /datum/pollutant/fragrance/wood

/obj/item/perfume/rose
	name = "perfumy różane"
	fragrance_type = /datum/pollutant/fragrance/rose

/obj/item/perfume/jasmine
	name = "perfumy jaśminowe"
	fragrance_type = /datum/pollutant/fragrance/jasmine

/obj/item/perfume/mint
	name = "perfumy miętowe"
	fragrance_type = /datum/pollutant/fragrance/mint

/obj/item/perfume/vanilla
	name = "perfumy waniliowe"
	fragrance_type = /datum/pollutant/fragrance/vanilla

/obj/item/perfume/pear
	name = "perfumy gruszkowe"
	fragrance_type = /datum/pollutant/fragrance/pear

/obj/item/perfume/strawberry
	name = "perfumy truskawkowe"
	fragrance_type = /datum/pollutant/fragrance/strawberry

/obj/item/perfume/cherry
	name = "perfumy wiśniowe"
	fragrance_type = /datum/pollutant/fragrance/cherry

/obj/item/perfume/amber
	name = "perfumy bursztynowe"
	fragrance_type = /datum/pollutant/fragrance/amber

/// Monke kept this box in the barber vendor, we sell it in ClothesMate
/obj/item/storage/box/perfume
	name = "pudełko perfum"
	desc = "Zestaw perfum na każdą okazję."

/obj/item/storage/box/perfume/PopulateContents()
	new /obj/item/perfume/cologne(src)
	new /obj/item/perfume/wood(src)
	new /obj/item/perfume/rose(src)
	new /obj/item/perfume/jasmine(src)
	new /obj/item/perfume/mint(src)
	new /obj/item/perfume/vanilla(src)
	new /obj/item/perfume/pear(src)
	new /obj/item/perfume/strawberry(src)
	new /obj/item/perfume/cherry(src)
	new /obj/item/perfume/amber(src)
