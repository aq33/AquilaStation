/obj/item/reagent_containers/pill/patch
	name = "plaster chemiczny"
	desc = "Plaster chemiczny do podawania przez skórę."
	icon = 'icons/obj/medicine_containers.dmi'
	icon_state = "bandaid_small_cross"
	item_state = "bandaid_small_cross"
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 3 SECONDS
	dissolvable = FALSE

/obj/item/reagent_containers/pill/patch/attack(mob/living/L, mob/user, obj/item/bodypart/affecting)
	if(!ishuman(L))
		return ..()
	affecting = L.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		balloon_alert(user, "Brakuje tej kończyny.")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		balloon_alert(user, "[src] nie działa na robotyczne kończyny.")
		return
	return ..()

/obj/item/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	return TRUE // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/reagent_containers/pill/patch/styptic
	name = "plaster na urazy"
	desc = "Pomaga na urazy fizyczne."
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 30)
	icon_state = "bandaid_big_brute"

/obj/item/reagent_containers/pill/patch/silver_sulf
	name = "plaster na oparzenia"
	desc = "Pomaga na oparzenia."
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 30)
	icon_state = "bandaid_big_burn"

/obj/item/reagent_containers/pill/patch/synthflesh
	name = "plaster z syntetycznym ciałem"
	desc = "Pomaga na urazy fizyczne i oparzenia."
	list_reagents = list(/datum/reagent/medicine/synthflesh = 30)
	icon_state = "bandaid_big_both"
