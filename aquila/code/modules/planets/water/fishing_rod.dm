// AQUILA - wędki i przynęta: uproszczony port /obj/item/fishing_rod z tg (code/modules/fishing/fishing_rod.dm, ikony
// icons/obj/fishing.dmi i inhandy fishing_rod_*hand.dmi, CC BY-SA 3.0). Wędkę zarzuca się kliknięciem w łowisko w zasięgu
// wzroku (do cast_range pól), tak samo w combat mode i na intencjach. Przynętą jest robak albo dowolne jedzenie
// (kliknięcie jedzeniem w wędkę), zdejmuje się ją, używając wędki w ręce.
// Uproszczenia względem tg: bez wymiennych żyłek i haczyków (ich działanie siedzi w zmiennych wędki), bez umiejętności
// wędkarstwa, wypraw na ryby i rzucania wędką w przedmioty.

/obj/item/fishing_rod
	name = "wędka"
	desc = "Zwykła wędka z kołowrotkiem. Zarzuć ją w łowisko, a kiedy spławik zacznie skakać, kliknij i holuj rybę."
	icon = 'aquila/icons/planets/water/fishing.dmi'
	icon_state = "fishing_rod"
	lefthand_file = 'aquila/icons/planets/water/fishing_rod_lefthand.dmi'
	righthand_file = 'aquila/icons/planets/water/fishing_rod_righthand.dmi'
	item_state = "rod"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 8
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 5
	attack_verb = list("smaga", "chłoszcze")
	custom_materials = list(/datum/material/wood = 2000)
	/// Przynęta (robak albo jedzenie)
	var/obj/item/bait
	/// Dodatek do trudności minigry
	var/difficulty_modifier = 0
	/// Mnożniki minigry: szybkość przynęty przy holowaniu, przyrost postępu, wysokość paska przynęty
	var/bait_speed_mult = 1
	var/completion_speed_mult = 1
	var/bait_height_mult = 1
	/// Żyłka odporna na żar (łowienie w lawie)
	var/heat_resistant = FALSE
	/// Jak daleko można zarzucić
	var/cast_range = 5
	/// Ramka paska minigry (stan z fishing_hud.dmi) i stan kołowrotka
	var/frame_state = "frame_wood"
	var/reel_overlay = "reel_overlay"

/obj/item/fishing_rod/Destroy(force)
	QDEL_NULL(bait)
	return ..()

/obj/item/fishing_rod/examine(mob/user)
	. = ..()
	if(bait)
		. += span_notice("Na haczyku: [bait.name]. Użyj wędki w ręce, żeby ją zdjąć.")
	else
		. += span_notice("Haczyk jest pusty. Przynęta (robak albo jedzenie) przyciąga więcej ryb i ułatwia holowanie.")
	if(heat_resistant)
		. += span_notice("Żyłka jest odporna na żar: da się nią łowić w lawie.")

/obj/item/fishing_rod/update_overlays()
	. = ..()
	. += reel_overlay
	if(bait)
		. += istype(bait, /obj/item/food/fishing_worm) ? "worm_overlay" : "dough_overlay"
	else
		. += "hook_overlay"

/obj/item/fishing_rod/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/fishing_rod/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/food))
		if(bait)
			to_chat(user, span_warning("Na haczyku już jest [bait.name]."))
			return TRUE
		if(!user.transferItemToLoc(attacking_item, src))
			return TRUE
		bait = attacking_item
		to_chat(user, span_notice("Zakładasz [bait.name] na haczyk."))
		update_icon()
		return TRUE
	return ..()

/obj/item/fishing_rod/attack_self(mob/user)
	if(HAS_TRAIT(user, TRAIT_GONE_FISHING))
		return ..()
	if(!bait)
		to_chat(user, span_notice("Haczyk jest pusty."))
		return
	var/obj/item/removed = bait
	bait = null
	removed.forceMove(drop_location())
	user.put_in_hands(removed)
	to_chat(user, span_notice("Zdejmujesz [removed.name] z haczyka."))
	update_icon()

/obj/item/fishing_rod/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == bait)
		bait = null
		update_icon()

/// Przynęta zjedzona przez rybę (po minigrze)
/obj/item/fishing_rod/proc/consume_bait()
	if(!bait)
		return
	QDEL_NULL(bait)
	update_icon()

/obj/item/fishing_rod/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_GONE_FISHING) || !isturf(target) && !isturf(target.loc))
		return
	var/atom/spot = isturf(target) ? target : target.loc
	if(get_dist(user, spot) > cast_range || !(spot in view(cast_range, user)))
		return
	cast_line(spot, user)

/// Zarzuca wędkę w pole: łowisko zaczyna łowienie, inne pola nic nie robią
/obj/item/fishing_rod/proc/cast_line(atom/spot, mob/user)
	SEND_SIGNAL(spot, COMSIG_PRE_FISHING, src, user)
	if(SEND_SIGNAL(spot, COMSIG_FISHING_ROD_CAST, src, user) & FISHING_ROD_CAST_HANDLED)
		return TRUE
	return FALSE

/// Żyłka od wędki do spławika
/obj/item/fishing_rod/proc/create_fishing_line(atom/movable/target, mob/user)
	return user.Beam(target, "fishing_line", 'aquila/icons/planets/water/fishing_line.dmi', INFINITY, cast_range + 2)

/// Wędka zaawansowana: lżejsza, łatwiej się nią holuje, żyłka odporna na żar (lawa)
/obj/item/fishing_rod/tech
	name = "wędka zaawansowana"
	desc = "Wędka z kompozytu z czujnikiem brania i żyłką odporną na żar. Holuje się nią łatwiej, a łowić można nawet w lawie."
	icon_state = "fishing_rod_science"
	reel_overlay = "reel_science"
	frame_state = "frame_science"
	difficulty_modifier = -5
	completion_speed_mult = 1.2
	bait_height_mult = 1.2
	heat_resistant = TRUE
	custom_materials = list(/datum/material/iron = 2000, /datum/material/plastic = 2000, /datum/material/plasma = 500)

/// Robak na przynętę (najlepsza przynęta)
/obj/item/food/fishing_worm
	name = "robak"
	desc = "Tłusty, wijący się robak. Ryby go uwielbiają. Ludzie raczej nie."
	icon = 'aquila/icons/planets/water/fishing.dmi'
	icon_state = "worm"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	tastes = list("ziemia" = 2, "rozpacz" = 1)
	foodtypes = MEAT | GROSS | RAW
	w_class = WEIGHT_CLASS_TINY

/// Puszka z robakami
/obj/item/storage/box/fishing_worms
	name = "puszka z robakami"
	desc = "Puszka pełna robaków na przynętę. Trzymaj z dala od kuchni."
	icon = 'aquila/icons/planets/water/fishing.dmi'
	icon_state = "bait_can"
	illustration = null
	foldable = null

/obj/item/storage/box/fishing_worms/ComponentInitialize()
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	storage.max_items = 10
	storage.can_hold = typecacheof(list(/obj/item/food/fishing_worm))

/obj/item/storage/box/fishing_worms/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/food/fishing_worm(src)

/obj/item/storage/box/fishing_worms/update_icon_state()
	. = ..()
	icon_state = length(contents) ? "bait_can_open" : "bait_can_empty"

/obj/item/storage/box/fishing_worms/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/box/fishing_worms/Exited(atom/movable/gone, direction)
	. = ..()
	update_icon()

/obj/item/storage/box/fishing_worms/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	update_icon()
