/*
Slimecrossing Armor
	Armor added by the slimecrossing system.
	Collected here for clarity.
*/

//Rebreather mask - Chilling Blue
/obj/item/clothing/mask/nobreath
	name = "maska z recyrkulacją"
	desc = "Przezroczysta maska podobna do zwykłej maski oddechowej, ale zrobiona z niebieskawego szlamu. Nie ma jednak żadnej rurki doprowadzającej powietrze."
	icon_state = "slime"
	item_state = "slime"
	body_parts_covered = NONE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0
	permeability_coefficient = 0.5
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE

/obj/item/clothing/mask/nobreath/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_MASK)
		ADD_TRAIT(user, TRAIT_NOBREATH, "breathmask_[REF(src)]")
		user.failed_last_breath = FALSE
		user.clear_alert("not_enough_oxy")
		user.apply_status_effect(/datum/status_effect/rebreathing)

/obj/item/clothing/mask/nobreath/dropped(mob/living/carbon/human/user)
	..()
	if(user.wear_mask != src)
		return
	else
		REMOVE_TRAIT(user, TRAIT_NOBREATH, "breathmask_[REF(src)]")
		user.remove_status_effect(/datum/status_effect/rebreathing)

/obj/item/clothing/glasses/prism_glasses
	name = "okulary pryzmatyczne"
	desc = "Soczewki lekko świecą i rozszczepiają światło na olśniewające barwy."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "prismglasses"
	actions_types = list(/datum/action/item_action/change_prism_colour, /datum/action/item_action/place_light_prism)
	var/glasses_color = "#FFFFFF"

/obj/item/clothing/glasses/prism_glasses/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/structure/light_prism
	name = "pryzmat świetlny"
	desc = "Lśniący kryształ z półstałego światła. Wygląda na kruchy."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	max_integrity = 10

/obj/structure/light_prism/Initialize(mapload, var/newcolor)
	. = ..()
	color = newcolor
	light_color = newcolor
	set_light(5)

/obj/structure/light_prism/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>Rozpraszasz [src].</span>")
	qdel(src)

/datum/action/item_action/change_prism_colour
	name = "Dostosuj soczewki pryzmatyczne"
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "prismcolor"

/datum/action/item_action/change_prism_colour/Trigger()
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = tgui_color_picker(owner, "Wybierz kolor soczewek:", "Zmiana koloru",glasses.glasses_color)
	if(!new_color)
		return
	glasses.glasses_color = new_color

/datum/action/item_action/place_light_prism
	name = "Wytwórz pryzmat świetlny"
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/place_light_prism/Trigger()
	if(!IsAvailable())
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, "<span class='warning'>Nie ma tu dość energii otoczenia, by wytworzyć kolejny pryzmat światła.</span>")
		return
	if(istype(glasses))
		if(!glasses.glasses_color)
			to_chat(owner, "<span class='warning'>Soczewka jest dziwnie nieprzejrzysta...</span>")
			return
		to_chat(owner, "<span class='notice'>Skupiasz pobliskie światło w świecący, eteryczny pryzmat.</span>")
		new /obj/structure/light_prism(get_turf(owner), glasses.glasses_color)

/obj/item/clothing/head/peaceflower
	name = "pąk heroiny"
	desc = "Skrajnie uzależniający kwiat pełen magii pokoju."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "peaceflower"
	item_state = "peaceflower"
	slot_flags = ITEM_SLOT_HEAD
	clothing_flags = EFFECT_HAT | SNUG_FIT
	body_parts_covered = NONE
	dynamic_hair_suffix = ""
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/clothing/head/peaceflower/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		ADD_TRAIT(user, TRAIT_PACIFISM, "peaceflower_[REF(src)]")

/obj/item/clothing/head/peaceflower/dropped(mob/living/carbon/human/user)
	..()
	if(user.head != src)
		return
	else
		REMOVE_TRAIT(user, TRAIT_PACIFISM, "peaceflower_[REF(src)]")

/obj/item/clothing/head/peaceflower/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, "<span class='warning'>Czujesz spokój. <b style='color:pink'>Czego jeszcze mógłbyś chcieć?</b></span>")
			return
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "pancerz adamantytowy"
	desc = "Pełna adamantytowa zbroja płytowa. Imponująco odporna na obrażenia, ale waży mniej więcej tyle co ty. Zablokowane stawy poruszają się same, więc w tej zbroi nie da się przyspieszyć."
	icon_state = "adamsuit"
	item_state = "adamsuit"
	flags_inv = NONE
	slowdown = 0 //slowdown is handled in the equipped proc
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/heavy/adamantine/equipped(mob/user, slot)
	. = ..()
	user.add_movespeed_modifier(MOVESPEED_ID_SLOW_ARMOR, update=TRUE, priority=100, multiplicative_slowdown= 4)

/obj/item/clothing/suit/armor/heavy/adamantine/dropped(mob/user)
	..()
	user.remove_movespeed_modifier(MOVESPEED_ID_SLOW_ARMOR, TRUE)

/obj/item/clothing/suit/armor/heavy/adamantine/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) && prob(hit_reflect_chance))
		return TRUE
	else
		return FALSE
